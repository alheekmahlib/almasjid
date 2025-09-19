part of '../splash.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get instance =>
      GetInstance().putOrFind(() => SplashScreenController());

  SplashState state = SplashState();

  @override
  Future<void> onInit() async {
    _loadInitialData();
    Future.delayed(const Duration(milliseconds: 4300))
        .then((_) async => await changeCustomWidget());
    // startTime();
    WhatsNewController.instance.state.newFeatures =
        await WhatsNewController.instance.getNewFeatures();
    super.onInit();
  }

  @override
  void onReady() {
    final height = Get.height;
    openSlider(duration: 3500, height: height);
    closeSlider(duration: 4300, height: 0.0);
    super.onReady();
  }

  void openSlider({required int duration, required double height}) {
    Future.delayed(Duration(milliseconds: duration))
        .then((_) => state.firstContainerHeight.value = height);
    Future.delayed(Duration(milliseconds: duration + 300))
        .then((_) => state.secondContainerHeight.value = height);
  }

  void closeSlider({required int duration, required double height}) {
    Future.delayed(Duration(milliseconds: duration))
        .then((_) => state.secondContainerHeight.value = height);
    Future.delayed(Duration(milliseconds: duration + 300))
        .then((_) => state.firstContainerHeight.value = height);
  }

  Future<void> changeCustomWidget() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!GeneralController.instance.state.activeLocation.value) {
      state.customWidgetIndex.value = 1;
    } else if (!isAllowed) {
      state.customWidgetIndex.value = 2;
    } else if (WhatsNewController.instance.state.newFeatures.isNotEmpty) {
      state.customWidgetIndex.value = 3;
    } else {
      Get.offAndToNamed(AppRouter.homeScreen);
    }
  }

  Widget get customWidget {
    switch (state.customWidgetIndex.value) {
      case 0:
        return AnimatedDrawingWidget(
          customColor: Get.theme.canvasColor,
        );
      case 1:
        return ActiveLocationWidget();
      case 2:
        return ActiveNotificationWidget();
      case 3:
        return WhatsNewScreen(
          newFeatures: WhatsNewController.instance.state.newFeatures,
        );
      default:
        return AnimatedDrawingWidget(
          customColor: Get.theme.canvasColor,
        );
    }
  }

  /// -------- [Methods] ----------

  Future<void> activateNotifications() async {
    try {
      state.isNotificationLoading.value = true;
      await NotifyHelper().requistPermissions();
      NotifyHelper.initAwesomeNotifications();
      state.customWidgetIndex.value = 3;
    } finally {
      state.isNotificationLoading.value = false;
    }
  }

  Future<void> _loadInitialData() async {
    SettingsController.instance.loadLang();
    GeneralController.instance.getLastPageAndFontSize();
    GeneralController.instance.updateGreeting();
    GeneralController.instance.state.screenSelectedValue.value =
        state.box.read(SCREEN_SELECTED_VALUE) ?? 0;
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
}
