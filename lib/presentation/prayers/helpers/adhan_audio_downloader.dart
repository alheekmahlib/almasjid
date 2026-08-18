part of '../prayers.dart';

/// تنزيل أصوات الأذان من الكتالوج واستخراجها حسب المنصة:
/// - أندرويد: الأذان كاملاً (عادي + فجري) إلى `<Documents>/Sounds/audio/`
///   لتشغّله خدمة التشغيل المباشر عند وقت الصلاة.
/// - iOS: مقطع ≤30 ثانية إلى Library/Sounds مباشرة، لأن UNNotificationSound
///   يحل أسماء الملفات من هذا المجلد فقط (غير المدمج من الحزمة).
/// - macOS: غير مدعوم في هذه المرحلة (يبقى على الأصوات المدمجة).
class AudioDownloader {
  final notiCtrl = PrayersNotificationsCtrl.instance;

  static const List<String> _audioExtensions = [
    '.wav',
    '.mp3',
    '.m4a',
    '.caf',
    '.aiff',
    '.aif',
  ];

  Future<AdhanData> downloadAndUnzipAdhan(
    AdhanData adhanData, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (Platform.isMacOS) return adhanData;

    final url = Platform.isIOS
        ? adhanData.urlIosAdhanZip
        : adhanData.urlAndroidAdhanZip;

    if (Platform.isIOS) {
      final segmentPath = await _downloadAndExtractIosSegment(
        adhanData.index,
        url,
        adhanData.adhanFileName,
        onReceiveProgress: onReceiveProgress,
      );
      return AdhanData(
        index: adhanData.index,
        adhanFileName: adhanData.adhanFileName,
        adhanLocalPath: adhanData.adhanLocalPath,
        isBundled: adhanData.isBundled,
        adhanName: adhanData.adhanName,
        urlAndroidAdhanZip: adhanData.urlAndroidAdhanZip,
        urlIosAdhanZip: adhanData.urlIosAdhanZip,
        urlPlayAdhan: adhanData.urlPlayAdhan,
        androidFilePath: adhanData.androidFilePath,
        iosFilePath: segmentPath,
        androidFajirFilePath: adhanData.androidFajirFilePath,
        adhanPath: segmentPath,
      );
    }

    final androidFilePath = await _downloadAndExtractAndroid(
      adhanData.index,
      url,
      adhanData.adhanFileName,
      onReceiveProgress: onReceiveProgress,
    );

    return AdhanData(
      index: adhanData.index,
      adhanFileName: adhanData.adhanFileName,
      adhanLocalPath: adhanData.adhanLocalPath,
      isBundled: adhanData.isBundled,
      adhanName: adhanData.adhanName,
      urlAndroidAdhanZip: adhanData.urlAndroidAdhanZip,
      urlIosAdhanZip: adhanData.urlIosAdhanZip,
      urlPlayAdhan: adhanData.urlPlayAdhan,
      androidFilePath: androidFilePath,
      iosFilePath: adhanData.iosFilePath,
      androidFajirFilePath: notiCtrl.state.tempAdhanPathFajir.value,
      adhanPath: androidFilePath,
    );
  }

  /// مسار الصوت المحمّل للمقرئ إن وُجد الملف فعلاً على القرص.
  static String? downloadedAudioPathFor(int index) {
    final path = GetStorage(
      'AdhanSounds',
    ).read<String?>('$index$ADHAN_PATH_AUDIO');
    return (path != null && File(path).existsSync()) ? path : null;
  }

  /// حذف ملفات مقرئ محمّل ومفاتيح التخزين الخاصة به.
  static Future<void> deleteDownloaded(AdhanData adhanData) async {
    final box = GetStorage('AdhanSounds');
    for (final key in [
      '${adhanData.index}$ADHAN_PATH_AUDIO',
      '${adhanData.index}$ADHAN_PATH_FAJIR_AUDIO',
    ]) {
      final path = box.read<String?>(key);
      if (path != null) {
        try {
          final file = File(path);
          if (file.existsSync()) await file.delete();
        } catch (e) {
          log(
            'Failed deleting downloaded adhan file: $e',
            name: 'AudioDownloader',
          );
        }
      }
      box.remove(key);
    }
  }

