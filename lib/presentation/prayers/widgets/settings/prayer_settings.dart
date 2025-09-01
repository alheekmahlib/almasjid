part of '../../prayers.dart';

class PrayerSettings extends StatelessWidget {
  const PrayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GetBuilder<GeneralController>(builder: (generalCtrl) {
        return Column(
          children: [
            CustomSwitchWidget(
              controller: GeneralController.instance,
              title: 'detectLocation',
              value: generalCtrl.state.activeLocation.value,
              startMargin: 16.0,
              onChanged: (bool value) => generalCtrl.toggleLocationService(),
            ),
            AdhanSounds(),
            const Gap(8),
            SetTimingCalculations()
          ],
        );
      }),
    );
  }
}
