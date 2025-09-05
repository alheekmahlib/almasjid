part of '../../../prayers.dart';

extension AdhanGetters on AdhanController {
  /// -------- [Getters] ----------
  // int get adjustment {
  //   if (state.adjustmentIndex.value >= 0 &&
  //       state.adjustmentIndex.value < state.adjustments.length) {
  //     return state.adjustments[state.adjustmentIndex.value].value;
  //   }
  //   return 0;
  // }

  RxInt get currentPrayer => (state.prayerTimes!.currentPrayer().index - 1).obs;
  int get nextPrayer => state.prayerTimes!.nextPrayer().index;

  String get getFridayDhuhrName =>
      intl.DateFormat('EEEE').format(state.now) == 'Friday'
          ? 'FridayFullName'
          : 'Dhuhr';

  String get getMaghribName => EventController.instance.hijriNow.hMonth == 9
      ? 'ramadanMaghribName'
      : 'Maghrib';

  PrayerDetail getPrayerDetails({required bool isNextPrayer}) {
    final Prayer currentPrayer = state.prayerTimes!.currentPrayer();
    final Prayer? targetPrayer;

    if (isNextPrayer) {
      if (currentPrayer == Prayer.isha) {
        targetPrayer = Prayer.fajr;
      } else {
        targetPrayer = state.prayerTimes!.nextPrayer();
      }
    } else {
      targetPrayer = currentPrayer;
    }

    DateTime? targetPrayerDateTime =
        state.prayerTimes!.timeForPrayer(targetPrayer);
    if (isNextPrayer &&
        targetPrayer == Prayer.fajr &&
        currentPrayer == Prayer.isha) {
      targetPrayerDateTime = targetPrayerDateTime?.add(const Duration(days: 1));
    }

    return PrayerDetail(
      prayerName: prayerNameFromEnum(targetPrayer).tr,
      prayerTime: targetPrayerDateTime,
      prayerDisplayTime: DateFormatter.formatPrayerTime(targetPrayerDateTime),
    );
  }

  RxDouble get getTimeLeftPercentage {
    final now = DateTime.now();
    final Prayer currentPrayer = state.prayerTimes!.currentPrayer();
    final Prayer? nextPrayer;

    if (currentPrayer == Prayer.isha) {
      nextPrayer = Prayer.fajr;
    } else {
      nextPrayer = state.prayerTimes!.nextPrayer();
    }
    DateTime? nextPrayerDateTime = state.prayerTimes!.timeForPrayer(nextPrayer);
    DateTime? currentPrayerDateTime =
        state.prayerTimes!.timeForPrayer(currentPrayer);

    if (nextPrayer == Prayer.fajr && currentPrayer == Prayer.isha) {
      nextPrayerDateTime = nextPrayerDateTime?.add(const Duration(days: 1));
    }
    if (nextPrayerDateTime == null ||
        currentPrayerDateTime == null ||
        nextPrayerDateTime.isBefore(now)) {
      return 0.0.obs;
    }

    final totalDuration =
        nextPrayerDateTime.difference(currentPrayerDateTime).inMinutes;
    final elapsedDuration = now.difference(currentPrayerDateTime).inMinutes;

    double percentage =
        ((elapsedDuration / totalDuration) * 100).clamp(0, 100).toDouble();
    return percentage.obs;
  }

  /// حساب التقدم من صلاة الفجر إلى صلاة العشاء
  /// Calculate progress from Fajr to Isha prayer
  RxDouble get getPrayerDayProgress {
    final now = DateTime.now(); // استخدام الوقت الحالي الفعلي
    final PrayerTimes? prayerTimes = state.prayerTimes;

    if (prayerTimes == null) {
      return 0.0.obs;
    }

    final DateTime fajrTime = prayerTimes.fajr;
    final DateTime ishaTime = prayerTimes.isha;

    // إذا كان الوقت الحالي قبل الفجر، فالتقدم يكون 0
    if (now.isBefore(fajrTime)) {
      return 0.0.obs;
    }

    // إذا كان الوقت الحالي بعد العشاء، فالتقدم يكون 100%
    if (now.isAfter(ishaTime)) {
      return 100.0.obs;
    }

    // حساب المدة الإجمالية من الفجر إلى العشاء بالدقائق
    final totalDuration = ishaTime.difference(fajrTime).inMinutes;

    // حساب المدة المنقضية من الفجر حتى الآن بالدقائق
    final elapsedDuration = now.difference(fajrTime).inMinutes;

    // تجنب القسمة على صفر
    if (totalDuration <= 0) {
      return 0.0.obs;
    }

    // حساب النسبة المئوية (من 0 إلى 100)
    double percentage =
        ((elapsedDuration / totalDuration) * 100).clamp(0, 100).toDouble();

    return percentage.obs;
  }

