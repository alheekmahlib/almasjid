import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/extensions.dart';

class AboutAppText extends StatelessWidget {
  const AboutAppText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ExpansionTile(
        backgroundColor:
            context.theme.colorScheme.surface.withValues(alpha: .15),
        collapsedBackgroundColor:
            context.theme.colorScheme.surface.withValues(alpha: .15),
        collapsedIconColor: context.theme.colorScheme.inversePrimary,
        iconColor: context.theme.colorScheme.inversePrimary,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        minTileHeight: 50.0,
        title: SizedBox(
          width: 100.0,
          child: Text(
            'aboutApp'.tr,
            style: TextStyle(
              fontFamily: 'cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.inversePrimary
                  .withValues(alpha: .6),
            ),
          ),
        ),
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'about_app'.tr,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.inversePrimary,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const Gap(24),
                Text(
                  'about_app2'.tr,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.inversePrimary,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const Gap(8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ('about_app3').tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'cairo',
                        // fontWeight: FontWeight.bold,
                        color: context.theme.hintColor,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    context.hDivider(width: MediaQuery.sizeOf(context).width),
                    const Gap(16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
