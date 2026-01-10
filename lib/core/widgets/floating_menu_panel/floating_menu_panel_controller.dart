import 'package:flutter/foundation.dart';

enum FloatingMenuPanelPhysicalSide {
  left,
  right,
  top,
  bottom,
}

class FloatingMenuPanelController extends ChangeNotifier {
  bool _isOpen;

  /// جهة المقبض على الشاشة (يسار/يمين/فوق/تحت) ويمكن الاستماع لها.
  /// تكون null قبل أول بناء للمكوّن.
  final ValueNotifier<FloatingMenuPanelPhysicalSide?> physicalSide =
      ValueNotifier<FloatingMenuPanelPhysicalSide?>(null);

  /// جهة المقبض عموديًا (top/bottom) ويمكن الاستماع لها.
  /// تكون null قبل أول بناء للمكوّن.
  final ValueNotifier<FloatingMenuPanelPhysicalSide?> verticalSide =
      ValueNotifier<FloatingMenuPanelPhysicalSide?>(null);

  FloatingMenuPanelController({bool initialIsOpen = false})
      : _isOpen = initialIsOpen;

  bool get isOpen => _isOpen;

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void toggle() {
    _isOpen ? close() : open();
  }

  void updatePhysicalSide(FloatingMenuPanelPhysicalSide side) {
    if (physicalSide.value == side) return;
    physicalSide.value = side;
  }

  void updateVerticalSide(FloatingMenuPanelPhysicalSide side) {
    if (verticalSide.value == side) return;
    verticalSide.value = side;
  }
}
