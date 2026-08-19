import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/utils/constants/extensions/bottom_sheet_extension.dart';
import '../../../core/utils/helpers/app_router.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/container_button_widget.dart';
import '../controller/feedback_controller.dart';
import '../data/models/feedback_thread.dart';
import '../widgets/feedback_send_sheet.dart';

/// شاشة "تواصل معنا": قائمة بطاقات الملاحظات السابقة + زر لإرسال ملاحظة جديدة.
///
/// كل اللوجيك في [FeedbackController] — هذه الشاشة مجرد واجهة.
class FeedbackThreadScreen extends StatelessWidget {
  const FeedbackThreadScreen({super.key});

  FeedbackController get _c => FeedbackController.instance;

  @override
  Widget build(BuildContext context) {
    // تأكد من تحميل القائمة عند الفتح (يشمل بعد hot restart).
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.ensureLoaded());
    final colorScheme = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSendSheet,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        icon: const Icon(Icons.add),
        label: Text(
          'feedbackSendNote'.tr,
          style: TextStyle(
            color: colorScheme.primary,
            fontFamily: 'cairo',
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(withBackButton: true),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'email'.tr,
                style: TextStyle(
                  color: colorScheme.inversePrimary,
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_c.isLoadingList.value && _c.threads.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_c.loadError.value && _c.threads.isEmpty) {
                  return _errorState();
                }
                if (!_c.hasFeedback || _c.threads.isEmpty) {
                  return _emptyState(context);
                }
                return RefreshIndicator(
                  onRefresh: _c.loadAllThreads,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      8.h,
                      16.w,
                      96.h,
                    ), // مساحة للـ FAB
                    itemCount: _c.threads.length,
                    separatorBuilder: (_, __) => Gap(10.h),
                    itemBuilder: (context, index) {
                      final thread = _c.threads[index];
                      return _FeedbackCard(
                        thread: thread,
                        onTap: () => _openConversation(thread),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// يفتح شاشة المحادثة للبطاقة المضغوطة.
  void _openConversation(FeedbackThread thread) {
    Get.toNamed(AppRouter.feedbackConversation)?.then((_) {
      // أعد تحميل القائمة عند العودة (قد تكون أضفت ردًا).
      _c.loadAllThreads();
    });
    _c.openConversation(thread.feedback.token);
  }

  /// يفتح ورقة الإرسال.
  void _openSendSheet() {
    const SizedBox().customBottomSheet(
      textTitle: 'feedbackSendNote',
      containerColor: Get.theme.colorScheme.primaryContainer,
      child: const FeedbackSendSheet(),
    );
  }

  /// فشل جلب القائمة مع وجود ملاحظات محفوظة → إعادة محاولة.
  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 48.sp),
          const Gap(12),
          TextButton(
            onPressed: () => _c.loadAllThreads(),
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              size: 72.sp,
              color: colorScheme.surface.withValues(alpha: 0.4),
            ),
            Gap(16.h),
            Text(
              'feedbackNoNotesYet'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.inversePrimary.withValues(alpha: 0.7),
                fontFamily: 'cairo',
                fontSize: 16.sp,
              ),
            ),
            Gap(20.h),
            ContainerButtonWidget(
              onPressed: _openSendSheet,
              title: 'feedbackSendNote'.tr,
              icon: Icons.add,
              width: 200.w,
              height: 46,
              backgroundColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة ملاحظة واحدة في القائمة.
class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.thread, required this.onTap});
  final FeedbackThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final f = thread.feedback;
    final (label, color) = _statusStyle(f.status);
    final adminCount = thread.replies.where((r) => r.isAdmin).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (adminCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14.sp,
                          color: colorScheme.inversePrimary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        Gap(4.w),
                        Text(
                          '$adminCount',
                          style: TextStyle(
                            color: colorScheme.inversePrimary.withValues(
                              alpha: 0.6,
                            ),
                            fontFamily: 'cairo',
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Gap(8.h),
              Text(
                f.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.inversePrimary,
                  fontFamily: 'cairo',
                  fontSize: 15.sp,
                ),
              ),
              Gap(6.h),
              Text(
                _formatDate(f.createdAt),
                style: TextStyle(
                  color: colorScheme.inversePrimary.withValues(alpha: 0.5),
                  fontFamily: 'cairo',
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _statusStyle(String status) {
    switch (status) {
      case 'in_progress':
        return ('feedbackStatusInProgress'.tr, Colors.amber.shade700);
      case 'complete':
        return ('feedbackStatusComplete'.tr, Colors.green.shade700);
      case 'planned':
      default:
        return ('feedbackStatusPlanned'.tr, Colors.blue.shade700);
    }
  }

  /// yyyy/MM/dd محليًا، أو النص الخام عند فشل التحليل.
  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}/${two(d.month)}/${two(d.day)}';
    } catch (_) {
      return iso;
    }
  }
}
