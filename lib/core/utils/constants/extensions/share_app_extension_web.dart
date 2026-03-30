import 'package:almasjid/core/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

extension ShareAppExtension on void {
  Future<void> shareApp() async {
    final box = Get.context!.findRenderObject() as RenderBox?;
    final params = ShareParams(
      text:
          'تطبيق "أَقِم - مكتبة الحكمة" هو رفيقك اليومي للحفاظ على صلاتك.\n\nللتحميل:\n${ApiConstants.downloadAppUrl}',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    await SharePlus.instance.share(params);
  }
}
