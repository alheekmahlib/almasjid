part of '../prayers.dart';

class PrayerDetails extends StatelessWidget {
  final String? prayerName;
  final String? prayerSummary;

  const PrayerDetails({super.key, this.prayerName, this.prayerSummary});

  @override
  Widget build(BuildContext context) {
    final index = prayerList.indexWhere((p) => p == prayerName!);
    return GetBuilder<AdhanController>(
        id: 'init_athan',
        builder: (adhanCtrl) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prayerSummary ??
                            '${adhanCtrl.prayerNameList[index]['title']}'.tr,
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        adhanCtrl.prayerNameList[index]['time'],
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                prayerProgressBar(context, adhanCtrl, index),
                const Gap(8),
                prayerDetails(context, index),
                const Gap(16),
                context.hDivider(
                    width: Get.width * .5,
                    height: 1,
                    color: context.theme.colorScheme.surface
                        .withValues(alpha: .7)),
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SettingPrayerTimes(listNum: index, isOnePrayer: true),
                ),
              ],
            ),
          );
        });
  }

  Widget prayerProgressBar(
      BuildContext context, AdhanController adhanCtrl, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Obx(() => RoundedProgressBar(
                height: 35,
                style: RoundedProgressBarStyle(
                  borderWidth: 5,
                  widthShadow: 5,
                  backgroundProgress: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
                  colorProgress: Theme.of(context).colorScheme.surface,
                  colorProgressDark: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withValues(alpha: 0.1),
                  colorBorder: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.1),
                  colorBackgroundIcon: Colors.transparent,
                ),
                // margin: EdgeInsets.symmetric(vertical: 16),
                borderRadius: BorderRadius.circular(4),
                percent: adhanCtrl.getTimeLeftForPrayerByIndex(index).value,
              )),
          SlideCountdownWidget(
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary,
              duration: adhanCtrl.getDurationLeftForPrayerByIndex(index).value),
        ],
      ),
    );
  }

  Widget prayerDetails(BuildContext context, int index) {
    return Column(
      children: [
        prayerHadithsList[index]['fromQuran'] == ''
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'fromQuran:'.tr,
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface
                              .withValues(alpha: .2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          )),
                      child: Text(
                        prayerHadithsList[index]['fromQuran'],
                        style: TextStyle(
                          fontFamily: 'uthmanic2',
                          fontSize: 22,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                      ),
                    ),
                    context.hDivider(
                        width: Get.width * .5,
                        height: 1,
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: .7)),
                    Text(
                      prayerHadithsList[index]['ayahNumber'],
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 14,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .7),
                      ),
                    ),
                  ],
                )),
        prayerHadithsList[index]['fromSunnah'] == ''
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'fromSunnah:'.tr,
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface
                              .withValues(alpha: .2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          )),
                      child: Text(
                        prayerHadithsList[index]['fromSunnah'],
                        style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .7),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    context.hDivider(
                        width: Get.width * .5,
                        height: 1,
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: .7)),
                    Text(
                      prayerHadithsList[index]['rule'],
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 14,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
