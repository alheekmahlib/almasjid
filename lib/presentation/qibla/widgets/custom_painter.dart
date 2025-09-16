part of '../qibla.dart';

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({
    required this.ringColor,
    required this.tickColor,
    required this.textColor,
  });

  final Color ringColor;
  final Color tickColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = ringColor;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Ticks
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = tickColor;

    final boldTickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = tickColor.withValues(alpha: .9);

    const int totalTicks = 120; // every 3 degrees
    for (int i = 0; i < totalTicks; i++) {
      final double t = (i / totalTicks) * 2 * 3.141592653589793;
      final bool isCardinal = i % 30 == 0; // every 90 degrees
      final bool isBold = i % 10 == 0; // every 36 degrees (~10°)

      final double tickLen = isCardinal
          ? 14
          : isBold
              ? 9
              : 5;

      final Offset p1 = Offset(
        center.dx + (radius - 14) * _mc(t),
        center.dy + (radius - 14) * _ms(t),
      );
      final Offset p2 = Offset(
        center.dx + (radius - 14 - tickLen) * _mc(t),
        center.dy + (radius - 14 - tickLen) * _ms(t),
      );
      canvas.drawLine(p1, p2, isBold ? boldTickPaint : tickPaint);
    }

    // NESW letters
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final double t = (i / 4) * 2 * 3.141592653589793 -
          3.141592653589793 / 2; // start from top (N)
      final Offset pos = Offset(
        center.dx + (radius - 36) * _mc(t),
        center.dy + (radius - 36) * _ms(t),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            fontFamily: 'cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Lightweight wrappers to avoid importing dart:math in this part file.
double _ms(double r) => Offset.fromDirection(r).dy; // sin
double _mc(double r) => Offset.fromDirection(r).dx; // cos
