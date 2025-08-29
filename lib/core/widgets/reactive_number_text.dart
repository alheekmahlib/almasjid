import 'package:flutter/material.dart'
    show
        BuildContext,
        StatelessWidget,
        Text,
        TextAlign,
        TextDirection,
        TextOverflow,
        TextStyle,
        Widget;
import 'package:get/get.dart';

import '/core/services/languages/localization_controller.dart';
import '/core/utils/constants/extensions/convert_number_extension.dart';

class ReactiveNumberText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  const ReactiveNumberText(
      {super.key,
      required this.text,
      this.style,
      this.textDirection,
      this.textAlign,
      this.overflow});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      id: 'changeLanguage',
      builder: (localeCtrl) => Text(
        text.convertNumbers(),
        style: style,
        textDirection: textDirection,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }
}
