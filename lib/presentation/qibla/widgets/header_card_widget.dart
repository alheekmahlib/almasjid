part of '../qibla.dart';

class HeaderCardWidget extends StatelessWidget {
  final bool aligned;
  const HeaderCardWidget({
    super.key,
    required this.aligned,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QiblaController>(
      // استخدام نمط الكائن الوحيد بدلاً من إنشاء نسخة جديدة في كل مرة
      // Use singleton pattern instead of creating a new instance each time
      init: QiblaController.instance,
      builder: (qiblaCtrl) => Column(
        children: [
          Row(
            children: [
              CustomButton(
                onPressed: () {
                  // التبديل بين الشاشتين - Switch between screens
                  int newIndex = qiblaCtrl.currentIndex.value == 0 ? 1 : 0;
                  qiblaCtrl.changeTab(newIndex);
                },
                width: 80,
                borderRadius: 16,
                verticalPadding: 8.0,
                backgroundColor: context.theme.colorScheme.surface,
                iconWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      qiblaCtrl.currentIndex.value == 0
                          ? Icons.map_outlined
                          : Icons.compass_calibration_outlined,
                      color: context.theme.canvasColor,
                      size: 26,
                    ),
                    const Gap(2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        qiblaCtrl.currentIndex.value == 0
                            ? 'map'.tr
                            : 'compass'.tr,
                        style: TextStyle(
                          color: context.theme.canvasColor,
                          fontFamily: 'cairo',
                          fontWeight: FontWeight.bold,
                          height: 1.7,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color:
                        context.theme.colorScheme.surface.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary
                            .withValues(alpha: .08),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${'qiblaDirection'.tr} : ',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 20,
                              height: 1.7,
                              fontWeight: FontWeight.w800,
                              color: context.theme.colorScheme.inversePrimary
                                  .withValues(alpha: .6),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Text(
                            '${qiblaCtrl.qiblaDirection.value.toStringAsFixed(1)}°',
                            key: ValueKey(qiblaCtrl.qiblaDirection.value
                                .toStringAsFixed(1)),
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 40,
                              height: 1.7,
                              fontWeight: FontWeight.w800,
                              color: context.theme.colorScheme.inversePrimary
                                  .withValues(alpha: .6),
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
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: aligned ? 1 : 0,
            child: customLottie(LottieConstants.assetsLottieCheck, height: 120),
          ),
        ],
      ),
    );
  }
}
