import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

import '../../../core/services/background_services.dart';
import '../../../core/services/location/locations.dart';
import '../../../core/utils/constants/shared_preferences_constants.dart';
import '../../../core/widgets/home_widget/home_widget.dart';
import '../../prayers/prayers.dart';
import '../../qibla/qibla.dart';
import '../../splash/splash.dart';
import 'general_state.dart';

class GeneralController extends GetxController with WidgetsBindingObserver {
  static GeneralController get instance => Get.isRegistered<GeneralController>()
      ? Get.find<GeneralController>()
      : Get.put<GeneralController>(GeneralController());

  GeneralState state = GeneralState();
  Completer<void>? _settingsCompleter;

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
      await initLocation(isOpenSettings: false);

      if (Platform.isIOS || Platform.isAndroid) {
        await BGServices().registerTask();
        // await HijriWidgetConfig.initialize();
        await PrayersWidgetConfig.initialize();
        Future.delayed(const Duration(seconds: 5)).then((_) {
          // HijriWidgetConfig().updateHijriDate();
          PrayersWidgetConfig().updatePrayersDate();
        });
        await BackgroundTaskHandler.initializeHandler();
      }
    }
    WidgetsBinding.instance.addObserver(this);
    // HijriWidgetConfig().updateHijriDate();
    // PrayersWidgetConfig.onPrayerWidgetClicked();
    // HijriWidgetConfig.onHijriWidgetClicked();
    // Future.delayed(
    //     const Duration(seconds: 10), () => RateAppHelper.initRateMyApp());

    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// -------- [Methods] ----------

  /// Greeting
  void updateGreeting() {
    final now = DateTime.now();
    final isMorning = now.hour < 12;
    state.greeting.value =
        isMorning ? 'صبحكم الله بالخير' : 'مساكم الله بالخير';
  }

  /// -------- [PrayersMethods] ----------

  // ✅ هذه الدالة تُستدعى عند تغيير حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    super.didChangeAppLifecycleState(appState);

    // عندما يعود المستخدم للتطبيق
    if (appState == AppLifecycleState.resumed) {
      if (_settingsCompleter != null && !_settingsCompleter!.isCompleted) {
        _settingsCompleter!.complete();
      }

      // تحديث الـ widget عند عودة التطبيق من الخلفية
      // Update widget when app returns from background
      if (state.activeLocation.value &&
          (Platform.isIOS || Platform.isAndroid)) {
        Future.delayed(const Duration(milliseconds: 500), () {
          PrayersWidgetConfig().updatePrayersDate();
          log('Widget updated on app resume', name: 'GeneralController');
        });
      }
    }
  }

  // ✅ دالة لفتح الإعدادات والانتظار حتى العودة
  Future<void> _openSettingsAndWait() async {
    _settingsCompleter = Completer<void>();

    await Geolocator.openAppSettings();

    // انتظار حتى يعود المستخدم للتطبيق
    await _settingsCompleter!.future;

    // انتظار قليل للتأكد من تحديث الأذونات
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> initLocation({bool? isOpenSettings = true}) async {
    try {
      state.isLocationLoading.value = true;
      await Geolocator.checkPermission();
      LocationPermission permission = await Geolocator.checkPermission();
      bool isEnabled = await Geolocator.isLocationServiceEnabled();

      // حالة الرفض الدائم - فتح الإعدادات والانتظار
      if (isEnabled &&
          isOpenSettings! &&
          permission == LocationPermission.deniedForever) {
        // فتح الإعدادات والانتظار حتى العودة
        await _openSettingsAndWait();

        // ✅ إعادة التحقق من الإذن بعد العودة
        permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          await _activateLocation();
        } else {
          // المستخدم لم يفعّل الموقع
          log('User did not enable location permission');
        }
      } else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // ✅ الإذن موجود - تفعيل مباشر

        await Geolocator.requestPermission().then((_) async {
          await _activateLocation();
          if (Platform.isMacOS) {
            Get.forceAppUpdate();
          }
        });
      } else if (permission == LocationPermission.denied) {
        // ✅ طلب الإذن لأول مرة
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          await Geolocator.requestPermission().then((_) async {
            await _activateLocation();
            if (Platform.isMacOS) {
              Get.forceAppUpdate();
            }
          });
        }
      }
    } catch (e) {
      log(e.toString(), name: 'Main', error: e);
    } finally {
      state.isLocationLoading.value = false;
    }
  }

  // ✅ دالة منفصلة لتفعيل الموقع
  Future<void> _activateLocation() async {
    await LocationHelper.instance.getPositionDetails().then((_) async {
      log('Location activated: ${Location.instance.position}', name: 'Main');
      state.box.write(ACTIVE_LOCATION, true);
      state.box.write(IS_LOCATION_ACTIVE, true);
      state.box.write(FIRST_LAUNCH, true);
      await AdhanController.instance.initializeStoredAdhan().then((_) async {
        AdhanController.instance.state.location =
            await AdhanController.instance.localizedLocation;
        Get.forceAppUpdate();
      });
    });
  }

  /// Initialize location with manual selection (for Huawei devices)
  Future<void> initManualLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      state.isLocationLoading.value = true;

      await HuaweiLocationHelper.instance.setManualLocation(
        latitude: latitude,
        longitude: longitude,
      );

      state.activeLocation.value = true;
      state.box.write(ACTIVE_LOCATION, true);
      state.box.write(IS_LOCATION_ACTIVE, true);
      state.box.write(FIRST_LAUNCH, true);

      AdhanController.instance.initializeStoredAdhan();
      Get.forceAppUpdate();
      await SplashScreenController.instance.isNotificationAllowed();
    } catch (e) {
      log('Error initializing manual location: $e',
          name: 'GeneralController', error: e);
      rethrow;
    } finally {
      state.isLocationLoading.value = false;
    }
  }

  Future<void> cancelLocation() async {
    state.activeLocation.value = false;
    state.box.write(ACTIVE_LOCATION, false);
    state.box.write(IS_LOCATION_ACTIVE, false);
    state.box.write(FIRST_LAUNCH, true);
    await SplashScreenController.instance.isNotificationAllowed();
    log('Location cancelled', name: 'Main');
  }

  Future<void> toggleLocationService() async {
    if (!state.activeLocation.value) {
      LocationPermission permission = await Geolocator.checkPermission();
      bool isEnabled = await LocationHelper.instance.isLocationServiceEnabled();
      if (!isEnabled) {
        await LocationHelper.instance.openLocationSettings;
      } else if (isEnabled &&
          (permission == LocationPermission.deniedForever ||
              permission == LocationPermission.denied)) {
        await _openSettingsAndWait();
        await Future.delayed(const Duration(seconds: 3));
        if (await LocationHelper.instance.checkPermission()) {
          await _activateLocation();
          // await initLocation().then((_) async {
          //   state.activeLocation.value = true;
          //   await AdhanController.instance.initializeStoredAdhan().then((_) {
          //     state.box.write(ACTIVE_LOCATION, true);
          //     Get.forceAppUpdate();
          //   });
          // });
        }
        log('Location services are already enabled.');
      } else {
        await _activateLocation();
        // await initLocation().then((_) async {
        //   state.activeLocation.value = true;
        //   await AdhanController.instance.initializeStoredAdhan().then((_) {
        //     state.box.write(ACTIVE_LOCATION, true);
        //     Get.forceAppUpdate();
        //   });
        // });
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
    final currentLocation = LocationHelper().currentLocation;
    final position = await LocationHelper().fetchCurrentPosition;
    if (position == null) {
      Get.context!.showSearchBottomSheet(Get.context!);
      return false;
    }
    final newLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    log('Current Location: $currentLocation, New Location: $newLocation',
        name: 'GeneralController');
    if (newLocation != currentLocation) {
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
    log('Location has not changed, no update needed',
        name: 'GeneralController');
    return false;
  }
}
