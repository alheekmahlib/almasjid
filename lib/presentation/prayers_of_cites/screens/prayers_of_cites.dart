part of '../cites.dart';

class PrayersOfCites extends StatelessWidget {
  const PrayersOfCites({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = PrayersOfCitesController.instance;

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface.withValues(alpha: .1),
      body: SafeArea(
        child: Container(
          color: context.theme.colorScheme.primaryContainer,
          child: GetBuilder<PrayersOfCitesController>(
            id: 'cities',
            init: ctrl,
            builder: (controller) {
              return Column(
                children: [
                  const AppBarWidget(withBackButton: false),
                  const Gap(16),
                  Expanded(
                    child: context.customOrientation(
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'cites'.tr,
                                  style: TextStyle(
                                    fontFamily: 'cairo',
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: context
                                        .theme.colorScheme.inversePrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(12),
                                _SearchBar(
                                  onTap: () => context.showSearchBottomSheet(
                                    context,
                                    onCitySelected:
                                        controller.addFromSearchResult,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: controller.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : controller.cities.isEmpty
                                    ? Center(
                                        child: Text(
                                          'citiesPrayerTimesSearchHint'.tr,
                                          style: TextStyle(
                                            fontFamily: 'cairo',
                                            fontSize: 14,
                                            color: context.theme.colorScheme
                                                .inversePrimary
                                                .withValues(alpha: 0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : ReorderableListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        itemCount: controller.cities.length,
                                        onReorder: controller.reorder,
                                        itemBuilder: (context, index) {
                                          final city = controller.cities[index];

                                          return Padding(
                                            key: ValueKey(city.id),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3.0),
                                            child: _CityCard(
                                              city: city,
                                              onDelete: () => controller
                                                  .removeCity(city.id),
                                              onTap: () => customBottomSheet(
                                                containerColor: context
                                                    .theme
                                                    .colorScheme
                                                    .primaryContainer,
                                                child: CityPrayerTimesScreen(
                                                    city: city),
                                              ),
                                              dragHandle:
                                                  ReorderableDragStartListener(
                                                index: index,
                                                child: Icon(
                                                  Icons.drag_handle,
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .inversePrimary
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'citiesPrayerTimesTitle'.tr,
                                    style: TextStyle(
                                      fontFamily: 'cairo',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: context
                                          .theme.colorScheme.inversePrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Gap(12),
                                  _SearchBar(
                                    onTap: () => context.showSearchBottomSheet(
                                      context,
                                      onCitySelected:
                                          controller.addFromSearchResult,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: controller.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : controller.cities.isEmpty
                                    ? Center(
                                        child: Text(
                                          'citiesPrayerTimesSearchHint'.tr,
                                          style: TextStyle(
                                            fontFamily: 'cairo',
                                            fontSize: 14,
                                            color: context.theme.colorScheme
                                                .inversePrimary
                                                .withValues(alpha: 0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : ReorderableListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        itemCount: controller.cities.length,
                                        onReorder: controller.reorder,
                                        itemBuilder: (context, index) {
                                          final city = controller.cities[index];

                                          return Padding(
                                            key: ValueKey(city.id),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3.0),
                                            child: _CityCard(
                                              city: city,
                                              onDelete: () => controller
                                                  .removeCity(city.id),
                                              onTap: () => customBottomSheet(
                                                containerColor: context
                                                    .theme
                                                    .colorScheme
                                                    .primaryContainer,
                                                child: CityPrayerTimesScreen(
                                                    city: city),
                                              ),
                                              dragHandle:
                                                  ReorderableDragStartListener(
                                                index: index,
                                                child: Icon(
                                                  Icons.drag_handle,
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .inversePrimary
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'citiesPrayerTimesSearchHint'.tr,
            prefixIcon: const Icon(Icons.search),
            contentPadding: EdgeInsets.zero,
            constraints: const BoxConstraints(maxHeight: 45),
            filled: true,
            fillColor: context.theme.colorScheme.surface.withValues(alpha: .2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.theme.colorScheme.surface,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.theme.colorScheme.surface,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.theme.colorScheme.surface,
                width: 1,
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'cairo',
            fontSize: 14,
            color: context.theme.colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  final SavedCity city;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Widget dragHandle;

  const _CityCard({
    required this.city,
    required this.onTap,
    required this.onDelete,
    required this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final String lang = (Get.locale?.languageCode ?? 'ar').toLowerCase();
    final service = CityPrayerTimesService();
    final citesCtrl = PrayersOfCitesController.instance;
    return ContainerButtonWidget(
      onPressed: onTap,
      width: Get.width,
      height: 90,
      backgroundColor:
          context.theme.colorScheme.surface.withValues(alpha: 0.15),
      borderColor: Colors.transparent,
      shadowColor: Colors.transparent,
      useGradient: false,
      withShape: false,
      // borderRadius: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: onDelete,
                    width: 40,
                    iconSize: 25,
                    verticalPadding: 0,
                    svgColor: Colors.red.withValues(alpha: 0.8),
                    icon: Icons.delete_outline,
                  ),
                ),
                Expanded(child: dragHandle),
              ],
            ),
            const Gap(8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<({String city, String country})>(
                    key: ValueKey('${city.id}|$lang'),
                    future: citesCtrl.localizedCityDisplay(city,
                        languageCode: lang),
                    builder: (context, snapshot) {
                      final displayCity = snapshot.data?.city ?? city.name;
                      final displayCountry =
                          snapshot.data?.country ?? city.countryDisplay;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              displayCity,
                              style: TextStyle(
                                height: 1.3,
                                fontFamily: 'cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.inversePrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              displayCountry,
                              style: TextStyle(
                                height: 1.3,
                                fontFamily: 'cairo',
                                fontSize: 14,
                                color: context.theme.colorScheme.inversePrimary
                                    .withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: double.infinity,
              color: context.theme.colorScheme.surface.withValues(alpha: 0.25),
            ),
            const Gap(6),
            FutureBuilder<CityPrayerTimesResult>(
                future: service.getForCity(city),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: 110,
                      child: Text(
                        '--',
                        style: TextStyle(
                          height: 1.3,
                          fontFamily: 'cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final data = snapshot.data!;
                  return SizedBox(
                    width: 110,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.prayerList[data.currentIndex]['title']}'.tr,
                          style: TextStyle(
                            height: 1.3,
                            fontFamily: 'cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.theme.colorScheme.inversePrimary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const Gap(6),
                        Text(
                          data.prayerList[data.currentIndex]['time'],
                          style: TextStyle(
                            height: 1.3,
                            fontFamily: 'cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
