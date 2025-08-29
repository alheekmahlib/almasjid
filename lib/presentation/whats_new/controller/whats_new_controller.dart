part of '../whats_new.dart';

class WhatsNewController extends GetxController {
  static WhatsNewController get instance =>
      GetInstance().putOrFind(() => WhatsNewController());

  WhatsNewState state = WhatsNewState();
  @override
  Future<void> onInit() async {
    activeLocation();
    state.newFeatures = await getNewFeatures();
    super.onInit();
  }

  /// -------- [Methods] ----------

  void navigationPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.newFeatures.isNotEmpty) {
        SplashScreenController.instance.state.customWidget.value = 3;
      } else {
        Get.offAllNamed(AppRouter.homeScreen);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getNewFeatures() async {
    int lastShownIndex = await getLastShownIndex();

    List<Map<String, dynamic>> newFeatures = whatsNewList.where((item) {
      return item['index'] > lastShownIndex;
    }).toList();

    return newFeatures;
  }

  void showWhatsNew() async {
    List<Map<String, dynamic>> newFeatures = await getNewFeatures();
    if (newFeatures.isNotEmpty) {
      await saveLastShownIndex(newFeatures.last['index']);
    }
  }

  void activeLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!GeneralController.instance.isFirstLaunch) {
        GetStorage().write(IS_LOCATION_ACTIVE, true);
        SplashScreenController.instance.state.customWidget.value = 1;
      } else {
        navigationPage();
      }
    });
  }

  List<Map<String, dynamic>> whatsNewList = [
    {
      'index': 11,
      'title': "",
      'details': "What'sNewDetails10",
      'imagePath': '',
    },
  ];
}
