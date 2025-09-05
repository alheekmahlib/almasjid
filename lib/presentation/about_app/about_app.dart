import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';
import '../../../core/utils/constants/extensions/extensions.dart';
import '../../../core/utils/constants/svg_constants.dart';
import '../../../core/widgets/animated_drawing_widget.dart';
import '../../core/widgets/app_bar_widget.dart';
import 'about_app_text.dart';
import 'user_options.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
          color: context.theme.colorScheme.primaryContainer,
          child: Column(
            children: [
              const AppBarWidget(withBackButton: true),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: context.customOrientation(
                    ListView(
                      children: [
                        const Gap(64),
                        AnimatedDrawingWidget(
                            opacity: 1,
                            width: Get.width * .6,
                            height: Get.width * .3),
                        const Gap(64),
                        const AboutAppText(),
                        const Gap(16),
                        const UserOptions(),
                        const Gap(32),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: customSvgWithCustomColor(
                            SvgPath.svgLogoAqemLogoStroke,
                            height: 200,
                          ),
                        ),
                        const Gap(32),
                        Expanded(
                          flex: 4,
                          child: ListView(
                            children: const [
                              AboutAppText(),
                              Gap(16),
                              UserOptions(),
                            ],
                          ),
                        )
                      ],
                    ),
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
