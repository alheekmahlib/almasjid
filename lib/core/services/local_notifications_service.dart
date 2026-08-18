import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart'
    show
        AppLifecycleState,
        WidgetsBinding,
        WidgetsBindingObserver,
        WidgetsFlutterBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/constants/shared_preferences_constants.dart';

/// نموذج موحد لإشعار مستلَم عند النقر، بديل أنواع awesome_notifications.
class LocalReceivedNotification {
  const LocalReceivedNotification({
    this.id,
    this.title,
    this.summary,
    this.body,
    this.payload = const {},
    this.displayedDate,
  });

  final int? id;
  final String? title;
  final String? summary;
  final String? body;
  final Map<String, String?> payload;
  final DateTime? displayedDate;
}

/// خدمة الإشعارات المحلية الموحدة لكل المنصات (Android/iOS/macOS)
/// عبر flutter_local_notifications.
class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _tzInitialized = false;
  void Function(LocalReceivedNotification notification)? _onTap;
  _AppLifecycleTapBridge? _lifecycleBridge;

  /// مفتاح تخزين نقرة إشعار وصلت والواجهة غير متاحة (خلفية/مقتولة).
  static const String _pendingTapKey = 'pending_notification_tap';

  // ─── قنوات Android ───
  static const String adhanChannelPrefix = 'prayers_adhan_';
  static const String bellChannelId = 'prayers_bell';
  static const String silentChannelId = 'prayers_silent';

  /// أسماء ملفات res/raw بدون امتداد، لكل مقرئ مدمج.
  static const List<String> _reciters = [
    'aqsa',
    'saqqaf',
    'sarihi',
    'baset',
    'qatami',
    'salah',
  ];

  /// قنوات awesome_notifications القديمة تُحذف مرة عند التهيئة (هجرة نظيفة).
  static const List<String> _legacyAwesomeChannelIds = [
    'prayers_notifications_channel_ak',
    'prayers_notifications_channel_ak_saqqaf',
    'prayers_notifications_channel_ak_sarihi',
    'prayers_notifications_channel_ak_baset',
    'prayers_notifications_channel_ak_qatami',
    'prayers_notifications_channel_ak_salah',
    'prayers_notifications_channel_ak_notification',
  ];

  /// الصوت المختار من التخزين بصيغة `resource://raw/<name>`
  String get _selectedAdhanResource =>
      GetStorage('AdhanSounds').read<String?>(ADHAN_PATH) ??
      'resource://raw/aqsa_athan';

  /// اسم المقرئ المختار من المسار المخزن (أو الافتراضي aqsa).
  String get _selectedReciter {
    final raw = _selectedAdhanResource.replaceFirst('resource://raw/', '');
    for (final reciter in _reciters) {
      if (raw.startsWith(reciter)) return reciter;
    }
    return 'aqsa';
  }

  /// تهيئة الخدمة. يمكن استدعاؤها أكثر من مرة؛ أول استدعاء يهيئ المنصة،
  /// والاستدعاءات اللاحقة تكتفي بتحديث مستقبل النقر.
  Future<void> initialize({
    required void Function(LocalReceivedNotification notification) onTap,
  }) async {
    _onTap = onTap;
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();
    await _ensureTimeZoneInitialized();

    const darwinSettings = DarwinInitializationSettings(
      // الأذونات تُطلب صراحةً من شاشة تفعيل الإشعارات (requistPermissions).
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    await _createAndroidChannels();

    _lifecycleBridge = _AppLifecycleTapBridge(_consumePendingTapOnResume);
    WidgetsBinding.instance.addObserver(_lifecycleBridge!);

    _initialized = true;
    log('LocalNotificationsService initialized', name: 'LocalNotifications');
  }

  Future<void> _ensureTimeZoneInitialized() async {
    if (_tzInitialized) return;
    tzdata.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      log(
        'Local timezone: ${timeZoneInfo.identifier}',
        name: 'LocalNotifications',
      );
    } catch (e) {
      // fallback: tz.local (قد يكون UTC على بعض البيئات)
      log('Failed to resolve local timezone: $e', name: 'LocalNotifications');
    }
    _tzInitialized = true;
  }

  // ─── الأذونات ───

  /// طلب أذونات الإشعارات حسب المنصة. تُرجع true إذا مُنحت.
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      // لا يمكن طلب الأذونات قبل التهيئة؛ نُهيئ بمستقبل فارغ مؤقتاً.
      await initialize(onTap: (_) {});
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (Platform.isMacOS) {
      final macOS = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      return await macOS?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  // ─── القنوات (Android) ───

  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    for (final reciter in _reciters) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          '$adhanChannelPrefix$reciter',
          'مواقيت الصلاة - أذان $reciter',
          description: 'إشعار أذان الصلاة بصوت $reciter',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('${reciter}_athan'),
        ),
      );
    }

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        bellChannelId,
        'تنبيهات التطبيق',
        description: 'إشعارات التطبيق بصوت الجرس',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
    );

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        silentChannelId,
        'إشعارات صامتة',
        description: 'إشعارات بدون صوت',
        importance: Importance.max,
        playSound: false,
      ),
    );

    for (final legacyId in _legacyAwesomeChannelIds) {
      await android.deleteNotificationChannel(legacyId);
    }
  }

  // ─── الجدولة والإرسال ───

  /// جدولة إشعار في وقت محدد على كل المنصات.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    String? summary,
    required DateTime scheduledTime,
    String? soundType,
    bool isFajr = false,
    Map<String, String?> payload = const {},
    int? badgeNumber,
    bool isRepeats = false,
  }) async {
    await initialize(onTap: _onTap ?? (_) {});

    final safeTime = _ensureFuture(scheduledTime);
    final details = _buildNotificationDetails(
      soundType: soundType,
      summary: summary,
      badgeNumber: badgeNumber,
    );

    final tzDateTime = tz.TZDateTime.from(safeTime, tz.local);
    final encodedPayload = encodePayload(payload);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: encodedPayload,
        matchDateTimeComponents: isRepeats ? DateTimeComponents.time : null,
      );
    } on PlatformException catch (e) {
      // قد يُرفض الإنذار الدقيق (Android 12+)؛ نتراجع لجدولة غير دقيقة.
      log(
        'Exact schedule failed, falling back to inexact: $e',
        name: 'LocalNotifications',
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: encodedPayload,
        matchDateTimeComponents: isRepeats ? DateTimeComponents.time : null,
      );
    }

    log('Scheduled: $title at $safeTime (id: $id)', name: 'LocalNotifications');
  }

  /// إرسال إشعار فوري.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? summary,
    String? soundType,
    Map<String, String?> payload = const {},
    int? badgeNumber,
  }) async {
    await initialize(onTap: _onTap ?? (_) {});
    await _plugin.show(
      id,
      title,
      body,
      _buildNotificationDetails(
        soundType: soundType,
        summary: summary,
        badgeNumber: badgeNumber,
      ),
      payload: encodePayload(payload),
    );
  }

  DateTime _ensureFuture(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.isAfter(now.add(const Duration(seconds: 2)))) return dateTime;
    final bumped = now.add(const Duration(seconds: 5));
    log('Bumped past schedule time to: $bumped', name: 'LocalNotifications');
    return bumped;
  }

  NotificationDetails _buildNotificationDetails({
    required String? soundType,
    required String? summary,
    required int? badgeNumber,
  }) {
    final isAdhan = soundType == 'sound';
    final isSilent = soundType == 'nothing' || soundType == 'silent';

    // Android: الصوت يأتي من القناة؛ كل مقرئ له قناة بصوته.
    final String androidChannelId;
    final String androidChannelName;
    final AndroidNotificationSound? androidSound;
    switch (soundType) {
      case 'sound':
        final reciter = _selectedReciter;
        androidChannelId = '$adhanChannelPrefix$reciter';
        androidChannelName = 'مواقيت الصلاة - أذان $reciter';
        androidSound = RawResourceAndroidNotificationSound('${reciter}_athan');
      case 'bell':
        androidChannelId = bellChannelId;
        androidChannelName = 'تنبيهات التطبيق';
        androidSound = const RawResourceAndroidNotificationSound(
          'notification',
        );
      default:
        androidChannelId = silentChannelId;
        androidChannelName = 'إشعارات صامتة';
        androidSound = null;
    }

    final androidDetails = AndroidNotificationDetails(
      androidChannelId,
      androidChannelName,
      importance: Importance.max,
      priority: Priority.max,
      playSound: !isSilent,
      sound: isSilent ? null : androidSound,
      category: AndroidNotificationCategory.alarm,
      // wakeUpScreen السابق: شاشة كاملة لإشعار الأذان فقط.
      fullScreenIntent: isAdhan,
      visibility: NotificationVisibility.public,
    );

    // iOS/macOS: الصوت يُحل من حزمة التطبيق (وبمكتبة Apple من Library/Sounds).
    final String? darwinSoundFile;
    switch (soundType) {
      case 'sound':
        darwinSoundFile = '${_selectedReciter}_athan.aiff';
      case 'bell':
        darwinSoundFile = 'notification.aiff';
      default:
        darwinSoundFile = null;
    }

    final darwinDetails = DarwinNotificationDetails(
      sound: darwinSoundFile,
      subtitle: summary,
      presentAlert: true,
      presentBadge: true,
      presentSound: darwinSoundFile != null,
      badgeNumber: badgeNumber,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  // ─── الإلغاء ───

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    log('Cancelled notification: $id', name: 'LocalNotifications');
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    log('Cancelled all notifications', name: 'LocalNotifications');
  }

  // ─── معالجة النقر ───

  Future<void> _onForegroundResponse(NotificationResponse response) async {
    log(
      'Notification tapped (foreground): ${response.id}',
      name: 'LocalNotifications',
    );
    _onTap?.call(_fromResponse(response));
  }

  /// معالج نقر في خلفية/تطبيق مقتول: يخزّن النقرة وتُستهلك عند استئناف الواجهة.
  @pragma('vm:entry-point')
  static Future<void> _onBackgroundResponse(
    NotificationResponse response,
  ) async {
    try {
      await GetStorage.init();
      final stored = jsonEncode({
        'id': response.id,
        'payload': response.payload,
      });
      await GetStorage().write(_pendingTapKey, stored);
    } catch (e) {
      log('Failed to persist background tap: $e', name: 'LocalNotifications');
    }
  }

  /// نقرات مؤجلة وصلت والإقلاع من إشعار (iOS مقتول / Android عامةً).
  Future<LocalReceivedNotification?> consumeLaunchTap() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      final response = details?.notificationResponse;
      if ((details?.didNotificationLaunchApp ?? false) && response != null) {
        return _fromResponse(response);
      }
    } catch (e) {
      log('Failed to read launch details: $e', name: 'LocalNotifications');
    }
    return null;
  }

  /// استهلاك نقرة مخزنة من معالج الخلفية (إن وجدت) ثم حذفها.
  Future<LocalReceivedNotification?> consumePendingTap() async {
    try {
      final box = GetStorage();
      final stored = box.read<String?>(_pendingTapKey);
      if (stored == null || stored.isEmpty) return null;
      await box.remove(_pendingTapKey);

      final decoded = jsonDecode(stored);
      if (decoded is! Map<String, dynamic>) return null;
      final payload = decodePayload(decoded['payload'] as String?);
      return _fromPayloadMap(id: decoded['id'] as int?, payload: payload);
    } catch (e) {
      log('Failed to consume pending tap: $e', name: 'LocalNotifications');
      return null;
    }
  }

  Future<void> _consumePendingTapOnResume() async {
    final pending = await consumePendingTap();
    if (pending != null) {
      _onTap?.call(pending);
    }
  }

  static LocalReceivedNotification _fromResponse(
    NotificationResponse response,
  ) {
    return _fromPayloadMap(
      id: response.id,
      payload: decodePayload(response.payload),
    );
  }

  static LocalReceivedNotification _fromPayloadMap({
    required int? id,
    required Map<String, String?> payload,
  }) {
    final firedAtMillis = int.tryParse(payload['fired_at'] ?? '');
    return LocalReceivedNotification(
      id: id,
      title: payload['title'],
      summary: payload['summary'],
      body: payload['body'],
      payload: payload,
      displayedDate: firedAtMillis == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(firedAtMillis),
    );
  }

  // ─── تسلسل payload ───

  static String? encodePayload(Map<String, String?> payload) {
    if (payload.isEmpty) return null;
    try {
      return jsonEncode(payload);
    } catch (e) {
      log('Failed to encode payload: $e', name: 'LocalNotifications');
      return null;
    }
  }

  static Map<String, String?> decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return const {};
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value?.toString()));
      }
    } catch (e) {
      log('Failed to decode payload: $e', name: 'LocalNotifications');
    }
    return const {};
  }
}

/// يستمع لاستئناف الواجهة ليستهلك نقرات وصلت أثناء الخلفية.
class _AppLifecycleTapBridge with WidgetsBindingObserver {
  _AppLifecycleTapBridge(this._onResumed);

  final Future<void> Function() _onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }
}
