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

  /// الحصول على الموقع المحفوظ من GetStorage
  /// Get stored location from GetStorage
  LatLng? get getStoredLocation {
    try {
      final storedLocation = box.read('CURRENT_LOCATION');
      if (storedLocation is Map<String, dynamic> &&
          storedLocation.containsKey('latitude') &&
          storedLocation.containsKey('longitude')) {
        return LatLng(
          storedLocation['latitude']?.toDouble() ?? 0.0,
          storedLocation['longitude']?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      log('Error getting stored location: $e', name: 'QiblaController');
    }
    return null;
  }

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
    try {
      // أولاً: محاولة استخدام الموقع المحفوظ
      // First: Try to use stored location
      final storedLocation = getStoredLocation;

      if (storedLocation != null) {
        log('Using stored location for Qibla calculation',
            name: 'QiblaController');
        _calculateQiblaFromLocation(storedLocation);
        return;
      }

      // ثانياً: جلب الموقع الحالي إذا لم يكن محفوظاً
      // Second: Get current location if not stored
      log('No stored location found, getting current location',
          name: 'QiblaController');
      await _getCurrentLocationAndCalculateQibla();
    } catch (e) {
      log('Error updating Qibla direction: $e', name: 'QiblaController');
      // في حالة الخطأ، محاولة استخدام الموقع المحفوظ كـ fallback
      final storedLocation = getStoredLocation;
      if (storedLocation != null) {
        _calculateQiblaFromLocation(storedLocation);
      }
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
  Future<void> _getCurrentLocationAndCalculateQibla() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    final currentLocation = LatLng(position.latitude, position.longitude);

    // حفظ الموقع الجديد في GetStorage
    // Save new location to GetStorage
    box.write('CURRENT_LOCATION', {
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    _calculateQiblaFromLocation(currentLocation);
  }

  @override
  void onInit() {
    // تحميل الموقع المحفوظ أولاً
    // Load stored location first
    final storedLocation = getStoredLocation;
    if (storedLocation != null) {
      log('Loading Qibla from stored location', name: 'QiblaController');
      _calculateQiblaFromLocation(storedLocation);
    }

    // التحقق من الصلاحيات وتحديث الموقع إذا لزم الأمر
    // Check permissions and update location if needed
    _checkPermissions().then((_) {
      if (locationEnabled.value && permissionGranted.value) {
        // إذا لم يكن هناك موقع محفوظ، جلب الموقع الحالي
        // If no stored location, get current location
        if (storedLocation == null) {
          updateQiblaDirection();
        }
      }
    });

    qiblaWidgetIndex.value = box.read(QIBLA_WIDGET_INDEX) ?? 0;
    super.onInit();
  }

  /// فرض تحديث الموقع والقبلة
  /// Force location and Qibla update
  Future<void> forceLocationUpdate() async {
    try {
      await _checkPermissions();
      if (locationEnabled.value && permissionGranted.value) {
        await _getCurrentLocationAndCalculateQibla();
        log('Location forcibly updated', name: 'QiblaController');
      }
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
      // إذا لم يكن لدينا موقع محفوظ، نحاول الحصول عليه من نظام الصلاة
      if (!isStoredLocationValid) {
        log('Syncing location with prayer system', name: 'QiblaController');
        final storedLocation = getStoredLocation;
        if (storedLocation != null) {
          _calculateQiblaFromLocation(storedLocation);
        }
      }
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
