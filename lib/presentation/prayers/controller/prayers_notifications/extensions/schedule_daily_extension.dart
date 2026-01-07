part of '../../../prayers.dart';

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

    int notificationId = prayerIndex;
    int daysToSchedule = Platform.isIOS ? 10 : 30;

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

      notificationId += 5;

      if (Platform.isAndroid && day >= 30) break;
      if ((Platform.isIOS || Platform.isMacOS) && day >= 10) break;
    }

    if (lastPrayerTime != null) {
      DateTime reminderTime = lastPrayerTime.add(const Duration(minutes: 5));
      await NotifyHelper().scheduledNotification(
        reminderId: notificationId + 1000,
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
        Future.microtask(() async {
          await PrayersNotificationsCtrl.instance
              .scheduleDailyNotificationsForPrayer(
                  prayer.index, prayerName, notificationType);
        });
      }
    }

    // إعادة جدولة إشعارات الصيام (السحور/الإفطار/العشر الأواخر)
    Future.microtask(() async {
      await RamadanController.instance.rescheduleFastingNotifications();
    });
  }

  Future<void> cancelAllPrayerNotifications() async {
    const prayerNotificationIds = <int>[0, 2, 3, 4, 5];
    for (final id in prayerNotificationIds) {
      await NotifyHelper().cancelNotification(id);
    }
    log('تم إلغاء جميع إشعارات الصلاة.', name: 'ScheduleDailyExtension');
  }

  Future<void> cancelPrayerNotificationsForAllDay(
      int prayerNotificationId) async {
    final dayLength = Platform.isAndroid ? 61 : 10;
    for (int i = 0; i < dayLength; i++) {
      await NotifyHelper().cancelNotification(prayerNotificationId);
      prayerNotificationId += 5;
    }
    log('تم إلغاء جميع إشعارات صلاة $prayerNotificationId.',
        name: 'ScheduleDailyExtension');
  }
}
