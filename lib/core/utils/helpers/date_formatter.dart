import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../services/languages/localization_controller.dart';

class DateFormatter {
  // معالجة أكواد اللغات للتأكد من توافقها مع مكتبة intl - Handle language codes to ensure compatibility with intl library
  // Handle Filipino language code mapping (fil <-> ph)
  static String _normalizeLocaleCode(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'ph': // Philippines country code sometimes used incorrectly as language code
        return 'fil'; // Correct Filipino language code
      case 'fil':
        return 'fil';
      default:
        return localeCode;
    }
  }

  static final String _locale =
      _normalizeLocaleCode(LocalizationController.instance.locale.languageCode);

  /// Formats the given [dateTime] to just time (hour and minute) in the user's time zone.
  /// Example: 4:10 AM (English), ٤:١٠ ص (Arabic)
  static Future<String> justTime(DateTime dateTime) async {
    try {
      final userDateTime = await _convertToUserTimeZone(dateTime);
      final hour = DateFormat('hh', _locale).format(userDateTime);
      final minute = DateFormat('mm', _locale).format(userDateTime);
      final period = DateFormat('a', _locale).format(userDateTime);
      return '$hour:$minute $period';
    } catch (e) {
      // Fallback to English if the locale is not supported
      // التراجع إلى الإنجليزية إذا كانت اللغة غير مدعومة
      final userDateTime = await _convertToUserTimeZone(dateTime);
      final hour = DateFormat('hh', 'en').format(userDateTime);
      final minute = DateFormat('mm', 'en').format(userDateTime);
      final period = DateFormat('a', 'en').format(userDateTime);
      return '$hour:$minute $period';
    }
  }

  /// Formats the given [dateTime] to just date in the user's time zone.
  /// Example: Apr 7, 2024
  static Future<String> justDate(DateTime dateTime) async {
    try {
      final userDateTime = await _convertToUserTimeZone(dateTime);
      return DateFormat.yMMMd(_locale).format(userDateTime);
    } catch (e) {
      // Fallback to English if the locale is not supported
      // التراجع إلى الإنجليزية إذا كانت اللغة غير مدعومة
      final userDateTime = await _convertToUserTimeZone(dateTime);
      return DateFormat.yMMMd('en').format(userDateTime);
    }
  }

  /// Formats the given [dateTime] to date and time in the user's time zone.
  /// Example: Apr 7, 2024, 8:00 PM
  static Future<String> dateAndTime(DateTime dateTime) async {
    try {
      final userDateTime = await _convertToUserTimeZone(dateTime);
      return DateFormat.yMMMd(_locale).add_jm().format(userDateTime);
    } catch (e) {
      // Fallback to English if the locale is not supported
      // التراجع إلى الإنجليزية إذا كانت اللغة غير مدعومة
      final userDateTime = await _convertToUserTimeZone(dateTime);
      return DateFormat.yMMMd('en').add_jm().format(userDateTime);
    }
  }

  /// Converts the given [dateTime] to the user's time zone.
  static Future<tz.TZDateTime> _convertToUserTimeZone(DateTime dateTime) async {
    final userTimeZone = await _getUserTimeZone();
    return tz.TZDateTime.from(dateTime, userTimeZone);
  }

  /// Get the user's time zone
  static Future<tz.Location> _getUserTimeZone() async {
    TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();
    final String currentTimeZone = timezone.identifier;
    return tz.getLocation(currentTimeZone);
  }

  static String formatPrayerTime(DateTime? time) {
    if (time == null) return '';
    try {
      // Customize the format as needed
      return DateFormat('h:mm a', _locale).format(time);
    } catch (e) {
      // Fallback to English if the locale is not supported
      // التراجع إلى الإنجليزية إذا كانت اللغة غير مدعومة
      return DateFormat('h:mm a', 'en').format(time);
    }
  }

  static String timeLeft(DateTime? time) {
    if (time == null) return '';
    try {
      // Customize the format as needed
      return DateFormat('hh:mm', _locale).format(time);
    } catch (e) {
      // Fallback to English if the locale is not supported
      // التراجع إلى الإنجليزية إذا كانت اللغة غير مدعومة
      return DateFormat('hh:mm', 'en').format(time);
    }
  }
}