  /// حساب قطع المؤشر (Gauge Segments) بناءً على أوقات الصلوات
  /// Calculate gauge segments based on prayer times
  List<GaugeSegment> get getPrayerGaugeSegments {
    final PrayerTimes? prayerTimes = state.prayerTimes;

    if (prayerTimes == null) {
      return [];
    }

    // أوقات الصلوات الخمس (من الفجر إلى العشاء)
    final List<DateTime> prayers = [
      prayerTimes.fajr, // الفجر
      prayerTimes.sunrise, // الشروق
      prayerTimes.dhuhr, // الظهر
      prayerTimes.asr, // العصر
      prayerTimes.maghrib, // المغرب
      prayerTimes.isha, // العشاء
    ];

    // ألوان مختلفة لكل فترة صلاة
    final List<GaugeAxisGradient> prayerColors = [
      const GaugeAxisGradient(
        colors: [Color(0xff000000), Color(0xff4b4c4f)],
        colorStops: [0.0, 1.0],
      ), // الفجر إلى الشروق - أزرق داكن (فجر)
      const GaugeAxisGradient(
        colors: [Color(0xffB8E0EA), Color(0xff0098EE)],
        colorStops: [0.0, 1.0],
      ), // الشروق إلى الظهر - ذهبي (صباح)
      const GaugeAxisGradient(
        colors: [Color(0xff0098EE), Color(0xffc5deed)],
        colorStops: [0.0, 1.0],
      ), // الظهر إلى العصر - أزرق فاتح (ظهيرة)
      const GaugeAxisGradient(
        colors: [Color(0xfff2dfd9), Color(0xfff8a159)],
        colorStops: [0.0, 1.0],
      ), // العصر إلى المغرب - برتقالي (عصر)
      const GaugeAxisGradient(
        colors: [Color(0xff4b4c4f), Color(0xff000000)],
        colorStops: [0.0, 1.0],
      ), // المغرب إلى العشاء - بنفسجي (مغرب)
    ];

    final DateTime fajrTime = prayers[0];
    final DateTime ishaTime = prayers[5];
    final int totalDuration = ishaTime.difference(fajrTime).inMinutes;

    if (totalDuration <= 0) {
      return [];
    }

    List<GaugeSegment> segments = [];
    double currentFrom = 0.0;

    // إنشاء segment لكل فترة بين صلاتين متتاليتين
    // Create segment for each period between two consecutive prayers
    for (int i = 0; i < prayers.length - 1; i++) {
      // حساب مدة الفترة بين الصلاة الحالية والتالية بالدقائق
      // Calculate duration between current and next prayer in minutes
      final int prayerDuration =
          prayers[i + 1].difference(prayers[i]).inMinutes;

      // حساب النسبة المئوية لهذه الفترة من إجمالي اليوم
      // Calculate percentage of this period from total day
      final double prayerPercentage = (prayerDuration / totalDuration) * 100;
      final double currentTo = currentFrom + prayerPercentage;

      segments.add(
        GaugeSegment(
          from: currentFrom,
          to: currentTo,
          gradient: prayerColors[i],
          cornerRadius: const Radius.circular(8.0),
        ),
      );

      currentFrom = currentTo; // البداية التالية تكون نهاية الحالية
    }

    return segments;
  }

  /// الحصول على اسم الفترة الحالية للصلاة
  /// Get current prayer period name
  String get getCurrentPrayerPeriodName {
    final now = DateTime.now();
    final PrayerTimes? prayerTimes = state.prayerTimes;

    if (prayerTimes == null) {
      return 'غير محدد';
    }

    if (now.isBefore(prayerTimes.fajr)) {
      return 'قبل الفجر';
    } else if (now.isBefore(prayerTimes.sunrise)) {
      return 'فترة الفجر';
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      return 'فترة الصباح';
    } else if (now.isBefore(prayerTimes.asr)) {
      return 'فترة الظهيرة';
    } else if (now.isBefore(prayerTimes.maghrib)) {
      return 'فترة العصر';
    } else if (now.isBefore(prayerTimes.isha)) {
      return 'فترة المغرب';
    } else {
      return 'فترة العشاء';
    }
  }

