import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../presentation/controllers/settings_controller.dart';
import '../../utils/constants/shared_preferences_constants.dart';
import '../services_locator.dart';
import 'app_constants.dart';
import 'language_models.dart';

class LocalizationController extends GetxController implements GetxService {
  static LocalizationController get instance =>
      GetInstance().putOrFind(() => LocalizationController());
  GetStorage box = GetStorage();

  LocalizationController() {
    loadCurrentLanguage();
  }

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

  Locale _locale = Locale(AppConstants.languages[1].languageCode,
      AppConstants.languages[1].countryCode);

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  List<LanguageModel> _languages = [];
  Locale get locale => _locale;
  List<LanguageModel> get languages => _languages;

  void loadCurrentLanguage() {
    // تطبيع كود اللغة للتأكد من توافقه - Normalize language code for compatibility
    String languageCode = _normalizeLanguageCode(
        box.read(AppConstants.LANGUAGE_CODE) ??
            AppConstants.languages[1].languageCode);

    _locale = Locale(
        languageCode,
        box.read(AppConstants.COUNTRY_CODE) ??
            AppConstants.languages[1].countryCode);

    for (int index = 0; index < AppConstants.languages.length; index++) {
      if (AppConstants.languages[index].languageCode == _locale.languageCode) {
        _selectedIndex = index;
        break;
      }
    }
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
  }

  void setLanguage(Locale locale) {
    // تطبيع كود اللغة للتأكد من توافقه - Normalize language code for compatibility
    String normalizedLanguageCode = _normalizeLanguageCode(locale.languageCode);
    Locale normalizedLocale =
        Locale(normalizedLanguageCode, locale.countryCode);

    // تحديث اللغة في GetX أولاً - Update language in GetX first
    Get.updateLocale(normalizedLocale);
    _locale = normalizedLocale;
    saveLanguage(_locale);
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void saveLanguage(Locale locale) async {
    box.write(AppConstants.LANGUAGE_CODE, locale.languageCode);
    box.write(AppConstants.COUNTRY_CODE, locale.countryCode!);
  }

  Future<void> changeLangOnTap(int index) async {
    final lang = AppConstants.languages[index];

    // تطبيع كود اللغة للتأكد من توافقه - Normalize language code for compatibility
    String normalizedLanguageCode = _normalizeLanguageCode(lang.languageCode);

    // تحديث اللغة المحلية أولاً - Update local language first
    setLanguage(Locale(normalizedLanguageCode, ''));

    // حفظ إعدادات اللغة - Save language settings
    await box.write(LANG, normalizedLanguageCode);
    await box.write(LANG_NAME, lang.languageName);

    // تحديث إعدادات التطبيق - Update app settings
    sl<SettingsController>().languageName.value = lang.languageName;
    update(['changeLanguage']);
    // إجبار تحديث جميع Controllers المعتمدة على اللغة
    // Force update all language-dependent Controllers
    Get.forceAppUpdate();
  }
}
