part of '../prayers.dart';

class ProhibitionWidget extends StatelessWidget {
  const ProhibitionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdhanController>(
      id: 'prohibitionTimes',
      builder: (adhanCtrl) => adhanCtrl.prohibitionTimesBool.value
          ? ContainerButtonWidget(
              onPressed: () => context.customBottomSheet(
                textTitle: 'prohibitionTimes'.tr,
                containerColor: context.theme.colorScheme.primaryContainer,
                child: prohibitionDetails(
                    context, adhanCtrl.state.prohibitionTimesIndex.value),
              ),
              title: 'prohibitionTimes'.tr,
              horizontalMargin: 24.0,
              backgroundColor: const Color(0xfff8a159).withValues(alpha: .2),
              borderColor: context.theme.colorScheme.surface,
              titleColor: context.theme.colorScheme.inversePrimary,
              useGradient: false,
              withShape: false,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget prohibitionDetails(BuildContext context, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            '${prohibitionTimesList[index]['title']}'.tr,
            style: TextStyle(
              fontFamily: 'cairo',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.inversePrimary
                  .withValues(alpha: .7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                    color:
                        context.theme.colorScheme.surface.withValues(alpha: .2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    )),
                child: Text(
                  prohibitionTimesList[index]['hadith'],
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.inversePrimary
                        .withValues(alpha: .7),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const Gap(8),
              context.hDivider(
                  width: Get.width * .5,
                  height: 1,
                  color:
                      context.theme.colorScheme.surface.withValues(alpha: .7)),
              Text(
                prohibitionTimesList[index]['source'],
                style: TextStyle(
                  fontFamily: 'cairo',
                  fontSize: 14,
                  color: context.theme.colorScheme.inversePrimary
                      .withValues(alpha: .7),
                ),
              ),
              const Gap(16),
            ],
          ),
        ),
      ],
    );
  }
}
