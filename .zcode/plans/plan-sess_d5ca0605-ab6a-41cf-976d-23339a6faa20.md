# الخطة المعدّلة: توحيد الإشعارات على flutter_local_notifications ثم نظام أصوات الأذان عبر API

## القرار الجديد المعتمد
المرحلة الأولى تصبح: **هجرة كاملة من awesome_notifications إلى flutter_local_notifications (FLN 19.5.0) لكل المنصات**، كإصدار مستقل قائم بذاته (parity بدون ميزات جديدة)، ثم بناء نظام أصوات الأذان عبر API فوق الأساس الموحد.

## المرحلة 1 — توحيد الإشعارات (إصدار مستقل: هجرة فقط)

### 1.1 تعميم الخدمة الموحدة
- تحويل `MacOSNotificationsService` إلى خدمة موحدة (مثلاً `LocalNotificationsService`) تدعم Android + iOS + macOS:
  - تهيئة FLN بـ `InitializationSettings` لكل منصة + `onDidReceiveNotificationResponse` + `onDidReceiveBackgroundNotificationResponse` (ساكنة مع `@pragma('vm:entry-point')`).
  - إعادة استخدام الأنماط الموجودة نفسها: تهيئة timezone، `zonedSchedule` بـ `AndroidScheduleMode.exactAllowWhileIdle`، تسلسل payload بصيغة `k=v&k2=v2` (الموجود حالياً).
  - أذونات: `requestNotifications` لأندرويد 13+ و`requestPermissions` لـ iOS/macOS، مع الحفاظ على أعلام `GetStorage` الحالية (`_permissionFlagKey`).
- استبدال `NotificationInterval` (حالة time==null) بجدولة `zonedSchedule` بعد دقيقتين — سلوك مكافئ.

### 1.2 إعادة كتابة NotifyHelper كواجهة رقيقة
- حذف فرع awesome بالكامل و`initAwesomeNotifications`؛ كل الاستدعاءات (صلوات، رمضان، منشورات، تذكيرات قراءة) تمر كما هي عبر `NotifyHelper.scheduledNotification` فلا تتأثر الملفات الأخرى.
- `customSound` يُعاد بناؤه: iOS/macOS → اسم ملف مع امتداد (مثل `aqsa_athan.aiff`)، أندرويد → `RawResourceAndroidNotificationSound`.

### 1.3 قنوات أندرويد + إصلاح الخلل المكتشف
- إنشاء القنوات عبر `AndroidFlutterLocalNotificationsPlugin.createNotificationChannel`: قناة لكل مقرئ مدمج (aqsa, saqqaf, sarihi, baset, qatami, salah بصوت res/raw المناسب) + قناة bell + قناة silent — بدل القنوات السبع المهجورة.
- **إصلاح الخلل**: `_getChannelKey` يعيد قناة المقرئ المختار فعلياً (قراءة `ADHAN_PATH`) بدل إرجاع قناة aqsa دائماً — أول إصلاح حقيقي لعدم سماع المقرئ المختار على أندرويد 8+.

### 1.4 معالجات النقر (استبدال listeners)
- تعريف بنية إشعار داخلية موحدة (id, title, body, payloadMap) بدل أنواع `ReceivedAction/ReceivedNotification` الخاصة بـ awesome.
- Foreground tap → نفس توجيه `prayerListList` → `PrayersNotificationsCtrl.onNotificationActionReceived`، وBackground tap → معالج الساكنة الموازي.
- تحديث `prayers_noti_ui.dart` و`schedule_daily_extension.dart` و`prayers.dart` (حذف استيراد awesome).
- فجوتا parity موثقتان: لا يوجد callback عند "عرض/إهمال" الإشعار في FLN (الكود الحالي فيهما شبه فارغ — logging فقط)، وشارة Badge على أندرويد launcher-specific (تُحذف `setGlobalBadgeCounter`، يبقى `badgeNumber` في Darwin details).

### 1.5 تفاصيل أندرويد المكافئة لـ wakeUpScreen
- `AndroidNotificationDetails`: `fullScreenIntent: true`, `category: alarm`, `priority: max`, `visibility: public` + إضافة `USE_FULL_SCREEN_INTENT` للـ manifest.
- التحقق من الـ merged manifest (FLN يضيف receivers/services الخاصة به تلقائياً).

### 1.6 الحذف والتنظيف
- إزالة `awesome_notifications` من pubspec.yaml → `flutter pub get`.
- `flutter analyze` + `dart format` نظيفان.

