import 'dart:convert';
import 'dart:developer' show log;

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/services/api_client.dart';
import '../../../core/services/error_handling_system.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../data/models/our_app_model.dart';

/// OurAppsController - تحكم في شاشة "تطبيقاتنا"
/// يجلب التطبيقات من واجهة Vexaltech عبر ApiClient ويفلترها حسب الشركة.
class OurAppsController extends GetxController {
  static OurAppsController get instance =>
      GetInstance().putOrFind(() => OurAppsController());

  /// حالة التحميل - Loading state
  final RxBool isLoading = false.obs;

  /// قائمة التطبيقات المفلترة - Filtered apps list
  final RxList<OurAppInfo> apps = <OurAppInfo>[].obs;

  /// رسالة الخطأ - Error message
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApps();
  }

  /// جلب التطبيقات من Vexaltech ثم الفلترة بحسب
  /// companyName == 'Alheekmah Library'
  Future<void> fetchApps() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient().request(
        endpoint: ApiConstants.ourAppsUrl,
        method: HttpMethod.get,
      );

      response.fold((failure) => errorMessage.value = failure.message, (data) {
        final decoded = data is String ? jsonDecode(data) : data;
        final List<dynamic> raw = decoded['apps'] as List<dynamic>;
        final all = raw
            .map((e) => OurAppInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        apps.value = all
            .where((a) => a.companyName == 'Alheekmah Library')
            .toList();
      });
    } catch (e, s) {
      log('Exception details:\n $e', name: 'OurAppsController');
      log('Stack trace:\n $s', name: 'OurAppsController');
      errorMessage.value = DataSource.DEFAULT.getFailure().message;
    } finally {
      isLoading.value = false;
    }
  }

  /// يفتح صفحة تنزيل التطبيق عبر dynamicLink القادم من Vexaltech
  /// (يُشتق من slug داخل الموديل إن غاب الرابط الصريح).
  Future<void> launchApp(OurAppInfo app) async {
    if (app.dynamicLink.isEmpty) {
      log('No download link for app ${app.id}', name: 'OurAppsController');
      return;
    }
    final uri = Uri.parse(app.dynamicLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      log('No url client found', name: 'OurAppsController');
    }
  }
}
