part of '../splash.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final s = SplashScreenController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: context.customOrientation(
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: AlheekmahAndLoading(),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedDrawingWidget(
                          opacity: .03,
                          width: Get.width,
                          height: Get.width * .6,
                          customColor: context.theme.canvasColor,
                        ),
                        AnimatedDrawingWidget(
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
                  _animatedContainer(context),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GetX<SplashScreenController>(
                      builder: (s) => AnimatedOpacity(
                        opacity: s.state.containerAnimate.value ? 1 : 0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCirc,
                        child: s.customWidget,
                      ),
                    ),
                  ),
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
                                  opacity: .03,
                                  width: Get.width,
                                  height: Get.width * .6),
                              const AnimatedDrawingWidget(),
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 4,
                          child: AlheekmahAndLoading(),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SplashScreenController.instance
                          .ramadhanOrEidGreeting(),
                    ),
                    _animatedContainer(context),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GetX<SplashScreenController>(
                        builder: (s) => AnimatedOpacity(
                          opacity: s.state.containerAnimate.value ? 1 : 0,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCirc,
                          child: s.customWidget,
                        ),
                      ),
                    ),
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
                height: s.state.smallContainerHeight.value,
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
                height: s.state.smallContainerHeight.value,
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
              height: s.state.containerAnimate.value ? Get.height * .5 : 0,
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
                height: s.state.containerAnimate.value ? Get.height * .5 : 0,
                width: Get.width,
                color: context.theme.colorScheme.primaryContainer,
              )),
        ),
      ],
    );
  }
}