### 1.7 اختبارات المرحلة 1
- مصفوفة يدوية: جدولة 30 يوم أندرويد / 10 أيام iOS، نقر على الإشعار (تطبيق حي + مقتول) يفتح bottom sheet الأذان، رمضان (bell)، منشورات بعيدة، رفض إذن أندرويد 13+، اختيار كل مقرئ والتأكد أنه الصوت الفعلي على أندرويد (تحقق الإصلاح).

## المرحلة 2 — نظام أصوات الأذان عبر API (فوق الأساس الموحد)

### 2.1 الكتالوج البعيد
- JSON بعيد على GitHub (نمط noti.json) + نسخة مدمجة احتياطية في `assets/json/adhanSounds.json`.
- Schema: `index, adhanName, adhanFileName, urlAndroidFull (zip كامل), urlIosSegment (ملف ≤30ث), urlPlayAdhan, isBundled`.
- متطلب تحضيري (محتوى): إنتاج مقاطع iOS ≤30ث لكل مقرئ — حالياً المقرئون 1-5 يشيرون جميعاً لنفس `Al-Saqqaf_part.zip`.

### 2.2 توسعة AudioDownloader
- قراءة الكتالوج البعيد مع fallback للمدمج، تخزين مسارات بادئة `file://`، كشف حالة التحميل/الحذف/إعادة التحميل والتحقق من وجود الملف.

### 2.3 واجهة الاختيار + الهجرة
- `adhan_sounds.dart` يعرض الكتالوج البعيد بشارات تحميل/حجم/تقدم (المعاينة بـ just_audio تبقى).
- الهجرة: مقرئ مختار غير محمّل → تحميل صامت بالخلفية + fallback للأقصى حتى الاكتمال.
- كل نص جديد عبر مفاتيح الترجمة المعتمدة.

### 2.4 أندرويد — التشغيل المباشر عند الوقت
- `AdhanPlaybackService` (Kotlin، foreground نوع mediaPlayback، إشعار دائم بزر إيقاف، AudioFocus) + `AlarmManager` مجدول بدقة عبر MethodChannel جديدة بالتوازي مع جدولة FLN (نفس نافذة 30 يوماً ومحفزات إعادة الجدولة).
- إشعار FLN لنوع 'sound' يصبح صامتاً (heads-up) والخدمة مصدر الصوت — تشغّل الملف المحمّل كاملاً أو raw resource للافتراضي.
- أذونات: `FOOGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` + fallback عند سحب `SCHEDULE_EXACT_ALARM`.

### 2.5 iOS — المقطع القصير
- `DarwinNotificationDetails(sound: '<segment>.caf')` — اسم ملف مباشر يُحل من `Library/Sounds` (الموجود أصلاً في AudioDownloader) — أنظف من مسار awesome المطلق.
- تحقق مبكر على جهاز حقيقي كأول خطوة في هذه المرحلة.

### 2.6 تخفيف التطبيق
- حذف 10 ملفات WAV من `res/raw` + 5 ملفات AIFF من `ios/Resource` (يبقى aqsa ×2 + notification + silence) + تحديث project.pbxproj. macOS دون تغيير.

### 2.7 اختبارات نهائية
- flutter_test: parsing الكتالوج، منطق fallback الهجرة، حسابات نافذة الجدولة.
- مصفوفة يدوية: أندرويد (مقتول/Doze/سحب الإنذار الدقيق)، iOS (قفل/مفتاح صامت)، فجر بنسخته الفجرية، الافتراضي بدون تحميلات.

## المخاطر الرئيسية
1. **هجرة FLN تمس المسار الأهم في التطبيق** (إشعارات الصلوات) — لهذا هي إصدار مستقل قبل أي ميزة، مع مصفوفة اختبار يدوية صريحة.
2. `UNNotificationSound` من `Library/Sounds` — يُتحقق منه مبكراً (2.5) وهو موثق رسمياً من Apple بخلاف مسار awesome المطلق.
3. جاهزية المحتوى (مقاطع iOS، ملفات كاملة لكل مقرئ) — متطلب تحضيري خارج الكود قبل الإطلاق.
4. حد iOS البالغ 64 إشعاراً مجدولاً — السلوك الحالي مماثل (نفس APIs) فلا انحدار متوقع، لكن نراقب العدد مع إضافات رمضان/المنشورات.

## تسلسل التنفيذ
المرحلة 1 كاملة ← إصدار مستقل واختبار ميداني ← المرحلة 2 (2.1→2.7). مستند التصميم `docs/superpowers/specs/2026-08-17-adhan-sounds-api-design.md` يُكتب ويُcommit كأول خطوة تنفيذ.