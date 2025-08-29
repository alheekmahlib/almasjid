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
            backgroundColor: context.theme.colorScheme.inversePrimary,
            shape: SquircleShape(),
            gap: 32,
            selectedTab: controller.currentIndex,
            tabs: [
              FloatyTab(
                isSelected: controller.currentIndex == 0,
                title: 'prayer',
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  onTap: () {
                    // Add action for search tab
                  },
                ),
              ),
              FloatyTab(
                isSelected: controller.currentIndex == 1,
                title: 'Home',
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  onTap: () {
                    // Add action for search tab
                  },
                ),
              ),
            ],
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: Container(
          //   margin: EdgeInsets.all(16.0),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.surface,
          //     borderRadius: BorderRadius.circular(16),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.1),
          //         blurRadius: 10,
          //         offset: const Offset(0, -5),
          //       ),
          //     ],
          //   ),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(16),
          //     child: BottomNavigationBar(
          //       currentIndex: controller.currentIndex,
          //       onTap: controller.changeIndex,
          //       type: BottomNavigationBarType.fixed,
          //       showSelectedLabels: false,
          //       showUnselectedLabels: false,
          //       backgroundColor: Theme.of(context).colorScheme.surface,
          //       selectedItemColor: Theme.of(context).colorScheme.primary,
          //       unselectedItemColor: Theme.of(context)
          //           .colorScheme
          //           .inversePrimary
          //           .withValues(alpha: 0.6),
          //       selectedLabelStyle: const TextStyle(
          //         fontFamily: 'cairo',
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //       unselectedLabelStyle: const TextStyle(
          //         fontFamily: 'cairo',
          //         fontSize: 18,
          //       ),
          //       items: [
          //         BottomNavigationBarItem(
          //           label: '',
          //           icon: Container(
          //             padding: const EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               color: controller.currentIndex == 0
          //                   ? Theme.of(context)
          //                       .colorScheme
          //                       .primaryContainer
          //                       .withValues(alpha: 0.5)
          //                   : Colors.transparent,
          //               borderRadius: BorderRadius.circular(18),
          //             ),
          //             child: Icon(
          //               Icons.explore,
          //               size: 24,
          //               color: controller.currentIndex == 0
          //                   ? Theme.of(context).colorScheme.primary
          //                   : Theme.of(context)
          //                       .colorScheme
          //                       .onSecondary
          //                       .withValues(alpha: 0.6),
          //             ),
          //           ),
          //         ),
          //         BottomNavigationBarItem(
          //           label: '',
          //           icon: Container(
          //             padding: const EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               color: controller.currentIndex == 1
          //                   ? Theme.of(context)
          //                       .colorScheme
          //                       .primaryContainer
          //                       .withValues(alpha: 0.5)
          //                   : Colors.transparent,
          //               borderRadius: BorderRadius.circular(18),
          //             ),
          //             child: customSvgWithCustomColor(
          //               height: 30,
          //               width: 30,
          //               controller.currentIndex == 1
          //                   ? SvgPath.svgHomePrayerFill
          //                   : SvgPath.svgHomePrayerStroke,
          //               color: context.theme.colorScheme.inversePrimary,
          //             ),
          //           ),
          //         ),
          //         BottomNavigationBarItem(
          //           label: '',
          //           icon: Container(
          //             padding: const EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               color: controller.currentIndex == 2
          //                   ? Theme.of(context)
          //                       .colorScheme
          //                       .primaryContainer
          //                       .withValues(alpha: 0.5)
          //                   : Colors.transparent,
          //               borderRadius: BorderRadius.circular(18),
          //             ),
          //             child: Icon(
          //               Icons.settings,
          //               size: 24,
          //               color: controller.currentIndex == 2
          //                   ? Theme.of(context).colorScheme.primary
          //                   : Theme.of(context)
          //                       .colorScheme
          //                       .onSecondary
          //                       .withValues(alpha: 0.6),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        );
      },
    );
  }
}
