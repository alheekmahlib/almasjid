import 'package:flutter/material.dart' show Color;

/// Web stub for awesome_notifications types

class ReceivedNotification {
  final int id;
  final DateTime? displayedDate;
  final String? title;
  final String? summary;
  final String? body;
  final Map<String, String?>? payload;

  ReceivedNotification({
    this.id = 0,
    this.displayedDate,
    this.title,
    this.summary,
    this.body,
    this.payload,
  });
}

class ReceivedAction extends ReceivedNotification {
  ReceivedAction({
    super.id,
    super.displayedDate,
    super.title,
    super.summary,
    super.body,
    super.payload,
  });
}

class NotificationContent {
  NotificationContent({
    required int id,
    required String channelKey,
    ActionType actionType = ActionType.Default,
    String? title,
    String? summary,
    String? body,
    Map<String, String?>? payload,
    String? customSound,
    bool? wakeUpScreen,
    int? badge,
    String? groupKey,
  });
}

class NotificationChannel {
  NotificationChannel({
    String? channelGroupKey,
    required String channelKey,
    required String channelName,
    required String channelDescription,
    Color? ledColor,
    NotificationImportance importance = NotificationImportance.Default,
    bool playSound = true,
    String? soundSource,
  });
}

class NotificationChannelGroup {
  NotificationChannelGroup({
    required String channelGroupKey,
    required String channelGroupName,
  });
}

class NotificationCalendar {
  NotificationCalendar.fromDate({required DateTime date, bool repeats = false});
}

class NotificationInterval {
  NotificationInterval({
    required Duration interval,
    String? timeZone,
    bool repeats = false,
  });
}

enum NotificationImportance { Default, Max }

enum ActionType { Default }

class AwesomeNotifications {
  void initialize(String? icon, List<NotificationChannel> channels,
      {List<NotificationChannelGroup>? channelGroups, bool debug = false}) {}

  Future<void> createNotification(
      {NotificationContent? content, dynamic schedule}) async {}

  Future<String> getLocalTimeZoneIdentifier() async => 'UTC';

  Future<int> getGlobalBadgeCounter() async => 0;

  Future<void> setGlobalBadgeCounter(int count) async {}

  Future<void> cancelSchedule(int id) async {}

  Future<bool> isNotificationAllowed() async => false;

  Future<bool> requestPermissionToSendNotifications() async => false;

  void setListeners({
    Future<void> Function(ReceivedAction)? onActionReceivedMethod,
    Future<void> Function(ReceivedNotification)? onNotificationCreatedMethod,
    Future<void> Function(ReceivedNotification)? onNotificationDisplayedMethod,
    Future<void> Function(ReceivedAction)? onDismissActionReceivedMethod,
  }) {}
}
