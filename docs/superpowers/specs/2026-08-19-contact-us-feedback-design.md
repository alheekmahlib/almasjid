# تصميم: تحويل "تواصل معنا" إلى نظام ملاحظات متكامل (Feedback)

- **التاريخ:** 2026-08-19
- **الحالة:** معتمد من المالك في الجلسة (مع خيار: الفيديو يُفتح خارجيًا)
- **المرجع:** قسم الملاحظات في تطبيق `alquranalkareem` (`lib/presentation/screens/feedback`)
- **التطبيق المستهدف:** أقم (`almasjid`) — "أقم - مكتبة الحكمة"

---

## 1. الهدف والدافع

خيار "تواصل معنا" الحالي في شاشة (عن التطبيق) مجرد `mailto` يفتح تطبيق البريد
الخارجي (الامتداد `contactUs` في `contact_us_extension.dart`)، بلا واجهة إدخال
داخل التطبيق، وبلا معالجة فشل ظاهرة إن لم يوجد عميل بريد. الهدف: استبداله
بنظام ملاحظات/محادثات متكامل مطابق لتجربة تطبيق القرآن: المستخدم يرسل ملاحظة
مع مرفقات، ويشاهد ردود المشرف في محادثة داخل التطبيق، ويصل إشعار عند ورود رد.

قرارات معتمدة من المالك:

1. **المرفقات:** صور متعددة + فيديو واحد (حد أقصى 5 ملفات) — تُضاف حزمة
   `image_picker` الرسمية.
2. **نقطة الدخول:** استبدال كامل — الضغط على "تواصل معنا" يفتح الشاشة الجديدة،
   ويُحذف مسار mailto القديم (الملف يُحذف لأنه غير مستخدم في أي مكان آخر).
3. **الإشعارات:** فحص خلفي عبر `background_services.dart` الموجود (كل 20 دقيقة)
   + إشعار محلي عبر `LocalNotificationsService`، والنقر على الإشعار يفتح
   المحادثة مباشرة.
4. **عرض الفيديو المرفق:** يُفتح خارجيًا بالمشغل الافتراضي عبر `url_launcher`
   (المتوفر). لا تُضاف حزمة `video_player` في هذه المرحلة. الصور تُعرض داخل
   التطبيق بتكبير كامل عبر `InteractiveViewer`.

## 2. سلوك المستخدم (UX)

### 2.1 الدخول

```
HomeScreen → القائمة العائمة → الإعدادات → "عن التطبيق"
  → UserOptions → صف "تواصل معنا"
      → Get.toNamed(AppRouter.feedback)  [بديل contactUs/mailto]
```

### 2.2 شاشة المحادثات (قائمة ملاحظاتي)

- `AppBarWidget(withBackButton: true)` بعنوان "تواصل معنا".
- قائمة بطاقات لكل الملاحظات مرتبة تنازليًا حسب تاريخ الإنشاء؛ كل بطاقة تعرض:
  شارة حالة ملوّنة (مُخطّط أزرق / قيد التنفيذ كهرماني / مكتمل أخضر)، معاينة
  الرسالة (سطران)، التاريخ، وعدّاد ردود المشرف مع أيقونة محادثة.
- سحب للتحديث `RefreshIndicator` يعيد جلب كل المحادثات.
- زر عائم ممتد "إرسال الملاحظة" (`FloatingActionButton.extended`).
- حالة فراغ: أيقونة بريد كبيرة + نص إرشادي + زر إرسال
  (`ContainerButtonWidget`).
- حالة تحميل / حالة خطأ مع زر إعادة المحاولة (نمط `OurAppsBuild`).

### 2.3 ورقة الإرسال (Bottom Sheet)

تُفتح عبر `customBottomSheet()` الموجودة:

