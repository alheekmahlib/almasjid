# خطة: إضافة أوقات الإقامة مع إشعاراتها ومعالجة حد الـ 64 إشعار في iOS

## نظرة عامة
ميزة الإقامة جديدة كليًا. **بلا قسم إعدادات جديد** — تُدمج في `SettingPrayerTimes` الموجودة: صف إقامة صغير تحت كل صلاة من الصلوات الخمس + مفتاحا تبديل ضمن نفس العمود. تُبنى بأنماط المشروع الحالية حصرًا (GetX + GetStorage، نمط `OurPrayerAdjustments`). **لا تبعيات جديدة ولا ملفات واجهة جديدة.**

## الخطوة 0: وثيقة التصميم
كتابة `docs/superpowers/specs/2026-08-18-iqama-times-design.md` (بنفس مأسسة `2026-08-17-adhan-sounds-api-design.md`): القرارات، الميزانية، المعرفات، وسلوك iOS (إبقاء أقرب 64 تلقائيًا كخط دفاع أخير).

## الخطوة 1: الثوابت والنموذج
1. `lib/core/utils/constants/shared_preferences_constants.dart`: إضافة:
   - `IQAMA_OFFSET_FAJR/DHUHR/ASR/MAGHRIB/ISHA` (int دقائق)
   - `IQAMA_NOTIFICATIONS_ENABLED` (bool، افتراضي false — مطلوب)
   - `SHOW_IQAMA_TIMES` (bool، افتراضي true)
2. `lib/presentation/prayers/controller/adhan/adhan_state.dart`: صنف `IqamaOffsets` بنمط `OurPrayerAdjustments`:
   - `fromGetStorage()`، افتراضيات: فجر 25، ظهر 15، عصر 15، مغرب 10، عشاء 15
   - `adjust(prayerKey, ±5)` مع clamp بين 5 و60
   - `getByIndex(int)` لواجهة +/-
   - حقول Rx في `AdhanState`: `iqamaOffsets`، `iqamaNotificationsEnabled`، `showIqamaTimes`

## الخطوة 2: عرض وقت الإقامة
1. `lib/presentation/prayers/data/model/prayer_list.dart`: إضافة `iqamaTime` (نص منسق) و`iqamaDateTime` لخرائط الصلوات الخمس فقط (null للشروق/منتصف الليل/ثلثه الأخير).
2. `lib/presentation/prayers/widgets/prayer_build.dart` و`prayer_details.dart`: سطر صغير «الإقامة 6:45» تحت/بجانب وقت الأذان، يظهر عند `showIqamaTimes == true` فقط وللصلوات الخمس. إعادة البناء عبر `update(['init_athan'])` الموجودة.
3. **لا تغيير** في منطق العد التنازلي أو «الصلاة القادمة» — يبقى مرتبطًا بالأذان.

## الخطوة 3: الإعدادات — دمج داخل SettingPrayerTimes (بدون قسم جديد)
كل التعديل داخل `lib/presentation/prayers/widgets/settings/setting_prayer_times.dart`:
1. تحت صف كل صلاة من الخلوات الخمس (وليس الشروق/الليل): صف فرعي مضغوط `__IqamaRow` خاص بالملف نفسه:
   - نص «الإقامة» + وقت الإقامة المحسوب (أذان + إزاحة) بخط أصغر
   - قيمة الإزاحة الحالية + أزرار +/- (خطوة 5، clamp 5–60) بنفس مظهر أزرار التعديل الحالية
   - يعمل أيضًا في وضع الصلاة الواحدة (`isOnePrayer: true`) داخل نافذة تفاصيل الصلاة
2. في أسفل عمود `SettingPrayerTimes` نفسه (بعد القائمة، بلا عنوان قسم جديد): مفتاحا `CustomSwitchWidget`:
   - «إشعارات الإقامة» (افتراضي مغلق)
   - «إظهار وقت الإقامة»
3. معالجات جديدة في extension الملف `adhan_ui.dart`: `toggleIqamaNotifications`، `toggleShowIqamaTimes`، `adjustIqamaOffset(index, {isAdding})`:
   - تغيير إزاحة أو مفتاح الإشعارات → إعادة جدولة نافذة الإقامة فورًا (≤10 إشعارات)
   - مفتاح الإشعارات يغيّر الميزانية → `reschedulePrayers()` كاملة

## الخطوة 4: الجدولة ومعالجة حد الـ 64 (الجزء الجوهري)
كل التعديلات في `lib/presentation/prayers/controller/prayers_notifications/extensions/schedule_daily_extension.dart`:

