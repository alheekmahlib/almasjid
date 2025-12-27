import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/extensions.dart';
import '../../../../core/utils/constants/lottie.dart';
import '../../../../core/utils/constants/lottie_constants.dart';
import '../../../../core/widgets/animated_drawing_widget.dart';
import '../../../../core/widgets/container_button_widget.dart';
import '../../splash.dart';

class ActiveNotificationWidget extends StatelessWidget {
  ActiveNotificationWidget({super.key});

  final splashCtrl = SplashScreenController.instance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: AnimatedDrawingWidget(
              opacity: .09, width: Get.width, height: Get.width * .6),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: context.customOrientation(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(16),
                customLottie(LottieConstants.assetsLottieNotification),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    'notificationNote'.tr,
                    style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 12.sp.clamp(12, 22),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: context.theme.canvasColor),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Gap(32),
                Obx(() => ContainerButtonWidget(
                      onPressed: splashCtrl.state.isNotificationLoading.value
                          ? null
                          : () async {
                              await splashCtrl.activateNotifications();
                            },
                      height: 45,
                      width: Get.width,
                      horizontalMargin: 0,
                      useGradient: false,
                      withShape: false,
                      isLoading: splashCtrl.state.isNotificationLoading.value,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      borderColor: context.theme.colorScheme.surface,
                      title: 'activation'.tr,
                    )),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      customLottie(LottieConstants.assetsLottieNotification),
                      const Spacer(),
                      Obx(() => ContainerButtonWidget(
                            onPressed: splashCtrl
                                    .state.isNotificationLoading.value
                                ? null
                                : () async {
                                    await splashCtrl.activateNotifications();
                                  },
                            height: 45,
                            width: Get.width,
                            horizontalMargin: 0,
                            useGradient: false,
                            withShape: false,
                            isLoading:
                                splashCtrl.state.isNotificationLoading.value,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            borderColor: context.theme.colorScheme.surface,
                            title: 'activation'.tr,
                          )),
                    ],
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'notificationNote'.tr,
                      style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 8.sp.clamp(8, 18),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: context.theme.canvasColor),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
