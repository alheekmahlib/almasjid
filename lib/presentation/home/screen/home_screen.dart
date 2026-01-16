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
              fit: BoxFit.scaleDown,
              child: FloatyNavBar(
                backgroundColor:
                    context.theme.colorScheme.primary.withValues(alpha: .8),
                shape: const CircleShape(),
                gap: 32,
                selectedTab: controller.currentIndex,
                tabs: NavBarTab.values
                    .map((nav) => FloatyTab(
                          isSelected: controller.currentIndex == nav.tapIndex,
                          title: nav.label.tr,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          selectedColor: context.theme.colorScheme.surface,
                          unselectedColor: Colors.transparent,
                          titleStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'cairo',
                            fontSize: 18,
                            color:
                                context.theme.canvasColor.withValues(alpha: .6),
                          ),
                          icon: customSvgWithColor(
                            height: 30,
                            width: 30,
                            nav.icon,
                            color: controller.currentIndex == nav.tapIndex
                                ? context.theme.colorScheme.primary
                                : context.theme.colorScheme.surface
                                    .withValues(alpha: .6),
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
