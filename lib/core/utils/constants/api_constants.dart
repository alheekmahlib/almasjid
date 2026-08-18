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
      'alheekmahlib/data/blob/main/adhan_sounds/adhan_sounds.json?raw=true';
  static const String adhanSoundsCatalogFallbackUrl =
      '$adhanSoundsBaseGitlab/adhan_sounds.json';
  static const String ourAppsUrl =
      'alheekmahlib/thegarlanded/blob/master/ourApps.json?raw=true';
  static const String mapLightUrl =
      'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png';
  static const String mapDarkUrl =
      'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png';
  static const String mapHuaweiUrl =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
}
