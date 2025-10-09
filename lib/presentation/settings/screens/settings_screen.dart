import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/bottom_sheet_extension.dart';
import '/core/utils/constants/extensions/extensions.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';
import '/presentation/prayers/prayers.dart';
import '../../../core/utils/constants/svg_constants.dart';
import '../../../core/widgets/animated_drawing_widget.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/container_button_widget.dart';
import '../widgets/settings_list.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.theme.colorScheme.surface,
        body: SafeArea(
          child: Container(
            height: Get.height,
            color: context.theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppBarWidget(),
                Flexible(
                  child: context.customOrientation(
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const Gap(32),
                          AnimatedDrawingWidget(
                              opacity: 1,
                              width: Get.width * .6,
                              height: Get.width * .3),
                          const Gap(32),
                          ContainerButtonWidget(
                            onPressed: () => context.customBottomSheet(
                              containerColor:
                                  context.theme.colorScheme.primaryContainer,
                              textTitle: 'prayerSetting',
                              child: const PrayerSettings(),
                            ),
                            width: Get.width,
                            horizontalMargin: 32,
                            useGradient: false,
                            withShape: false,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            borderColor: Theme.of(context).highlightColor,
                            height: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Gap(8),
                                customSvgWithColor(
                                  SvgPath.svgHomeSettings,
                                  height: 22,
                                  color: context
                                      .theme.colorScheme.inversePrimary
                                      .withValues(alpha: .6),
                                ),
                                const Gap(16),
                                Text(
                                  'prayerSetting'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: context
                                        .theme.colorScheme.inversePrimary
                                        .withValues(alpha: .6),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'cairo',
                                    height: 1.7,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // const Gap(8),
                          SettingsList(),
                          const Gap(80),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const Gap(32),
                                ContainerButtonWidget(
                                  onPressed: () => context.customBottomSheet(
                                    containerColor: context
                                        .theme.colorScheme.primaryContainer,
                                    textTitle: 'prayerSetting',
                                    child: const PrayerSettings(),
                                  ),
                                  width: Get.width,
                                  horizontalMargin: 32,
                                  useGradient: false,
                                  withShape: false,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  borderColor: Theme.of(context).highlightColor,
                                  height: 55,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(8),
                                      customSvgWithColor(
                                        SvgPath.svgHomeSettings,
                                        height: 24,
                                        color: context
                                            .theme.colorScheme.inversePrimary
                                            .withValues(alpha: .6),
                                      ),
                                      const Gap(16),
                                      Text(
                                        'prayerSetting'.tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: context
                                              .theme.colorScheme.inversePrimary
                                              .withValues(alpha: .6),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'cairo',
                                          height: 1.7,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                // const Gap(8),
                                SettingsList(),
                                const Gap(80),
                              ],
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: AnimatedDrawingWidget(
                              opacity: 1,
                              width: context.customOrientation(
                                  Get.width * .6, Get.width * .4),
                              height: context.customOrientation(
                                  Get.width * .3, Get.height * .23)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
