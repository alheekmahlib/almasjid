part of '../prayers.dart';

class ActiveLocationOrPrayerWidget extends StatelessWidget {
  const ActiveLocationOrPrayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<GeneralController>(
            builder: (generalCtrl) =>
                // generalCtrl.state.activeLocation.value
                //     ? PrayerNowWithButtonWidget(isWithButton: true)
                //     :
                Column(
              children: [
                const Gap(8.0),
                Text(
                  'pleaseActivateLocationFirstToShowAdhan'.tr,
                  style: TextStyle(
                    color: context.theme.colorScheme.inversePrimary,
                    fontSize: 16.0,
                    fontFamily: 'cairo',
                  ),
                ),
                const Gap(8.0),
                CustomSwitchWidget<GeneralController>(
                  controller: GeneralController.instance,
                  title: 'locate'.tr,
                  value: generalCtrl.state.activeLocation.value,
                  topPadding: 8.0,
                  bottomPadding: 8.0,
                  endPadding: 0.0,
                  startPadding: 0.0,
                  onChanged: (_) async =>
                      await generalCtrl.toggleLocationService(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
