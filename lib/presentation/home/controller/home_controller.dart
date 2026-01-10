part of '../home.dart';

class HomeController extends GetxController {
  int _currentIndex = 1; // البداية بصفحة الصلاة في الوسط

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    update();
  }
}
