// ignore_for_file: avoid_log

import 'dart:developer' show log;

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import '/core/services/prayer_background_manager.dart';
import '../utils/constants/shared_preferences_constants.dart';
import '../utils/helpers/platform_helper.dart';
import '../widgets/home_widget/home_widget.dart';
// import '../widgets/home_widget/home_widget.dart';

/// مُعالج المهام في الخلفية
/// Background task handler
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (isTimeout) {
    log('Headless task timed-out: $taskId', name: 'Background service');
    BackgroundFetch.finish(taskId);
    return;
  }

  log('Headless event received.', name: 'Background service');

  // تنفيذ المهام باستخدام المدير الجديد
  // Execute tasks using new manager
  await _executeBackgroundTasks();

  BackgroundFetch.finish(taskId);
}

/// تنفيذ المهام في الخلفية
/// Execute background tasks
Future<void> _executeBackgroundTasks() async {
  try {
    await GetStorage.init();
    if (GetStorage().read(ACTIVE_LOCATION)) {
      await PrayerBackgroundManager.executePeriodicTasks();
      if (isMobile) {
        await HijriWidgetConfig.initialize();
        await PrayersWidgetConfig.initialize();
        await HijriWidgetConfig().updateHijriDate();
        await PrayersWidgetConfig().updatePrayersDate();
      }
    }
  } catch (e) {
    log('Error executing background tasks: $e', name: 'Background service');
  }
}

/// معالج المهام في الخلفية المحلي
/// Local background task handler
class BackgroundTaskHandler {
  static const MethodChannel platform =
      MethodChannel('com.alheekmah.alheekmahLibrary/background_tasks');

  /// تهيئة معالج المهام
  /// Initialize task handler
  static Future<void> initializeHandler() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'performDailyTasks') {
        await PrayerBackgroundManager.executeDailyTasks();
      } else if (call.method == 'performBackgroundFetch') {
        // معالجة طلب background fetch من النظام
        // Handle background fetch request from system
        await _executeBackgroundTasks();
      }
    });
  }
}

/// خدمة العمليات في الخلفية
/// Background services class
class BGServices {
  /// طباعة نصائح تحسين عمل المهام في الخلفية
  /// Print tips for optimizing background tasks
  void printBackgroundOptimizationTips() {
    if (isIOS) {
      log('📱 نصائح لتحسين عمل المهام في الخلفية على iOS:',
          name: 'Background service');
      log('1. تأكد من تمكين Background App Refresh في الإعدادات',
          name: 'Background service');
      log('2. استخدم التطبيق بانتظام لتحسين أولوية النظام',
          name: 'Background service');
      log('3. اترك التطبيق في الخلفية بدلاً من إغلاقه تماماً',
          name: 'Background service');
      log('4. تأكد من عدم تفعيل Low Power Mode', name: 'Background service');
    } else {
      log('🤖 نصائح لتحسين عمل المهام في الخلفية على Android:',
          name: 'Background service');
      log('1. تعطيل Battery Optimization للتطبيق', name: 'Background service');
      log('2. إضافة التطبيق لقائمة الاستثناءات', name: 'Background service');
      log('3. تمكين AutoStart إذا كان متاحاً', name: 'Background service');
    }
  }

  /// التحقق من حالة background fetch
  /// Check background fetch status
  Future<void> checkBackgroundFetchStatus() async {
    try {
      int status = await BackgroundFetch.status;
      switch (status) {
        case BackgroundFetch.STATUS_RESTRICTED:
          log('Background fetch is restricted', name: 'Background service');
          log('الحل: تأكد من تمكين Background App Refresh في الإعدادات',
              name: 'Background service');
          break;
        case BackgroundFetch.STATUS_DENIED:
          log('Background fetch is denied', name: 'Background service');
          log('الحل: يجب تمكين Background App Refresh للتطبيق',
              name: 'Background service');
          break;
        case BackgroundFetch.STATUS_AVAILABLE:
          log('Background fetch is available and working ✅',
              name: 'Background service');
          break;
        default:
          log('Background fetch status unknown: $status',
              name: 'Background service');
      }
    } catch (e) {
      log('Error checking background fetch status: $e',
          name: 'Background service');
    }
  }

  /// تسجيل المهام في الخلفية
  /// Register background tasks
  Future<void> registerTask() async {
    log('🚀 بدء تسجيل خدمات العمليات في الخلفية...',
        name: 'Background service');
    log(
        'Platform: ${isIOS ? "iOS" : isAndroid ? "android" : "other"}',
        name: 'Background service');

    // التحقق من حالة background fetch أولاً
    // Check background fetch status first
    await checkBackgroundFetchStatus();

    // تسجيل المهمة للأندرويد
    // Register headless task for Android
    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

    // تكوين وبدء BackgroundFetch
    // Configure and start BackgroundFetch
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // 15 دقيقة / 15 minutes (more frequent)
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onFetch,
      _onTimeOut,
    ).then((int status) {
      log('Background fetch configured successfully: $status',
          name: 'Background service');
    }).catchError((e) {
      log('Background fetch configuration error: $e',
          name: 'Background service');
    });

    // بدء خدمة العمليات في الخلفية
    // Start background fetch service
    await BackgroundFetch.start().then((v) async {
      await _executeBackgroundTasks();
      log('Background service started successfully',
          name: 'Background service');
    }).catchError((e) {
      log('Error starting background service: $e', name: 'Background service');
    });

    // جدولة المهام الدورية
    // Schedule periodic tasks
    try {
      await BackgroundFetch.scheduleTask(
        TaskConfig(
          taskId: 'com.transistorsoft.fetchNotifications',
          delay: 15 * 60 * 1000, // 15 دقيقة / 15 minutes (more frequent)
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          periodic: true,
          requiredNetworkType: NetworkType.ANY,
        ),
      );
      log('Periodic task scheduled successfully', name: 'Background service');
    } catch (e) {
      if (isIOS) {
        // تحديد نوع الخطأ بشكل أكثر تفصيلاً
        // More detailed error identification
        String errorMsg = e.toString();
        if (errorMsg.contains('BGTaskSchedulerErrorDomain')) {
          log('iOS task scheduling: System managed background tasks (normal behavior)',
              name: 'Background service');
          log('ملاحظة: iOS يدير المهام في الخلفية تلقائياً حسب استخدام المستخدم',
              name: 'Background service');
        } else {
          log('iOS task scheduling limitation: $e', name: 'Background service');
        }
        log('iOS background tasks have system limitations and may require app to be in background mode',
            name: 'Background service');
      } else {
        log('Task scheduling error: $e', name: 'Background service');
      }
    }

    // طباعة نصائح التحسين في النهاية
    // Print optimization tips at the end
    printBackgroundOptimizationTips();
  }
}

/// معالج الأحداث المجدولة
/// Scheduled event handler
Future<void> _onFetch(String taskId) async {
  log('Background fetch event received: $taskId', name: 'Background service');

  try {
    await _executeBackgroundTasks();
  } catch (e) {
    log('Error in background fetch: $e', name: 'Background service');
  }

  // إشارة انتهاء المهمة
  // Signal task completion
  BackgroundFetch.finish(taskId);
}

/// معالج انتهاء وقت المهمة
/// Task timeout handler
Future<void>? _onTimeOut(String taskId) async {
  log('Background task timeout: $taskId', name: 'Background service');
  BackgroundFetch.finish(taskId);
}
