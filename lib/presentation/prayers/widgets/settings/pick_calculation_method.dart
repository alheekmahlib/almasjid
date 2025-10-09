part of '../../prayers.dart';

class PickCalculationMethod extends StatelessWidget {
  PickCalculationMethod({super.key});

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: adhanCtrl.state.countryListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PopupMenuButton(
              position: PopupMenuPosition.under,
              color: context.theme.colorScheme.primaryContainer,
              itemBuilder: (context) => List.generate(
                  adhanCtrl.state.countries.length,
                  (index) => PopupMenuItem(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                adhanCtrl.state.countries[index],
                                style: TextStyle(
                                    color: context
                                        .theme.colorScheme.inversePrimary
                                        .withValues(alpha: .7),
                                    fontSize: 16,
                                    fontFamily: 'cairo'),
                              ),
                              onTap: () {
                                adhanCtrl.state.selectedCountry.value =
                                    adhanCtrl.state.countries[index];
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      )),
              child: Semantics(
                button: true,
                enabled: true,
                label: adhanCtrl.state.selectedCountry.value,
                child: Container(
                  height: 37,
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color:
                        context.theme.colorScheme.surface.withValues(alpha: .2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            adhanCtrl.state.selectedCountry.value,
                            style: TextStyle(
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: .7),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'cairo'),
                          )),
                      Semantics(
                        button: true,
                        enabled: true,
                        label: adhanCtrl.state.selectedCountry.value,
                        child: Icon(Icons.keyboard_arrow_down_outlined,
                            size: 20, color: context.theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading countries: ${snapshot.error}');
          } else {
            return CircularProgressIndicator(
              color: context.theme.canvasColor,
            );
          }
        });
  }
}
