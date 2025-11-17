part of '../prayers.dart';

class PrayerScreen extends StatelessWidget {
  PrayerScreen({super.key});

  final generalCtrl = GeneralController.instance;
  final adhanCtrl = AdhanController.instance;
  final eventCtrl = EventController.instance;

  @override
  Widget build(BuildContext context) {
    // adhanCtrl.initializeAdhan();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) {
          return;
        }
        PrayersNotificationsCtrl.instance.state.adhanPlayer.stop();
        Get.back();
      },
      child: Obx(
        () => !generalCtrl.state.activeLocation.value
            ? ActiveLocationButton()
            : Scaffold(
                backgroundColor: context.theme.colorScheme.surface,
                body: SafeArea(
                  child: Container(
                    color: context.theme.colorScheme.primaryContainer,
                    child: Column(
                      children: [
                        const AppBarWidget(),
                        GetBuilder<AdhanController>(
                          id: 'loading_state',
                          builder: (controller) =>
                              controller.state.isLoadingPrayerData.value
                                  ? const LoadingWidget()
                                  : Flexible(
                                      child: context.customOrientation(
                                        portraitBuild(context),
                                        landscapeBuild(context),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget portraitBuild(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            width: context.customOrientation(Get.width, Get.width * .45),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(16.h),
                  const PrayerNowWidget(),
                  Gap(8.h),
                  context.hDivider(width: Get.width * .5),
                  Gap(8.h),
                  Row(
                    children: [
                      Expanded(
                        child: updateLocationBuild(context),
                      ),
                      Expanded(
                        child: HijriDateWidget(
                          svgColor: context.theme.colorScheme.surface,
                          horizontalPadding: 24.0,
                        ),
                      ),
                    ],
                  ),
                  Gap(8.h),
                  horizontalWeekCalendar(context),
                  Gap(8.h),
                  const ProhibitionWidget(),
                ],
              ),
            ),
          ),
          SizedBox(
            width: context.customOrientation(Get.width, Get.width * .45),
            child: const PrayerBuild(),
          ),
        ],
      ),
    );
  }

  Widget landscapeBuild(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const Gap(16),
                  horizontalWeekCalendar(context),
                  const Gap(8),
                  const PrayerBuild(),
                ],
              )),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(16),
              const PrayerNowWidget(),
              const Gap(16),
              context.hDivider(width: Get.width * .5),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: updateLocationBuild(context),
                  ),
                  Expanded(
                    child: HijriDateWidget(
                      svgColor: context.theme.colorScheme.surface,
                      horizontalPadding: 24.0,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              const ProhibitionWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget horizontalWeekCalendar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: HorizontalWeekCalendar(
        hijriInitialDate: eventCtrl.hijriNow,
        hijriMaxDate:
            HijriDate.fromDate(DateTime.now().add(const Duration(days: 7))),
        hijriMinDate: HijriDate.fromDate(
            DateTime.now().subtract(const Duration(days: 7))),
        minDate: DateTime.now().subtract(const Duration(days: 7)),
        maxDate: DateTime.now().add(const Duration(days: 7)),
        initialDate: DateTime.now(),
        onDateChange: (date) async {
          adhanCtrl.state.selectedDate = date;
          // حساب أوقات الصلاة للتاريخ المختار
          // Calculate prayer times for selected date
          await adhanCtrl.updateSelectedDate(date);
        },
        carouselHeight: 60,
        showTopNavbar: false,
        monthFormat: 'MMMM yyyy',
        showNavigationButtons: true,
        useHijriDates: true,
        weekStartFrom: WeekStartFrom.friday,
        borderRadius: BorderRadius.circular(12),
        itemBorderColor: Colors.transparent,
        activeBackgroundColor: context.theme.colorScheme.surface,
        activeTextColor: Colors.white,
        inactiveBackgroundColor: Colors.transparent,
        inactiveTextColor: context.theme.colorScheme.inversePrimary,
        disabledTextColor: Colors.grey,
        disabledBackgroundColor: Colors.grey.withValues(alpha: .3),
        activeNavigatorColor: context.theme.colorScheme.surface,
        inactiveNavigatorColor: Colors.grey,
        monthColor: context.theme.colorScheme.surface,
        onWeekChange: (List<DateTime> dates) {},
        scrollPhysics: const BouncingScrollPhysics(),
        translateNumbers: true,
        languageCode: Get.locale?.languageCode ?? 'ar',
        customDayNames: [
          'Sun'.tr,
          'Mon'.tr,
          'Tue'.tr,
          'Wed'.tr,
          'Thu'.tr,
          'Fri'.tr,
          'Sat'.tr,
        ],
        dayTextStyle: TextStyle(
          fontSize: 20,
          fontFamily: 'cairo',
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.inversePrimary,
          height: 1.1,
        ),
        monthTextStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'cairo',
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.inversePrimary,
          height: 1.5,
        ),
        dayNameTextStyle: TextStyle(
          fontSize: 14,
          fontFamily: 'cairo',
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.inversePrimary,
          height: 1.1,
        ),
      ),
    );
  }

  Padding updateLocationBuild(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        height: 60,
        width: Get.width,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Icon(Icons.place_rounded,
                color: context.theme.colorScheme.surface.withValues(alpha: .1),
                size: 70),
            ContainerButtonWidget(
              height: 70,
              svgHeight: 80,
              width: Get.width,
              // svgPath: SvgPath.svgAlert,
              withShape: false,
              useGradient: false,
              backgroundColor: Colors.transparent,
              borderColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: .2),
              title: '${Location.instance.city}\n${Location.instance.country}',
              titleColor: context.theme.colorScheme.inversePrimary,
              onPressed: () async {
                // تحديث الموقع وإعادة حساب أوقات الصلاة
                // Update location and recalculate prayer times
                final success =
                    await generalCtrl.updateLocationAndPrayerTimes();
                if (success) {
                  // إجبار تحديث واجهة المستخدم
                  // Force UI update
                  Get.forceAppUpdate();
                  log(
                    'Location and prayer times updated successfully',
                    name: 'PrayerScreen',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
