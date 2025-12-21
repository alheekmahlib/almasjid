import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/timezone.dart' as tz;

import '/core/widgets/local_notification/controller/local_notifications_controller.dart';
import '../../presentation/prayers/prayers.dart';
import '../utils/constants/lists.dart';
import '../utils/constants/shared_preferences_constants.dart';

class LocalReceivedNotification {
  const LocalReceivedNotification({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.payload,
    required this.displayedDate,
  });

  final int id;
  final String title;
  final String summary;
  final String body;
  final Map<String, String?> payload;
  final DateTime displayedDate;
}

class LocalReceivedAction {
  const LocalReceivedAction({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.payload,
    required this.displayedDate,
  });

  final int id;
  final String title;
  final String summary;
  final String body;
  final Map<String, String?> payload;
  final DateTime displayedDate;

  static LocalReceivedAction? tryParse({
    required int id,
    required String? payloadString,
  }) {
    if (payloadString == null || payloadString.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payloadString) as Map<String, dynamic>;
      final title = decoded['title'] as String?;
      final summary = decoded['summary'] as String?;
      final body = decoded['body'] as String?;
      final displayedAt = decoded['displayed_at'] as String?;
      final payloadAny = decoded['payload'] as Map<String, dynamic>?;

      if (title == null || summary == null || body == null) {
        return null;
      }

      final payload = payloadAny == null
          ? <String, String?>{}
          : payloadAny.map((k, v) => MapEntry(k, v?.toString()));

      return LocalReceivedAction(
        id: id,
        title: title,
        summary: summary,
        body: body,
        payload: payload,
        displayedDate:
            displayedAt != null ? DateTime.parse(displayedAt) : DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

class _AdhanChannelDef {
  const _AdhanChannelDef({
    required this.rawName,
    required this.name,
    required this.description,
  });

  final String rawName;
  final String name;
  final String description;
}

class NotifyHelper {
  static const String _logName = 'NotifyHelper';
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static String? _timeZoneIdentifier;

  static const String _permissionFlagKey = 'notifications_permission_granted';
  static const String _notificationSetupSeenKey = 'notification_setup_seen';
  static const String _androidChannelsMigratedFlagKey =
      'android_notification_channels_v2_migrated';

  bool get isAllowed => GetStorage().read<bool>(_permissionFlagKey) ?? false;

  /// تحقق مما إذا كان المستخدم قد شاهد شاشة تفعيل الإشعارات من قبل
  bool get hasSeenNotificationSetup =>
      GetStorage().read<bool>(_notificationSetupSeenKey) ?? false;

  /// تعيين أن المستخدم قد شاهد شاشة تفعيل الإشعارات
  Future<void> markNotificationSetupAsSeen() async {
    await GetStorage().write(_notificationSetupSeenKey, true);
  }

  static const List<_AdhanChannelDef> _adhanChannelDefs = <_AdhanChannelDef>[
    _AdhanChannelDef(
      rawName: 'aqsa_athan',
      name: 'Prayer Times (Aqsa)',
      description: 'Prayer times with Aqsa adhan',
    ),
    _AdhanChannelDef(
      rawName: 'aqsa_fajir_athan',
      name: 'Prayer Times (Aqsa - Fajr)',
      description: 'Fajr prayer times with Aqsa adhan',
    ),
    _AdhanChannelDef(
      rawName: 'saqqaf_athan',
      name: 'Prayer Times (Saqqaf)',
      description: 'Prayer times with Saqqaf adhan',
    ),
    _AdhanChannelDef(
      rawName: 'saqqaf_fajir_athan',
      name: 'Prayer Times (Saqqaf - Fajr)',
      description: 'Fajr prayer times with Saqqaf adhan',
    ),
    _AdhanChannelDef(
      rawName: 'sarihi_athan',
      name: 'Prayer Times (Sarihi)',
      description: 'Prayer times with Sarihi adhan',
    ),
    _AdhanChannelDef(
      rawName: 'sarihi_athan_fajir',
      name: 'Prayer Times (Sarihi - Fajr)',
      description: 'Fajr prayer times with Sarihi adhan',
    ),
    _AdhanChannelDef(
      rawName: 'baset_athan',
      name: 'Prayer Times (Baset)',
      description: 'Prayer times with Baset adhan',
    ),
    _AdhanChannelDef(
      rawName: 'baset_fajir_athan',
      name: 'Prayer Times (Baset - Fajr)',
      description: 'Fajr prayer times with Baset adhan',
    ),
    _AdhanChannelDef(
      rawName: 'qatami_athan',
      name: 'Prayer Times (Qatami)',
      description: 'Prayer times with Qatami adhan',
    ),
    _AdhanChannelDef(
      rawName: 'qatami_fajir_athan',
      name: 'Prayer Times (Qatami - Fajr)',
      description: 'Fajr prayer times with Qatami adhan',
    ),
    _AdhanChannelDef(
      rawName: 'salah_athan',
      name: 'Prayer Times (Salah)',
      description: 'Prayer times with Salah adhan',
    ),
    _AdhanChannelDef(
      rawName: 'salah_fajir_athan',
      name: 'Prayer Times (Salah - Fajr)',
      description: 'Fajr prayer times with Salah adhan',
    ),
  ];

  static final List<String> _knownAndroidChannelIds = <String>[
    'prayers_bell',
    'prayers_silent',
    ..._adhanChannelDefs.map((d) => 'prayers_adhan_${d.rawName}'),
  ];

  static Future<bool> _ensureAndroidNotificationsAllowed() async {
    final dynamic android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    try {
      final bool? enabled = await android.areNotificationsEnabled();
      if (enabled == true) return true;

      final bool? granted = await android.requestNotificationsPermission();
      if (granted == true) return true;

      final bool? enabledAfter = await android.areNotificationsEnabled();
      return enabledAfter == true;
    } catch (e) {
      log('Failed to verify/request Android notification permission: $e',
          name: _logName);
      return true;
    }
  }

  static Future<AndroidScheduleMode?> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final allowed = await _ensureAndroidNotificationsAllowed();
    if (!allowed) {
      log('Notifications are disabled for this app (Android).', name: _logName);
      return null;
    }

    final dynamic android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    bool canExact = true;
    try {
      final bool? v = await android?.canScheduleExactNotifications();
      canExact = v ?? true;
    } catch (_) {
      canExact = true;
    }

    if (canExact == false) {
      try {
        await android?.requestExactAlarmsPermission();
        final bool? v2 = await android?.canScheduleExactNotifications();
        canExact = v2 ?? canExact;
      } catch (_) {
        // ignore
      }
    }

    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  String get audioPath =>
      GetStorage('AdhanSounds').read<String?>(ADHAN_PATH) ??
      'resource://raw/aqsa_athan';
  String get audioFajirPath =>
      GetStorage('AdhanSounds').read<String?>(ADHAN_PATH_FAJIR) ??
      'resource://raw/aqsa_fajir_athan';

  static String _rawNameFromResourceUri(String uri) {
    // Expected formats: resource://raw/aqsa_athan
    // (Android raw resources are referenced without extension)
    const prefix = 'resource://raw/';
    if (!uri.startsWith(prefix)) return uri;
    final raw = uri.substring(prefix.length);
    // Backward-compat for previously stored/typoed names.
    if (raw == 'aqsa_athan_fajir') return 'aqsa_fajir_athan';
    return raw;
  }

  static String _darwinSoundFileFromResourceUri(String uri) {
    // iOS/macOS notification sounds are bundled in ios/Resource as .aiff
    final rawName = _rawNameFromResourceUri(uri);
    if (rawName.endsWith('.aiff') ||
        rawName.endsWith('.wav') ||
        rawName.endsWith('.caf')) {
      return rawName;
    }
    return '$rawName.aiff';
  }

  static Future<void> _configureLocalTimeZone() async {
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneInfo.identifier;
      _timeZoneIdentifier = timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to default tz.local if timezone can't be resolved
      log('Timezone init fallback: $e', name: _logName);
    }
  }

  static AndroidNotificationChannel _androidChannel({
    required String id,
    required String name,
    required String description,
    String? soundRawName,
    required bool playSound,
  }) {
    return AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: Importance.max,
      sound: soundRawName == null
          ? null
          : RawResourceAndroidNotificationSound(soundRawName),
      playSound: playSound,
    );
  }

  static Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    final channels = <AndroidNotificationChannel>[
      _androidChannel(
        id: 'prayers_bell',
        name: 'App Notifications',
        description: 'Notification channel for app notifications',
        soundRawName: 'notification',
        playSound: true,
      ),
      _androidChannel(
        id: 'prayers_silent',
        name: 'Silent Notifications',
        description: 'Notification channel for silent notifications',
        soundRawName: null,
        playSound: false,
      ),
      ..._adhanChannelDefs.map(
        (d) => _androidChannel(
          id: 'prayers_adhan_${d.rawName}',
          name: d.name,
          description: d.description,
          soundRawName: d.rawName,
          playSound: true,
        ),
      ),
    ];

    for (final channel in channels) {
      await android.createNotificationChannel(channel);
    }
  }

