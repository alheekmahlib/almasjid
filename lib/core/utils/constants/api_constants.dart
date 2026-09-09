import 'api_keys.dart';

class ApiConstants {
  static const downloadAppUrl =
      'https://alheekmahlib.github.io/alheekmahlib/#/download/aqim';

  static const baseUrl = 'https://github.com/';
  static const String notificationsUrl =
      'alheekmahlib/thegarlanded/blob/master/noti.json?raw=true';

  /// مجلد أصوات الأذان في مستودع data:
  /// GitHub أساسي (قد يكون محجوباً في بعض الدول) وGitLab بديل تلقائي.
  static const String adhanSoundsBaseGithub =
      'https://raw.githubusercontent.com/alheekmahlib/data/main/adhan_sounds';
  static const String adhanSoundsBaseGitlab =
      'https://gitlab.com/haozo89/data/-/raw/main/adhanSounds';

  /// كتالوج أصوات الأذان البعيد؛ النسخة المدمجة assets/json/adhanSounds.json
  /// تُستخدم كاحتياط عند تعذر الجلب.
  static const String adhanSoundsCatalogUrl =
      'alheekmahlib/data/blob/main/adhan_sounds/adhanSounds.json?raw=true';
  static const String adhanSoundsCatalogFallbackUrl =
      '$adhanSoundsBaseGitlab/adhanSounds.json';

  /// كتالوج تطبيقات مكتبة الحكمة من لوحة Vexaltech.
  static const String ourAppsUrl = 'https://dash.vexaltech.dev/api/apps';

  /// Feedback API — نطاق مستقل عن baseUrl (يُمرَّر URL كامل في ApiClient.request).
  static const String feedbackApiUrl = 'https://vexaltech.dev/api/feedback';
  static const String feedbackEndpoint =
      '/feedback'; // POST إنشاء + GET /feedback/{token}
  static const String feedbackReplySuffix =
      '/reply'; // POST /feedback/{token}/reply
  static const String feedbackUploadEndpoint = '/upload'; // POST رفع وسائط

  /// ترويسة User-Agent المطلوبة لعمل مفاتيح MapTiler:
  /// المفتاح مقيّد في لوحة MapTiler بحقل Allowed User-Agent header بهذه القيمة
  /// (مطابقة جزئية حساسة لحالة الأحرف).
  static const String mapTilerUserAgent = ApiKeys.mapTilerUserAgent;

  /// positron هي نظيرة basemaps.cartocdn light_all (كلاهما تصميم CARTO).
  static const String mapLightUrl =
      'https://api.maptiler.com/maps/positron/{z}/{x}/{y}.png?key=${ApiKeys.mapTilerKey}';
  // 'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png';
  /// darkmatter هي نظيرة basemaps.cartocdn dark_all (كلاهما تصميم CARTO).
  static const String mapDarkUrl =
      'https://api.maptiler.com/maps/darkmatter/{z}/{x}/{y}.png?key=${ApiKeys.mapTilerKey}';
  // 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png';
}
