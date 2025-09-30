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
      log('Error checking location permission: $e', name: 'LocationHelper');
      return false;
    }
  }

  /// Request Huawei Location Kit permissions
  Future<void> _requestHuaweiLocationPermissions() async {
    try {
      // For Huawei devices, we rely on the regular Android permissions
      // which are already handled by the Geolocator package
      log('Huawei location permissions checked via Geolocator',
          name: 'LocationHelper');
    } catch (e) {
      log('Error with Huawei location permissions: $e', name: 'LocationHelper');
      throw LocationException('Failed to verify Huawei location permissions.');
    }
  }

  Future<void> getPositionDetails() async {
    // Check if HMS is actually available and installed
    bool isHMSAvailable = await HuaweiLocationHelper.instance._isHMSAvailable();

    bool useHuaweiLocation = Platform.isAndroid && isHMSAvailable;

    if (await Geolocator.isLocationServiceEnabled()) {
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    }

    if (await checkPermission()) {
      Position? currentPosition;

      if (useHuaweiLocation) {
        try {
          log('Attempting to use Huawei Location Kit', name: 'LocationHelper');

          // Request Huawei location permissions first
          await _requestHuaweiLocationPermissions();

          hms_location.FusedLocationProviderClient locationClient =
              hms_location.FusedLocationProviderClient();

          hms_location.Location hwLocation =
              await locationClient.getLastLocation();

          if (hwLocation.latitude != null && hwLocation.longitude != null) {
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
            log('Successfully obtained position from Huawei Location Kit',
                name: 'LocationHelper');
          } else {
            log('Huawei Location Kit returned null coordinates, falling back to Geolocator',
                name: 'LocationHelper');
          }
        } catch (e) {
          log('HMS Location error (falling back to Geolocator): $e',
              name: 'LocationHelper');
          // Force fallback to Geolocator
          useHuaweiLocation = false;
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
        log('Error updating location details: $e', name: 'LocationHelper');
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
        // Use Huawei Site Kit for reverse geocoding
        final searchService = await hms_site.SearchService.create(
          apiKey:
              'DgEDAOWzkAh3lV1XyJPMbxrS3TO7CdkpnVN6Lu5jvKRljqjVY7exQlLNZoSNkmRpWogb2+vhf5vNr20LV+4LvlQbtAhXqCOiYAfGYg==', // Using API key from agconnect-services.json
        );

        // Create a nearby search request to find places near the current location
        final nearbySearchRequest = hms_site.NearbySearchRequest(
          location: hms_site.Coordinate(
            lat: currentPosition.latitude,
            lng: currentPosition.longitude,
          ),
          radius: 100, // Search within 100 meters
          language: 'en',
        );

        final nearbySearchResponse =
            await searchService.nearbySearch(nearbySearchRequest);

        if (nearbySearchResponse.sites?.isNotEmpty == true) {
          final site = nearbySearchResponse.sites!.first;
          final addressDetail = site?.address;
          if (addressDetail != null) {
            city = addressDetail.locality ??
                addressDetail.subAdminArea ??
                addressDetail.adminArea;
            country = addressDetail.country;
          }

          log('Huawei Site Kit found: $city, $country', name: 'LocationHelper');
        }
      } catch (e) {
        log('Failed to get location from Huawei Site Kit: $e',
            name: 'LocationHelper');
        // Fallback to Google geocoding if available
        useHuaweiLocation = false;
      }
    }

    if (!useHuaweiLocation) {
      try {
        placemarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        );
      } catch (e) {
        log('Failed to get placemark from coordinates: $e',
            name: 'LocationHelper');
      }
    }

    if (city != null && country != null) {
      Location().updateLocation(
        city: city,
        country: country,
        position: currentPosition,
      );
    } else if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      final placeCity = placemark.locality ??
          placemark.subAdministrativeArea ??
          placemark.administrativeArea ??
          'Unknown';
      final placeCountry = placemark.country ?? 'Unknown';
      Location().updateLocation(
        city: placeCity,
        country: placeCountry,
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

    // Check if HMS is actually available and installed
    bool isHMSAvailable = await HuaweiLocationHelper.instance._isHMSAvailable();

    bool useHuaweiLocation = Platform.isAndroid && isHMSAvailable;

    Position? currentPosition;

    if (useHuaweiLocation) {
      try {
        log('Attempting to use Huawei Location Kit for position',
            name: 'Background service');
        hms_location.FusedLocationProviderClient locationClient =
            hms_location.FusedLocationProviderClient();

        hms_location.Location hwLocation =
            await locationClient.getLastLocation();

        if (hwLocation.latitude != null && hwLocation.longitude != null) {
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
          log('Huawei Location Kit position obtained: (${currentPosition.latitude}, ${currentPosition.longitude})',
              name: 'Background service');
        } else {
          log('Huawei Location Kit returned null coordinates, falling back to Geolocator',
              name: 'Background service');
        }
      } catch (e) {
        log('HMS Location error (falling back to Geolocator): $e',
            name: 'Background service');
        // Force fallback to Geolocator
        useHuaweiLocation = false;
      }
    }

    if (!useHuaweiLocation || currentPosition == null) {
      log('Using Geolocator for position', name: 'Background service');
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

  /// Request location updates using Huawei Location Kit or Geolocator
  /// This method provides continuous location updates
  Future<void> requestLocationUpdates({
    required Function(Position) onLocationUpdate,
    Duration? interval,
  }) async {
    // Check if HMS is actually available and installed
    bool isHMSAvailable = await HuaweiLocationHelper.instance._isHMSAvailable();

    bool useHuaweiLocation = Platform.isAndroid && isHMSAvailable;

    if (!(await checkPermission())) {
      throw LocationException('Location permissions not granted');
    }

    if (useHuaweiLocation) {
      try {
        log('Attempting to set up Huawei Location updates',
            name: 'LocationHelper');

        hms_location.FusedLocationProviderClient locationClient =
            hms_location.FusedLocationProviderClient();

        // For Huawei, we need to periodically check for location updates
        // since direct streaming is not supported in the same way
        Timer.periodic(
            Duration(milliseconds: interval?.inMilliseconds ?? 10000),
            (timer) async {
          try {
            hms_location.Location hwLocation =
                await locationClient.getLastLocation();
            if (hwLocation.latitude != null && hwLocation.longitude != null) {
              Position position = Position(
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
              onLocationUpdate(position);
            }
          } catch (e) {
            log('Error getting Huawei location update: $e',
                name: 'LocationHelper');
          }
        });

        log('Huawei location updates setup successfully',
            name: 'LocationHelper');
      } catch (e) {
        log('Error setting up Huawei location updates (falling back to Geolocator): $e',
            name: 'LocationHelper');
        // Force fallback to Geolocator
        useHuaweiLocation = false;
        _requestGeolocatorUpdates(onLocationUpdate, interval);
      }
    } else {
      _requestGeolocatorUpdates(onLocationUpdate, interval);
    }
  }

  /// Fallback method using Geolocator for location updates
  void _requestGeolocatorUpdates(
    Function(Position) onLocationUpdate,
    Duration? interval,
  ) {
    log('Setting up Geolocator location updates', name: 'LocationHelper');

    Geolocator.getPositionStream(
      locationSettings: Platform.isAndroid
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 100,
              timeLimit: const Duration(seconds: 30),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 100,
              timeLimit: Duration(seconds: 30),
            ),
    ).listen((Position position) {
      onLocationUpdate(position);
    });
  }
}
