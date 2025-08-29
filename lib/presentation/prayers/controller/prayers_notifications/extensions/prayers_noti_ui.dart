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

  // void selectAdhanOnTap(int index) {
  //   if (isAdhanDownloadedByIndex(index).value) {
  //     final selectedAdhan =
  //         state.downloadedAdhanData.firstWhereOrNull((e) => e.index == index);
  //     if (selectedAdhan != null) {
  //       state.selectedAdhanPath.value = selectedAdhan.adhanPath!;
  //       state.selectedAdhanPathFajir.value =
  //           selectedAdhan.androidFajirFilePath!;
  //       state.box.write(ADHAN_PATH, state.selectedAdhanPath.value);
  //       state.box.write(ADHAN_PATH_FAJIR, state.selectedAdhanPathFajir.value);
  //     }
  //
  //     log('adhan: ${state.downloadedAdhanData[0].iosFilePath}');
  //     log('adhan selected: $index ${state.box.read(ADHAN_PATH)}');
  //     log('adhan fajir selected: $index ${state.box.read(ADHAN_PATH_FAJIR)}');
  //   } else {
  //     log('adhan is not downloaded');
  //     Get.defaultDialog(
  //       backgroundColor: Get.context!.theme.cardColor,
  //       titleStyle: TextStyle(color: Get.context!.theme.canvasColor),
  //       middleTextStyle: TextStyle(color: Get.context!.theme.canvasColor),
  //       title: 'Adhan isn\'t Downloaded',
  //       middleText: 'Please Download Adhan First',
  //     );
  //   }
  // }

  void switchAdhanOnTap(int index) {
    switch (index) {
      case 0:
        state.selectedAdhanPath.value = 'resource://raw/aqsa_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/aqsa_athan'
            : 'resource://raw/aqsa_athan_fajir';
        break;
      case 1:
        state.selectedAdhanPath.value = 'resource://raw/saqqaf_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/saqqaf_athan'
            : 'resource://raw/saqqaf_athan_fajir';
        break;
      case 2:
        state.selectedAdhanPath.value = 'resource://raw/sarihi_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/sarihi_athan'
            : 'resource://raw/sarihi_athan_fajir';
        break;
      default:
        state.selectedAdhanPath.value = 'resource://raw/aqsa_athan';
        state.selectedAdhanPathFajir.value = Platform.isIOS
            ? 'resource://raw/aqsa_athan'
            : 'resource://raw/aqsa_athan_fajir';
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

  void onNotificationActionReceived(ReceivedAction receivedAction) {
    // playAudio(receivedAction.id, receivedAction.title, receivedAction.body);
    Get.to(() => PrayerScreen(), transition: Transition.downToUp);
    if (DateTime.now().isBefore(
        receivedAction.displayedDate!.add(const Duration(minutes: 5)))) {
      Future.delayed(const Duration(seconds: 1)).then((_) => Get.bottomSheet(
              PrayerDetails(
                prayerName: receivedAction.title!,
                prayerSummary: receivedAction.summary!,
              ),
              isScrollControlled: true)
          .then((_) async => await state.adhanPlayer.stop()));
      playAudio(receivedAction.id, receivedAction.title);
    }
  }

  Future<void> playAudio(int? id, String? title) async {
    final String athanIndex =
        GetStorage('AdhanSounds').read(ADHAN_PATH_INDEX) ?? '0';
    String? audioPath =
        GetStorage('AdhanSounds').read<String?>('$athanIndex$ADHAN_PATH_AUDIO');
    String? audioFajirPath = GetStorage('AdhanSounds')
        .read<String?>('$athanIndex$ADHAN_PATH_FAJIR_AUDIO');

    log('Audio paths: audioPath=$audioPath, audioFajirPath=$audioFajirPath',
        name: 'NotifyHelper');

    if (audioPath != null && File(audioPath).existsSync()) {
      try {
        await state.adhanPlayer.setAudioSource(
          AudioSource.file(
            id == 0 ? audioFajirPath! : audioPath,
          ),
        );
        await state.adhanPlayer.play();
      } catch (e, stack) {
        log('Error playing audio: $e',
            error: e, stackTrace: stack, name: 'NotifyHelper');
      }
    } else {
      log('Audio file does not exist or path is null', name: 'NotifyHelper');
    }
  }
}
