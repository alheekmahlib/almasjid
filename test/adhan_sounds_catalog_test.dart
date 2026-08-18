import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:almasjid/presentation/prayers/data/model/adhan_data.dart';
import 'package:almasjid/presentation/prayers/prayers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdhanSoundsCatalog', () {
    test('uses remote entries when fetch succeeds', () async {
      final remoteJson = jsonEncode([
        {
          'index': 0,
          'adhanFileName': 'aqsa',
          'adhanLocalPath': 'resource://raw/aqsa_athan',
          'adhanName': 'aqsa',
          'urlAndroidAdhanZip': 'https://example.com/aqsa.zip',
          'urlIosAdhanZip': 'https://example.com/aqsa_part.zip',
          'urlPlayAdhan': 'https://example.com/aqsa.m4a',
        },
        {
          'index': 1,
          'adhanFileName': 'new_reciter',
          'adhanName': 'new_reciter',
          'urlAndroidAdhanZip': 'https://example.com/new.zip',
          'urlIosAdhanZip': 'https://example.com/new_part.zip',
          'urlPlayAdhan': 'https://example.com/new.m4a',
        },
      ]);

      final entries = await AdhanSoundsCatalog.load(
        fetchRemote: () async => remoteJson,
      );

      expect(entries, hasLength(2));
      // مقرئ بعيد بلا مسار محلي: ليس مدمجاً.
      expect(entries[0].isBundled, isTrue);
      expect(entries[0].adhanLocalPath, 'resource://raw/aqsa_athan');
      expect(entries[1].isBundled, isFalse);
      expect(entries[1].adhanLocalPath, isNull);
    });

    test('falls back to bundled assets when remote fetch throws', () async {
      final entries = await AdhanSoundsCatalog.load(
        fetchRemote: () async => throw Exception('network down'),
      );

      expect(entries, isNotEmpty);
      // النسخة المدمجة الحالية تحتوي 6 مقرئين مع مسارات محلية.
      expect(entries, hasLength(6));
      expect(entries.every((e) => e.isBundled), isTrue);
      expect(entries.first.adhanFileName, 'aqsa');
    });

    test('falls back to bundled assets when remote returns null or empty',
        () async {
      for (final remote in [null, '', '[]']) {
        final entries = await AdhanSoundsCatalog.load(
          fetchRemote: () async => remote,
        );
        expect(entries, hasLength(6), reason: 'remote="$remote"');
      }
    });

    test('falls back to bundled assets on malformed remote JSON', () async {
      final entries = await AdhanSoundsCatalog.load(
        fetchRemote: () async => 'not-json{',
      );
      expect(entries, hasLength(6));
    });
  });

  group('AdhanData round trip', () {
    test('preserves isBundled and nullable local path through toJson',
        () async {
      final remote = AdhanData(
        index: 9,
        adhanFileName: 'remote_reciter',
        adhanLocalPath: null,
        isBundled: false,
        adhanName: 'remote_reciter',
        urlAndroidAdhanZip: 'a',
        urlIosAdhanZip: 'b',
        urlPlayAdhan: 'c',
      );

      final restored = AdhanData.fromJson(remote.toJson());
      expect(restored.isBundled, isFalse);
      expect(restored.adhanLocalPath, isNull);
      expect(restored.index, 9);
    });

    test('treats legacy entries with local path as bundled', () async {
      final legacy = AdhanData.fromJson({
        'index': 0,
        'adhanFileName': 'aqsa',
        'adhanLocalPath': 'resource://raw/aqsa_athan',
        'adhanName': 'aqsa',
        'urlAndroidAdhanZip': 'a',
        'urlIosAdhanZip': 'b',
        'urlPlayAdhan': 'c',
      });
      expect(legacy.isBundled, isTrue);
    });
  });
}
