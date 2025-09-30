part of '../prayers.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedDrawingWidget(
            height: 70,
            width: 140,
          ),
          const Gap(16),
          Text(
            'جاري تحميل بيانات الصلاة...'.tr,
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
