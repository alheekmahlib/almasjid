part of '../teaching.dart';

class _BranchTile extends StatelessWidget {
  final String name;
  final String title;
  final String subtitle;
  const _BranchTile(
      {required this.name, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => customBottomSheet(
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.theme.colorScheme.surface.withValues(alpha: .15),
              ),
            ),
            child: subtitle.buildTextString()),
        textTitle: name,
        containerColor: context.theme.colorScheme.primaryContainer,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.theme.colorScheme.surface.withValues(alpha: .15),
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color:
                context.theme.colorScheme.inversePrimary.withValues(alpha: .9),
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            fontFamily: 'cairo',
          ),
        ),
      ),
    );
  }
}