- حقل رسالة إجباري: 5–8 أسطر، حد 8000 حرف، عدّاد "متبقي" حيّ.
- حقل بريد اختياري للتواصل.
- قسم وسائط: اختيار صور متعددة (جودة 85) أو فيديو واحد، حد أقصى 5 ملفات،
  صور ≤10MB (jpg/jpeg/png/webp/gif)، فيديو ≤50MB (mp4/webm/mov)، مصغّرات
  72×72 مع زر إزالة وشارة فيديو، وشريط تقدم رفع نسبة مئوية أثناء الإرسال.
- زر إرسال `ContainerButtonWidget(isLoading: ...)` يُفعَّل فقط عند وجود نص
  أو ملفات، ودائرة تحميل أثناء الإرسال.
- نجاح الإرسال: `showCustomErrorSnackBar(..., isDone: true)` + إغلاق الورقة +
  فتح محادثة الملاحظة الجديدة. الفشل: رسالة خطأ مترجمة.

### 2.4 شاشة المحادثة

- `AppBarWidget(withBackButton: true)` + `Chip` للحالة أعلى القائمة.
- فقاعات: الرسالة الأصلية أولًا (فقاعة أولى بلا وقت)، ثم الردود — ردود المشرف
  محاذاة بداية الاتجاه (RTL: يسار) بلون السطح، ردود المستخدم محاذاة نهاية
  الاتجاه بلون أساسي، كل فقاعة: اسم الدور (المشرف/أنا) + الوقت HH:MM + معرض
  الوسائط إن وجد.
- شريط رد سفلي مثبت: `TextField` (1–4 أسطر) + زر إرسال يتحول لدائرة تحميل؛
  يدعم إرفاق وسائط بنفس قيود ورقة الإرسال (يُقبل رد وسائط فقط بلا نص).
- حالة خطأ في التحميل مع زر إعادة محاولة.

### 2.5 معرض الوسائط

- مصفوفة مصغّرات 120×120 عبر `Image.network` مع loadingBuilder/errorBuilder،
  الفيديو عليه أيقونة تشغيل.
- الضغط على صورة: عرض ملء الشاشة `InteractiveViewer` (تكبير 0.5x–4x) على
  خلفية سوداء مع إمكانية الإغلاق.
- الضغط على فيديو: `launchUrl` خارجي (الانحراف المعتمد رقم 4 أعلاه).

## 3. البنية والملفات

### 3.1 جديد — `lib/presentation/feedback/`

| الملف | الدور |
|---|---|
| `controller/feedback_controller.dart` | كنترولر GetX وحيد لكل المنطق |
| `data/models/feedback_model.dart` | موديل الملاحظة |
| `data/models/feedback_reply_model.dart` | موديل الرد |
| `data/models/feedback_thread.dart` | المحادثة (ملاحظة + ردود) |
| `screens/feedback_thread_screen.dart` | شاشة قائمة المحادثات |
| `screens/feedback_conversation_screen.dart` | شاشة المحادثة |
| `widgets/feedback_send_sheet.dart` | ورقة الإرسال (StatefulWidget) |
| `widgets/feedback_media_gallery.dart` | المعرض + العارض الملء الشاشي |

تُستخدم الحزمة النمطية (barrel/part) فقط إذا تطلب نمط الميزات المجاورة ذلك؛
الأصل ملفات مستقلة باستيرادات مباشرة (نمط `ourApp`).

### 3.2 تعديل قائم (إعادة استخدام قبل الإنشاء)

