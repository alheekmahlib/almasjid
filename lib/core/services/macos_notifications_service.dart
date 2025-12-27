import 'dart:developer' show log;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/constants/shared_preferences_constants.dart';

/// خدمة الإشعارات المحلية لنظام macOS
/// تستخدم flutter_local_notifications بدلاً من awesome_notifications
class MacOSNotificationsService {
  MacOSNotificationsService._();
  static final instance = MacOSNotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // أصوات الأذان المتاحة
  static const _defaultSound = 'aqsa_athan';
  static const _defaultFajrSound = 'aqsa_fajir_athan';

  String get _adhanSound {
    final stored = GetStorage('AdhanSounds').read<String?>(ADHAN_PATH);
    if (stored == null) return _defaultSound;
    // تحويل من صيغة Android إلى macOS (بدون امتداد)
    return stored.replaceAll('resource://raw/', '');
  }

  String get _fajrSound {
    final stored = GetStorage('AdhanSounds').read<String?>(ADHAN_PATH_FAJIR);
    if (stored == null) return _defaultFajrSound;
    return stored.replaceAll('resource://raw/', '');
  }

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    if (_initialized) return;

    const settings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(macOS: settings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    log('macOS Notifications initialized', name: 'MacOSNotifications');
  }

  /// طلب صلاحيات الإشعارات
  Future<bool> requestPermissions() async {
    final macOS = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    return await macOS?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  /// جدولة إشعار
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? soundType,
    bool isFajr = false,
    Map<String, String>? payload,
  }) async {
    if (!_initialized) await initialize();

    final sound = _resolveSound(soundType, isFajr);
    final details = _buildNotificationDetails(sound);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload?.entries.map((e) => '${e.key}=${e.value}').join('&'),
    );

    log('Scheduled: $title at $scheduledTime', name: 'MacOSNotifications');
  }

  /// إرسال إشعار فوري
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? soundType,
    bool isFajr = false,
  }) async {
    if (!_initialized) await initialize();

    final sound = _resolveSound(soundType, isFajr);
    await _plugin.show(id, title, body, _buildNotificationDetails(sound));
  }

  /// إلغاء إشعار
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    log('Cancelled notification: $id', name: 'MacOSNotifications');
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    log('Cancelled all notifications', name: 'MacOSNotifications');
  }

  // ─────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────

  String? _resolveSound(String? soundType, bool isFajr) {
    String? sound;
    switch (soundType) {
      case 'nothing':
      case 'silent':
        sound = null;
        break;
      case 'bell':
        sound = 'notification';
        break;
      case 'sound':
        sound = isFajr ? _fajrSound : _adhanSound;
        break;
      default:
        sound = 'notification';
    }
    log('Resolved sound: $sound (type: $soundType, isFajr: $isFajr)',
        name: 'MacOSNotifications');
    return sound;
  }

  NotificationDetails _buildNotificationDetails(String? sound) {
    return NotificationDetails(
      macOS: DarwinNotificationDetails(
        sound: sound,
        presentAlert: true,
        presentBadge: true,
        presentSound: sound != null,
      ),
    );
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    tz.initializeTimeZones();
    final location = tz.local;
    return tz.TZDateTime(
      location,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    log('Notification tapped: ${response.payload}', name: 'MacOSNotifications');
    // يمكن إضافة منطق التنقل هنا
  }
}
