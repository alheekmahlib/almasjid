part of '../../prayers.dart';

/// صف ضبط إزاحة الإقامة تحت صف الصلاة: وقت الإقامة المحسوب + أزرار +/-.
class _IqamaAdjustRow extends StatelessWidget {
  final int prayerIndex;

  const _IqamaAdjustRow({required this.prayerIndex});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdhanController>(
      id: 'init_athan',
      init: Get.find<AdhanController>(),
      builder: (adhanCtrl) => Padding(
        padding: const EdgeInsetsDirectional.only(top: 4, bottom: 4),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'iqama'.tr,
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .6),
                      ),
                    ),
                    const Gap(8),
                    ReactiveNumberText(
                      text:
                          '${adhanCtrl.prayerNameList[prayerIndex]['iqamaTime'] ?? ''}',
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                child: Row(
                  children: [
                    ReactiveNumberText(
                      text:
                          '${adhanCtrl.state.iqamaOffsets.getByIndex(prayerIndex)}'
                              .convertNumbersToCurrentLang(),
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .7),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'minutes'.tr,
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 10,
                        color: context.theme.colorScheme.inversePrimary
                            .withValues(alpha: .6),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      height: 25,
                      width: 75,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 25,
                            child: ElevatedButton(
                              onPressed: () async {
                                await adhanCtrl.adjustIqamaOffset(prayerIndex);
                              },
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.zero,
                                ),
                                elevation: WidgetStateProperty.all(0),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: context.theme.canvasColor,
                              ),
                            ),
                          ),
                          context.vDivider(
                            height: 20,
                            color: context.theme.canvasColor,
                          ),
                          SizedBox(
                            width: 25,
                            child: ElevatedButton(
                              onPressed: () async {
                                await adhanCtrl.adjustIqamaOffset(
                                  prayerIndex,
                                  isAdding: false,
                                );
                              },
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.zero,
                                ),
                                elevation: WidgetStateProperty.all(0),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: context.theme.canvasColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
