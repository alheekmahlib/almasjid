import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/bottom_sheet_extension.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';
import '/presentation/prayers/prayers.dart';
import '../../../core/utils/constants/svg_constants.dart';
import '../../../core/widgets/container_button_widget.dart';
import '../../home/home.dart';
import '../widgets/settings_list.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const Gap(16),
          ContainerButtonWidget(
            onPressed: () {
              if (HomeController.instance.floatyMenuController.isOpen) {
                HomeController.instance.floatyMenuController.close();
              }
              context.customBottomSheet(
                containerColor: context.theme.colorScheme.primaryContainer,
                textTitle: 'prayerSetting',
                child: const PrayerSettings(),
              );
            },
            width: Get.width,
            horizontalMargin: 16,
            useGradient: false,
            withShape: false,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            borderColor: Theme.of(context).canvasColor,
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Gap(8),
                customSvgWithColor(
                  SvgPath.svgHomeSettings,
                  height: 22,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                const Gap(16),
                Text(
                  'prayerSetting'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    color: context.theme.canvasColor.withValues(alpha: .6),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cairo',
                    height: 1.4,
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
    );
  }
}
