import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/utils/constants/extensions/custom_error_snack_bar.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../controller/feedback_controller.dart';
import '../data/models/feedback_reply_model.dart';
import '../widgets/feedback_media_gallery.dart';

/// شاشة المحادثة الواحدة: الرسالة الأصلية + الردود (مشرف/مستخدم) + شريط الرد.
///
/// تستهلك [FeedbackController.openThread] — لا تملك state إلا حقل الرد.
class FeedbackConversationScreen extends StatefulWidget {
  const FeedbackConversationScreen({super.key});

  @override
  State<FeedbackConversationScreen> createState() =>
      _FeedbackConversationScreenState();
}

class _FeedbackConversationScreenState
    extends State<FeedbackConversationScreen> {
  final FeedbackController _c = FeedbackController.instance;
  final TextEditingController _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    _c.clearFiles();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final canSend =
        _replyCtrl.text.trim().isNotEmpty || _c.selectedFiles.isNotEmpty;
    if (!canSend) return;
    final result = await _c.sendReply(_replyCtrl.text);
    if (!mounted) return;
    result.fold(
      (failure) => context.showCustomErrorSnackBar('feedbackSentError'.tr),
      (_) {
        _replyCtrl.clear();
        _c.clearFiles();
      },
    );
  }

  Future<void> _pickImages() async {
    final err = await _c.pickImages();
    if (err != null && mounted) context.showCustomErrorSnackBar(err.tr);
  }

  Future<void> _pickVideo() async {
    final err = await _c.pickVideo();
    if (err != null && mounted) context.showCustomErrorSnackBar(err.tr);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(withBackButton: true),
            Expanded(
              child: Obx(() {
                if (_c.isLoadingThread.value && _c.openThread.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final thread = _c.openThread.value;
                if (thread == null) {
                  return _errorState();
                }
                return Column(
                  children: [
                    _statusChip(thread.feedback.status),
                    Expanded(
                      child: _conversation(
                        thread.feedback.message,
                        thread.replies,
                        thread.feedback.mediaUrls,
                      ),
                    ),
                    _replyBar(context),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final (label, color) = _statusStyle(status);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'cairo',
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          visualDensity: VisualDensity.compact,
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

  Widget _conversation(
    String originalMessage,
    List<FeedbackReplyModel> replies,
    List<String> originalMediaUrls,
  ) {
    final items = <_ChatItem>[
      _ChatItem(
        body: originalMessage,
        isAdmin: false,
        createdAt: '',
        isOriginal: true,
        mediaUrls: originalMediaUrls,
      ),
      ...replies.map(
        (r) => _ChatItem(
          body: r.body,
          isAdmin: r.isAdmin,
          createdAt: r.createdAt,
          mediaUrls: r.mediaUrls,
        ),
      ),
    ];
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) => _ChatBubble(item: items[index]),
    );
  }

  Widget _replyBar(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(color: colorScheme.surface.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مصغّرات المرفقات المختارة للرد.
          Obx(() {
            final files = _c.selectedFiles;
            if (files.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(files.length, (i) {
                  final isVideo = _c.isVideoFile(files[i]);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: SizedBox(
                          width: 48.w,
                          height: 48.w,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(files[i], fit: BoxFit.cover),
                              if (isVideo)
                                Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _c.removeFileAt(i),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyCtrl,
                  minLines: 1,
                  maxLines: 4,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  style: TextStyle(
                    color: colorScheme.inversePrimary,
                    fontFamily: 'cairo',
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    hintText: 'feedbackReplyHint'.tr,
                    hintStyle: TextStyle(
                      color: colorScheme.inversePrimary.withValues(alpha: 0.5),
                      fontFamily: 'cairo',
                      fontSize: 15.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Gap(4.w),
              Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _c.isReplying.value ? null : _pickImages,
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: colorScheme.primary,
                        size: 22.sp,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: _c.isReplying.value ? null : _pickVideo,
                      icon: Icon(
                        Icons.videocam_outlined,
                        color: colorScheme.primary,
                        size: 22.sp,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Gap(4.w),
              Obx(
                () => IconButton(
                  onPressed: _c.isReplying.value ? null : _sendReply,
                  icon: _c.isReplying.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: colorScheme.primary,
                          size: 24.sp,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: TextButton(
        onPressed: () => _c.loadAllThreads(),
        child: Text('retry'.tr),
      ),
    );
  }
}

class _ChatItem {
  final String body;
  final bool isAdmin;
  final String createdAt;
  final bool isOriginal;
  final List<String> mediaUrls;
  const _ChatItem({
    required this.body,
    required this.isAdmin,
    required this.createdAt,
    this.isOriginal = false,
    this.mediaUrls = const [],
  });
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.item});
  final _ChatItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final align = item.isAdmin
        ? AlignmentDirectional.centerStart
        : AlignmentDirectional.centerEnd;
    final bg = item.isAdmin
        ? colorScheme.surface.withValues(alpha: 0.2)
        : colorScheme.primary.withValues(alpha: 0.1);
    final roleLabel = item.isAdmin
        ? 'feedbackAdminRole'.tr
        : 'feedbackYouRole'.tr;
    final time = item.createdAt.isEmpty ? '' : _formatTime(item.createdAt);

    return Align(
      alignment: align,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        constraints: BoxConstraints(maxWidth: 280.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roleLabel,
              style: TextStyle(
                color: colorScheme.inversePrimary.withValues(alpha: 0.6),
                fontFamily: 'cairo',
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
            Gap(4.h),
            if (item.body.isNotEmpty)
              Text(
                item.body,
                style: TextStyle(
                  color: colorScheme.inversePrimary,
                  fontFamily: 'cairo',
                  fontSize: 15.sp,
                ),
                textAlign: TextAlign.start,
              ),
            if (item.mediaUrls.isNotEmpty) ...[
              Gap(6.h),
              FeedbackMediaGallery(urls: item.mediaUrls),
            ],
            if (time.isNotEmpty) ...[
              Gap(4.h),
              Text(
                time,
                style: TextStyle(
                  color: colorScheme.inversePrimary.withValues(alpha: 0.5),
                  fontFamily: 'cairo',
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final local = dt.toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(local.hour)}:${two(local.minute)}';
    } catch (_) {
      return '';
    }
  }
}
