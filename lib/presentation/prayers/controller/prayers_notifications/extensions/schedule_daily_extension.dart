part of '../../../prayers.dart';

const int _kPrayerNotificationsBaseId = 20000;
const int _kPrayerNotificationsDayStride = 10;
const int _kPrayerOpenAppReminderBaseId = 21000;
const String _kLegacyPrayerNotificationsCancelledFlag =
    'legacy_prayer_notifications_cancelled_v2';

int _prayerKeyFromIndex(int prayerIndex) {
  switch (prayerIndex) {
    case 0:
      return 0; // Fajr
    case 2:
      return 1; // Dhuhr
    case 3:
      return 2; // Asr
    case 4:
      return 3; // Maghrib
    case 5:
      return 4; // Isha
    default:
      throw ArgumentError.value(prayerIndex, 'prayerIndex', 'Unsupported');
  }
}

int _scheduledPrayerNotificationId({required int prayerKey, required int day}) {
  return _kPrayerNotificationsBaseId +
      (day * _kPrayerNotificationsDayStride) +
      prayerKey;
}

int _openAppReminderIdForPrayer(int prayerKey) {
  return _kPrayerOpenAppReminderBaseId + prayerKey;
}

int _daysToSchedule() {
  // مطابقة للمنطق الحالي: iOS/macOS أقل لتجنب الحدود.
  return (Platform.isIOS || Platform.isMacOS) ? 10 : 30;
}

Future<void> _cancelLegacyPrayerNotificationsForPrayerIndex(
    int prayerIndex) async {
  // النظام القديم كان يعتمد: baseId ثم +5 لكل يوم.
  final dayLength = Platform.isAndroid ? 61 : 10;
  for (int i = 0; i < dayLength; i++) {
    final legacyBaseId = prayerIndex + (5 * i);
    await NotifyHelper().cancelNotification(legacyBaseId);

    // في بعض الإصدارات كان iOS يرسل "الأذان الكامل" عبر عدة إشعارات متتالية.
    if (Platform.isIOS) {
      for (int offset = 1; offset <= 6; offset++) {
        await NotifyHelper().cancelNotification(legacyBaseId + offset);
      }
    }
  }

  // تذكير "افتح التطبيق" في النظام القديم كان: 1000 + (baseId + 5*n)
  // (نبدأ من 1 لتجنب المساس بـ 1000/1001 الخاصين برمضان).
  for (int n = 1; n <= dayLength; n++) {
    await NotifyHelper().cancelNotification(1000 + prayerIndex + (5 * n));
  }
}

Future<void> _cancelLegacyPrayerNotificationsIfNeeded() async {
  final storage = GetStorage();
  final alreadyCancelled =
      storage.read<bool>(_kLegacyPrayerNotificationsCancelledFlag) ?? false;
  if (alreadyCancelled) return;

  const prayerIndexes = <int>[0, 2, 3, 4, 5];
  for (final prayerIndex in prayerIndexes) {
    await _cancelLegacyPrayerNotificationsForPrayerIndex(prayerIndex);
  }

  await storage.write(_kLegacyPrayerNotificationsCancelledFlag, true);
  log('Legacy prayer notification IDs cancelled (migration)',
      name: 'ScheduleDailyExtension');
}

