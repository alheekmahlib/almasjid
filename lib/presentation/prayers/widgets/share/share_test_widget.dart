// اختبار بسيط للمشاركة - يمكنك حذف هذا الملف بعد الاختبار
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareTestWidget extends StatelessWidget {
  const ShareTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار المشاركة')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _shareTextOnly(),
              child: const Text('مشاركة نص فقط'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _shareImageOnly(),
              child: const Text('مشاركة صورة فقط'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _shareTextAndImage(),
              child: const Text('مشاركة نص وصورة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTextOnly() async {
    try {
      final params = ShareParams(
        text: 'هذا نص تجريبي للمشاركة من تطبيق المسجد',
        subject: 'اختبار المشاركة',
      );

      final result = await SharePlus.instance.share(params);
      print('Share text result: ${result.status}');
    } catch (e) {
      print('Error sharing text: $e');
    }
  }

  Future<void> _shareImageOnly() async {
    try {
      // إنشاء صورة تجريبية بسيطة
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/test_image.png');

      // إنشاء بيانات صورة بسيطة (مربع أحمر صغير)
      final imageData = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        2,
        0,
        0,
        0,
        144,
        119,
        83,
        222,
        0,
        0,
        0,
        12,
        73,
        68,
        65,
        84,
        8,
        153,
        99,
        248,
        15,
        0,
        0,
        1,
        0,
        1,
        85,
        212,
        33,
        40,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130
      ]);

      await file.writeAsBytes(imageData);

      final params = ShareParams(
        files: [XFile(file.path, name: 'test_image.png')],
      );

      final result = await SharePlus.instance.share(params);
      print('Share image result: ${result.status}');
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  Future<void> _shareTextAndImage() async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/test_combined.png');

      final imageData = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        2,
        0,
        0,
        0,
        144,
        119,
        83,
        222,
        0,
        0,
        0,
        12,
        73,
        68,
        65,
        84,
        8,
        153,
        99,
        248,
        15,
        0,
        0,
        1,
        0,
        1,
        85,
        212,
        33,
        40,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130
      ]);

      await file.writeAsBytes(imageData);

      final params = ShareParams(
        text: 'نص مع صورة من تطبيق المسجد',
        files: [XFile(file.path, name: 'combined_test.png')],
        subject: 'اختبار النص والصورة',
      );

      final result = await SharePlus.instance.share(params);
      print('Share combined result: ${result.status}');
    } catch (e) {
      print('Error sharing combined: $e');
    }
  }
}
