import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/services/languages/app_constants.dart';
import '../../../core/services/languages/localization_controller.dart';
import '../../controllers/settings_controller.dart';
import 'button_with_new_style.dart';

class LanguageList extends StatelessWidget {
  const LanguageList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localCtrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'langChange'.tr,
              style: TextStyle(
                color: context.theme.colorScheme.inversePrimary,
                fontFamily: 'cairo',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Gap(4),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: context.theme.highlightColor, width: 1.5),
                  borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                textColor: context.theme.colorScheme.primary,
                backgroundColor: context.theme.colorScheme.primaryContainer,
                collapsedBackgroundColor:
                    context.theme.colorScheme.primaryContainer,
                collapsedIconColor: context.theme.colorScheme.inversePrimary,
                iconColor: context.theme.colorScheme.inversePrimary,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: SizedBox(
                  width: 100.0,
                  child: Obx(() {
                    return Text(
                      SettingsController.instance.languageName.value,
                      style: TextStyle(
                        fontSize: 18,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .6),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cairo',
                        height: 1.7,
                      ),
                    );
                  }),
                ),
                children: <Widget>[
                  OverflowBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children:
                          List.generate(AppConstants.languages.length, (index) {
                        final lang = AppConstants.languages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ButtonWithNewStyle(
                            onTap: () => localCtrl.changeLangOnTap(index),
                            controller: localCtrl,
                            containerHeight: 37,
                            containerWidth: Get.width,
                            checkBoxColor: context.theme.colorScheme.surface,
                            value: 'lang'.tr == lang.languageName,
                            svgPath: null,
                            imagePath: null,
                            child: Center(
                              child: Text(
                                lang.languageName,
                                style: TextStyle(
                                  color: 'lang'.tr == lang.languageName
                                      ? context.theme.colorScheme.inversePrimary
                                      : context.theme.colorScheme.inversePrimary
                                          .withValues(alpha: .5),
                                  fontSize: 16,
                                  fontWeight: 'lang'.tr == lang.languageName
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontFamily: 'noto',
                                ),
                              ),
                            ),
                          ),
                        );
                      })),
                  const Gap(8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
