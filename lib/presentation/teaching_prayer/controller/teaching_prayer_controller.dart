part of '../teaching.dart';

class TeachingPrayerController extends GetxController {
  static TeachingPrayerController get instance =>
      Get.isRegistered<TeachingPrayerController>()
          ? Get.find<TeachingPrayerController>()
          : Get.put<TeachingPrayerController>(TeachingPrayerController());

  // ─────────────────────────────────────────────────────────────────────────
  // حالة التحميل والبيانات
  // ─────────────────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final Rx<TeachingPrayerData?> data = Rx<TeachingPrayerData?>(null);

  /// بيانات السنن والبدع الشهرية
  final Rx<SunnahsAndHeresiesData?> sunnahsData =
      Rx<SunnahsAndHeresiesData?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (isLoading.value) return;
    isLoading.value = true;
    update(['loading_state']);
    try {
      await Future.wait([
        _loadTeachingPrayerData(),
        _loadSunnahsAndHeresiesData(),
      ]);
    } finally {
      isLoading.value = false;
      update(['loading_state', 'content_state', 'sunnahs_state']);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // تحميل بيانات تعليم الصلاة
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadTeachingPrayerData() async {
    try {
      final source =
          await rootBundle.loadString('assets/json/teaching_prayer.json');
      final sanitized = _stripBlockComments(source);
      final jsonMap = json.decode(sanitized) as Map<String, dynamic>;
      data.value = TeachingPrayerData.fromJson(jsonMap);
    } catch (_) {
      data.value = TeachingPrayerData(sections: const [], lastUpdated: null);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // تحميل بيانات السنن والبدع
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadSunnahsAndHeresiesData() async {
    try {
      final source =
          await rootBundle.loadString('assets/json/sunnahsAndHeresies.json');
      final sanitized = _stripBlockComments(source);
      final jsonMap = json.decode(sanitized) as Map<String, dynamic>;
      sunnahsData.value = SunnahsAndHeresiesData.fromJson(jsonMap);
    } catch (_) {
      sunnahsData.value = const SunnahsAndHeresiesData(months: []);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // API الخاص بالسنن والبدع حسب الشهر الهجري
  // ─────────────────────────────────────────────────────────────────────────

  /// جلب بيانات شهر هجري معين
  /// [monthNumber] رقم الشهر من 1 (محرم) إلى 12 (ذو الحجة)
  /// يُرجع null إذا لم توجد بيانات للشهر المطلوب
  HijriMonthData? getMonthData(int monthNumber) {
    return sunnahsData.value?.getMonthData(monthNumber);
  }

  /// التحقق من وجود بيانات لشهر معين
  bool hasDataForMonth(int monthNumber) {
    return sunnahsData.value?.hasDataForMonth(monthNumber) ?? false;
  }

  /// جلب قائمة السنن لشهر معين
  /// تُرجع قائمة فارغة إذا لم يوجد الشهر
  List<SunnahItem> getSunnahsForMonth(int monthNumber) {
    return getMonthData(monthNumber)?.validSunnahs ?? const [];
  }

  /// جلب قائمة البدع لشهر معين
  /// تُرجع قائمة فارغة إذا لم يوجد الشهر
  List<HeresyItem> getHeresiesForMonth(int monthNumber) {
    return getMonthData(monthNumber)?.validHeresies ?? const [];
  }

  /// جلب الحديث/الآية لشهر معين
  /// تُرجع null إذا لم يوجد الشهر أو الحديث فارغ
  HadithInfo? getHadithForMonth(int monthNumber) {
    final hadith = getMonthData(monthNumber)?.hadith;
    return (hadith?.isNotEmpty ?? false) ? hadith : null;
  }

  /// قائمة أرقام الأشهر المتاحة في البيانات
  List<int> get availableMonths =>
      sunnahsData.value?.availableMonths ?? const [];

  // ─────────────────────────────────────────────────────────────────────────
  // Getters عامة
  // ─────────────────────────────────────────────────────────────────────────

  List<TPSection> get sections => data.value?.sections ?? const [];

  String get currentLang => Get.locale?.languageCode ?? 'ar';

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// إزالة التعليقات من JSON
  static String _stripBlockComments(String input) {
    final regex = RegExp(
      r'/\*[^*]*\*+(?:[^/*][^*]*\*+)*/',
      multiLine: true,
      dotAll: true,
    );
    return input.replaceAll(regex, '');
  }
}
