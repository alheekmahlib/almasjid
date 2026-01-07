import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSwitchWidget<T extends GetxController> extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final T controller;
  final String title;
  final String? getBuilderId;
  final double? startPadding;
  final double? topPadding;
  final double? endPadding;
  final double? bottomPadding;
  final double? startMargin;
  final double? topMargin;
  final double? endMargin;
  final double? bottomMargin;
  final Widget? titleWidget;
  final Color? continerColor;
  const CustomSwitchWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.controller,
    required this.title,
    this.getBuilderId,
    this.startPadding = 0.0,
    this.topPadding = 0.0,
    this.endPadding = 0.0,
    this.bottomPadding = 0.0,
    this.startMargin = 0.0,
    this.topMargin = 1.0,
    this.endMargin = 0.0,
    this.bottomMargin = 1.0,
    this.titleWidget,
    this.continerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(startMargin ?? 0.0,
          topMargin ?? 0.0, endMargin ?? 0.0, bottomMargin ?? 0.0),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(startPadding ?? 0.0,
            topPadding ?? 0.0, endPadding ?? 0.0, bottomPadding ?? 0.0),
        decoration: BoxDecoration(
          color: continerColor ??
              Theme.of(context).colorScheme.surface.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: titleWidget ??
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title.tr,
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                      ),
                    ),
              ),
            ),
            GetBuilder<T>(
              init: controller,
              id: getBuilderId,
              builder: (ctrl) => Switch(
                value: value,
                activeThumbColor: Colors.red,
                inactiveTrackColor: context.theme.colorScheme.secondaryContainer
                    .withValues(alpha: .5),
                activeTrackColor:
                    context.theme.colorScheme.surface.withValues(alpha: .7),
                thumbColor: value
                    ? WidgetStatePropertyAll(context.theme.colorScheme.surface)
                    : WidgetStatePropertyAll(context.theme.canvasColor),
                trackOutlineColor:
                    WidgetStatePropertyAll(context.theme.colorScheme.surface),
                inactiveThumbColor:
                    context.theme.colorScheme.surface.withValues(alpha: .2),
                trackColor: WidgetStatePropertyAll(value
                    ? context.theme.colorScheme.secondaryContainer
                    : Colors.red.withValues(alpha: .8)),
                onChanged: (v) {
                  onChanged(v);
                  if (getBuilderId != null) {
                    ctrl.update([getBuilderId!]);
                  } else {
                    ctrl.update();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
