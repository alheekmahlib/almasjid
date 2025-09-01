import 'package:almasjid/core/utils/constants/extensions/bottom_sheet_extension.dart';
import 'package:almasjid/core/utils/constants/extensions/svg_extensions.dart';
import 'package:floaty_nav_bar/floaty_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/constants/svg_constants.dart';
import '../prayers/prayers.dart';
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
            backgroundColor: context.theme.colorScheme.inversePrimary,
            shape: const SquircleShape(),
            gap: 32,
            selectedTab: controller.currentIndex,
            tabs: [
              FloatyTab(
                isSelected: controller.currentIndex == 0,
                title: 'prayer',
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                selectedColor: context.theme.colorScheme.surface,
                unselectedColor: Colors.transparent,
                titleStyle: TextStyle(
                  fontFamily: 'cairo',
                  fontSize: 18,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                icon: customSvgWithColor(
                  height: 30,
                  width: 30,
                  SvgPath.svgHomeMosque,
                  color: controller.currentIndex == 0
                      ? context.theme.colorScheme.inversePrimary
                      : context.theme.canvasColor.withValues(alpha: .6),
                ),
                onTap: () => controller.changeIndex(0),
                floatyActionButton: FloatyActionButton(
                  icon: customSvgWithColor(
                    height: 30,
                    width: 30,
                    SvgPath.svgHomeSettings,
                    color: context.theme.canvasColor.withValues(alpha: .6),
                  ),
                  onTap: () => context.customBottomSheet(
                    containerColor: context.theme.colorScheme.primaryContainer,
                    textTitle: 'prayerSettings',
                    child: const PrayerSettings(),
                  ),
                ),
              ),
              FloatyTab(
                isSelected: controller.currentIndex == 1,
                title: 'Home',
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                selectedColor: context.theme.colorScheme.surface,
                unselectedColor: Colors.transparent,
                titleStyle: TextStyle(
                  fontFamily: 'cairo',
                  fontSize: 18,
                  color: context.theme.canvasColor.withValues(alpha: .6),
                ),
                icon: customSvgWithColor(
                  height: 30,
                  width: 30,
                  SvgPath.svgHomeKaaba,
                  color: controller.currentIndex == 1
                      ? context.theme.colorScheme.inversePrimary
                      : context.theme.canvasColor.withValues(alpha: .6),
                ),
                onTap: () => controller.changeIndex(1),
                floatyActionButton: FloatyActionButton(
                  icon: customSvgWithColor(
                    height: 30,
                    width: 30,
                    SvgPath.svgHomeSettings,
                    color: context.theme.canvasColor.withValues(alpha: .6),
                  ),
                  onTap: () => context.customBottomSheet(
                    containerColor: context.theme.colorScheme.primaryContainer,
                    textTitle: 'prayerSettings',
                    child: const PrayerSettings(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
