part of '../qibla.dart';

class QiblaController extends GetxController {
  static QiblaController get instance =>
      GetInstance().putOrFind(() => QiblaController());
  // Qibla =================================================================
  RxDouble qiblaDirection = 0.0.obs;
  RxBool locationEnabled = false.obs;
  RxBool permissionGranted = false.obs;
  RxDouble direction = 0.0.obs;
  RxInt qiblaWidgetIndex = 0.obs;
  Rx<Color> qiblaColor =
      Theme.of(Get.context!).colorScheme.surface.withValues(alpha: .3).obs;
  RxBool isCorrect = false.obs;
  final box = GetStorage();
  Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  LatLng qiblaLocation = const LatLng(21.4225, 39.8262);
  Rx<MapController> mapController = MapController().obs;
  List<LatLng>? geodesicPoints;

  RxInt currentIndex = 0.obs;

  // التبديل بين الشاشتين
  // Toggle between screens
  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }

  RxBool isDirectionCorrect(double direction) =>
      ((qiblaDirection.value - direction).abs() <= 0.3).obs;

  double get currentZoom => mapController.value.camera.zoom;

  void get currentLocation => mapController.value.move(userLocation.value!, 18);

  void get zoomIn => mapController.value
      .move(mapController.value.camera.center, currentZoom + 1);

  void get zoomOut => mapController.value
      .move(mapController.value.camera.center, currentZoom - 1);

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    locationEnabled.value = serviceEnabled;
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permissionGranted.value = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      permissionGranted.value = false;
      return;
    }

    permissionGranted.value = true;
  }

  Future<void> updateQiblaDirection() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    Coordinates coordinates = Coordinates(
      position.latitude,
      position.longitude,
    );

    Qibla qibla = Qibla(coordinates);
    qiblaDirection.value = qibla.direction;
    userLocation.value =
        LatLng(position.latitude, position.longitude); // تحديث Rx
    update();
  }

  @override
  void onInit() {
    _checkPermissions().then((_) {
      if (locationEnabled.value && permissionGranted.value) {
        updateQiblaDirection();
      }
    });
    qiblaWidgetIndex.value = box.read(QIBLA_WIDGET_INDEX) ?? 0;
    super.onInit();
  }

  List<LatLng> calculateGeodesicPoints(LatLng start, LatLng end, int steps) {
    final startPosition = turf.Position(start.longitude, start.latitude);
    final endPosition = turf.Position(end.longitude, end.latitude);
    final line = turf.Feature<turf.LineString>(
      geometry: turf.LineString(coordinates: [startPosition, endPosition]),
    );

    List<LatLng> points = [];
    double totalDistance = turf.length(line).toDouble();
    for (int i = 0; i <= steps; i++) {
      double fraction = (i / steps) * totalDistance;
      final interpolatedPoint = turf.along(line, fraction);
      if (interpolatedPoint.geometry != null) {
        points.add(LatLng(
          interpolatedPoint.geometry!.coordinates[1]!.toDouble(),
          interpolatedPoint.geometry!.coordinates[0]!.toDouble(),
        ));
      }
    }
    return points;
  }
}

class CachedTileProvider extends TileProvider {
  final BaseCacheManager cacheManager = DefaultCacheManager();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = options.urlTemplate!
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString())
        .replaceAll('{z}', coordinates.z.toString());

    return NetworkImageWithCache(url, cacheManager);
  }
}

class NetworkImageWithCache extends ImageProvider<NetworkImageWithCache> {
  final String url;
  final BaseCacheManager cacheManager;

  NetworkImageWithCache(this.url, this.cacheManager);

  @override
  Future<NetworkImageWithCache> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageWithCache>(this);
  }

  // @override
  ImageStreamCompleter load(NetworkImageWithCache key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync() async {
    try {
      // تحميل البلاطة من الكاش أو الإنترنت
      final fileInfo = await cacheManager.getSingleFile(url);

      final bytes = await fileInfo.readAsBytes();

      // استخدام ui.instantiateImageCodec لتحويل البيانات إلى Codec
      return await ui.instantiateImageCodec(bytes);
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }
}
