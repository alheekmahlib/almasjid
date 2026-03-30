/// Stub implementation for web platform where background services are not supported.
library;

void backgroundFetchHeadlessTask(dynamic task) {}

class BackgroundTaskHandler {
  static Future<void> initializeHandler() async {}
}

class BGServices {
  void printBackgroundOptimizationTips() {}
  Future<void> checkBackgroundFetchStatus() async {}
  Future<void> registerTask() async {}
}
