part of '../../prayers.dart';

const allowedMaxAdjustment = 30;
const allowedMinAdjustment = -30;

class AdhanState {
  /// -------- [Variables] ----------
  final box = GetStorage();
  PrayerTimes? prayerTimes;
  String nextPrayerTime = '';
  // استخدم getter لضمان قراءة الوقت الحالي دائمًا بدل تجميده لحظة إنشاء الحالة
  DateTime get now => DateTime.now();
  RxString countdownTime = ''.obs;
  SunnahTimes? sunnahTimes;
  // HijriDateConfig hijriDateNow = EventController.instance.hijriNow;
  late Coordinates coordinates;
  late DateComponents dateComponents;
  late CalculationParameters params;
  RxDouble timeProgress = 0.0.obs;
  Timer? timer;
  RxString fajrTime = ''.obs;
  RxString sunriseTime = ''.obs;
  RxString dhuhrTime = ''.obs;
  RxString asrTime = ''.obs;
  RxString maghribTime = ''.obs;
  RxString ishaTime = ''.obs;
  RxString lastThirdTime = ''.obs;
  RxString midnightTime = ''.obs;
  bool isHanafi = true;
  RxInt highLatitudeRuleIndex = 0.obs;
  RxBool twilightAngle = false.obs;
  RxBool middleOfTheNight = true.obs;
  RxBool seventhOfTheNight = true.obs;
  PrayerTimes? prayerTimesNow;
  RxBool autoCalculationMethod = true.obs;
  RxString calculationMethodString = 'أم القرى'.obs;
  RxString selectedCountry = 'Saudi Arabia'.obs;
  List<String> countries = [];
  late final HighLatitudeRule highLatitudeRule;
  RxInt adjustmentIndex = RxInt(0);
  OurPrayerAdjustments adjustments = OurPrayerAdjustments();
  Future<List<String>>? countryListFuture;
  RxInt prohibitionTimesIndex = 0.obs;
  RxBool isPrayerTimesInitialized = false.obs;
  RxBool isLoadingPrayerData = false.obs;
  Rx<Color> backgroundColor = const Color(0xffB8E0EA).obs;
  var selectedDate = DateTime.now();

  /// اسم المدينة والدولة بلغة المستخدم
  RxString localizedCity = ''.obs;
  RxString localizedCountry = ''.obs;

  // أوقات الصلاة للتاريخ المختار / Prayer times for selected date
  PrayerTimes? selectedDatePrayerTimes;
  SunnahTimes? selectedDateSunnahTimes;
  RxString selectedDateFajrTime = ''.obs;
  RxString selectedDateSunriseTime = ''.obs;
  RxString selectedDateDhuhrTime = ''.obs;
  RxString selectedDateAsrTime = ''.obs;
  RxString selectedDateMaghribTime = ''.obs;
  RxString selectedDateIshaTime = ''.obs;
  RxString selectedDateLastThirdTime = ''.obs;
  RxString selectedDateMidnightTime = ''.obs;
  String location = '';
}

class OurPrayerAdjustments extends PrayerAdjustments {
  int midnight = 0;
  int lastThird = 0;
  List<int> get values =>
      [fajr, sunrise, dhuhr, asr, maghrib, isha, midnight, lastThird];
  OurPrayerAdjustments({
    super.fajr = 0,
    super.sunrise = 0,
    super.dhuhr = 0,
    super.asr = 0,
    super.maghrib = 0,
    super.isha = 0,
    this.midnight = 0,
    this.lastThird = 0,
  });

  int getAdjustmentByIndex(int index) {
    return getAdjustmentByPrayerName(
        AdhanController.instance.prayerNameList[index]['sharedAdjustment']!);
  }

  int getAdjustmentByPrayerName(String prayerName) {
    switch (prayerName) {
      case 'ADJUSTMENT_FAJR':
        return fajr;
      case 'ADJUSTMENT_SUNRISE':
        return sunrise;
      case 'ADJUSTMENT_DHUHR':
        return dhuhr;
      case 'ADJUSTMENT_ASR':
        return asr;
      case 'ADJUSTMENT_MAGHRIB':
        return maghrib;
      case 'ADJUSTMENT_ISHA':
        return isha;
      case 'ADJUSTMENT_MIDNIGHT':
        return midnight;
      case 'ADJUSTMENT_LAST_THIRD':
        return lastThird;
      default:
        log('Unknown prayer name: $prayerName');
        return 0;
    }
  }

  factory OurPrayerAdjustments.fromGetStorage() {
    final box = AdhanController.instance.state.box;
    return OurPrayerAdjustments(
      fajr: box.read('ADJUSTMENT_FAJR') ?? 0,
      sunrise: box.read('ADJUSTMENT_SUNRISE') ?? 0,
      dhuhr: box.read('ADJUSTMENT_DHUHR') ?? 0,
      asr: box.read('ADJUSTMENT_ASR') ?? 0,
      maghrib: box.read('ADJUSTMENT_MAGHRIB') ?? 0,
      isha: box.read('ADJUSTMENT_ISHA') ?? 0,
      midnight: box.read('ADJUSTMENT_MIDNIGHT') ?? 0,
      lastThird: box.read('ADJUSTMENT_LAST_THIRD') ?? 0,
    );
  }

  factory OurPrayerAdjustments.fromJson(Map<String, dynamic> json) {
    return OurPrayerAdjustments(
      fajr: json['fajr'] ?? 0,
      sunrise: json['sunrise'] ?? 0,
      dhuhr: json['dhuhr'] ?? 0,
      asr: json['asr'] ?? 0,
      maghrib: json['maghrib'] ?? 0,
      isha: json['isha'] ?? 0,
      midnight: json['midnight'] ?? 0,
      lastThird: json['lastThird'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'midnight': midnight,
      'lastThird': lastThird,
    };
  }

  // add adjustment by prayer name
  void addAdjustment(String prayerName, int value) {
    switch (prayerName) {
      case 'ADJUSTMENT_FAJR':
        fajr = (fajr + value).clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_SUNRISE':
        sunrise =
            (sunrise + value).clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_DHUHR':
        dhuhr =
            (dhuhr + value).clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_ASR':
        asr = (asr + value).clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_MAGHRIB':
        maghrib =
            (maghrib + value).clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_ISHA':
        isha = (isha + value).clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_MIDNIGHT':
        midnight = (midnight + value)
            .clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      case 'ADJUSTMENT_LAST_THIRD':
        lastThird = (lastThird + value)
            .clamp(allowedMinAdjustment, allowedMaxAdjustment);
        break;
      default:
        log('Unknown prayer name: $prayerName');
    }
    // Update the adjustments in the box
    _editAdjustmentsInBox();
  }

  // edit the adjustments in the box
  Future<void> _editAdjustmentsInBox() async {
    AdhanController.instance.state.box.write('ADJUSTMENT_FAJR', fajr);
    AdhanController.instance.state.box.write('ADJUSTMENT_SUNRISE', sunrise);
    AdhanController.instance.state.box.write('ADJUSTMENT_DHUHR', dhuhr);
    AdhanController.instance.state.box.write('ADJUSTMENT_ASR', asr);
    AdhanController.instance.state.box.write('ADJUSTMENT_MAGHRIB', maghrib);
    AdhanController.instance.state.box.write('ADJUSTMENT_ISHA', isha);
    AdhanController.instance.state.box.write('ADJUSTMENT_MIDNIGHT', midnight);
    AdhanController.instance.state.box.write('ADJUSTMENT_THIRD', lastThird);
  }
}
