/// Stub implementation for web platform where notifications are not supported.
library;

class NotifyHelper {
  static bool _initialized = false;

  String get audioPath => '';
  String get audioFajirPath => '';

  bool get isAllowed => false;
  bool get hasSeenNotificationSetup => true;

  void markNotificationSetupAsSeen() {}

  String customSound(Map<String, String?> payload, int reminderId) => '';

  Future<void> scheduledNotification({
    required int reminderId,
    required String title,
    required String summary,
    required String body,
    required bool isRepeats,
    DateTime? time,
    Map<String, String?>? payload,
    int? soundIndex,
  }) async {}

  static void initAwesomeNotifications() {
    _initialized = true;
  }

  Future<void> notificationBadgeListener() async {}

  Future<void> cancelNotification(int notificationId) async {}

  Future<void> requistPermissions() async {}

  void setNotificationsListeners() {}

  Future<bool> isNotificationAllowed() async => false;
}
