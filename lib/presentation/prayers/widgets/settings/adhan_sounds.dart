part of '../../prayers.dart';

class AdhanSounds extends StatelessWidget {
  AdhanSounds({super.key});

  final notificationCtrl = PrayersNotificationsCtrl.instance;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ContainerButtonWidget(
        onPressed: () => customBottomSheet(
            textTitle: 'adhanSounds', child: bottomSheetWidget(context)),
        title: 'adhanSounds',
        titleColor: Theme.of(context).colorScheme.inversePrimary,
        width: Get.width,
        withShape: false,
        useGradient: false,
        borderRadius: 8.0,
        borderColor: Colors.transparent,
        backgroundColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: .3),
      ),
    );
  }

  Widget bottomSheetWidget(BuildContext context) {
    return SizedBox(
      height: Get.height * .3,
      child: FutureBuilder<List<AdhanData>>(
          future: notificationCtrl.state.adhanData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView(
                  children: List.generate(
                    snapshot.data!.length,
                    (index) => adhanListBuild(context, index),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
          }),
    );
  }

  Widget adhanListBuild(BuildContext context, int index) {
    final notificationCtrl = PrayersNotificationsCtrl.instance;
    return FutureBuilder<List<AdhanData>>(
        future: notificationCtrl.state.adhanData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<AdhanData> adhans = snapshot.data!;
            notificationCtrl.isAdhanDownloadedByIndex(0).value
                ? null
                : notificationCtrl.adhanDownload(adhans[0]);
            return GetX<PrayersNotificationsCtrl>(builder: (notificationCtrl) {
              bool isSelected =
                  notificationCtrl.isAdhanSelectByIndex(index).value;
              return Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                        color: isSelected
                            ? context.theme.colorScheme.surface
                            : context.theme.colorScheme.surface
                                .withValues(alpha: .5),
                        width: isSelected ? 2 : 1)),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.theme.colorScheme.surface
                                  .withValues(alpha: .5)
                              : context.theme.colorScheme.surface
                                  .withValues(alpha: .2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: ListTile(
                          onTap: () async {
                            notificationCtrl.switchAdhanOnTap(index);
                            notificationCtrl
                                    .isAdhanDownloadedByIndex(index)
                                    .value
                                ? null
                                : await notificationCtrl
                                    .adhanDownload(adhans[index]);
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                adhans[index].adhanName.tr,
                                style: TextStyle(
                                    color: context
                                        .theme.colorScheme.secondaryContainer
                                        .withValues(alpha: .7),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'cairo'),
                                textAlign: TextAlign.center,
                              ),
                              PlayButton(
                                adhanData: adhans,
                                index: index,
                              ),
                            ],
                          ),
                          // leading: PlayButton(),
                        ),
                      ),
                    ),
                    isSelected
                        ? Expanded(
                            flex: 2,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Obx(
                                  () => SquarePercentIndicator(
                                    width: 45,
                                    height: 45,
                                    borderRadius: 4,
                                    shadowWidth: 1.5,
                                    progressWidth: 2,
                                    shadowColor: Colors.transparent,
                                    progressColor: index ==
                                            notificationCtrl
                                                .state.downloadIndex.value
                                        ? notificationCtrl
                                                .state.isDownloading.value
                                            ? context.theme.colorScheme.surface
                                            : Colors.transparent
                                        : Colors.transparent,
                                    progress:
                                        notificationCtrl.state.progress.value,
                                  ),
                                ),
                                isSelected
                                    ? Icon(Icons.done,
                                        size: 28,
                                        color: context.theme.colorScheme
                                            .secondaryContainer)
                                    : const SizedBox.shrink(),
                              ],
                            ))
                        : const SizedBox.shrink(),
                  ],
                ),
              );
            });
          } else {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
        });
  }
}
