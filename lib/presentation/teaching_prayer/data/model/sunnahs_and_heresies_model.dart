part of '../../teaching.dart';

/// نموذج بيانات السنن والبدع الشهرية
/// - يدعم اللغات المتعددة
/// - يعتمد على رقم الشهر الهجري للوصول للبيانات

class SunnahsAndHeresiesData {
  final List<HijriMonthData> months;

  const SunnahsAndHeresiesData({required this.months});

  factory SunnahsAndHeresiesData.fromJson(Map<String, dynamic> json) {
    final monthsList = json['manths'] as List<dynamic>? ?? <dynamic>[];
    return SunnahsAndHeresiesData(
      months: monthsList
          .map((e) => HijriMonthData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// جلب بيانات شهر معين بناءً على رقمه الهجري (1-12)
  /// يُرجع null إذا لم يوجد الشهر
  HijriMonthData? getMonthData(int monthNumber) {
    try {
      return months.firstWhere((m) => m.number == monthNumber);
    } catch (_) {
      return null;
    }
  }

  /// التحقق من وجود بيانات لشهر معين
  bool hasDataForMonth(int monthNumber) =>
      months.any((m) => m.number == monthNumber);

  /// قائمة أرقام الأشهر المتاحة
  List<int> get availableMonths => months.map((m) => m.number).toList();
}

/// بيانات شهر هجري واحد
class HijriMonthData {
  final int number;
  final HadithInfo hadith;
  final List<SunnahItem> sunnahs;
  final List<HeresyItem> heresies;

  const HijriMonthData({
    required this.number,
    required this.hadith,
    required this.sunnahs,
    required this.heresies,
  });

  factory HijriMonthData.fromJson(Map<String, dynamic> json) {
    return HijriMonthData(
      number: json['number'] as int? ?? 0,
      hadith: HadithInfo.fromJson(
        json['hadith'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      sunnahs: _parseItems<SunnahItem>(
        json['sunnahs'],
        SunnahItem.fromJson,
      ),
      heresies: _parseItems<HeresyItem>(
        json['heresies'],
        HeresyItem.fromJson,
      ),
    );
  }

  /// هل يحتوي الشهر على بيانات فعلية (حديث أو سنن أو بدع غير فارغة)
  bool get hasContent =>
      hadith.isNotEmpty || validSunnahs.isNotEmpty || validHeresies.isNotEmpty;

  /// السنن الفعلية (غير الفارغة)
  List<SunnahItem> get validSunnahs =>
      sunnahs.where((s) => s.isNotEmpty).toList();

  /// البدع الفعلية (غير الفارغة)
  List<HeresyItem> get validHeresies =>
      heresies.where((h) => h.isNotEmpty).toList();
}

/// معلومات الحديث أو الآية
class HadithInfo {
  final String ayahOrHadith;
  final String bookInfo;

  const HadithInfo({
    required this.ayahOrHadith,
    required this.bookInfo,
  });

  factory HadithInfo.fromJson(Map<String, dynamic> json) {
    return HadithInfo(
      ayahOrHadith: json['ayahOrHadith'] as String? ?? '',
      bookInfo: json['bookInfo'] as String? ?? '',
    );
  }

  bool get isNotEmpty => ayahOrHadith.trim().isNotEmpty;
  bool get isEmpty => !isNotEmpty;
}

/// عنصر سُنّة
class SunnahItem {
  final Map<String, String> name;
  final Map<String, String> description;

  const SunnahItem({
    required this.name,
    required this.description,
  });

  factory SunnahItem.fromJson(Map<String, dynamic> json) {
    return SunnahItem(
      name: _parseLocalizedMap(json['name']),
      description: _parseLocalizedMap(json['description']),
    );
  }

  String resolveName(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalizedText(name, langCode, fallback: fallback);

  String resolveDescription(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalizedText(description, langCode, fallback: fallback);

  bool get isNotEmpty =>
      name.values.any((v) => v.trim().isNotEmpty) ||
      description.values.any((v) => v.trim().isNotEmpty);
}

/// عنصر بدعة
class HeresyItem {
  final Map<String, String> name;
  final Map<String, String> description;

  const HeresyItem({
    required this.name,
    required this.description,
  });

  factory HeresyItem.fromJson(Map<String, dynamic> json) {
    return HeresyItem(
      name: _parseLocalizedMap(json['name']),
      description: _parseLocalizedMap(json['description']),
    );
  }

  String resolveName(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalizedText(name, langCode, fallback: fallback);

  String resolveDescription(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalizedText(description, langCode, fallback: fallback);

  bool get isNotEmpty =>
      name.values.any((v) => v.trim().isNotEmpty) ||
      description.values.any((v) => v.trim().isNotEmpty);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers الخاصة بهذا الموديل
// ─────────────────────────────────────────────────────────────────────────────

/// تحويل Map ديناميكية إلى Map<String, String>
Map<String, String> _parseLocalizedMap(dynamic value) {
  if (value is Map) {
    return value.map(
      (key, val) => MapEntry(
        key.toString(),
        val?.toString() ?? '',
      ),
    );
  }
  return const <String, String>{};
}

/// تحليل قائمة عناصر من JSON
List<T> _parseItems<T>(
  dynamic list,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (list is! List) return const [];
  return list
      .whereType<Map<String, dynamic>>()
      .map((e) => fromJson(e))
      .toList();
}

/// استخراج النص المحلي حسب اللغة مع fallback
String _resolveLocalizedText(
  Map<String, String> map,
  String langCode, {
  String fallback = 'ar',
}) {
  if (map.isEmpty) return '';

  final lc = langCode.toLowerCase();

  // 1. اللغة المطلوبة
  if (map.containsKey(lc) && map[lc]!.trim().isNotEmpty) {
    return map[lc]!.trim();
  }

  // 2. مختصر اللغة (بدون الإقليم)
  final shortLang = lc.split('_').first;
  if (shortLang != lc &&
      map.containsKey(shortLang) &&
      map[shortLang]!.trim().isNotEmpty) {
    return map[shortLang]!.trim();
  }

  // 3. اللغة الاحتياطية (عادة العربية)
  if (map.containsKey(fallback) && map[fallback]!.trim().isNotEmpty) {
    return map[fallback]!.trim();
  }

  // 4. الإنجليزية كبديل
  if (map.containsKey('en') && map['en']!.trim().isNotEmpty) {
    return map['en']!.trim();
  }

  // 5. أول قيمة غير فارغة
  for (final value in map.values) {
    if (value.trim().isNotEmpty) return value.trim();
  }

  return '';
}
