import 'package:get/get.dart';

import '../../../presentation/about_app/about_app.dart';
import '../../../presentation/home/home.dart';
import '../../../presentation/ourApp/screen/our_apps_screen.dart';
import '../../../presentation/prayers/prayers.dart';
import '../../../presentation/qibla/qibla.dart';
import '../../../presentation/teaching_prayer/teaching.dart';

class AppRouter {
  static const String homeScreen = '/homeScreen';
  static const String prayerScreen = '/prayerScreen';
  static const String qiblaScreen = '/qiblaScreen';
  static const String ourApps = '/ourApps';
  static const String aboutApp = '/aboutApp';
  static const String teachingPrayer = '/teachingPrayer';

  static List<GetPage> pages = [
    GetPage(
      name: homeScreen,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: prayerScreen,
      page: () => PrayerScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: qiblaScreen,
      page: () => QiblaScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: ourApps,
      page: () => const OurApps(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: aboutApp,
      page: () => const AboutApp(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: teachingPrayer,
      page: () => const TeachingPrayerScreen(),
      transition: Transition.fadeIn,
    ),
  ];

  // static Map<String, WidgetBuilder> get routes => {
  //       prayerScreen: (context) => PrayerScreen(),
  //     };

  // // إضافة المسارات إلى التطبيق باستخدام GetMaterialApp
  // static Widget buildApp() {
  //   return GetMaterialApp(
  //     initialRoute: prayerScreen,
  //     getPages: [
  //       GetPage(
  //         name: prayerScreen,
  //         page: () => PrayerScreen(),
  //       ),
  //     ],
  //   );
  // }
}
