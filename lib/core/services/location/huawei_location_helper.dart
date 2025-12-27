part of 'locations.dart';

class HuaweiLocationHelper {
  HuaweiLocationHelper._privateConstructor();

  static final HuaweiLocationHelper instance =
      HuaweiLocationHelper._privateConstructor();

  /// Check if Huawei Mobile Services (HMS) is available and working
  Future<bool> _isHMSAvailable() async {
    if (!Platform.isAndroid) {
      log('Not an Android device, HMS not available', name: 'LocationHelper');
      return false;
    }

    try {
      bool? isGoogle = await GoogleHuaweiAvailability.isGoogleServiceAvailable;
      bool? isHuawei = await GoogleHuaweiAvailability.isHuaweiServiceAvailable;

      log('Device services check - Google: $isGoogle, Huawei: $isHuawei',
          name: 'LocationHelper');

      // Use HMS if Huawei services are available
      if (isHuawei == true) {
        log('✅ HMS is available on this device', name: 'LocationHelper');
        return true;
      } else {
        log('❌ HMS not available: isHuawei=$isHuawei, isGoogle=$isGoogle',
            name: 'LocationHelper');
        return false;
      }
    } catch (e) {
      log('❌ Error checking HMS availability: $e', name: 'LocationHelper');
      return false;
    }
  }

  /// Check if this is a Huawei device that should use manual location selection
  Future<bool> isHuaweiDevice() async {
    return await _isHMSAvailable();
  }

  /// Search for cities using Huawei Site Kit with fallback to mock data
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (!await _isHMSAvailable()) {
      log('HMS not available, using offline city database',
          name: 'LocationHelper');
      return await _searchCitiesWithNominatim(query);
    }

