import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// معرض وسائط رسالة الملاحظة (صور + فيديو) — يُعرض داخل فقاعة المحادثة.
///
/// الصور تُعرض ملء الشاشة بتكبير داخل التطبيق،
/// والفيديو يُفتح بالمشغل الخارجي (قرار التصميم — بلا video_player).
class FeedbackMediaGallery extends StatelessWidget {
  const FeedbackMediaGallery({super.key, required this.urls});

  /// قائمة روابط الوسائط.
  final List<String> urls;

  bool _isVideo(String url) {
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mov');
  }

  Future<void> _openVideoExternally(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log('No external video player found', name: 'FeedbackMediaGallery');
      }
    } catch (e) {
      log('openVideo error: $e', name: 'FeedbackMediaGallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: urls.map((url) => _mediaThumb(context, url)).toList(),
    );
  }

  Widget _mediaThumb(BuildContext context, String url) {
    final isVideo = _isVideo(url);
    return GestureDetector(
      onTap: () {
        if (isVideo) {
          _openVideoExternally(url);
        } else {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => _FullScreenImage(url: url)));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 120.w,
          height: 120.w,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.1),
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stack) => ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              if (isVideo)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عارض الصورة ملء الشاشة مع تكبير/تصغير.
class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.network(
              url,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stack) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
