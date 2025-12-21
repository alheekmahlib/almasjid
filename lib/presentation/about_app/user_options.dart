import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/contact_us_extension.dart';
import '/core/utils/constants/extensions/launch_alheekmah_url_extension.dart';
import '/core/utils/constants/extensions/share_app_extension.dart';

class UserOptions extends StatelessWidget {
  const UserOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              child: Row(
                children: [
                  Icon(
                    Icons.share_outlined,
                    color: context.theme.hintColor,
                    size: 20,
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: context.theme.colorScheme.surface,
                  ),
                  Text(
                    'share'.tr,
                    style: TextStyle(
                      color: context.theme.colorScheme.inversePrimary
                          .withValues(alpha: .6),
                      fontFamily: 'cairo',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              onTap: () async => await shareApp(),
            ),
            const Divider(),
            InkWell(
              onTap: () => contactUs(
                context: context,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: context.theme.hintColor,
                    size: 20,
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: context.theme.colorScheme.surface,
                  ),
                  Text(
                    'email'.tr,
                    style: TextStyle(
                      color: context.theme.colorScheme.inversePrimary
                          .withValues(alpha: .6),
                      fontFamily: 'cairo',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            InkWell(
              onTap: () => launchAlheekmahUrl(),
              child: Row(
                children: [
                  Icon(
                    Icons.facebook_rounded,
                    color: context.theme.hintColor,
                    size: 20,
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: context.theme.colorScheme.surface,
                  ),
                  Text(
                    'facebook'.tr,
                    style: TextStyle(
                      color: context.theme.colorScheme.inversePrimary
                          .withValues(alpha: .6),
                      fontFamily: 'cairo',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
