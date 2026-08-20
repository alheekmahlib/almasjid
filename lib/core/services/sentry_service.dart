import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// تهيئة Sentry لمراقبة الأخطاء والأداء.
///
/// DSN مضمّن مؤقتاً للتشخيص — تُحذف هذه المكتبة بالكامل قبل رفع التطبيق للمتجر.
class SentryService {
  static const String dsn =
      'https://d31799ce6b509bb73006047a0e03f64e@o4509838657585152.ingest.us.sentry.io/4511940407656448';

  static bool get isEnabled => dsn.isNotEmpty;

  static Future<void> init(Future<void> Function() appRunner) {
    return SentryFlutter.init((options) {
      options.dsn = dsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
      options.debug = kDebugMode;
    }, appRunner: appRunner);
  }

  /// التقاط استثناء وإرساله إلى Sentry.
  /// لا تفعل شيئاً موثوقاً قبل [init] أو عند غياب DSN.
  static Future<SentryId> capture(Object error, {StackTrace? stackTrace}) {
    return Sentry.captureException(error, stackTrace: stackTrace);
  }
}
