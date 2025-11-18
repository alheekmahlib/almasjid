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

  /// التحقق من توفر مستشعر البوصلة على الجهاز
  /// Check if device has a working compass sensor
  Future<bool> checkCompassAvailability(
      {Duration timeout = const Duration(seconds: 2)}) async {
    try {
      final stream = CompassX.events;
      final event = await stream.first.timeout(timeout);
      final heading = event.heading;
      if (heading.isNaN) return false;
      return true;
    } catch (e) {
      log('Compass availability check failed: $e', name: 'QiblaController');
      return false;
    }
  }

  /// الحصول على الموقع المحفوظ من GetStorage
  /// Get stored location from GetStorage
  LatLng? get getStoredLocation {
    // الإعتماد على مدير الكاش الخاص بالصلاة كمصدر وحيد للموقع
    try {
      return PrayerCacheManager.getStoredLocation();
    } catch (e) {
      log('Error getting stored location: $e', name: 'QiblaController');
      return null;
    }
  }

  double get currentZoom => mapController.value.camera.zoom;

  void get currentLocation => mapController.value.move(userLocation.value!, 18);

  void get zoomIn => mapController.value
      .move(mapController.value.camera.center, currentZoom + 1);

  void get zoomOut => mapController.value
      .move(mapController.value.camera.center, currentZoom - 1);

  // لم نعد ندير صلاحيات الموقع هنا؛ إنما نعكس الحالة من الخدمات المركزية
  Future<void> _refreshLocationStatus() async {
    try {
      // الخدمة متاحة؟
      locationEnabled.value =
          await LocationHelper.instance.isLocationServiceEnabled();
      // نعدّ وجود موقع مخزّن كدليل كافٍ للسماح
      permissionGranted.value = getStoredLocation != null;
    } catch (_) {
      locationEnabled.value = false;
      permissionGranted.value = false;
    }
  }

  Future<void> updateQiblaDirection() async {
    try {
      // الإعتماد فقط على الموقع المخزّن من أنظمة الموقع/الصلاة
      final storedLocation = getStoredLocation;
      if (storedLocation == null) {
        log('No stored location found for Qibla calculation',
            name: 'QiblaController');
        return;
      }
      log('Using stored location for Qibla calculation',
          name: 'QiblaController');
      _calculateQiblaFromLocation(storedLocation);
    } catch (e) {
      log('Error updating Qibla direction: $e', name: 'QiblaController');
      // في جميع الأحوال لا نحاول طلب الموقع من هنا
    }
  }

  /// حساب القبلة من موقع محدد
  /// Calculate Qibla from specific location
  void _calculateQiblaFromLocation(LatLng location) {
    final coordinates = Coordinates(
      location.latitude,
      location.longitude,
    );

    final qibla = Qibla(coordinates);
    qiblaDirection.value = qibla.direction;
    userLocation.value = location;
    update();
  }

  /// جلب الموقع الحالي وحساب القبلة
  /// Get current location and calculate Qibla
  // أزيلت: لم نعد نجلب الموقع مباشرة من هنا

  @override
  void onInit() {
    // تحميل القبلة من الموقع المخزّن فقط
    updateQiblaDirection();
    // تحديث حالة الخدمة/الصلاحيات من الخدمات المركزية
    _refreshLocationStatus();

    // الاستماع لتغيّر الموقع المخزّن وتحديث القبلة تلقائيًا
    box.listenKey(CURRENT_LOCATION, (value) {
      log('CURRENT_LOCATION changed, updating Qibla', name: 'QiblaController');
      final loc = getStoredLocation;
      if (loc != null) {
        _calculateQiblaFromLocation(loc);
      }
      _refreshLocationStatus();
    });

    qiblaWidgetIndex.value = box.read(QIBLA_WIDGET_INDEX) ?? 0;
    super.onInit();
  }

  /// فرض تحديث الموقع والقبلة
  /// Force location and Qibla update
  Future<void> forceLocationUpdate() async {
    try {
      // دع خدمات الموقع تحدث الموقع وتكتب في التخزين، ثم أعد التحميل من الكاش
      await LocationHelper.instance.getPositionDetails();
      await updateQiblaDirection();
      await _refreshLocationStatus();
      log('Location forcibly updated via LocationHelper',
          name: 'QiblaController');
    } catch (e) {
      log('Error forcing location update: $e', name: 'QiblaController');
    }
  }

  /// التحقق من صحة الموقع المحفوظ
  /// Validate stored location
  bool get isStoredLocationValid {
    final storedLocation = getStoredLocation;
    return storedLocation != null &&
        storedLocation.latitude != 0.0 &&
        storedLocation.longitude != 0.0;
  }

  /// مزامنة الموقع مع نظام الصلاة
  /// Sync location with prayer system
  void syncWithPrayerSystem() {
    try {
      log('Syncing Qibla with stored location', name: 'QiblaController');
      updateQiblaDirection();
    } catch (e) {
      log('Error syncing with prayer system: $e', name: 'QiblaController');
    }
  }

  /// الحصول على معلومات الموقع الحالي
  /// Get current location info
  Map<String, dynamic> get locationInfo {
    final storedLocation = getStoredLocation;
    return {
      'hasStoredLocation': storedLocation != null,
      'isValid': isStoredLocationValid,
      'latitude': storedLocation?.latitude,
      'longitude': storedLocation?.longitude,
      'qiblaDirection': qiblaDirection.value,
      'userLocation': userLocation.value,
    };
  }

  /// طباعة تقرير حالة القبلة للمطورين
  /// Print Qibla status report for developers
  void printQiblaStatusReport() {
    log('=== QIBLA STATUS REPORT ===', name: 'QiblaController');

    final info = locationInfo;
    log('Stored Location Available: ${info['hasStoredLocation']}',
        name: 'QiblaController');
    log('Location Valid: ${info['isValid']}', name: 'QiblaController');

    if (info['latitude'] != null && info['longitude'] != null) {
      log('Coordinates: ${info['latitude']?.toStringAsFixed(6)}, ${info['longitude']?.toStringAsFixed(6)}',
          name: 'QiblaController');
      log('Qibla Direction: ${info['qiblaDirection']?.toStringAsFixed(2)}°',
          name: 'QiblaController');
    }

    log('Permissions - Location: ${locationEnabled.value}, Permission: ${permissionGranted.value}',
        name: 'QiblaController');
    log('Current User Location: ${userLocation.value}',
        name: 'QiblaController');

    log('=== END QIBLA REPORT ===', name: 'QiblaController');
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
