part of '../prayers.dart';

class ProhibitionWidget extends StatelessWidget {
  const ProhibitionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AdhanController>(
      builder: (adhanCtrl) => adhanCtrl.prohibitionTimesBool.value
          ? Padding(
              padding:
                  const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 8.0),
              child: SizedBox(
                height: 55,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'prohibitionTimes'.tr,
                          style: TextStyle(
                            fontFamily: 'cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                context.theme.canvasColor.withValues(alpha: .7),
                          ),
                        ),
                      ),
                      const Gap(8),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => prohibitionDetails(context,
                                adhanCtrl.state.prohibitionTimesIndex.value),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget prohibitionDetails(BuildContext context, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Text(
            '${prohibitionTimesList[index]['title']}'.tr,
            style: TextStyle(
              fontFamily: 'cairo',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.theme.canvasColor.withValues(alpha: .7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
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
                    color: context.theme.canvasColor.withValues(alpha: .7),
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
                    fontFamily: 'naskh',
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                    color: context.theme.canvasColor.withValues(alpha: .7),
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
                  fontFamily: 'naskh',
                  fontSize: 14,
                  color: context.theme.canvasColor.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
