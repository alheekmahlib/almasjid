part of '../prayers.dart';

class PrayerBuild extends StatelessWidget {
  final bool isCurrentPrayerOnly;
  const PrayerBuild({super.key, this.isCurrentPrayerOnly = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: 8.0,
          left: 8.0,
          top: 16.0,
          bottom: isCurrentPrayerOnly ? 16.0 : 120.0),
      child: GetBuilder<AdhanController>(
        id: 'init_athan',
        builder: (adhanCtrl) => Column(
          mainAxisSize: MainAxisSize.min,
          children: () {
            final prayerList = adhanCtrl.prayerNameList.toList();

            final List<int> visibleIndices;
            if (isCurrentPrayerOnly) {
              final currentIndex = adhanCtrl.currentPrayerIndex;
              visibleIndices =
                  currentIndex >= 0 && currentIndex < prayerList.length
                      ? <int>[currentIndex]
                      : <int>[];
            } else {
              visibleIndices = List<int>.generate(prayerList.length, (i) => i);
            }

            return List.generate(visibleIndices.length, (i) {
              final index = visibleIndices[i];
              final String prayerTitle = prayerList[index]['title'];
              final String prayerTime = prayerList[index]['time'];

              return _buildPrayerRowWithTimeline(
                context,
                index,
                prayerTitle,
                prayerTime,
                adhanCtrl,
              );
            });
          }(),
        ),
      ),
    );
  }

  // بناء صف الصلاة مع التايم لاين المخصص
  Widget _buildPrayerRowWithTimeline(BuildContext context, int index,
      String prayerTitle, String prayerTime, AdhanController adhanCtrl) {
    final bool isCurrentPrayer = adhanCtrl.currentPrayerIndex == index;
    final bool isPastPrayer = index < adhanCtrl.currentPrayerIndex;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // عمود التايم لاين
          !isCurrentPrayerOnly
              ? SizedBox(
                  width: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // الخط العلوي
                      // if (index > 0) ...[
                      Container(
                        width: 5,
                        decoration: BoxDecoration(
                          color: index <= adhanCtrl.currentPrayerIndex
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // ],

                      // المؤشر
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: _buildTimelineIndicator(context, index,
                            isCurrentPrayer, isPastPrayer, adhanCtrl),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          Gap(16.h),

          // محتوى الصلاة
          Expanded(
            child: Container(
              margin: isCurrentPrayer
                  ? EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 16.0, index == 7 ? 0.0 : 6.0)
                  : EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 32.0, index == 7 ? 0.0 : 6.0),
              child: _buildPrayerContent(
                  context, index, prayerTitle, prayerTime, adhanCtrl),
            ),
          ),
        ],
      ),
    );
  }
}

// بناء مؤشر التايم لاين باستخدام timelines_plus
Widget _buildTimelineIndicator(BuildContext context, int index,
    bool isCurrentPrayer, bool isPastPrayer, AdhanController adhanCtrl) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    width: (isCurrentPrayer ? 42 : 28),
    height: (isCurrentPrayer ? 42 : 28),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _getTimelineIndicatorColor(
          context, index, isCurrentPrayer, isPastPrayer),
    ),
    child: Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _prayerIconBuild(context, index, adhanCtrl, isCurrentPrayer,
            isCustomColor: false),
      ),
    ),
  );
}

// بناء محتوى الصلاة
Widget _buildPrayerContent(BuildContext context, int index, String prayerTitle,
    String prayerTime, AdhanController adhanCtrl) {
  final bool isCurrentPrayer = adhanCtrl.currentPrayerIndex == index;

  return GetBuilder<AdhanController>(
      id: 'change_notification',
      builder: (adhanCtrl) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isCurrentPrayer
                  ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: ContainerButtonWidget(
              onPressed: () => context.customBottomSheet(
                textTitle: 'prayerDetails'.tr,
                containerColor: context.theme.colorScheme.primaryContainer,
                child: PrayerDetails(
                  prayerName: prayerTitle,
                ),
              ),
              width: Get.width,
              horizontalMargin: 0,
              useGradient: false,
              withShape: false,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              borderColor: isCurrentPrayer
                  ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                  : Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.2),
              height: (isCurrentPrayer ? 60 : 45),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _prayerNameBuild(
                              context, index, prayerTitle, adhanCtrl),
                        )),
                    Expanded(
                      flex: 4,
                      child: _prayerTimeBuild(
                          context, index, prayerTime, adhanCtrl),
                    ),
                  ],
                ),
              ),
            ),
          ));
}

// دالة مساعدة لتحديد لون مؤشر التايم لاين
Color _getTimelineIndicatorColor(
    BuildContext context, int index, bool isCurrentPrayer, bool isPastPrayer) {
  if (isCurrentPrayer) {
    return Theme.of(context).colorScheme.surface;
  } else if (isPastPrayer) {
    return Theme.of(context).colorScheme.surface.withValues(alpha: 0.7);
  } else {
    return Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);
  }
}

Widget _prayerNameBuild(BuildContext context, int index, String prayerTitle,
    AdhanController adhanCtrl) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      prayerTitle.tr,
      style: TextStyle(
        fontFamily: 'cairo',
        fontSize: adhanCtrl.currentPrayerIndex == index ? 18.sp : 14,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      textAlign: TextAlign.start,
    ),
  );
}

Widget _prayerTimeBuild(BuildContext context, int index, String prayerTime,
    AdhanController adhanCtrl) {
  return Center(
    child: ReactiveNumberText(
      text: prayerTime.toString(),
      style: TextStyle(
        fontFamily: 'cairo',
        fontSize: adhanCtrl.currentPrayerIndex == index ? 22 : 18,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
    ),
  );
}

Widget _prayerIconBuild(BuildContext context, int index,
    AdhanController adhanCtrl, bool isCurrentPrayer,
    {bool? isCustomColor = true,
    double? newSize,
    double? oldSize,
    Color? color}) {
  return Icon(
    adhanCtrl.prayerNameList[index]['icon'],
    size: isCurrentPrayer ? (newSize ?? 28) : (oldSize ?? 16),
    color: color ??
        (isCustomColor!
            ? index == 1 || index == 2 || index == 3 || index == 4
                ? const Color.fromARGB(255, 242, 181, 15)
                : Theme.of(context).canvasColor
            : Theme.of(context).canvasColor),
  );
}
