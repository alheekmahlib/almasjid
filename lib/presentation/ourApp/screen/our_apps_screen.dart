import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/constants/extensions/extensions.dart';
import '../../../../core/utils/constants/svg_constants.dart';
import '../../../../core/widgets/animated_drawing_widget.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../controller/our_apps_controller.dart';
import '../widgets/our_apps_build.dart';

class OurApps extends StatelessWidget {
  const OurApps({super.key});

  @override
  Widget build(BuildContext context) {
    // إنشاء المتحكم عبر حاوية DI يطلق fetchApps من onInit
    sl<OurAppsController>();
    return Material(
      color: context.theme.colorScheme.primaryContainer,
      child: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(withBackButton: true),
            context.customOrientation(
              Expanded(
                child: Column(
                  children: [
                    const Gap(16),
                    AnimatedDrawingWidget(
                      opacity: 1,
                      width: Get.width * .6,
                      height: Get.width * .3,
                    ),
                    const Gap(32),
                    const Expanded(child: OurAppsBuild()),
                    customSvgWithColor(
                      SvgPath.svgAlheekmahLogo,
                      width: 40.0,
                      color: context.theme.colorScheme.inversePrimary,
                    ),
                    const Gap(32),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          const Spacer(),
                          AnimatedDrawingWidget(
                            opacity: 1,
                            width: Get.width * .4,
                            height: Get.width * .2,
                          ),
                          const Spacer(),
                          customSvgWithColor(
                            SvgPath.svgAlheekmahLogo,
                            width: 60.0,
                            color: context.theme.colorScheme.inversePrimary,
                          ),
                          const Gap(32),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32.0),
                        decoration: BoxDecoration(
                          color: context.theme.canvasColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: const OurAppsBuild(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
