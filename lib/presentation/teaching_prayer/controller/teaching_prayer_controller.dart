part of '../teaching.dart';

class TeachingPrayerController extends GetxController {
  static TeachingPrayerController get instance =>
      Get.isRegistered<TeachingPrayerController>()
          ? Get.find<TeachingPrayerController>()
          : Get.put<TeachingPrayerController>(TeachingPrayerController());

  final RxBool isLoading = false.obs;
  final Rx<TeachingPrayerData?> data = Rx<TeachingPrayerData?>(null);

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
      final source =
          await rootBundle.loadString('assets/json/teaching_prayer.json');
      // تأكد من صحة JSON (مع دعم التعليقات المحتملة عبر إزالة /* ... */)
      final sanitized = _stripBlockComments(source);
      final jsonMap = json.decode(sanitized) as Map<String, dynamic>;
      data.value = TeachingPrayerData.fromJson(jsonMap);
    } catch (e) {
      // تجاهل: يمكن لاحقاً ربطه بـ error_handling_system
      data.value = TeachingPrayerData(sections: const [], lastUpdated: null);
    } finally {
      isLoading.value = false;
      update(['loading_state', 'content_state']);
    }
  }

  List<TPSection> get sections => data.value?.sections ?? const [];

  String get currentLang => Get.locale?.languageCode ?? 'ar';

  static String _stripBlockComments(String input) {
    // يزيل التعليقات على شكل /* ... */ للحالات التي يحتوي فيها JSON على شروح
    final regex = RegExp(r'/\*[^*]*\*+(?:[^/*][^*]*\*+)*/',
        multiLine: true, dotAll: true);
    return input.replaceAll(regex, '');
  }
}