  Future<List<int>?> _downloadZipBytes(
    String url, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: const Duration(seconds: 60),
      ),
      onReceiveProgress: onReceiveProgress,
    );
    return response.data as List<int>?;
  }

  /// iOS: استخراج المقطع الأول (مرتباً بالاسم) إلى Library/Sounds مباشرة.
  Future<String?> _downloadAndExtractIosSegment(
    int index,
    String url,
    String fileName, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final bytes = await _downloadZipBytes(
        url,
        onReceiveProgress: onReceiveProgress,
      );
      if (bytes == null) return null;

      // Library/Sounds هو المجلد الوحيد (غير حزمة التطبيق) الذي يحل منه
      // iOS أصوات الإشعارات.
      final libraryDir = await getLibraryDirectory();
      final soundsDir = Directory(path.join(libraryDir.path, 'Sounds'));
      if (!soundsDir.existsSync()) {
        soundsDir.createSync(recursive: true);
      }

      final zipFile = File(path.join(soundsDir.path, '$fileName.zip'));
      await zipFile.writeAsBytes(bytes);
      final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
      await zipFile.delete();

      final audioFiles =
          archive
              .where(
                (file) =>
                    file.isFile &&
                    _audioExtensions.any(
                      (ext) => file.name.toLowerCase().endsWith(ext),
                    ),
              )
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      if (audioFiles.isEmpty) return null;

      final first = audioFiles.first;
      final extractedFile = File(path.join(soundsDir.path, first.name));
      await extractedFile.writeAsBytes(first.content as List<int>);

      GetStorage(
        'AdhanSounds',
      ).write('$index$ADHAN_PATH_AUDIO', extractedFile.path);
      log(
        'iOS segment extracted: ${extractedFile.path}',
        name: 'AudioDownloader',
      );
      return extractedFile.path;
    } catch (e) {
      log('Error downloading iOS adhan segment: $e', name: 'AudioDownloader');
      return null;
    }
  }

  /// أندرويد: استخراج الأذان كاملاً (عادي + فجري إن وُجد) إلى Sounds/audio/.
  Future<String?> _downloadAndExtractAndroid(
    int index,
    String url,
    String fileName, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final bytes = await _downloadZipBytes(
        url,
        onReceiveProgress: onReceiveProgress,
      );
      if (bytes == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory(path.join(appDir.path, 'Sounds'));
      if (!soundsDir.existsSync()) {
        soundsDir.createSync(recursive: true);
      }

      final zipFile = File(path.join(soundsDir.path, '$fileName.zip'));
      await zipFile.writeAsBytes(bytes);
      final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
      await zipFile.delete();

      String? extractedFilePath;
      String? extractedFilePathFajir;

      for (var file in archive) {
        if (file.isFile &&
            _audioExtensions.any(
              (ext) => file.name.toLowerCase().endsWith(ext),
            )) {
          final outputPath = path.join(soundsDir.path, 'audio');
          final extractedFile = File(path.join(outputPath, file.name));
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(file.content as List<int>);

          if (file.name.toLowerCase().contains('fajir')) {
            extractedFilePathFajir = extractedFile.path;
            GetStorage(
              'AdhanSounds',
            ).write('$index$ADHAN_PATH_FAJIR_AUDIO', extractedFile.path);
            log(
              'extractedFilePathFajir: ${extractedFile.path}',
              name: 'AudioDownloader',
            );
          } else {
            extractedFilePath = extractedFile.path;
            GetStorage(
              'AdhanSounds',
            ).write('$index$ADHAN_PATH_AUDIO', extractedFile.path);
            log(
              'extractedFilePath: ${extractedFile.path}',
              name: 'AudioDownloader',
            );
          }
        }
      }
      GetStorage('AdhanSounds').write(ADHAN_PATH_INDEX, index.toString());

      // الملف الفجري اختياري؛ بعض الحزم لا تحتوي نسخة فجرية.
      if (extractedFilePath == null) {
        throw Exception('Failed to extract audio files.');
      }
      notiCtrl.state.tempAdhanPathFajir.value =
          extractedFilePathFajir ?? extractedFilePath;
      notiCtrl.state.tempAdhanPath.value = extractedFilePath;
      log(
        'Final tempAdhanPath: ${notiCtrl.state.tempAdhanPath.value}',
        name: 'AudioDownloader',
      );
      log(
        'Final tempAdhanPathFajir: ${notiCtrl.state.tempAdhanPathFajir.value}',
        name: 'AudioDownloader',
      );

      return extractedFilePath;
    } catch (e) {
      log('Error downloading or extracting file: $e', name: 'AudioDownloader');
      return null;
    }
  }
}
