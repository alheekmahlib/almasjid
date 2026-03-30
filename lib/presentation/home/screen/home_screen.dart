part of '../home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController.instance,
      builder: (ctrl) {
        return Scaffold(
          extendBody: false,
          backgroundColor: context.theme.colorScheme.primaryContainer,
          body: Stack(
            children: [
              NavBarTab.values
                  .map((nav) => nav.currentScreen)
                  .toList()[ctrl.currentIndex],
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatyNavBar(
                  height: 45,
                  backgroundColor: context.theme.colorScheme.surface,
                  // glassEffect: FloatyGlassEffect.liquidGlass(
                  //   gradient: LinearGradient(
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //       colors: [
                  //         context.theme.colorScheme.surface.withValues(alpha: .4),
                  //         context.theme.colorScheme.surface.withValues(alpha: .28),
                  //         context.theme.colorScheme.surface.withValues(alpha: .2),
                  //         context.theme.colorScheme.surface.withValues(alpha: .3)
                  //       ],
                  //       stops: const [
                  //         0.0,
                  //         0.3,
                  //         0.7,
                  //         1.0
                  //       ]),
                  // ),
                  // shape: const CircleShape(),
                  // gap: 16,
                  selectedTab: ctrl.currentIndex,
                  margin: EdgeInsets.symmetric(
                      horizontal:
                          context.customOrientation(16.0, Get.width * .2)),
                  menu: FloatyMenu(
                    height: context.customOrientation(380.0, 200.0),
                    controller: ctrl.floatyMenuController,
                    child: const SettingsScreen(),
                    borderRadius: BorderRadius.circular(32),
                    icon: customSvgWithColor(
                      height: 20,
                      SvgPath.svgHomeSettings,
                      color: context.theme.hintColor,
                    ),
                    title: 'settings'.tr,
                    titleStyle: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 12,
                      height: 1,
                      color: context.theme.hintColor,
                    ),
                    selectedColor:
                        context.theme.canvasColor.withValues(alpha: .2),
                    unselectedColor: Colors.transparent,
                    selectedDisplayMode: FloatyTabDisplayMode.iconOnly,
                    unselectedDisplayMode: FloatyTabDisplayMode.iconOnly,
                    labelPosition: FloatyLabelPosition.bottom,
                  ),
                  tabs: NavBarTab.values
                      .map((nav) => FloatyTab(
                            // height: 40,
                            indicatorColor: context.theme.colorScheme.primary,
                            enableHaptics: true,
                            isSelected: ctrl.currentIndex == nav.tapIndex,
                            title: nav.label.tr,
                            margin: EdgeInsets.zero,
                            selectedColor:
                                context.theme.canvasColor.withValues(alpha: .2),
                            unselectedColor: Colors.transparent,
                            selectedDisplayMode: FloatyTabDisplayMode.iconOnly,
                            unselectedDisplayMode:
                                FloatyTabDisplayMode.iconOnly,
                            labelPosition: FloatyLabelPosition.bottom,
                            titleStyle: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 12,
                              height: 1,
                              color: context.theme.hintColor,
                            ),
                            icon: customSvgWithColor(
                              height: 22,
                              nav.icon,
                              color: context.theme.hintColor,
                            ),
                            onTap: () => ctrl.changeIndex(nav.tapIndex),
                            floatyActionButton: FloatyActionButton(
                              icon: customSvgWithColor(
                                height: 22,
                                SvgPath.svgHomeRamadan,
                                color: context.theme.hintColor,
                              ),
                              backgroundColor:
                                  context.theme.colorScheme.surface,
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
            ],
          ),
        );
      },
    );
  }
}
