import 'dart:developer' show log;
import 'dart:ui' show Locale;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  static SettingsController get instance =>
      GetInstance().putOrFind(() => SettingsController());
  Locale? initialLang;
  RxString languageName = 'العربية'.obs;
  RxString languageFont = 'naskh'.obs;
  // RxString languageFont2 = 'cairo'.obs;
  RxBool settingsSelected = false.obs;
  final box = GetStorage();

  // معالجة أكواد اللغات للتأكد من توافقها - Handle language codes to ensure compatibility
  // Handle Filipino language code mapping (fil <-> ph)
  static String _normalizeLanguageCode(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ph': // Philippines country code sometimes used incorrectly as language code
        return 'fil'; // Correct Filipino language code
      case 'fil':
        return 'fil';
      default:
        return languageCode;
    }
  }

  void setLocale(Locale value) {
    initialLang = value;
    update();
  }

  void loadLang() {
    String? langCode = box.read('lang');
    String? langName = box.read('langName') ?? 'العربية';
    String? langFont = box.read('languageFont') ?? 'naskh';
    // String? langFont2 =
    //     await box.read("languageFont2");

    log('Lang code: $langCode'); // Add this line to debug the value of langCode

    if (langCode == null || langCode.isEmpty) {
      initialLang = const Locale('ar', 'AE');
    } else {
      // تطبيع كود اللغة للتأكد من توافقه - Normalize language code for compatibility
      String normalizedLangCode = _normalizeLanguageCode(langCode);
      initialLang = Locale(normalizedLangCode,
          ''); // Make sure langCode is not null or invalid here
    }

    languageName.value = langName;
    languageFont.value = langFont;
    // languageFont2.value = langFont2;

    log('get lang $initialLang');
  }
}
