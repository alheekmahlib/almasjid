part of '../qibla.dart';

class QiblaScreen extends StatelessWidget {
  QiblaScreen({super.key});

  final qiblaCtrl = QiblaController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
          color: context.theme.colorScheme.primaryContainer,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppBarWidget(),
              // const Gap(16),
              Expanded(
                child: activeLocationWidget(
                  context,
                  FutureBuilder<bool>(
                    future: QiblaController.instance.checkCompassAvailability(),
                    builder: (context, snapshot) {
                      // أثناء الفحص، نعرض البوصلة افتراضيًا لعدم تعطيل الواجهة، أو يمكن عرض لودينغ خفيف
                      final hasCompass = snapshot.data ?? true;
                      if (hasCompass) {
                        return GetBuilder<QiblaController>(
                          init: QiblaController.instance,
                          builder: (qiblaCtrl) => IndexedStack(
                            index: qiblaCtrl.currentIndex.value,
                            children: [
                              QiblaCompassWidget(),
                              QiblaMapWidget(),
                            ],
                          ),
                        );
                      }

                      // لا توجد بوصلة: نعرض تنبيه/واجهة بديلة مناسبة
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          customSvgWithColor(
                            SvgPath.svgHomeKaaba,
                            height: Get.width,
                            color: context.theme.colorScheme.surface
                                .withValues(alpha: .05),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                customSvgWithColor(
                                  SvgPath.svgHomeKaaba,
                                  height: 100,
                                  color: context.theme.colorScheme.surface,
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            context.theme.colorScheme.surface,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          children: [
                                            Text(
                                              '${'qiblaDirectionForCity'.tr} ${Location.instance.city}',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'cairo',
                                                fontWeight: FontWeight.bold,
                                                color: context.theme.colorScheme
                                                    .inversePrimary
                                                    .withValues(alpha: .7),
                                              ),
                                            ),
                                            Obx(() => Text(
                                                  '${QiblaController.instance.qiblaDirection.value.toStringAsFixed(1)}°',
                                                  key: ValueKey(QiblaController
                                                      .instance
                                                      .qiblaDirection
                                                      .value
                                                      .toStringAsFixed(1)),
                                                  style: TextStyle(
                                                    fontFamily: 'cairo',
                                                    fontSize: 40,
                                                    height: 1.7,
                                                    fontWeight: FontWeight.w800,
                                                    color: context
                                                        .theme
                                                        .colorScheme
                                                        .inversePrimary
                                                        .withValues(alpha: .6),
                                                  ),
                                                )),
                                          ],
                                        ),
                                        Text(
                                          'qiblaNoteForDesktop'.tr,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'cairo',
                                            fontWeight: FontWeight.bold,
                                            color: context.theme.colorScheme
                                                .inversePrimary
                                                .withValues(alpha: .5),
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget activeLocationWidget(BuildContext context, Widget child) {
    return Obx(() => !GeneralController.instance.state.activeLocation.value
        ? ActiveLocationButton()
        : child);
  }
}
