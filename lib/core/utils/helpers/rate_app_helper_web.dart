/// Stub implementation for web platform where rate_my_app is not supported.
library;

import 'package:flutter/material.dart';

class RateAppHelper {
  static Future<void> initRateMyApp() async {}

  static final _RateMyAppStub rateMyApp = _RateMyAppStub();

  static void showRateDialog(BuildContext context) {}
}

class _RateMyAppStub {
  Future<void> init() async {}
  bool get shouldOpenDialog => false;
}
