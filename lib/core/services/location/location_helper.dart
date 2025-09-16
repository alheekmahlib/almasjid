part of 'locations.dart';

class LocationHelper {
  static final LocationHelper instance = LocationHelper._();

  factory LocationHelper() {
    return instance;
  }
  LocationHelper._();

  Future<bool> checkPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('message',
              error: LocationException('Location permissions are denied.'));
          throw LocationException('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException('Location permissions are permanently denied.');
      }
      return true;
    } catch (e) {
      log('Error checking location permission: $e',
          name: LocationHelper.instance.toString());
      return false;
    }
  }

  Future<void> getPositionDetails() async {
    bool? isGoogle = await GoogleHuaweiAvailability.isGoogleServiceAvailable;
    bool? isHuawei = await GoogleHuaweiAvailability.isHuaweiServiceAvailable;
    final bool useHuaweiLocation =
        Platform.isAndroid && (isHuawei == true) && (isGoogle != true);

    if (await Geolocator.isLocationServiceEnabled()) {
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    }
    if (await checkPermission()) {
      Position? currentPosition;

      if (useHuaweiLocation) {
        try {
          hms_location.FusedLocationProviderClient locationClient =
              hms_location.FusedLocationProviderClient();

          hms_location.Location hwLocation =
              await locationClient.getLastLocation();
          currentPosition = Position(
            latitude: hwLocation.latitude!,
            longitude: hwLocation.longitude!,
            timestamp: DateTime.now(),
            accuracy: hwLocation.horizontalAccuracyMeters ?? 0.0,
            altitude: hwLocation.altitude ?? 0.0,
            heading: 0.0,
            speed: hwLocation.speed ?? 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        } catch (e) {
          log('HMS Location error: $e',
              name: LocationHelper.instance.toString());
        }
      }

      if (!useHuaweiLocation || currentPosition == null) {
        currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: Platform.isAndroid
              ? AndroidSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 1000,
                  forceLocationManager: useHuaweiLocation,
                  timeLimit: const Duration(seconds: 30),
                )
              : const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 1000,
                  timeLimit: Duration(seconds: 30),
                ),
        );
      }

      try {
        if (Platform.isAndroid || Platform.isIOS) {
          await _getLocationForMobile(currentPosition, useHuaweiLocation);
          GetStorage().write(ACTIVE_LOCATION, true);
          GeneralController.instance.state.activeLocation.value = true;
        } else {
          await _getLocationForDesktop(currentPosition);
          GetStorage().write(ACTIVE_LOCATION, true);
          GeneralController.instance.state.activeLocation.value = true;
        }
      } catch (e) {
        GetStorage().write(ACTIVE_LOCATION, false);
        GeneralController.instance.state.activeLocation.value = false;
        log('Error updating location details: $e',
            name: LocationHelper.instance.toString());
      }
    }
  }

  Future<void> _getLocationForMobile(
      Position currentPosition, bool useHuaweiLocation) async {
    List<Placemark> placemarks = [];
    String? city;
    String? country;

    if (useHuaweiLocation) {
      try {
        // TODO: Replace with actual Huawei Site Kit reverse geocoding implementation
        // For now, using a placeholder or a web-based geocoding service if available
        // Example: Using Nominatim for Huawei devices without GMS for reverse geocoding
        await NominatimGeocoding.init();
        Coordinate coordinate = Coordinate(
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude);
        Geocoding geocoding =
            await NominatimGeocoding.to.reverseGeoCoding(coordinate);
        city = geocoding.address.city;
        country = geocoding.address.country;
      } catch (e) {
        log('HMS Site Kit reverse geocoding error: $e');
        // Fallback to geocoding package if HMS Site Kit fails or is not implemented yet
        try {
          placemarks = await placemarkFromCoordinates(
            currentPosition.latitude,
            currentPosition.longitude,
          );
        } catch (e) {
          log('error: $e');
        }
      }
    } else {
      try {
        placemarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        );
      } catch (e) {
        log('error: $e');
      }
    }

    if (city != null && country != null) {
      Location().updateLocation(
        city: city,
        country: country,
        position: currentPosition,
      );
    } else if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      Location().updateLocation(
        city: placemark.locality ?? 'UNKNOWN',
        country: placemark.country ?? 'UNKNOWN',
        position: currentPosition,
      );
    }
  }

  Future<void> _getLocationForDesktop(Position currentPosition) async {
    await NominatimGeocoding.init();
    Coordinate coordinate = Coordinate(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude);
    Geocoding geocoding =
        await NominatimGeocoding.to.reverseGeoCoding(coordinate);
    Location().updateLocation(
      city: geocoding.address.city,
      country: geocoding.address.country,
      position: currentPosition,
    );
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// the [openAppSettings] and the [openLocationSettings] are required due to
  /// package documentation (https://pub.dev/packages/geolocator#settings)
  /// Opens the application settings.
  Future<void> get openAppSettings async => await Geolocator.openAppSettings();

  Future<bool> get isAppSettingsOpens async =>
      await Geolocator.openAppSettings();

  /// Enable Location (gps) service
  Future<bool> get isLocationSettingsOpens async =>
      await Geolocator.openLocationSettings();

  Future<void> get openLocationSettings async =>
      await Geolocator.openLocationSettings();

  LatLng? _currentLocation;

  LatLng get currentLocation {
    final storedLocation = GetStorage().read(CURRENT_LOCATION);
    if (storedLocation != null) {
      return LatLng(storedLocation['latitude'], storedLocation['longitude']);
    } else {
      return _currentLocation!;
    }
  }

  set currentLocation(LatLng value) {
    GetStorage().write(CURRENT_LOCATION,
        {'latitude': value.latitude, 'longitude': value.longitude});
    _currentLocation = value;
  }

  Future<Position?> get fetchCurrentPosition async {
    log('Starting to fetch location...', name: 'Background service');

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      log('Location services are disabled.', name: 'Background service');
      return null; // Return null when location services are disabled
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log('Location permissions are denied.', name: 'Background service');
      return null; // Return null when permissions are denied
    }

    bool? isGoogle = await GoogleHuaweiAvailability.isGoogleServiceAvailable;
    bool? isHuawei = await GoogleHuaweiAvailability.isHuaweiServiceAvailable;
    final bool useHuaweiLocation =
        Platform.isAndroid && (isHuawei == true) && (isGoogle != true);

    Position? currentPosition;

    if (useHuaweiLocation) {
      try {
        hms_location.FusedLocationProviderClient locationClient =
            hms_location.FusedLocationProviderClient();

        hms_location.Location hwLocation =
            await locationClient.getLastLocation();
        currentPosition = Position(
          latitude: hwLocation.latitude!,
          longitude: hwLocation.longitude!,
          timestamp: DateTime.now(),
          accuracy: hwLocation.horizontalAccuracyMeters ?? 0.0,
          altitude: hwLocation.altitude ?? 0.0,
          heading: 0.0,
          speed: hwLocation.speed ?? 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } catch (e) {
        log('HMS Location error: $e', name: 'Background service');
      }
    }

    if (!useHuaweiLocation || currentPosition == null) {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isAndroid
            ? AndroidSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
                forceLocationManager: useHuaweiLocation,
                timeLimit: const Duration(seconds: 30),
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
                timeLimit: Duration(seconds: 30),
              ),
      );
    }

    log('Fetched current position: (${currentPosition.latitude}, ${currentPosition.longitude})',
        name: 'Background service');

    return currentPosition;
  }
}
