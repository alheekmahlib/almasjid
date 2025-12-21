import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '/core/utils/constants/extensions/extensions.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';
import '/core/widgets/local_notification/controller/local_notifications_controller.dart';
import '../../../presentation/controllers/general/general_controller.dart';
import '../../utils/constants/svg_constants.dart';
import 'widgets/notification_icon_widget.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});
  final notiCtrl = LocalNotificationsController.instance;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalNotificationsController>(
      builder: (notiCtrl) => notiCtrl.postsList.isEmpty
          ? Center(
              child: Column(
                children: [
                  const Gap(64),
                  customSvgWithCustomColor(SvgPath.svgNotifications, width: 80),
                  const Gap(32),
                  Text(
                    'noNotifications'.tr,
                    style: TextStyle(
                      color: context.theme.canvasColor,
                      fontFamily: 'cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: NotificationIconWidget(
                    iconHeight: 60,
                    padding: 8.0,
                  ),
                ),
                const Gap(16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: notiCtrl.postsList.length,
                  itemBuilder: (context, index) {
                    var reversedList = notiCtrl.postsList.reversed.toList();
                    var noti = reversedList[index];
                    return noti.appName == 'zad'
                        ? ExpansionTile(
                            backgroundColor: context.theme.colorScheme.primary
                                .withValues(alpha: .2),
                            collapsedBackgroundColor: context
                                .theme.colorScheme.primary
                                .withValues(alpha: .2),
                            collapsedIconColor: context.theme.canvasColor,
                            iconColor: context.theme.canvasColor,
                            childrenPadding: const EdgeInsets.all(16.0),
                            onExpansionChanged: (_) =>
                                notiCtrl.markNotificationAsRead(noti.id),
                            title: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: noti.opened
                                    ? context.theme.canvasColor
                                        .withValues(alpha: .1)
                                    : context.theme.colorScheme.surface
                                        .withValues(alpha: .15),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  width: 1,
                                  color: noti.opened
                                      ? Colors.transparent
                                      : context.theme.colorScheme.surface,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    noti.title,
                                    style: TextStyle(
                                      color: context.theme.canvasColor,
                                      fontFamily: 'cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  customSvgWithColor(
                                    SvgPath.svgNotifications,
                                    height: 25,
                                    color: noti.opened
                                        ? context.theme.canvasColor
                                        : context.theme.colorScheme.surface,
                                  ),
                                ],
                              ),
                            ),
                            children: <Widget>[
                              Text(
                                noti.title,
                                style: TextStyle(
                                  color: context.theme.canvasColor,
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: GeneralController
                                      .instance.state.fontSizeArabic.value,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              context.hDivider(width: Get.width),
                              const Gap(16),
                              Text(
                                noti.body,
                                style: TextStyle(
                                  color: context.theme.canvasColor,
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: GeneralController
                                          .instance.state.fontSizeArabic.value -
                                      2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Gap(32),
                              noti.isLottie && noti.lottie.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: context.theme.canvasColor
                                            .withValues(alpha: .15),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border.all(
                                          width: 1,
                                          color:
                                              context.theme.colorScheme.surface,
                                        ),
                                      ),
                                      child: Lottie.network(
                                        noti.lottie,
                                        width: Get.width * .5,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const CircularProgressIndicator
                                                    .adaptive(),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              const Gap(32),
                              noti.isImage && noti.image.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: context.theme.canvasColor
                                            .withValues(alpha: .15),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border.all(
                                          width: 1,
                                          color:
                                              context.theme.colorScheme.surface,
                                        ),
                                      ),
                                      child: Image.network(
                                        noti.image,
                                        width: Get.width * .5,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const CircularProgressIndicator
                                                    .adaptive(),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              const Gap(8),
                              context.hDivider(width: Get.width),
                              const Gap(16),
                            ],
                          )
                        : const SizedBox.shrink();
                  },
                )
              ],
            ),
    );
  }
}
