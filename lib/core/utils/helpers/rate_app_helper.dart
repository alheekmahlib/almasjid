import 'dart:async' show unawaited;

import 'package:multi_store_review/multi_store_review.dart';

class RateAppHelper {
  static final MultiStoreReview _review = MultiStoreReview.instance;

  /// معرّف التطبيق في App Store؛ يغطي iOS وmacOS معًا لأن القائمة شراء
  /// موحّد (universal purchase). متجر Google يُستنتج تلقائيًا من اسم
  /// الحزمة com.alheekmah.aqimApp.
  static const StoreListing _listing = StoreListing(appStoreId: '6752765521');

  /// يُنادى مرة عند إقلاع التطبيق: يعدّ الإطلاق ويسلّح بوابة التقييم.
  ///
  /// الأرقام منسوخة من إعداد rate_my_app السابق:
  /// 7 تشغيلات قبل أول طلب، و15 يومًا بين المحاولات.
  /// الحالة تُخزَّن داخل المنصة نفسها (SharedPreferences/UserDefaults) —
  /// لا تحتاج get_storage ولا أي إعداد إضافي.
  static void initReviewGate() {
    unawaited(
      _review.configure(
        policy: const ReviewPolicy(minLaunches: 7, minDaysBetweenPrompts: 15),
      ),
    );
  }

  /// اسأل بوابة التقييم في اللحظات الإيجابية (إتمام مهمة أعجب المستخدم...).
  ///
  /// تعيد true إذا جرت محاولة عرض حوار التقييم (أو فتح صفحة المتجر كحل
  /// بديل)، وfalse إن قررت البوابة الانتظار. لا ترمي استثناءً أبدًا،
  /// وحوار التقييم أصلي ومترجم وفق لغة جهاز المستخدم.
  static Future<bool> maybeRequestReview() =>
      _review.maybeRequestReview(listing: _listing);
}
