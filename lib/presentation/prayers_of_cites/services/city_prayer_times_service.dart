part of '../cites.dart';

class CityPrayerTimesResult {
  final DateTime day;
  final String timeZoneId;
  final PrayerTimes prayerTimes;
  final SunnahTimes sunnahTimes;
  final CalculationParameters params;
  final List<Map<String, dynamic>> prayerList;
  final int currentIndex;

  const CityPrayerTimesResult({
    required this.day,
    required this.timeZoneId,
    required this.prayerTimes,
    required this.sunnahTimes,
    required this.params,
    required this.prayerList,
    required this.currentIndex,
  });
}

class CityPrayerTimesService {
  static final Map<String, String> _timeZoneCache = <String, String>{};

  Future<CityPrayerTimesResult> getForCity(
    SavedCity city, {
    DateTime? date,
  }) async {
    final String timeZoneId = await _resolveTimeZoneId(city: city, date: date);
    final tz.Location cityLocation = _safeGetLocation(timeZoneId);

    final DateTime instant = date ?? DateTime.now();
    final tz.TZDateTime cityNow = tz.TZDateTime.from(instant, cityLocation);
    final DateTime dayKey =
        DateTime.utc(cityNow.year, cityNow.month, cityNow.day);
    final DateTime dayForCalc =
        DateTime(cityNow.year, cityNow.month, cityNow.day);

    final CalculationParameters params = await _resolveParams(city);
    _applyUserSettings(params);

    final coordinates = Coordinates(city.latitude, city.longitude);
    final dateComponents = DateComponents.from(dayForCalc);

    final PrayerTimes prayerTimes =
        PrayerTimes(coordinates, dateComponents, params);
    final SunnahTimes sunnahTimes = SunnahTimes(prayerTimes);

    // adhan package يبني أوقاتاً بحسب timezone الجهاز، لذا نعدلها لتكون بحسب timezone المدينة.
    final DateTime fajr = _adjustToCityTime(prayerTimes.fajr, cityLocation);
    final DateTime sunrise =
        _adjustToCityTime(prayerTimes.sunrise, cityLocation);
    final DateTime dhuhr = _adjustToCityTime(prayerTimes.dhuhr, cityLocation);
    final DateTime asr = _adjustToCityTime(prayerTimes.asr, cityLocation);
    final DateTime maghrib =
        _adjustToCityTime(prayerTimes.maghrib, cityLocation);
    final DateTime isha = _adjustToCityTime(prayerTimes.isha, cityLocation);
    final DateTime middleOfTheNight =
        _adjustToCityTime(sunnahTimes.middleOfTheNight, cityLocation);
    final DateTime lastThirdOfTheNight =
        _adjustToCityTime(sunnahTimes.lastThirdOfTheNight, cityLocation);

    final prayerList = _buildPrayerList(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      middleOfTheNight: middleOfTheNight,
      lastThirdOfTheNight: lastThirdOfTheNight,
      params: params,
    );
    final int currentIndex = _currentPrayerIndexFromAdjusted(
      nowInCity: cityNow,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      middleOfTheNight: middleOfTheNight,
      lastThirdOfTheNight: lastThirdOfTheNight,
    );

    return CityPrayerTimesResult(
      day: dayKey,
      timeZoneId: timeZoneId,
      prayerTimes: prayerTimes,
      sunnahTimes: sunnahTimes,
      params: params,
      prayerList: prayerList,
      currentIndex: currentIndex,
    );
  }

  tz.Location _safeGetLocation(String timeZoneId) {
    try {
      return tz.getLocation(timeZoneId);
    } catch (_) {
      return tz.local;
    }
  }

  Future<String> _resolveTimeZoneId({
    required SavedCity city,
    required DateTime? date,
  }) async {
    final cached = _timeZoneCache[city.id];
    if (cached != null && cached.trim().isNotEmpty) return cached;

    try {
      final response = await Dio().get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': city.latitude,
          'longitude': city.longitude,
          // أي قيمة في current تكفي لإرجاع timezone + utc_offset_seconds
          'current': 'temperature_2m',
          'timezone': 'auto',
        },
        options: Options(
          headers: {
            'User-Agent': 'Aqim/1.0 (contact: haozo89@gmail.com)',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final tzId = (data['timezone'] as String?)?.trim();
        if (tzId != null && tzId.isNotEmpty) {
          _timeZoneCache[city.id] = tzId;
          return tzId;
        }
      }
    } catch (_) {
      // ignore
    }

    return tz.local.name;
  }

