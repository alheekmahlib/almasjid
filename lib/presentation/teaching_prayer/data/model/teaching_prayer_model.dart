part of '../../teaching.dart';

/// نماذج JSON لقسم "تعليم الصلاة"
/// - بنية عامة:
/// {
///   "sections": [ Section ],
///   "lastUpdated": "2025-09-30T..."
/// }

class TeachingPrayerData {
  final List<TPSection> sections;
  final DateTime? lastUpdated;

  TeachingPrayerData({required this.sections, this.lastUpdated});

  factory TeachingPrayerData.fromJson(Map<String, dynamic> json) {
    return TeachingPrayerData(
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => TPSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TPSection>[],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }

  static TeachingPrayerData decode(String source) =>
      TeachingPrayerData.fromJson(json.decode(source) as Map<String, dynamic>);
}

class TPSection {
  final Map<String, String> name; // مفاتيح لغات -> نص
  final List<TPBranch> branches;

  TPSection({required this.name, required this.branches});

  factory TPSection.fromJson(Map<String, dynamic> json) {
    return TPSection(
      name: _mapStringString(json['name']),
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => TPBranch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TPBranch>[],
    );
  }

  String resolveName(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalized(name, langCode, fallback: fallback);
}

class TPBranch {
  final Map<String, String> name;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final List<String> enabledElements;

  TPBranch({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.enabledElements,
  });

  factory TPBranch.fromJson(Map<String, dynamic> json) {
    return TPBranch(
      name: _mapStringString(json['name']),
      title: _mapStringString(json['title']),
      subtitle: _mapStringString(json['subtitle']),
      enabledElements: (json['enabledElements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  String resolveName(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalized(name, langCode, fallback: fallback);
  String resolveTitle(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalized(title, langCode, fallback: fallback);
  String resolveSubtitle(String langCode, {String fallback = 'ar'}) =>
      _resolveLocalized(subtitle, langCode, fallback: fallback);
}

// Helpers

Map<String, String> _mapStringString(dynamic value) {
  if (value is Map) {
    return value
        .map((key, val) => MapEntry(key.toString(), val?.toString() ?? ''));
  }
  return const <String, String>{};
}

String _resolveLocalized(Map<String, String> map, String langCode,
    {String fallback = 'ar'}) {
  if (map.isEmpty) return '';
  // محاولات: اللغة المطلوبة -> مختصر بدون الإقليم -> الإنجليزية -> العربية -> أول متاح
  final lc = langCode.toLowerCase();
  if (map.containsKey(lc)) return map[lc]!.trim();
  final short = lc.split('-').first;
  if (map.containsKey(short)) return map[short]!.trim();
  if (map.containsKey('en')) return map['en']!.trim();
  if (map.containsKey(fallback)) return map[fallback]!.trim();
  return map.values.first.trim();
}
