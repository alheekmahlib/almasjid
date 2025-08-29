part of '../../prayers.dart';

class SetTimingCalculations extends StatelessWidget {
  SetTimingCalculations({super.key});

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            'setTimingCalculations'.tr,
            style: TextStyle(
                color: context.theme.canvasColor,
                fontFamily: 'cairo',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Gap(4),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'automaticallyDetermineCalculationMethod',
            value: adhanCtrl.state.autoCalculationMethod.value,
            onChanged: (bool value) => adhanCtrl.switchAutoCalculation(value),
          ),
          const Gap(8),
          Obx(() => !adhanCtrl.state.autoCalculationMethod.value
              ? PickCalculationMethod()
              : const SizedBox.shrink()),
          const Gap(8),
          Text(
            'madhab'.tr,
            style: TextStyle(
                color: context.theme.canvasColor.withValues(alpha: .7),
                fontFamily: 'cairo',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Gap(4),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'shafie',
            value: !adhanCtrl.state.isHanafi,
            // value: (!adhanCtrl.state.isHanafi).obs,
            onChanged: (v) => adhanCtrl.hanafiOnTap(!v),
          ),
          CustomSwitchWidget<AdhanController>(
              controller: AdhanController.instance,
              title: 'hanafe',
              value: adhanCtrl.state.isHanafi,
              onChanged: adhanCtrl.hanafiOnTap),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'madhabNote'.tr,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.theme.canvasColor.withValues(alpha: .5),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const Gap(32),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'middleOfTheNight',
            value: adhanCtrl.state.middleOfTheNight.value,
            onChanged: (bool value) async {
              adhanCtrl.getHighLatitudeRule(0);
              // await adhanCtrl.initializeStoredAdhan(forceUpdate: true);
            },
          ),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'SeventhOfTheNight',
            value: adhanCtrl.state.seventhOfTheNight.value,
            onChanged: (bool value) async {
              adhanCtrl.getHighLatitudeRule(1);
              // await adhanCtrl.initializeStoredAdhan(forceUpdate: true);
            },
          ),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'usingTheAngle',
            value: adhanCtrl.state.twilightAngle.value,
            onChanged: (bool value) async {
              adhanCtrl.getHighLatitudeRule(2);
              // await adhanCtrl.initializeStoredAdhan(forceUpdate: true);
            },
          ),
          const Gap(32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SettingPrayerTimes(isOnePrayer: false),
          ),
        ],
      ),
    );
  }
}
