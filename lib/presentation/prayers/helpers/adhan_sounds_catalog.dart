part of '../prayers.dart';

/// يجلب كتالوج أصوات الأذان مع سلسلة احتياط ثلاثية:
/// GitHub ← GitLab ← النسخة المدمجة في التطبيق.
/// يسمح بإضافة مقرئين جدد دون تحديث التطبيق، والروابط داخل الكتالوج
/// مسارات نسبية تُحل عبر [resolveUrl] إلى المستودع الأساسي أو البديل.
class AdhanSoundsCatalog {
  const AdhanSoundsCatalog._();

  /// مصدر آخر جلب ناجح (true = GitLab)؛ يُستخدم لحل المسارات النسبية
  /// للمعاينات والتحميلات اللاحقة.
  static bool lastSourceWasGitlab = false;

  /// [fetchRemote] قابل للحقن للاختبارات.
  static Future<List<AdhanData>> load({
    Future<String?> Function()? fetchRemote,
  }) async {
    final fetcher = fetchRemote ?? _fetchRemoteCatalog;
    try {
      final jsonString = await fetcher();
      final entries = _parse(jsonString);
      if (entries != null && entries.isNotEmpty) return entries;
    } catch (e) {
      log(
        'Remote adhan catalog failed, falling back to bundled: $e',
        name: 'AdhanSoundsCatalog',
      );
    }
    return _loadBundled();
  }

  static List<AdhanData>? _parse(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) return null;
    try {
      // قد يفك Dio JSON تلقائياً فيصل List بدل String.
      final decoded = jsonDecode(jsonString);
      final List<dynamic>? jsonData = decoded is List<dynamic> ? decoded : null;
      if (jsonData == null || jsonData.isEmpty) return null;
      return jsonData
          .map((data) => AdhanData.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Failed parsing adhan catalog: $e', name: 'AdhanSoundsCatalog');
      return null;
    }
  }

  static Future<String?> _fetchRemoteCatalog() async {
    final response = await ApiClient().request(
      endpoint: ApiConstants.adhanSoundsCatalogUrl,
      method: HttpMethod.get,
      fallbackUrl: ApiConstants.adhanSoundsCatalogFallbackUrl,
    );
    if (response.isRight) {
      final data = response.right;
      if (data is String && data.trim().isNotEmpty) return data;
      if (data is List<dynamic>) return jsonEncode(data);
    }
    return null;
  }

  static Future<List<AdhanData>> _loadBundled() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/adhanSounds.json',
    );
    final entries = _parse(jsonString);
    if (entries == null || entries.isEmpty) {
      log('Bundled adhan catalog is empty!', name: 'AdhanSoundsCatalog');
      return const [];
    }
    log(
      'Adhan catalog loaded from bundled assets (${entries.length} entries)',
      name: 'AdhanSoundsCatalog',
    );
    return entries;
  }

  /// حل مسار نسبي من الكتالوج إلى رابط مطلق حسب المستودع المفضل.
  static String resolveUrl(String pathOrUrl, {bool? preferGitlab}) {
    if (pathOrUrl.startsWith('http')) return pathOrUrl;
    final useGitlab = preferGitlab ?? lastSourceWasGitlab;
    final base = useGitlab
        ? ApiConstants.adhanSoundsBaseGitlab
        : ApiConstants.adhanSoundsBaseGithub;
    return '$base/$pathOrUrl';
  }

  /// الرابط البديل (المستودع الآخر) لنفس المسار النسبي.
  static String resolveFallbackUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http')) return pathOrUrl;
    final base = lastSourceWasGitlab
        ? ApiConstants.adhanSoundsBaseGithub
        : ApiConstants.adhanSoundsBaseGitlab;
    return '$base/$pathOrUrl';
  }
}
