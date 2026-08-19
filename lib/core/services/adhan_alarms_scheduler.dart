import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:flutter/services.dart' show MethodChannel;

/// إنذار تشغيل أذان واحد: نفس معرف إشعار FLN المقابل له.
class AdhanAlarm {
  const AdhanAlarm({
    required this.id,
    required this.time,
    this.filePath,
    this.notifId,
    this.notifTitle,
    this.notifText,
    this.stopActionLabel,
  });

  final int id;
  final DateTime time;

  /// مسار الصوت المحمّل؛ null يعني الرجوع للمورد الخام الافتراضي (الأقصى).
  final String? filePath;

  /// معرف ونصوص إشعار الصلاة نفسه؛ تدمج الخدمة إشعارها الأمامي فيه
  /// (نفس المعرف) فيظهر إشعار واحد فقط — تماماً مثل iOS/macOS.
  final int? notifId;
  final String? notifTitle;
  final String? notifText;
  final String? stopActionLabel;
}

/// جدولة إنذارات تشغيل الأذان على أندرويد بالتوازي مع إشعارات
/// flutter_local_notifications؛ عند انطلاق الإنذار تُطلق خدمة أمامية
/// تشغّل الأذان كاملاً. لا تعمل هذه الجدولة على iOS/macOS (إشعار FLN
/// نفسه يحمل الصوت هناك).
class AdhanAlarmsScheduler {
  const AdhanAlarmsScheduler._();

  static const MethodChannel _channel = MethodChannel(
    'com.alheekmah.aqimApp/adhan_alarms',
  );

  static Future<void> schedule(List<AdhanAlarm> alarms) async {
    if (!Platform.isAndroid || alarms.isEmpty) return;
    try {
      await _channel.invokeMethod('scheduleAdhanAlarms', {
        'alarms': alarms
            .map(
              (alarm) => <String, Object?>{
                'id': alarm.id,
                'triggerAtMillis': alarm.time.millisecondsSinceEpoch,
                'filePath': alarm.filePath,
                'notifId': alarm.notifId,
                'notifTitle': alarm.notifTitle,
                'notifText': alarm.notifText,
                'stopActionLabel': alarm.stopActionLabel,
              },
            )
            .toList(),
      });
      log('Scheduled ${alarms.length} adhan alarms', name: 'AdhanAlarms');
    } catch (e) {
      log('Failed scheduling adhan alarms: $e', name: 'AdhanAlarms');
    }
  }

  static Future<void> cancel(List<int> ids) async {
    if (!Platform.isAndroid || ids.isEmpty) return;
    try {
      await _channel.invokeMethod('cancelAdhanAlarms', {'ids': ids});
    } catch (e) {
      log('Failed cancelling adhan alarms: $e', name: 'AdhanAlarms');
    }
  }

  static Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('hasExactAlarmPermission') ??
          false;
    } catch (e) {
      log('Failed checking exact alarm permission: $e', name: 'AdhanAlarms');
      return false;
    }
  }
}