    try {
      // Try to initialize SearchService without API key first (uses agconnect-services.json)
      hms_site.SearchService? searchService;

      try {
        // Attempt to create SearchService with API key from agconnect-services.json
        searchService = await hms_site.SearchService.create(
            apiKey:
                'DgEDAOWzkAh3lV1XyJPMbxrS3TO7CdkpnVN6Lu5jvKRljqjVY7exQlLNZoSNkmRpWogb2+vhf5vNr20LV+4LvlQbtAhXqCOiYAfGYg==');
      } catch (e1) {
        log('Failed to create SearchService: $e1', name: 'LocationHelper');
        log('Falling back to offline city database', name: 'LocationHelper');
        return await _searchCitiesWithNominatim(query);
      }

      final textSearchRequest = hms_site.TextSearchRequest(
        query: query,
        location: hms_site.Coordinate(lat: 21.4359348, lng: 39.681737),
        radius: 50000000, // Large radius for global search
        hwPoiType: hms_site.HwLocationType.GEOCODE,
        language: Get.locale?.languageCode ?? 'ar',
        pageSize: 20,
      );

      final textSearchResponse =
          await searchService.textSearch(textSearchRequest);

      List<Map<String, dynamic>> cities = [];
      if (textSearchResponse.sites?.isNotEmpty == true) {
        for (var site in textSearchResponse.sites!) {
          if (site?.name?.isNotEmpty == true && site?.location != null) {
            cities.add({
              'name': site!.name!,
              'country': site.address?.country ?? '',
              'latitude': site.location!.lat,
              'longitude': site.location!.lng,
              'fullAddress': site.formatAddress ?? site.name!,
            });
          }
        }
      }

      if (cities.isEmpty) {
        log('No results from HMS, trying Nominatim', name: 'LocationHelper');
        return await _searchCitiesWithNominatim(query);
      }

      return cities;
    } catch (e) {
      log('Error searching cities with Huawei Site Kit: $e',
          name: 'LocationHelper');

      // Check for specific HMS error codes
      if (e.toString().contains('010002')) {
        log('HMS authentication error (010002) - API key or keystore issue. Using mock data.',
            name: 'LocationHelper');
      } else if (e.toString().contains('010001')) {
        log('HMS service not available (010001). Using mock data.',
            name: 'LocationHelper');
      }

      // Always fallback to Nominatim instead of throwing error
      return await _searchCitiesWithNominatim(query);
    }
  }

  /// Search cities using Huawei Site Kit when HMS is available, or Nominatim as fallback
  Future<List<Map<String, dynamic>>> _searchCitiesWithNominatim(
      String query) async {
    if (query.trim().isEmpty) return _getFallbackCities();

    try {
      // First try to use Huawei Site Kit for city search
      if (await _isHMSAvailable()) {
        log('Using Huawei Site Kit for city search', name: 'LocationHelper');
        return await _searchCitiesWithHuaweiMap(query);
      }

      log('HMS not available, using Nominatim fallback',
          name: 'LocationHelper');
      return await _searchCitiesWithNominatimAPI(query);
    } catch (e) {
      log('Error in city search: $e', name: 'LocationHelper');
      return _getFallbackCities();
    }
  }

  /// Search cities using Huawei Map Site Kit
  Future<List<Map<String, dynamic>>> _searchCitiesWithHuaweiMap(
      String query) async {
    try {
      hms_site.SearchService? searchService;

      try {
        searchService = await hms_site.SearchService.create(
            apiKey:
                'DgEDAOWzkAh3lV1XyJPMbxrS3TO7CdkpnVN6Lu5jvKRljqjVY7exQlLNZoSNkmRpWogb2+vhf5vNr20LV+4LvlQbtAhXqCOiYAfGYg==');
      } catch (e) {
        log('Failed to create Huawei SearchService: $e',
            name: 'LocationHelper');
        return await _searchCitiesWithNominatimAPI(query);
      }

      // Create text search request for cities
      final textSearchRequest = hms_site.TextSearchRequest(
        query: query,
        location: hms_site.Coordinate(
            lat: 24.7136, lng: 46.6753), // Center around Riyadh
        radius: 100000000, // Very large radius for global search
        hwPoiType: hms_site.HwLocationType.GEOCODE, // Search for places/cities
        language: Get.locale?.languageCode ?? 'ar',
        pageSize: 20,
      );

      final textSearchResponse =
          await searchService.textSearch(textSearchRequest);

      List<Map<String, dynamic>> cities = [];
      if (textSearchResponse.sites?.isNotEmpty == true) {
        for (var site in textSearchResponse.sites!) {
          if (site?.name?.isNotEmpty == true && site?.location != null) {
            String cityName = site!.name!;
            String country = site.address?.country ?? '';
            String adminArea = site.address?.adminArea ?? '';

            // Filter to show only city-level results
            if (_isCityResult(site)) {
              cities.add({
                'name': cityName,
                'country': country.isNotEmpty ? country : adminArea,
                'latitude': site.location!.lat,
                'longitude': site.location!.lng,
                'fullAddress': _buildFullAddress(cityName, country, adminArea),
              });
            }
          }
        }
      }

      if (cities.isNotEmpty) {
        log('Found ${cities.length} cities from Huawei Map: $cities',
            name: 'LocationHelper');
        return cities;
      } else {
        log('No cities found with Huawei Map, falling back to Nominatim',
            name: 'LocationHelper');
        return await _searchCitiesWithNominatimAPI(query);
      }
    } catch (e) {
      log('Error searching cities with Huawei Map: $e', name: 'LocationHelper');
      return await _searchCitiesWithNominatimAPI(query);
    }
  }

  /// Check if the site result represents a city
  bool _isCityResult(hms_site.Site site) {
    final poiType = site.poi?.poiTypes?.first;
    final name = site.name?.toLowerCase() ?? '';
    final adminArea = site.address?.adminArea?.toLowerCase() ?? '';
    final locality = site.address?.locality?.toLowerCase() ?? '';

    // Consider it a city if it has administrative area information
    // or if the POI type suggests it's a geographical location
    return adminArea.isNotEmpty ||
        locality.isNotEmpty ||
        poiType != null ||
        name.contains('city') ||
        name.contains('مدينة') ||
        name.contains('محافظة');
  }

  /// Build full address string
  String _buildFullAddress(String cityName, String country, String adminArea) {
    List<String> parts = [cityName];

    if (country.isNotEmpty && country != cityName) {
      parts.add(country);
    } else if (adminArea.isNotEmpty && adminArea != cityName) {
      parts.add(adminArea);
    }

    return parts.join('، ');
  }

  /// Search cities using Nominatim API with proper User-Agent
  Future<List<Map<String, dynamic>>> _searchCitiesWithNominatimAPI(
      String query) async {
    try {
      log('Attempting Nominatim search for: $query', name: 'LocationHelper');

      final locale = _getNominatimLocale();

      // استخدام Dio مع User-Agent صحيح (مطلوب من Nominatim)
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '10',
          'accept-language': locale.name.toLowerCase(),
        },
        options: Options(
          headers: {
            'User-Agent': 'Aqim/1.0 (contact: haozo89@gmail.com)',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> cities = [];

        for (var item in response.data) {
          final address = item['address'] ?? {};
          String cityName = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['state_district'] ??
              address['county'] ??
              item['display_name']?.toString().split(',').first ??
              '';

          String country = address['country'] ?? '';

          if (cityName.isNotEmpty &&
              item['lat'] != null &&
              item['lon'] != null) {
            cities.add({
              'name': cityName,
              'country': country,
              'latitude': double.tryParse(item['lat'].toString()) ?? 0.0,
              'longitude': double.tryParse(item['lon'].toString()) ?? 0.0,
              'fullAddress':
                  cityName + (country.isNotEmpty ? '، $country' : ''),
            });
          }
        }

        if (cities.isNotEmpty) {
          log('Found ${cities.length} cities from Nominatim',
              name: 'LocationHelper');
          return cities.take(8).toList(); // Limit to 8 results
        }
      }
    } catch (e) {
      log('Error with Nominatim search: $e', name: 'LocationHelper');
    }

    log('All search methods failed, returning fallback cities',
        name: 'LocationHelper');
    return _getFallbackCities();
  }

  /// تحويل لغة التطبيق إلى Locale الخاص بـ Nominatim
  Locale _getNominatimLocale() {
    switch (Get.locale?.languageCode) {
      case 'ar':
        return Locale.AR;
      case 'en':
        return Locale.EN;
      case 'tr':
        return Locale.TR;
      case 'ur':
        return Locale.UR;
      case 'id':
        return Locale.ID;
      case 'ms':
        return Locale.MS;
      case 'bn':
        return Locale.BN;
      case 'es':
        return Locale.ES;
      case 'ku':
        return Locale.KU;
      case 'so':
        return Locale.SO;
      default:
        return Locale.EN;
    }
  }

  Future<void> setManualLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Create a Position object (من geolocator)
      final position = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // استدعاء العنوان
      final location = await getAddressFromLatLng(latitude, longitude);

      final address = location?['address'] ?? {};
      final cityName = address['city'] ??
          address['town'] ??
          address['village'] ??
          'غير معروف';
      final country = address['country'] ?? 'غير معروف';

      // Update location
      Location().updateLocation(
        city: cityName,
        country: country,
        position: position,
      );

      // Update storage
      GetStorage().write(ACTIVE_LOCATION, true);
      GeneralController.instance.state.activeLocation.value = true;

      log('Manual location set: $cityName, $country ($latitude, $longitude)',
          name: 'LocationHelper');
    } catch (e) {
      log('Error setting manual location: $e', name: 'LocationHelper');
      throw LocationException('Failed to set manual location: $e');
    }
  }

