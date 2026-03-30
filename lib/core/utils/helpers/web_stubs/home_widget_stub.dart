/// Web stub for home_widget package
class HomeWidget {
  static Future<void> setAppGroupId(String groupId) async {}

  static Future<bool?> saveWidgetData<T>(String id, T? data) async => null;

  static Future<bool?> updateWidget({
    String? iOSName,
    String? androidName,
    String? qualifiedAndroidName,
  }) async =>
      null;

  static Future<T?> getWidgetData<T>(String id, {T? defaultValue}) async =>
      defaultValue;
}
