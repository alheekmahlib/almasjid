part of '../whats_new.dart';

class WhatsNewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> newFeatures;
  WhatsNewScreen({super.key, required this.newFeatures});

  final controller = PageController(viewportFraction: 1, keepPage: true);
  final whatsNewCtrl = WhatsNewController.instance;
  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Text(
                  'skip'.tr,
                  style: TextStyle(
                    color: context.theme.colorScheme.surface,
                    fontSize: 12.0.sp,
                    fontFamily: 'cairo',
                  ),
                ),
                onTap: () {
                  Get.offAllNamed(AppRouter.homeScreen);
                  whatsNewCtrl.saveLastShownIndex(newFeatures.last['index']);
                },
              ),
              SmoothPageIndicatorWidget(
                controller: controller,
                newFeatures: newFeatures,
              ),
            ],
          ),
          const Gap(16),
          const WhatsNewWidget(),
          PageViewBuild(
            controller: controller,
            newFeatures: newFeatures,
          ),
          ButtonWidget(
            controller: controller,
            newFeatures: newFeatures,
          ),
        ],
      ),
    );
  }
}
