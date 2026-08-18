import 'dart:convert';

import 'package:almasjid/core/services/local_notifications_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalNotificationsService payload codec', () {
    test('round-trips a typical prayer payload', () {
      const payload = {
        'sound_type': 'sound',
        'title': 'Fajr',
        'summary': 'حان الآن موعد صلاة الفجر',
        'fired_at': '1765432100000',
      };

      final encoded = LocalNotificationsService.encodePayload(payload);
      expect(encoded, isNotNull);

      final decoded = LocalNotificationsService.decodePayload(encoded);
      expect(decoded, equals(payload));
    });

    test('returns null for empty payload', () {
      expect(LocalNotificationsService.encodePayload(const {}), isNull);
    });

    test('returns empty map for null or empty input', () {
      expect(LocalNotificationsService.decodePayload(null), isEmpty);
      expect(LocalNotificationsService.decodePayload(''), isEmpty);
    });

    test('returns empty map for malformed JSON instead of throwing', () {
      expect(LocalNotificationsService.decodePayload('not-json{'), isEmpty);
      // JSON صالح لكن ليس كائناً (قائمة مثلاً)
      expect(
        LocalNotificationsService.decodePayload(jsonEncode(['a', 'b'])),
        isEmpty,
      );
    });

    test('coerces non-string values to strings', () {
      final encoded = jsonEncode({'sound_type': 'bell', 'count': 3});
      final decoded = LocalNotificationsService.decodePayload(encoded);
      expect(decoded['count'], equals('3'));
    });
  });
}