  static Future<void> _migrateAndroidChannelsIfNeeded() async {
    if (!Platform.isAndroid) return;

    // Android notification channel sound can't be changed after creation.
    // During migration/debug, channels might have been created without sound.
    // Delete + recreate once to ensure the expected sound is applied.
    final box = GetStorage();
    final migrated = box.read<bool>(_androidChannelsMigratedFlagKey) ?? false;
    if (migrated) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    try {
      for (final id in _knownAndroidChannelIds) {
        try {
          await android.deleteNotificationChannel(id);
        } catch (_) {
          // ignore
        }
      }
      await _createAndroidChannels();
      await box.write(_androidChannelsMigratedFlagKey, true);
      log('Android notification channels migrated (delete+recreate)',
          name: _logName);
    } catch (e) {
      log('Android channel migration failed: $e', name: _logName);
    }
  }

  static Future<void> _ensureAndroidChannels() async {
    if (!Platform.isAndroid) return;
    await _migrateAndroidChannelsIfNeeded();
    // Idempotent: create channels again to ensure they exist.
    await _createAndroidChannels();
  }

  static String _androidChannelIdFor({
    required Map<String, String?> payload,
    required int reminderId,
    required String audioPath,
    required String audioFajirPath,
  }) {
    final soundType = payload['sound_type'];
    switch (soundType) {
      case 'nothing':
      case 'silent':
        return 'prayers_silent';
      case 'bell':
        return 'prayers_bell';
      case 'sound':
        final uri = reminderId == 0 ? audioFajirPath : audioPath;
        final rawName = _rawNameFromResourceUri(uri);
        return 'prayers_adhan_$rawName';
      default:
        return 'prayers_bell';
    }
  }

