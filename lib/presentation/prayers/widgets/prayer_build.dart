part of '../prayers.dart';

class PrayerBuild extends StatelessWidget {
  const PrayerBuild({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: GetBuilder<AdhanController>(
            id: 'init_athan',
            builder: (adhanCtrl) => ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: adhanCtrl.prayerNameList.length,
                  itemBuilder: (context, index) {
                    final prayerList = adhanCtrl.prayerNameList.toList();
                    final String prayerTitle = prayerList[index]['title'];
                    final String prayerTime = prayerList[index]['time'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _prayerContainerBuild(
                          context, index, prayerTitle, prayerTime),
                    );
                  },
                )),
      ),
    );
  }

  Widget _prayerNameBuild(BuildContext context, int index, String prayerTitle,
      AdhanController adhanCtrl) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        prayerTitle.tr,
        style: TextStyle(
          fontFamily: 'cairo',
          fontSize: adhanCtrl.getCurrentPrayerByDateTime() == index ? 20 : 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
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
          fontSize: adhanCtrl.getCurrentPrayerByDateTime() == index ? 20 : 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }

  Widget _prayerIconBuild(
      BuildContext context, int index, AdhanController adhanCtrl) {
    return Icon(
      adhanCtrl.prayerNameList[index]['icon'],
      size: adhanCtrl.getCurrentPrayerByDateTime() == index ? 28 : 24,
      color: index == 1 || index == 2 || index == 3 || index == 4
          ? const Color.fromARGB(255, 242, 181, 15)
          : Theme.of(context).canvasColor,
    );
  }

  Widget _prayerContainerBuild(
      BuildContext context, int index, String prayerTitle, String prayerTime) {
    return Center(
      child: GetBuilder<AdhanController>(
          id: 'change_notification',
          builder: (adhanCtrl) => ContainerButtonWidget(
                onPressed: () => customBottomSheet(
                  child: PrayerDetails(
                    prayerName: prayerTitle,
                  ),
                ),
                width: Get.width,
                horizontalMargin: 8.0,
                backgroundColor: adhanCtrl.getCurrentPrayerByDateTime() == index
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: .5),
                height:
                    adhanCtrl.getCurrentPrayerByDateTime() == index ? 70 : 49,
                icon: adhanCtrl.getPrayerIcon(prayerTitle),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _prayerIconBuild(context, index, adhanCtrl),
                    ),
                    Expanded(
                        flex: 4,
                        child: _prayerNameBuild(
                            context, index, prayerTitle, adhanCtrl)),
                    Expanded(
                      flex: 4,
                      child: _prayerTimeBuild(
                          context, index, prayerTime, adhanCtrl),
                    ),
                  ],
                ),
              )),
    );
  }
}
