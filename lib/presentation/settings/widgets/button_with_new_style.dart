import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';

class ButtonWithNewStyle<T extends GetxController> extends StatelessWidget {
  final VoidCallback onTap;
  final T controller;
  final bool value;
  final String? svgPath;
  final String? imagePath;
  final Widget? child;
  final double? containerHeight;
  final double? containerWidth;
  final bool? isWithBorder;
  final Color? checkBoxColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? horizontalMargin;
  final double? verticalMargin;
  const ButtonWithNewStyle(
      {super.key,
      required this.onTap,
      required this.controller,
      required this.value,
      this.svgPath = '',
      this.imagePath = '',
      this.child,
      this.containerHeight,
      this.containerWidth,
      this.isWithBorder = true,
      this.checkBoxColor,
      this.horizontalPadding,
      this.verticalPadding,
      this.horizontalMargin,
      this.verticalMargin});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      init: controller,
      builder: (c) => GestureDetector(
          onTap: onTap,
          child: Container(
            height: containerHeight,
            width: containerWidth,
            decoration: BoxDecoration(
                color: context.theme.colorScheme.surface.withValues(alpha: .2),
                border: Border.all(
                    color: isWithBorder!
                        ? value
                            ? context.theme.colorScheme.surface
                            : Colors.transparent
                        : Colors.transparent,
                    width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding ?? 4.0,
                vertical: verticalPadding ?? 4.0),
            margin: EdgeInsets.symmetric(
                horizontal: horizontalMargin ?? 4.0,
                vertical: verticalMargin ?? 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: containerHeight! - 5,
                      width: 15,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        color: context.theme.colorScheme.secondaryContainer
                            .withValues(alpha: .2),
                      ),
                    ),
                    Container(
                      height: containerHeight! - 20,
                      width: 8,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3.0)),
                        color: value
                            ? checkBoxColor ?? context.theme.canvasColor
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (svgPath != null)
                        customSvg(
                          svgPath!,
                          height: containerHeight! - 10,
                        ),
                      if (imagePath != null)
                        Image.asset(
                          imagePath!,
                          height: containerHeight! - 10,
                        ),
                      if (child != null) child!,
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
