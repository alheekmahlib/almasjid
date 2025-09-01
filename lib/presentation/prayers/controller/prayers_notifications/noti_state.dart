part of '../../prayers.dart';

class NotiState {
  final box = GetStorage('AdhanSounds');

  RxString progressString = '0'.obs;
  RxDouble progress = 0.0.obs;
  RxBool isDownloading = false.obs;
  RxInt downloadIndex = 0.obs;
  late var cancelToken = CancelToken();
  late Future<List<AdhanData>> adhanData;
  List<AdhanData> adhanList = [];
  // Map<String,dynamic> downloaded
  RxList<AdhanData> downloadedAdhanData = RxList();
  RxString selectedAdhanPath = RxString('');
  RxString selectedAdhanPathFajir = RxString('');
  RxString notificationChannelKey = RxString('notification');
  RxString tempAdhanPath = RxString('');
  RxString tempAdhanPathFajir = RxString('');
  String? notificationSoundType;
  final audioPlayer = AudioPlayer();
  var currentlyPlayingIndex = Rxn<int>();
  AudioPlayer adhanPlayer = AudioPlayer();
}
