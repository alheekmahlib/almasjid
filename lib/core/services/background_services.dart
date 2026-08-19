// ignore_for_file: avoid_log

import 'dart:async';
import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import '/core/services/prayer_background_manager.dart';
import '../../presentation/feedback/controller/feedback_controller.dart';
import '../../presentation/prayers/prayers.dart';
import '../widgets/home_widget/home_widget.dart';

/// مُعالج المهام في الخلفية (headless)
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessEvent task) async {
  final taskId = task.taskId;
  if (task.timeout) {
    log('Headless task timed-out: $taskId', name: 'Background service');
    BackgroundFetch.finish(taskId);
    return;
  }
  log('Headless event received: $taskId', name: 'Background service');
  await _executeBackgroundTask(taskId);
  BackgroundFetch.finish(taskId);
}

class BGServices {
  static Timer? _midnightTimer;

  Future<void> registerTask() async {
    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

    await BackgroundFetch.configure(
          BackgroundFetchConfig(
            minimumFetchInterval: 20,
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
        )
        .then((int status) {
          log('configure success: $status', name: 'Background service');
        })
        .catchError((e) {
          log('configure ERROR: $e', name: 'Background service');
        });

    await BackgroundFetch.start()
        .then((v) async {
          await _executeBackgroundTask('initial');
          log('Background Service Started $v', name: 'Background service');
        })
        .catchError((e) {
          log('Error on Background Service $e', name: 'Background service');
        });

    // مهمة دورية كل 20 دقيقة (Android فقط — على iOS يكفي configure)
    if (Platform.isAndroid) {
      try {
        await BackgroundFetch.scheduleTask(
          TaskConfig(
            taskId: 'com.transistorsoft.fetchNotifications',
            delay: 20 * 60 * 1000, // 20 minutes
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
      } catch (e) {
        log('Task Scheduling Error: $e', name: 'Background service');
      }
    }

    // جدولة Timer منتصف الليل في الواجهة الأمامية
    scheduleForegroundMidnightTimer();
  }

  /// جدولة Timer في الواجهة الأمامية لتحديث الودجت عند منتصف الليل
  static void scheduleForegroundMidnightTimer() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 1);
    final delay = nextMidnight.difference(now);

    _midnightTimer = Timer(delay, () async {
      log(
        'Foreground midnight timer fired at ${DateTime.now()}',
        name: 'Background service',
      );
      await _executeBackgroundTask('foreground_midnight');
      // إعادة جدولة Timer التالي
      scheduleForegroundMidnightTimer();
    });

    log(
      'Foreground midnight timer scheduled for $nextMidnight (${delay.inMinutes} min)',
      name: 'Background service',
    );
  }

  /// إلغاء Timer منتصف الليل
  static void cancelForegroundMidnightTimer() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
  }
}

/// معالج المهام في الخلفية المحلي (MethodChannel)
class BackgroundTaskHandler {
  static const MethodChannel platform = MethodChannel(
    'com.alheekmah.alheekmahLibrary/background_tasks',
  );

  static Future<void> initializeHandler() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'performDailyTasks') {
        await PrayerBackgroundManager.executeDailyTasks();
      } else if (call.method == 'performBackgroundFetch') {
        await _executeBackgroundTask('native_callback');
      }
    });
  }
}

/// المنطق المشترك لجميع المهام — يُستدعى من كل المسارات
Future<void> _executeBackgroundTask(String taskId) async {
  log('Executing task: $taskId', name: 'Background service');

  try {
    await GetStorage.init();
    final storage = GetStorage();

    // المهام الدورية (إشعارات وغيرها)
    await PrayerBackgroundManager.executePeriodicTasks();

    // فحص ردود المشرف على ملاحظات المستخدم (مثل تطبيق القرآن).
    try {
      await FeedbackController.checkNewRepliesBackground();
    } catch (e) {
      log('feedback replies check failed: $e', name: 'Background service');
    }

    // التحقق من تغيّر التاريخ (يوم جديد بعد منتصف الليل)
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = storage.read('last_widget_update_date') as String?;

    if (lastDate == null || lastDate != today) {
      log(
        'New day detected ($lastDate -> $today), updating prayers & widget',
        name: 'Background service',
      );

      // محاولة إعادة حساب أوقات الصلاة لليوم الجديد
      try {
        await AdhanController.instance.initializeStoredAdhan(
          forceUpdate: false,
        );
      } catch (e) {
        log(
          'initializeStoredAdhan failed (will try cache fallback): $e',
          name: 'Background service',
        );
      }
      await PrayerBackgroundManager.executeDailyTasks();

      if (Platform.isIOS || Platform.isAndroid) {
        // await HijriWidgetConfig.initialize();
        await PrayersWidgetConfig.initialize();
        // await HijriWidgetConfig().updateHijriDate();
        await PrayersWidgetConfig().updatePrayersDate();
      }

      // لا نكتب التاريخ إلا إذا نجح تحديث ويدجت الصلوات فعلاً
      if (PrayersWidgetConfig.lastUpdateSucceeded) {
        storage.write('last_widget_update_date', today);
      } else {
        log(
          'Prayer widget update failed — will retry on next background task',
          name: 'Background service',
        );
      }
    }
  } catch (e) {
    log('Error in background task ($taskId): $e', name: 'Background service');
  }
}

Future<void> _onFetch(String taskId) async {
  log('Event received $taskId', name: 'Background service');
  await _executeBackgroundTask(taskId);
  BackgroundFetch.finish(taskId);
}

Future<void> _onTimeOut(String taskId) async {
  log('Task timeout: $taskId', name: 'Background service');
  BackgroundFetch.finish(taskId);
}
