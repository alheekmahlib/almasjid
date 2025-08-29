import 'package:almasjid/core/utils/constants/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/services/notifications_helper.dart';
import '../../../../core/utils/constants/lottie.dart';
import '../../../../core/utils/constants/lottie_constants.dart';
import '../../../../core/widgets/animated_drawing_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../whats_new/whats_new.dart';

class ActiveNotificationWidget extends StatelessWidget {
  ActiveNotificationWidget({super.key});

  final whatsNewCtrl = WhatsNewController.instance;

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
                // customLottie(LottieConstants.assetsLottieActivateNotification),
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
                        fontFamily: 'naskh',
                        fontSize: 20.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: context.theme.colorScheme.inversePrimary),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Gap(32),
                SizedBox(
                  height: 45,
                  child: CustomButton(
                    onPressed: () async {
                      NotifyHelper()
                          .requistPermissions()
                          .then((_) => whatsNewCtrl.navigationPage());
                      // NotifyHelper.initFlutterLocalNotifications();
                      NotifyHelper.initAwesomeNotifications();
                    },
                    svgPath: 'SvgPath.svgCheckMark',
                    svgColor: context.theme.colorScheme.surface,
                    titleColor: context.theme.canvasColor,
                    title: 'activation'.tr,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      customLottie(
                          LottieConstants.assetsLottieActivateNotification),
                      const Spacer(),
                      SizedBox(
                        height: 45,
                        child: CustomButton(
                          onPressed: () async {
                            NotifyHelper()
                                .requistPermissions()
                                .then((_) => whatsNewCtrl.navigationPage());
                            // NotifyHelper.initFlutterLocalNotifications();
                            NotifyHelper.initAwesomeNotifications();
                          },
                          svgPath: 'SvgPath.svgCheckMark',
                          svgColor: context.theme.colorScheme.surface,
                          titleColor: context.theme.canvasColor,
                          title: 'activation'.tr,
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
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      'notificationNote'.tr,
                      style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 20.sp,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.inversePrimary),
                      textAlign: TextAlign.center,
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
