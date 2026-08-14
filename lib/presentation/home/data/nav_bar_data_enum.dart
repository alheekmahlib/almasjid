part of '../home.dart';

enum NavBarTab {
  qibla,
  prayer,
  liatafaqahuu,
  cites;

  String get label {
    switch (this) {
      case NavBarTab.qibla:
        return 'qibla';
      case NavBarTab.prayer:
        return 'prayer';
      case NavBarTab.liatafaqahuu:
        return 'liatafaqahuu';
      case NavBarTab.cites:
        return 'cites';
    }
  }

  String get urlPath {
    switch (this) {
      case NavBarTab.qibla:
        return '/qibla';
      case NavBarTab.prayer:
        return '/prayer';
      case NavBarTab.liatafaqahuu:
        return '/learn';
      case NavBarTab.cites:
        return '/cities';
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
      case NavBarTab.cites:
        return SvgPath.svgHomeCites;
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
      case NavBarTab.cites:
        return const PrayersOfCites();
    }
  }
}
