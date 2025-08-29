import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../prayers/prayers.dart';
import '../qibla/qibla.dart';

class HomeController extends GetxController {
  int _currentIndex = 0; // البداية بصفحة الصلاة في الوسط

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    update();
  }

  Widget getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return PrayerScreen(); // القبلة - اليمين
      case 1:
        return QiblaScreen();
      default:
        return PrayerScreen();
    }
  }

  Widget getScreenByIndex(int index) {
    switch (index) {
      case 0:
        return PrayerScreen(); // القبلة - اليمين
      case 1:
        return QiblaScreen(); // الصلاة - الوسط (الصفحة الرئيسية)
      default:
        return PrayerScreen();
    }
  }
}
