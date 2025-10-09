import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/widgets/container_button_widget.dart';
import '/presentation/controllers/huawei_map_controller.dart';
import '../../../../core/utils/constants/api_constants.dart';

class HuaweiMapLocationWidget extends StatelessWidget {
  const HuaweiMapLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final mapController = Get.put(FlutterMapController());

    return SizedBox(
      height: Get.height * 0.7,
      child: Column(
        children: [
          // Map container
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Obx(() => Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      FlutterMap(
                        mapController: mapController.mapController,
                        options: MapOptions(
                          initialCenter: mapController.defaultLocation,
                          initialZoom: 13.0,
                          onTap: (tapPosition, point) {
                            mapController.onMapTap(point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: ApiConstants.mapHuaweiUrl,
                          ),
                          MarkerLayer(
                            markers: mapController.selectedLocation.value !=
                                    null
                                ? [
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point:
                                          mapController.selectedLocation.value!,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ]
                                : [],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => mapController.zoomIn,
                            child: Container(
                              height: 30,
                              width: 30,
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add,
                                  color: context.theme.canvasColor),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => mapController.zoomOut,
                            child: Container(
                              height: 30,
                              width: 30,
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.remove,
                                  color: context.theme.canvasColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),

          // Selected location info
          Obx(() => mapController.selectedLocation.value != null
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: context.theme.colorScheme.primary,
                            size: 20,
                          ),
                          Gap(8.w),
                          Text(
                            'locationSetted'.tr,
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Gap(8.h),
                      Obx(() => Text(
                            mapController.selectedAddress.value,
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 14,
                              color: context.theme.colorScheme.primary,
                            ),
                          )),
                    ],
                  ),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      Gap(8.w),
                      Expanded(
                        child: Text(
                          'tapOnMapToSelectLocation'.tr,
                          style: TextStyle(
                            fontFamily: 'cairo',
                            fontSize: 14,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Confirm button
                Expanded(
                  child: Obx(() => ContainerButtonWidget(
                        onPressed: mapController.selectedLocation.value != null
                            ? () async => await mapController.confirmLocation()
                            : null,
                        height: 45,
                        width: double.infinity,
                        horizontalMargin: 0,
                        useGradient: false,
                        withShape: false,
                        backgroundColor: Colors.transparent,
                        isLoading: mapController.isLoadingLocation.value,
                        borderColor: context.theme.colorScheme.surface,
                        titleColor: context.theme.colorScheme.inversePrimary,
                        title: 'locate'.tr,
                      )),
                ),
                const Gap(12),
                // Cancel button
                Expanded(
                  child: ContainerButtonWidget(
                    onPressed: () => Get.back(),
                    height: 45,
                    width: double.infinity,
                    horizontalMargin: 0,
                    useGradient: false,
                    withShape: false,
                    backgroundColor: Colors.transparent,
                    isLoading: mapController.isLoadingLocation.value,
                    borderColor: Colors.red,
                    titleColor: context.theme.colorScheme.inversePrimary,
                    title: 'cancel'.tr,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
