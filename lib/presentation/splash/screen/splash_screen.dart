part of '../splash.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final s = SplashScreenController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.primary,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: context.customOrientation(
              Stack(
                alignment: Alignment.center,
                children: [
                  GetX<SplashScreenController>(
                      builder: (s) => s.state.customWidgetIndex.value == 0
                          ? const Align(
                              alignment: Alignment.bottomCenter,
                              child: AlheekmahAndLoading(),
                            )
                          : const SizedBox.shrink()),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedDrawingWidget(
                          opacity: .02,
                          width: Get.width,
                          height: Get.width * .6,
                          customColor: context.theme.canvasColor,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 56.0),
                        child: SplashScreenController.instance
                            .ramadhanOrEidGreeting()),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: GetX<SplashScreenController>(
                      builder: (s) => s.customWidget,
                    ),
                  ),
                  _animatedContainer(context),
                ],
              ),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedDrawingWidget(
                                  opacity: .02,
                                  width: Get.width,
                                  height: Get.width * .6),
                            ],
                          ),
                        ),
                        GetX<SplashScreenController>(
                          builder: (s) => s.state.customWidgetIndex.value == 0
                              ? const Expanded(
                                  flex: 4,
                                  child: AlheekmahAndLoading(),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SplashScreenController.instance
                          .ramadhanOrEidGreeting(),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GetX<SplashScreenController>(
                        builder: (s) => s.customWidget,
                      ),
                    ),
                    _animatedContainer(context),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget _animatedContainer(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Obx(() => AnimatedContainer(
                alignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCirc,
                height: s.state.firstContainerHeight.value,
                width: Get.width,
                color: context.theme.colorScheme.surface.withValues(alpha: .5),
              )),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Obx(() => AnimatedContainer(
                alignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCirc,
                height: s.state.firstContainerHeight.value,
                width: Get.width,
                color: context.theme.colorScheme.surface.withValues(alpha: .5),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Obx(
            () => AnimatedContainer(
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCirc,
              height: s.state.secondContainerHeight.value,
              width: Get.width,
              color: context.theme.colorScheme.primaryContainer,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Obx(() => AnimatedContainer(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCirc,
                height: s.state.secondContainerHeight.value,
                width: Get.width,
                color: context.theme.colorScheme.primaryContainer,
              )),
        ),
      ],
    );
  }
}
