import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GeneralState {
  /// -------- [Variables] ----------

  final box = GetStorage();

  RxDouble fontSizeArabic = 20.0.obs;
  RxBool isShowControl = true.obs;
  RxString greeting = ''.obs;
  final ScrollController ayahListController = ScrollController();
  double ayahItemWidth = 30.0;
  RxInt screenSelectedValue = 0.obs;
  RxBool activeLocation = false.obs;
  // RxBool isLocationActive = false.obs;

  // مفتاح للحصول على ارتفاع AyahTafsirWidget
  // final tafsirKey = GlobalKey().obs;

  // RxInt buttonIndex = 0.obs;
}
