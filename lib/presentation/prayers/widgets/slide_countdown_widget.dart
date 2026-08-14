part of '../prayers.dart';

class SlideCountdownWidget extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final Duration? duration;
  final bool? shouldShowHours;
  final bool? shouldShowMinutes;
  final bool? shouldShowSeconds;
  final double? fontHeight;
  SlideCountdownWidget({
    super.key,
    required this.fontSize,
    this.color,
    this.duration,
    this.shouldShowHours,
    this.shouldShowMinutes,
    this.shouldShowSeconds,
    this.fontHeight,
  });

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SlideCountdown(
        digitsNumber: [
          '0'.convertNumbers(Get.locale!.languageCode),
          '1'.convertNumbers(Get.locale!.languageCode),
          '2'.convertNumbers(Get.locale!.languageCode),
          '3'.convertNumbers(Get.locale!.languageCode),
          '4'.convertNumbers(Get.locale!.languageCode),
          '5'.convertNumbers(Get.locale!.languageCode),
          '6'.convertNumbers(Get.locale!.languageCode),
          '7'.convertNumbers(Get.locale!.languageCode),
          '8'.convertNumbers(Get.locale!.languageCode),
          '9'.convertNumbers(Get.locale!.languageCode)
        ],
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        showZeroValue: true,
        shouldShowHours: (_) => shouldShowHours ?? true,
        shouldShowMinutes: (_) => shouldShowMinutes ?? true,
        shouldShowSeconds: (_) => shouldShowSeconds ?? true,
        shouldShowDays: (_) => false,
        onDone: () => Get.forceAppUpdate(),
        slideDirection: SlideDirection.up,
        countUpAtDuration: true,
        duration: duration ??
            (adhanCtrl.state.prayerTimes == null
                ? const Duration(hours: 1)
                : adhanCtrl.getTimeLeftForNextPrayer),
        separatorStyle: TextStyle(
          color: color ?? Colors.white,
          fontSize: fontSize,
          fontFamily: 'cairo',
          fontWeight: FontWeight.bold,
          height: fontHeight ?? 1.5,
        ),
        style: TextStyle(
          color: color ?? Colors.white,
          locale: const Locale('ar'),
          fontFamily: 'cairo',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: fontHeight ?? 1.5,
        ),
      ),
    );
  }
}
