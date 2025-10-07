part of '../prayers.dart';

class SlideCountdownWidget extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final Duration? duration;
  SlideCountdownWidget(
      {super.key, required this.fontSize, this.color, this.duration});

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SlideCountdown(
        digitsNumber: [
          '0'.convertNumbers(),
          '1'.convertNumbers(),
          '2'.convertNumbers(),
          '3'.convertNumbers(),
          '4'.convertNumbers(),
          '5'.convertNumbers(),
          '6'.convertNumbers(),
          '7'.convertNumbers(),
          '8'.convertNumbers(),
          '9'.convertNumbers()
        ],
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        showZeroValue: true,
        shouldShowDays: (_) => false,
        onDone: () => Get.forceAppUpdate(),
        slideDirection: SlideDirection.up,
        countUpAtDuration: true,
        duration: duration ?? adhanCtrl.getTimeLeftForNextPrayer,
        separatorStyle: TextStyle(
          color: color ?? Colors.white,
          fontSize: fontSize,
          fontFamily: 'cairo',
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        style: TextStyle(
          color: color ?? Colors.white,
          locale: const Locale('ar'),
          fontFamily: 'cairo',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
    );
  }
}
