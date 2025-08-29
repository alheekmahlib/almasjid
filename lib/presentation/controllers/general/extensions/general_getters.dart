import 'dart:developer';

import 'package:get/get.dart';

import '../../../../core/utils/constants/shared_preferences_constants.dart';
import '../../../calendar/events.dart';
import '../general_controller.dart';

extension GeneralGetters on GeneralController {
  /// -------- [Getters] ----------

  List get eidDaysList =>
      ['1-10', '2-10', '3-10', '10-12', '11-12', '12-12', '13-12'];

  String get eidGreetingContent =>
      EventController.instance.hijriNow.hMonth == 10
          ? 'eidGreetingContent'.tr
          : 'eidGreetingContent2'.tr;

  bool get eidDays {
    String todayString =
        '${EventController.instance.hijriNow.hDay}-${EventController.instance.hijriNow.hMonth}';
    return eidDaysList.contains(todayString);
  }

  void getLastPageAndFontSize() {
    try {
      double fontSizeFromPref = state.box.read(FONT_SIZE) ?? 24.0;
      if (fontSizeFromPref != 0.0 && fontSizeFromPref > 0) {
        state.fontSizeArabic.value = fontSizeFromPref;
      } else {
        state.fontSizeArabic.value = 24.0;
      }
    } catch (e) {
      log('Failed to load last page: $e');
    }
  }

  bool get isActiveLocation => state.box.read(IS_LOCATION_ACTIVE) ?? false;
  bool get isFirstLaunch => state.box.read(FIRST_LAUNCH) ?? false;
}
