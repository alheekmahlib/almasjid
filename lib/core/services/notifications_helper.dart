import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get_storage/get_storage.dart';

import '../../presentation/prayers/prayers.dart';
import '../utils/constants/lists.dart';
import '../utils/constants/shared_preferences_constants.dart';
import '../widgets/local_notification/controller/local_notifications_controller.dart';
import 'macos_notifications_service.dart';

class NotifyHelper {
  static bool _initialized = false;
  String get audioPath =>
      GetStorage('AdhanSounds').read<String?>(ADHAN_PATH) ??
      'resource://raw/aqsa_athan';
  String get audioFajirPath =>
      GetStorage('AdhanSounds').read<String?>(ADHAN_PATH_FAJIR) ??
      'resource://raw/aqsa_athan_fajir';

  static const String _permissionFlagKey = 'notifications_permission_granted';
  static const String _notificationSetupSeenKey = 'notification_setup_seen';

  bool get isAllowed => GetStorage().read<bool>(_permissionFlagKey) ?? false;

  /// تحقق مما إذا كان المستخدم قد شاهد شاشة تفعيل الإشعارات من قبل
  bool get hasSeenNotificationSetup =>
      GetStorage().read<bool>(_notificationSetupSeenKey) ?? false;

  /// تعيين أن المستخدم قد شاهد شاشة تفعيل الإشعارات
  void markNotificationSetupAsSeen() {
    GetStorage().write(_notificationSetupSeenKey, true);
    log('Marked notification setup as seen', name: 'NotifyHelper');
  }

  // تحديد الصوت المخصص للإشعار بناءً على نوع الصوت المحدد
  // Custom sound selection based on specified sound type
  String customSound(Map<String, String?> payload, int reminderId) {
    String? soundType = payload['sound_type'];

    switch (soundType) {
      case 'nothing':
      case 'silent':
        return 'resource://raw/silence';
      case 'bell':
        return 'resource://raw/notification';
      case 'sound':
        return reminderId == 0 ? audioFajirPath : audioPath;
      default:
        return 'resource://raw/notification';
    }
  }

