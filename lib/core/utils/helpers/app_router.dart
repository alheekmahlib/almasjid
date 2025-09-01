import 'package:get/get.dart';

import '../../../presentation/home/home_screen.dart';
import '../../../presentation/prayers/prayers.dart';
import '../../../presentation/qibla/qibla.dart';

class AppRouter {
  static const String homeScreen = '/homeScreen';
  static const String prayerScreen = '/prayerScreen';
  static const String qiblaScreen = '/qiblaScreen';

  static List<GetPage> pages = [
    GetPage(
      name: homeScreen,
      page: () => const HomeScreen(),
      // page: () => ZadIntelligenceScreen(),
      // binding: HomeWidgetsBinding(),
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
