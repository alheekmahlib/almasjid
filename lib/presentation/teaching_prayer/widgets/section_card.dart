part of '../teaching.dart';

class _SectionCard extends StatelessWidget {
  final String title;
  final int index;
  const _SectionCard({required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = TeachingPrayerController.instance;
    final section = ctrl.sections[index];
    final lang = ctrl.currentLang;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.surface.withValues(alpha: .2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.theme.colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'cairo',
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: List.generate(section.branches.length, (i) {
                final b = section.branches[i];
                final name = b.resolveName(lang);
                final title = b.resolveTitle(lang);
                final subtitle = b.resolveSubtitle(lang);
                return _BranchTile(
                    name: name, title: title, subtitle: subtitle);
              }),
            ),
          ),
          const Gap(4),
        ],
      ),
    );
  }
}
