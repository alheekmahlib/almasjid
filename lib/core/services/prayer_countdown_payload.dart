// منطق نقي (بلا تبعيات) لحساب العدّ التنازلي للصلاة القادمة والوقت
// المنقضي على السابقة، بأوقات مطلقة تغطي الأمس/اليوم/الغد لتلاشي
// التباس خانات الليل (منتصف الليل والثلث الأخير) حول منتصف النهار.
//
// الفهرسة تتبع ترتيب prayerNameList في وحدة الصلوات:
// 0 الفجر، 1 الشروق، 2 الظهر، 3 العصر، 4 المغرب، 5 العشاء،
// 6 منتصف الليل، 7 الثلث الأخير.

/// خانة حدّ قابلة للعدّ بوقت مطلق فعلي.
class CountdownSlot {
  const CountdownSlot({required this.index, required this.at});

  /// فهرس الخانة ضمن prayerNameList (0-7).
  final int index;

  /// الوقت المطلق (تاريخ + ساعة) للخانة.
  final DateTime at;
}

/// فهارس الصلوات الخمس (فجر، ظهر، عصر، مغرب، عشاء). الخانات الأخرى
/// (شروق 1، منتصف الليل 6، الثلث الأخير 7) ليست صلواتٍ فيُوسم العدّ
/// إليها بوسم «الوقت القادم» لا «الصلاة القادمة».
const Set<int> prayerSlotIndices = {0, 2, 3, 4, 5};

bool isPrayerSlot(int index) => prayerSlotIndices.contains(index);

/// لقطة العدّ لحظة معيّنة.
class CountdownSnapshot {
  const CountdownSnapshot({
    required this.next,
    required this.prev,
    required this.elapsed,
  });

  /// أول خانة لم يحن وقتها بعد (قد تكون null إن غطّت القائمة الماضي كله).
  final CountdownSlot? next;

  /// آخر خانة مضى وقتها (قد تكون null إن لم يبدأ شيء بعد).
  final CountdownSlot? prev;

  /// الوقت المنقضي منذ [prev] حتى لحظة الحساب.
  final Duration elapsed;
}

/// يرتب الخانات زمنيًا وينظّف المتطابقات والمكررات.
List<CountdownSlot> normalizeSlots(List<CountdownSlot> slots) {
  final sorted = [...slots]..sort((a, b) => a.at.compareTo(b.at));
  // إسقاط المتطابقات تمامًا (نفس اللحظة) مع الاحتفاظ بالأخير.
  final result = <CountdownSlot>[];
  for (final slot in sorted) {
    if (result.isNotEmpty && result.last.at.isAtSameMomentAs(slot.at)) {
      result[result.length - 1] = slot;
      continue;
    }
    result.add(slot);
  }
  return result;
}

/// يحسب لقطة العدّ: الخانة القادمة والسابقة والمنقضي منذ السابقة.
///
/// يجب تمرير [slots] مرتبة (مخرجات [normalizeSlots]) وتغطي نافذة
/// زمنية كافية حول [now] (الأمس حتى الغد موصى بها).
CountdownSnapshot computeCountdownSnapshot({
  required List<CountdownSlot> slots,
  required DateTime now,
}) {
  CountdownSlot? prev;
  CountdownSlot? next;
  for (final slot in slots) {
    if (!slot.at.isAfter(now)) {
      prev = slot;
    } else {
      next = slot;
      break;
    }
  }
  return CountdownSnapshot(
    next: next,
    prev: prev,
    elapsed: prev == null ? Duration.zero : now.difference(prev.at),
  );
}

/// بيانات عرض العدّ — نفس حقول بطاقة iOS حرفيًا (نصوص مترجمة سلفًا
/// من Dart؛ المنصات الأصلية — RemoteViews أندرويد وLive Activity —
/// تعرضها مع عدّادين أصليين يحدّثهما النظام كل ثانية).
class CountdownDisplayData {
  const CountdownDisplayData({
    required this.nextLabel,
    required this.nextName,
    required this.nextTime,
    required this.nextAt,
    required this.elapsedLabel,
    required this.prevName,
    this.prevAt,
  });

  final String nextLabel;
  final String nextName;
  final String nextTime;
  final DateTime nextAt;
  final String elapsedLabel;
  final String prevName;
  final DateTime? prevAt;

  Map<String, Object?> toMap() => {
    'nextLabel': nextLabel,
    'nextName': nextName,
    'nextTime': nextTime,
    'nextAt': nextAt.millisecondsSinceEpoch,
    'elapsedLabel': elapsedLabel,
    'prevName': prevName,
    'prevAt': prevAt?.millisecondsSinceEpoch,
  };
}

/// حدّ مجدول أصليًا: بيانات العرض التي تسود ابتداءً من لحظة [at]
/// (وقت الخانة التي تبدأ). العدّاد التصاعدي يبدأ عندها من 0:00:00.
class CountdownBoundaryEntry {
  const CountdownBoundaryEntry({required this.at, required this.data});

  final DateTime at;
  final CountdownDisplayData data;

  Map<String, Object?> toMap() => {
    'at': at.millisecondsSinceEpoch,
    ...data.toMap(),
  };
}

/// يبني حدود النشر الأصلية لكل خانة قادمة لها خانةٌ تليها.
///
/// آخر خانة في [slots] لا تُنشئ حدًّا (لا توجد «قادمة» بعدها داخل
/// النافذة)، وتتجدد النافذة مع كل تشغيل للمهام الدورية أو فتح التطبيق.
List<CountdownBoundaryEntry> buildBoundaryEntries({
  required List<CountdownSlot> slots,
  required DateTime now,
  required CountdownDisplayData Function(
    CountdownSlot justStarted,
    CountdownSlot next,
  )
  buildData,
}) {
  final entries = <CountdownBoundaryEntry>[];
  for (var i = 0; i < slots.length - 1; i++) {
    final slot = slots[i];
    if (!slot.at.isAfter(now)) continue;
    entries.add(
      CountdownBoundaryEntry(at: slot.at, data: buildData(slot, slots[i + 1])),
    );
  }
  return entries;
}
