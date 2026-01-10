part of '../teaching.dart';

class _BranchTile extends StatelessWidget {
  final String name;
  final String title;
  final String subtitle;
  final bool? isSunnah;
  const _BranchTile({
    required this.name,
    required this.title,
    required this.subtitle,
    this.isSunnah = true,
  });

  @override
  Widget build(BuildContext context) {
    // return CustomOpenContainer(
    //   closedColor: closedColor ?? Colors.transparent,
    //   closedRadius: 16,

    //   // حجم المفتوح
    //   openWidth: Get.width,
    //   openHeight: Get.height,
    //   openColor: openColor ?? context.theme.colorScheme.primaryContainer,
    //   openRadius: 8,
    //   withBoxShadow: false,

    //   // المحتوى المغلق
    //   closedChild: Container(
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

    //   // المحتوى المفتوح
    //   openChild: Container(
    //       margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
    //       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    //       decoration: BoxDecoration(
    //         color: context.theme.colorScheme.surface.withValues(alpha: .08),
    //         borderRadius: BorderRadius.circular(12),
    //         border: Border.all(
    //           color: context.theme.colorScheme.surface.withValues(alpha: .15),
    //         ),
    //       ),
    //       child: SingleChildScrollView(
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
    //         ),
    //       )),
    // );
    return GestureDetector(
      onTap: () => customBottomSheet(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: context.theme.colorScheme.inversePrimary
                      .withValues(alpha: .7),
                  fontSize: 18,
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              Container(
                  // margin:
                  //     const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isSunnah!
                        ? context.theme.colorScheme.surface
                            .withValues(alpha: .08)
                        : Colors.orange.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: .15),
                    ),
                  ),
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
                  )),
            ],
          ),
        ),
        textTitle: title,
        containerColor: context.theme.colorScheme.primaryContainer,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSunnah!
              ? context.theme.colorScheme.surface.withValues(alpha: .08)
              : Colors.orange.withValues(alpha: .08),
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
    );
  }
}
