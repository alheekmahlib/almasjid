part of '../prayers.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Gap(64),
          const AnimatedDrawingWidget(
            height: 70,
            width: 140,
            isRepeat: true,
          ),
          const Gap(16),
          Text(
            'downloadingPrayerData'.tr,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'cairo',
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
