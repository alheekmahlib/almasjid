import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/extensions.dart';

// كنترولر GetX لإدارة التاب الحالي مع نمط الكائن الوحيد
// GetX controller to manage current tab with singleton pattern
class CustomTabBarController extends GetxController {
  // نمط الكائن الوحيد مع GetX
  // Singleton pattern with GetX
  static CustomTabBarController get instance =>
      Get.isRegistered<CustomTabBarController>()
          ? Get.find<CustomTabBarController>()
          : Get.put(CustomTabBarController());

  RxInt currentIndex = 0.obs;

  // تغيير التاب الحالي
  // Change current tab
  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }
}

class CustomTabBarWidget extends StatelessWidget {
  final String firstTabText;
  final String secondTabText;
  final Widget firstTabChild;
  final Widget secondTabChild;
  final Widget? topChild;
  final double? topPadding;
  final Color? containerColor;

  const CustomTabBarWidget({
    super.key,
    required this.firstTabText,
    required this.secondTabText,
    required this.firstTabChild,
    required this.secondTabChild,
    this.topChild,
    this.topPadding,
    this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    // شرح: نستخدم init داخل GetBuilder لإنشاء الكنترولر إذا لم يكن مسجلاً
    // Explanation: Use init in GetBuilder to create controller if not registered
    return Column(
      children: [
        // Use GetBuilder to show current tab content with singleton pattern
        SizedBox(
          height: Get.height * .75,
          width: context.customOrientation(Get.width, Get.width * .45),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding ?? 0.0),
            child: GetBuilder<CustomTabBarController>(
              init: CustomTabBarController
                  .instance, // استخدام النسخة الوحيدة من الكنترولر
              builder: (tabCtrl) => IndexedStack(
                index: tabCtrl.currentIndex.value,
                children: [
                  firstTabChild,
                  secondTabChild,
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: context.customOrientation(Get.width, Get.width * .45),
          child: Column(
            children: [
              topChild != null ? const Gap(32) : const SizedBox.shrink(),
              topChild ?? const SizedBox.shrink(),
              topChild != null ? const Gap(32) : const SizedBox.shrink(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: containerColor ??
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: .3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: GetBuilder<CustomTabBarController>(
                  // استخدام نمط الكائن الوحيد بدلاً من إنشاء نسخة جديدة في كل مرة
                  // Use singleton pattern instead of creating a new instance each time
                  init: CustomTabBarController.instance,
                  builder: (tabCtrl) => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => tabCtrl.changeTab(0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: tabCtrl.currentIndex.value == 0
                                  ? context.theme.colorScheme.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                firstTabText.tr,
                                style: TextStyle(
                                  color: tabCtrl.currentIndex.value == 0
                                      ? context.theme.canvasColor
                                      : context
                                          .theme.colorScheme.inversePrimary,
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => tabCtrl.changeTab(1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: tabCtrl.currentIndex.value == 1
                                  ? context.theme.colorScheme.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                secondTabText.tr,
                                style: TextStyle(
                                  color: tabCtrl.currentIndex.value == 1
                                      ? context.theme.canvasColor
                                      : context
                                          .theme.colorScheme.inversePrimary,
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ), // استخدام GetBuilder لعرض محتوى التاب الحالي مع نمط الكائن الوحيد
      ],
    );
  }
}