| الملف | التغيير |
|---|---|
| `pubspec.yaml` | إضافة `image_picker: ^1.2.3` (نفس إصدار المرجع) |
| `lib/core/utils/constants/api_constants.dart` | نفس ثوابت المرجع حرفيًا: `feedbackApiUrl` (القاعدة) + `feedbackEndpoint = '/feedback'` + `feedbackReplySuffix = '/reply'` + `feedbackUploadEndpoint = '/upload'` |
| `lib/core/services/api_client.dart` | إضافة `uploadFile()`: رفع multipart (حقل `file`) يعيد `Either<Failure, dynamic>` بنفس نمط `request` (بدون fallback) |
| `lib/core/services/services_locator.dart` | `sl.registerLazySingleton<FeedbackController>(() => Get.put<FeedbackController>(FeedbackController(), permanent: true))` |
| `lib/core/services/background_services.dart` | استدعاء `FeedbackController.checkNewRepliesBackground()` داخل `_executeBackgroundTask` (معزول try/catch) |
| `lib/core/services/notifications_helper.dart` | توسيع `_handleNotificationTap`: تفرع `payload['type'] == 'feedback_reply'` → فتح المحادثة عبر token |
| `lib/core/utils/helpers/app_router.dart` | `static const String feedback = '/feedback';` + `GetPage` بـ `Transition.fadeIn` |
| `lib/presentation/about_app/user_options.dart` | استبدال استدعاء `contactUs(...)` بـ `Get.toNamed(AppRouter.feedback)` (نفس الأيقونة والعنوان) |
| `lib/core/utils/constants/extensions/contact_us_extension.dart` | **حذف** (غير مستخدم في أي مكان آخر — تم التحقق) |
| `assets/locales/*.json` (11 ملفًا) | مفاتيح جديدة (قسم 9) |

## 4. طبقة البيانات (API)

نفس خادم المرجع (Vexaltech) المشترك بين تطبيقات المالك؛ لا مصادقة — الهوية
token محلي لكل ملاحظة يُخزن في GetStorage.

| العملية | Endpoint | Body / الاستجابة |
|---|---|---|
| إنشاء ملاحظة | `POST {feedbackApiUrl}/feedback` | body: `{message, app_source, contact_email?, user_meta{}, media_urls[]}` → `{token, data}` |
| جلب محادثة | `GET {feedbackApiUrl}/feedback/{token}` | `{feedback:{}, replies:[]}` |
| رد متابعة | `POST {feedbackApiUrl}/feedback/{token}/reply` | `{body, media_urls?}` |
| رفع ملف | `POST {feedbackUploadUrl}/upload` | multipart حقل `file` → `{url}` |

- `app_source` ثابت: `'أقم - مكتبة الحكمة'`.
- `user_meta` يُجمع تلقائيًا عبر `flutter_app_info` (المتوفر): إصدار التطبيق،
  طراز الجهاز، إصدار النظام واسمه، واللغة.
- الاستجابات قد تكون Map مباشرة أو String-JSON — يُعالَج دفاعيًا بدالة
  `_asMap` مثل المرجع.
- كل الطلبات عبر `ApiClient` الموجود + `Failure/Either` الموجود.

## 5. الـ Models (نفس حقول المرجع حرفيًا)

- **FeedbackModel:** `id`, `token`, `message`, `status` (`planned` | `in_progress` | `complete`), `published` (bool), `appSource?`, `contactEmail?`, `createdAt`, `updatedAt`, `mediaUrls` (يقرأ `media_urls` أو `media` للتوافق) + `fromJson` + `copyWith`.
- **FeedbackReplyModel:** `id`, `feedbackId`, `authorRole` (`admin` | `user`) + getter `isAdmin`, `body`, `createdAt`, `mediaUrls` + `fromJson`.
- **FeedbackThread:** `feedback` + `replies` + `fromJson` + `copyWith`.

## 6. الـ Controller — `FeedbackController extends GetxController`

