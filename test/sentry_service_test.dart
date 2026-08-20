import 'package:almasjid/core/services/sentry_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('SentryService', () {
    test('المراقبة مفعّلة والرابط المضمّن صالح', () {
      expect(SentryService.isEnabled, isTrue);
      expect(SentryService.dsn, startsWith('https://'));
      expect(SentryService.dsn, contains('sentry.io'));
    });

    test(
      'التقاط استثناء قبل التهيئة لا يرمي خطأً ويعيد معرّفاً فارغاً',
      () async {
        final sentryId = await SentryService.capture(
          StateError('test error'),
          stackTrace: StackTrace.current,
        );

        expect(sentryId, const SentryId.empty());
      },
    );
  });
}
