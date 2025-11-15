import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/extensions.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';
import '../svg_constants.dart';

extension BottomSheetExtension on void {
  void customBottomSheet(
      {required Widget child,
      Widget? titleChild,
      String? textTitle,
      Color? containerColor}) {
    showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        isDismissible: true,
        // showDragHandle: true,
        constraints: BoxConstraints(
            maxWidth:
                Get.context!.customOrientation(Get.width, Get.width * .5)),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(top: 56.0, right: 8.0, left: 8.0),
            child: Container(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border.all(
                  width: 1,
                  color: Theme.of(Get.context!).colorScheme.primary,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: containerColor ??
                      Theme.of(Get.context!).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox().customSvgWithColor(
                          SvgPath.svgCloseCarve,
                          width: 120,
                          color:
                              Theme.of(Get.context!).colorScheme.inversePrimary,
                        ),
                        Container(
                          width: 70,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(Get.context!)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      ],
                    ),
                    const Gap(8),
                    Get.context!.hDivider(
                      color: Theme.of(Get.context!).colorScheme.inversePrimary,
                      height: 1,
                      width: 70,
                    ),
                    titleChild ??
                        Text(
                          textTitle?.tr ?? '',
                          style: TextStyle(
                            color: Theme.of(Get.context!)
                                .colorScheme
                                .inversePrimary,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                    const Gap(8),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            child,
                          ],
                        ),
                      ),
                    ),
                    const Gap(32),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
