part of '../splash.dart';

final generalCtrl = GeneralController.instance;
final mapCtrl = FlutterMapController.instance;

extension ShowSearchBottomSheet on BuildContext {
  void showSearchBottomSheet(BuildContext context) {
    const SizedBox().customBottomSheet(
      textTitle: 'searchForCity'.tr,
      containerColor: context.theme.colorScheme.primaryContainer,
      child: SizedBox(
        height: Get.height * 0.8,
        child: Column(
          children: [
            // Search TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: mapCtrl.searchController,
                decoration: InputDecoration(
                  hintText: 'enterCityName'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() => mapCtrl.isSearching.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(13.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const SizedBox.shrink()),
                  contentPadding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    maxHeight: 45,
                  ),
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
                onChanged: (value) {
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mapCtrl.searchController.text == value) {
                      mapCtrl.searchCities(value);
                    }
                  });
                },
              ),
            ),
            const Gap(16),
            // Search Results
            Obx(() => mapCtrl.searchResults.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: mapCtrl.searchResults.length,
                      itemBuilder: (context, index) {
                        final city = mapCtrl.searchResults[index];
                        return ListTile(
                          title: Text(
                            city['name'],
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: context.theme.colorScheme.inversePrimary,
                            ),
                          ),
                          subtitle: Text(
                            city['country'],
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 14,
                              color: context.theme.colorScheme.inversePrimary
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          trailing: Icon(Icons.location_on,
                              color: context.theme.colorScheme.surface),
                          onTap: () => mapCtrl.selectCity(city),
                        );
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
