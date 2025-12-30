part of '../../prayers.dart';

class _ShareCard extends StatelessWidget {
  final share = ShareController.instance;
  final adhan = AdhanController.instance;

  @override
  Widget build(BuildContext context) {
    final gradient = adhan.getTimeNowColor();
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Inner overlay to ensure text contrast
              color: Colors.black.withValues(alpha: .15),
              border: Border.all(
                color: Colors.white.withValues(alpha: .1),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                HijriDateWidget(
                  alignment: Alignment.center,
                  fontColor: context.theme.canvasColor,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            // Next prayer
                            Text(
                              'nextPrayer'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'cairo',
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: .9),
                                height: 1.0,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              share.nextPrayerName.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'cairo',
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Text(
                          share.formattedNextPrayerTime,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'cairo',
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),

                    const Gap(12),
                    // Progress bar (from fajr to isha)
                    Obx(() => RoundedProgressBar(
                          height: 25,
                          style: RoundedProgressBarStyle(
                            borderWidth: 5,
                            widthShadow: 5,
                            backgroundProgress: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            colorProgress: Theme.of(context).canvasColor,
                            colorProgressDark: Theme.of(context)
                                .colorScheme
                                .inversePrimary
                                .withValues(alpha: 0.1),
                            colorBorder: Theme.of(context)
                                .canvasColor
                                .withValues(alpha: 0.1),
                            colorBackgroundIcon: Colors.transparent,
                          ),
                          // margin: EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(10),
                          percent: adhan
                              .getIntervalPercentageOfDayBetweenPrayerAndNextByIndex(
                                  adhan.getCurrentPrayerByDateTime())
                              .value,
                        )),

                    // Time left chip
                    Center(
                      child: Text(
                        '${'timeLeft:'.tr} ${share.timeLeftLabel.convertNumbers()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'cairo',
                          color:
                              context.theme.canvasColor.withValues(alpha: .8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Gap(8),
                    // Hijri + Place
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            share.hijriDateText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'cairo',
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.place_rounded,
                            color: Colors.white, size: 18),
                        const Gap(8),
                        Flexible(
                          child: Text(
                            AdhanController.instance.state.location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'cairo',
                              color: Colors.white.withValues(alpha: .9),
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    customSvgWithCustomColor(
                      SvgPath.svgLogoAqemLogo,
                      color: context.theme.canvasColor,
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // App brand / title
          Text(
            'appName'.tr,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'cairo',
              color: context.theme.canvasColor.withValues(alpha: .7),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
