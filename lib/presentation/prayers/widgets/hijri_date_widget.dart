part of '../prayers.dart';

class HijriDateWidget extends StatelessWidget {
  final Color? color;
  final double? horizontalPadding;
  final AlignmentGeometry? alignment;
  const HijriDateWidget(
      {super.key, this.color, this.horizontalPadding, this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment ?? AlignmentDirectional.centerEnd,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 0.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            customSvgWithCustomColor(
              'assets/svg/hijri/${EventController.instance.hijriNow.hMonth}.svg',
              color: (color ?? context.theme.canvasColor).withValues(alpha: .4),
              height: 48,
            ),
            Column(
              children: [
                Text(
                  EventController.instance.hijriNow.hDay
                      .toString()
                      .convertNumbers(),
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'cairo',
                    fontWeight: FontWeight.w700,
                    color: color ?? context.theme.canvasColor,
                    height: 1.2,
                  ),
                ),
                Text(
                  '${EventController.instance.hijriNow.getDayName()}FullName'
                      .tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'cairo',
                    fontWeight: FontWeight.w700,
                    color: color ?? context.theme.canvasColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
