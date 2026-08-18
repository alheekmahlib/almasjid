import 'package:get/get.dart';

/// مدخل من كتالوج أصوات الأذان.
/// الروابط (url*) مسارات نسبية داخل مجلد الأصوات في مستودع data
/// وتُحل إلى GitHub أو GitLab عند التحميل (انظر AdhanSoundsCatalog).
class AdhanData {
  final int index;
  final String adhanFileName;

  /// مسار الصوت المدمج (resource://raw/...) أو null للمقرئين البعيدين فقط.
  final String? adhanLocalPath;

  /// true إذا كان الصوت مدمجاً في حزمة التطبيق (الافتراضي: الأقصى فقط).
  final bool isBundled;
  final String adhanName;

  /// ملف الأذان العادي لأندرويد (مسار نسبي، مثل android/saqqaf_athan.wav).
  final String? urlAndroidAdhan;

  /// ملف نسخة الفجر لأندرويد (اختياري).
  final String? urlAndroidFajirAdhan;

  /// ملف صوت iOS (مسار نسبي، مثل ios/saqqaf_athan.aiff) ≤30 ثانية
  /// ليصلح كصوت إشعار.
  final String? urlIosAdhan;

  /// رابط المعاينة (m4a مباشر).
  final String urlPlayAdhan;
  final String? androidFilePath;
  final String? iosFilePath;
  final String? androidFajirFilePath;
  final String? adhanPath;

  AdhanData({
    required this.index,
    required this.adhanFileName,
    this.adhanLocalPath,
    this.isBundled = false,
    required this.adhanName,
    this.urlAndroidAdhan,
    this.urlAndroidFajirAdhan,
    this.urlIosAdhan,
    required this.urlPlayAdhan,
    this.androidFilePath,
    this.iosFilePath,
    this.androidFajirFilePath,
    this.adhanPath,
  });

  String? get path =>
      GetPlatform.isIOS || GetPlatform.isMacOS ? iosFilePath : androidFilePath;

  factory AdhanData.fromJson(Map<String, dynamic> json) {
    final localPath = json['adhanLocalPath'] as String?;
    return AdhanData(
      index: json['index'] as int,
      adhanFileName: json['adhanFileName'] as String,
      adhanLocalPath: localPath,
      isBundled: json['isBundled'] as bool? ?? localPath != null,
      adhanName: json['adhanName'] as String,
      // توافق مع أسماء الحقول القديمة (urlAndroidAdhanZip/urlIosAdhanZip).
      urlAndroidAdhan:
          json['urlAndroidAdhan'] as String? ??
          json['urlAndroidAdhanZip'] as String?,
      urlAndroidFajirAdhan: json['urlAndroidFajirAdhan'] as String?,
      urlIosAdhan:
          json['urlIosAdhan'] as String? ?? json['urlIosAdhanZip'] as String?,
      urlPlayAdhan: json['urlPlayAdhan'] as String,
      androidFilePath: json['androidFilePath'] as String?,
      iosFilePath: json['iosFilePath'] as String?,
      androidFajirFilePath: json['androidFajirFilePath'] as String?,
      adhanPath: json['adhanPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'adhanFileName': adhanFileName,
      'adhanLocalPath': adhanLocalPath,
      'isBundled': isBundled,
      'adhanName': adhanName,
      'urlAndroidAdhan': urlAndroidAdhan,
      'urlAndroidFajirAdhan': urlAndroidFajirAdhan,
      'urlIosAdhan': urlIosAdhan,
      'urlPlayAdhan': urlPlayAdhan,
      'androidFilePath': androidFilePath,
      'iosFilePath': iosFilePath,
      'androidFajirFilePath': androidFajirFilePath,
      'adhanPath': adhanPath,
    };
  }
}
