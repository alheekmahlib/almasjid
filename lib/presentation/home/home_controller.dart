import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../prayers/prayers.dart';
import '../qibla/qibla.dart';
import '../settings/screens/settings_screen.dart';
import '../teaching_prayer/teaching.dart';

class HomeController extends GetxController {
  int _currentIndex = 1; // البداية بصفحة الصلاة في الوسط

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    update();
  }

  Widget getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return QiblaScreen();
      case 1:
        return PrayerScreen();
      case 2:
        return const TeachingPrayerScreen();
      case 3:
        return const SettingsScreen();
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
      case 3:
        return const TeachingPrayerScreen();
      default:
        return PrayerScreen();
    }
  }
}