extension ScheduleDailyExtension on PrayersNotificationsCtrl {
  Future<void> scheduleDailyNotificationsForPrayer(
      int prayerIndex, String prayerName, String notificationType) async {
    final athanCtrl = AdhanController.instance;
    if ('nothing' == notificationType) {
      GetStorage('AdhanSounds').remove('scheduledAdhan_$prayerName');
      log('منبة صلاة $prayerName removed', name: 'ScheduleDailyExtension');
      return cancelPrayerNotificationsForAllDay(prayerIndex);
    }
    GetStorage('AdhanSounds')
        .write('scheduledAdhan_$prayerName', notificationType);

    if (athanCtrl.state.prayerTimes == null ||
        athanCtrl.state.sunnahTimes == null) {
      return;
    }

    final prayerKey = _prayerKeyFromIndex(prayerIndex);
    final daysToSchedule = _daysToSchedule();

    DateTime? lastPrayerTime;
    final now = DateTime.now();

    for (int day = 0; day < daysToSchedule; day++) {
      DateComponents dateComponents =
          DateComponents.from(DateTime.now().add(Duration(days: day)));

      PrayerTimes prayerTimes = PrayerTimes(
        athanCtrl.state.coordinates,
        dateComponents,
        athanCtrl.state.params,
      );

      late final DateTime prayerTime;
      Prayer selectedPrayer;
      String selectedBody;

      switch (prayerIndex) {
        case 0:
          selectedPrayer = Prayer.fajr;
          prayerTime = prayerTimes.fajr;
          selectedBody = 'fajrBody';
          break;
        case 2:
          selectedPrayer = Prayer.dhuhr;
          prayerTime = prayerTimes.dhuhr;
          selectedBody = 'dhuhrBody';
          break;
        case 3:
          selectedPrayer = Prayer.asr;
          prayerTime = prayerTimes.asr;
          selectedBody = 'asrBody';
          break;
        case 4:
          selectedPrayer = Prayer.maghrib;
          prayerTime = prayerTimes.maghrib;
          selectedBody = 'maghribBody';
          break;
        case 5:
          selectedPrayer = Prayer.isha;
          prayerTime = prayerTimes.isha;
          selectedBody = 'ishaBody';
          break;
        default:
          return;
      }

      // لا تُجدول إشعارًا بوقتٍ ماضٍ. إذا كانت صلاة اليوم قد فاتت، انتقل لليوم التالي.
      if (prayerTime.isBefore(now)) {
        log(
          'Skip past prayer time for ${athanCtrl.prayerNameFromEnum(selectedPrayer).tr}: $prayerTime',
          name: 'ScheduleDailyExtension',
        );
        continue;
      }

      final notificationId = _scheduledPrayerNotificationId(
        prayerKey: prayerKey,
        day: day,
      );

      /// this code is for full athan on ios
      // if (Platform.isIOS) {
      //   for (int i = 1; i <= 6; i++) {
      //     DateTime nextNotificationTime =
      //         prayerTime.add(Duration(seconds: 30 * i));
      //     await NotifyHelper().scheduledNotification(
      //       notificationId + i,
      //       athanCtrl.prayerNameFromEnum(selectedPrayer).tr,
      //       'وقت صلاة ${athanCtrl.prayerNameFromEnum(selectedPrayer).tr}',
      //       'حان الآن موعد صلاة ${athanCtrl.prayerNameFromEnum(selectedPrayer).tr}',
      //       false,
      //       time: nextNotificationTime,
      //       payload: {'sound_type': notificationType},
      //       soundIndex: i + 1,
      //     );
      //   }
      // } else {
      await NotifyHelper().scheduledNotification(
          reminderId: notificationId,
          title: athanCtrl.prayerNameFromEnum(selectedPrayer).tr,
          summary:
              '${'timeForPrayer'.tr} ${athanCtrl.prayerNameFromEnum(selectedPrayer).tr}',
          body: selectedBody.tr,
          isRepeats: false,
          time: prayerTime,
          payload: {'sound_type': notificationType},
          soundIndex: 1);
      // }

      log('تم جدولة صلاة ${athanCtrl.prayerNameFromEnum(selectedPrayer).tr}',
          name: 'ScheduleDailyExtension');
      log('notificationId: $notificationId', name: 'ScheduleDailyExtension');
      // log('موعد صلاة ${DateFormatter.formatPrayerTime(prayerTime).tr}');

      lastPrayerTime = prayerTime;
    }

    if (lastPrayerTime != null) {
      DateTime reminderTime = lastPrayerTime.add(const Duration(minutes: 5));
      await NotifyHelper().scheduledNotification(
        reminderId: _openAppReminderIdForPrayer(prayerKey),
        title: 'reminder'.tr,
        summary: 'openAppReminderTitle'.tr,
        body: 'openAppReminderBody'.tr,
        isRepeats: false,
        time: reminderTime,
        payload: {'sound_type': 'bell'},
      );

      log('تم جدولة تذكير بعد آخر صلاة بـ ٥ دقائق');
      // log('موعد التذكير ${DateFormatter.formatPrayerTime(reminderTime)}');
    }
  }

