# تصميم: توحيد الإشعارات وتوسيع أصوات الأذان عبر API

التاريخ: 2026-08-17
الحالة: معتمد (المرحلة 1 قيد التنفيذ)

## الخلفية والقرارات

التطبيق كان يستخدم مكتبتين للإشعارات: `awesome_notifications` (Android/iOS) و
`flutter_local_notifications` (macOS فقط). القرار المعتمد:

1. **المرحلة 1**: توحيد الإشعارات على `flutter_local_notifications` (FLN) لكل
   المنصات وحذف `awesome_notifications` — إصدار مستقل بغرض parity.
2. **المرحلة 2**: نظام أصوات أذان قابل للتوسع عبر API مع هجرة كاملة
   (كل المقرئين قابلون للتحميل، ويبقى مقرئ الأقصى مدمجاً كافتراضي).

### قيود منصات مؤكدة بالفحص (لا تغيرها المكتبة)

- **Android 8+**: صوت الإشعار يأتي من NotificationChannel حصراً، و
  `awesome_notifications` تبني `android.resource://` فقط (أي مسار ملف محمّل
  يُرجع null). حتى مع FLN، الصوت المحمّل لا يمكن أن يكون صوت إشعار لأن
  عملية النظام هي من تشغّله — الحل: تشغيل مباشر عبر Foreground Service.
- **iOS**: `UNNotificationSound` يقبل أصواتاً من حزمة التطبيق أو من
  `Library/Sounds` في sandbox التطبيق، بحد 30 ثانية للإشعار الواحد.
  `AudioDownloader` يكتب أصلاً في `Library/Sounds` على iOS.

### خلل مكتشف (قبل هذا العمل)

على Android، اختيار المقرئ لم يكن يؤثر على صوت الإشعار فعلياً:
`_getChannelKey` يعيد دائماً قناة `prayers_notifications_channel_ak`
(صوتها الثابت aqsa_athan)، و`customSound` على مستوى الإشعار يُتجاهل على
API 26+. كما أن 6 قنوات معرّفة لكل مقرئ لم تكن مستخدمة إطلاقاً.

## المرحلة 1 — التوحيد على FLN

### البنية

- خدمة موحدة جديدة `LocalNotificationsService`
  (`lib/core/services/local_notifications_service.dart`) تحل محل
  `MacOSNotificationsService` وتدعم Android + iOS + macOS:
  - تهيئة FLN لكل منصة + timezone.
  - قنوات Android: قناة لكل مقرئ (`prayers_adhan_<name>`) + `prayers_bell`
    + `prayers_silent`، مع حذف قنوات awesome القديمة مرة واحدة.
  - جدولة `zonedSchedule` بـ `exactAllowWhileIdle` مع fallback إلى
    `inexactAllowWhileIdle` عند رفض إذن الإنذارات الدقيقة.
  - أذونات لكل منصة (Android 13+ `requestNotificationsPermission`،
    Darwin `requestPermissions`).
- `NotifyHelper` يبقى الواجهة الوحيدة لكل المُجدوِلين (صلوات، رمضان،
  منشورات، تذكيرات قراءة) فلا تتغير نقاط الاستدعاء الخارجية.
- نموذج موحد `LocalReceivedNotification` (id/title/summary/body/payload/
  displayedDate) بديل أنواع awesome، مع تصديره من notifications_helper.

### معالجة النقر (استبدال listeners)

FLN لا يمرر title/body في معالج النقر، لذا يُحقن `title` و`summary`
و`fired_at` (وقت الجدولة بالمللي ثانية) في payload تلقائياً من
NotifyHelper، ويُبنى منها النموذج الموحد.

- **前台 (الواجهة الحية)**: `onDidReceiveNotificationResponse`.
- **خلفية/مقتول (Android)**: معالج ساكن `@pragma('vm:entry-point')` يكتب
  payload في GetStorage (`pending_notification_tap`)، ويستهلكه جسر
  WidgetsBindingObserver عند استئناف الواجهة أو بعد الإقلاع.
- **مقتول (iOS)**: عبر `getNotificationAppLaunchDetails` عند الإقلاع.
- التوجيه يبقى كما هو: إذا كان العنوان في `prayerListList` →
  `PrayersNotificationsCtrl.onNotificationActionReceived` (bottom sheet
  الأذان + playAudio).

### الأصوات

- Android: `RawResourceAndroidNotificationSound('<reciter>_athan')` مع
  قناة المقرئ المختار — وهذا نفسه إصلاح الخلل المكتشف.
- iOS/macOS: `DarwinNotificationDetails(sound: '<reciter>_athan.aiff')`
  من حزمة التطبيق، و`notification.aiff` للجرس.
- نسخ الفجر تبقى غير مستخدمة في الإشعارات (كما هي الحالية —
  `reminderId == 0` لا يتحقق مع نظام IDs الحالي)؛ تُعالج في المرحلة 2.
- `wakeUpScreen` السابق يستبدل بـ `fullScreenIntent` + `category: alarm`
  لنوع 'sound' فقط + إضافة `USE_FULL_SCREEN_INTENT` للـ manifest.

### فجوات parity موثقة (مقبولة)

1. FLN لا يوفر callback عند "عرض" الإشعار أو "إهماله" (الكود السابق فيهما
   logging فقط).
2. شارة Badge على Android أصبحت launcher-specific؛ حُذفت
   `setGlobalBadgeCounter` ويُمرر `badgeNumber` في Darwin details فقط.
3. `NotificationInterval` (حالة time==null) تُستبدل بجدولة بعد دقيقتين
   (كل الاستدعاءات الحالية تمرر isRepeats: false).

## المرحلة 2 — نظام أصوات الأذان عبر API (ملخص)

- كتالوج بعيد على GitHub (نمط noti.json) + نسخة مدمجة احتياطية. الحقول:
  `index, adhanName, adhanFileName, urlAndroidFull, urlIosSegment (≤30ث),
  urlPlayAdhan, isBundled`.
- أندرويد: `AdhanPlaybackService` (foreground نوع mediaPlayback + إشعار دائم
  بزر إيقاف + AudioFocus) تُطلَق عبر AlarmManager مجدولة بالتوازي مع جدولة
  FLN؛ إشعار FLA لنوع 'sound' يصبح صامتاً والخدمة مصدر الصوت.
- iOS: `DarwinNotificationDetails(sound: '<segment>')` يُحل من
  `Library/Sounds` (الملفات المحمّلة موجودة هناك أصلاً).
- الهجرة: مقرئ مختار غير محمّل → تحميل صامت بالخلفية + fallback للأقصى.
- تخفيف الحزمة: حذف WAV/PIFF لغير الافتراضي (يبقى aqsa ×2 + notification
  + silence).
- متطلب تحضيري (محتوى): إنتاج مقاطع iOS ≤30ث لكل مقرئ — حالياً المقرئون
  1-5 في adhanSounds.json يشيرون جميعاً لنفس `Al-Saqqaf_part.zip`.

## الاختبار

- مصفوفة يدوية للمرحلة 1: جدولة 30ي/10ي، نقر (حي/خلفية/مقتول)، رمضان،
  منشورات، رفض إذن Android 13+، التحقق من سماع المقرئ المختار على Android.
- flutter_test: parsing الكتالوج، fallback الهجرة، حسابات نافذة الجدولة.
