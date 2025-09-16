import 'package:get/get.dart';

// كنترولر GetX لإدارة الشاشة الحالية مع نمط الكائن الوحيد
// GetX controller to manage current screen with singleton pattern
class CustomTabBarController extends GetxController {
  // نمط الكائن الوحيد مع GetX
  // Singleton pattern with GetX
  static CustomTabBarController get instance =>
      Get.isRegistered<CustomTabBarController>()
          ? Get.find<CustomTabBarController>()
          : Get.put(CustomTabBarController());

  RxInt currentIndex = 0.obs;

  // التبديل بين الشاشتين
  // Toggle between screens
  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }
}
