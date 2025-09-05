part of '../qibla.dart';

class QiblaMapWidget extends StatelessWidget {
  QiblaMapWidget({super.key});

  final qiblaCtrl = QiblaController.instance;
  final cacheManager = DefaultCacheManager();

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
        height: Get.height * .8,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Stack(
              children: [
                StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
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

                    return Obx(() => ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.1, 0.9, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: qiblaCtrl.mapController.value,
                                options: MapOptions(
                                  initialCenter: qiblaCtrl.userLocation.value!,
                                  initialZoom: 17,
                                  interactionOptions: const InteractionOptions(
                                    flags: ~InteractiveFlag.doubleTapZoom,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: ApiConstants.mapUrl,
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
                                            ? context.theme.colorScheme.primary
                                            : context.theme.colorScheme.primary
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
                                          angle:
                                              direction * (3.14159265359 / 180),
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
                              // ...يمكنك إضافة عناصر أخرى فوق الخريطة هنا إذا أردت...
                            ],
                          ),
                        ));
                  },
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32.0, horizontal: 16.0),
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
                            child: Icon(Icons.add,
                                color: context.theme.canvasColor),
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
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
