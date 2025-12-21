import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../presentation/controllers/general/general_controller.dart';
import '../../presentation/prayers/prayers.dart';
import 'animated_drawing_widget.dart';

class ActiveLocationButton extends StatelessWidget {
  ActiveLocationButton({
    super.key,
  });

  final generalCtrl = GeneralController.instance;
  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AnimatedDrawingWidget(
          height: 70,
          width: 140,
          isRepeat: true,
        ),
        const Gap(16),
        Container(
          height: 80,
          width: Get.width,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withValues(alpha: .1),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                child: Text(
                  'activeLocationPlease'.tr,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'naskh',
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.inversePrimary
                        .withValues(alpha: .7),
                  ),
                ),
              ),
              const Gap(32),
              Expanded(
                flex: 2,
                child: Obx(() => Switch(
                      value: generalCtrl.state.activeLocation.value,
                      activeThumbColor: Colors.red,
                      inactiveTrackColor: context.theme.colorScheme.surface
                          .withValues(alpha: .5),
                      activeTrackColor: context.theme.colorScheme.surface
                          .withValues(alpha: .7),
                      thumbColor: WidgetStatePropertyAll(
                          context.theme.colorScheme.surface),
                      trackOutlineColor: WidgetStatePropertyAll(adhanCtrl
                              .state.autoCalculationMethod.value
                          ? context.theme.colorScheme.surface
                          : context.theme.canvasColor.withValues(alpha: .5)),
                      onChanged: (_) async =>
                          await generalCtrl.toggleLocationService(),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
