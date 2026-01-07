part of '../teaching.dart';

// ======= Widget قابل لإعادة الاستخدام =======
class CustomOpenContainer extends StatelessWidget {
  final Widget closedChild;
  final Widget openChild;
  final double openWidth;
  final double openHeight;
  final Duration duration;
  final Color closedColor;
  final Color openColor;
  final double closedRadius;
  final double openRadius;
  final bool withBoxShadow;

  const CustomOpenContainer({
    super.key,
    required this.closedChild,
    required this.openChild,
    this.openWidth = 300,
    this.openHeight = 400,
    this.duration = const Duration(milliseconds: 400),
    this.closedColor = Colors.blue,
    this.openColor = Colors.white,
    this.closedRadius = 12,
    this.openRadius = 8,
    this.withBoxShadow = true,
  });

  void _openContainer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SafeArea(
            child: Center(
              child: Hero(
                tag: 'container_$hashCode',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: openWidth,
                    height: openHeight,
                    decoration: BoxDecoration(
                      color: openColor,
                      borderRadius: BorderRadius.circular(openRadius),
                      boxShadow: withBoxShadow
                          ? const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 6, 6, 0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Get.back(),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: customSvgWithColor(
                                    SvgPath.svgArrowUp,
                                    height: 25,
                                    color: context.theme.colorScheme.surface,
                                  ),
                                ),
                              ),
                              const Gap(16),
                              Expanded(child: closedChild),
                            ],
                          ),
                        ),
                        Expanded(child: openChild),
                        const Gap(6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openContainer(context),
      child: Hero(
        tag: 'container_$hashCode',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: closedColor,
              borderRadius: BorderRadius.circular(closedRadius),
              boxShadow: withBoxShadow
                  ? const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: closedChild,
          ),
        ),
      ),
    );
  }
}
