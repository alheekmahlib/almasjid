import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/core/services/languages/dependency_inj.dart' as dep;
import 'core/services/notifications_helper.dart';
import 'core/services/services_locator.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  widgetsBinding;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Map<String, Map<String, String>> languages = await dep.init();
  await initializeApp();
  runApp(AppInfo(
    data: await AppInfoData.get(),
    child: MyApp(
      languages: languages,
    ),
  ));
}

Future<void> initializeApp() async {
  Future.delayed(const Duration(seconds: 0));
  await GetStorage.init();
  // Always initialize services (register controllers, timezone, etc.)
  await ServicesLocator().init();
  tz.initializeTimeZones();
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    await NominatimGeocoding.init();
  }
  NotifyHelper.initAwesomeNotifications();
  NotifyHelper().setNotificationsListeners();

  // Mobile-specific initialization
  // if (Platform.isAndroid || Platform.isIOS) {
  //   await setLocaleIdentifier('en');
  // }

  // Ensure splash is removed on all platforms
  FlutterNativeSplash.remove();
}
