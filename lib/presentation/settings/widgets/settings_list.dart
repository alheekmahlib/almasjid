import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/extensions.dart';
import '/core/utils/constants/extensions/svg_extensions.dart';
import '../../../core/utils/constants/svg_constants.dart';
import '../../../core/utils/helpers/app_router.dart';
import '../../../core/widgets/container_button_widget.dart';
import '../../controllers/general/general_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../home/home.dart';
import 'language_list.dart';
import 'theme_change.dart';

class SettingsList extends StatelessWidget {
  SettingsList({super.key});
  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (_) {
      return Column(
        children: [
          Column(
            children: [
              const LanguageList(),
              const Gap(8),
              ThemeChange(),
              const Gap(8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    _customButtonWidget(
                      context,
                      title: 'ourApps',
                      svgPath: SvgPath.svgAlheekmahLogo,
                      onTap: () => Get.toNamed(
                        AppRouter.ourApps,
                      ),
                    ),
                    const Gap(4),
                    _customButtonWidget(
                      context,
                      title: 'aboutApp',
                      iconWidth: 40.0,
                      svgPath: SvgPath.svgLogoAqemLogo,
                      onTap: () => Get.toNamed(
                        AppRouter.aboutApp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _customButtonWidget(
    BuildContext context, {
    required VoidCallback onTap,
    required String svgPath,
    required String title,
    double? iconWidth,
  }) {
    return ContainerButtonWidget(
      onPressed: () {
        if (HomeController.instance.floatyMenuController.isOpen) {
          HomeController.instance.floatyMenuController.close();
        }
        onTap();
      },
      backgroundColor: context.theme.colorScheme.primaryContainer,
      svgColor: context.theme.colorScheme.surface,
      shapeColor: Colors.transparent,
      borderRadius: 10.0,
      verticalPadding: 0.0,
      horizontalMargin: 0.0,
      height: 45,
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: customSvgWithColor(svgPath,
                    width: (iconWidth ?? 60.0),
                    color: Theme.of(context).colorScheme.surface)),
            context.vDivider(height: 20.0),
            Expanded(
              flex: 8,
              child: Text(
                title.tr,
                style: TextStyle(
                  fontSize: 17,
                  color: context.theme.colorScheme.inversePrimary
                      .withValues(alpha: .6),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
