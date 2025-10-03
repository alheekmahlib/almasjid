import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

extension SvgExtensionWithColor on Widget {
  Widget customSvgWithColor(String path,
      {double? height, double? width, Color? color}) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
          color ?? Theme.of(Get.context!).colorScheme.primary, BlendMode.srcIn),
    );
  }
}

extension SvgExtension on Widget {
  Widget customSvgWithCustomColor(String path,
      {double? height, double? width, Color? color}) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
          color ?? Theme.of(Get.context!).primaryColorLight,
          BlendMode.modulate),
    );
  }

  Widget customSvg(String path, {double? height, double? width}) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
    );
  }

  Widget customSvgWithGradient(String path,
      {double? height, double? width, LinearGradient? gradient, BoxFit? fit}) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient!.createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit = BoxFit.contain,
      ),
    );
  }
}
