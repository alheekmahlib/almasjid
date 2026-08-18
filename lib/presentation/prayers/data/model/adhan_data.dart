import 'package:get/get.dart';

class AdhanData {
  final int index;
  final String adhanFileName;

  /// مسار الصوت المدمج (resource://raw/...) أو null للمقرئين البعيدين فقط.
  final String? adhanLocalPath;

  /// true إذا كان الصوت مدمجاً في حزمة التطبيق (الافتراضي: الأقصى فقط).
  final bool isBundled;
  final String adhanName;
  final String urlAndroidAdhanZip;
  final String urlIosAdhanZip;
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
    required this.urlAndroidAdhanZip,
    required this.urlIosAdhanZip,
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
      urlAndroidAdhanZip: json['urlAndroidAdhanZip'] as String,
      urlIosAdhanZip: json['urlIosAdhanZip'] as String,
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
      'urlAndroidAdhanZip': urlAndroidAdhanZip,
      'urlIosAdhanZip': urlIosAdhanZip,
      'urlPlayAdhan': urlPlayAdhan,
      'androidFilePath': androidFilePath,
      'iosFilePath': iosFilePath,
      'androidFajirFilePath': androidFajirFilePath,
      'adhanPath': adhanPath,
    };
  }
}
