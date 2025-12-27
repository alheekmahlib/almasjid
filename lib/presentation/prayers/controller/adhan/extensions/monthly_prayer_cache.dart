// ignore_for_file: constant_identifier_names

part of '../../../prayers.dart';

/// مدير التخزين الشهري لأوقات الصلاة
/// Monthly prayer times cache manager
class MonthlyPrayerCache {
  static const String _tag = 'MonthlyPrayerCache';
  static final GetStorage _storage = GetStorage();

  // مفاتيح التخزين
  // Storage keys
  static const String MONTHLY_PRAYER_DATA = 'MONTHLY_PRAYER_DATA';
  static const String MONTHLY_CACHE_DATE = 'MONTHLY_CACHE_DATE';
  static const String MONTHLY_CACHE_LOCATION = 'MONTHLY_CACHE_LOCATION';

  /// حفظ بيانات الصلاة لشهر كامل
  /// Save prayer data for a complete month
  static Future<void> saveMonthlyPrayerData({
    required LatLng location,
    required CalculationParameters params,
    required DateTime month,
  }) async {
    try {
      log('Calculating monthly prayer data for ${month.month}/${month.year}',
          name: _tag);

      // حساب بيانات الشهر الكامل
      final monthlyData = await _calculateMonthlyPrayerTimes(
        location: location,
        params: params,
        month: month,
      );

      // حفظ البيانات
      await _storage.write(MONTHLY_PRAYER_DATA, monthlyData.toJson());
      await _storage.write(
          MONTHLY_CACHE_DATE, DateTime.now().toIso8601String());
      await _storage.write(MONTHLY_CACHE_LOCATION, {
        'latitude': location.latitude,
        'longitude': location.longitude,
      });

      // مزامنة البيانات الشهرية إلى App Group للويدجت مباشرةً
      // Sync monthly data to App Group so the widget doesn't need the app to open daily
      try {
        await HomeWidget.setAppGroupId(StringConstants.groupId);
        await HomeWidget.saveWidgetData(
          'monthly_prayer_data',
          jsonEncode(monthlyData.toJson()),
        );
        log('Monthly prayer data mirrored to App Group for widget', name: _tag);

        // إخطار الـ widget بتحديث البيانات (ضروري لتفعيل إعادة قراءة البيانات)
        // Notify widget to update (required to trigger data reload)
        if (Platform.isIOS || Platform.isMacOS) {
          await HomeWidget.updateWidget(
            iOSName: StringConstants.iosPrayersWidget,
            androidName: StringConstants.androidPrayersWidget,
            qualifiedAndroidName: 'com.alheekmah.alheekmahLibrary.PrayerWidget',
          );
          log('Widget notified after monthly data save', name: _tag);
        }
      } catch (e) {
        log('Failed mirroring monthly data to App Group: $e', name: _tag);
      }

      log('Monthly prayer data saved successfully', name: _tag);
    } catch (e) {
      log('Error saving monthly prayer data: $e', name: _tag);
    }
  }

  /// التحقق من صحة البيانات الشهرية المخزنة
  /// Check if cached monthly data is valid
  static bool isMonthlyDataValid({required LatLng currentLocation}) {
    try {
      final storedData = _storage.read(MONTHLY_PRAYER_DATA);
      final storedDate = _storage.read(MONTHLY_CACHE_DATE);
      final storedLocation = _storage.read(MONTHLY_CACHE_LOCATION);

      if (storedData == null || storedDate == null || storedLocation == null) {
        return false;
      }

      // التحقق من الموقع
      if (!_isLocationValid(storedLocation, currentLocation)) {
        return false;
      }

      // التحقق من أن البيانات تغطي الشهر الحالي
      final monthlyData = MonthlyPrayerData.fromJson(storedData);
      final now = DateTime.now();

      return monthlyData.containsDate(now);
    } catch (e) {
      log('Error validating monthly cache: $e', name: _tag);
      return false;
    }
  }

  /// الحصول على أوقات الصلاة ليوم محدد من البيانات المخزنة
  /// Get prayer times for specific date from cached data
  static DayPrayerTimes? getPrayerTimesForDate(DateTime date) {
    try {
      final storedData = _storage.read(MONTHLY_PRAYER_DATA);
      if (storedData == null) return null;

      final monthlyData = MonthlyPrayerData.fromJson(storedData);
      return monthlyData.getPrayerTimesForDay(date);
    } catch (e) {
      log('Error getting prayer times for date: $e', name: _tag);
      return null;
    }
  }

  /// حساب أوقات الصلاة لشهر كامل
  /// Calculate prayer times for complete month
  static Future<MonthlyPrayerData> _calculateMonthlyPrayerTimes({
    required LatLng location,
    required CalculationParameters params,
    required DateTime month,
  }) async {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dailyTimes = <int, DayPrayerTimes>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateComponents = DateComponents.from(date);

      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
      final sunnahTimes = SunnahTimes(prayerTimes);

      dailyTimes[day] = DayPrayerTimes(
        date: date,
        fajr: prayerTimes.fajr,
        sunrise: prayerTimes.sunrise,
        dhuhr: prayerTimes.dhuhr,
        asr: prayerTimes.asr,
        maghrib: prayerTimes.maghrib,
        isha: prayerTimes.isha,
        midnight: sunnahTimes.middleOfTheNight,
        lastThird: sunnahTimes.lastThirdOfTheNight,
      );
    }

