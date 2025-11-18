part of '../home.dart';

enum NavBarTab {
  qibla,
  prayer,
  liatafaqahuu,
  settings;

  String get label {
    switch (this) {
      case NavBarTab.qibla:
        return 'qibla';
      case NavBarTab.prayer:
        return 'prayer';
      case NavBarTab.liatafaqahuu:
        return 'liatafaqahuu';
      case NavBarTab.settings:
        return 'settings';
    }
  }

  String get icon {
    switch (this) {
      case NavBarTab.qibla:
        return SvgPath.svgHomeKaaba;
      case NavBarTab.prayer:
        return SvgPath.svgHomeMosque;
      case NavBarTab.liatafaqahuu:
        return SvgPath.svgHomeTeachingPrayer;
      case NavBarTab.settings:
        return SvgPath.svgHomeSettings;
    }
  }

  // @override
  int get tapIndex {
    return NavBarTab.values.indexOf(this);
  }

  Widget get currentScreen {
    switch (this) {
      case NavBarTab.qibla:
        return QiblaScreen();
      case NavBarTab.prayer:
        return PrayerScreen();
      case NavBarTab.liatafaqahuu:
        return const TeachingPrayerScreen();
      case NavBarTab.settings:
        return const SettingsScreen();
    }
  }
}
