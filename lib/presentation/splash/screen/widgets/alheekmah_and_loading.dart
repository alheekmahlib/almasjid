part of '../../splash.dart';

class AlheekmahAndLoading extends StatelessWidget {
  const AlheekmahAndLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          customSvgWithColor(
            SvgPath.svgAlheekmahLogo,
            color: context.theme.canvasColor,
            width: 90,
          ),
          Transform.translate(
            offset: const Offset(0, 30),
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
    );
  }
}
