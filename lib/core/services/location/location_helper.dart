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
    if (await Geolocator.isLocationServiceEnabled()) {
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    }
    if (await checkPermission()) {
      // إعدادات الموقع المحسنة - Enhanced location settings
      var currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter:
              1000, // تحديث الموقع كل 1000 متر - Update location every 1000 meters
          timeLimit: Duration(
              seconds:
                  30), // حد زمني للحصول على الموقع - Time limit for location fetch
        ),
      );
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          await _getLocationForMobile(currentPosition);
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

  Future<void> _getLocationForMobile(Position currentPosition) async {
    List<Placemark> placemarks = [];
    try {
      placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );
    } catch (e) {
      log('error: $e');
    }
    if (placemarks.isNotEmpty) {
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

    // إعدادات الموقع المحسنة لكل منصة - Enhanced location settings for each platform
    Position currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter:
            10, // تحديث الموقع كل 10 متر - Update location every 10 meters
        timeLimit: Duration(
            seconds:
                30), // حد زمني للحصول على الموقع - Time limit for location fetch
      ),
    );
    log('Fetched current position: (${currentPosition.latitude}, ${currentPosition.longitude})',
        name: 'Background service');

    return currentPosition; // Return the fetched position
  }
  //
  // Future<void> getCityAndCountry(
  //     double latitude, double longitude, String appLanguage) async {
  //   try {
  //     // استخدام اللغة المختارة في التطبيق
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       latitude,
  //       longitude,
  //       localeIdentifier: appLanguage, // تمرير اللغة المختارة
  //     );
  //
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks.first;
  //       String city = place.locality ?? ''; // اسم المدينة
  //       String country = place.country ?? ''; // اسم الدولة
  //
  //       log('City: $city, Country: $country');
  //     } else {
  //       log('No placemarks found');
  //     }
  //   } catch (e) {
  //     log('Error: $e');
  //   }
  // }
}
