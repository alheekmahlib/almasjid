part of '../teaching.dart';

class _BranchTile extends StatelessWidget {
  final String name;
  final String title;
  final String subtitle;
  final Color? closedColor;
  final Color? openColor;
  const _BranchTile(
      {required this.name,
      required this.title,
      required this.subtitle,
      this.closedColor,
      this.openColor});

  @override
  Widget build(BuildContext context) {
    return CustomOpenContainer(
      closedColor: closedColor ?? Colors.transparent,
      closedRadius: 16,

      // حجم المفتوح
      openWidth: Get.width,
      openHeight: Get.height,
      openColor: openColor ?? context.theme.colorScheme.primaryContainer,
      openRadius: 8,
      withBoxShadow: false,

      // المحتوى المغلق
      closedChild: Container(
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
            fontSize: 15,
            fontFamily: 'cairo',
          ),
        ),
      ),

      // المحتوى المفتوح
      openChild: Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.theme.colorScheme.surface.withValues(alpha: .15),
            ),
          ),
          child: SingleChildScrollView(
            child: ArabicJustifiedRichText(
              textSpan: TextSpan(
                children: subtitle.buildTextString(),
                style: TextStyle(
                  color: context.theme.colorScheme.inversePrimary
                      .withValues(alpha: .9),
                  fontSize: 15,
                  fontFamily: 'cairo',
                ),
              ),
              textAlign: TextAlign.justify,
            ),
          )),
    );
    // return GestureDetector(
    //   onTap: () => customBottomSheet(
    //     child: Container(
    //         margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
    //         padding:
    //             const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    //         decoration: BoxDecoration(
    //           color: context.theme.colorScheme.surface.withValues(alpha: .08),
    //           borderRadius: BorderRadius.circular(12),
    //           border: Border.all(
    //             color: context.theme.colorScheme.surface.withValues(alpha: .15),
    //           ),
    //         ),
    //         child: ArabicJustifiedRichText(
    //           textSpan: TextSpan(
    //             children: subtitle.buildTextString(),
    //             style: TextStyle(
    //               color: context.theme.colorScheme.inversePrimary
    //                   .withValues(alpha: .9),
    //               fontSize: 15,
    //               fontFamily: 'cairo',
    //             ),
    //           ),
    //           textAlign: TextAlign.justify,
    //         )),
    //     textTitle: name,
    //     containerColor: context.theme.colorScheme.primaryContainer,
    //   ),
    //   child: Container(
    //     margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
    //     padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    //     decoration: BoxDecoration(
    //       color: context.theme.colorScheme.surface.withValues(alpha: .08),
    //       borderRadius: BorderRadius.circular(12),
    //       border: Border.all(
    //         color: context.theme.colorScheme.surface.withValues(alpha: .15),
    //       ),
    //     ),
    //     child: Text(
    //       name,
    //       style: TextStyle(
    //         color:
    //             context.theme.colorScheme.inversePrimary.withValues(alpha: .9),
    //         fontWeight: FontWeight.bold,
    //         fontSize: 15,
    //         fontFamily: 'cairo',
    //       ),
    //     ),
    //   ),
    // );
  }
}
