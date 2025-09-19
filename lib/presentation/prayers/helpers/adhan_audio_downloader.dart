part of '../prayers.dart';

class AudioDownloader {
  final notiCtrl = PrayersNotificationsCtrl.instance;

  Future<AdhanData> downloadAndUnzipAdhan(AdhanData adhanData,
      {void Function(int, int)? onReceiveProgress}) async {
    final androidFilePath =
        // Platform.isAndroid
        //     ?
        await _downloadAndExtractFile(
      adhanData.index,
      adhanData.urlAndroidAdhanZip,
      adhanData.adhanFileName,
      'audio',
      onReceiveProgress: onReceiveProgress,
    );
    // : null;

    // final iosFilePath = Platform.isIOS || Platform.isMacOS
    //     ? await _downloadAndExtractFile(
    //         adhanData.urlIosAdhanZip,
    //         adhanData.adhanFileName,
    //         'ios',
    //         onReceiveProgress: onReceiveProgress,
    //       )
    //     : null;

    return AdhanData(
      index: adhanData.index,
      adhanFileName: adhanData.adhanFileName,
      adhanLocalPath: adhanData.adhanLocalPath,
      adhanName: adhanData.adhanName,
      urlAndroidAdhanZip: adhanData.urlAndroidAdhanZip,
      urlIosAdhanZip: adhanData.urlIosAdhanZip,
      urlPlayAdhan: adhanData.urlPlayAdhan,
      androidFilePath: androidFilePath,
      iosFilePath: '', // iosFilePath,
      androidFajirFilePath: notiCtrl.state.tempAdhanPathFajir.value,
      adhanPath: notiCtrl.state.tempAdhanPath.value,
    );
  }

  Future<String?> _downloadAndExtractFile(
      int index, String url, String fileName, String platform,
      {void Function(int, int)? onReceiveProgress}) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 60),
        ),
        onReceiveProgress: onReceiveProgress,
      );

      // استخدام getLibraryDirectory بدلاً من getTemporaryDirectory
      final appDir = Platform.isAndroid
          ? await getApplicationDocumentsDirectory() // Use application documents directory on Android
          : await getLibraryDirectory();
      final soundsDir = Directory(path.join(appDir.path, 'Sounds'));

      // التأكد من وجود المجلد وإنشائه إذا لم يكن موجودًا
      if (!soundsDir.existsSync()) {
        soundsDir.createSync(recursive: true);
      }

      final zipFilePath = path.join(soundsDir.path, '$fileName.zip');
      final zipFile = File(zipFilePath);

      await zipFile.writeAsBytes(response.data);

      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      String? extractedFilePath;
      String? extractedFilePathFajir;

      for (var file in archive) {
        if (file.isFile &&
            (file.name.endsWith('.wav') ||
                file.name.endsWith('.mp3') ||
                file.name.endsWith('.m4a'))) {
          final outputPath = path.join(soundsDir.path, platform);
          final extractedFile = File(path.join(outputPath, file.name));
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(file.content as List<int>);

          if (file.name.contains('fajir')) {
            extractedFilePathFajir = extractedFile.path;
            GetStorage('AdhanSounds')
                .write('$index$ADHAN_PATH_FAJIR_AUDIO', extractedFile.path);
            log('extractedFilePathFajir: ${extractedFile.path}',
                name: 'AudioDownloader');
          } else {
            extractedFilePath = extractedFile.path;
            GetStorage('AdhanSounds')
                .write('$index$ADHAN_PATH_AUDIO', extractedFile.path);
            log('extractedFilePath: ${extractedFile.path}',
                name: 'AudioDownloader');
          }
        }
      }
      GetStorage('AdhanSounds').write(ADHAN_PATH_INDEX, index.toString());

      await zipFile.delete();

      if (extractedFilePath == null || extractedFilePathFajir == null) {
        throw Exception('Failed to extract audio files.');
      }
      notiCtrl.state.tempAdhanPathFajir.value = extractedFilePathFajir;
      notiCtrl.state.tempAdhanPath.value = extractedFilePath;
      log('Final tempAdhanPath: ${notiCtrl.state.tempAdhanPath.value}');
      log('Final tempAdhanPathFajir: ${notiCtrl.state.tempAdhanPathFajir.value}');

      return extractedFilePathFajir;
    } catch (e) {
      log('Error downloading or extracting file: $e');
      return null;
    }
  }
}
