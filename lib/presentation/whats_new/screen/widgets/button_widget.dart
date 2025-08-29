part of '../../whats_new.dart';

class ButtonWidget extends StatelessWidget {
  final PageController controller;
  final List<Map<String, dynamic>> newFeatures;

  ButtonWidget(
      {super.key, required this.controller, required this.newFeatures});

  final whatsNewCtrl = WhatsNewController.instance;
  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    whatsNewCtrl.state.currentPageIndex.value = controller.page?.toInt() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: Obx(() {
        return SizedBox(
          height: 45,
          child: CustomButton(
            onPressed: () {
              if (whatsNewCtrl.state.currentPageIndex.value ==
                  newFeatures.length - 1) {
                whatsNewCtrl.saveLastShownIndex(newFeatures.last['index']);
                Get.offAllNamed(AppRouter.homeScreen);
              } else {
                controller.animateToPage(controller.page!.toInt() + 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeIn);
              }
            },
            svgPath: SvgPath.svgCheckMark,
            svgColor: context.theme.colorScheme.surface,
            titleColor: context.theme.canvasColor,
            iconWidget: Center(
              child: whatsNewCtrl.state.currentPageIndex.value ==
                      newFeatures.length - 1
                  ? Text('start'.tr,
                      style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 18,
                          color: context.theme.canvasColor))
                  : Icon(
                      Icons.arrow_forward,
                      color: context.theme.colorScheme.primary,
                    ),
            ),
          ),
        );
      }),
    );
  }
}
