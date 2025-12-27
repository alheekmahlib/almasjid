import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/constants/extensions/extensions.dart';
import '../../../../core/utils/constants/svg_constants.dart';
import '../../../../core/widgets/animated_drawing_widget.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../controller/our_apps_controller.dart';
import 'widgets/our_apps_build.dart';

class OurApps extends StatelessWidget {
  const OurApps({super.key});

  @override
  Widget build(BuildContext context) {
    sl<OurAppsController>().fetchApps();
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
          color: context.theme.colorScheme.primaryContainer,
          child: Column(
            children: [
              const AppBarWidget(withBackButton: true),
              context.customOrientation(
                Flexible(
                  child: Column(
                    children: [
                      const Gap(64),
                      AnimatedDrawingWidget(
                          opacity: 1,
                          width: Get.width * .6,
                          height: Get.width * .3),
                      const Gap(64),
                      OurAppsBuild(),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: customSvgWithColor(SvgPath.svgAlheekmahLogo,
                            width: 80.0,
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDrawingWidget(
                                opacity: 1,
                                width: Get.width * .4,
                                height: Get.width * .2),
                            Padding(
                              padding: context.customOrientation(
                                  const EdgeInsets.symmetric(vertical: 40.0).r,
                                  const EdgeInsets.symmetric(vertical: 32.0).r),
                              child: customSvgWithColor(
                                  SvgPath.svgAlheekmahLogo,
                                  width: 80.0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          primary: false,
                          child: OurAppsBuild(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
