import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/extensions.dart';
import '/core/widgets/custom_button.dart';
import '/presentation/controllers/general/general_controller.dart';
import '../../../../core/utils/constants/lottie.dart';
import '../../../../core/utils/constants/lottie_constants.dart';
import '../../../../core/widgets/container_button_widget.dart';
import '../../splash.dart';

class ActiveLocationWidget extends StatelessWidget {
  ActiveLocationWidget({super.key});

  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32.0),
        child: context.customOrientation(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(16),
                customLottieWithColor(LottieConstants.assetsLottieLocation,
                    width: 250.0, color: context.theme.colorScheme.surface),
                const Spacer(),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'locationNote'.tr,
                    style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 16.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: context.theme.canvasColor),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Gap(32),
                Obx(() => ContainerButtonWidget(
                      onPressed: generalCtrl.state.isLocationLoading.value
                          ? null
                          : () async => await generalCtrl.initLocation().then(
                              (_) => SplashScreenController
                                  .instance.state.customWidgetIndex.value = 2),
                      height: 45,
                      width: Get.width,
                      horizontalMargin: 0,
                      useGradient: false,
                      withShape: false,
                      isLoading: generalCtrl.state.isLocationLoading.value,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      borderColor: context.theme.colorScheme.surface,
                      title: 'locate'.tr,
                    )),
                const Gap(8),
                ContainerButtonWidget(
                  onPressed: () => generalCtrl.cancelLocation(),
                  height: 45,
                  width: Get.width,
                  horizontalMargin: 0,
                  useGradient: false,
                  withShape: false,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  borderColor: Colors.red,
                  title: 'cancel'.tr,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      customLottieWithColor(
                          LottieConstants.assetsLottieLocation,
                          width: 250.0,
                          color: context.theme.colorScheme.surface),
                      const Spacer(),
                      SizedBox(
                        height: 45,
                        child: CustomButton(
                          onPressed: () async => await generalCtrl
                              .initLocation()
                              .then((_) => SplashScreenController
                                  .instance.state.customWidgetIndex.value = 2),
                          svgPath: 'SvgPath.svgCheckMark',
                          svgColor: context.theme.colorScheme.surface,
                          titleColor: context.theme.canvasColor,
                          title: 'locate'.tr,
                        ),
                      ),
                      const Gap(8),
                      SizedBox(
                        height: 45,
                        child: CustomButton(
                          onPressed: () => generalCtrl.cancelLocation(),
                          svgPath: 'SvgPath.svgClose',
                          svgColor: context.theme.colorScheme.surface,
                          titleColor: context.theme.canvasColor,
                          title: 'cancel'.tr,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'locationNote'.tr,
                      style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 18.sp,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.inversePrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )));
  }
}
