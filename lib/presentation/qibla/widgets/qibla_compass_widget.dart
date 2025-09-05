part of '../qibla.dart';

class QiblaCompassWidget extends StatelessWidget {
  QiblaCompassWidget({super.key});

  final qiblaCtrl = QiblaController.instance;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QiblaController>(
      builder: (qiblaCtrl) {
        if (!qiblaCtrl.locationEnabled.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (!qiblaCtrl.permissionGranted.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (!snapshot.hasData ||
                qiblaCtrl.qiblaDirection.value == 0.0) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else {
              double direction = snapshot.data!.heading!;
              final qiblaIndex = qiblaCtrl.qiblaWidgetIndex.value;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                qiblaCtrl.direction.value = direction;
                if (qiblaCtrl.isDirectionCorrect(direction).value) {
                  HapticFeedback.mediumImpact();
                  qiblaCtrl.qiblaColor.value = Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: .4);
                  qiblaCtrl.isCorrect.value = true;
                } else {
                  qiblaCtrl.qiblaColor.value = Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: .2);
                  qiblaCtrl.isCorrect.value = false;
                }
              });
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        customSvgWithColor(
                          SvgPath.svgHomeKaaba,
                          height: 70,
                          color:
                              context.theme.canvasColor.withValues(alpha: .4),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${'qiblaDirection'.tr} : ',
                              style: TextStyle(
                                fontFamily: 'cairo',
                                fontSize: 28,
                                height: 1.6,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: .6),
                              ),
                            ),
                            Text(
                              '${qiblaCtrl.qiblaDirection.value.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontFamily: 'cairo',
                                fontSize: 45,
                                height: 1.6,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: .6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: ((qiblaCtrl.qiblaDirection.value - direction) *
                          (3.141592653589793 / 180)),
                      child: customSvg(
                        qiblaList[qiblaIndex]['qibla'],
                        height: qiblaList[qiblaIndex]['height'] + 20,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: .3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${direction.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 20,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .6),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}
