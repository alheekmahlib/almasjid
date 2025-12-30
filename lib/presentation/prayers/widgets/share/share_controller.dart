part of '../../prayers.dart';

class ShareController extends GetxController {
  static ShareController get instance => Get.isRegistered<ShareController>()
      ? Get.find<ShareController>()
      : Get.put(ShareController());

  final screenshotController = ScreenshotController();
  final RxBool isSaving = false.obs;
  final RxBool isPrinting = false.obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  Uint8List? imageBytesScreen;

  AdhanController get adhan => AdhanController.instance;

  // Build display strings using available getters/helpers
  String get nextPrayerName => adhan.state.prayerTimes == null
      ? ''
      : adhan.getNextPrayerDetail.prayerName;
  DateTime? get nextPrayerTime => adhan.state.prayerTimes == null
      ? null
      : adhan.getNextPrayerDetail.prayerTime;

  String get formattedNextPrayerTime =>
      DateFormatter.formatPrayerTime(nextPrayerTime);

  // Time left as mm:ss or h:mm
  String get timeLeftLabel {
    if (adhan.state.prayerTimes == null) return '--';
    final diff = adhan.getTimeLeftForNextPrayer;
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    if (diff == Duration.zero) return '--';
    if (hours <= 0) {
      return '${minutes.toString().padLeft(2, '0')} ${'min'.tr}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} ${'h'.tr}';
  }

  // Hijri date text
  String get hijriDateText {
    final h = EventController.instance.hijriNow;
    return '${'${h.hDay}'.convertNumbers()} ${h.getLongMonthName().tr} ${'${h.hYear}'.convertNumbers()}';
  }

  // City, Country
  // String get placeText {
  //   final city = Location.instance.city;
  //   final country = Location.instance.country.isNotEmpty
  //       ? Location.instance.country
  //       : adhan.state.selectedCountry.value;
  //   if (city.isNotEmpty) return '$city,\n$country';
  //   return country;
  // }

  Future<void> createAndShowVerseImage() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 9,
        delay: const Duration(milliseconds: 100),
      );
      if (imageBytes != null) {
        imageBytesScreen = imageBytes;
        update();
      }
    } catch (e) {
      log('Error capturing verse image: $e');
    }
  }

  Future<void> shareAsImage() async {
    try {
      isSaving.value = true;

      if (imageBytesScreen != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
                '${directory.path}/prayer_share_${DateTime.now().millisecondsSinceEpoch}.png')
            .create();
        await imagePath.writeAsBytes(imageBytesScreen!);

        final shareText = '${'sharePrayerTime'.tr}\n'
            '${'appName'.tr}';

        final params = ShareParams(
          text: shareText,
          files: [XFile(imagePath.path, name: 'prayer_times.png')],
          subject: 'Prayer Times - Al-Masjid App',
        );

        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          log('Image shared successfully!');
        } else if (result.status == ShareResultStatus.dismissed) {
          log('Share dismissed by user');
        } else {
          log('Share unavailable or failed');
        }
      }
    } catch (e) {
      log('Error sharing image: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
