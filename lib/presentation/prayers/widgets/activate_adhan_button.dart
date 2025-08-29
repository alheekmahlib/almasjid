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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        adhanCtrl.prayerNameList[index]['icon'],
                        size: 70,
                        color:
                            index == 1 || index == 2 || index == 3 || index == 4
                                ? const Color.fromARGB(255, 242, 181, 15)
                                    .withValues(alpha: .4)
                                : Theme.of(context)
                                    .canvasColor
                                    .withValues(alpha: .2),
                      ),
                      Text(
                        '${adhanCtrl.prayerNameList[index]['title']}'.tr,
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              context.theme.canvasColor.withValues(alpha: .7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    adhanCtrl.prayerNameList[index]['time'],
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.theme.canvasColor.withValues(alpha: .7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Gap(16),
            Column(
              children: List.generate(
                notificationOptions.length,
                (i) => SizedBox(
                  height: 50,
                  child: GestureDetector(
                    onTap: () async =>
                        await adhanCtrl.notificationOptionsOnTap(i, index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