  /// الحصول على لون الفترة الحالية للصلاة
  /// Get current prayer period color
  Color get getCurrentPrayerPeriodColor {
    final now = DateTime.now();
    final PrayerTimes? prayerTimes = state.prayerTimes;

    if (prayerTimes == null) {
      return const Color(0xFF9E9E9E);
    }

    if (now.isBefore(prayerTimes.fajr)) {
      return const Color(0xFF263238); // رمادي داكن قبل الفجر
    } else if (now.isBefore(prayerTimes.sunrise)) {
      return const Color(0xFF1A237E); // أزرق داكن (فجر)
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      return const Color(0xFFFFB300); // ذهبي (صباح)
    } else if (now.isBefore(prayerTimes.asr)) {
      return const Color(0xFF0288D1); // أزرق فاتح (ظهيرة)
    } else if (now.isBefore(prayerTimes.maghrib)) {
      return const Color(0xFFFF6F00); // برتقالي (عصر)
    } else if (now.isBefore(prayerTimes.isha)) {
      return const Color(0xFF7B1FA2); // بنفسجي (مغرب)
    } else {
      return const Color(0xFF4A148C); // بنفسجي داكن (عشاء)
    }
  }

  RxDouble getTimeLeftForPrayerByIndex(int index) {
    final now = DateTime.now();

    if (index < 0 || index >= prayerNameList.length) {
      throw ArgumentError(
          'Index out of range, must be between 0 and ${prayerNameList.length - 1}.');
    }

    Map<String, dynamic> targetPrayerMap = prayerNameList[index];
    DateTime? targetPrayerDateTime = targetPrayerMap['dateTime'];

    // إذا كانت الصلاة المطلوبة قد مرت اليوم، نضيف يوم واحد لحساب الصلاة القادمة
    if (targetPrayerDateTime != null) {
      targetPrayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        targetPrayerDateTime.hour,
        targetPrayerDateTime.minute,
      );
      if (targetPrayerDateTime.isBefore(now)) {
        targetPrayerDateTime =
            targetPrayerDateTime.add(const Duration(days: 1));
      }
    }

    if (targetPrayerDateTime == null) {
      return 0.0.obs;
    }

    final totalDuration = targetPrayerDateTime.difference(now).inMinutes;
    final fullDayDuration = const Duration(days: 1).inMinutes;

