part of '../splash.dart';

class SplashState {
  /// -------- [Variables] ----------
  var today = EventController.instance.hijriNow;
  final box = GetStorage();
  RxBool logoAnimate = false.obs;
  RxBool containerAnimate = false.obs;
  RxDouble smallContainerHeight = 0.0.obs;
  RxInt customWidget = 0.obs;
}
