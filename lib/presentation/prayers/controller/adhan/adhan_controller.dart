part of '../../prayers.dart';

class AdhanController extends GetxController {
  static AdhanController get instance =>
      GetInstance().putOrFind(() => AdhanController());

  AdhanState state = AdhanState();

  // Tracks and updates current prayer highlighting reliably
  int _lastCurrentPrayerIndex = -1;
  Timer? _currentPrayerTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (Platform.isAndroid || Platform.isIOS) {
      geo.setLocaleIdentifier('en');
    }
    getShared;
    Future.delayed(
        const Duration(seconds: 4), () async => await initializeStoredAdhan());
    Future.delayed(
        const Duration(seconds: 8),
        () async =>
            await PrayersNotificationsCtrl.instance.reschedulePrayers());
    updateProgressBar();
    // Start periodic watcher after initial data likely loaded
    Future.delayed(const Duration(seconds: 10), () {
      updateCurrentPrayer();
    });
  }

  @override
  void onClose() {
    state.timer?.cancel();
    _currentPrayerTimer?.cancel();
    super.onClose();
  }

  /// -------- [Methods] ----------

  Future<void> fetchCountryList() async {
    state.countryListFuture = getCountryList();
  }

  String prayerNameFromEnum(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return 'Fajr';
    }
  }

  Future<void> initTimes() async {
    log('====================');
    log('Updating times...');
    log('====================');
    await Future.wait([
      getPrayerTime(0, state.prayerTimes!.fajr)
          .then((v) => state.fajrTime.value = v),
      getPrayerTime(1, state.prayerTimes!.sunrise)
          .then((v) => state.sunriseTime.value = v),
      getPrayerTime(2, state.prayerTimes!.dhuhr)
          .then((v) => state.dhuhrTime.value = v),
      getPrayerTime(3, state.prayerTimes!.asr)
          .then((v) => state.asrTime.value = v),
      getPrayerTime(4, state.prayerTimes!.maghrib)
          .then((v) => state.maghribTime.value = v),
      getPrayerTime(5, state.prayerTimes!.isha)
          .then((v) => state.ishaTime.value = v),
      getPrayerTime(6, state.sunnahTimes!.middleOfTheNight)
          .then((v) => state.midnightTime.value = v),
      getPrayerTime(7, state.sunnahTimes!.lastThirdOfTheNight)
          .then((v) => state.lastThirdTime.value = v),
    ]);
    log('Times updated, calling update...');
    // update();
  }

  Future<void> initializeAdhanVariables() async {
    if (GeneralController.instance.state.activeLocation.value) {
      state.coordinates = Coordinates(Location.instance.position!.latitude,
          Location.instance.position!.longitude);
      state.dateComponents = DateComponents.from(state.now);

      if (!state.autoCalculationMethod.value) {
        state.params =
            (await state.selectedCountry.value.getCalculationParameters());
      } else {
        state.params =
            (await Location.instance.country.getCalculationParameters());
      }
      state.adjustments = OurPrayerAdjustments.fromGetStorage();
      state.params.adjustments = state.adjustments;

      // if (state.params.ishaAngle == null && state.params.ishaInterval == null) {
      //   throw const FormatException(
      //       "ishaAngle or ishaInterval must be defined for the selected calculation method");
      // }

      state.params
        ..madhab = getMadhab(state.isHanafi)
        ..highLatitudeRule =
            await getHighLatitudeRule(state.highLatitudeRuleIndex.value);

      state.prayerTimesNow =
          PrayerTimes(state.coordinates, state.dateComponents, state.params);
      state.sunnahTimes = SunnahTimes(state.prayerTimesNow!);
      state.prayerTimes = state.prayerTimesNow;
      // update();
      return await initTimes();
    }
  }

  /// تهيئة بيانات الأذان المخزنة مع التحقق من الحاجة للتحديث
  /// Initialize stored adhan data with update check
  Future<void> initializeStoredAdhan(
      {LatLng? currentLocation,
      LatLng? newLocation,
      bool forceUpdate = false}) async {
    try {
      log('Initializing adhan data...', name: 'AdhanController');

      // الحصول على الموقع الحالي إذا لم يتم توفيره
      // Get current location if not provided
      currentLocation ??= PrayerCacheManager.getStoredLocation();

      // التحقق من صحة التخزين المؤقت
      // Check cache validity
      if (!forceUpdate &&
          PrayerCacheManager.isCacheValid(currentLocation: currentLocation)) {
        log('Using cached prayer data', name: 'AdhanController');

        // استرداد البيانات المخزنة
        // Restore cached data
        final cachedData = PrayerCacheManager.getCachedPrayerData();
        if (cachedData != null && state.fromJson(cachedData)) {
          await _finalizePrayerTimeInitialization();
          return;
        }
      }

      // إجراء التحديث إذا لزم الأمر
      // Perform update if needed
      log('Fetching new prayer data', name: 'AdhanController');

      if (GeneralController.instance.state.activeLocation.value) {
        await _fetchAndCalculatePrayerTimes(newLocation ?? currentLocation);
        await _finalizePrayerTimeInitialization();
      }
    } catch (e) {
      log('Error initializing adhan: $e', name: 'AdhanController');
      // في حالة الخطأ، حاول استخدام البيانات المخزنة
      // In case of error, try to use cached data
      await _tryUseCachedData();
    }
  }

  /// جلب وحساب أوقات الصلاة
  /// Fetch and calculate prayer times
  Future<void> _fetchAndCalculatePrayerTimes(LatLng? currentLocation) async {
    await initializeAdhanVariables();
    await fetchCountryList();
    await getCountryList().then((c) => state.countries = c);

    // حفظ البيانات الجديدة
    // Save new data
    PrayerCacheManager.savePrayerData(state.toJson(), currentLocation);
  }

  /// إنهاء تهيئة أوقات الصلاة
  /// Finalize prayer time initialization
  Future<void> _finalizePrayerTimeInitialization() async {
    await initTimes();
    state.isPrayerTimesInitialized.value = true;

    // حساب أوقات الصلاة للتاريخ المختار (اليوم الحالي في البداية)
    // Calculate prayer times for selected date (current day initially)
    await calculatePrayerTimesForDate(state.selectedDate);

    update(['init_athan', 'update_progress']);
    PrayerProgressController.instance.updateProgress();
  }

  /// محاولة استخدام البيانات المخزنة في حالة الخطأ
  /// Try to use cached data in case of error
  Future<void> _tryUseCachedData() async {
    try {
      final cachedData = PrayerCacheManager.getCachedPrayerData();
      if (cachedData != null && state.fromJson(cachedData)) {
        await _finalizePrayerTimeInitialization();
        log('Using cached data due to error', name: 'AdhanController');
        return;
      }

      // إذا فشل كل شيء، قم بالحساب الأساسي
      // If everything fails, do basic calculation
      await initializeAdhanVariables();
      state.isPrayerTimesInitialized.value = true;
      update(['init_athan']);
    } catch (e) {
      log('Failed to load any prayer data: $e', name: 'AdhanController');
    }
  }

  Future<List<String>> getCountryList() async {
    final jsonString = await rootBundle.loadString('assets/json/madhab.json');
    final jsonData = jsonDecode(jsonString) as List<dynamic>; // Decode as List

    // List<String> countries = [];
    for (var item in jsonData) {
      // Assuming each item is a map with a "country" key
      state.countries.add(item['country'] as String);
    }
    return state.countries;
  }

  void updateProgress() {
    var now = DateTime.now();
    var totalMinutes = 24 * 60;
    var currentMinutes = now.hour * 60 + now.minute;
    state.timeProgress.value = (currentMinutes / totalMinutes) * 100;
    update(['update_progress']);
  }

  /// تحديث شريط التقدم بصورة دورية
  /// Update progress bar periodically
  void updateProgressBar() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      update(['update_progress', 'CurrentPrayer']);
    });
  }

  /// قائمة أسماء الصلوات مع التفاصيل
  /// Prayer names list with details
  List<Map<String, dynamic>> get prayerNameList =>
      generatePrayerNameList(state);

  /// تحديث قائمة أسماء الصلوات
  /// Update prayer names list
  set updatePrayerNameList(List<Map<String, dynamic>> newList) {
    update(['init_athan']);
  }

  /// تحديث الصلاة الحالية بصورة دورية مع إعادة بناء عناصر الواجهة عند التغيير
  /// Update current prayer periodically and rebuild related UI when it changes
  void updateCurrentPrayer() {
    _currentPrayerTimer?.cancel();
    // Seed last index to current to avoid redundant first rebuild
    _lastCurrentPrayerIndex = getCurrentPrayerByDateTime();
    _currentPrayerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final currentIndex = getCurrentPrayerByDateTime();
      getTimeNowColor();
      if (currentIndex != _lastCurrentPrayerIndex) {
        _lastCurrentPrayerIndex = currentIndex;
        // Rebuild prayer list and selected-date views when prayer changes
        update(['init_athan', 'selected_date_prayers', 'CurrentPrayer']);
      } else {
        // Still push lighter updates for components that depend on time
        update(['CurrentPrayer']);
      }
    });
  }

  /// مسح البيانات المخزنة وإعادة الحساب
  /// Clear cached data and recalculate
  Future<void> clearCacheAndRecalculate() async {
    state.box.remove(PRAYER_TIME_DATE);
    state.box.remove(PRAYER_TIME);
    await initializeStoredAdhan(forceUpdate: true);
  }

  /// حساب أوقات الصلاة لتاريخ محدد
  /// Calculate prayer times for specific date
  Future<void> calculatePrayerTimesForDate(DateTime selectedDate) async {
    try {
      if (!GeneralController.instance.state.activeLocation.value) return;

      // إنشاء DateComponents للتاريخ المختار
      final dateComponents = DateComponents.from(selectedDate);

      // حساب أوقات الصلاة للتاريخ المختار
      state.selectedDatePrayerTimes =
          PrayerTimes(state.coordinates, dateComponents, state.params);

      state.selectedDateSunnahTimes =
          SunnahTimes(state.selectedDatePrayerTimes!);

      // تحديث أوقات الصلاة للتاريخ المختار
      await Future.wait([
        getPrayerTime(0, state.selectedDatePrayerTimes!.fajr)
            .then((v) => state.selectedDateFajrTime.value = v),
        getPrayerTime(1, state.selectedDatePrayerTimes!.sunrise)
            .then((v) => state.selectedDateSunriseTime.value = v),
        getPrayerTime(2, state.selectedDatePrayerTimes!.dhuhr)
            .then((v) => state.selectedDateDhuhrTime.value = v),
        getPrayerTime(3, state.selectedDatePrayerTimes!.asr)
            .then((v) => state.selectedDateAsrTime.value = v),
        getPrayerTime(4, state.selectedDatePrayerTimes!.maghrib)
            .then((v) => state.selectedDateMaghribTime.value = v),
        getPrayerTime(5, state.selectedDatePrayerTimes!.isha)
            .then((v) => state.selectedDateIshaTime.value = v),
        getPrayerTime(6, state.selectedDateSunnahTimes!.middleOfTheNight)
            .then((v) => state.selectedDateMidnightTime.value = v),
        getPrayerTime(7, state.selectedDateSunnahTimes!.lastThirdOfTheNight)
            .then((v) => state.selectedDateLastThirdTime.value = v),
      ]);

      // تحديث الواجهة
      update(['init_athan', 'selected_date_prayers']);
    } catch (e) {
      log('Error calculating prayer times for date: $e',
          name: 'AdhanController');
    }
  }

  /// تحديث التاريخ المختار وحساب أوقات الصلاة
  /// Update selected date and calculate prayer times
  Future<void> updateSelectedDate(DateTime newDate) async {
    state.selectedDate = newDate;
    await calculatePrayerTimesForDate(newDate);
  }
}