1. **معرفات الإقامة** (تستغل الخانات 5–9 الشاغرة في stride=10 الحالي — بلا تصادم):
   `_iqamaNotificationId(prayerKey, day) = 20000 + day*10 + 5 + prayerKey`
   (كشف الفجر `reminderId % 10 == 0` لن يطابقها؛ النقر عليها يفتح التطبيق فقط دون تشغيل أذان).

2. **دالة الميزانية** (نقية قابلة للاختبار):
   `int adhanDaysToSchedule({required int enabledAdhanCount, required bool iqamaEnabled, required bool ramadanActive})`
   - أندرويد: 30 (دون تغيير)، macOS: 10 (دون تغيير)
   - iOS: `clamp(((60 − iqamaSlots − ramadanSlots − 5) ~/ enabledAdhanCount), 2, 10)`؛ iqamaSlots=10 عند التفعيل، ramadanSlots=15 في رمضان
   - النتائج: عادي 9 أيام، مع الإقامة 9، إقامة+رمضان ~6 — يصلح الخلل الكامن الحالي (70 > 64)

3. **`scheduleIqamaNotifications()`**: للصلوات الخمس؛ أفق = يومان (اليوم+الغد) على iOS وكامل الأفق على أندرويد/macOS؛ تخطي الأوقات الماضية؛ جدولة عبر `NotifyHelper().scheduledNotification` بـ `sound_type: 'bell'`، الملخص = `'timeForIqama'.tr + اسم الصلاة`، بدون `AdhanAlarmsScheduler` (ليست أذانًا كاملًا).

4. **`cancelAllIqamaNotifications()`**: إلغاء نطاق معرفات الإقامة.

5. التوصيل:
   - `reschedulePrayers()` → إلغاء ثم جدولة الإقامة إن فُعّلت، وأيام الأذان تُحسب بالميزانية (بدل الثابت 10)
   - `cancelAllPrayerNotifications()` → يشمل معرفات الإقامة
   - `prayer_background_manager.dart`: في المهمة الدورية، إن فُعّلت إشعارات الإقامة → تحديث نافذة اليوم+الغد حتى مع صلاحية الكاش (التجدد المتدحرج الذي يحاكي «الجدولة عند ظهور الأذان» ضمن قيود iOS التي لا تنفّذ كودًا عند ظهور الإشعار)

## الخطوة 5: الترجمة
إضافة المفاتيح إلى 11 ملف locale في `assets/locales/`:
`iqamaNotifications` (إشعارات الإقامة)، `iqamaNotificationsDesc`، `showIqamaTimes` (إظهار وقت الإقامة)، `iqama` (الإقامة)، `timeForIqama` (حان وقت إقامة صلاة)
بترجمات مناسبة لـ: ar, en, bn, es, fil, id, ku, ms, so, tr, ur.

## الخطوة 6: الاختبارات (flutter_test)
1. وحدة `IqamaOffsets`: الافتراضات، clamp (5/60)، الخطوة 5، حفظ/قراءة من GetStorage.
2. وحدة دالة الميزانية: iOS عادي=9، إقامة=9، إقامة+رمضان=6، أندرويد=30، حد أدنى 2.
3. widget: صف الإقامة يظهر تحت الصلوات الخمس فقط في `SettingPrayerTimes`، +/- يحدّثان القيمة، مفتاح الإظهار يخفي وقت الإقامة من صف الصلاة.

## الخطوة 7: التحقق
- `dart format` على المعدَّل + `flutter analyze` (صفر تحذيرات جديدة)
- `flutter test` — الجديدة والقديمة تمر

## قرارات مثبتة (من نقاش التصميم)
- الإشعار يصل **عند وقت الإقامة تمامًا** (لا تنبيه مسبق)
- إشعارات الإقامة **مغلقة افتراضيًا**، عرض الوقت **مفتوح افتراضيًا**
- الإقامة مستقلة عن إعداد أذان كل صلاة (مفتاح عام واحد)
- تعديل الإزاحة داخل `SettingPrayerTimes` تحت كل صلاة — **بدون قسم إعدادات جديد وبدون ملف widget جديد**

## ملاحظات مخاطر
- تفعيل الإقامة على iOS يقصّر أفق الأذان من 10 إلى 9 أيام (~6 في رمضان) — مقصود وموثق.
- نافذة الإقامة 48 ساعة تتجدد عند: فتح التطبيق (بعد 8 ثوانٍ)، المهمة الدورية (~20 دقيقة)، المهمة اليومية، تغيير الإعدادات. لتعطُّلها يجب ألا يعمل التطبيق 48 ساعة كاملة، وتلتئم ذاتيًا عند أول تشغيل.