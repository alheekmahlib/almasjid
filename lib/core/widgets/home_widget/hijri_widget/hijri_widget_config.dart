part of '../home_widget.dart';

class HijriWidgetConfig {
  Future<void> updateHijriDate() async {
    final eventCtrl = EventController.instance;
    if (Platform.isIOS) {
      try {
        HijriDate.setLocal('ar');
        await HomeWidget.saveWidgetData<String>(
            'hDay', '${eventCtrl.hijriNow.hDay}');
        await HomeWidget.saveWidgetData<String>(
            'hMonth', '${eventCtrl.hijriNow.hMonth}');
        await HomeWidget.saveWidgetData<String>(
            'hYear', '${eventCtrl.hijriNow.hYear}');
        await HomeWidget.saveWidgetData<String>(
            'lengthOfMonth', '${eventCtrl.getLengthOfMonth}');
      } catch (e) {
        log('Error updating Hijri date widget: $e');
      }
      await HomeWidget.updateWidget(
        iOSName: StringConstants.iosHijriWidget,
        // androidName: StringConstants.androidHijriWidget,
      );
    }
  }

  static Future<void> onHijriWidgetClicked() async {
    // الاستماع لأحداث النقر على الويدجت - Listen to widget click events
    HomeWidget.widgetClicked.listen((event) {
      log('widgetClicked: $event', name: 'HijriWidgetConfig');
      // تحويل Uri إلى String للمقارنة - Convert Uri to String for comparison
      final eventString = event?.toString() ?? '';
      if (eventString == StringConstants.iosHijriWidget) {
        // Get.to(() => HijriCalendarScreen(), transition: Transition.downToUp);
      }
    });
  }

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(StringConstants.groupId);
  }
}
