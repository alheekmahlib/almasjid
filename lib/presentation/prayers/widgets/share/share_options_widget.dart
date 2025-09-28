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
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(12),
          _imageBuild(card, context),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _imageBuild(ClipRRect card, BuildContext context) {
    return ContainerButtonWidget(
      onPressed: shareCtrl.isSaving.value
          ? null
          : () async {
              await shareCtrl.createAndShowVerseImage();
              await shareCtrl.shareAsImage();
            },
      height: 310,
      horizontalMargin: 0.0,
      borderRadius: 0.0,
      backgroundColor: context.theme.colorScheme.surface.withValues(alpha: .3),
      useGradient: false,
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
                        color: context.theme.colorScheme.inversePrimary,
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
