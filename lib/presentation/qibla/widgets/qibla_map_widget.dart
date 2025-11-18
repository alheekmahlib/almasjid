part of '../qibla.dart';

class QiblaMapWidget extends StatelessWidget {
  QiblaMapWidget({super.key});

  final qiblaCtrl = QiblaController.instance;
  final cacheManager = DefaultCacheManager();
  final themeCtrl = ThemeController.instance;

  @override
  Widget build(BuildContext context) {
    // استخدم Obx لمراقبة userLocation
    return Obx(() {
      if (qiblaCtrl.userLocation.value == null) {
        // إذا لم تتوفر الإحداثيات بعد، أظهر مؤشر التحميل
        return const Center(child: CircularProgressIndicator());
      }

      qiblaCtrl.geodesicPoints = qiblaCtrl.calculateGeodesicPoints(
          qiblaCtrl.userLocation.value!, qiblaCtrl.qiblaLocation, 100);

      return SizedBox(
        height: Get.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              StreamBuilder<CompassXEvent>(
                stream: CompassX.events,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error calculating Qiblah direction.'));
                  }

                  double? direction = snapshot.data?.heading;
                  if (direction == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    qiblaCtrl.direction.value = direction;
                    if (qiblaCtrl.isDirectionCorrect(direction).value) {
                      HapticFeedback.mediumImpact();
                      try {
                        qiblaCtrl.mapController.value.rotate(-direction);
                      } catch (e) {
                        log('Error rotating map: $e');
                      }
                    }
                  });

                  return Obx(() => Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          FlutterMap(
                            mapController: qiblaCtrl.mapController.value,
                            options: MapOptions(
                              initialCenter: qiblaCtrl.userLocation.value!,
                              initialZoom: 17,
                              backgroundColor: Colors.transparent,
                              interactionOptions: const InteractionOptions(
                                flags: ~InteractiveFlag.doubleTapZoom,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: themeCtrl.isDarkMode
                                    ? ApiConstants.mapDarkUrl
                                    : ApiConstants.mapLightUrl,
                                // tileProvider: CachedTileProvider(),
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: qiblaCtrl.geodesicPoints!,
                                    strokeWidth: 10.0,
                                    color: qiblaCtrl
                                            .isDirectionCorrect(direction)
                                            .value
                                        ? context.theme.colorScheme.surface
                                        : context.theme.colorScheme.surface
                                            .withValues(alpha: .3),
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: qiblaCtrl.userLocation.value!,
                                    width: 60,
                                    height: 60,
                                    child: Transform.rotate(
                                      angle: direction * (3.14159265359 / 180),
                                      child: Transform.translate(
                                        offset: const Offset(0, -15),
                                        child: customSvgWithCustomColor(
                                          SvgPath.svgQiblaPrayerRug,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Marker(
                                    point: qiblaCtrl.qiblaLocation,
                                    width: 20,
                                    height: 20,
                                    child: customSvgWithCustomColor(
                                      SvgPath.svgQiblaArrow4,
                                      height: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: HeaderCardWidget(
                                  aligned: qiblaCtrl
                                      .isDirectionCorrect(direction)
                                      .value),
                            ),
                          ),
                        ],
                      ));
                },
              ),
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 64.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => qiblaCtrl.currentLocation,
                        child: Container(
                          height: 35,
                          width: 35,
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.location_on_outlined,
                              color: context.theme.canvasColor),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => qiblaCtrl.zoomIn,
                        child: Container(
                          height: 35,
                          width: 35,
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.add, color: context.theme.canvasColor),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => qiblaCtrl.zoomOut,
                        child: Container(
                          height: 35,
                          width: 35,
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.remove,
                              color: context.theme.canvasColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
