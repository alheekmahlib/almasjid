import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/services/location/locations.dart';
import '/core/utils/constants/extensions/bottom_sheet_extension.dart';
import '/core/utils/constants/extensions/extensions.dart';
import '/presentation/controllers/general/general_controller.dart';
import '../../../../core/utils/constants/lottie.dart';
import '../../../../core/utils/constants/lottie_constants.dart';
import '../../../../core/widgets/container_button_widget.dart';
import '../../../controllers/huawei_map_controller.dart';
import '../../splash.dart';
import 'huawei_map_widget.dart';

class ActiveLocationWidget extends StatelessWidget {
  ActiveLocationWidget({super.key});

  final generalCtrl = GeneralController.instance;
  final mapCtrl = FlutterMapController.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: HuaweiLocationHelper.instance.isHuaweiDevice(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isHuaweiDevice = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: context.customOrientation(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(16),
                customLottieWithColor(LottieConstants.assetsLottieLocation,
                    width: 250.0, color: context.theme.colorScheme.surface),
                const Spacer(),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'locationNote'.tr,
                    style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 16.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: context.theme.canvasColor),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Gap(32),
                _buttonsBuild(context, isHuaweiDevice),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Spacer(),
                      _buttonsBuild(context, isHuaweiDevice),
                    ],
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.2,
                        child: customLottieWithColor(
                            LottieConstants.assetsLottieLocation,
                            width: 250.0,
                            color: context.theme.colorScheme.surface),
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        decoration: BoxDecoration(
                            color: context.theme.colorScheme.surface
                                .withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'locationNote'.tr,
                          style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 8.sp,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: context.theme.canvasColor),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    customBottomSheet(
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
                  fontSize: 14.sp,
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
                              fontSize: 16.sp,
                              color: context.theme.colorScheme.inversePrimary,
                            ),
                          ),
                          subtitle: Text(
                            city['country'],
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 14.sp,
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

  void _showMapBottomSheet(BuildContext context) {
    customBottomSheet(
      textTitle: 'searchForCity'.tr,
      containerColor: context.theme.colorScheme.primaryContainer,
      child: const HuaweiMapLocationWidget(),
    );
  }

  Widget _buttonsBuild(BuildContext context, bool isHuaweiDevice) {
    return Column(
      children: [
        Obx(() => ContainerButtonWidget(
              onPressed: generalCtrl.state.isLocationLoading.value
                  ? null
                  : () async => isHuaweiDevice
                      ? _showSearchBottomSheet(context)
                      : await generalCtrl.initLocation().then((_) =>
                          SplashScreenController
                              .instance.state.customWidgetIndex.value = 2),
              height: 45,
              width: Get.width,
              horizontalMargin: 0,
              useGradient: false,
              withShape: false,
              isLoading: generalCtrl.state.isLocationLoading.value,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              borderColor: context.theme.colorScheme.surface,
              title: isHuaweiDevice ? 'searchForCity'.tr : 'locate'.tr,
            )),
        isHuaweiDevice ? const Gap(8) : const SizedBox.shrink(),
        isHuaweiDevice
            ? ContainerButtonWidget(
                onPressed: () => _showMapBottomSheet(context),
                height: 45,
                width: Get.width,
                horizontalMargin: 0,
                useGradient: false,
                withShape: false,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                borderColor: context.theme.colorScheme.surface,
                title: 'selectFromMap'.tr,
              )
            : const SizedBox.shrink(),
        const Gap(8),
        ContainerButtonWidget(
          onPressed: () => generalCtrl.cancelLocation(),
          height: 45,
          width: Get.width,
          horizontalMargin: 0,
          useGradient: false,
          withShape: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          borderColor: Colors.red,
          title: 'cancel'.tr,
        ),
      ],
    );
  }
}
