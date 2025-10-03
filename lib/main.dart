import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/core/services/languages/dependency_inj.dart' as dep;
import 'core/services/notifications_helper.dart';
import 'core/services/services_locator.dart';
import 'core/utils/constants/shared_preferences_constants.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  widgetsBinding;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Map<String, Map<String, String>> languages = await dep.init();
  await initializeApp();
  runApp(MyApp(
    languages: languages,
  ));
}

Future<void> initializeApp() async {
  Future.delayed(const Duration(seconds: 0));
  await GetStorage.init();
  GetStorage().remove(AUDIO_SERVICE_INITIALIZED);
  // Always initialize services (register controllers, timezone, etc.)
  await ServicesLocator().init();
  tz.initializeTimeZones();
  NotifyHelper.initAwesomeNotifications();
  NotifyHelper().setNotificationsListeners();

  // Mobile-specific initialization
  if (Platform.isAndroid || Platform.isIOS) {
    await setLocaleIdentifier('en');
    // NotifyHelper.initFlutterLocalNotifications();
  }

  // Ensure splash is removed on all platforms
  FlutterNativeSplash.remove();
}
