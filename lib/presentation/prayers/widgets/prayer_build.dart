part of '../prayers.dart';

class PrayerBuild extends StatelessWidget {
  final bool isCurrentPrayerOnly;
  final List<Map<String, dynamic>>? prayersOverride;
  final int? currentPrayerIndexOverride;
  final bool? withOnTap;
  final double? bottomPadding;

  const PrayerBuild({
    super.key,
    this.isCurrentPrayerOnly = false,
    this.prayersOverride,
    this.currentPrayerIndexOverride,
    this.withOnTap = true,
    this.bottomPadding,
  });

  bool get _useOverride => prayersOverride != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: 8.0,
          left: 8.0,
          top: 16.0,
          bottom: isCurrentPrayerOnly ? 16.0 : (bottomPadding ?? 120.0)),
      child: _useOverride
          ? _buildPrayerList(
              context,
              prayersOverride!,
              currentPrayerIndexOverride ?? -1,
              adhanCtrl: null,
            )
          : GetBuilder<AdhanController>(
              id: 'init_athan',
              builder: (adhanCtrl) => _buildPrayerList(
                context,
                adhanCtrl.prayerNameList.toList(),
                adhanCtrl.currentPrayerIndex,
                adhanCtrl: adhanCtrl,
              ),
            ),
    );
  }

  Widget _buildPrayerList(
    BuildContext context,
    List<Map<String, dynamic>> prayerList,
    int currentPrayerIndex, {
    required AdhanController? adhanCtrl,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: () {
        final List<int> visibleIndices;
        if (isCurrentPrayerOnly) {
          visibleIndices =
              currentPrayerIndex >= 0 && currentPrayerIndex < prayerList.length
                  ? <int>[currentPrayerIndex]
                  : <int>[];
        } else {
          visibleIndices = List<int>.generate(prayerList.length, (i) => i);
        }

        return List.generate(visibleIndices.length, (i) {
          final index = visibleIndices[i];
          final String prayerTitle =
              prayerList[index]['title']?.toString() ?? '';
          final String prayerTime = prayerList[index]['time']?.toString() ?? '';
          final IconData icon =
              prayerList[index]['icon'] as IconData? ?? Icons.access_time;

          return _buildPrayerRowWithTimeline(
            context,
            index,
            prayerTitle,
            prayerTime,
            currentPrayerIndex,
            icon,
            adhanCtrl,
          );
        });
      }(),
    );
  }

  // بناء صف الصلاة مع التايم لاين المخصص
  Widget _buildPrayerRowWithTimeline(
      BuildContext context,
      int index,
      String prayerTitle,
      String prayerTime,
      int currentPrayerIndex,
      IconData icon,
      AdhanController? adhanCtrl) {
    final bool isCurrentPrayer = currentPrayerIndex == index;
    final bool isPastPrayer =
        currentPrayerIndex >= 0 && index < currentPrayerIndex;

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
                          color: index <= currentPrayerIndex
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
                            isCurrentPrayer, isPastPrayer, icon),
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
                context,
                index,
                prayerTitle,
                prayerTime,
                currentPrayerIndex,
                icon,
                adhanCtrl,
                withOnTap!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// بناء مؤشر التايم لاين باستخدام timelines_plus
Widget _buildTimelineIndicator(BuildContext context, int index,
    bool isCurrentPrayer, bool isPastPrayer, IconData icon) {
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
        child: _prayerIconBuild(context, index, icon, isCurrentPrayer,
            isCustomColor: false),
      ),
    ),
  );
}

// بناء محتوى الصلاة
Widget _buildPrayerContent(
    BuildContext context,
    int index,
    String prayerTitle,
    String prayerTime,
    int currentPrayerIndex,
    IconData icon,
    AdhanController? adhanCtrl,
    bool withOnTap) {
  if (adhanCtrl == null) {
    return _buildPrayerContentCore(
      context,
      index,
      prayerTitle,
      prayerTime,
      currentPrayerIndex,
      withOnTap,
    );
  }

  return GetBuilder<AdhanController>(
    id: 'change_notification',
    builder: (controller) => _buildPrayerContentCore(
      context,
      index,
      prayerTitle,
      prayerTime,
      controller.currentPrayerIndex,
      withOnTap,
    ),
  );
}

Widget _buildPrayerContentCore(
  BuildContext context,
  int index,
  String prayerTitle,
  String prayerTime,
  int currentPrayerIndex,
  bool withOnTap,
) {
  final bool isCurrentPrayer = currentPrayerIndex == index;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: isCurrentPrayer
          ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
          : Colors.transparent,
    ),
    child: ContainerButtonWidget(
      onPressed: withOnTap
          ? () => context.customBottomSheet(
                textTitle: 'prayerDetails'.tr,
                containerColor: context.theme.colorScheme.primaryContainer,
                child: PrayerDetails(
                  prayerName: prayerTitle,
                ),
              )
          : null,
      width: Get.width,
      horizontalMargin: 0,
      useGradient: false,
      withShape: false,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      borderColor: isCurrentPrayer
          ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
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
                  context,
                  index,
                  prayerTitle,
                  currentPrayerIndex,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: _prayerTimeBuild(
                context,
                index,
                prayerTime,
                currentPrayerIndex,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

Widget _prayerNameBuild(
  BuildContext context,
  int index,
  String prayerTitle,
  int currentPrayerIndex,
) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      prayerTitle.tr,
      style: TextStyle(
        fontFamily: 'cairo',
        fontSize: currentPrayerIndex == index ? 18.sp : 16,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      textAlign: TextAlign.start,
    ),
  );
}

Widget _prayerTimeBuild(
  BuildContext context,
  int index,
  String prayerTime,
  int currentPrayerIndex,
) {
  return Center(
    child: ReactiveNumberText(
      text: prayerTime.toString(),
      style: TextStyle(
        fontFamily: 'cairo',
        fontSize: currentPrayerIndex == index ? 22 : 19,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
    ),
  );
}

Widget _prayerIconBuild(
    BuildContext context, int index, IconData icon, bool isCurrentPrayer,
    {bool? isCustomColor = true,
    double? newSize,
    double? oldSize,
    Color? color}) {
  return Icon(
    icon,
    size: isCurrentPrayer ? (newSize ?? 28) : (oldSize ?? 16),
    color: color ??
        (isCustomColor!
            ? index == 1 || index == 2 || index == 3 || index == 4
                ? const Color.fromARGB(255, 242, 181, 15)
                : Theme.of(context).canvasColor
            : Theme.of(context).canvasColor),
  );
}
