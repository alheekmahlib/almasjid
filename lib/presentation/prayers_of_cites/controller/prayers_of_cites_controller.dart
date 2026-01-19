part of '../cites.dart';

class PrayersOfCitesController extends GetxController {
  static PrayersOfCitesController get instance =>
      GetInstance().putOrFind(() => PrayersOfCitesController());

  final SavedCitiesStorage _storage = SavedCitiesStorage();
  final CityPrayerTimesService _service = CityPrayerTimesService();

  final Map<String, CityPrayerTimesResult> _cache =
      <String, CityPrayerTimesResult>{};

  List<SavedCity> cities = <SavedCity>[];
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading = true;
    update(['cities']);

    cities = _storage.readAll();

    isLoading = false;
    update(['cities']);

    // Warm cache in background (non-blocking)
    for (final city in cities) {
      _prefetch(city);
    }
  }

  Future<void> addFromSearchResult(Map<String, dynamic> city) async {
    final double lat = (city['latitude'] as num).toDouble();
    final double lon = (city['longitude'] as num).toDouble();

    final String name = (city['name'] as String?)?.trim() ?? '';
    final String countryDisplay = (city['country'] as String?)?.trim() ?? '';
    final String? fullAddress = (city['fullAddress'] as String?)?.trim();

    String countryRaw = (city['countryRaw'] as String?)?.trim() ?? '';
    if (countryRaw.isEmpty) {
      try {
        final data = await HuaweiLocationHelper.instance.getAddressFromLatLng(
          lat,
          lon,
          languageCode: 'en',
        );
        final address = (data?['address'] as Map?) ?? const {};
        countryRaw = (address['country'] as String?)?.trim() ?? '';
      } catch (_) {
        countryRaw = '';
      }
    }

    final saved = SavedCity(
      id: SavedCity.buildId(lat, lon),
      name: name,
      countryDisplay: countryDisplay,
      countryRaw: countryRaw.isNotEmpty ? countryRaw : countryDisplay,
      latitude: lat,
      longitude: lon,
      sortOrder: cities.length,
      fullAddress: fullAddress,
    );

    cities = await _storage.add(saved);
    update(['cities']);

    _prefetch(saved);
  }

  Future<void> removeCity(String id) async {
    cities = await _storage.removeById(id);
    _cache.remove(id);
    update(['cities']);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    cities = await _storage.reorder(oldIndex, newIndex);
    update(['cities']);
  }

  CityPrayerTimesResult? cachedFor(SavedCity city) {
    final cached = _cache[city.id];
    if (cached == null) return null;

    try {
      final tz.Location loc = tz.getLocation(cached.timeZoneId);
      final tz.TZDateTime cityNow = tz.TZDateTime.from(DateTime.now(), loc);
      final DateTime dayKey =
          DateTime.utc(cityNow.year, cityNow.month, cityNow.day);
      return cached.day == dayKey ? cached : null;
    } catch (_) {
      final today = DateTime.now();
      final fallback = DateTime.utc(today.year, today.month, today.day);
      return cached.day == fallback ? cached : null;
    }
  }

  Future<void> _prefetch(SavedCity city) async {
    if (cachedFor(city) != null) return;

    try {
      final result = await _service.getForCity(city);
      _cache[city.id] = result;
      update(['cities']);
    } catch (e) {
      log('Failed to prefetch city prayer times: $e');
    }
  }

  DateTime? getPrayerDateTimeFromList(CityPrayerTimesResult data, int index) {
    final dynamic raw = data.prayerList[index]['dateTime'];
    return raw is DateTime ? raw : null;
  }

  Duration cityDurationLeftForIndex(CityPrayerTimesResult data, int index) {
    try {
      final DateTime? prayerTime = getPrayerDateTimeFromList(data, index);
      if (prayerTime == null) return Duration.zero;

      final tz.Location loc = tz.getLocation(data.timeZoneId);
      final tz.TZDateTime now = tz.TZDateTime.now(loc);

      tz.TZDateTime target = tz.TZDateTime(
        loc,
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
        prayerTime.second,
      );

      if (!target.isAfter(now)) {
        target = target.add(const Duration(days: 1));
      }

      final Duration diff = target.difference(now);
      return diff.isNegative ? Duration.zero : diff;
    } catch (_) {
      return Duration.zero;
    }
  }

  double cityTimeLeftPercentForIndex(CityPrayerTimesResult data, int index) {
    try {
      // النسبة يجب أن تكون ضمن "الفترة" بين الصلاة السابقة والصلاة الحالية (المستهدفة).
      // هذا يجعل الشريط منطقيًا عند بقاء 44 دقيقة مثلًا (لن يظهر مكتملًا).

      final int len = data.prayerList.length;
      if (len == 0) return 0.0;

      final DateTime? targetRaw = getPrayerDateTimeFromList(data, index);
      final int prevIndex = (index - 1) < 0 ? (len - 1) : (index - 1);
      final DateTime? prevRaw = getPrayerDateTimeFromList(data, prevIndex);
      if (targetRaw == null || prevRaw == null) return 0.0;

      final tz.Location loc = tz.getLocation(data.timeZoneId);
      final tz.TZDateTime now = tz.TZDateTime.now(loc);

      // نبني "موعد الصلاة الهدف القادم" بالنسبة للحظة الآن في المدينة
      tz.TZDateTime target = tz.TZDateTime(
        loc,
        now.year,
        now.month,
        now.day,
        targetRaw.hour,
        targetRaw.minute,
        targetRaw.second,
      );
      if (!target.isAfter(now)) {
        target = target.add(const Duration(days: 1));
      }

      // نبني "موعد الصلاة السابقة" بالنسبة ليوم الهدف
      tz.TZDateTime prev = tz.TZDateTime(
        loc,
        target.year,
        target.month,
        target.day,
        prevRaw.hour,
        prevRaw.minute,
        prevRaw.second,
      );
      // إذا كان وقت السابقة يساوي/يتجاوز الهدف (مثل عشاء -> فجر)، السابقة تكون في اليوم السابق
      if (!prev.isBefore(target)) {
        prev = prev.subtract(const Duration(days: 1));
      }

      final int totalMinutes = target.difference(prev).inMinutes;
      if (totalMinutes <= 0) return 0.0;

      int elapsedMinutes = now.difference(prev).inMinutes;
      if (elapsedMinutes < 0) elapsedMinutes = 0;
      if (elapsedMinutes > totalMinutes) elapsedMinutes = totalMinutes;

      return ((elapsedMinutes / totalMinutes) * 100).clamp(0, 100).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  /// ترجمة اسم المدينة/الدولة للعرض فقط حسب لغة التطبيق الحالية.
  /// لا تُغيّر بيانات المدينة المخزنة ولا تؤثر على الحسابات.
  Future<({String city, String country})> localizedCityDisplay(
    SavedCity city, {
    String? languageCode,
  }) async {
    final String lang =
        (languageCode ?? Get.locale?.languageCode ?? 'ar').toLowerCase();

    try {
      final result = await NominatimReverseGeocodingService.instance.reverse(
        latitude: city.latitude,
        longitude: city.longitude,
        languageCode: lang,
      );

      final String resolvedCity =
          result.city.trim().isNotEmpty && result.city != 'Unknown'
              ? result.city.trim()
              : city.name;
      final String resolvedCountry =
          result.country.trim().isNotEmpty && result.country != 'Unknown'
              ? result.country.trim()
              : city.countryDisplay;

      return (city: resolvedCity, country: resolvedCountry);
    } catch (_) {
      return (city: city.name, country: city.countryDisplay);
    }
  }
}