    // حساب النسبة المئوية المتبقية من 0 إلى 100 (كلما قل الوقت المتبقي زادت النسبة المئوية)
    double percentageLeft =
        (((fullDayDuration - totalDuration) / fullDayDuration) * 100)
            .clamp(0, 100)
            .toDouble();
    return percentageLeft.obs;
  }

  LinearGradient getNowColorByIndex(int index) {
    if (index == 0) {
      return const LinearGradient(
          colors: [Color(0xff0a0f29), Color(0xff000000)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 1) {
      return const LinearGradient(
          colors: [Color(0xffbababa), Color(0xff232323)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 2) {
      return const LinearGradient(
          colors: [Color(0xffB8E0EA), Color(0xff0098EE)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 3) {
      return const LinearGradient(
          colors: [Color(0xffB8E0EA), Color(0xff0098EE)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 4) {
      return const LinearGradient(
          colors: [Color(0xffF17148), Color(0xffCF4B6D)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 5) {
      return const LinearGradient(
          colors: [Color(0xff0a0f29), Color(0xff000000)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 6) {
      return const LinearGradient(
          colors: [Color(0xff0a0f29), Color(0xff000000)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else if (index == 7) {
      return const LinearGradient(
          colors: [Color(0xff0a0f29), Color(0xff000000)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    } else {
      state.backgroundColor.value = const Color(0xffbababa);
      return const LinearGradient(
          colors: [Color(0xffbababa), Color(0xff232323)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter);
    }
  }

  Rx<Duration> getDurationLeftForPrayerByIndex(int index) {
    final now = DateTime.now();

    if (index < 0 || index >= prayerNameList.length) {
      throw ArgumentError(
          'Index out of range, must be between 0 and ${prayerNameList.length - 1}.');
    }

    Map<String, dynamic> targetPrayerMap = prayerNameList[index];
    DateTime? targetPrayerDateTime = targetPrayerMap['dateTime'];

    // إذا كانت الصلاة المطلوبة قد مرت اليوم، نضيف يوم واحد لحساب الصلاة القادمة
    if (targetPrayerDateTime != null) {
      targetPrayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        targetPrayerDateTime.hour,
        targetPrayerDateTime.minute,
      );
      if (targetPrayerDateTime.isBefore(now)) {
        targetPrayerDateTime =
            targetPrayerDateTime.add(const Duration(days: 1));
      }
    }

    if (targetPrayerDateTime == null) {
      return Duration.zero.obs;
    }

    final durationLeft = targetPrayerDateTime.difference(now);
    return durationLeft.obs;
  }

  Duration get getTimeLeftForNextPrayer {
    final now = DateTime.now();
    final Prayer currentPrayer = state.prayerTimes!.currentPrayer();
    final Prayer? nextPrayer;

    if (currentPrayer == Prayer.isha) {
      nextPrayer = Prayer.fajr;
    } else {
      nextPrayer = state.prayerTimes!.nextPrayer();
    }
    DateTime? nextPrayerDateTime = state.prayerTimes!.timeForPrayer(nextPrayer);
    if (nextPrayer == Prayer.fajr && currentPrayer == Prayer.isha) {
      nextPrayerDateTime = nextPrayerDateTime?.add(const Duration(days: 1));
    }
    if (nextPrayerDateTime == null || nextPrayerDateTime.isBefore(now)) {
      return Duration.zero;
    }
    return nextPrayerDateTime.difference(now);
  }

  DateTime get getTimeLeftForHomeWidgetNextPrayer {
    final now = DateTime.now();
    final Prayer nextPrayer = state.prayerTimes!.nextPrayer();
    final DateTime? nextPrayerDateTime =
        state.prayerTimes!.timeForPrayer(nextPrayer);
    if (nextPrayerDateTime == null || nextPrayerDateTime.isBefore(now)) {
      return now.add(const Duration(hours: 1));
    }
    return nextPrayerDateTime;
  }

  /// دالة لمعرفة رقم الصلاة السابقة بدون استدعاء update
  /// Function to get the previous prayer index without calling update.
  int getPreviousPrayerByDateTime() {
    final currentPrayerIndex = getCurrentPrayerByDateTime();
    return (currentPrayerIndex - 1) < 0 ? 7 : (currentPrayerIndex - 1);
  }

  /// دالة لمعرفة رقم الصلاة القادمة بدون استدعاء update
  /// Function to get the next prayer index without calling update.
  RxInt getNextPrayerByDateTime() {
    final currentPrayerIndex = getCurrentPrayerByDateTime();
    return ((currentPrayerIndex + 1) > 7 ? 0 : (currentPrayerIndex + 1)).obs;
  }

  PrayerDetail get getNextPrayerDetail => getPrayerDetails(isNextPrayer: true);

  LinearGradient getTimeNowColor() {
    DateTime sunrise = state.prayerTimes!.sunrise;
    DateTime dhuhr = state.prayerTimes!.dhuhr;
    DateTime maghrib = state.prayerTimes!.maghrib;

    if (state.now.isAfter(sunrise.subtract(const Duration(minutes: 10))) &&
        state.now.isBefore(sunrise.add(const Duration(minutes: 30)))) {
      return const LinearGradient(
          colors: [Color(0xffbababa), Color(0xff232323)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight);
    } else if (state.now.isAfter(sunrise.add(const Duration(minutes: 30))) &&
        state.now.isBefore(dhuhr.subtract(const Duration(hours: 1)))) {
      return const LinearGradient(
          colors: [Color(0xffB8E0EA), Color(0xff0098EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight);
    } else if (state.now.isAfter(dhuhr.subtract(const Duration(hours: 1))) &&
        state.now.isBefore(maghrib.subtract(const Duration(hours: 1)))) {
      return const LinearGradient(
          colors: [Color(0xffB8E0EA), Color(0xff0098EE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter);
    } else if (state.now.isAfter(maghrib.subtract(const Duration(hours: 1))) &&
        state.now.isBefore(maghrib.add(const Duration(minutes: 20)))) {
      return const LinearGradient(
          colors: [Color(0xffF17148), Color(0xffCF4B6D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter);
    } else if (state.now.isAfter(maghrib.add(const Duration(minutes: 20))) ||
        state.now.isBefore(sunrise.subtract(const Duration(minutes: 10)))) {
      return const LinearGradient(
          colors: [Color(0xff0a0f29), Color(0xff000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight);
    } else {
      state.backgroundColor.value = const Color(0xffbababa);
      return const LinearGradient(
          colors: [Color(0xffbababa), Color(0xff232323)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight);
    }
  }

  /// دالة لمعرفة أوقات النهي عن الصلاة
  /// Function to get prayer prohibition times
  RxBool get prohibitionTimesBool {
    PrayerTimes dateTime = state.prayerTimes!;

    // 1- من طلوع الفجر الصادق حتى تطلع الشمس (أو من بعد صلاة الفجر)
    // From true dawn until sunrise (or from after Fajr prayer)
    if (state.now.isAfter(dateTime.fajr) &&
        state.now.isBefore(dateTime.sunrise)) {
      state.prohibitionTimesIndex.value = 0;
      return true.obs;
    }

    // 2- من طلوع الشمس حتى ترتفع قيد رمح (تقريباً 15-20 دقيقة)
    // From sunrise until the sun rises a spear's length (approximately 15-20 minutes)
    // else if (state.now.isAfter(sunrise) &&
    //     state.now.isBefore(sunrise.add(const Duration(minutes: 20)))) {
    //   state.prohibitionTimesIndex.value = 1;
    //   return true.obs;
    // }

    // 5- حين يقوم قائم الظهيرة وتتوسط الشمس كبد السماء قبل الزوال (5-10 دقائق قبل الظهر)
    // When the sun is at its zenith before midday (5-10 minutes before Dhuhr)
    else if (state.now
            .isAfter(dateTime.dhuhr.subtract(const Duration(minutes: 10))) &&
        state.now.isBefore(dateTime.dhuhr)) {
      state.prohibitionTimesIndex.value = 1;
      return true.obs;
    }

    // 3- من بعد صلاة العصر حتى تميل إلى الغروب
    // From after Asr prayer until the sun starts to set
    else if (state.now.isAfter(dateTime.asr) &&
        state.now
            .isBefore(dateTime.maghrib.subtract(const Duration(minutes: 15)))) {
      state.prohibitionTimesIndex.value = 2;
      return true.obs;
    }

    // 4- من حين تميل الشمس للغروب حتى تغرب (15 دقيقة قبل المغرب)
    // When the sun starts to set until it sets (15 minutes before Maghrib)
    // else if (state.now.isAfter(maghrib.subtract(const Duration(minutes: 15))) &&
    //     state.now.isBefore(maghrib)) {
    //   state.prohibitionTimesIndex.value = 4;
    //   return true.obs;
    // }
    else {
      state.prohibitionTimesIndex.value = -1; // لا يوجد وقت نهي
      return false.obs;
    }
  }

  void get getShared {
    state.isHanafi = state.box.read(SHAFI) ?? true;
    state.highLatitudeRuleIndex.value = state.box.read(HIGH_LATITUDE_RULE) ?? 0;
    state.autoCalculationMethod.value =
        state.box.read(AUTO_CALCULATION) ?? true;
    // state.adjustments[0].value = state.box.read(ADJUSTMENT_FAJR) ?? 0;
    // state.adjustments[1].value = state.box.read(ADJUSTMENT_DHUHR) ?? 0;
    // state.adjustments[2].value = state.box.read(ADJUSTMENT_ASR) ?? 0;
    // state.adjustments[3].value = state.box.read(ADJUSTMENT_MAGHRIB) ?? 0;
    // state.adjustments[4].value = state.box.read(ADJUSTMENT_ISHA) ?? 0;
    // state.adjustments[5].value = state.box.read(ADJUSTMENT_THIRD) ?? 0;
    // state.adjustments[6].value = state.box.read(ADJUSTMENT_MIDNIGHT) ?? 0;
    // state.adjustments[7].value = state.box.read(ADJUSTMENT_SUNRISE) ?? 0;
  }

  Duration get getDelayUntilNextIsha {
    DateTime nextIsha = state.prayerTimes!.isha;

    // If today's Isha time is already passed, schedule for tomorrow
    if (state.now.isAfter(nextIsha)) {
      nextIsha = nextIsha.add(const Duration(minutes: 15));
    }

    return nextIsha.difference(state.now);
  }

  Madhab getMadhab(bool madhab) {
    if (madhab) {
      return Madhab.shafi;
    } else {
      return Madhab.hanafi;
    }
  }

  Future<HighLatitudeRule> getHighLatitudeRule(int index) async {
    // إذا كانت الحالة المطلوبة مفعلة بالفعل، لا نفعل شيئًا
    if (index == 0) {
      state.middleOfTheNight.value = true;
      state.seventhOfTheNight.value = false;
      state.twilightAngle.value = false;
      state.box.write(HIGH_LATITUDE_RULE, 0);
      log('HighLatitudeRule set to middleOfTheNight', name: 'AdhanGetters');
    } else if (index == 1) {
      state.middleOfTheNight.value = false;
      state.seventhOfTheNight.value = true;
      state.twilightAngle.value = false;
      state.box.write(HIGH_LATITUDE_RULE, 1);
      log('HighLatitudeRule set to seventhOfTheNight', name: 'AdhanGetters');
    } else if (index == 2) {
      state.middleOfTheNight.value = false;
      state.seventhOfTheNight.value = false;
      state.twilightAngle.value = true;
      state.box.write(HIGH_LATITUDE_RULE, 2);
      log('HighLatitudeRule set to twilightAngle', name: 'AdhanGetters');
    } else {
      log('No change in HighLatitudeRule', name: 'AdhanGetters');
      return getHighLatitudeRuleFromIndex(
          index); // نرجع القيمة الحالية دون تغيير
    }
    // initializeStoredAdhan();
    return getHighLatitudeRuleFromIndex(index);
  }

  HighLatitudeRule getHighLatitudeRuleFromIndex(int index) {
    switch (index) {
      case 0:
        return HighLatitudeRule.middle_of_the_night;
      case 1:
        return HighLatitudeRule.seventh_of_the_night;
      case 2:
        return HighLatitudeRule.twilight_angle;
      default:
        return HighLatitudeRule.middle_of_the_night; // القيمة الافتراضية
    }
  }

  int getCurrentPrayerByDateTime() {
    final when = state.now;
    final prayer = state.prayerTimes;
    final sunnah = state.sunnahTimes!;
    int value = 0;
    if (when.isBefore(prayer!.fajr)) {
      value = 0; // fajr
    } else if (when.isBefore(prayer.sunrise)) {
      value = 1; // sunrise
    } else if (when.isBefore(prayer.dhuhr)) {
      value = 2; // dhuhr
    } else if (when.isBefore(prayer.asr)) {
      value = 3; // asr
    } else if (when.isBefore(prayer.maghrib)) {
      value = 4; //maghrib
    } else if (when.isBefore(prayer.isha)) {
      value = 5; // isha
    } else if (when.isBefore(sunnah.middleOfTheNight)) {
      value = 6; // midnightTime
    } else if (when.isBefore(sunnah.lastThirdOfTheNight)) {
      value = 7; // lastQuarterOfNight
    } else {
      value = 0; // none
    }
    return value;
  }

  Future<String> getPrayerTime(int prayerIndex, DateTime prayerTime) async {
    try {
      DateTime adjustedPrayerTime = prayerTime;
      return await DateFormatter.justTime(adjustedPrayerTime);
    } catch (e) {
      return '';
    }
  }

  IconData getPrayerIcon(String prayerName) {
    String notiType =
        GetStorage('AdhanSounds').read('scheduledAdhan_$prayerName') ??
            'nothing';
    if ('nothing' == notiType) {
      return notificationOptions[0]['icon'];
    } else if ('silent' == notiType) {
      return notificationOptions[1]['icon'];
    } else if ('bell' == notiType) {
      return notificationOptions[2]['icon'];
    } else if ('sound' == notiType) {
      return notificationOptions[3]['icon'];
    } else {
      return notificationOptions[0]['icon'];
    }
  }
}
