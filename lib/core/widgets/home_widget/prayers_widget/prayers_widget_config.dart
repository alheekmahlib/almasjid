part of '../home_widget.dart';

class PrayersWidgetConfig {
  final adhanCtrl = AdhanController.instance;

  /// عدد محاولات إعادة التحديث عند عدم جاهزية البيانات
  static int _retryCount = 0;
  static const int _maxRetries = 5;

  /// تتبّع نجاح آخر تحديث — يُستخدم لمنع كتابة last_widget_update_date عند الفشل
  static bool lastUpdateSucceeded = false;

  /// ضمان تهيئة AppGroupId قبل أي عملية كتابة — آمن للاستدعاء المتكرر
  static Future<void> _ensureAppGroupId() async {
    if (!Platform.isMacOS) {
      await HomeWidget.setAppGroupId(StringConstants.groupId);
    }
  }

  Future<void> updatePrayersDate() async {
    try {
      await _ensureAppGroupId();
      if (!adhanCtrl.state.isPrayerTimesInitialized.value ||
          adhanCtrl.state.prayerTimes == null ||
          adhanCtrl.state.sunnahTimes == null) {
        log('Prayer times not initialized — trying MonthlyPrayerCache fallback',
            name: 'PrayersWidgetConfig');

        // محاولة التحديث من الكاش الشهري مباشرة بدون انتظار AdhanController
        final fallbackSuccess = await _updateFromMonthlyCache();
        if (fallbackSuccess) {
          _retryCount = 0;
          lastUpdateSucceeded = true;
          return;
        }

        // إعادة المحاولة بعد ثانيتين إذا لم تتجاوز الحد الأقصى
        // Retry after 2 seconds if not exceeded max retries
        if (_retryCount < _maxRetries) {
          _retryCount++;
          log('Retrying widget update ($_retryCount/$_maxRetries)...',
              name: 'PrayersWidgetConfig');
          await Future.delayed(const Duration(seconds: 2));
          return await updatePrayersDate();
        } else {
          _retryCount = 0;
          log('Max retries reached, giving up', name: 'PrayersWidgetConfig');
          lastUpdateSucceeded = false;
        }
        return;
      }

      // إعادة تعيين عداد المحاولات عند النجاح
      _retryCount = 0;

      if (adhanCtrl.prayerNameList.isEmpty ||
          adhanCtrl.prayerNameList.length < 8) {
        log('Invalid prayer list data — trying MonthlyPrayerCache fallback',
            name: 'PrayersWidgetConfig');

        final fallbackSuccess = await _updateFromMonthlyCache();
        lastUpdateSucceeded = fallbackSuccess;
        return;
      }
      log('Updating prayers widget data...', name: 'PrayersWidgetConfig');
      HijriDate hijri = EventController.instance.hijriNow;

      final fajrTime = adhanCtrl.prayerNameList[0]['dateTime'] as DateTime;
      final sunriseTime = adhanCtrl.prayerNameList[1]['dateTime'] as DateTime;
      final dhuhrTime = adhanCtrl.prayerNameList[2]['dateTime'] as DateTime;
      final asrTime = adhanCtrl.prayerNameList[3]['dateTime'] as DateTime;
      final maghribTime = adhanCtrl.prayerNameList[4]['dateTime'] as DateTime;
      final ishaTime = adhanCtrl.prayerNameList[5]['dateTime'] as DateTime;
      final middleOfTheNightTime =
          adhanCtrl.prayerNameList[6]['dateTime'] as DateTime;
      final lastThirdOfTheNightTime =
          adhanCtrl.prayerNameList[7]['dateTime'] as DateTime;

      final fajrName = adhanCtrl.prayerNameList[0]['title'] as String;
      final sunriseName = adhanCtrl.prayerNameList[1]['title'] as String;
      final dhuhrName = adhanCtrl.prayerNameList[2]['title'] as String;
      final asrName = adhanCtrl.prayerNameList[3]['title'] as String;
      final maghribName = adhanCtrl.prayerNameList[4]['title'] as String;
      final ishaName = adhanCtrl.prayerNameList[5]['title'] as String;
      final middleOfTheNightName =
          adhanCtrl.prayerNameList[6]['title'] as String;
      final lastThirdOfTheNightName =
          adhanCtrl.prayerNameList[7]['title'] as String;

      if (Platform.isMacOS) {
        // macOS: لا تستدعي HomeWidget (غير مدعوم) — ادفع البيانات عبر قناة Swift فقط.
        await MacOSWidgetService.instance.updatePrayerData(
          fajrTime: fajrTime,
          sunriseTime: sunriseTime,
          dhuhrTime: dhuhrTime,
          asrTime: asrTime,
          maghribTime: maghribTime,
          ishaTime: ishaTime,
          middleOfTheNightTime: middleOfTheNightTime,
          lastThirdOfTheNightTime: lastThirdOfTheNightTime,
          fajrName: fajrName.tr,
          sunriseName: sunriseName.tr,
          dhuhrName: dhuhrName.tr,
          asrName: asrName.tr,
          maghribName: maghribName.tr,
          ishaName: ishaName.tr,
          middleOfTheNightName: middleOfTheNightName.tr,
          lastThirdOfTheNightName: lastThirdOfTheNightName.tr,
          hijriDay: '${hijri.hDay}',
          hijriDayName: weekDaysFullName[hijri.weekDay() - 1].tr,
          hijriMonth: '${hijri.hMonth}',
          hijriYear: '${hijri.hYear}',
          currentPrayerName:
              adhanCtrl.getPrayerDetails(isNextPrayer: false).prayerName,
          nextPrayerName:
              adhanCtrl.getPrayerDetails(isNextPrayer: true).prayerName,
          currentPrayerTime:
              adhanCtrl.getPrayerDetails(isNextPrayer: false).prayerTime,
          nextPrayerTime:
              adhanCtrl.getPrayerDetails(isNextPrayer: true).prayerTime,
          appLanguage: Get.locale?.languageCode ?? 'ar',
        );
      } else if (Platform.isIOS) {
        // iOS: استخدم HomeWidget كما هو.
        await HomeWidget.saveWidgetData('fajrTime', '$fajrTime');
        await HomeWidget.saveWidgetData('dhuhrTime', '$dhuhrTime');
        await HomeWidget.saveWidgetData('asrTime', '$asrTime');
        await HomeWidget.saveWidgetData('maghribTime', '$maghribTime');
        await HomeWidget.saveWidgetData('ishaTime', '$ishaTime');
        await HomeWidget.saveWidgetData('sunriseTime', '$sunriseTime');
        await HomeWidget.saveWidgetData(
            'middleOfTheNightTime', '$middleOfTheNightTime');
        await HomeWidget.saveWidgetData(
            'lastThirdOfTheNightTime', '$lastThirdOfTheNightTime');
        log('Saved individual prayer times (forced even if monthly present)',
            name: 'PrayersWidgetConfig');
        await HomeWidget.saveWidgetData('fajrName', fajrName.tr);
        await HomeWidget.saveWidgetData('dhuhrName', dhuhrName.tr);
        await HomeWidget.saveWidgetData('asrName', asrName.tr);
        await HomeWidget.saveWidgetData('maghribName', maghribName.tr);
        await HomeWidget.saveWidgetData('ishaName', ishaName.tr);
        await HomeWidget.saveWidgetData('sunriseName', sunriseName.tr);
        await HomeWidget.saveWidgetData(
            'middleOfTheNightName', middleOfTheNightName.tr);
        await HomeWidget.saveWidgetData(
            'lastThirdOfTheNightName', lastThirdOfTheNightName.tr);
        await HomeWidget.saveWidgetData('hijriDay', '${hijri.hDay}');
        await HomeWidget.saveWidgetData(
            'hijriDayName', weekDaysFullName[hijri.weekDay() - 1].tr);
        await HomeWidget.saveWidgetData('hijriMonth', '${hijri.hMonth}');
        await HomeWidget.saveWidgetData('hijriYear', '${hijri.hYear}');
        await HomeWidget.saveWidgetData(
            'appLanguage', Get.locale?.languageCode ?? 'ar');
      } else if (Platform.isAndroid) {
        // حفظ طوابع زمنية لدعم عدّاد الوديجت (Chronometer)
        final currentPrayer = adhanCtrl.getPrayerDetails(isNextPrayer: false);
        final nextPrayer = adhanCtrl.getPrayerDetails(isNextPrayer: true);
        if (currentPrayer.prayerTime != null) {
          await HomeWidget.saveWidgetData<int>('current_prayer_epoch',
              currentPrayer.prayerTime!.millisecondsSinceEpoch);
        }
        if (nextPrayer.prayerTime != null) {
          await HomeWidget.saveWidgetData<int>('next_prayer_epoch',
              nextPrayer.prayerTime!.millisecondsSinceEpoch);
        }
        await HomeWidget.saveWidgetData<String>(
            'hijri_day_number', '${hijri.hDay}'.convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'hijri_day_name', weekDaysFullName[hijri.weekDay() - 1].tr);
        await HomeWidget.saveWidgetData<String>(
            'hijri_year', '${hijri.hYear}'.convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'hijri_month_image', '${hijri.hMonth}');
        await HomeWidget.saveWidgetData<String>('current_prayer_name',
            adhanCtrl.getPrayerDetails(isNextPrayer: false).prayerName);
        await HomeWidget.saveWidgetData<String>(
            'current_prayer_time',
            DateFormatter.formatPrayerTime(
                    adhanCtrl.getPrayerDetails(isNextPrayer: false).prayerTime)
                .convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'next_prayer_time',
            DateFormatter.formatPrayerTime(
                    adhanCtrl.getPrayerDetails(isNextPrayer: true).prayerTime)
                .convertNumbers());
        await HomeWidget.saveWidgetData<String>('fajr_time',
            DateFormatter.formatPrayerTime(fajrTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('shuroq_time',
            DateFormatter.formatPrayerTime(sunriseTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('dhuhr_time',
            DateFormatter.formatPrayerTime(dhuhrTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('asr_time',
            DateFormatter.formatPrayerTime(asrTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('maghrib_time',
            DateFormatter.formatPrayerTime(maghribTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('isha_time',
            DateFormatter.formatPrayerTime(ishaTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'muntasaf_allayl_time',
            DateFormatter.formatPrayerTime(middleOfTheNightTime)
                .convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'althuluth_alakhir_time',
            DateFormatter.formatPrayerTime(lastThirdOfTheNightTime)
                .convertNumbers());
        await HomeWidget.saveWidgetData<String>('fajr_name', fajrName.tr);
        await HomeWidget.saveWidgetData<String>('shuroq_name', sunriseName.tr);
        await HomeWidget.saveWidgetData<String>('dhuhr_name', dhuhrName.tr);
        await HomeWidget.saveWidgetData<String>('asr_name', asrName.tr);
        await HomeWidget.saveWidgetData<String>('maghrib_name', maghribName.tr);
        await HomeWidget.saveWidgetData<String>('isha_name', ishaName.tr);
        await HomeWidget.saveWidgetData<String>(
            'muntasaf_allayl_name', middleOfTheNightName.tr);
        await HomeWidget.saveWidgetData<String>(
            'althuluth_alakhir_name', lastThirdOfTheNightName.tr);
        // اسم الصلاة التالية للاستخدام في الوديجت
        await HomeWidget.saveWidgetData<String>('next_prayer_name',
            adhanCtrl.getPrayerDetails(isNextPrayer: true).prayerName);
        // تمرير لغة التطبيق اختيارياً في أندرويد (قد تُستخدم في المزود الأصلي للويدجت)
        await HomeWidget.saveWidgetData<String>(
            'app_language', Get.locale?.languageCode ?? 'ar');
      }

      // كتابة بيانات الشهر الكامل إلى مخزن الويدجت المشترك — قبل التحديث
      try {
        await _writeMonthlyDataToWidgetStorage();
      } catch (_) {}
      if (Platform.isMacOS) {
        await MacOSWidgetService.instance.reloadAllTimelines();
      } else {
        // حدّث جميع مزوّدات أندرويد (كبير وصغير) + iOS
        await HomeWidget.updateWidget(
          iOSName: StringConstants.iosPrayersWidget,
          androidName: StringConstants.androidPrayersWidget,
          qualifiedAndroidName: 'com.alheekmah.alheekmahLibrary.PrayerWidget',
        );
        await HomeWidget.updateWidget(
          iOSName: StringConstants.iosPrayersWidget,
          androidName: StringConstants.androidPrayersWidget,
          qualifiedAndroidName:
              'com.alheekmah.alheekmahLibrary.PrayerWidgetSmall',
        );
      }
      _scheduleNextUpdate();
      lastUpdateSucceeded = true;
    } catch (e) {
      log('Error in updatePrayersDate: $e', name: 'PrayersWidgetConfig');
      lastUpdateSucceeded = false;
    }
  }

  void _scheduleNextUpdate() {
    try {
      _cancelScheduledUpdate();
      final nextPrayer = adhanCtrl.getPrayerDetails(isNextPrayer: true);
      if (nextPrayer.prayerTime != null) {
        final now = DateTime.now();
        final diff = nextPrayer.prayerTime!.difference(now);
        if (diff.inSeconds > 0) {
          _updateTimer =
              Timer(diff + const Duration(minutes: 1), updatePrayersDate);
        }
      }
    } catch (e) {
      log('Error scheduling next update: $e', name: 'PrayersWidgetConfig');
    }
  }

  static Timer? _updateTimer;

  void _cancelScheduledUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// مسار بديل: تحديث الويدجت مباشرة من الكاش الشهري بدون AdhanController
  /// Fallback: update widget directly from MonthlyPrayerCache without AdhanController
  Future<bool> _updateFromMonthlyCache() async {
    try {
      await _ensureAppGroupId();
      final now = DateTime.now();
      final dayTimes = MonthlyPrayerCache.getPrayerTimesForDate(now);
      if (dayTimes == null) {
        log('No MonthlyPrayerCache data for today',
            name: 'PrayersWidgetConfig');
        return false;
      }

      log('Updating widget from MonthlyPrayerCache fallback',
          name: 'PrayersWidgetConfig');

      final fajrTime = dayTimes.fajr;
      final sunriseTime = dayTimes.sunrise;
      final dhuhrTime = dayTimes.dhuhr;
      final asrTime = dayTimes.asr;
      final maghribTime = dayTimes.maghrib;
      final ishaTime = dayTimes.isha;
      final middleOfTheNightTime = dayTimes.midnight;
      final lastThirdOfTheNightTime = dayTimes.lastThird;

      // أسماء الصلوات مع مراعاة الجمعة ورمضان
      const fajrName = 'Fajr';
      const sunriseName = 'Sunrise';
      final dhuhrName =
          intl.DateFormat('EEEE').format(now) == 'Friday' ? 'Friday' : 'Dhuhr';
      const asrName = 'Asr';
      final hijri = HijriDate.now();
      final maghribName = hijri.hMonth == 9 ? 'ramadanMaghribName' : 'Maghrib';
      const ishaName = 'Isha';
      const middleOfTheNightName = 'middleOfTheNight';
      const lastThirdOfTheNightName = 'lastThirdOfTheNight';

      // حساب الصلاة الحالية والتالية من الأوقات مباشرة
      final allPrayers = <String, DateTime>{
        'Fajr': fajrTime,
        'Sunrise': sunriseTime,
        dhuhrName: dhuhrTime,
        'Asr': asrTime,
        maghribName: maghribTime,
        'Isha': ishaTime,
      };

      String currentPrayerName = 'Fajr'.tr;
      DateTime? currentPrayerTime = fajrTime;
      String nextPrayerName = 'Fajr'.tr;
      DateTime? nextPrayerTime = fajrTime;

      final orderedEntries = allPrayers.entries.toList();
      for (int i = orderedEntries.length - 1; i >= 0; i--) {
        if (now.isAfter(orderedEntries[i].value) ||
            now.isAtSameMomentAs(orderedEntries[i].value)) {
          currentPrayerName = orderedEntries[i].key.tr;
          currentPrayerTime = orderedEntries[i].value;
          if (i < orderedEntries.length - 1) {
            nextPrayerName = orderedEntries[i + 1].key.tr;
            nextPrayerTime = orderedEntries[i + 1].value;
          } else {
            // بعد العشاء → الفجر غدًا
            nextPrayerName = 'Fajr'.tr;
            nextPrayerTime = fajrTime.add(const Duration(days: 1));
          }
          break;
        }
      }
      // قبل الفجر → الحالية عشاء أمس والتالية فجر اليوم
      if (now.isBefore(fajrTime)) {
        currentPrayerName = 'Isha'.tr;
        currentPrayerTime = ishaTime.subtract(const Duration(days: 1));
        nextPrayerName = 'Fajr'.tr;
        nextPrayerTime = fajrTime;
      }

      if (Platform.isMacOS) {
        await MacOSWidgetService.instance.updatePrayerData(
          fajrTime: fajrTime,
          sunriseTime: sunriseTime,
          dhuhrTime: dhuhrTime,
          asrTime: asrTime,
          maghribTime: maghribTime,
          ishaTime: ishaTime,
          middleOfTheNightTime: middleOfTheNightTime,
          lastThirdOfTheNightTime: lastThirdOfTheNightTime,
          fajrName: fajrName.tr,
          sunriseName: sunriseName.tr,
          dhuhrName: dhuhrName.tr,
          asrName: asrName.tr,
          maghribName: maghribName.tr,
          ishaName: ishaName.tr,
          middleOfTheNightName: middleOfTheNightName.tr,
          lastThirdOfTheNightName: lastThirdOfTheNightName.tr,
          hijriDay: '${hijri.hDay}',
          hijriDayName: weekDaysFullName[hijri.weekDay() - 1].tr,
          hijriMonth: '${hijri.hMonth}',
          hijriYear: '${hijri.hYear}',
          currentPrayerName: currentPrayerName,
          nextPrayerName: nextPrayerName,
          currentPrayerTime: currentPrayerTime,
          nextPrayerTime: nextPrayerTime,
          appLanguage: Get.locale?.languageCode ?? 'ar',
        );
        await MacOSWidgetService.instance.reloadAllTimelines();
      } else if (Platform.isIOS) {
        await HomeWidget.saveWidgetData('fajrTime', '$fajrTime');
        await HomeWidget.saveWidgetData('dhuhrTime', '$dhuhrTime');
        await HomeWidget.saveWidgetData('asrTime', '$asrTime');
        await HomeWidget.saveWidgetData('maghribTime', '$maghribTime');
        await HomeWidget.saveWidgetData('ishaTime', '$ishaTime');
        await HomeWidget.saveWidgetData('sunriseTime', '$sunriseTime');
        await HomeWidget.saveWidgetData(
            'middleOfTheNightTime', '$middleOfTheNightTime');
        await HomeWidget.saveWidgetData(
            'lastThirdOfTheNightTime', '$lastThirdOfTheNightTime');
        await HomeWidget.saveWidgetData('fajrName', fajrName.tr);
        await HomeWidget.saveWidgetData('dhuhrName', dhuhrName.tr);
        await HomeWidget.saveWidgetData('asrName', asrName.tr);
        await HomeWidget.saveWidgetData('maghribName', maghribName.tr);
        await HomeWidget.saveWidgetData('ishaName', ishaName.tr);
        await HomeWidget.saveWidgetData('sunriseName', sunriseName.tr);
        await HomeWidget.saveWidgetData(
            'middleOfTheNightName', middleOfTheNightName.tr);
        await HomeWidget.saveWidgetData(
            'lastThirdOfTheNightName', lastThirdOfTheNightName.tr);
        await HomeWidget.saveWidgetData('hijriDay', '${hijri.hDay}');
        await HomeWidget.saveWidgetData(
            'hijriDayName', weekDaysFullName[hijri.weekDay() - 1].tr);
        await HomeWidget.saveWidgetData('hijriMonth', '${hijri.hMonth}');
        await HomeWidget.saveWidgetData('hijriYear', '${hijri.hYear}');
        await HomeWidget.saveWidgetData(
            'appLanguage', Get.locale?.languageCode ?? 'ar');
      } else if (Platform.isAndroid) {
        if (currentPrayerTime != null) {
          await HomeWidget.saveWidgetData<int>(
              'current_prayer_epoch', currentPrayerTime.millisecondsSinceEpoch);
        }
        if (nextPrayerTime != null) {
          await HomeWidget.saveWidgetData<int>(
              'next_prayer_epoch', nextPrayerTime.millisecondsSinceEpoch);
        }
        await HomeWidget.saveWidgetData<String>(
            'hijri_day_number', '${hijri.hDay}'.convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'hijri_day_name', weekDaysFullName[hijri.weekDay() - 1].tr);
        await HomeWidget.saveWidgetData<String>(
            'hijri_year', '${hijri.hYear}'.convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'hijri_month_image', '${hijri.hMonth}');
        await HomeWidget.saveWidgetData<String>(
            'current_prayer_name', currentPrayerName);
        await HomeWidget.saveWidgetData<String>('current_prayer_time',
            DateFormatter.formatPrayerTime(currentPrayerTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('next_prayer_time',
            DateFormatter.formatPrayerTime(nextPrayerTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('fajr_time',
            DateFormatter.formatPrayerTime(fajrTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('shuroq_time',
            DateFormatter.formatPrayerTime(sunriseTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('dhuhr_time',
            DateFormatter.formatPrayerTime(dhuhrTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('asr_time',
            DateFormatter.formatPrayerTime(asrTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('maghrib_time',
            DateFormatter.formatPrayerTime(maghribTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>('isha_time',
            DateFormatter.formatPrayerTime(ishaTime).convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'muntasaf_allayl_time',
            DateFormatter.formatPrayerTime(middleOfTheNightTime)
                .convertNumbers());
        await HomeWidget.saveWidgetData<String>(
            'althuluth_alakhir_time',
            DateFormatter.formatPrayerTime(lastThirdOfTheNightTime)
                .convertNumbers());
        await HomeWidget.saveWidgetData<String>('fajr_name', fajrName.tr);
        await HomeWidget.saveWidgetData<String>('shuroq_name', sunriseName.tr);
        await HomeWidget.saveWidgetData<String>('dhuhr_name', dhuhrName.tr);
        await HomeWidget.saveWidgetData<String>('asr_name', asrName.tr);
        await HomeWidget.saveWidgetData<String>('maghrib_name', maghribName.tr);
        await HomeWidget.saveWidgetData<String>('isha_name', ishaName.tr);
        await HomeWidget.saveWidgetData<String>(
            'muntasaf_allayl_name', middleOfTheNightName.tr);
        await HomeWidget.saveWidgetData<String>(
            'althuluth_alakhir_name', lastThirdOfTheNightName.tr);
        await HomeWidget.saveWidgetData<String>(
            'next_prayer_name', nextPrayerName);
        await HomeWidget.saveWidgetData<String>(
            'app_language', Get.locale?.languageCode ?? 'ar');
      }

      // كتابة بيانات الشهر الكامل إلى مخزن الويدجت المشترك — قبل التحديث
      try {
        await _writeMonthlyDataToWidgetStorage();
      } catch (_) {}

      if (!Platform.isMacOS) {
        await HomeWidget.updateWidget(
          iOSName: StringConstants.iosPrayersWidget,
          androidName: StringConstants.androidPrayersWidget,
          qualifiedAndroidName: 'com.alheekmah.alheekmahLibrary.PrayerWidget',
        );
        await HomeWidget.updateWidget(
          iOSName: StringConstants.iosPrayersWidget,
          androidName: StringConstants.androidPrayersWidget,
          qualifiedAndroidName:
              'com.alheekmah.alheekmahLibrary.PrayerWidgetSmall',
        );
      }

      log('Widget updated from MonthlyPrayerCache successfully',
          name: 'PrayersWidgetConfig');
      return true;
    } catch (e) {
      log('Error in _updateFromMonthlyCache: $e', name: 'PrayersWidgetConfig');
      return false;
    }
  }

  /// كتابة بيانات الشهر الكامل إلى مخزن الويدجت المشترك
  /// ليتمكّن الويدجت الأصلي (iOS/Android) من استخراج أوقات اليوم الصحيحة بدون Flutter
  /// Write full month data to widget shared storage so native widget
  /// can extract correct daily times without Flutter running
  Future<void> _writeMonthlyDataToWidgetStorage() async {
    // macOS: HomeWidget لا يدعم saveWidgetData — البيانات تُرسل عبر MacOSWidgetService
    if (Platform.isMacOS) return;
    try {
      await _ensureAppGroupId();
      final now = DateTime.now();

      // كتابة بيانات الشهر الحالي والشهر القادم — لضمان توفر البيانات عند نهاية الشهر
      final months = [
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1), // يعمل حتى ديسمبر → ينتقل لسنة جديدة
      ];

      for (final monthStart in months) {
        final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
        final days = <String, String>{};

        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(monthStart.year, monthStart.month, day);
          final dayTimes = MonthlyPrayerCache.getPrayerTimesForDate(date);
          if (dayTimes == null) continue;

          // ترتيب ثابت: fajr|sunrise|dhuhr|asr|maghrib|isha|midnight|lastThird
          String hm(DateTime dt) =>
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

          days['$day'] =
              '${hm(dayTimes.fajr)}|${hm(dayTimes.sunrise)}|${hm(dayTimes.dhuhr)}|${hm(dayTimes.asr)}|${hm(dayTimes.maghrib)}|${hm(dayTimes.isha)}|${hm(dayTimes.midnight)}|${hm(dayTimes.lastThird)}';
        }

        if (days.isEmpty) continue;

        final data = {
          'year': monthStart.year,
          'month': monthStart.month,
          'days': days,
        };

        // مفتاح خاص بكل شهر + المفتاح العام للتوافقية
        final monthKey = 'monthly_prayer_times_${monthStart.year}_${monthStart.month}';
        await HomeWidget.saveWidgetData<String>(monthKey, jsonEncode(data));

        // الاحتفاظ بالمفتاح القديم للشهر الحالي (توافقية مع Provider.swift القديم)
        if (monthStart.year == now.year && monthStart.month == now.month) {
          await HomeWidget.saveWidgetData<String>(
              'monthly_prayer_times', jsonEncode(data));
        }

        log('Monthly prayer data written to widget storage (${monthStart.year}-${monthStart.month}, ${days.length} days)',
            name: 'PrayersWidgetConfig');
      }
    } catch (e) {
      log('Error writing monthly data to widget storage: $e',
          name: 'PrayersWidgetConfig');
    }
  }

  static Future<void> onPrayerWidgetClicked() async {
    HomeWidget.widgetClicked.listen((event) {
      if (event == null) return;
      final eventString = event.toString();
      if (eventString == StringConstants.iosPrayersWidget ||
          eventString == StringConstants.androidPrayersWidget) {
        if (Get.context != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              Get.toNamed(AppRouter.homeScreen);
            } catch (_) {
              try {
                Get.to(() => const HomeScreen(),
                    transition: Transition.downToUp);
              } catch (_) {}
            }
          });
        }
      }
    });
  }

  static Future<void> initialize() async {
    try {
      if (Platform.isMacOS) {
        // HomeWidget قد لا يدعم macOS بالكامل؛ نعتمد على قناة Swift المخصصة.
        await MacOSWidgetService.instance.initialize();

        // جرّب تحديث كامل سريعًا (مع آلية retries الموجودة داخل updatePrayersDate).
        Future.delayed(const Duration(seconds: 1), () {
          PrayersWidgetConfig().updatePrayersDate();
        });
      } else {
        await HomeWidget.setAppGroupId(StringConstants.groupId);
        await onPrayerWidgetClicked();
      }
    } catch (e) {
      log('Failed to initialize widget: $e', name: 'PrayersWidgetConfig');
    }
  }
}
