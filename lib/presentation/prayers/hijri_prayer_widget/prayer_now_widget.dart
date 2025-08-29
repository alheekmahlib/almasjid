import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../core/widgets/reactive_number_text.dart';
import '../prayers.dart';

class PrayerNowWidget extends StatelessWidget {
  PrayerNowWidget({super.key});

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    final List<IconData> stepIcons = [
      SolarIconsBold.moonFog,
      SolarIconsBold.sun,
      SolarIconsBold.sun2,
      SolarIconsBold.sunset,
      SolarIconsBold.moon,
      SolarIconsBold.moon,
      SolarIconsBold.moon,
      SolarIconsBold.moon,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Obx(
        () => AnimatedRadialGauge(
          /// The animation duration.
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,

          /// Define the radius.
          /// If you omit this value, the parent size will be used, if possible.
          radius: Get.width * .45,

          /// Gauge value.
          value: adhanCtrl.getPrayerDayProgress.value,

          /// Optionally, you can configure your gauge, providing additional
          /// styles and transformers.
          axis: GaugeAxis(
            /// Provide the [min] and [max] value for the [value] argument.
            min: 0,
            max: 100,

            /// Render the gauge as a 180-degree arc.
            degrees: 180,

            /// Set the background color and axis thickness.
            style: GaugeAxisStyle(
              thickness: 30,
              background: context.theme.colorScheme.primaryContainer,
              segmentSpacing: 10,
              cornerRadius: const Radius.circular(8.0),
            ),

            /// Define the pointer that will indicate the progress (optional).
            // pointer: GaugePointer.needle(
            //   width: 10,
            //   height: 10,
            //   borderRadius: 8,
            //   color: Color(0xFF193663),
            // ),

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
                stepIcons[adhanCtrl.getNextPrayerByDateTime().value],
                size: 100,
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
                      fontSize: 24,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.inversePrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  SlideCountdownWidget(
                    fontSize: 30,
                    color: context.theme.colorScheme.inversePrimary,
                    duration: adhanCtrl
                        .getDurationLeftForPrayerByIndex(
                            adhanCtrl.getCurrentPrayerByDateTime())
                        .value,
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
