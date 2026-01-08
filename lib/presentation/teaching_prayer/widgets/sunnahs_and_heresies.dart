part of '../teaching.dart';

class SunnahsAndHeresies extends StatelessWidget {
  const SunnahsAndHeresies({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TeachingPrayerController.instance;
    final eventCtrl = EventController.instance;
    final currentMonth = eventCtrl.hijriNow.hMonth;

    // التحقق من وجود بيانات للشهر الحالي
    if (!ctrl.hasDataForMonth(currentMonth)) {
      return const SizedBox.shrink();
    }

    final monthData = ctrl.getMonthData(currentMonth);
    if (monthData == null || !monthData.hasContent) {
      return const SizedBox.shrink();
    }

    final hadith = ctrl.getHadithForMonth(currentMonth);
    final sunnahs = ctrl.getSunnahsForMonth(currentMonth);
    final heresies = ctrl.getHeresiesForMonth(currentMonth);
    final lang = ctrl.currentLang;

    return Column(
      children: [
        CustomOpenContainer(
          closedColor: Colors.transparent,
          closedRadius: 16,

          // حجم المفتوح
          openWidth: Get.width,
          openHeight: Get.height,
          openColor: context.theme.colorScheme.primaryContainer,
          openRadius: 8,
          withBoxShadow: false,
          closedChild: Container(
            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.theme.colorScheme.surface.withValues(alpha: .15),
              ),
            ),
            child: customSvgWithColor(
              'assets/svg/hijri/${monthData.number}.svg',
              height: 60,
              color: context.theme.colorScheme.surface,
            ),
          ),
          openChild: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      context.theme.colorScheme.surface.withValues(alpha: .15),
                ),
              ),
              child:
                  SingleChildScrollView(child: _HadithCard(hadith: hadith!))),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.theme.colorScheme.surface.withValues(alpha: .2),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              // عرض الحديث/الآية إن وُجد
              // if (hadith != null) _HadithCard(hadith: hadith),

              // عرض السنن
              if (sunnahs.isNotEmpty) ...[
                _CategoryHeader(
                  title: _getLocalizedText('sunnahs', lang),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const Gap(8),
                _ItemsGrid(
                  items: sunnahs,
                  lang: lang,
                  isSunnah: true,
                ),
                const Gap(8),
              ],

              // عرض البدع
              if (heresies.isNotEmpty) ...[
                _CategoryHeader(
                  title: _getLocalizedText('heresies', lang),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                const Gap(8),
                _ItemsGrid(
                  items: heresies,
                  lang: lang,
                  isSunnah: false,
                ),
              ],

              const Gap(8),
            ],
          ),
        ),
      ],
    );
  }

  static String _getLocalizedText(String key, String lang) {
    const Map<String, Map<String, String>> texts = {
      'sunnahs': {
        'ar': 'السُّنن',
        'en': 'Sunnahs',
        'tr': 'Sünnetler',
        'ur': 'سنتیں',
        'id': 'Sunnah',
        'ms': 'Sunnah',
        'bn': 'সুন্নাহ',
        'es': 'Sunnas',
      },
      'heresies': {
        'ar': 'البِدَع',
        'en': 'Innovations (Bid\'ah)',
        'tr': 'Bid\'atler',
        'ur': 'بدعات',
        'id': 'Bid\'ah',
        'ms': 'Bid\'ah',
        'bn': 'বিদ\'আত',
        'es': 'Innovaciones',
      },
    };
    return texts[key]?[lang] ?? texts[key]?['ar'] ?? key;
  }
}

/// بطاقة عرض الحديث/الآية
class _HadithCard extends StatelessWidget {
  final HadithInfo hadith;
  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ArabicJustifiedRichText(
          textSpan: TextSpan(
            children: hadith.ayahOrHadith.buildTextString(),
            style: TextStyle(
              color: context.theme.colorScheme.inversePrimary,
              fontSize: 15,
              fontFamily: 'cairo',
              height: 1.8,
            ),
          ),
          textAlign: TextAlign.justify,
        ),
        if (hadith.bookInfo.isNotEmpty) ...[
          const Gap(12),
          Text(
            hadith.bookInfo,
            style: TextStyle(
              color: context.theme.colorScheme.inversePrimary
                  .withValues(alpha: .6),
              fontSize: 12,
              fontFamily: 'cairo',
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ],
    );
  }
}

/// عنوان القسم (سنن / بدع)
class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const Gap(8),
        Text(
          title,
          style: TextStyle(
            color: context.theme.colorScheme.inversePrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'cairo',
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

/// شبكة عرض العناصر (سنن أو بدع)
class _ItemsGrid extends StatelessWidget {
  final List<dynamic> items;
  final String lang;
  final bool isSunnah;

  const _ItemsGrid({
    required this.items,
    required this.lang,
    required this.isSunnah,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final name = isSunnah
            ? (item as SunnahItem).resolveName(lang)
            : (item as HeresyItem).resolveName(lang);
        final description = isSunnah
            ? (item as SunnahItem).resolveDescription(lang)
            : (item as HeresyItem).resolveDescription(lang);

        return _BranchTile(
          name: name,
          title: name,
          subtitle: description,
          closedColor: isSunnah
              ? Colors.green.withValues(alpha: .08)
              : Colors.orange.withValues(alpha: .08),
          // openColor: isSunnah
          //     ? Colors.green.withValues(alpha: .15)
          //     : Colors.orange.withValues(alpha: .08),
          // isSunnah: isSunnah,
        );
      }).toList(),
    );
  }
}