  DateTime _adjustToCityTime(DateTime time, tz.Location cityLocation) {
    // نعدل الساعة بقيمة الفرق بين offset المدينة و offset الجهاز.
    final Duration deviceOffset = time.timeZoneOffset;

    // نحسب offset المدينة لنفس التاريخ/الساعة (لتفادي مشاكل DST قدر الإمكان)
    final tz.TZDateTime cityWallClock = tz.TZDateTime(
      cityLocation,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
      time.millisecond,
      time.microsecond,
    );
    final Duration cityOffset = cityWallClock.timeZoneOffset;

    final Duration delta = cityOffset - deviceOffset;
    return time.add(delta);
  }

  Future<CalculationParameters> _resolveParams(SavedCity city) async {
    final countryName = city.countryRaw.trim().isNotEmpty
        ? city.countryRaw.trim()
        : city.countryDisplay.trim();

    try {
      return await countryName.getCalculationParameters();
    } catch (_) {
      return CalculationMethod.other.getParameters();
    }
  }

  void _applyUserSettings(CalculationParameters params) {
    final userState = AdhanController.instance.state;

    params.madhab = userState.isHanafi ? Madhab.hanafi : Madhab.shafi;
    params.highLatitudeRule = userState.params.highLatitudeRule;

    params.adjustments.fajr = userState.adjustments.fajr;
    params.adjustments.sunrise = userState.adjustments.sunrise;
    params.adjustments.dhuhr = userState.adjustments.dhuhr;
    params.adjustments.asr = userState.adjustments.asr;
    params.adjustments.maghrib = userState.adjustments.maghrib;
    params.adjustments.isha = userState.adjustments.isha;
  }

  List<Map<String, dynamic>> _buildPrayerList({
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime middleOfTheNight,
    required DateTime lastThirdOfTheNight,
    required CalculationParameters params,
  }) {
    return <Map<String, dynamic>>[
      {
        'title': 'Fajr',
        'time': DateFormatter.formatPrayerTime(fajr),
        'dateTime': fajr,
        'sharedAdjustment': 'ADJUSTMENT_FAJR',
        'icon': SolarIconsBold.moonFog,
        'adjustment': params.adjustments.fajr,
      },
      {
        'title': 'Sunrise',
        'time': DateFormatter.formatPrayerTime(sunrise),
        'dateTime': sunrise,
        'sharedAdjustment': 'ADJUSTMENT_SUNRISE',
        'icon': SolarIconsBold.sunrise,
        'adjustment': params.adjustments.sunrise,
      },
      {
        'title': AdhanController.instance.getFridayDhuhrName,
        'time': DateFormatter.formatPrayerTime(dhuhr),
        'dateTime': dhuhr,
        'sharedAdjustment': 'ADJUSTMENT_DHUHR',
        'icon': SolarIconsBold.sun,
        'adjustment': params.adjustments.dhuhr,
      },
      {
        'title': 'Asr',
        'time': DateFormatter.formatPrayerTime(asr),
        'dateTime': asr,
        'sharedAdjustment': 'ADJUSTMENT_ASR',
        'icon': SolarIconsBold.sun2,
        'adjustment': params.adjustments.asr,
      },
      {
        'title': AdhanController.instance.getMaghribName,
        'time': DateFormatter.formatPrayerTime(maghrib),
        'dateTime': maghrib,
        'sharedAdjustment': 'ADJUSTMENT_MAGHRIB',
        'icon': SolarIconsBold.sunset,
        'adjustment': params.adjustments.maghrib,
      },
      {
        'title': 'Isha',
        'time': DateFormatter.formatPrayerTime(isha),
        'dateTime': isha,
        'sharedAdjustment': 'ADJUSTMENT_ISHA',
        'icon': SolarIconsBold.moon,
        'adjustment': params.adjustments.isha,
      },
      {
        'title': 'middleOfTheNight',
        'time': DateFormatter.formatPrayerTime(middleOfTheNight),
        'dateTime': middleOfTheNight,
        'sharedAdjustment': 'ADJUSTMENT_MIDNIGHT',
        'icon': SolarIconsBold.moonStars,
        'adjustment': 0,
      },
      {
        'title': 'lastThirdOfTheNight',
        'time': DateFormatter.formatPrayerTime(lastThirdOfTheNight),
        'dateTime': lastThirdOfTheNight,
        'sharedAdjustment': 'ADJUSTMENT_THIRD',
        'icon': SolarIconsBold.moonStars,
        'adjustment': 0,
      },
    ];
  }

