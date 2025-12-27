part of '../home_widget.dart';

class PrayersWidgetConfig {
  final adhanCtrl = AdhanController.instance;

  /// عدد محاولات إعادة التحديث عند عدم جاهزية البيانات
  static int _retryCount = 0;
  static const int _maxRetries = 5;

  Future<void> updatePrayersDate() async {
    try {
      if (!adhanCtrl.state.isPrayerTimesInitialized.value ||
          adhanCtrl.state.prayerTimes == null ||
          adhanCtrl.state.sunnahTimes == null) {
        log('Prayer times not initialized', name: 'PrayersWidgetConfig');

        // إعادة المحاولة بعد ثانيتين إذا لم تتجاوز الحد الأقصى
        // Retry after 2 seconds if not exceeded max retries
        if (_retryCount < _maxRetries) {
          _retryCount++;
          log('Retrying widget update ($_retryCount/$_maxRetries)...',
              name: 'PrayersWidgetConfig');
          Future.delayed(const Duration(seconds: 2), updatePrayersDate);
        } else {
          _retryCount = 0;
          log('Max retries reached, giving up', name: 'PrayersWidgetConfig');
        }
        return;
      }

      // إعادة تعيين عداد المحاولات عند النجاح
      _retryCount = 0;

      if (adhanCtrl.prayerNameList.isEmpty ||
          adhanCtrl.prayerNameList.length < 8) {
        log('Invalid prayer list data', name: 'PrayersWidgetConfig');
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

      if (Platform.isIOS || Platform.isMacOS) {
        // محاولة جلب بيانات الشهر: إن وُجدت لا حاجة لتمرير كل الأوقات منفصلة
        final box = GetStorage();
        final monthlyRaw = box.read('MONTHLY_PRAYER_DATA');
        final hasMonthly = monthlyRaw != null;

        // حفظ الأوقات الفردية دائماً لتسهيل المقارنة والتشخيص حتى مع وجود الشهري
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
        try {
          if (hasMonthly) {
            await HomeWidget.saveWidgetData(
                'monthly_prayer_data', jsonEncode(monthlyRaw));
            log('Saved monthly_prayer_data JSON', name: 'PrayersWidgetConfig');
          } else {
            log('Monthly data missing; relying on individual times',
                name: 'PrayersWidgetConfig');
          }
        } catch (e) {
          log('Failed monthly_prayer_data save: $e',
              name: 'PrayersWidgetConfig');
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
            currentPrayerName:
                adhanCtrl.getPrayerDetails(isNextPrayer: false).prayerName,
            nextPrayerName:
                adhanCtrl.getPrayerDetails(isNextPrayer: true).prayerName,
            currentPrayerTime:
                adhanCtrl.getPrayerDetails(isNextPrayer: false).prayerTime,
            nextPrayerTime:
                adhanCtrl.getPrayerDetails(isNextPrayer: true).prayerTime,
          );
        }
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

      // حدّث جميع مزوّدات أندرويد (كبير وصغير)
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
      if (Platform.isMacOS) {
        await MacOSWidgetService.instance.reloadAllTimelines();
      }
      _scheduleNextUpdate();
      _startProgressUpdates();
    } catch (e) {
      log('Error in updatePrayersDate: $e', name: 'PrayersWidgetConfig');
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

  void _startProgressUpdates() {
    try {
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        updatePrayersDate();
      });
    } catch (e) {
      log('Error starting progress updates: $e', name: 'PrayersWidgetConfig');
    }
  }

  static Timer? _updateTimer;
  static Timer? _progressTimer;

  void _cancelScheduledUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _progressTimer?.cancel();
    _progressTimer = null;
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
      await HomeWidget.setAppGroupId(StringConstants.groupId);
      await onPrayerWidgetClicked();
      PrayersWidgetConfig()._startProgressUpdates();
    } catch (e) {
      log('Failed to initialize widget: $e', name: 'PrayersWidgetConfig');
    }
  }
}
