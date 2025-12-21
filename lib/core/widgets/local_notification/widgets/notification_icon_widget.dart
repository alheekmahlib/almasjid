import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/convert_number_extension.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';
import '/core/widgets/local_notification/controller/local_notifications_controller.dart';
import '../../../utils/constants/svg_constants.dart';
import '../../reactive_number_text.dart';

class NotificationIconWidget extends StatelessWidget {
  final double iconHeight;
  final Color? iconColor;
  final double? padding;
  final double? margin;
  const NotificationIconWidget(
      {super.key,
      required this.iconHeight,
      required this.padding,
      this.margin,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GetX<LocalNotificationsController>(builder: (notiCtrl) {
      return Center(
        child: badges.Badge(
          showBadge: notiCtrl.unreadCount > 0,
          position: badges.BadgePosition.bottomEnd(bottom: -25, end: -18),
          badgeStyle: const badges.BadgeStyle(
            shape: badges.BadgeShape.square,
            badgeColor: Colors.transparent,
          ),
          badgeContent: ReactiveNumberText(
            text: notiCtrl.unreadCount.toString().convertNumbers(),
            style: TextStyle(
                fontFamily: 'cairo',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: context.theme.canvasColor),
          ),
          child: customSvgWithCustomColor(SvgPath.svgNotifications,
              height: iconHeight,
              width: iconHeight,
              color: iconColor ??
                  Theme.of(context).colorScheme.secondaryContainer),
        ),
      );
    });
  }
}
