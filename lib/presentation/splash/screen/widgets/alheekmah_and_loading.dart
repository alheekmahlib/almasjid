part of '../../splash.dart';

class AlheekmahAndLoading extends StatelessWidget {
  const AlheekmahAndLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: Get.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.only(top: 56.0),
                child: SplashScreenController.instance.ramadhanOrEidGreeting(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      customSvgWithColor(
                        SvgPath.svgAlheekmahLogo,
                        color: context.theme.canvasColor,
                        width: 90,
                      ),
                      Transform.translate(
                        offset: const Offset(0, 110),
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: customLottieWithColor(
                            LottieConstants.assetsLottieSplashLoading,
                            width: 250.0,
                            color: context.theme.colorScheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
