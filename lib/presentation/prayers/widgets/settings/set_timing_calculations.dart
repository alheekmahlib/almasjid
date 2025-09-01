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
                color: context.theme.colorScheme.inversePrimary,
                fontFamily: 'cairo',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Gap(4),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            startMargin: 16.0,
            title: 'automaticallyDetermineCalculationMethod',
            value: adhanCtrl.state.autoCalculationMethod.value,
            onChanged: (bool value) => adhanCtrl.switchAutoCalculation(value),
          ),
          Obx(() => !adhanCtrl.state.autoCalculationMethod.value
              ? PickCalculationMethod()
              : const SizedBox.shrink()),
          Text(
            'madhab'.tr,
            style: TextStyle(
                color: context.theme.colorScheme.inversePrimary
                    .withValues(alpha: .7),
                fontFamily: 'cairo',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Gap(4),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'shafie',
            startMargin: 16.0,
            value: !adhanCtrl.state.isHanafi,
            // value: (!adhanCtrl.state.isHanafi).obs,
            onChanged: (v) => adhanCtrl.hanafiOnTap(!v),
          ),
          CustomSwitchWidget<AdhanController>(
              controller: AdhanController.instance,
              title: 'hanafe',
              startMargin: 16.0,
              value: adhanCtrl.state.isHanafi,
              onChanged: adhanCtrl.hanafiOnTap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'madhabNote'.tr,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.inversePrimary
                    .withValues(alpha: .5),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const Gap(32),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'middleOfTheNight',
            startMargin: 16.0,
            value: adhanCtrl.state.middleOfTheNight.value,
            onChanged: (bool value) async {
              adhanCtrl.getHighLatitudeRule(0);
              // await adhanCtrl.initializeStoredAdhan(forceUpdate: true);
            },
          ),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'SeventhOfTheNight',
            startMargin: 16.0,
            value: adhanCtrl.state.seventhOfTheNight.value,
            onChanged: (bool value) async {
              adhanCtrl.getHighLatitudeRule(1);
              // await adhanCtrl.initializeStoredAdhan(forceUpdate: true);
            },
          ),
          CustomSwitchWidget<AdhanController>(
            controller: AdhanController.instance,
            title: 'usingTheAngle',
            startMargin: 16.0,
            value: adhanCtrl.state.twilightAngle.value,
            onChanged: (bool value) async {
              adhanCtrl.getHighLatitudeRule(2);
              // await adhanCtrl.initializeStoredAdhan(forceUpdate: true);
            },
          ),
          const Gap(8),
          const SettingPrayerTimes(isOnePrayer: false),
        ],
      ),
    );
  }
}
