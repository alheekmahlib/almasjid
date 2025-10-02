import 'package:almasjid/core/utils/constants/extensions/svg_extensions.dart';
import 'package:floaty_nav_bar/floaty_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/constants/svg_constants.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة الكنترولر
    Get.put(HomeController());

    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          body: controller.getCurrentScreen(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatyNavBar(
            backgroundColor:
                context.theme.colorScheme.primary.withValues(alpha: .8),
            shape: const SquircleShape(),
            gap: 32,
            selectedTab: controller.currentIndex,
            tabs: [
              FloatyTab(
                isSelected: controller.currentIndex == 0,
                title: 'qibla'.tr,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                selectedColor: context.theme.colorScheme.surface,
                unselectedColor: Colors.transparent,
                titleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                  fontSize: 18,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                icon: customSvgWithColor(
                  height: 30,
                  width: 30,
                  SvgPath.svgHomeKaaba,
                  color: controller.currentIndex == 0
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.surface.withValues(alpha: .6),
                ),
                onTap: () => controller.changeIndex(0),
              ),
              FloatyTab(
                isSelected: controller.currentIndex == 1,
                title: 'prayer'.tr,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                selectedColor: context.theme.colorScheme.surface,
                unselectedColor: Colors.transparent,
                titleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                  fontSize: 18,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                icon: customSvgWithColor(
                  height: 30,
                  width: 30,
                  SvgPath.svgHomeMosque,
                  color: controller.currentIndex == 1
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.surface.withValues(alpha: .6),
                ),
                onTap: () => controller.changeIndex(1),
              ),
              FloatyTab(
                isSelected: controller.currentIndex == 2,
                title: 'liatafaqahuu'.tr,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                selectedColor: context.theme.colorScheme.surface,
                unselectedColor: Colors.transparent,
                titleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                  fontSize: 18,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                icon: customSvgWithColor(
                  height: 30,
                  width: 30,
                  SvgPath.svgHomeTeachingPrayer,
                  color: controller.currentIndex == 2
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.surface.withValues(alpha: .6),
                ),
                onTap: () => controller.changeIndex(2),
              ),
              FloatyTab(
                isSelected: controller.currentIndex == 3,
                title: 'settings'.tr,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                selectedColor: context.theme.colorScheme.surface,
                unselectedColor: Colors.transparent,
                titleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                  fontSize: 18,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                icon: customSvgWithColor(
                  height: 30,
                  width: 30,
                  SvgPath.svgHomeSettings,
                  color: controller.currentIndex == 3
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.surface.withValues(alpha: .6),
                ),
                onTap: () => controller.changeIndex(3),
              ),
            ],
          ),
        );
      },
    );
  }
}
