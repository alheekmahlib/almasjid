import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GeneralState {
  /// -------- [Variables] ----------

  final box = GetStorage();

  RxDouble fontSizeArabic = 20.0.obs;
  RxBool isShowControl = true.obs;
  RxString greeting = ''.obs;
  RxBool activeLocation = false.obs;
  RxBool isLocationLoading = false.obs;
}