    return MonthlyPrayerData(
      year: month.year,
      month: month.month,
      dailyTimes: dailyTimes,
      location: location,
      calculatedAt: DateTime.now(),
      params: params,
    );
  }

  /// التحقق من صحة الموقع
  /// Check if location is valid
  static bool _isLocationValid(dynamic storedLocation, LatLng currentLocation) {
    try {
      if (storedLocation is! Map<String, dynamic>) return false;

      final storedLat = storedLocation['latitude']?.toDouble();
      final storedLng = storedLocation['longitude']?.toDouble();

      if (storedLat == null || storedLng == null) return false;

      // التحقق من المسافة (0.01 درجة تقريباً 1 كم)
      const threshold = 0.01;
      final latDiff = (storedLat - currentLocation.latitude).abs();
      final lngDiff = (storedLng - currentLocation.longitude).abs();

      return latDiff <= threshold && lngDiff <= threshold;
    } catch (e) {
      return false;
    }
  }

  /// مسح البيانات الشهرية المخزنة
  /// Clear cached monthly data
  static void clearMonthlyCache() {
    try {
      _storage.remove(MONTHLY_PRAYER_DATA);
      _storage.remove(MONTHLY_CACHE_DATE);
      _storage.remove(MONTHLY_CACHE_LOCATION);
      log('Monthly cache cleared', name: _tag);
    } catch (e) {
      log('Error clearing monthly cache: $e', name: _tag);
    }
  }
}

/// بيانات الصلاة ليوم واحد
/// Prayer data for single day
class DayPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime midnight;
  final DateTime lastThird;

  DayPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.lastThird,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'midnight': midnight.toIso8601String(),
      'lastThird': lastThird.toIso8601String(),
    };
  }

  factory DayPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DayPrayerTimes(
      date: DateTime.parse(json['date']),
      fajr: DateTime.parse(json['fajr']),
      sunrise: DateTime.parse(json['sunrise']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
      midnight: DateTime.parse(json['midnight']),
      lastThird: DateTime.parse(json['lastThird']),
    );
  }
}

/// بيانات الصلاة لشهر كامل
/// Prayer data for complete month
class MonthlyPrayerData {
  final int year;
  final int month;
  final Map<int, DayPrayerTimes> dailyTimes;
  final LatLng location;
  final DateTime calculatedAt;
  final CalculationParameters params;

  MonthlyPrayerData({
    required this.year,
    required this.month,
    required this.dailyTimes,
    required this.location,
    required this.calculatedAt,
    required this.params,
  });

  /// التحقق من احتواء تاريخ محدد
  /// Check if contains specific date
  bool containsDate(DateTime date) {
    return date.year == year &&
        date.month == month &&
        dailyTimes.containsKey(date.day);
  }

  /// الحصول على أوقات الصلاة ليوم محدد
  /// Get prayer times for specific day
  DayPrayerTimes? getPrayerTimesForDay(DateTime date) {
    if (!containsDate(date)) return null;
    return dailyTimes[date.day];
  }

  Map<String, dynamic> toJson() {
    final dailyTimesJson = <String, dynamic>{};
    dailyTimes.forEach((day, times) {
      dailyTimesJson[day.toString()] = times.toJson();
    });

    return {
      'year': year,
      'month': month,
      'dailyTimes': dailyTimesJson,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'calculatedAt': calculatedAt.toIso8601String(),
      'params': {
        'fajrAngle': params.fajrAngle,
        'ishaAngle': params.ishaAngle,
        'madhab': params.madhab.toString(),
        'highLatitudeRule': params.highLatitudeRule.toString(),
      },
    };
  }

  factory MonthlyPrayerData.fromJson(Map<String, dynamic> json) {
    final dailyTimesJson = json['dailyTimes'] as Map<String, dynamic>;
    final dailyTimes = <int, DayPrayerTimes>{};

    dailyTimesJson.forEach((dayStr, timesJson) {
      final day = int.parse(dayStr);
      dailyTimes[day] = DayPrayerTimes.fromJson(timesJson);
    });

    final locationJson = json['location'] as Map<String, dynamic>;
    final paramsJson = json['params'] as Map<String, dynamic>;

    // إعادة بناء معاملات الحساب
    final params = CalculationParameters(
      fajrAngle: paramsJson['fajrAngle']?.toDouble() ?? 18.0,
    )..ishaAngle = paramsJson['ishaAngle']?.toDouble() ?? 17.0;

    // تعيين المذهب
    final madhabStr = paramsJson['madhab'] ?? 'Madhab.shafi';
    params.madhab = madhabStr.contains('hanafi') ? Madhab.hanafi : Madhab.shafi;

    // تعيين قاعدة خطوط العرض العليا
    final ruleStr = paramsJson['highLatitudeRule'] ??
        'HighLatitudeRule.middle_of_the_night';
    params.highLatitudeRule = HighLatitudeRule.values.firstWhere(
      (rule) => rule.toString() == ruleStr,
      orElse: () => HighLatitudeRule.middle_of_the_night,
    );

    return MonthlyPrayerData(
      year: json['year'],
      month: json['month'],
      dailyTimes: dailyTimes,
      location: LatLng(
        locationJson['latitude']?.toDouble() ?? 0.0,
        locationJson['longitude']?.toDouble() ?? 0.0,
      ),
      calculatedAt: DateTime.parse(json['calculatedAt']),
      params: params,
    );
  }
}
