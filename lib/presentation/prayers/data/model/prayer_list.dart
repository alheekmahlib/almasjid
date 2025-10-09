part of '../../prayers.dart';

List<Map<String, dynamic>> generatePrayerNameList(AdhanState state) {
  // تحديد ما إذا كنا نستخدم أوقات الصلاة للتاريخ المختار أم اليوم الحالي
  // Determine if we're using selected date prayer times or current day
  // ملاحظة: لا نعتمد على selectedDatePrayerTimes لأنها قد لا تُملأ عند التحميل من الكاش الشهري.
  // يكفي أن يكون التاريخ المختار مختلفًا عن اليوم الحالي لنعرض الأوقات النصية الخاصة به.
  final bool useSelectedDate = !_isSameDay(state.selectedDate, DateTime.now());

  final bool hasSelectedDateTimes = state.selectedDatePrayerTimes != null &&
      state.selectedDateSunnahTimes != null;

  // إن لم تتوفر كائنات PrayerTimes للتاريخ المختار (مسار الكاش الشهري)،
  // نستخدم كائنات اليوم الحالي لقيم dateTime فقط، بينما تبقى قيم "time" نصية محسوبة لليوم المختار.
  final prayerTimes = useSelectedDate && hasSelectedDateTimes
      ? state.selectedDatePrayerTimes!
      : state.prayerTimes!;
  final sunnahTimes = useSelectedDate && hasSelectedDateTimes
      ? state.selectedDateSunnahTimes!
      : state.sunnahTimes!;

  return [
    {
      'title': 'Fajr',
      'time': useSelectedDate
          ? state.selectedDateFajrTime.value
          : state.fajrTime.value,
      'dateTime': prayerTimes.fajr,
      'minuteTime': prayerTimes.fajr.minute,
      'sharedAlarm': 'ALARM_FAJR',
      'sharedAfter': 'AFTER_FAJR',
      'sharedAdjustment': 'ADJUSTMENT_FAJR',
      'icon': SolarIconsBold.moonFog,
      'adjustment': state.params.adjustments.fajr,
    },
    {
      'title': 'Sunrise',
      'time': useSelectedDate
          ? state.selectedDateSunriseTime.value
          : state.sunriseTime.value,
      'dateTime': prayerTimes.sunrise,
      'minuteTime': prayerTimes.sunrise.minute,
      'sharedAlarm': 'ALARM_SUNRISE',
      'sharedAfter': 'AFTER_SUNRISE',
      'sharedAdjustment': 'ADJUSTMENT_SUNRISE',
      'icon': SolarIconsBold.sunrise,
      'adjustment': state.params.adjustments.sunrise,
    },
    {
      'title': AdhanController.instance.getFridayDhuhrName,
      'time': useSelectedDate
          ? state.selectedDateDhuhrTime.value
          : state.dhuhrTime.value,
      'dateTime': prayerTimes.dhuhr,
      'minuteTime': prayerTimes.dhuhr.minute,
      'sharedAlarm': 'ALARM_DHUHR',
      'sharedAfter': 'AFTER_DHUHR',
      'sharedAdjustment': 'ADJUSTMENT_DHUHR',
      'icon': SolarIconsBold.sun,
      'adjustment': state.params.adjustments.dhuhr,
    },
    {
      'title': 'Asr',
      'time': useSelectedDate
          ? state.selectedDateAsrTime.value
          : state.asrTime.value,
      'dateTime': prayerTimes.asr,
      'minuteTime': prayerTimes.asr.minute,
      'sharedAlarm': 'ALARM_ASR',
      'sharedAfter': 'AFTER_ASR',
      'sharedAdjustment': 'ADJUSTMENT_ASR',
      'icon': SolarIconsBold.sun2,
      'adjustment': state.params.adjustments.asr,
    },
    {
      'title': AdhanController.instance.getMaghribName,
      'time': useSelectedDate
          ? state.selectedDateMaghribTime.value
          : state.maghribTime.value,
      'dateTime': prayerTimes.maghrib,
      'minuteTime': prayerTimes.maghrib.minute,
      'sharedAlarm': 'ALARM_MAGHRIB',
      'sharedAfter': 'AFTER_MAGHRIB',
      'sharedAdjustment': 'ADJUSTMENT_MAGHRIB',
      'icon': SolarIconsBold.sunset,
      'adjustment': state.params.adjustments.maghrib,
    },
    {
      'title': 'Isha',
      'time': useSelectedDate
          ? state.selectedDateIshaTime.value
          : state.ishaTime.value,
      'dateTime': prayerTimes.isha,
      'minuteTime': prayerTimes.isha.minute,
      'sharedAlarm': 'ALARM_ISHA',
      'sharedAfter': 'AFTER_ISHA',
      'sharedAdjustment': 'ADJUSTMENT_ISHA',
      'icon': SolarIconsBold.moon,
      'adjustment': state.params.adjustments.isha,
    },
    {
      'title': 'middleOfTheNight',
      'time': useSelectedDate
          ? state.selectedDateMidnightTime.value
          : state.midnightTime.value,
      'dateTime': sunnahTimes.middleOfTheNight,
      'minuteTime': sunnahTimes.middleOfTheNight.minute,
      'sharedAlarm': 'ALARM_MIDNIGHT',
      'sharedAfter': 'AFTER_MIDNIGHT',
      'sharedAdjustment': 'ADJUSTMENT_MIDNIGHT',
      'icon': SolarIconsBold.moonStars,
      'adjustment': sunnahTimes.middleOfTheNight.hour,
    },
    {
      'title': 'lastThirdOfTheNight',
      'time': useSelectedDate
          ? state.selectedDateLastThirdTime.value
          : state.lastThirdTime.value,
      'dateTime': sunnahTimes.lastThirdOfTheNight,
      'minuteTime': sunnahTimes.lastThirdOfTheNight.minute,
      'sharedAlarm': 'ALARM_LAST_THIRD',
      'sharedAfter': 'AFTER_LAST_THIRD',
      'sharedAdjustment': 'ADJUSTMENT_THIRD',
      'icon': SolarIconsBold.moonStars,
      'adjustment': sunnahTimes.lastThirdOfTheNight.hour,
    },
  ];
}

/// وظيفة مساعدة للتحقق من تطابق التاريخين
/// Helper function to check if two dates are the same day
bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
