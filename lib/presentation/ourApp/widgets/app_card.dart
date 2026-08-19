import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/container_button_widget.dart';
import '../data/models/our_app_model.dart';

/// بطاقة غنية لتطبيق واحد: بانر + شعار + عنوان + وصف + وسوم + معرض صور + زر تنزيل.
class AppCard extends StatelessWidget {
  final OurAppInfo app;
  final ValueChanged<OurAppInfo> onLaunch;

  const AppCard({super.key, required this.app, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onLaunch(app),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(8)).r,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0).r,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بانر علوي عريض
            _networkImage(
              OurAppInfo.resolveImageUrl(app.appBanner),
              height: 140.h,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _networkImage(
                        OurAppInfo.resolveImageUrl(app.appLogo),
                        height: 50.h,
                        width: 50.h,
                        fit: BoxFit.contain,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          app.appTitle,
                          style: TextStyle(
                            color: context.theme.colorScheme.inversePrimary,
                            fontSize: 14.sp,
                            height: 1.7,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    app.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.theme.colorScheme.surface.withValues(
                        alpha: .7,
                      ),
                      fontSize: 10.sp,
                      height: 1.7,
                      fontFamily: 'cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (app.tags != null && app.tags!.isNotEmpty) ...[
                    const Gap(8),
                    Wrap(
                      spacing: 6.0.w,
                      runSpacing: 4.0.h,
                      children: app.tags!
                          .map((t) => _tagChip(context, t))
                          .toList(),
                    ),
                  ],
                  if (app.banners != null && app.banners!.isNotEmpty) ...[
                    const Gap(10),
                    SizedBox(
                      height: 150.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: app.banners!.length,
                        separatorBuilder: (_, __) => const Gap(8),
                        itemBuilder: (context, i) => ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ).r,
                          child: _networkImage(
                            OurAppInfo.resolveImageUrl(app.banners![i]),
                            height: 150.h,
                            width: 90.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Gap(12),
                  Align(
                    alignment: Alignment.center,
                    child: ContainerButtonWidget(
                      onPressed: () => onLaunch(app),
                      width: 160,
                      height: 45,
                      borderRadius: 8,
                      icon: Icons.download_outlined,
                      svgHeight: 20,
                      title: 'download'.tr,
                      backgroundColor: context.theme.colorScheme.surface,
                      titleColor: context.theme.colorScheme.primaryContainer,
                      svgColor: context.theme.colorScheme.primaryContainer,
                      shapeColor: context.theme.colorScheme.primaryContainer
                          .withValues(alpha: .3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0).r,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withValues(alpha: .12),
        borderRadius: const BorderRadius.all(Radius.circular(20)).r,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          height: 1.7,
          fontFamily: 'cairo',
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.surface,
        ),
      ),
    );
  }

  /// صورة شبكة مع placeholder للتحميل وأيقونة عند الفشل لتفادي الكراش.
  Widget _networkImage(
    String url, {
    required double height,
    double? width,
    required BoxFit fit,
  }) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          width: width,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: height,
          width: width,
          child: Container(
            color: Colors.black12,
            child: const Icon(Icons.broken_image_outlined),
          ),
        );
      },
    );
  }
}