- الوصول: `static FeedbackController get instance => GetInstance().putOrFind(...)` + تسجيل في `services_locator` (permanent).
- الحالة (كلها Rx تُستهلك بـ `Obx`): `threads`, `isLoadingList`, `isSubmitting`, `openThread` (Rxn), `isLoadingThread`, `isReplying`, `selectedFiles`, `isUploading`, `uploadProgress` (0.0–1.0).
- التخزين المحلي (GetStorage): مفاتيح `feedback_tokens` (قائمة tokens) و`feedback_last_reply_id` (آخر id رد مُشاهد).
- الدوال: `onInit` (تحميل القائمة + فحص الردود)، `loadAllThreads()` (توازي `Future.wait`)، `submitFeedback()` → `Either`, `openConversation(token)`, `sendReply(body)` → `Either` (يقبل وسائط فقط)، `pickImages()/pickVideo()/removeFileAt()/clearFiles()/isVideoFile()`، `_uploadAllFiles()` (تسلسلي بتقدم تراكمي)، `checkForNewReplies()` (للواجهة الأمامية) + `static checkNewRepliesBackground()` بوسم `@pragma('vm:entry-point')` (معزولة try/catch، تُهيئ GetStorage بنفسها، ونصوص الإشعار بصيغة نهائية ثابتة لأن الترجمة قد لا تتاح في isolate الخلفية).
- رفع الوسائط يسبق إرسال الرسالة؛ الروابط تُرفق كـ `media_urls`.

## 7. الإشعارات والفحص الخلفي

- **الفحص:** يُستدعى من (أ) `onInit` للكنترولر عند أول فتح للشاشة، و(ب) من
  `_executeBackgroundTask` في `background_services.dart` (يعمل كل 20 دقيقة +
  مهمة منتصف الليل + مهام MethodChannel الأصلية الموجودة).
- **الإشعار:** `LocalNotificationsService.instance.showNotification` بقناة
  التنبيهات الموجودة (`soundType: 'bell'`)، عنوان "رد المشرف" ونص الرد.
- **المعرفات:** نطاق خاص منفصل عن نطاق الصلوات (20000–21000):
  `900000 + (token.hashCode.abs() % 99999)` — لا تعارض مع إشعارات الأذان.
- **النقر:** payload يحمل `{type: 'feedback_reply', feedback_token}`؛ يُوسَّع
  `NotifyHelper._handleNotificationTap` ليتفرع عليه وينفذ
  `Get.toNamed(AppRouter.feedback)` ثم فتح المحادثة — مع ملاحظة أن الطلب من
  الخلفية يمر عبر `_routeDeferredTaps` الموجود الذي ينتظر جهوزية الواجهة، فلا
  حاجة لمعالجة خاصة.
- ملاحظة سلوكية: الخلفية تعرض الإشعار فقط؛ تحديث القائمة يحدث عند فتح
  التطبيق/الشاشة (سلوك مقبول — مثل المرجع).

## 8. الواجهة — widgets أقم حصرًا

- `AppBarWidget` للأشرطة العلوية، `ContainerButtonWidget` للأزرار الرئيسية
  (يدعم `isLoading` مدمجًا)، `customBottomSheet()` لورقة الإرسال،
  `showCustomErrorSnackBar` للتنبيهات، حقول `TextField` بزخرفة موحدة مستلة من
  `show_search_bottom_sheet` الحالي (حواف 16، حدود بلون `colorScheme.surface`،
  prefixIcon)، حالات تحميل/خطأ/فراغ بنمط `OurAppsBuild`، `Gap` للمسافات،
  وأبعاد `flutter_screenutil` (360×690).
- ورقة الإرسال StatefulWidget تُنشئ `TextEditingController` وتتخلص منها، مع
  `ValueNotifier` لعدّاد الأحرف.
- لا تُنسخ widgets تطبيق القرآن (`CustomButton/ContainerButton` الخاصان به)؛
  تُعاد صياغة كل شاشة بمكوّنات أقم.

## 9. الترجمة

