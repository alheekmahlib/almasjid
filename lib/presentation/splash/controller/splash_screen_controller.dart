part of '../splash.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get instance =>
      GetInstance().putOrFind(() => SplashScreenController());

  SplashState state = SplashState();

  @override
  void onInit() {
    _loadInitialData();
    startTime();
    Future.delayed(const Duration(milliseconds: 600))
        .then((_) => state.logoAnimate.value = true);
    Future.delayed(const Duration(milliseconds: 4000))
        .then((_) => state.containerAnimate.value = true);
    Future.delayed(const Duration(milliseconds: 3800))
        .then((_) => state.smallContainerHeight.value = Get.height);
    // Future.delayed(const Duration(milliseconds: 4500)).then((_) {
    //   state.customWidget.value = 0;
    // });
    super.onInit();
  }

  /// -------- [Methods] ----------

  Future<void> _loadInitialData() async {
    SettingsController.instance.loadLang();
    GeneralController.instance.getLastPageAndFontSize();
    GeneralController.instance.updateGreeting();
    GeneralController.instance.state.screenSelectedValue.value =
        state.box.read(SCREEN_SELECTED_VALUE) ?? 0;
  }

  Future startTime() async {
    await Future.delayed(const Duration(milliseconds: 4300));
    WhatsNewController.instance.activeLocation();
  }

  Widget ramadhanOrEidGreeting() {
    if (state.today.hMonth == 9) {
      return ramadanOrEid('ramadan_white', height: 100.0);
    } else if (GeneralController.instance.eidDays) {
      return ramadanOrEid('eid_white', height: 100.0);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget get customWidget {
    switch (state.customWidget.value) {
      case 1:
        return ActiveLocationWidget();
      case 2:
        return ActiveNotificationWidget();
      case 3:
        return WhatsNewScreen(
          newFeatures: WhatsNewController.instance.state.newFeatures,
        );
      default:
        return Container();
    }
  }
}
