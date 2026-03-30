import 'dart:developer';

/// Web stub for MacOSWidgetService
class MacOSWidgetService {
  static MacOSWidgetService? _instance;
  static MacOSWidgetService get instance =>
      _instance ??= MacOSWidgetService._();

  MacOSWidgetService._();

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
    required String appLanguage,
    String? monthlyPrayerData,
  }) async {
    log('MacOSWidgetService.updatePrayerData skipped (web)',
        name: 'MacOSWidgetService');
  }

  Future<void> reloadAllTimelines() async {}
  Future<void> updateMonthlyPrayerData(String monthlyPrayerData,
      {String? appLanguage}) async {}
  Future<void> reloadTimeline(String widgetKind) async {}
  Future<void> initialize() async {}
}
