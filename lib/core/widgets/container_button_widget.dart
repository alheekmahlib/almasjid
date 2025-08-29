import 'package:almasjid/core/utils/constants/svg_constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/alignment_rotated_extension.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';

class ContainerButtonWidget extends StatelessWidget {
  final String? svgPath;
  final String? title;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? svgHeight;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? svgColor;
  final Color? borderColor;
  final Widget? child;
  final IconData? icon;
  final double? verticalMargin;
  final double? horizontalMargin;
  const ContainerButtonWidget(
      {super.key,
      this.svgPath,
      this.onPressed,
      this.width,
      this.backgroundColor,
      this.shadowColor,
      this.svgColor,
      this.title,
      this.child,
      this.svgHeight,
      this.borderColor,
      this.icon,
      this.height,
      this.verticalMargin,
      this.horizontalMargin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        padding: EdgeInsets.all(4.0),
        margin: EdgeInsets.symmetric(
            vertical: verticalMargin ?? 0.0,
            horizontal: horizontalMargin ?? 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.surface,
            width: 1,
          ),
        ),
        child: ClipPath(
          child: Container(
            height: height ?? 35,
            width: width ?? 30,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).colorScheme.surface.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Transform.translate(
                    offset: alignmentLayout(
                        const Offset(-40, 0), const Offset(40, 0)),
                    child: icon != null
                        ? Icon(
                            icon!,
                            size: 200,
                            color: svgColor ??
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withValues(alpha: .1),
                          )
                        : customSvgWithColor(
                            svgPath ?? SvgPath.svgAlert,
                            height: 200,
                            color: svgColor ??
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withValues(alpha: .1),
                          ),
                  ),
                ),
                title != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          icon != null
                              ? Icon(
                                  icon!,
                                  size: svgHeight ?? 24,
                                  color: svgColor ??
                                      Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                          .withValues(alpha: .1),
                                )
                              : customSvgWithColor(
                                  svgPath ?? SvgPath.svgAlert,
                                  height: 24,
                                  color: svgColor ??
                                      Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                ),
                          const Gap(8),
                          Text(
                            title!,
                            style: TextStyle(
                              fontSize: 18,
                              color: context.theme.canvasColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'cairo',
                              height: 1.5,
                            ),
                          ),
                        ],
                      )
                    : child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
