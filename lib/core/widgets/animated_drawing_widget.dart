import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart'
    show
        Alignment,
        BlendMode,
        BuildContext,
        Color,
        Curves,
        LinearGradient,
        Opacity,
        ShaderMask,
        SizedBox,
        StatelessWidget,
        Widget;
import 'package:get/get_utils/get_utils.dart';

import '../utils/constants/svg_constants.dart';

class AnimatedDrawingWidget extends StatelessWidget {
  final String? svgPath;
  final double? height;
  final double? width;
  final double? opacity;
  final int? duration;
  final AnimationDirection? animationDirection;
  final Color? customColor;
  final bool? isRepeat;

  const AnimatedDrawingWidget(
      {super.key,
      this.height,
      this.width,
      this.opacity,
      this.duration,
      this.animationDirection,
      this.customColor,
      this.svgPath,
      this.isRepeat});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 90,
      width: width ?? 170,
      child: Opacity(
        opacity: opacity ?? 1.0,
        child: _buildAnimatedDrawing(context),
      ),
    );
  }

  // بناء الـ AnimatedDrawing مع معالجة مخصصة لـ iOS
  // Build AnimatedDrawing with custom iOS handling
  Widget _buildAnimatedDrawing(BuildContext context) {
    // في iOS، نحتاج إلى معالجة مخصصة للألوان والتدرجات
    // In iOS, we need custom handling for colors and gradients
    final effectiveColor = customColor ?? context.theme.colorScheme.surface;

    // إنشاء التدرج بطريقة متوافقة مع iOS
    // Create gradient in iOS-compatible way
    final gradient = LinearGradient(
      colors: [
        effectiveColor,
        effectiveColor,
      ],
      begin: Alignment.center,
      end: Alignment.center,
    );

    // للتأكد من التوافق مع iOS، نستخدم ShaderMask بطريقة محسنة
    // For iOS compatibility, use ShaderMask in optimized way
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.modulate,
      child: AnimatedDrawing.svg(
        svgPath ?? SvgPath.svgLogoAqemLogoStroke,
        animationDirection:
            animationDirection ?? AnimationDirection.rightToLeft,
        run: true,
        duration: Duration(seconds: duration ?? 3),
        height: height ?? 90,
        width: width ?? 170,
        // إضافة خصائص مخصصة لـ iOS
        // Add iOS-specific properties
        scaleToViewport: true,
        repeat: isRepeat ?? false,
        lineAnimation: LineAnimation.oneByOne,
        // تحسين الأداء على iOS
        // Optimize performance on iOS
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}