22 مفتاحًا جديدًا بأسلوب camelCase المسطّح + وصف `@key`، تُضاف إلى ملفات
اللغات الـ 11 (ar, en, bn, es, fil, id, ku, ms, so, tr, ur) — الترجمة
الأمينة لكل لغة، والمفاتيح مطابقة لمرجع القرآن حيث أمكن لتسهيل الصيانة
المشتركة: `feedbackSendNote` (إرسال الملاحظة)، `feedbackSubtitle`،
`feedbackMessageHint`، `feedbackContactOptional`، `feedbackSentSuccess`،
`feedbackSentError`، `feedbackNoNotesYet`، `feedbackReplyHint`،
`feedbackReplyTitle` (رد المشرف)، `feedbackStatusPlanned/InProgress/Complete`،
`feedbackAdminRole`، `feedbackYouRole`، `feedbackPickImages`،
`feedbackPickVideo`، `feedbackMaxFiles`، `feedbackFileTooLarge`،
`feedbackInvalidType`، `feedbackUploading`، `charactersRemaining`، `retry`
(العدد 22 لأن بعض مفاتيح المرجع سقطت: عنوان شاشة القائمة يعيد استخدام مفتاح
`email` الموجود = "تواصل معنا" بدل مفتاح جديد، و`feedbackNewReply` و
`feedbackAddMedia` غير مستخدمة في أي واجهة فأُسقطتا — YAGNI).

تم التحقق أن أيا من المفاتيح الـ 22 غير موجود في ملفات الترجمة الحالية.

## 10. الصلاحيات والمنصات

- `image_picker` يستخدم Photo Picker على Android 13+ و iOS الحديث دون أذونات
  تخزين؛ إن تطلب `Info.plist` إضافة `NSPhotoLibraryUsageDescription` (iOS
  القديم) تُضاف بصيغة ودّية، وكذلك `NSPhotoLibraryAddUsageDescription` غير
  مطلوب (لا حفظ للألبوم).
- macOS مدعومة في التطبيق؛ `image_picker` يدعم macOS عبر file picker — يُتحقق
  من التشغيل على macOS في أقرب فرصة، وأي قصور لا يوقف بقية المنصات (الاختيار
  يفشل بأمان مع رسالة خطأ ودّية).
- منصات ويب/سطح المكتب الأخرى خارج الاهتمام.

## 11. الاختبارات (`test/` — نفس النمط القائم)

1. **models:** `feedback_models_test.dart` — fromJson للسلوك الأساسي + حالات
   الحافة: `media` مقابل `media_urls`، ردود فارغة، status غير معروف، نص JSON
   بدل Map.
2. **widget:** `feedback_screens_test.dart` — شاشة القائمة تعرض حالة الفراغ،
   فتح ورقة الإرسال والتحقق من تعطل زر الإرسال بلا نص/مرفقات، وعدّاد
   الأحرف. مع `Get.reset()/sl.reset()` وmock لقنوات MethodChannel
   (image_picker/connectivity) و`ScreenUtilInit` + `GetMaterialApp(locale: ar)`
   كما في `our_apps_screen_back_button_test.dart`.
3. لا اختبارات شبكة حية؛ الكنترولر يُختبر عبر الوحدة فقط إن أمكن دون شبكة
   (دوال الملفات المحلية).

## 12. قرارات وانحرافات عن المرجع

| # | الانحراف | السبب |
|---|---|---|
| 1 | الفيديو يُفتح خارجيًا (`url_launcher`) لا بمشغل داخلي | تفادي حزمة `video_player` وغموض دعمها على macOS |
| 2 | الإشعار عبر `flutter_local_notifications` لا AwesomeNotifications | نظام الإشعارات القائم في أقم |
| 3 | النقر على الإشعار يفتح المحادثة | تحسين غير موجود في المرجع، متاح مجانًا عبر نظام payload القائم |
| 4 | مسار `GetPage` باسم `/feedback` لا `Get.to` مباشر | اتفاقية التوجيه القائمة في أقم |
| 5 | رفع الملفات عبر `uploadFile()` جديدة في `ApiClient` | المرجع يملكها في ApiClient الخاص به؛ أقم تفتقدها — توسعة الخدمة القائمة بدل تكرارها |

## 13. خارج النطاق

- أي مصادقة مستخدم أو ربط حساب.
- إشعارات push حقيقية (FCM/APNs) — الفحص دوري polling.
- تعديل لوحة التحكم الخلفية أو الـ API نفسه.
- شارة unread على بطاقة القائمة (يكفي العداد داخل البطاقة).
- إعادة تصميم بقية شاشة (عن التطبيق).
