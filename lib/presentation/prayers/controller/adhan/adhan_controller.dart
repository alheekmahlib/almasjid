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
      // تعيين حالة التحميل إلى true
      state.isLoadingPrayerData.value = true;
      update(['loading_state']);
      log('Initializing adhan data...', name: 'AdhanController');

      // الحصول على الموقع الحالي إذا لم يتم توفيره
      // Get current location if not provided
      currentLocation ??= PrayerCacheManager.getStoredLocation();

      if (currentLocation == null) {
        log('No location available', name: 'AdhanController');
        state.isLoadingPrayerData.value = false;
        update(['loading_state']);
        return;
      }

      // أولاً: محاولة استخدام النظام الشهري الجديد
      // First: Try to use monthly cache system
      if (!forceUpdate &&
          MonthlyPrayerCache.isMonthlyDataValid(
              currentLocation: currentLocation)) {
        log('Using monthly cached prayer data', name: 'AdhanController');

        if (await _loadFromMonthlyCache()) {
          return;
        }
      }

      // ثانياً: محاولة استخدام النظام اليومي القديم كـ fallback
      // Second: Try to use daily cache system as fallback
      if (!forceUpdate &&
          PrayerCacheManager.isCacheValid(currentLocation: currentLocation)) {
        log('Using daily cached prayer data', name: 'AdhanController');

        // استرداد البيانات المخزنة
        // Restore cached data
        final cachedData = PrayerCacheManager.getCachedPrayerData();
        if (cachedData != null && state.fromJson(cachedData)) {
          await _finalizePrayerTimeInitialization();
          return;
        }
      }

      // ثالثاً: جلب بيانات جديدة وحفظها في النظام الشهري
      // Third: Fetch new data and save to monthly system
      log('Fetching new prayer data', name: 'AdhanController');

      if (GeneralController.instance.state.activeLocation.value) {
        await _fetchAndCalculatePrayerTimes(newLocation ?? currentLocation);
        await _saveToMonthlyCache(currentLocation);
        await _finalizePrayerTimeInitialization();
      } else {
        // إيقاف حالة التحميل إذا لم يكن الموقع نشطاً
        state.isLoadingPrayerData.value = false;
        update(['loading_state']);
      }
    } catch (e) {
      log('Error initializing adhan: $e', name: 'AdhanController');
      // إيقاف حالة التحميل في حالة الخطأ
      state.isLoadingPrayerData.value = false;
      update(['loading_state']);
      // في حالة الخطأ، حاول استخدام البيانات المخزنة
      // In case of error, try to use cached data
      await _tryUseCachedData();
    }
  }

  /// جلب وحساب أوقات الصلاة
  /// Fetch and calculate prayer times
  Future<void> _fetchAndCalculatePrayerTimes(LatLng? currentLocation) async {
    try {
      await initializeAdhanVariables();
      await fetchCountryList();
      await getCountryList().then((c) => state.countries = c);

      // حفظ البيانات الجديدة
      // Save new data
      PrayerCacheManager.savePrayerData(state.toJson(), currentLocation);
    } catch (e) {
      log('Error fetching prayer times: $e', name: 'AdhanController');
      rethrow;
    }
  }

  /// إنهاء تهيئة أوقات الصلاة
  /// Finalize prayer time initialization
  Future<void> _finalizePrayerTimeInitialization() async {
    await initTimes();
    state.isPrayerTimesInitialized.value = true;

    // إيقاف حالة التحميل
    state.isLoadingPrayerData.value = false;
    update(['loading_state']);

    // حساب أوقات الصلاة للتاريخ المختار (اليوم الحالي في البداية)
    // Calculate prayer times for selected date (current day initially)
    await calculatePrayerTimesForDate(state.selectedDate);

    update(['init_athan', 'update_progress']);
    PrayerProgressController.instance.updateProgress();

    // Ensure precise scheduling starts after times are ready
    updateCurrentPrayer();
  }

  /// تحميل البيانات من التخزين الشهري
  /// Load data from monthly cache
  Future<bool> _loadFromMonthlyCache() async {
    try {
      final today = DateTime.now();
      final todayPrayerTimes = MonthlyPrayerCache.getPrayerTimesForDate(today);

      if (todayPrayerTimes != null) {
        // تحويل بيانات اليوم إلى البيانات المطلوبة للحالة
        await _convertDayPrayerTimesToState(todayPrayerTimes);
        await _finalizePrayerTimeInitialization();
        return true;
      }

      return false;
    } catch (e) {
      log('Error loading from monthly cache: $e', name: 'AdhanController');
      return false;
    }
  }

  /// تحويل بيانات يوم واحد إلى حالة الكونترولر
  /// Convert single day prayer times to controller state
  Future<void> _convertDayPrayerTimesToState(DayPrayerTimes dayTimes) async {
    // تعيين الإحداثيات والمعاملات (يجب الحصول عليها من المخزن أو إعادة حسابها)
    if (GeneralController.instance.state.activeLocation.value) {
      state.coordinates = Coordinates(
        Location.instance.position!.latitude,
        Location.instance.position!.longitude,
      );
      state.dateComponents = DateComponents.from(dayTimes.date);

      // الحصول على المعاملات المحفوظة
      await initializeAdhanVariables();

      // إنشاء PrayerTimes من البيانات المحفوظة
      state.prayerTimesNow =
          PrayerTimes(state.coordinates, state.dateComponents, state.params);
      state.sunnahTimes = SunnahTimes(state.prayerTimesNow!);
      state.prayerTimes = state.prayerTimesNow;
    }
  }

  /// حفظ البيانات في التخزين الشهري
  /// Save data to monthly cache
  Future<void> _saveToMonthlyCache(LatLng location) async {
    try {
      final now = DateTime.now();
      await MonthlyPrayerCache.saveMonthlyPrayerData(
        location: location,
        params: state.params,
        month: DateTime(now.year, now.month, 1),
      );
      log('Data saved to monthly cache', name: 'AdhanController');
    } catch (e) {
      log('Error saving to monthly cache: $e', name: 'AdhanController');
      // في حالة الخطأ، لا نعيد رمي الاستثناء لأن الحفظ اليومي ما زال يعمل
      // Don't rethrow as daily saving still works as fallback
    }
  }

  /// محاولة استخدام البيانات المخزنة في حالة الخطأ
  /// Try to use cached data in case of error
  Future<void> _tryUseCachedData() async {
    try {
      // محاولة النظام الشهري أولاً
      final currentLocation = PrayerCacheManager.getStoredLocation();
      if (currentLocation != null &&
          MonthlyPrayerCache.isMonthlyDataValid(
              currentLocation: currentLocation)) {
        if (await _loadFromMonthlyCache()) {
          return;
        }
      }

      // محاولة النظام اليومي كـ fallback
      final cachedData = PrayerCacheManager.getCachedPrayerData();
      if (cachedData != null && state.fromJson(cachedData)) {
        await _finalizePrayerTimeInitialization();
        return;
      }

      log('No valid cached data available', name: 'AdhanController');
      // إيقاف حالة التحميل
      state.isLoadingPrayerData.value = false;
      update(['init_athan', 'loading_state']);
    } catch (e) {
      log('Error in _tryUseCachedData: $e', name: 'AdhanController');
      // إيقاف حالة التحميل في حالة الخطأ أيضا
      state.isLoadingPrayerData.value = false;
      update(['loading_state']);
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
      // Refresh progress widgets and lightly rebuild prayer list for visual tweaks
      update(['update_progress', 'init_athan']);
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
    // Cancel any previous timer and seed the current prayer index
    _currentPrayerTimer?.cancel();
    _lastCurrentPrayerIndex = getCurrentPrayerByDateTime();

    // Push a lightweight update for time-dependent widgets
    update(['update_progress', 'init_athan']);

    // Schedule an exact tick at the next prayer change
    _scheduleNextPrayerTick();
  }

  /// جدولة مؤقّت لموعد تغيّر الصلاة التالي بدقّة
  /// Schedule a one-shot timer to fire exactly at the next prayer boundary
  void _scheduleNextPrayerTick() {
    // Determine duration until next prayer change using existing helper
    final Duration wait = _timeUntilNextPrayerChange();

    // Safety: ensure at least 1s to avoid zero/negative durations
    final Duration safeWait =
        wait.inSeconds <= 0 ? const Duration(seconds: 1) : wait;

    _currentPrayerTimer = Timer(safeWait, () {
      final currentIndex = getCurrentPrayerByDateTime();
      getTimeNowColor();

      final changed = currentIndex != _lastCurrentPrayerIndex;
      _lastCurrentPrayerIndex = currentIndex;

      if (changed) {
        // Update only the necessary widgets: list highlight, selected date views, and progress visuals
        update(['init_athan', 'selected_date_prayers', 'update_progress']);
      } else {
        // Still refresh progress/time-bound widgets
        update(['update_progress']);
      }

      // Schedule the next tick for the following boundary
      _scheduleNextPrayerTick();
    });
  }

  /// الوقت المتبقي حتى تغيّر الصلاة الحاليّة إلى التي تليها
  /// Uses controller's duration helper for current prayer
  Duration _timeUntilNextPrayerChange() {
    try {
      final int idx = getCurrentPrayerByDateTime();
      final Duration d = getDurationLeftForPrayerByIndex(idx).value;
      // Guard against unrealistic values
      if (d.isNegative) return const Duration(seconds: 1);
      // Cap extremely long waits to avoid potential platform timer quirks (optional)
      return d;
    } catch (_) {
      // Fallback to a short retry if anything goes wrong
      return const Duration(seconds: 5);
    }
  }

  /// مسح البيانات المخزنة وإعادة الحساب
  /// Clear cached data and recalculate
  Future<void> clearCacheAndRecalculate() async {
    state.isLoadingPrayerData.value = true;
    update(['loading_state']);
    state.box.remove(PRAYER_TIME_DATE);
    state.box.remove(PRAYER_TIME);
    await initializeStoredAdhan(forceUpdate: true);
  }

  /// حساب أوقات الصلاة لتاريخ محدد
  /// Calculate prayer times for specific date
  Future<void> calculatePrayerTimesForDate(DateTime selectedDate) async {
    try {
      if (!GeneralController.instance.state.activeLocation.value) return;

      // أولاً: محاولة الحصول على البيانات من التخزين الشهري
      // First: Try to get data from monthly cache
      final cachedDayData =
          MonthlyPrayerCache.getPrayerTimesForDate(selectedDate);
      if (cachedDayData != null) {
        log('Using monthly cached data for selected date',
            name: 'AdhanController');
        await _loadSelectedDateFromCache(cachedDayData);
        return;
      }

      // ثانياً: حساب البيانات يدوياً إذا لم تكن متوفرة في التخزين
      // Second: Calculate manually if not available in cache
      log('Calculating prayer times for selected date manually',
          name: 'AdhanController');
      await _calculateSelectedDateManually(selectedDate);
    } catch (e) {
      log('Error calculating prayer times for date: $e',
          name: 'AdhanController');
    }
  }

  /// تحميل بيانات التاريخ المختار من البيانات المخزنة
  /// Load selected date data from cached data
  Future<void> _loadSelectedDateFromCache(DayPrayerTimes cachedData) async {
    // تحويل البيانات المخزنة إلى النصوص المطلوبة للواجهة
    await Future.wait([
      getPrayerTime(0, cachedData.fajr)
          .then((v) => state.selectedDateFajrTime.value = v),
      getPrayerTime(1, cachedData.sunrise)
          .then((v) => state.selectedDateSunriseTime.value = v),
      getPrayerTime(2, cachedData.dhuhr)
          .then((v) => state.selectedDateDhuhrTime.value = v),
      getPrayerTime(3, cachedData.asr)
          .then((v) => state.selectedDateAsrTime.value = v),
      getPrayerTime(4, cachedData.maghrib)
          .then((v) => state.selectedDateMaghribTime.value = v),
      getPrayerTime(5, cachedData.isha)
          .then((v) => state.selectedDateIshaTime.value = v),
      getPrayerTime(6, cachedData.midnight)
          .then((v) => state.selectedDateMidnightTime.value = v),
      getPrayerTime(7, cachedData.lastThird)
          .then((v) => state.selectedDateLastThirdTime.value = v),
    ]);

    // تحديث الواجهة
    update(['init_athan', 'selected_date_prayers']);
  }

  /// حساب بيانات التاريخ المختار يدوياً
  /// Calculate selected date data manually
  Future<void> _calculateSelectedDateManually(DateTime selectedDate) async {
    state.coordinates = Coordinates(Location.instance.position!.latitude,
        Location.instance.position!.longitude);
    state.dateComponents = DateComponents.from(selectedDate);

    if (!state.autoCalculationMethod.value) {
      state.params =
          (await state.selectedCountry.value.getCalculationParameters());
    } else {
      state.params =
          (await Location.instance.country.getCalculationParameters());
    }
    state.adjustments = OurPrayerAdjustments.fromGetStorage();
    state.params.adjustments = state.adjustments;
    state.params
      ..madhab = getMadhab(state.isHanafi)
      ..highLatitudeRule =
          await getHighLatitudeRule(state.highLatitudeRuleIndex.value);

    state.selectedDatePrayerTimes =
        PrayerTimes(state.coordinates, state.dateComponents, state.params);
    state.selectedDateSunnahTimes = SunnahTimes(state.selectedDatePrayerTimes!);

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
  }

  /// تحديث التاريخ المختار وحساب أوقات الصلاة
  /// Update selected date and calculate prayer times
  Future<void> updateSelectedDate(DateTime newDate) async {
    state.selectedDate = newDate;
    await calculatePrayerTimesForDate(newDate);
  }

  /// تحديث البيانات الشهرية في الخلفية
  /// Update monthly data in background
  Future<void> updateMonthlyDataInBackground() async {
    try {
      final currentLocation = PrayerCacheManager.getStoredLocation();
      if (currentLocation != null &&
          GeneralController.instance.state.activeLocation.value) {
        log('Updating monthly prayer data in background',
            name: 'AdhanController');

        final now = DateTime.now();
        await MonthlyPrayerCache.saveMonthlyPrayerData(
          location: currentLocation,
          params: state.params,
          month: DateTime(now.year, now.month, 1),
        );

        // أيضاً تحديث الشهر التالي للاستعداد
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        await MonthlyPrayerCache.saveMonthlyPrayerData(
          location: currentLocation,
          params: state.params,
          month: nextMonth,
        );

        log('Monthly data updated successfully', name: 'AdhanController');
      }
    } catch (e) {
      log('Error updating monthly data: $e', name: 'AdhanController');
    }
  }

  /// فحص وتنظيف البيانات القديمة
  /// Check and clean old data
  Future<void> cleanupOldData() async {
    try {
      // تنظيف البيانات اليومية القديمة إذا كان لدينا بيانات شهرية صالحة
      final currentLocation = PrayerCacheManager.getStoredLocation();
      if (currentLocation != null &&
          MonthlyPrayerCache.isMonthlyDataValid(
              currentLocation: currentLocation)) {
        log('Cleaning up old daily cache data', name: 'AdhanController');
        PrayerCacheManager.clearCache();
      }
    } catch (e) {
      log('Error during cleanup: $e', name: 'AdhanController');
    }
  }
}