  // جدولة الإشعار مع الصوت المخصص
  // Schedule notification with custom sound
  Future<void> scheduledNotification({
    required int reminderId,
    required String title,
    required String summary,
    required String body,
    required bool isRepeats,
    DateTime? time,
    Map<String, String?>? payload,
    int? soundIndex,
  }) async {
    payload ??= {'sound_type': 'bell'};

    // macOS: استخدام flutter_local_notifications
    if (Platform.isMacOS) {
      await _scheduleMacOSNotification(
        id: reminderId,
        title: title,
        body: body,
        time: time,
        soundType: payload['sound_type'],
        isFajr: reminderId == 0,
      );
      return;
    }

    // iOS/Android: استخدام awesome_notifications
    if (!_initialized) {
      initAwesomeNotifications();
    }
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    // تحديد القناة المناسبة بناءً على نوع الصوت
    // Select appropriate channel based on sound type
    String channelKey = _getChannelKey(payload['sound_type']);

    try {
      log('audioPath: $audioPath', name: 'NotifyHelper');
      log('sound_type: ${payload['sound_type']}', name: 'NotifyHelper');
      log('channelKey: $channelKey', name: 'NotifyHelper');

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminderId,
          groupKey: 'prayers_notifications_ak$reminderId',
          channelKey: channelKey,
          actionType: ActionType.Default,
          title: title,
          summary: summary,
          body: body,
          payload: payload,
          customSound: customSound(payload, reminderId),
          wakeUpScreen: true,
          badge: LocalNotificationsController.instance.unreadCount,
        ),
        schedule: time != null
            ? NotificationCalendar.fromDate(date: time, repeats: isRepeats)
            : NotificationInterval(
                interval: const Duration(minutes: 2),
                timeZone: localTimeZone,
                repeats: false),
      );
      log('Notification successfully scheduled', name: 'NotifyHelper');
    } catch (e) {
      log('Error scheduling notification: $e', name: 'NotifyHelper');
    }
  }

  /// جدولة إشعار macOS
  Future<void> _scheduleMacOSNotification({
    required int id,
    required String title,
    required String body,
    DateTime? time,
    String? soundType,
    bool isFajr = false,
  }) async {
    final service = MacOSNotificationsService.instance;
    await service.initialize();

    if (time != null) {
      await service.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: time,
        soundType: soundType,
        isFajr: false,
      );
    } else {
      await service.showNotification(
        id: id,
        title: title,
        body: body,
        soundType: soundType,
        isFajr: false,
      );
    }
  }

  // تحديد القناة المناسبة بناءً على نوع الصوت
  // Determine appropriate channel based on sound type
  String _getChannelKey(String? soundType) {
    switch (soundType) {
      case 'sound':
        return 'prayers_notifications_channel_ak';
      case 'bell':
      case 'nothing':
      case 'silent':
      default:
        return 'prayers_notifications_channel_ak_notification';
    }
  }

  static void initAwesomeNotifications() {
    if (_initialized) return;
    AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak',
          channelName: 'Prayer Times Notifications',
          channelDescription: 'Notification channel for Prayer Times',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/aqsa_athan',
        ),
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak_saqqaf',
          channelName: 'Prayer Times Notifications saqqaf',
          channelDescription: 'Notification channel for Prayer Times',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/saqqaf_athan',
        ),
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak_sarihi',
          channelName: 'Prayer Times Notifications sarihi',
          channelDescription: 'Notification channel for Prayer Times',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/sarihi_athan',
        ),
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak_baset',
          channelName: 'Prayer Times Notifications baset',
          channelDescription: 'Notification channel for Prayer Times',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/baset_athan',
        ),
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak_qatami',
          channelName: 'Prayer Times Notifications qatami',
          channelDescription: 'Notification channel for Prayer Times',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/qatami_athan',
        ),
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak_salah',
          channelName: 'Prayer Times Notifications salah',
          channelDescription: 'Notification channel for Prayer Times',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/salah_athan',
        ),
        NotificationChannel(
          // channelGroupKey: 'prayers_notifications_channel_group_ak',
          channelKey: 'prayers_notifications_channel_ak_notification',
          channelName: 'App Notifications',
          channelDescription: 'Notification channel for App Notifications',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/notification',
        ),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'prayers_notifications_channel_group_ak',
            channelGroupName: 'Channel Group for Prayer Times Notifications'),
      ],
      debug: true,
    );
    _initialized = true;
    log('Awesome Notifications Initialized', name: 'NotifyHelper');
  }

  Future<void> notificationBadgeListener() async {
    await AwesomeNotifications().getGlobalBadgeCounter().then((_) async {
      await AwesomeNotifications().setGlobalBadgeCounter(
          LocalNotificationsController.instance.unreadCount);
    });
  }

  Future<void> cancelNotification(int notificationId) async {
    log('Notification ID $notificationId was cancelled', name: 'NotifyHelper');
    if (Platform.isMacOS) {
      return MacOSNotificationsService.instance.cancel(notificationId);
    }
    return AwesomeNotifications().cancelSchedule(notificationId);
  }

  Future<void> requistPermissions() async {
    // macOS: استخدام flutter_local_notifications
    if (Platform.isMacOS) {
      final service = MacOSNotificationsService.instance;
      await service.initialize();
      await service.requestPermissions();
      log('macOS notification permission requested', name: 'NotifyHelper');
      return;
    }

    // iOS/Android
    if (!_initialized) {
      initAwesomeNotifications();
    }
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        try {
          await AwesomeNotifications().requestPermissionToSendNotifications();
          log('Notification permission requested', name: 'NotifyHelper');
        } catch (e) {
          log('Failed to request notification permission: $e',
              name: 'NotifyHelper');
        }
      }
    });
  }

  void setNotificationsListeners() {
    // macOS لا يحتاج listeners منفصلة
    if (Platform.isMacOS) return;

    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    log(
      'Notification Created: ${receivedNotification.title}',
      name: 'NotifyHelper',
    );
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    log(
      'notificationDisplayed 2: ${receivedNotification.body}',
      name: 'NotifyHelper',
    );
    // log('audioPlayer.allowsExternalPlayback : ${PrayersNotificationsCtrl.instance.state.adhanPlayer.allowsExternalPlayback}',
    //     name: 'NotifyHelper');
    // if (prayerList.contains(receivedNotification.title!) ||
    //     receivedNotification.payload?['sound_type'] == 'sound') {
    //   await PrayersNotificationsCtrl.instance
    //       .fullAthanForIos(receivedNotification);
    // }
    if (receivedNotification.payload?['sound_type'] == 'sound') {
      // playAudio(receivedNotification.id, receivedNotification.title,
      //     receivedNotification.body);
    }
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    log('Notification Dismessed: ${receivedAction.body}', name: 'NotifyHelper');
    // notiCtrl.state.adhanPlayer.stop();
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    log(
      'Received Action: ${receivedAction.body} Received Action ID: ${receivedAction.id}',
      name: 'NotifyHelper',
    );
    // notiCtrl.state.adhanPlayer.stop();
    if (prayerListList.contains(receivedAction.title!)) {
      PrayersNotificationsCtrl.instance.onNotificationActionReceived(
        receivedAction,
      );
    }
  }

  Future<bool> isNotificationAllowed() async {
    // تحقق أولاً: هل شاهد المستخدم شاشة تفعيل الإشعارات من قبل؟
    // إذا لم يشاهدها، نُرجع false لإظهار الشاشة
    if (hasSeenNotificationSetup) {
      return true;
    }

    try {
      if (!_initialized) {
        if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
          await MacOSNotificationsService.instance.initialize();
        } else {
          initAwesomeNotifications();
        }
      }
    } catch (_) {}
    return GetStorage().read<bool>(_permissionFlagKey) ?? false;
  }
}
