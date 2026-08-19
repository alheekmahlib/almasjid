import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/utils/constants/extensions/custom_error_snack_bar.dart';
import '../../../core/utils/helpers/app_router.dart';
import '../../../core/widgets/container_button_widget.dart';
import '../controller/feedback_controller.dart';

/// ورقة إرسال ملاحظة جديدة (تُفتح عبر customBottomSheet).
///
/// كل اللوجيك في [FeedbackController] — الورقة تدير TextEditingControllers
/// المحلية فقط (تنظيف عند الإغلاق).
class FeedbackSendSheet extends StatefulWidget {
  const FeedbackSendSheet({super.key});

  @override
  State<FeedbackSendSheet> createState() => _FeedbackSendSheetState();
}

class _FeedbackSendSheetState extends State<FeedbackSendSheet> {
  final FeedbackController _c = FeedbackController.instance;
  final TextEditingController _messageCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final ValueNotifier<int> _charCount = ValueNotifier<int>(0);

  static const int _maxChars = 8000;

  @override
  void initState() {
    super.initState();
    _messageCtrl.addListener(() => _charCount.value = _messageCtrl.text.length);
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _emailCtrl.dispose();
    _charCount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _c.submitFeedback(
      _messageCtrl.text,
      email: _emailCtrl.text,
      context: context,
    );
    if (!mounted) return;
    result.fold(
      (failure) => context.showCustomErrorSnackBar('feedbackSentError'.tr),
      (model) {
        _messageCtrl.clear();
        _emailCtrl.clear();
        // أغلق الورقة (route الخاص بـ showModalBottomSheet).
        Navigator.of(context).pop();
        context.showCustomErrorSnackBar('feedbackSentSuccess'.tr, isDone: true);
        _c.loadAllThreads();
        // افتح محادثة الملاحظة الجديدة مباشرة إن توفر token.
        if (model.token.isNotEmpty) {
          _c.openConversation(model.token);
          Get.toNamed(AppRouter.feedbackConversation);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'feedbackSubtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.inversePrimary.withValues(alpha: 0.7),
              fontFamily: 'cairo',
              fontSize: 13.sp,
            ),
          ),
          Gap(12.h),
          _messageField(context),
          ValueListenableBuilder<int>(
            valueListenable: _charCount,
            builder: (context, used, _) {
              final remaining = _maxChars - used;
              return Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '$remaining ${'charactersRemaining'.tr}',
                  style: TextStyle(
                    color: colorScheme.inversePrimary.withValues(alpha: 0.6),
                    fontFamily: 'cairo',
                    fontSize: 11.sp,
                  ),
                ),
              );
            },
          ),
          Gap(12.h),
          _emailField(context),
          Gap(12.h),
          _mediaSection(context),
          Gap(16.h),
          ValueListenableBuilder<int>(
            valueListenable: _charCount,
            builder: (context, used, _) {
              final hasText = used > 0;
              return Obx(() {
                final busy = _c.isSubmitting.value;
                final uploading = _c.isUploading.value;
                final hasFiles = _c.selectedFiles.isNotEmpty;
                // مفعّل إن وُجد نص أو ملفات، ولسنا مشغولين.
                final enabled = (hasText || hasFiles) && !busy && !uploading;
                return Opacity(
                  opacity: enabled ? 1.0 : 0.5,
                  child: ContainerButtonWidget(
                    onPressed: enabled ? _submit : null,
                    title: 'feedbackSendNote'.tr,
                    isLoading: busy,
                    icon: Icons.send,
                    height: 48,
                    backgroundColor: colorScheme.primary,
                  ),
                );
              });
            },
          ),
          Gap(16.h),
        ],
      ),
    );
  }

  Widget _mediaSection(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Obx(() {
      final files = _c.selectedFiles;
      final uploading = _c.isUploading.value;
      final progress = _c.uploadProgress.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف الأزرار: + صور + فيديو + عدّاد.
          Row(
            children: [
              _pickerButton(
                context: context,
                icon: Icons.add_photo_alternate_outlined,
                label: 'feedbackPickImages',
                onPressed: uploading ? null : () => _pickImages(context),
              ),
              Gap(8.w),
              _pickerButton(
                context: context,
                icon: Icons.videocam_outlined,
                label: 'feedbackPickVideo',
                onPressed: uploading ? null : () => _pickVideo(context),
              ),
              const Spacer(),
              Text(
                '${files.length}/${FeedbackController.maxFiles}',
                style: TextStyle(
                  color: colorScheme.inversePrimary.withValues(alpha: 0.6),
                  fontFamily: 'cairo',
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          // شريط تقدّم الرفع.
          if (uploading) ...[
            Gap(8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: colorScheme.surface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            Gap(4.h),
            Text(
              '${'feedbackUploading'.tr} ${(progress * 100).toInt()}%',
              style: TextStyle(
                color: colorScheme.inversePrimary.withValues(alpha: 0.6),
                fontFamily: 'cairo',
                fontSize: 11.sp,
              ),
            ),
          ],
          // شبكة المصغّرات.
          if (files.isNotEmpty) ...[
            Gap(8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(files.length, (i) {
                return _thumb(context, files[i], i);
              }),
            ),
          ],
        ],
      );
    });
  }

  Widget _pickerButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final colorScheme = context.theme.colorScheme;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.sp, color: colorScheme.primary),
              Gap(4.w),
              Text(
                label.tr,
                style: TextStyle(
                  color: colorScheme.inversePrimary,
                  fontFamily: 'cairo',
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// مصغّرة ملف واحد مع زر إزالة وشارة نوع.
  Widget _thumb(BuildContext context, File file, int index) {
    final isVideo = _c.isVideoFile(file);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: SizedBox(
            width: 72.w,
            height: 72.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(file, fit: BoxFit.cover),
                if (isVideo)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _c.removeFileAt(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 14.sp),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final err = await _c.pickImages();
    if (err != null && context.mounted) {
      context.showCustomErrorSnackBar(err.tr);
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final err = await _c.pickVideo();
    if (err != null && context.mounted) {
      context.showCustomErrorSnackBar(err.tr);
    }
  }

  /// زخرفة الحقول الموحدة: حدود بحواف 16 بلون السطح (نمط ورقة البحث القائمة).
  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    Widget? icon,
  }) {
    final colorScheme = context.theme.colorScheme;
    return InputDecoration(
      counterText: '',
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.inversePrimary.withValues(alpha: 0.5),
        fontFamily: 'cairo',
        fontSize: 15.sp,
      ),
      icon: icon,
      filled: true,
      fillColor: colorScheme.surface.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colorScheme.surface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colorScheme.surface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  Widget _messageField(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return TextField(
      controller: _messageCtrl,
      maxLines: 8,
      minLines: 5,
      maxLength: _maxChars,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: TextStyle(
        color: colorScheme.inversePrimary,
        fontFamily: 'cairo',
        fontSize: 15.sp,
      ),
      decoration: _fieldDecoration(context, hint: 'feedbackMessageHint'.tr),
    );
  }

  Widget _emailField(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return TextField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: TextStyle(
        color: colorScheme.inversePrimary,
        fontFamily: 'cairo',
        fontSize: 15.sp,
      ),
      decoration: _fieldDecoration(
        context,
        hint: 'feedbackContactOptional'.tr,
        icon: Icon(
          Icons.email_outlined,
          size: 20.sp,
          color: colorScheme.surface,
        ),
      ),
    );
  }
}
