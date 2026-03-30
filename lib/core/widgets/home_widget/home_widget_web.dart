/// Stub implementation for web platform where home widgets are not supported.
library;

class HijriWidgetConfig {
  Future<void> updateHijriDate() async {}
  static Future<void> onHijriWidgetClicked() async {}
  static Future<void> initialize() async {}
}

class PrayersWidgetConfig {
  Future<void> updatePrayersDate() async {}
  static Future<void> onPrayerWidgetClicked() async {}
  static Future<void> initialize() async {}
}
