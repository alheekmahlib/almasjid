import 'dart:developer' show log;

import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';

import '/core/services/location/locations.dart';
// import '/core/widgets/home_widget/home_widget.dart';
import '/core/widgets/local_notification/controller/local_notifications_controller.dart';
import '../../presentation/prayers/prayers.dart';

/// مدير العمليات في الخلفية للصلوات
/// Background operations manager for prayers
class PrayerBackgroundManager {
  static const String _tag = 'PrayerBackgroundManager';

  /// التحقق من أوقات الصلاة وتحديثها إذا لزم الأمر
  /// Check prayer times and update if necessary
  static Future<bool> checkAndUpdatePrayerTimes() async {
    try {
      log('Starting prayer times check...', name: _tag);

      // الحصول على الموقع الحالي
      // Get current location
      final currentLocation = await _getCurrentLocation();
      if (currentLocation == null) {
        log('Unable to get current location', name: _tag);
        return false;
      }

      // التحقق من صحة التخزين الشهري أولاً
      // Check monthly cache validity first
      final isMonthlyValid = MonthlyPrayerCache.isMonthlyDataValid(
          currentLocation: currentLocation);

      // التحقق من صحة التخزين اليومي
      // Check daily cache validity
      final isDailyValid =
          PrayerCacheManager.isCacheValid(currentLocation: currentLocation);

      if (isMonthlyValid || isDailyValid) {
        log('Prayer times cache is valid, no update needed', name: _tag);
        return false; // لا حاجة للتحديث / No update needed
      }

      log('Prayer times cache is invalid, updating...', name: _tag);

      // تحديث أوقات الصلاة
      // Update prayer times
      await AdhanController.instance.initializeStoredAdhan(
        newLocation: currentLocation,
        forceUpdate: true,
      );

      // إعادة جدولة الإشعارات
      // Reschedule notifications
      await PrayersNotificationsCtrl.instance.reschedulePrayers();

      log('Prayer times updated successfully', name: _tag);
      return true; // تم التحديث / Updated
    } catch (e) {
      log('Error checking/updating prayer times: $e', name: _tag);
      return false;
    }
  }

  /// الحصول على الموقع الحالي
  /// Get current location
  static Future<LatLng?> _getCurrentLocation() async {
    try {
      final position = await LocationHelper().fetchCurrentPosition;
      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      log('Error getting location: $e', name: _tag);
    }
    return null;
  }

  /// تنفيذ المهام اليومية
  /// Execute daily tasks
  static Future<void> executeDailyTasks() async {
    try {
      log('Executing daily tasks...', name: _tag);

      // تحديث أوقات الصلاة
      // Update prayer times
      await checkAndUpdatePrayerTimes();

      // تحديث البيانات الشهرية في الخلفية
      // Update monthly data in background
      await AdhanController.instance.updateMonthlyDataInBackground();

      // تنظيف البيانات القديمة
      // Clean up old data
      await AdhanController.instance.cleanupOldData();

      // تحديث التاريخ الهجري في الويدجت
      // Update Hijri date in widget
      // await HijriWidgetConfig().updateHijriDate();

      // جلب الإشعارات الجديدة
      // Fetch new notifications
      await LocalNotificationsController.instance.fetchNewNotifications();

      // تحديث تاريخ آخر تشغيل للمهام اليومية
      // Update last daily task run date
      await _updateLastDailyTaskRun();

      log('Daily tasks completed successfully', name: _tag);
    } catch (e) {
      log('Error executing daily tasks: $e', name: _tag);
    }
  }

  /// تنفيذ المهام الدورية (كل 20 دقيقة)
  /// Execute periodic tasks (every 20 minutes)
  static Future<void> executePeriodicTasks() async {
    try {
      log('Executing periodic tasks...', name: _tag);

      // التحقق من أوقات الصلاة
      // Check prayer times
      final updated = await checkAndUpdatePrayerTimes();

      // await PrayersWidgetConfig.initialize();
      // await HijriWidgetConfig.initialize();

      // // تحديث ويدجت الصلوات في كل مرة - Update prayers widget every time
      // await PrayersWidgetConfig().updatePrayersDate();

      // // إجبار تحديث الويدجت حتى لو لم تتغير الأوقات - Force widget update even if times haven't changed
      // await HijriWidgetConfig().updateHijriDate();

      // التحقق من المهام اليومية إذا لزم الأمر
      // Check daily tasks if needed
      if (await _shouldExecuteDailyTasks()) {
        await executeDailyTasks();
      }

      log('Periodic tasks completed${updated ? ' (prayer times updated)' : ''} - Widget updated',
          name: _tag);
    } catch (e) {
      log('Error executing periodic tasks: $e', name: _tag);
    }
  }

  /// التحقق من ضرورة تنفيذ المهام اليومية
  /// Check if daily tasks should be executed
  static Future<bool> _shouldExecuteDailyTasks() async {
    try {
      final storage = GetStorage();
      final lastRun = storage.read('last_daily_task_run') as String?;

      if (lastRun == null) return true;

      final lastRunDate = DateTime.parse(lastRun);
      final now = DateTime.now();

      // تنفيذ المهام اليومية إذا مرت 24 ساعة
      // Execute daily tasks if 24 hours have passed
      return now.difference(lastRunDate).inHours >= 24;
    } catch (e) {
      log('Error checking daily tasks need: $e', name: _tag);
      return true; // في حالة الخطأ، نفذ المهام / On error, execute tasks
    }
  }

  /// تحديث تاريخ آخر تشغيل للمهام اليومية
  /// Update last daily task run date
  static Future<void> _updateLastDailyTaskRun() async {
    try {
      final storage = GetStorage();
      storage.write('last_daily_task_run', DateTime.now().toIso8601String());
    } catch (e) {
      log('Error updating last daily task run: $e', name: _tag);
    }
  }

  /// الحصول على إحصائيات العمليات في الخلفية
  /// Get background operations statistics
  static Map<String, dynamic> getStats() {
    final storage = GetStorage();
    final dailyCacheStats = PrayerCacheManager.getCacheStats();

    // إحصائيات التخزين الشهري
    final currentLocation = PrayerCacheManager.getStoredLocation();
    final isMonthlyValid = currentLocation != null
        ? MonthlyPrayerCache.isMonthlyDataValid(
            currentLocation: currentLocation)
        : false;

    return {
      'dailyCacheStats': dailyCacheStats,
      'monthlyCacheValid': isMonthlyValid,
      'currentLocation': currentLocation != null
          ? {
              'latitude': currentLocation.latitude,
              'longitude': currentLocation.longitude,
            }
          : null,
      'lastDailyTaskRun': storage.read('last_daily_task_run'),
      'shouldExecuteDailyTasks': false, // سيتم حسابها في runtime
      'cacheSystemVersion': '2.0', // نسخة النظام الجديد
    };
  }
}
