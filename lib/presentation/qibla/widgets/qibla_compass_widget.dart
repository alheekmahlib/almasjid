part of '../qibla.dart';

class QiblaCompassWidget extends StatelessWidget {
  QiblaCompassWidget({super.key});

  final qiblaCtrl = QiblaController.instance;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * .8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: compassWidget(context)),
          const Gap(16),
          compassListWidget(context),
          const Gap(64.0),
        ],
      ),
    );
  }

  Widget compassWidget(BuildContext context) {
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
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: const Offset(0, 40),
                      child: Text(
                        '${direction.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 40,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .2),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: const Offset(0, -40),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface
                              .withValues(alpha: .1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${'qiblaDirection'.tr} : ',
                              style: TextStyle(
                                fontFamily: 'cairo',
                                fontSize: 20,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: .6),
                              ),
                            ),
                            Text(
                              '${qiblaCtrl.qiblaDirection.value.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontFamily: 'cairo',
                                fontSize: 20,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: .6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // السهم أو العنصر ثابت دائماً باتجاه القبلة فقط ولا يتأثر باتجاه الجهاز
                      // The widget is always fixed to the Qibla direction only, not affected by device heading

                      if (qiblaIndex == 0)
                        Transform.rotate(
                          angle: ((qiblaCtrl.qiblaDirection.value - direction) *
                              (3.141592653589793 / 180)),
                          child: customSvgWithCustomColor(
                            qiblaList[qiblaIndex]['qibla'],
                            height: qiblaList[qiblaIndex]['height'] + 20,
                            color: context.theme.colorScheme.surface,
                          ),
                        ),
                      if (qiblaIndex == 1)
                        _secondWidget(
                            qiblaIndex,
                            qiblaCtrl,
                            direction: direction,
                            context),
                      if (qiblaIndex == 2)
                        _thirdWidget(context, qiblaCtrl, qiblaIndex,
                            direction: direction),
                      if (qiblaIndex == 3)
                        _forthWidget(context, qiblaCtrl, qiblaIndex,
                            direction: direction),
                      if (qiblaIndex == 4)
                        _fifthWidget(context, qiblaCtrl, qiblaIndex,
                            direction: direction),
                    ],
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _secondWidget(
      int qiblaIndex, QiblaController qiblaCtrl, BuildContext context,
      {double? direction}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: (-qiblaCtrl.qiblaDirection.value * (3.141592653589793 / 180)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              customSvgWithCustomColor(
                SvgPath.svgQiblaQibla2,
                height: qiblaList[qiblaIndex]['height'] + 50,
                color: context.theme.colorScheme.surface,
              ),
              Transform.rotate(
                angle: (qiblaCtrl.qiblaDirection.value *
                    (3.141592653589793 / 180)),
                child: customSvg(
                  SvgPath.svgQiblaKaaba2,
                  height: qiblaList[qiblaIndex]['height'] + 40,
                ),
              ),
            ],
          ),
        ),
        Transform.rotate(
          angle: ((qiblaCtrl.qiblaDirection.value - (direction ?? 0)) *
              (3.141592653589793 / 180)),
          child: customSvgWithCustomColor(
            qiblaList[qiblaIndex]['arrow'],
            height: qiblaList[qiblaIndex]['arrowHeight'] + 20,
            color: context.theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _thirdWidget(
      BuildContext context, QiblaController qiblaCtrl, int qiblaIndex,
      {double? direction}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: (-qiblaCtrl.qiblaDirection.value * (3.141592653589793 / 180)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              customSvgWithCustomColor(
                SvgPath.svgQiblaQibla3,
                height: qiblaList[qiblaIndex]['height'] + 50,
                color: context.theme.colorScheme.surface,
              ),
              Transform.rotate(
                angle: (qiblaCtrl.qiblaDirection.value *
                    (3.141592653589793 / 180)),
                child: customSvg(
                  SvgPath.svgQiblaArrowd3,
                  height: qiblaList[qiblaIndex]['height'] + 45,
                ),
              ),
            ],
          ),
        ),
        Transform.rotate(
          angle: ((qiblaCtrl.qiblaDirection.value - (direction ?? 0)) *
              (3.141592653589793 / 180)),
          child: customSvgWithCustomColor(
            qiblaList[qiblaIndex]['arrow'],
            height: qiblaList[qiblaIndex]['arrowHeight'] + 20,
            color: context.theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _forthWidget(
      BuildContext context, QiblaController qiblaCtrl, int qiblaIndex,
      {double? direction}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: ((qiblaCtrl.qiblaDirection.value - (direction ?? 0)) *
              (3.141592653589793 / 180)),
          child: customSvgWithCustomColor(
            qiblaList[qiblaIndex]['arrow'],
            height: qiblaList[qiblaIndex]['arrowHeight'] + 350,
            color: context.theme.colorScheme.surface,
          ),
        ),
        Transform.rotate(
          angle: (-qiblaCtrl.qiblaDirection.value * (3.141592653589793 / 180)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.3,
                child: customSvgWithCustomColor(
                  SvgPath.svgQiblaQibla4,
                  height: qiblaList[qiblaIndex]['height'] + 20,
                  color: context.theme.colorScheme.surface,
                ),
              ),
              Transform.rotate(
                angle: (qiblaCtrl.qiblaDirection.value *
                    (3.141592653589793 / 180)),
                child: customSvg(
                  SvgPath.svgQiblaKaaba4,
                  height: qiblaList[qiblaIndex]['height'] + 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fifthWidget(
      BuildContext context, QiblaController qiblaCtrl, int qiblaIndex,
      {double? direction}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: (-qiblaCtrl.qiblaDirection.value * (3.141592653589793 / 180)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.3,
                child: customSvgWithCustomColor(
                  SvgPath.svgQiblaQibla5,
                  height: qiblaList[qiblaIndex]['height'] + 70,
                  color: context.theme.colorScheme.surface,
                ),
              ),
              Transform.rotate(
                angle: (qiblaCtrl.qiblaDirection.value *
                    (3.141592653589793 / 180)),
                child: customSvg(
                  SvgPath.svgQiblaKaaba5,
                  height: qiblaList[qiblaIndex]['height'] + 55,
                ),
              ),
            ],
          ),
        ),
        Transform.rotate(
          angle: ((qiblaCtrl.qiblaDirection.value - (direction ?? 0)) *
              (3.141592653589793 / 180)),
          child: customSvgWithCustomColor(
            qiblaList[qiblaIndex]['arrow'],
            height: qiblaList[qiblaIndex]['arrowHeight'] + 20,
            color: context.theme.colorScheme.inverseSurface,
          ),
        ),
        direction! > 0
            ? Container(
                height: 60,
                width: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  '${direction.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 18,
                    color: Get.theme.canvasColor,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        direction > 0
            ? Transform.translate(
                offset: const Offset(0, 35),
                child: Container(
                  height: 40,
                  width: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                      color: Get.theme.canvasColor,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${qiblaCtrl.qiblaDirection.value.toStringAsFixed(1)}°',
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 18,
                      color: Get.theme.canvasColor,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget compassListWidget(BuildContext context) {
    return Container(
        height: 130,
        width: Get.width,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.theme.colorScheme.surface.withValues(alpha: .4),
              context.theme.colorScheme.surface.withValues(alpha: .1),
              context.theme.colorScheme.surface.withValues(alpha: .4),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.symmetric(
            vertical: BorderSide(
              color: context.theme.colorScheme.surface,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 130,
              width: 30,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface.withValues(alpha: .5),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    'changeQiblaWidget'.tr,
                    style: TextStyle(
                        color: context.theme.canvasColor,
                        fontFamily: 'cairo',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
            const Gap(8.0),
            Flexible(
              child: PageView.builder(
                itemCount: qiblaList.length,
                scrollDirection: Axis.horizontal,
                // physics: const FixedExtentScrollPhysics(),
                controller: PageController(
                  initialPage: qiblaCtrl.qiblaWidgetIndex.value,
                  viewportFraction: 0.3,
                ),
                onPageChanged: (i) {
                  qiblaCtrl.qiblaWidgetIndex.value = i;
                  qiblaCtrl.box.write(QIBLA_WIDGET_INDEX, i);
                  qiblaCtrl.update();
                },
                itemBuilder: (context, index) {
                  return Obx(
                    () => Container(
                      width: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: qiblaCtrl.qiblaWidgetIndex.value == index
                                  ? context.theme.colorScheme.surface
                                  : Colors.transparent,
                              width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      padding: const EdgeInsets.all(4.0),
                      margin: const EdgeInsets.all(4.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // السهم أو العنصر ثابت دائماً باتجاه القبلة فقط ولا يتأثر باتجاه الجهاز
                          // The widget is always fixed to the Qibla direction only, not affected by device heading

                          if (index == 0)
                            customSvgWithCustomColor(
                              qiblaList[index]['qibla'],
                              height: qiblaList[index]['height'] + 20,
                              color: context.theme.colorScheme.surface,
                            ),
                          if (index == 1)
                            _secondWidget(index, qiblaCtrl, context,
                                direction: 0),
                          if (index == 2)
                            _thirdWidget(context, qiblaCtrl, index,
                                direction: 0),
                          if (index == 3)
                            _forthWidget(context, qiblaCtrl, index,
                                direction: 0),
                          if (index == 4)
                            _fifthWidget(context, qiblaCtrl, index,
                                direction: 0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
