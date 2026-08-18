part of '../prayers.dart';

/// يجلب كتالوج أصوات الأذان البعيد مع احتياط للنسخة المدمجة في التطبيق.
/// يسمح بإضافة مقرئين جدد دون تحديث التطبيق.
class AdhanSoundsCatalog {
  const AdhanSoundsCatalog._();

  /// [fetchRemote] قابل للحقن للاختبارات.
  static Future<List<AdhanData>> load({
    Future<String?> Function()? fetchRemote,
  }) async {
    final fetcher = fetchRemote ?? _fetchRemoteCatalog;
    try {
      final jsonString = await fetcher();
      if (jsonString != null && jsonString.trim().isNotEmpty) {
        final jsonData = jsonDecode(jsonString);
        if (jsonData is List<dynamic> && jsonData.isNotEmpty) {
          final entries = jsonData
              .map((data) => AdhanData.fromJson(data as Map<String, dynamic>))
              .toList();
          log(
            'Adhan catalog loaded remotely: ${entries.length} entries',
            name: 'AdhanSoundsCatalog',
          );
          return entries;
        }
      }
    } catch (e) {
      log(
        'Remote adhan catalog failed, falling back to bundled: $e',
        name: 'AdhanSoundsCatalog',
      );
    }
    return _loadBundled();
  }

  static Future<String?> _fetchRemoteCatalog() async {
    final response = await ApiClient().request(
      endpoint: ApiConstants.adhanSoundsCatalogUrl,
      method: HttpMethod.get,
    );
    if (response.isRight) {
      final data = response.right;
      if (data is String && data.trim().isNotEmpty) return data;
    }
    return null;
  }

  static Future<List<AdhanData>> _loadBundled() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/adhanSounds.json',
    );
    final jsonData = jsonDecode(jsonString);
    final entries = (jsonData as List<dynamic>)
        .map((data) => AdhanData.fromJson(data as Map<String, dynamic>))
        .toList();
    log(
      'Adhan catalog loaded from bundled assets (${entries.length} entries)',
      name: 'AdhanSoundsCatalog',
    );
    return entries;
  }
}