  static AndroidNotificationSound? _androidSoundFor({
    required Map<String, String?> payload,
    required int reminderId,
    required String audioPath,
    required String audioFajirPath,
  }) {
    final soundType = payload['sound_type'];
    switch (soundType) {
      case 'nothing':
      case 'silent':
        return null;
      case 'bell':
        return const RawResourceAndroidNotificationSound('notification');
      case 'sound':
        final uri = reminderId == 0 ? audioFajirPath : audioPath;
        return RawResourceAndroidNotificationSound(
            _rawNameFromResourceUri(uri));
      default:
        return const RawResourceAndroidNotificationSound('notification');
    }
  }

  static ({bool presentSound, String? soundFile}) _darwinSoundFor({
    required Map<String, String?> payload,
    required int reminderId,
    required String audioPath,
    required String audioFajirPath,
  }) {
    final soundType = payload['sound_type'];
    switch (soundType) {
      case 'nothing':
      case 'silent':
        return (presentSound: false, soundFile: null);
      case 'bell':
        return (presentSound: true, soundFile: 'notification.aiff');
      case 'sound':
        // iOS resources in this repo don't have separate fajr sounds; reuse the selected base adhan.
        final uri = audioPath;
        return (
          presentSound: true,
          soundFile: _darwinSoundFileFromResourceUri(uri)
        );
      default:
        return (presentSound: true, soundFile: 'notification.aiff');
    }
  }

