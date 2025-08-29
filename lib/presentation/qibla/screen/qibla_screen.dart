part of '../qibla.dart';

class QiblaScreen extends StatelessWidget {
  QiblaScreen({super.key});

  final qiblaCtrl = QiblaController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: activeLocationWidget(
      context,
      Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 16.0),
        child: Column(
          children: [
            Flexible(
              child: CustomTabBarWidget(
                firstTabText: 'compass',
                secondTabText: 'map',
                // topChild: Hero(
                //   tag: 'qibla_tag',
                //   child: customSvgWithCustomColor(
                //     SvgPath.svgQeblaLogo,
                //     width: 160.0,
                //     color: context.theme.colorScheme.surface,
                //   ),
                // ),
                firstTabChild: QiblaCompassWidget(),
                secondTabChild: QiblaMapWidget(),
              ),
            ),
          ],
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
                        activeColor: Colors.red,
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