  int _currentPrayerIndexFromAdjusted({
    required DateTime nowInCity,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime middleOfTheNight,
    required DateTime lastThirdOfTheNight,
  }) {
    try {
      // نحاكي منطق التطبيق الأساسي: المؤشر يمثل "القادم" (0-7)
      // 0=fajr, 1=sunrise, 2=dhuhr, 3=asr, 4=maghrib, 5=isha, 6=midnight, 7=lastThird
      int minutesSinceMidnight(DateTime dt) => (dt.hour * 60) + dt.minute;

      final int nowMin = minutesSinceMidnight(nowInCity);
      final int fajrMin = minutesSinceMidnight(fajr);

      // فترة ما قبل الفجر تحتاج تطبيعاً عبر منتصف الليل مثل الموجود في getCurrentPrayerByDateTime.
      if (nowMin < fajrMin) {
        int normalizeNight(int minutes, {required bool isEvening}) {
          // نعتبر المساء (>= 18:00) من اليوم السابق، والصباح من اليوم التالي.
          // ونحوّل الآن (قبل الفجر) إلى خط زمني في اليوم التالي (+1440).
          return isEvening ? minutes : (minutes + 1440);
        }

        final int nowNorm = nowMin + 1440;
        final int middleNorm = normalizeNight(
          minutesSinceMidnight(middleOfTheNight),
          isEvening: middleOfTheNight.hour >= 18,
        );
        final int lastThirdNorm = normalizeNight(
          minutesSinceMidnight(lastThirdOfTheNight),
          isEvening: lastThirdOfTheNight.hour >= 18,
        );

        if (nowNorm >= lastThirdNorm) return 0;
        if (nowNorm >= middleNorm) return 7;
        return 6;
      }

      final int sunriseMin = minutesSinceMidnight(sunrise);
      final int dhuhrMin = minutesSinceMidnight(dhuhr);
      final int asrMin = minutesSinceMidnight(asr);
      final int maghribMin = minutesSinceMidnight(maghrib);
      final int ishaMin = minutesSinceMidnight(isha);
      final int middleMin = minutesSinceMidnight(middleOfTheNight);
      final int lastThirdMin = minutesSinceMidnight(lastThirdOfTheNight);

      if (nowMin < sunriseMin) return 1;
      if (nowMin < dhuhrMin) return 2;
      if (nowMin < asrMin) return 3;
      if (nowMin < maghribMin) return 4;
      if (nowMin < ishaMin) return 5;

      // بعد العشاء: إما منتصف الليل أو الثلث الأخير أو (بعده) الفجر.
      // هنا نستخدم نفس الفكرة: لو كانت قيم sunnah بعد منتصف الليل (صباحاً)
      // فهي تخص اليوم التالي.
      int normalizeAfterIsha(int minutes, {required bool isMorning}) {
        return isMorning ? (minutes + 1440) : minutes;
      }

      final int nowAfterIshaNorm = nowMin;
      final int middleAfterIshaNorm = normalizeAfterIsha(
        middleMin,
        isMorning: middleOfTheNight.hour < 12,
      );
      final int lastThirdAfterIshaNorm = normalizeAfterIsha(
        lastThirdMin,
        isMorning: lastThirdOfTheNight.hour < 12,
      );

      if (nowAfterIshaNorm < middleAfterIshaNorm) return 6;
      if (nowAfterIshaNorm < lastThirdAfterIshaNorm) return 7;
      return 0;
    } catch (_) {
      return -1;
    }
  }
}