  static Future<void> initFlutterLocalNotifications() async {
    if (_initialized) return;
    await _configureLocalTimeZone();

    const androidPrimary = AndroidInitializationSettings('ic_notification');
    const androidFallback = AndroidInitializationSettings('launcher_icon');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    Future<void> initWith(AndroidInitializationSettings android) async {
      final settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
    }

    try {
      await initWith(androidPrimary);
    } on PlatformException catch (e) {
      if (Platform.isAndroid && e.code == 'invalid_icon') {
        log(
          'Android notification icon not found (ic_notification). Retrying with launcher_icon. error=$e',
          name: _logName,
        );
        await initWith(androidFallback);
      } else {
        rethrow;
      }
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;
      if (response != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationResponse(response);
        });
      }
    }

    await _ensureAndroidChannels();
    _initialized = true;
    log('flutter_local_notifications initialized', name: _logName);
  }

  static String _encodePayload({
    required String title,
    required String summary,
    required String body,
    required Map<String, String?> payload,
    required DateTime displayedAt,
  }) {
    return jsonEncode({
      'title': title,
      'summary': summary,
      'body': body,
      'payload': payload,
      'displayed_at': displayedAt.toIso8601String(),
    });
  }

  static NotificationDetails _buildNotificationDetails({
    required String androidChannelId,
    required AndroidNotificationSound? androidSound,
    required ({bool presentSound, String? soundFile}) darwinSound,
    required Map<String, String?> payload,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        'Notifications',
        channelDescription: 'Local notifications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        playSound: payload['sound_type'] != 'silent' &&
            payload['sound_type'] != 'nothing',
        sound: androidSound,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: darwinSound.presentSound,
        sound: darwinSound.soundFile,
        badgeNumber: LocalNotificationsController.instance.unreadCount,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: darwinSound.presentSound,
        sound: darwinSound.soundFile,
        badgeNumber: LocalNotificationsController.instance.unreadCount,
      ),
    );
  }

  static void _logPendingCount() {
    // This is diagnostic only. In release builds some devices/R8 setups may
    // break generic signatures used internally by the plugin when reading
    // scheduled notifications.
    if (!kDebugMode) return;

    _plugin
        .pendingNotificationRequests()
        .then(
          (pending) =>
              log('Pending notifications: ${pending.length}', name: _logName),
        )
        .catchError((Object e) {
      log('pendingNotificationRequests failed: $e', name: _logName);
    });
  }

  static void _scheduleTestWithTimer({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required String payloadString,
    required String channelId,
    required String? soundType,
  }) {
    log(
      'Test notification: will show after 2 minutes (Timer) id=$id channel=$channelId soundType=$soundType tzId=${_timeZoneIdentifier ?? 'unknown'}',
      name: _logName,
    );

    Timer(const Duration(minutes: 2), () async {
      try {
        await _plugin.show(
          id,
          title,
          body,
          details,
          payload: payloadString,
        );
        log('Test notification shown (Timer) id=$id', name: _logName);
      } catch (e) {
        log('Test notification failed (Timer) id=$id error=$e', name: _logName);
      }
    });
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  static void _handleNotificationResponse(NotificationResponse response) {
    final id = response.id;
    if (id == null) return;

    final action = LocalReceivedAction.tryParse(
      id: id,
      payloadString: response.payload,
    );
    if (action == null) return;

    if (prayerList.contains(action.title)) {
      PrayersNotificationsCtrl.instance.onNotificationActionReceived(action);
    }
  }

  // تحديد الصوت المخصص للإشعار بناءً على نوع الصوت المحدد
  // Custom sound selection based on specified sound type
  // NOTE: In flutter_local_notifications, Android sound is effectively determined by the channel.
  // We still compute the intended sound to select the right channel + Darwin sound.

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

    if (!_initialized) {
      await initFlutterLocalNotifications();
    }

    final now = DateTime.now();
    var scheduledAt = time ?? now.add(const Duration(minutes: 2));
    if (scheduledAt.isBefore(now)) {
      if (isRepeats) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      } else {
        log(
          'Skip scheduling in the past. id=$reminderId scheduledAt=$scheduledAt now=$now',
          name: _logName,
        );
        return;
      }
    }

    final androidScheduleMode = await _resolveAndroidScheduleMode();
    if (androidScheduleMode == null) return;

    final payloadString = _encodePayload(
      title: title,
      summary: summary,
      body: body,
      payload: payload,
      displayedAt: scheduledAt,
    );

    final androidChannelId = _androidChannelIdFor(
      payload: payload,
      reminderId: reminderId,
      audioPath: audioPath,
      audioFajirPath: audioFajirPath,
    );
    final androidSound = _androidSoundFor(
      payload: payload,
      reminderId: reminderId,
      audioPath: audioPath,
      audioFajirPath: audioFajirPath,
    );
    final darwinSound = _darwinSoundFor(
      payload: payload,
      reminderId: reminderId,
      audioPath: audioPath,
      audioFajirPath: audioFajirPath,
    );

    try {
      final details = _buildNotificationDetails(
        androidChannelId: androidChannelId,
        androidSound: androidSound,
        darwinSound: darwinSound,
        payload: payload,
      );

      // Test mode (debug only): if caller didn't provide a time, use an in-app delayed show.
      // This avoids device-specific restrictions around scheduled alarms while debugging.
      // Note: this will not fire if the app is killed before the delay.
      if (time == null) {
        _scheduleTestWithTimer(
          id: reminderId,
          title: title,
          body: body,
          details: details,
          payloadString: payloadString,
          channelId: androidChannelId,
          soundType: payload['sound_type'],
        );
        _logPendingCount();
        return;
      }

      // For short-delay tests (time == null), computing from TZ "now" is more reliable
      // than converting a DateTime across timezones.
      final tzDateTime = tz.TZDateTime.from(scheduledAt, tz.local);
      log(
        'Scheduling id=$reminderId at=$scheduledAt tz=$tzDateTime tzId=${_timeZoneIdentifier ?? 'unknown'} mode=$androidScheduleMode channel=$androidChannelId soundType=${payload['sound_type']}',
        name: _logName,
      );
      await _plugin.zonedSchedule(
        reminderId,
        title,
        body,
        tzDateTime,
        details,
        payload: payloadString,
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: isRepeats ? DateTimeComponents.time : null,
      );
      _logPendingCount();
      log('Notification successfully scheduled', name: _logName);
    } catch (e) {
      log('Error scheduling notification: $e', name: _logName);
    }
  }

  Future<void> notificationBadgeListener() async {
    // Best-effort: update badge count on platforms that support it.
    final count = LocalNotificationsController.instance.unreadCount;
    try {
      final dynamic ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.setBadgeCount(count);
    } catch (_) {}
    try {
      final dynamic mac = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      await mac?.setBadgeCount(count);
    } catch (_) {}
  }

  Future<void> cancelNotification(int notificationId) {
    log('Notification ID $notificationId was cancelled', name: _logName);
    return _plugin.cancel(notificationId);
  }

  Future<void> requistPermissions() async {
    if (!_initialized) {
      await initFlutterLocalNotifications();
    }

    try {
      if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final allowed = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        GetStorage().write(_permissionFlagKey, allowed ?? true);
      } else if (Platform.isMacOS) {
        final mac = _plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
        final allowed = await mac?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        GetStorage().write(_permissionFlagKey, allowed ?? true);
      } else if (Platform.isAndroid) {
        // Android 13+ requires runtime notification permission.
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final bool? granted = await android?.requestNotificationsPermission();
        GetStorage().write(_permissionFlagKey, granted ?? true);
      }
      log('Notification permission requested', name: _logName);
    } catch (e) {
      log('Failed to request notification permission: $e', name: _logName);
    }
  }

  Future<bool> isNotificationAllowed() async {
    // تحقق أولاً: هل شاهد المستخدم شاشة تفعيل الإشعارات من قبل؟
    // إذا لم يشاهدها، نُرجع false لإظهار الشاشة
    if (!hasSeenNotificationSetup) {
      return false;
    }

    try {
      if (!_initialized) {
        await initFlutterLocalNotifications();
      }

      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final bool? enabled = await android?.areNotificationsEnabled();
        if (enabled != null) return enabled;
      }
    } catch (_) {}
    return GetStorage().read<bool>(_permissionFlagKey) ?? false;
  }

  // Listeners are registered via `FlutterLocalNotificationsPlugin.initialize`.
}
