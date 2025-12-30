part of '../../../prayers.dart';

extension PrayersNotiUi on PrayersNotificationsCtrl {
  Future<void> playButtonOnTap(List<AdhanData>? adhanData, int i) async {
    final isDownloaded =
        state.downloadedAdhanData.any((d) => d.index == adhanData![i].index);
    if (isDownloaded) {
      AdhanData? adhan = state.downloadedAdhanData
          .firstWhere((a) => a.index == adhanData![i].index);
      await state.audioPlayer
          .setAudioSource(
            AudioSource.file(
              adhan.adhanPath!,
            ),
          )
          .then((_) async => await state.audioPlayer.play());
      log('AdhanPath: ${adhan.adhanPath} index: ${adhanData![i].index}');
    } else {
      log('urlPlayAdhan: ${adhanData![i].urlPlayAdhan} index: ${adhanData[i].index}');
      await state.audioPlayer
          .setAudioSource(
            AudioSource.uri(
              Uri.parse(adhanData[i].urlPlayAdhan),
            ),
          )
          .then((_) async => await state.audioPlayer.play());
    }
  }

  void switchAdhanOnTap(int index) {
    switch (index) {
      case 0:
        state.selectedAdhanPath.value = 'resource://raw/aqsa_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/aqsa_athan'
            : 'resource://raw/aqsa_fajir_athan';
        break;
      case 1:
        state.selectedAdhanPath.value = 'resource://raw/saqqaf_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/saqqaf_athan'
            : 'resource://raw/saqqaf_fajir_athan';
        break;
      case 2:
        state.selectedAdhanPath.value = 'resource://raw/sarihi_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/sarihi_athan'
            : 'resource://raw/sarihi_athan_fajir';
        break;
      case 3:
        state.selectedAdhanPath.value = 'resource://raw/baset_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/baset_athan'
            : 'resource://raw/baset_fajir_athan';
        break;
      case 4:
        state.selectedAdhanPath.value = 'resource://raw/qatami_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/qatami_athan'
            : 'resource://raw/qatami_fajir_athan';
        break;
      case 5:
        state.selectedAdhanPath.value = 'resource://raw/salah_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/salah_athan'
            : 'resource://raw/salah_fajir_athan';
        break;
      default:
        state.selectedAdhanPath.value = 'resource://raw/aqsa_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/aqsa_athan'
            : 'resource://raw/aqsa_fajir_athan';
    }

    // تخزين المسارات المختارة في GetStorage
    GetStorage('AdhanSounds').write(ADHAN_PATH, state.selectedAdhanPath.value);
    GetStorage('AdhanSounds')
        .write(ADHAN_PATH_FAJIR, state.selectedAdhanPathFajir.value);

    log('Adhan selected: $index, Path: ${state.selectedAdhanPath.value}',
        name: 'PrayersNotiUi');
    log('Adhan Fajir Path: ${state.selectedAdhanPathFajir.value}',
        name: 'PrayersNotiUi');
  }

  RxBool isAdhanSelectByIndex(int adhanIndex) =>
      state.adhanList[adhanIndex].adhanLocalPath ==
              state.selectedAdhanPath.value
          ? true.obs
          : false.obs;

  RxBool isAdhanDownloadedByIndex(int adhanIndex) => (null !=
          state.downloadedAdhanData
              .firstWhereOrNull((e) => e.index == adhanIndex))
      .obs;

  RxBool isAdhanPathDownloadedByIndex(int adhanIndex) =>
      (state.selectedAdhanPath.value ==
              state.downloadedAdhanData
                  .firstWhereOrNull((e) => e.index == adhanIndex)
                  ?.adhanPath)
          .obs;

  void onReceiveProgress(int received, int total) {
    if (total != -1) {
      state.progress.value = (received / total);
      state.progressString.value =
          '${(state.progress.value * 100).toStringAsFixed(0)}%';
      log(state.progressString.value);
    }
  }

