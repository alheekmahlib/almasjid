part of '../../prayers.dart';

class PickCalculationMethod extends StatelessWidget {
  PickCalculationMethod({super.key});

  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    final countryFuture =
        adhanCtrl.state.countryListFuture ??= adhanCtrl.getCountryList();
    return FutureBuilder<List<String>>(
        future: countryFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Obx(
              () => Semantics(
                button: true,
                enabled: true,
                label: adhanCtrl.state.selectedCountry.value,
                child: ContainerButtonWidget(
                  onPressed: () => customBottomSheet(
                    textTitle: 'selectCountry'.tr,
                    containerColor: context.theme.colorScheme.primaryContainer,
                    child: CountryPickerBottomSheet(),
                  ),
                  height: 47,
                  width: Get.width,
                  useGradient: false,
                  withShape: false,
                  borderRadius: 8,
                  borderColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  backgroundColor:
                      context.theme.colorScheme.surface.withValues(alpha: .2),
                  horizontalPadding: 16,
                  verticalPadding: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        adhanCtrl.state.selectedCountry.value,
                        style: TextStyle(
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'cairo',
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 20,
                        color: context.theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('failedToLoadCountries'.tr);
          } else {
            return CircularProgressIndicator(
              color: context.theme.canvasColor,
            );
          }
        });
  }
}
