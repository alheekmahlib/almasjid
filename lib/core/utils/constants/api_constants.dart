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
  static const String mapLightUrl =
      'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png';
  static const String mapDarkUrl =
      'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png';
  static const String mapHuaweiUrl =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
}
