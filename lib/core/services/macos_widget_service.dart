import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

/// خدمة دمج ويدجت macOS مع نظام أوقات الصلاة
/// macOS Widget integration service with prayer times system
class MacOSWidgetService {
  static MacOSWidgetService? _instance;
  static MacOSWidgetService get instance => _instance ??= MacOSWidgetService._();
  
  MacOSWidgetService._();
  
  // قناة التواصل مع Swift - Communication channel with Swift
  static const MethodChannel _channel = MethodChannel('com.alheekmah.alheekmahLibrary/macos_widget');
  
  /// تحديث بيانات الصلاة في ويدجت macOS
  /// Update prayer data in macOS widget
  Future<void> updatePrayerData({
    required DateTime fajrTime,
    required DateTime sunriseTime,
    required DateTime dhuhrTime,
    required DateTime asrTime,
    required DateTime maghribTime,
    required DateTime ishaTime,
    required DateTime middleOfTheNightTime,
    required DateTime lastThirdOfTheNightTime,
    required String fajrName,
    required String sunriseName,
    required String dhuhrName,
    required String asrName,
    required String maghribName,
    required String ishaName,
    required String middleOfTheNightName,
    required String lastThirdOfTheNightName,
    required String hijriDay,
    required String hijriDayName,
    required String hijriMonth,
    required String hijriYear,
    required String currentPrayerName,
    required String nextPrayerName,
    required DateTime? currentPrayerTime,
    required DateTime? nextPrayerTime,
  }) async {
    try {
      if (!Platform.isMacOS) return;
      
      // تحضير البيانات للإرسال - Prepare data for sending
      final Map<String, dynamic> prayerData = {
        // أوقات الصلاة - Prayer times
        'fajrTime': fajrTime.toIso8601String(),
        'sunriseTime': sunriseTime.toIso8601String(),
        'dhuhrTime': dhuhrTime.toIso8601String(),
        'asrTime': asrTime.toIso8601String(),
        'maghribTime': maghribTime.toIso8601String(),
        'ishaTime': ishaTime.toIso8601String(),
        'middleOfTheNightTime': middleOfTheNightTime.toIso8601String(),
        'lastThirdOfTheNightTime': lastThirdOfTheNightTime.toIso8601String(),
        
        // أسماء الصلاة - Prayer names
        'fajrName': fajrName,
        'sunriseName': sunriseName,
        'dhuhrName': dhuhrName,
        'asrName': asrName,
        'maghribName': maghribName,
        'ishaName': ishaName,
        'middleOfTheNightName': middleOfTheNightName,
        'lastThirdOfTheNightName': lastThirdOfTheNightName,
        
        // التاريخ الهجري - Hijri date
        'hijriDay': hijriDay,
        'hijriDayName': hijriDayName,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        
        // الصلاة الحالية والقادمة - Current and next prayer
        'currentPrayerName': currentPrayerName,
        'nextPrayerName': nextPrayerName,
        'currentPrayerTime': currentPrayerTime?.toIso8601String() ?? '',
        'nextPrayerTime': nextPrayerTime?.toIso8601String() ?? '',
        
        // طابع زمني للتحديث - Update timestamp
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // إرسال البيانات إلى Swift - Send data to Swift
      await _channel.invokeMethod('updatePrayerData', prayerData);
      
      log('تم إرسال بيانات الصلاة إلى ويدجت macOS - Prayer data sent to macOS widget successfully',
          name: 'MacOSWidgetService');
    } catch (e) {
      log('خطأ في تحديث بيانات الصلاة لـ macOS: $e - Error updating prayer data for macOS: $e',
          name: 'MacOSWidgetService');
    }
  }
  
  /// إعادة تحميل جميع timelines للويدجت
  /// Reload all widget timelines
  Future<void> reloadAllTimelines() async {
    try {
      if (!Platform.isMacOS) return;
      
      await _channel.invokeMethod('reloadAllTimelines');
      
      log('تم إعادة تحميل timelines للويدجت - Widget timelines reloaded successfully',
          name: 'MacOSWidgetService');
    } catch (e) {
      log('خطأ في إعادة تحميل timelines: $e - Error reloading timelines: $e',
          name: 'MacOSWidgetService');
    }
  }
  
  /// تحديث ويدجت معين
  /// Update specific widget
  Future<void> reloadTimeline(String widgetKind) async {
    try {
      if (!Platform.isMacOS) return;
      
      await _channel.invokeMethod('reloadTimeline', {'widgetKind': widgetKind});
      
      log('تم إعادة تحميل timeline للويدجت $widgetKind - Timeline reloaded for widget $widgetKind',
          name: 'MacOSWidgetService');
    } catch (e) {
      log('خطأ في إعادة تحميل timeline للويدجت $widgetKind: $e - Error reloading timeline for widget $widgetKind: $e',
          name: 'MacOSWidgetService');
    }
  }
  
  /// تهيئة الخدمة
  /// Initialize service
  Future<void> initialize() async {
    try {
      if (!Platform.isMacOS) return;
      
      await _channel.invokeMethod('initialize');
      
      log('تم تهيئة خدمة ويدجت macOS - macOS widget service initialized successfully',
          name: 'MacOSWidgetService');
    } catch (e) {
      log('خطأ في تهيئة خدمة ويدجت macOS: $e - Error initializing macOS widget service: $e',
          name: 'MacOSWidgetService');
    }
  }
}
