part of '../prayers.dart';

class TimeNowWidget extends StatelessWidget {
  final double? height;
  final int? index;
  const TimeNowWidget({super.key, this.height, this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdhanController>(
        id: 'CurrentPrayer',
        builder: (adhanCtrl) => SizedBox(
              height: height ?? 128.h,
              child: adhanCtrl
                  .getTimeNowWidget(
                    index: index,
                    _fajirWidget(context, adhanCtrl),
                    _sunriseWidget(context, adhanCtrl),
                    _dhuhrWidget(context, adhanCtrl),
                    _asrWidget(context, adhanCtrl),
                    _maghribWidget(context, adhanCtrl),
                    _ishaWidget(context, adhanCtrl),
                  )
                  .value,
            ));
  }

  Widget _fajirWidget(BuildContext context, AdhanController adhanCtrl) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child:
                  customLottie(LottieConstants.assetsLottieMoon, height: 170)),
        ),
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: customLottie(LottieConstants.assetsLottieClouds2,
                width: Get.width)),
      ],
    );
  }

  Widget _sunriseWidget(BuildContext context, AdhanController adhanCtrl) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child:
                  customLottie(LottieConstants.assetsLottieSun, height: 170)),
        ),
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: customLottie(LottieConstants.assetsLottieClouds2,
                width: Get.width)),
      ],
    );
  }

  Widget _asrWidget(BuildContext context, AdhanController adhanCtrl) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: customLottie(LottieConstants.assetsLottieSun, height: 170),
        ),
        customLottie(LottieConstants.assetsLottieClouds2, width: Get.width),
      ],
    );
  }

  Widget _dhuhrWidget(BuildContext context, AdhanController adhanCtrl) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: customLottie(LottieConstants.assetsLottieSun, height: 220),
        ),
        customLottie(LottieConstants.assetsLottieClouds2, width: Get.width),
      ],
    );
  }

  Widget _maghribWidget(BuildContext context, AdhanController adhanCtrl) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child:
                  customLottie(LottieConstants.assetsLottieSun, height: 170)),
        ),
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: customLottie(LottieConstants.assetsLottieClouds2,
                width: Get.width)),
      ],
    );
  }

  Widget _ishaWidget(BuildContext context, AdhanController adhanCtrl) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: customLottie(LottieConstants.assetsLottieMoon, height: 100),
        ),
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white.withValues(alpha: .7),
                  Colors.white.withValues(alpha: .7),
                  Colors.white.withValues(alpha: .7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: customLottie(LottieConstants.assetsLottieClouds2,
                width: Get.width)),
      ],
    );
  }
}
