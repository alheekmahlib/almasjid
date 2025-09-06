part of '../../prayers.dart';

class ShareOptionsWidget extends StatelessWidget {
  ShareOptionsWidget({super.key});

  final shareCtrl = ShareController.instance;

  @override
  Widget build(BuildContext context) {
    // Card to be captured
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Screenshot(
        controller: shareCtrl.screenshotController,
        child: _ShareCard(),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(12),
          _imageBuild(card, context),
          const Gap(6),
          Text(
            'The image will include the next prayer time, remaining time, Hijri date, and your location.'
                .tr,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  ContainerButtonWidget _imageBuild(ClipRRect card, BuildContext context) {
    return ContainerButtonWidget(
      onPressed: shareCtrl.isSaving.value
          ? null
          : () async {
              await shareCtrl.createAndShowVerseImage();
              await shareCtrl.shareAsImage();
            },
      height: 290,
      child: Column(
        children: [
          card,
          const Spacer(),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                shareCtrl.isSaving.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : customSvgWithColor(
                        SvgPath.svgShareShare,
                        height: 24,
                        color: context.theme.canvasColor,
                      ),
                const Gap(16),
                Text(
                    shareCtrl.isSaving.value ? 'saving...'.tr : 'shareImage'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'cairo',
                      color: context.theme.colorScheme.inversePrimary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
