import 'package:almasjid/core/utils/constants/extensions/bottom_sheet_extension.dart';
import 'package:almasjid/core/utils/constants/svg_constants.dart';
import 'package:almasjid/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';

import '../../../core/widgets/reactive_number_text.dart';
import '../prayers.dart';

class PrayerNowWidget extends StatelessWidget {
  PrayerNowWidget({super.key});

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          GetBuilder<AdhanController>(
            id: 'update_progress',
            builder: (adhanCtrl) {
              int currentPrayer = adhanCtrl.getCurrentPrayerByDateTime();
              return AnimatedRadialGauge(
                /// The animation duration.
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,

                /// Define the radius.
                /// If you omit this value, the parent size will be used, if possible.
                radius: Get.width * .48,

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
                  degrees: 200,

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
                    color:
                        context.theme.colorScheme.surface.withValues(alpha: .9),
                    placement: GaugeProgressPlacement.inside,
                  ),

                  /// Define axis segments (optional).
                  segments: adhanCtrl.getPrayerGaugeSegments,
                ),
                builder: (context, child, value) => Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Icon(
                      adhanCtrl.prayerNameList[currentPrayer]['icon'],
                      size: 180,
                      color: currentPrayer == 1 ||
                              currentPrayer == 2 ||
                              currentPrayer == 3 ||
                              currentPrayer == 4
                          ? const Color.fromARGB(255, 242, 181, 15)
                              .withValues(alpha: .1)
                          : context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .05),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${adhanCtrl.prayerNameList[currentPrayer]['title']}'
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
                        ),
                        ReactiveNumberText(
                          text: adhanCtrl.prayerNameList[currentPrayer]['time'],
                          style: TextStyle(
                            fontFamily: 'cairo',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.inversePrimary,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.surface
                                .withValues(alpha: .4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SlideCountdownWidget(
                              fontSize: 38,
                              color: context.theme.colorScheme.inversePrimary,
                              duration: adhanCtrl
                                  .getDurationLeftForPrayerByIndex(
                                      currentPrayer)
                                  .value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: 45,
            child: CustomButton(
              onPressed: () => context.customBottomSheet(
                containerColor: context.theme.colorScheme.primaryContainer,
                textTitle: 'sharePrayerTime',
                child: ShareOptionsWidget(),
              ),
              width: 45,
              iconSize: 28,
              isCustomSvgColor: true,
              svgPath: SvgPath.svgShareShare,
              svgColor: context.theme.colorScheme.surface,
              borderColor:
                  context.theme.colorScheme.surface.withValues(alpha: .3),
            ),
          ),
        ],
      ),
    );
  }
}
