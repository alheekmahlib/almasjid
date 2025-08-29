import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../presentation/controllers/theme_controller.dart';

Widget customLottie(String path,
    {double? width, double? height, bool? isRepeat}) {
  return Lottie.asset(path,
      width: width, height: height, repeat: isRepeat ?? true);
}

Widget customLottieWithColor(String path,
    {double? width, double? height, bool? isRepeat, Color? color}) {
  return ColorFiltered(
    colorFilter: ColorFilter.mode(
        ThemeController.instance.isDarkMode
            ? Colors.white
            : color ?? Get.context!.theme.colorScheme.surface,
        BlendMode.modulate),
    child: Lottie.asset(
      path,
      width: width,
      height: height,
      repeat: isRepeat ?? true,
    ),
  );
}

Widget ramadanOrEid(String name, {double? width, double? height}) {
  return Lottie.asset('assets/lottie/$name.json', width: width, height: height);
}
