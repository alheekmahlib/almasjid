part of '../../prayers.dart';

class PrayersNotificationsCtrl extends GetxController {
  static PrayersNotificationsCtrl get instance =>
      GetInstance().putOrFind(() => PrayersNotificationsCtrl());

  NotiState state = NotiState();

  @override
  Future<void> onInit() async {
    getSharedVariables;
    state.adhanData = loadAdhanData();
    log('downloadedAdhanData.value: ${state.downloadedAdhanData.length}');
    super.onInit();
  }

  String getFajirAdhan(String title) => title == 'Fajir'
      ? state.selectedAdhanPathFajir.value
      : state.selectedAdhanPath.value;

  void get getSharedVariables {
    String fajirPath = Platform.isIOS
        ? 'resource://raw/aqsa_athan'
        : 'resource://raw/aqsa_fajir_athan';
    state.selectedAdhanPath.value =
        state.box.read(ADHAN_PATH) ?? 'resource://raw/aqsa_athan';
    state.selectedAdhanPathFajir.value =
        state.box.read(ADHAN_PATH_FAJIR) ?? fajirPath;
    final downloadedSoundData = state.box.read('Downloaded_Adhan_Sounds_Data');
    log('Retrieved Data: $downloadedSoundData');

    if (null != downloadedSoundData) {
      state.downloadedAdhanData.value =
          (jsonDecode(downloadedSoundData) as List<dynamic>?)?.map((e) {
                return AdhanData.fromJson(e as Map<String, dynamic>);
              }).toList() ??
              [];
      log('Parsed Data Length: ${state.downloadedAdhanData.length}');
    }
  }

  Future<List<AdhanData>> loadAdhanData() async {
    log('Loading Adhan Data...', name: 'PrayersNotificationsCtrl');
    final jsonString =
        await rootBundle.loadString('assets/json/adhanSounds.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    // state.adhanList.add(AdhanData.fromJson(data));
    state.adhanList = jsonData.map((data) => AdhanData.fromJson(data)).toList();
    if (!Platform.isMacOS && !Platform.isAndroid) {
      isAdhanDownloadedByIndex(0).value
          ? null
          : adhanDownload(state.adhanList[0]);
    }
    return state.adhanList;
  }

  Future<void> adhanDownload(AdhanData adhanData) async {
    if (state.isDownloading.value) return;
    state.downloadIndex.value = adhanData.index;
    state.isDownloading.toggle();
    state.progress.value = 0;
    await AudioDownloader()
        .downloadAndUnzipAdhan(adhanData, onReceiveProgress: onReceiveProgress)
        .then((d) {
      state.downloadedAdhanData.add(d);
      final downloadedAdanSoundsAsMap =
          jsonEncode(state.downloadedAdhanData.map((e) => e.toJson()).toList());
      state.box
          .write('Downloaded_Adhan_Sounds_Data', downloadedAdanSoundsAsMap);
      // log('Saved Data: $downloadedAdanSoundsAsMap');
      if (state.downloadedAdhanData.length == 1) {
        switchAdhanOnTap(0);
      }
    });

    state.isDownloading.toggle();
  }
}
