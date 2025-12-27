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
    super.onInit();
  }

  @override
  void onReady() {
    // toggleSlider(duration: 3500);
    super.onReady();
  }

  void toggleSlider({required int duration}) {
    final height = Get.height;
    openSlider(duration: duration, height: height);
    closeSlider(duration: duration + 700, height: 0.0);
  }

  void openSlider({required int duration, required double height}) {
    Future.delayed(Duration(milliseconds: duration))
        .then((_) => state.firstContainerHeight.value = height);
    Future.delayed(Duration(milliseconds: duration + 200))
        .then((_) => state.secondContainerHeight.value = height);
  }

  void closeSlider({required int duration, required double height}) {
    Future.delayed(Duration(milliseconds: duration))
        .then((_) => state.secondContainerHeight.value = height);
    Future.delayed(Duration(milliseconds: duration + 200))
        .then((_) => state.firstContainerHeight.value = height);
  }

  Future<void> changeCustomWidget() async {
    if (LocationHelper().locationIsEmpty) {
      toggleSlider(duration: 0);
      Future.delayed(const Duration(milliseconds: 600),
          () => state.customWidgetIndex.value = 1);
    } else {
      await isNotificationAllowed();
    }
  }

  Future<void> isNotificationAllowed() async {
    bool isAllowed = await NotifyHelper().isNotificationAllowed();
    if (!isAllowed) {
      toggleSlider(duration: 0);
      Future.delayed(const Duration(milliseconds: 600),
          () => state.customWidgetIndex.value = 2);
    } else {
      hasNewFeatures();
    }
  }

  void hasNewFeatures() {
    if (WhatsNewController.instance.hasNewFeatures) {
      toggleSlider(duration: 0);
      Future.delayed(const Duration(milliseconds: 600),
          () => state.customWidgetIndex.value = 3);
    } else {
      toggleSlider(duration: 0);
      Future.delayed(const Duration(milliseconds: 900),
          () => Get.offAndToNamed(AppRouter.homeScreen));
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
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        await MacOSNotificationsService.instance.initialize();
        final granted =
            await MacOSNotificationsService.instance.requestPermissions();
        // حفظ حالة الصلاحية
        await GetStorage().write('notifications_permission_granted', granted);
        // تسجيل أن المستخدم شاهد شاشة تفعيل الإشعارات
        NotifyHelper().markNotificationSetupAsSeen();
        hasNewFeatures();
        return;
      } else {
        await NotifyHelper().requistPermissions();
        NotifyHelper.initAwesomeNotifications();
        // تسجيل أن المستخدم شاهد شاشة تفعيل الإشعارات
        NotifyHelper().markNotificationSetupAsSeen();
        hasNewFeatures();
      }
    } finally {
      state.isNotificationLoading.value = false;
    }
  }

  Future<void> _loadInitialData() async {
    SettingsController.instance.loadLang();
    GeneralController.instance.updateGreeting();
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
