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
    state.adhanList = await AdhanSoundsCatalog.load();
    _deriveSelectedIndexIfNeeded();
    unawaited(_migrateSelectedAdhanIfNeeded());
    return state.adhanList;
  }

  /// اشتقاق فهرس المقرئ المختار من المسار المخزن (توافق مع البيانات القديمة).
  void _deriveSelectedIndexIfNeeded() {
    if (state.box.read<String?>(ADHAN_SELECTED_INDEX) != null) return;
    final path =
        state.box.read<String?>(ADHAN_PATH) ?? 'resource://raw/aqsa_athan';
    final entry = state.adhanList.firstWhereOrNull(
      (e) =>
          e.adhanLocalPath == path ||
          (e.adhanFileName.isNotEmpty && path.contains(e.adhanFileName)),
    );
    state.box.write(ADHAN_SELECTED_INDEX, (entry?.index ?? 0).toString());
    log(
      'Derived selected adhan index: ${entry?.index ?? 0}',
      name: 'PrayersNotificationsCtrl',
    );
  }

  /// مقرئ مختار غير محمّل (بعد تحويل غير الافتراضي إلى تحميل عند الطلب)
  /// → تحميل صامت في الخلفية؛ حتى اكتماله يعود التشغيل للأقصى الافتراضي.
  Future<void> _migrateSelectedAdhanIfNeeded() async {
    if (Platform.isMacOS) return;
    try {
      final box = state.box;
      final path = box.read<String?>(ADHAN_PATH) ?? '';
      final selectedIndex =
          int.tryParse(box.read<String?>(ADHAN_SELECTED_INDEX) ?? '') ?? 0;
      final alreadyHaveFile =
          AudioDownloader.downloadedAudioPathFor(selectedIndex) != null;

      final needsDownload =
          !alreadyHaveFile &&
          path.startsWith('resource://raw/') &&
          !path.contains('aqsa');
      if (!needsDownload) return;

      final entry = state.adhanList.firstWhereOrNull(
        (e) => e.index == selectedIndex,
      );
      if (entry != null && !isAdhanDownloadedByIndex(selectedIndex).value) {
        log(
          'Migrating selected adhan ${entry.adhanName}: downloading silently',
          name: 'PrayersNotificationsCtrl',
        );
        await adhanDownload(entry);
      }
    } catch (e) {
      log('Adhan migration failed: $e', name: 'PrayersNotificationsCtrl');
    }
  }

  Future<void> adhanDownload(AdhanData adhanData) async {
    if (state.isDownloading.value) return;
    state.downloadIndex.value = adhanData.index;
    state.isDownloading.toggle();
    state.progress.value = 0;
    await AudioDownloader()
        .downloadAndUnzipAdhan(adhanData, onReceiveProgress: onReceiveProgress)
        .then((d) {
          final valid = d.adhanPath != null && File(d.adhanPath!).existsSync();
          if (!valid) {
            log(
              'Adhan download failed: ${adhanData.adhanName}',
              name: 'PrayersNotificationsCtrl',
            );
            return;
          }
          state.downloadedAdhanData.add(d);
          final downloadedAdanSoundsAsMap = jsonEncode(
            state.downloadedAdhanData.map((e) => e.toJson()).toList(),
          );
          state.box.write(
            'Downloaded_Adhan_Sounds_Data',
            downloadedAdanSoundsAsMap,
          );

          // تحديث مسارات الاختيار إن كان المقرئ المحمّل هو المختار حالياً.
          if (state.box.read<String?>(ADHAN_SELECTED_INDEX) ==
              d.index.toString()) {
            switchAdhanOnTap(d.index);
          }
        });

    state.isDownloading.toggle();
  }
}
