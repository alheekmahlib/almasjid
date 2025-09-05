import 'package:almasjid/core/utils/constants/extensions/bottom_sheet_extension.dart';
import 'package:almasjid/core/utils/constants/extensions/svg_extensions.dart';
import 'package:almasjid/presentation/prayers/prayers.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

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
            height: Get.height * .89,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32.0),
                bottomRight: Radius.circular(32.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppBarWidget(),
                Flexible(
                  child: SingleChildScrollView(
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
                            textTitle: 'prayerSettings',
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
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: .6),
                              ),
                              const Gap(16),
                              Text(
                                'prayerSettings'.tr,
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
                        const Gap(16),
                        SettingsList(),
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