// ==== دالة Nominatim =====
  Future<Map<String, dynamic>?> getAddressFromLatLng(
      double lat, double lon) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lon,
          'accept-language': 'en',
        },
        options: Options(
          headers: {
            'User-Agent': 'Aqim/1.0 (contact: haozo89@gmail.com)',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] ?? {};
        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            'غير معروف';
        final country = address['country'] ?? 'غير معروف';

        log('📍 المدينة: $city');
        log('🌍 الدولة: $country');
        return data;
      } else {
        log('⚠️ فشل الطلب: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ خطأ: $e');
      return null;
    }
  }

  /// Get most popular cities as final fallback
  List<Map<String, dynamic>> _getFallbackCities() {
    return [
      {
        'name': 'الرياض',
        'country': 'السعودية',
        'latitude': 24.7136,
        'longitude': 46.6753,
        'fullAddress': 'الرياض، السعودية'
      },
      {
        'name': 'مكة المكرمة',
        'country': 'السعودية',
        'latitude': 21.3891,
        'longitude': 39.8579,
        'fullAddress': 'مكة المكرمة، السعودية'
      },
      {
        'name': 'المدينة المنورة',
        'country': 'السعودية',
        'latitude': 24.5247,
        'longitude': 39.5692,
        'fullAddress': 'المدينة المنورة، السعودية'
      },
      {
        'name': 'القاهرة',
        'country': 'مصر',
        'latitude': 30.0444,
        'longitude': 31.2357,
        'fullAddress': 'القاهرة، مصر'
      },
      {
        'name': 'دبي',
        'country': 'الإمارات',
        'latitude': 25.2048,
        'longitude': 55.2708,
        'fullAddress': 'دبي، الإمارات'
      },
      {
        'name': 'الكويت',
        'country': 'الكويت',
        'latitude': 29.3117,
        'longitude': 47.4818,
        'fullAddress': 'الكويت، الكويت'
      },
      {
        'name': 'الدوحة',
        'country': 'قطر',
        'latitude': 25.2854,
        'longitude': 51.5310,
        'fullAddress': 'الدوحة، قطر'
      },
      {
        'name': 'بيروت',
        'country': 'لبنان',
        'latitude': 33.8938,
        'longitude': 35.5018,
        'fullAddress': 'بيروت، لبنان'
      },
    ];
  }
}
