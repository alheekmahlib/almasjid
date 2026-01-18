part of '../home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة الكنترولر
    Get.put(HomeController());

    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: context.theme.colorScheme.primaryContainer,
          body: NavBarTab.values
              .map((nav) => nav.currentScreen)
              .toList()[controller.currentIndex],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: FloatyNavBar(
                height: 60,
                backgroundColor:
                    context.theme.colorScheme.surface.withValues(alpha: .8),
                // glassEffect: const FloatyGlassEffect.light(),
                shape: const CircleShape(),
                gap: 16,
                selectedTab: controller.currentIndex,
                tabs: NavBarTab.values
                    .map((nav) => FloatyTab(
                          height: 50,
                          width: 65,
                          enableHaptics: true,
                          isSelected: controller.currentIndex == nav.tapIndex,
                          title: nav.label.tr,
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          selectedColor: context.theme.colorScheme.primary,
                          unselectedColor: Colors.transparent,
                          selectedDisplayMode: FloatyTabDisplayMode.titleOnly,
                          unselectedDisplayMode: FloatyTabDisplayMode.iconOnly,
                          titleStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'cairo',
                            fontSize: 18,
                            height: 1.4,
                            color: context.theme.colorScheme.surface,
                          ),
                          icon: customSvgWithColor(
                            height: 30,
                            width: 30,
                            nav.icon,
                            color: context.theme.colorScheme.primary,
                          ),
                          onTap: () => controller.changeIndex(nav.tapIndex),
                          floatyActionButton: FloatyActionButton(
                            icon: customSvgWithColor(
                              height: 30,
                              width: 30,
                              SvgPath.svgHomeRamadan,
                              color: context.theme.colorScheme.primary,
                            ),
                            backgroundColor: context.theme.colorScheme.surface,
                            onTap: () => customBottomSheet(
                              containerColor:
                                  context.theme.colorScheme.primaryContainer,
                              child: RamadanScreen(),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
