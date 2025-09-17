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
            ? activeLocationButton(context)
            : Scaffold(
                backgroundColor: context.theme.colorScheme.surface,
                body: SafeArea(
                  child: Container(
                    color: context.theme.colorScheme.primaryContainer,
                    child: Column(
                      children: [
                        const AppBarWidget(),
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: context.customOrientation(
                                      Get.width, Get.width * .45),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Gap(16),
                                        PrayerNowWidget(),
                                        const Gap(8),
                                        context.hDivider(width: Get.width * .5),
                                        const Gap(8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  updateLocationBuild(context),
                                            ),
                                            Expanded(
                                              child: HijriDateWidget(
                                                color: context
                                                    .theme.colorScheme.surface,
                                                horizontalPadding: 24.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Gap(8),
                                        horizontalWeekCalendar(context),
                                        const Gap(8),
                                        const ProhibitionWidget(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: context.customOrientation(
                                      Get.width, Get.width * .45),
                                  child: const PrayerBuild(),
                                ),
                              ],
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

  Widget horizontalWeekCalendar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: HorizontalWeekCalendar(
        hijriInitialDate: eventCtrl.hijriNow,
        hijriMaxDate:
            HijriCalendar.fromDate(DateTime.now().add(const Duration(days: 7))),
        hijriMinDate: HijriCalendar.fromDate(
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
          'Mon'.tr,
          'Tue'.tr,
          'Wed'.tr,
          'Thu'.tr,
          'Fri'.tr,
          'Sat'.tr,
          'Sun'.tr
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

  Container activeLocationButton(BuildContext context) {
    return Container(
      height: 80,
      width: Get.width,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.theme.canvasColor.withValues(alpha: .1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: Text(
              'activeLocationPlease'.tr,
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'naskh',
                fontWeight: FontWeight.bold,
                color: context.theme.canvasColor.withValues(alpha: .7),
              ),
            ),
          ),
          const Gap(32),
          Expanded(
            flex: 2,
            child: Obx(() => Switch(
                  value: generalCtrl.state.activeLocation.value,
                  activeColor: Colors.red,
                  inactiveTrackColor:
                      context.theme.colorScheme.surface.withValues(alpha: .5),
                  activeTrackColor:
                      context.theme.colorScheme.surface.withValues(alpha: .7),
                  thumbColor:
                      WidgetStatePropertyAll(context.theme.colorScheme.surface),
                  trackOutlineColor: WidgetStatePropertyAll(
                      adhanCtrl.state.autoCalculationMethod.value
                          ? context.theme.colorScheme.surface
                          : context.theme.canvasColor.withValues(alpha: .5)),
                  onChanged: (_) async =>
                      await generalCtrl.toggleLocationService(),
                )),
          ),
        ],
      ),
    );
  }

  Padding updateLocationBuild(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        height: 65,
        width: Get.width,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Icon(Icons.place_rounded,
                color: context.theme.colorScheme.surface.withValues(alpha: .1),
                size: 70),
            ContainerButtonWidget(
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
