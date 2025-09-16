import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/background_services.dart';
import '../../../core/services/location/locations.dart';
import '../../../core/utils/constants/shared_preferences_constants.dart';
import '../../prayers/prayers.dart';
import '../../qibla/qibla.dart';
import 'general_state.dart';

class GeneralController extends GetxController {
  static GeneralController get instance => Get.isRegistered<GeneralController>()
      ? Get.find<GeneralController>()
      : Get.put<GeneralController>(GeneralController());

  GeneralState state = GeneralState();

  // @override
  @override
  void onInit() async {
    state.activeLocation.value = state.box.read(ACTIVE_LOCATION) ?? false;

    if (state.activeLocation.value) {
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        await NominatimGeocoding.init();
        log('Location service is not supported on this platform');
      }
      // استرداد بيانات الموقع المحفوظة
      // Restore saved location data
      Location.instance.restoreFromStorage();
      await initLocation();

      if (Platform.isIOS || Platform.isAndroid) {
        await BGServices().registerTask();
        // await HijriWidgetConfig.initialize();
        // await PrayersWidgetConfig.initialize();
        // Future.delayed(const Duration(seconds: 5)).then((_) {
        //   HijriWidgetConfig().updateHijriDate();
        //   PrayersWidgetConfig().updatePrayersDate();
        // });
        await BackgroundTaskHandler.initializeHandler();
      }
    }
    Future.delayed(const Duration(seconds: 1)).then((_) async {
      try {
        await WakelockPlus.enable();
      } catch (e) {
        log('Failed to enable wakelock: $e');
      }
    });
    // WidgetsBinding.instance.addObserver(this);
    // HijriWidgetConfig().updateHijriDate();
    // PrayersWidgetConfig.onPrayerWidgetClicked();
    // HijriWidgetConfig.onHijriWidgetClicked();
    // Future.delayed(
    //     const Duration(seconds: 10), () => RateAppHelper.initRateMyApp());

    super.onInit();
  }

  // @override
  // void onClose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.onClose();
  // }

  /// -------- [Methods] ----------

  /// Greeting
  void updateGreeting() {
    final now = DateTime.now();
    final isMorning = now.hour < 12;
    state.greeting.value =
        isMorning ? 'صبحكم الله بالخير' : 'مساكم الله بالخير';
  }

  /// -------- [PrayersMethods] ----------

  Future<void> initLocation() async {
    try {
      state.isLocationLoading.value = true;
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        await NominatimGeocoding.init();
        log('Location service is not supported on this platform');
      }
      await LocationHelper.instance.getPositionDetails();
      // Get.forceAppUpdate();
      state.activeLocation.value = true;
      state.box.write(ACTIVE_LOCATION, true);
      state.box.write(IS_LOCATION_ACTIVE, true);
      state.box.write(FIRST_LAUNCH, true);
      // AdhanController.instance.initializeAdhanVariables();
      AdhanController.instance.initializeStoredAdhan();
      // AdhanController.instance.update(['init_athan', 'update_progress']);
      // Future.delayed(const Duration(seconds: 2))
      //     .then((_) => PrayersWidgetConfig().updatePrayersDate());
    } catch (e) {
      log(e.toString(), name: 'Main', error: e);
    } finally {
      state.isLocationLoading.value = false;
    }
  }

  void cancelLocation() {
    state.activeLocation.value = false;
    state.box.write(ACTIVE_LOCATION, false);
    state.box.write(IS_LOCATION_ACTIVE, false);
    state.box.write(FIRST_LAUNCH, true);
    // SplashScreenController.instance.state.customWidget.value = 2;
    log('Location cancelled', name: 'Main');
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState states) async {
  //   log('AppLifecycleState: $states');
  //   if (states == AppLifecycleState.resumed && state.activeLocation.value) {
  //     bool isEnabled = await LocationHelper.instance.isLocationServiceEnabled();
  //     if (isEnabled && !state.activeLocation.value) {
  //       await initLocation().then((_) async {
  //         state.activeLocation.value = true;
  //         await AdhanController.instance.initializeAdhan();
  //         Future.delayed(const Duration(seconds: 2))
  //             .then((_) => PrayersWidgetConfig().updatePrayersDate());
  //         state.box.write(ACTIVE_LOCATION, true);
  //         AdhanController.instance.update();
  //       });
  //     }
  //   }
  // }

  Future<void> toggleLocationService() async {
    if (!state.activeLocation.value) {
      bool isEnabled = await LocationHelper.instance.isLocationServiceEnabled();
      if (!isEnabled) {
        await LocationHelper.instance.openLocationSettings;
      } else if (isEnabled) {
        await LocationHelper.instance.openAppSettings;
        await Future.delayed(const Duration(seconds: 3));
        if (await LocationHelper.instance.checkPermission()) {
          await initLocation().then((_) async {
            state.activeLocation.value = true;
            await AdhanController.instance.initializeStoredAdhan().then((_) {
              state.box.write(ACTIVE_LOCATION, true);
              Get.forceAppUpdate();
            });
          });
        }
        log('Location services are already enabled.');
      } else {
        await initLocation().then((_) async {
          state.activeLocation.value = true;
          await AdhanController.instance.initializeStoredAdhan().then((_) {
            state.box.write(ACTIVE_LOCATION, true);
            Get.forceAppUpdate();
          });
        });
        log('Location services are already enabled.');
      }
      AdhanController.instance.update();
    } else {
      state.activeLocation.value = false;
      state.box.write(ACTIVE_LOCATION, false);
      Get.forceAppUpdate();
    }
  }

  /// تحديث الموقع وإعادة حساب أوقات الصلاة
  /// Update location and recalculate prayer times
  Future<bool> updateLocationAndPrayerTimes() async {
    try {
      log('Updating location and prayer times...', name: 'GeneralController');

      // التحقق من تفعيل خدمة الموقع
      // Check if location service is enabled
      if (!state.activeLocation.value) {
        log('Location service is not active', name: 'GeneralController');
        return false;
      }

      // تحديث الموقع
      // Update location
      await initLocation();

      // إعادة حساب أوقات الصلاة
      // Recalculate prayer times
      await AdhanController.instance.clearCacheAndRecalculate();
      await QiblaController.instance.updateQiblaDirection();

      // تحديث الويدجت
      // Update widget
      // PrayersWidgetConfig().updatePrayersDate();

      log('Location and prayer times updated successfully',
          name: 'GeneralController');
      return true;
    } catch (e) {
      log('Error updating location and prayer times: $e',
          name: 'GeneralController');
      return false;
    }
  }
}
