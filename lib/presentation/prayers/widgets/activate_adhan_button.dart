part of '../prayers.dart';

class ActivateAdhanButton extends StatelessWidget {
  final int index;
  final String prayerTitle;
  const ActivateAdhanButton({
    super.key,
    required this.index,
    required this.prayerTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdhanController>(
      id: 'change_notification',
      builder: (adhanCtrl) => Container(
        // height: 445,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Text(
              'notificationOptions'.tr,
              style: TextStyle(
                  color: context.theme.colorScheme.inversePrimary
                      .withValues(alpha: .7),
                  fontFamily: 'cairo',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const Gap(4),
            Column(
              children: List.generate(
                notificationOptions.length,
                (i) => SizedBox(
                  height: 50,
                  child: GestureDetector(
                    onTap: () async =>
                        await adhanCtrl.notificationOptionsOnTap(i, index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: adhanCtrl.getPrayerNotificationIndexForPrayer(
                                    prayerTitle) ==
                                i
                            ? context.theme.colorScheme.surface
                                .withValues(alpha: .3)
                            : context.theme.colorScheme.surface
                                .withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: adhanCtrl.getPrayerNotificationIndexForPrayer(
                                      prayerTitle) ==
                                  i
                              ? context.theme.colorScheme.surface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            notificationOptions[i]['icon'],
                            size: 28,
                            color: context.theme.colorScheme.primary,
                          ),
                          const Gap(16),
                          Text(
                            '${notificationOptions[i]['title']}'.tr,
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 24,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
