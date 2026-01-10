part of '../prayers.dart';

class DigitalScreen extends StatelessWidget {
  DigitalScreen({super.key});

  final generalCtrl = GeneralController.instance;
  final adhanCtrl = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) {
          return;
        }
        PrayersNotificationsCtrl.instance.state.adhanPlayer.stop();
        Get.back();
      },
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surface,
        body: SafeArea(
          child: Container(
            color: context.theme.colorScheme.primaryContainer,
            child: GetBuilder<AdhanController>(
              id: 'init_athan',
              builder: (adhanCtrl) {
                int currentPrayer = adhanCtrl.currentPrayerIndex;
                return Stack(
                  children: [
                    Column(
                      children: [
                        const AppBarWidget(),
                        const Gap(8),
                        BubbleLens(
                          width: Get.width,
                          height: 370,
                          size: 100,
                          paddingX: 8,
                          radius: const Radius.circular(0),
                          widgets: List.generate(
                              adhanCtrl.prayerNameList.length, (i) {
                            final String prayerTitle =
                                adhanCtrl.prayerNameList[i]['title'];
                            final String prayerTime =
                                adhanCtrl.prayerNameList[i]['time'];
                            final bool isCurrentPrayer =
                                adhanCtrl.currentPrayerIndex == i;
                            final bool isPastPrayer =
                                i < adhanCtrl.currentPrayerIndex;
                            return _buildTimelineIndicator(
                                context,
                                i,
                                isCurrentPrayer,
                                isPastPrayer,
                                adhanCtrl,
                                prayerTitle,
                                prayerTime);
                          }),
                        ),
                        updateLocationBuild(context),
                        _twoDigitBuild(
                          context,
                          currentPrayer,
                          shouldShowHours: true,
                          shouldShowMinutes: false,
                          shouldShowSeconds: false,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .3),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -50),
                          child: _twoDigitBuild(
                            context,
                            currentPrayer,
                            shouldShowHours: false,
                            shouldShowMinutes: true,
                            shouldShowSeconds: false,
                            color: context.theme.colorScheme.inversePrimary
                                .withValues(alpha: .5),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -100),
                          child: _twoDigitBuild(
                            context,
                            currentPrayer,
                            shouldShowHours: false,
                            shouldShowMinutes: false,
                            shouldShowSeconds: true,
                            color: context.theme.colorScheme.inversePrimary,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -150),
                          child: Container(
                            height: 90,
                            width: Get.width,
                            color: context.theme.colorScheme.primaryContainer,
                            child: Container(
                              height: 90,
                              width: Get.width,
                              color: context.theme.colorScheme.surface
                                  .withValues(alpha: .3),
                              child: SizedBox(
                                height: 35,
                                child: CustomButton(
                                  onPressed: () => context.customBottomSheet(
                                    containerColor: context
                                        .theme.colorScheme.primaryContainer,
                                    textTitle: 'sharePrayerTime',
                                    child: ShareOptionsWidget(),
                                  ),
                                  width: 40,
                                  iconSize: 28,
                                  isCustomSvgColor: true,
                                  svgPath: SvgPath.svgShareShare,
                                  svgColor: context.theme.colorScheme.surface,
                                  borderColor: context.theme.colorScheme.surface
                                      .withValues(alpha: .3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SlidingPanelBuilder(
                      minExtent: .37,
                      snapConfig: SlidingPanelSnapConfig(
                        animation: const CurvedSnapAnimation(
                          curve: Curves.easeInOut,
                          duration: (300, 500),
                        ),
                      ),
                      builder: (context, handle) {
                        return SlidingPanelBody(
                          color: context.theme.colorScheme.primaryContainer,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PrayerBuild(
                                isCurrentPrayerOnly: true,
                              ),
                              PrayerBuild(),
                              Gap(120),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

// بناء مؤشر التايم لاين باستخدام timelines_plus
  Widget _buildTimelineIndicator(
      BuildContext context,
      int index,
      bool isCurrentPrayer,
      bool isPastPrayer,
      AdhanController adhanCtrl,
      String prayerTitle,
      String prayerTime) {
    return GestureDetector(
      onTap: () => context.customBottomSheet(
        textTitle: 'prayerDetails'.tr,
        containerColor: context.theme.colorScheme.primaryContainer,
        child: PrayerDetails(
          prayerName: prayerTitle,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: (isCurrentPrayer ? 120 : 38),
        height: (isCurrentPrayer ? 120 : 38),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            // gradient: adhanCtrl.getPrayerGradients[index],
            color: isCurrentPrayer
                ? context.theme.colorScheme.inverseSurface
                : context.theme.colorScheme.surface.withValues(alpha: .1),
            border: Border.all(
              width: 2,
              color: isCurrentPrayer
                  ? Colors.transparent
                  : context.theme.colorScheme.surface.withValues(alpha: .3),
            )),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _prayerIconBuild(context, index, adhanCtrl, isCurrentPrayer,
                    isCustomColor: false,
                    newSize: 90,
                    oldSize: 90,
                    color: context.theme.canvasColor.withValues(alpha: .1)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          prayerTitle.tr,
                          style: TextStyle(
                            height: 1.3,
                            fontFamily: 'cairo',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      prayerTime,
                      style: TextStyle(
                        height: 1.3,
                        fontFamily: 'cairo',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _twoDigitBuild(BuildContext context, int currentPrayer,
      {bool shouldShowHours = false,
      bool shouldShowMinutes = false,
      bool shouldShowSeconds = false,
      Color? color}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 100.h,
          width: Get.width * .7,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primaryContainer,
            border: Border.symmetric(
              horizontal: BorderSide(
                color: context.theme.colorScheme.surface.withValues(alpha: .4),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 110.h,
          child: SlideCountdownWidget(
            key: ValueKey<int>(currentPrayer),
            fontSize: 120.sp,
            fontHeight: 1.1,
            shouldShowHours: shouldShowHours,
            shouldShowMinutes: shouldShowMinutes,
            shouldShowSeconds: shouldShowSeconds,
            color: color ?? context.theme.colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }

  Padding updateLocationBuild(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ContainerButtonWidget(
        onPressed: () async {
          final success = await generalCtrl.updateLocationAndPrayerTimes();
          if (success) {
            Get.forceAppUpdate();
            log(
              'Location and prayer times updated successfully',
              name: 'PrayerScreen',
            );
          }
        },
        height: 60,
        svgHeight: 80,
        width: Get.width,
        withShape: false,
        useGradient: false,
        backgroundColor: Colors.transparent,
        borderColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: .2),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Icon(Icons.place_rounded,
                color: context.theme.colorScheme.surface.withValues(alpha: .1),
                size: 70),
            Text(
              adhanCtrl.state.location,
              style: TextStyle(
                fontFamily: 'cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.inversePrimary,
                height: 1.3,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