  void onNotificationActionReceived(ReceivedAction receivedAction) async {
    if (DateTime.now().isBefore(
        receivedAction.displayedDate!.add(const Duration(minutes: 5)))) {
      Get.bottomSheet(
              Container(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                margin: const EdgeInsets.only(right: 8.0, left: 8.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox().customSvgWithColor(
                            SvgPath.svgCloseCarve,
                            width: 120,
                            color: Theme.of(Get.context!)
                                .colorScheme
                                .inversePrimary,
                          ),
                          Container(
                            width: 70,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(Get.context!)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                        ],
                      ),
                      const Gap(8),
                      PrayerDetails(
                        prayerNameTranslated: receivedAction.title,
                        prayerSummary: receivedAction.summary,
                        payload: receivedAction.payload!,
                      ),
                    ],
                  ),
                ),
              ),
              isScrollControlled: true)
          .then((_) async => await state.adhanPlayer.stop());
      await playAudio(receivedAction.id, receivedAction.title);
    }
  }

  Future<void> playAudio(int? id, String? title) async {
    final String athanIndex =
        GetStorage('AdhanSounds').read(ADHAN_PATH_INDEX) ?? '0';
    String? audioPath =
        GetStorage('AdhanSounds').read<String?>('$athanIndex$ADHAN_PATH_AUDIO');
    String? audioFajirPath = GetStorage('AdhanSounds')
        .read<String?>('$athanIndex$ADHAN_PATH_FAJIR_AUDIO');

    log('Audio paths: audioPath=$audioPath, audioFajirPath=$audioFajirPath, id=$id',
        name: 'NotifyHelper');

    // تحديد مسار الصوت المناسب (فجر أو عادي)
    final String? targetPath = id == 0 ? audioFajirPath : audioPath;

    // التحقق من وجود الملف المُحمّل
    if (targetPath != null && File(targetPath).existsSync()) {
      try {
        log('Playing downloaded audio: $targetPath', name: 'NotifyHelper');
        await state.adhanPlayer.setAudioSource(AudioSource.file(targetPath));
        await state.adhanPlayer.play();
        return;
      } catch (e, stack) {
        log('Error playing downloaded audio: $e',
            error: e, stackTrace: stack, name: 'NotifyHelper');
      }
    }

    // على Android، استخدم ملفات raw المحلية عبر MethodChannel
    if (Platform.isAndroid) {
      try {
        // قراءة المسار المحدد للأذان من التخزين
        final String selectedPath = id == 0
            ? (GetStorage('AdhanSounds').read<String?>(ADHAN_PATH_FAJIR) ??
                'resource://raw/aqsa_fajir_athan')
            : (GetStorage('AdhanSounds').read<String?>(ADHAN_PATH) ??
                'resource://raw/aqsa_athan');

        // استخراج اسم الملف من المسار
        final String fileName =
            selectedPath.replaceFirst('resource://raw/', '');

        log('Getting raw audio path for: $fileName', name: 'NotifyHelper');

        // استخدام MethodChannel للحصول على مسار الملف من raw
        const channel = MethodChannel('com.alheekmah.aqimApp/raw_audio');
        final String? rawPath = await channel.invokeMethod<String>(
          'getRawAudioPath',
          {'fileName': fileName},
        );

        if (rawPath != null && File(rawPath).existsSync()) {
          log('Playing raw audio from: $rawPath', name: 'NotifyHelper');
          await state.adhanPlayer.setAudioSource(AudioSource.file(rawPath));
          await state.adhanPlayer.play();
          return;
        }
      } catch (e, stack) {
        log('Error playing raw audio via MethodChannel: $e',
            error: e, stackTrace: stack, name: 'NotifyHelper');
      }
    }

    // إذا لم يكن الملف متوفراً، جرّب الملف الآخر كـ fallback
    final String? fallbackPath = id == 0 ? audioPath : audioFajirPath;
    if (fallbackPath != null && File(fallbackPath).existsSync()) {
      try {
        log('Playing fallback audio: $fallbackPath', name: 'NotifyHelper');
        await state.adhanPlayer.setAudioSource(AudioSource.file(fallbackPath));
        await state.adhanPlayer.play();
        return;
      } catch (e, stack) {
        log('Error playing fallback audio: $e',
            error: e, stackTrace: stack, name: 'NotifyHelper');
      }
    }

    log('No audio file available to play', name: 'NotifyHelper');
  }
}
