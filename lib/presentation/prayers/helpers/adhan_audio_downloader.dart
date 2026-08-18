part of '../prayers.dart';

/// تنزيل أصوات الأذان من الكتالوج حسب المنصة (GitHub ثم GitLab احتياطاً):
/// - أندرويد: ملفا WAV مباشرة — العادي والفجري (أذان الفجر مختلف) —
///   إلى `<Documents>/Sounds/audio/` لتشغّلهما خدمة التشغيل المباشر
///   وخصية تشغيل الأذان الكامل داخل التطبيق.
/// - iOS: حزمة zip تحتوي الأذان الكامل (عادي + فجري بصيغة m4a)
///   والمقطع القصير ≤30 ثانية (aiff)؛ يُستخرج كل شيء إلى Library/Sounds
///   لأن UNNotificationSound يحل أسماء الملفات من هناك، ويُخزن مسار
///   المقطع بمفتاح مستقل لصوت الإشعار بينما المفاتيح العادية تحمل
///   الأذان الكامل للتشغيل داخل التطبيق.
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

    if (Platform.isIOS) {
      return _downloadIos(adhanData, onReceiveProgress);
    }
    return _downloadAndroid(adhanData, onReceiveProgress);
  }

  /// مسار الصوت الكامل المحمّل للمقرئ (الفجري عند الطلب) إن وُجد فعلاً.
  static String? downloadedAudioPathFor(int index, {bool fajr = false}) {
    final box = GetStorage('AdhanSounds');
    final key = fajr
        ? '$index$ADHAN_PATH_FAJIR_AUDIO'
        : '$index$ADHAN_PATH_AUDIO';
    final path = box.read<String?>(key);
    return (path != null && File(path).existsSync()) ? path : null;
  }

  /// اسم ملف مقطع iOS (≤30 ثانية) المحمّل، أو null للرجوع للمدمج.
  static String? downloadedIosSegmentNameFor(int index) {
    final path = GetStorage(
      'AdhanSounds',
    ).read<String?>('$index$ADHAN_PATH_SEGMENT_AUDIO');
    return (path != null && File(path).existsSync()) ? _basename(path) : null;
  }

  /// حذف ملفات مقرئ محمّل ومفاتيح التخزين الخاصة به.
  static Future<void> deleteDownloaded(AdhanData adhanData) async {
    final box = GetStorage('AdhanSounds');
    for (final key in [
      '${adhanData.index}$ADHAN_PATH_AUDIO',
      '${adhanData.index}$ADHAN_PATH_FAJIR_AUDIO',
      '${adhanData.index}$ADHAN_PATH_SEGMENT_AUDIO',
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

  // ─── iOS ───

  Future<AdhanData> _downloadIos(
    AdhanData adhanData,
    void Function(int, int)? onReceiveProgress,
  ) async {
    final zipUrl = adhanData.urlIosAdhan;
    if (zipUrl == null) return adhanData;

    try {
      final bytes = await _downloadBytes(
        AdhanSoundsCatalog.resolveUrl(zipUrl),
        fallbackUrl: AdhanSoundsCatalog.resolveFallbackUrl(zipUrl),
        onReceiveProgress: onReceiveProgress,
      );
      if (bytes == null) return adhanData;

      // Library/Sounds هو المجلد الوحيد (غير حزمة التطبيق) الذي يحل منه
      // iOS أصوات الإشعارات؛ نستخرج فيه كل الملفات.
      final libraryDir = await getLibraryDirectory();
      final soundsDir = Directory(path.join(libraryDir.path, 'Sounds'));
      if (!soundsDir.existsSync()) {
        soundsDir.createSync(recursive: true);
      }

      final archive = ZipDecoder().decodeBytes(bytes);

      String? fullRegularPath;
      String? fullFajirPath;
      String? segmentPath;

      for (var file in archive) {
        final name = file.name.split('/').last;
        final isJunk = file.name.contains('__MACOSX') || name.startsWith('.');
        if (!file.isFile ||
            isJunk ||
            !_audioExtensions.any((ext) => name.toLowerCase().endsWith(ext))) {
          continue;
        }

        final extractedFile = File(path.join(soundsDir.path, name));
        await extractedFile.writeAsBytes(file.content as List<int>);

        final isFajir = name.toLowerCase().contains('fajir');
        // aiff = المقطع القصير لصوت الإشعار؛ m4a = الأذان الكامل للتشغيل.
        final isSegment =
            name.toLowerCase().endsWith('.aiff') ||
            name.toLowerCase().endsWith('.aif');
        if (isFajir) {
          fullFajirPath = extractedFile.path;
        } else if (isSegment) {
          segmentPath = extractedFile.path;
        } else {
          fullRegularPath = extractedFile.path;
        }
      }

      final box = GetStorage('AdhanSounds');
      if (fullRegularPath != null) {
        box.write('${adhanData.index}$ADHAN_PATH_AUDIO', fullRegularPath);
      }
      if (fullFajirPath != null) {
        box.write('${adhanData.index}$ADHAN_PATH_FAJIR_AUDIO', fullFajirPath);
      }
      if (segmentPath != null) {
        box.write('${adhanData.index}$ADHAN_PATH_SEGMENT_AUDIO', segmentPath);
      }
      box.write(ADHAN_PATH_INDEX, adhanData.index.toString());

      log(
        'iOS adhan extracted: full=$fullRegularPath, '
        'fajir=$fullFajirPath, segment=$segmentPath',
        name: 'AudioDownloader',
      );

      return _copyWithDownloaded(
        adhanData,
        mainPath: fullRegularPath,
        fajirPath: fullFajirPath,
        ios: true,
      );
    } catch (e) {
      log('Error downloading iOS adhan package: $e', name: 'AudioDownloader');
      return adhanData;
    }
  }

  // ─── Android ───

  Future<AdhanData> _downloadAndroid(
    AdhanData adhanData,
    void Function(int, int)? onReceiveProgress,
  ) async {
    final regularUrl = adhanData.urlAndroidAdhan;
    if (regularUrl == null) return adhanData;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, 'Sounds', 'audio'));
      if (!audioDir.existsSync()) {
        audioDir.createSync(recursive: true);
      }

      String? regularPath;
      String? fajirPath;

      // العادي (إجباري)
      final regularBytes = await _downloadBytes(
        AdhanSoundsCatalog.resolveUrl(regularUrl),
        fallbackUrl: AdhanSoundsCatalog.resolveFallbackUrl(regularUrl),
        onReceiveProgress: onReceiveProgress,
      );
      if (regularBytes != null) {
        final file = File(path.join(audioDir.path, regularUrl.split('/').last));
        await file.writeAsBytes(regularBytes);
        regularPath = file.path;
      }

      // الفجري (اختياري — أذان الفجر يختلف عن باقي الصلوات)
      final fajirUrl = adhanData.urlAndroidFajirAdhan;
      if (fajirUrl != null) {
        final fajirBytes = await _downloadBytes(
          AdhanSoundsCatalog.resolveUrl(fajirUrl),
          fallbackUrl: AdhanSoundsCatalog.resolveFallbackUrl(fajirUrl),
        );
        if (fajirBytes != null) {
          final file = File(path.join(audioDir.path, fajirUrl.split('/').last));
          await file.writeAsBytes(fajirBytes);
          fajirPath = file.path;
        }
      }

      if (regularPath == null) {
        throw Exception('Failed to download adhan audio files.');
      }

      final box = GetStorage('AdhanSounds');
      box.write('${adhanData.index}$ADHAN_PATH_AUDIO', regularPath);
      if (fajirPath != null) {
        box.write('${adhanData.index}$ADHAN_PATH_FAJIR_AUDIO', fajirPath);
      }
      box.write(ADHAN_PATH_INDEX, adhanData.index.toString());

      notiCtrl.state.tempAdhanPath.value = regularPath;
      notiCtrl.state.tempAdhanPathFajir.value = fajirPath ?? regularPath;
      log(
        'Android adhan saved: regular=$regularPath, fajir=$fajirPath',
        name: 'AudioDownloader',
      );

      return _copyWithDownloaded(
        adhanData,
        mainPath: regularPath,
        fajirPath: fajirPath,
        ios: false,
      );
    } catch (e) {
      log('Error downloading Android adhan: $e', name: 'AudioDownloader');
      return adhanData;
    }
  }

  // ─── أدوات مساعدة ───

  Future<List<int>?> _downloadBytes(
    String url, {
    String? fallbackUrl,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final result = await ApiClient().downloadFile(
      url: url,
      fallbackUrl: fallbackUrl,
      onProgress: onReceiveProgress,
      timeout: const Duration(minutes: 5),
      options: Options(responseType: ResponseType.bytes),
    );
    return result.isRight ? result.right as List<int>? : null;
  }

  AdhanData _copyWithDownloaded(
    AdhanData adhanData, {
    required String? mainPath,
    required String? fajirPath,
    required bool ios,
  }) {
    return AdhanData(
      index: adhanData.index,
      adhanFileName: adhanData.adhanFileName,
      adhanLocalPath: adhanData.adhanLocalPath,
      isBundled: adhanData.isBundled,
      adhanName: adhanData.adhanName,
      urlAndroidAdhan: adhanData.urlAndroidAdhan,
      urlAndroidFajirAdhan: adhanData.urlAndroidFajirAdhan,
      urlIosAdhan: adhanData.urlIosAdhan,
      urlPlayAdhan: adhanData.urlPlayAdhan,
      androidFilePath: ios ? adhanData.androidFilePath : mainPath,
      iosFilePath: ios ? mainPath : adhanData.iosFilePath,
      androidFajirFilePath: fajirPath,
      adhanPath: mainPath,
    );
  }

  static String _basename(String filePath) => filePath.split('/').last;
}
