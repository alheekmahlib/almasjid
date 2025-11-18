part of '../home.dart';

class HomeController extends GetxController {
  int _currentIndex = 1; // البداية بصفحة الصلاة في الوسط

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    update();
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
