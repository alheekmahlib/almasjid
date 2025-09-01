import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';

import '../../../core/widgets/reactive_number_text.dart';
import '../prayers.dart';

class PrayerNowWidget extends StatefulWidget {
  const PrayerNowWidget({super.key});

  @override
  State<PrayerNowWidget> createState() => _PrayerNowWidgetState();
}

class _PrayerNowWidgetState extends State<PrayerNowWidget> {
  final adhanCtrl = AdhanController.instance;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // تحديث قيمة الـ gauge كل دقيقة
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // سيؤدي إلى إعادة بناء الـ widget وتحديث قيم الـ gauge
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(
        () => AnimatedRadialGauge(
          /// The animation duration.
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,

          /// Define the radius.
          /// If you omit this value, the parent size will be used, if possible.
          radius: Get.width * .55,

          /// Gauge value.
          value: adhanCtrl.getPrayerDayProgress.value,

          onEnd: () => Get.forceAppUpdate(),

          /// Optionally, you can configure your gauge, providing additional
          /// styles and transformers.
          axis: GaugeAxis(
            /// Provide the [min] and [max] value for the [value] argument.
            min: 0,
            max: 100,

            /// Render the gauge as a 180-degree arc.
            degrees: 280,

            /// Set the background color and axis thickness.
            style: GaugeAxisStyle(
              thickness: 35,
              background: context.theme.colorScheme.primaryContainer,
              segmentSpacing: 10,
              cornerRadius: const Radius.circular(8.0),
            ),

            pointer: GaugePointer.circle(
              radius: 8,
              color: context.theme.canvasColor,
            ),

            /// Define the progress bar (optional).
            progressBar: GaugeProgressBar.basic(
              color: context.theme.colorScheme.surface.withValues(alpha: .9),
              placement: GaugeProgressPlacement.inside,
            ),

            /// Define axis segments (optional).
            segments: adhanCtrl.getPrayerGaugeSegments,
          ),
          builder: (context, child, value) => Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                adhanCtrl.prayerNameList[adhanCtrl.getCurrentPrayerByDateTime()]
                    ['icon'],
                size: 200,
                color: context.theme.colorScheme.inversePrimary
                    .withValues(alpha: .1),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${adhanCtrl.prayerNameList[adhanCtrl.getCurrentPrayerByDateTime()]['title']}'
                        .tr,
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.inversePrimary,
                      height: .2,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  ReactiveNumberText(
                    text: adhanCtrl.prayerNameList[
                        adhanCtrl.getCurrentPrayerByDateTime()]['time'],
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.inversePrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SlideCountdownWidget(
                      fontSize: 38,
                      color: context.theme.colorScheme.inversePrimary,
                      duration: adhanCtrl
                          .getDurationLeftForPrayerByIndex(
                              adhanCtrl.getCurrentPrayerByDateTime())
                          .value,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
