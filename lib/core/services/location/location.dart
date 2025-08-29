part of 'locations.dart';

class Location {
  static final Location instance = Location._();
  String _city = '';
  String _country = '';
  Position? _position;
  static final GetStorage _storage = GetStorage();

  factory Location() {
    return instance;
  }

  Location._();

  /// تحديث الموقع وحفظه في التخزين
  /// Update location and save to storage
  void updateLocation({
    required String city,
    required String country,
    required Position position,
  }) {
    _city = city;
    _country = country;
    _position = position;

    // حفظ البيانات في التخزين
    // Save data to storage
    _storage.write(CURRENT_LOCATION, {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'city': city,
      'country': country,
      'timestamp': DateTime.now().toIso8601String(),
    });

    log('Location updated: $city, $country (${position.latitude}, ${position.longitude})',
        name: 'Location');
  }

  /// استرداد الموقع من التخزين عند بدء التطبيق
  /// Restore location from storage on app start
  void restoreFromStorage() {
    try {
      final storedLocation = _storage.read(CURRENT_LOCATION);
      if (storedLocation is Map<String, dynamic>) {
        _city = storedLocation['city'] ?? '';
        _country = storedLocation['country'] ?? '';

        // استرداد Position إذا كانت البيانات متوفرة
        // Restore Position if data is available
        final lat = storedLocation['latitude'];
        final lng = storedLocation['longitude'];
        if (lat != null && lng != null) {
          _position = Position(
            latitude: lat.toDouble(),
            longitude: lng.toDouble(),
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }
    } catch (e) {
      log('Error restoring location from storage: $e', name: 'Location');
    }
  }

  String get city => _city;
  String get country => _country;
  Position? get position => _position;
}
