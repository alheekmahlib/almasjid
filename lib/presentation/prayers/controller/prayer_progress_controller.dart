part of '../prayers.dart';

class PrayerProgressController extends GetxController {
  static PrayerProgressController get instance =>
      GetInstance().putOrFind(() => PrayerProgressController());

  final adhanCtrl = AdhanController.instance;

  RxDouble progress = 0.0.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   Future.delayed(const Duration(seconds: 3)).then((_) => updateProgress());
  // }

  void updateProgress() {
    final now = DateTime.now();
    final fajr = adhanCtrl.state.prayerTimes!.fajr;
    final middle = adhanCtrl.state.sunnahTimes!.middleOfTheNight;

    DateTime startTime =
        DateTime(now.year, now.month, now.day, fajr.hour - 3, fajr.minute);
    DateTime endTime = DateTime(now.year, now.month, now.day, middle.hour,
        middle.minute, middle.second);

    final totalDuration = endTime.difference(startTime).inSeconds;
    final elapsedDuration = now.difference(startTime).inSeconds;

    double calculatedProgress = (elapsedDuration / totalDuration);

    // Clamp the progress value between 0 and 100
    progress.value = calculatedProgress;

    log('Progress: ${progress.value}%');

    // Update progress every minute
    Future.delayed(const Duration(minutes: 1), updateProgress);
  }
}
