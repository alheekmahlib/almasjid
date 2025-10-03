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
            color: context.theme.colorScheme.surface,
            child: activeLocationWidget(
              context,
              Container(
                color: context.theme.colorScheme.primaryContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppBarWidget(),
                    // const Gap(16),
                    Expanded(
                      child: context.definePlatform(
                          GetBuilder<QiblaController>(
                            init: QiblaController.instance,
                            builder: (qiblaCtrl) => IndexedStack(
                              index: qiblaCtrl.currentIndex.value,
                              children: [
                                QiblaCompassWidget(),
                                QiblaMapWidget(),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              customSvgWithColor(
                                SvgPath.svgHomeKaaba,
                                height: Get.width,
                                color: context.theme.colorScheme.surface
                                    .withValues(alpha: .05),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: context
                                                .theme.colorScheme.surface,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${'qiblaDirectionForCity'.tr} ${Location.instance.city}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'cairo',
                                                    fontWeight: FontWeight.bold,
                                                    color: context
                                                        .theme
                                                        .colorScheme
                                                        .inversePrimary
                                                        .withValues(alpha: .7),
                                                  ),
                                                ),
                                                Text(
                                                  '${qiblaCtrl.qiblaDirection.value.toStringAsFixed(1)}°',
                                                  key: ValueKey(qiblaCtrl
                                                      .qiblaDirection.value
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
                                                ),
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
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget activeLocationWidget(BuildContext context, Widget child) {
    return Obx(() => !GeneralController.instance.state.activeLocation.value
        ? Container(
            height: 80,
            width: Get.width,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 7,
                  child: Text(
                    'turnOnLocation'.tr,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'naskh',
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.inversePrimary
                          .withValues(alpha: .7),
                    ),
                  ),
                ),
                const Gap(32),
                Expanded(
                  flex: 2,
                  child: Obx(() => Switch(
                        value: GeneralController
                            .instance.state.activeLocation.value,
                        activeThumbColor: Colors.red,
                        inactiveTrackColor: context.theme.colorScheme.surface
                            .withValues(alpha: .5),
                        activeTrackColor: context.theme.colorScheme.surface
                            .withValues(alpha: .7),
                        thumbColor: WidgetStatePropertyAll(
                            context.theme.colorScheme.surface),
                        trackOutlineColor: WidgetStatePropertyAll(
                            GeneralController
                                    .instance.state.activeLocation.value
                                ? context.theme.colorScheme.surface
                                : context.theme.canvasColor
                                    .withValues(alpha: .5)),
                        onChanged: (_) async => await GeneralController.instance
                            .toggleLocationService(),
                      )),
                ),
              ],
            ),
          )
        : child);
  }
}
