part of '../cites.dart';

class CityPrayerTimesScreen extends StatelessWidget {
  final SavedCity city;

  CityPrayerTimesScreen({
    super.key,
    required this.city,
  });

  final citesCtrl = PrayersOfCitesController.instance;

  @override
  Widget build(BuildContext context) {
    final service = CityPrayerTimesService();
    final String lang = (Get.locale?.languageCode ?? 'ar').toLowerCase();

    return FutureBuilder<CityPrayerTimesResult>(
      future: service.getForCity(city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              'noData'.trParams({'x': 'citiesPrayerTimesTitle'.tr}),
              style: TextStyle(
                fontFamily: 'cairo',
                color: context.theme.colorScheme.inversePrimary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final data = snapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(16),
            FutureBuilder<({String city, String country})>(
              key: ValueKey('${city.id}|$lang'),
              future: citesCtrl.localizedCityDisplay(city, languageCode: lang),
              builder: (context, snapshot) {
                final displayCity = snapshot.data?.city ?? city.name;
                final displayCountry =
                    snapshot.data?.country ?? city.countryDisplay;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayCity,
                          style: TextStyle(
                            height: 1.3,
                            fontFamily: 'cairo',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.inversePrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          ' - $displayCountry',
                          style: TextStyle(
                            height: 1.3,
                            fontFamily: 'cairo',
                            fontSize: 22.sp,
                            color: context.theme.colorScheme.inversePrimary
                                .withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Gap(32),
            prayerProgressBarAndTitle(context, data, data.currentIndex),
            const Gap(16),
            PrayerBuild(
              prayersOverride: data.prayerList,
              currentPrayerIndexOverride: data.currentIndex,
              withOnTap: false,
              bottomPadding: 0.0,
            ),
          ],
        );
      },
    );
  }

  Widget prayerProgressBarAndTitle(
    BuildContext context,
    CityPrayerTimesResult data,
    int index,
  ) {
    if (index < 0 || index >= data.prayerList.length) {
      return const SizedBox.shrink();
    }

    final Duration durationLeft =
        citesCtrl.cityDurationLeftForIndex(data, index);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.theme.colorScheme.surface.withValues(alpha: .3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data.prayerList[data.currentIndex]['title']}'.tr,
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.inversePrimary
                          .withValues(alpha: .7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    data.prayerList[data.currentIndex]['time'],
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.inversePrimary
                          .withValues(alpha: .7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  StreamBuilder<int>(
                    stream: Stream<int>.periodic(
                        const Duration(seconds: 30), (i) => i),
                    builder: (context, _) {
                      final double percent =
                          citesCtrl.cityTimeLeftPercentForIndex(data, index);

                      return RoundedProgressBar(
                        height: 30,
                        style: RoundedProgressBarStyle(
                          borderWidth: 5,
                          widthShadow: 5,
                          backgroundProgress: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
                          colorProgress: Theme.of(context).colorScheme.surface,
                          colorProgressDark: Theme.of(context)
                              .colorScheme
                              .inversePrimary
                              .withValues(alpha: 0.1),
                          colorBorder: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.1),
                          colorBackgroundIcon: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        percent: percent,
                      );
                    },
                  ),
                  SlideCountdownWidget(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      duration: durationLeft),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, -15),
            child: Container(
              height: 30,
              width: 120,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      context.theme.colorScheme.surface.withValues(alpha: .3),
                  width: 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'timeLeft:'.tr,
                  style: TextStyle(
                    height: 1.3,
                    fontFamily: 'cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.inversePrimary
                        .withValues(alpha: .7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
