import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Hard Hat Icon with Safety Theme
/// 
/// A static icon representing safety equipment commonly used in electrical
/// and construction work. Features a realistic hard hat design with a
/// safety stripe accent.
/// 
/// Example usage:
/// ```dart
/// HardHatIcon(
///   size: 48,
///   color: Colors.orange,
///   accentColor: Colors.navy,
/// )
/// ```
class HardHatIcon extends StatelessWidget {
  /// Size of the icon (width and height)
  final double size;
  
  /// Primary color of the hard hat
  final Color? color;
  
  /// Color of the safety stripe accent
  final Color? accentColor;

  const HardHatIcon({
    super.key,
    this.size = 48,
    this.color,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HardHatPainter(
          color: color ?? const Color(0xFFB45309), // Copper
          accentColor: accentColor ?? const Color(0xFF1A202C), // Navy
        ),
      ),
    );
  }
}

class HardHatPainter extends CustomPainter {
  final Color color;
  final Color accentColor;

  HardHatPainter({
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
      
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw shadow
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(1, 2), radius: radius),
      -math.pi,
      math.pi,
      false,
      shadowPaint,
    );

    // Draw hard hat dome
    final domePath = Path();
    domePath.moveTo(center.dx - radius, center.dy);
    domePath.quadraticBezierTo(
      center.dx, center.dy - radius * 1.2,
      center.dx + radius, center.dy,
    );
    domePath.close();
    canvas.drawPath(domePath, paint);

    // Draw hard hat brim
    final brimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.7),
        width: size.width * 0.9,
        height: size.height * 0.15,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(brimRect, paint);

    // Draw inner highlight for depth
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
      
    final highlightPath = Path();
    highlightPath.moveTo(center.dx - radius * 0.8, center.dy - radius * 0.2);
    highlightPath.quadraticBezierTo(
      center.dx - radius * 0.3, center.dy - radius * 0.9,
      center.dx, center.dy - radius * 0.8,
    );
    highlightPath.lineTo(center.dx, center.dy - radius * 0.5);
    highlightPath.quadraticBezierTo(
      center.dx - radius * 0.3, center.dy - radius * 0.6,
      center.dx - radius * 0.8, center.dy - radius * 0.2,
    );
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);

    // Draw safety stripe
    final stripePath = Path();
    stripePath.moveTo(center.dx - radius * 0.7, center.dy - radius * 0.35);
    stripePath.lineTo(center.dx + radius * 0.7, center.dy - radius * 0.35);
    stripePath.lineTo(center.dx + radius * 0.65, center.dy - radius * 0.15);
    stripePath.lineTo(center.dx - radius * 0.65, center.dy - radius * 0.15);
    stripePath.close();
    canvas.drawPath(stripePath, accentPaint);

    // Draw ventilation holes
    final holePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
      
    for (int i = -2; i <= 2; i++) {
      if (i != 0) {
        canvas.drawCircle(
          Offset(center.dx + i * radius * 0.15, center.dy - radius * 0.6),
          size.width * 0.02,
          holePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HardHatPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accentColor != accentColor;
  }
}