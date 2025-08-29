part of '../../prayers.dart';

class PrayerSettings extends StatelessWidget {
  const PrayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GeneralController>(builder: (generalCtrl) {
      return Column(
        children: [
          CustomSwitchWidget(
            controller: GeneralController.instance,
            title: 'detectLocation',
            value: generalCtrl.state.activeLocation.value,
            bottomPadding: 8.0,
            onChanged: (bool value) => generalCtrl.toggleLocationService(),
          ),
          AdhanSounds(),
          const Gap(8),
          SetTimingCalculations()
        ],
      );
    });
  }
}
