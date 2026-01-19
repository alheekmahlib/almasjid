part of '../../prayers.dart';

class _CountryPickerSheetController extends GetxController {
  final adhanCtrl = AdhanController.instance;
  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      query.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<String> get filteredCountries {
    final countries = adhanCtrl.state.countries;
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return countries;
    return countries.where((c) => c.toLowerCase().contains(q)).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  void clearSearch() => searchController.clear();
}

class CountryPickerBottomSheet extends StatelessWidget {
  CountryPickerBottomSheet({super.key})
      : controller = Get.isRegistered<_CountryPickerSheetController>()
            ? Get.find<_CountryPickerSheetController>()
            : Get.put(_CountryPickerSheetController()) {
    controller.clearSearch();
  }

  final _CountryPickerSheetController controller;

  void _disposeControllerIfNeeded() {
    if (Get.isRegistered<_CountryPickerSheetController>()) {
      Get.delete<_CountryPickerSheetController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _disposeControllerIfNeeded();
        return true;
      },
      child: SizedBox(
        height: Get.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'enterCountryName'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(
                    () => controller.query.value.trim().isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            onPressed: controller.clearSearch,
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxHeight: 45),
                  filled: true,
                  fillColor:
                      context.theme.colorScheme.surface.withValues(alpha: .2),
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
            const Gap(12),
            Expanded(
              child: Obx(() {
                final selected =
                    controller.adhanCtrl.state.selectedCountry.value;
                final filtered = controller.filteredCountries;

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'noResults'.tr,
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 14,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Gap(4),
                  itemBuilder: (context, index) {
                    final country = filtered[index];
                    final isSelected = country == selected;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.theme.colorScheme.surface
                                  .withValues(alpha: 0.22)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          border: Border.all(
                            color: isSelected
                                ? context.theme.colorScheme.primary
                                    .withValues(alpha: 0.45)
                                : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          title: Text(
                            country,
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 16,
                              color: context.theme.colorScheme.inversePrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: context.theme.colorScheme.primary,
                                )
                              : Icon(
                                  Icons.circle_outlined,
                                  color: context
                                      .theme.colorScheme.inversePrimary
                                      .withValues(alpha: 0.25),
                                ),
                          onTap: () {
                            controller.adhanCtrl.state.selectedCountry.value =
                                country;
                            _disposeControllerIfNeeded();
                            Get.back();
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
