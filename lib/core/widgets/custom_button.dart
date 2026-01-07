import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';
import '../utils/constants/svg_constants.dart';

class CustomButton extends StatelessWidget {
  final String? svgPath;
  final VoidCallback onPressed;
  final double? width;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? svgColor;
  final IconData? icon;
  final double? iconSize;
  final String? title;
  final Color? titleColor;
  final Color? borderColor;
  final Widget? iconWidget;
  final bool? isCustomSvgColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? borderRadius;
  const CustomButton(
      {super.key,
      this.svgPath,
      required this.onPressed,
      this.width,
      this.backgroundColor,
      this.shadowColor,
      this.svgColor,
      this.icon,
      this.iconSize,
      this.title,
      this.titleColor,
      this.borderColor,
      this.iconWidget,
      this.isCustomSvgColor = false,
      this.horizontalPadding,
      this.verticalPadding,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 30,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.transparent,
            shadowColor: shadowColor ?? Colors.transparent,
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding ?? 4.0,
                vertical: verticalPadding ?? 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 4.0),
              // side: BorderSide(
              //   color: borderColor ?? Colors.transparent,
              //   width: 1,
              // ),
            ),
          ),
          onPressed: onPressed,
          child: title != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background graphic/icon. When using an Icon, position it with an end offset.
                      svgPath != null
                          ? (isCustomSvgColor!
                              ? _svgBuild(context)
                              : _svgBuildWithCustomColor(context))
                          : PositionedDirectional(
                              end: 60,
                              child: _iconBuild(context),
                            ),
                      title != null
                          ? Text(
                              title!.tr,
                              style: TextStyle(
                                  color: titleColor ??
                                      context
                                          .theme.colorScheme.secondaryContainer,
                                  fontFamily: 'cairo',
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              textAlign: TextAlign.center,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                )
              : svgPath != null
                  ? isCustomSvgColor!
                      ? _svgBuild(context)
                      : _svgBuildWithCustomColor(context)
                  : iconWidget ?? _iconBuild(context),
        ),
      ),
    );
  }

  Widget _iconBuild(BuildContext context) {
    // Return a plain Icon so it can be used safely in any layout.
    return Icon(
      icon ?? Icons.cloud_download_outlined,
      size: iconSize ?? 40,
      color: svgColor ?? context.theme.primaryColorLight,
    );
  }

  Widget _svgBuildWithCustomColor(BuildContext context) {
    return customSvgWithCustomColor(
      svgPath ?? SvgPath.svgAlert,
      width: iconSize ?? 40,
      color: svgColor ?? context.theme.primaryColorLight,
    );
  }

  Widget _svgBuild(BuildContext context) {
    return customSvgWithColor(
      svgPath ?? SvgPath.svgAlert,
      width: iconSize ?? 40,
      color: svgColor ?? context.theme.colorScheme.secondaryContainer,
    );
  }
}
