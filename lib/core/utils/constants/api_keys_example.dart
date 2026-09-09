/// نسخة نموذجية من api_keys.dart — الملف الحقيقي مستثنى من Git.
///
/// للإعداد محلياً:
/// 1. انسخ هذا الملف باسم api_keys.dart (في نفس المجلد).
/// 2. استبدل القيم النصية بالقيم الحقيقية.
/// في CI لا حاجة لهذه الخطوة؛ يُولَّد api_keys.dart من Secret باسم MAPTILER_KEY.
class ApiKeys {
  ApiKeys._();

  /// مفتاح MapTiler من cloud.maptiler.com/account/keys
  static const String mapTilerKey = 'YOUR_MAPTILER_KEY';

  /// قيمة Allowed User-Agent header المقيَّد بها المفتاح في لوحة MapTiler.
  static const String mapTilerUserAgent = 'Aqim-app';
}