  // Future<void> fullAthanForIos(
  //     LocalReceivedNotification receivedNotification) async {
  //   if (Platform.isIOS) {
  //     for (int i = 1; i <= 6; i++) {
  //       DateTime nextNotificationTime =
  //           DateTime.now().add(Duration(seconds: 30 * i));
  //       await NotifyHelper().scheduledNotification(
  //           reminderId: receivedNotification.id + i + 1,
  //           title: receivedNotification.title,
  //           summary: receivedNotification.summary,
  //           body: receivedNotification.body,
  //           isRepeats: false,
  //           time: nextNotificationTime,
  //           payload: receivedNotification.payload,
  //           soundIndex: i + 1);
  //     }
  //   }
  // }

  Future<void> reschedulePrayers() async {
    log('إعادة جدولة إشعارات الصلوات اليومية...',
        name: 'ScheduleDailyExtension');

    // تنظيف IDs القديمة مرة واحدة بعد التحديث لتفادي الإشعارات المكررة.
    await _cancelLegacyPrayerNotificationsIfNeeded();
    final adhanStorage = GetStorage('AdhanSounds');
    const prayers = <({int index, String name})>[
      (index: 0, name: 'Fajr'),
      (index: 2, name: 'Dhuhr'),
      (index: 3, name: 'Asr'),
      (index: 4, name: 'Maghrib'),
      (index: 5, name: 'Isha'),
    ];

    await cancelAllPrayerNotifications();

    for (final prayer in prayers) {
      final prayerName = prayer.name;
      final String? notificationType =
          adhanStorage.read('scheduledAdhan_$prayerName');
      log('notification: $notificationType', name: 'ScheduleDailyExtension');

      if (notificationType != null && notificationType != 'nothing') {
        await PrayersNotificationsCtrl.instance
            .scheduleDailyNotificationsForPrayer(
          prayer.index,
          prayerName,
          notificationType,
        );
      }
    }

    // إعادة جدولة إشعارات الصيام (السحور/الإفطار/العشر الأواخر)
    await RamadanController.instance.rescheduleFastingNotifications();
  }

  Future<void> cancelAllPrayerNotifications() async {
    const prayerIndexes = <int>[0, 2, 3, 4, 5];

    // تنظيف الجداول القديمة (مرة واحدة) لتفادي تداخل الإصدارات.
    await _cancelLegacyPrayerNotificationsIfNeeded();

    final daysToCancel = _daysToSchedule();
    for (int day = 0; day < daysToCancel; day++) {
      for (final prayerIndex in prayerIndexes) {
        final prayerKey = _prayerKeyFromIndex(prayerIndex);
        final id =
            _scheduledPrayerNotificationId(prayerKey: prayerKey, day: day);
        await NotifyHelper().cancelNotification(id);
      }
    }

    for (int prayerKey = 0; prayerKey < 5; prayerKey++) {
      await NotifyHelper()
          .cancelNotification(_openAppReminderIdForPrayer(prayerKey));
    }

    log('تم إلغاء جميع إشعارات الصلاة.', name: 'ScheduleDailyExtension');
  }

  Future<void> cancelPrayerNotificationsForAllDay(
      int prayerNotificationId) async {
    final originalPrayerIndex = prayerNotificationId;

    // تنظيف من النظام القديم.
    await _cancelLegacyPrayerNotificationsForPrayerIndex(originalPrayerIndex);

    final prayerKey = _prayerKeyFromIndex(originalPrayerIndex);
    final daysToCancel = _daysToSchedule();
    for (int day = 0; day < daysToCancel; day++) {
      final id = _scheduledPrayerNotificationId(prayerKey: prayerKey, day: day);
      await NotifyHelper().cancelNotification(id);
    }
    await NotifyHelper()
        .cancelNotification(_openAppReminderIdForPrayer(prayerKey));

    log('تم إلغاء جميع إشعارات صلاة $originalPrayerIndex.',
        name: 'ScheduleDailyExtension');
  }

  /// إلغاء IDs القديمة مرة واحدة بعد التحديث.
  Future<void> cancelLegacyPrayerNotificationsIfNeeded() async {
    await _cancelLegacyPrayerNotificationsIfNeeded();
  }
}
