import 'package:flutter/material.dart';

/// Subtle circuit pattern background painter used in various UI surfaces.
///
/// This class matches the constructor used in NotificationPopup.
class CircuitPatternPainter extends CustomPainter { // Currently unused; kept to match call sites

  CircuitPatternPainter({
    this.primaryColor = const Color(0x0D000000), // ~5% opacity black fallback
    this.secondaryColor = const Color(0x08000000),
    this.animate = false,
  });
  final Color primaryColor;
  final Color secondaryColor;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Horizontal circuit traces
    for (int i = 0; i < 8; i++) {
      final double y = size.height * (i / 8);
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y);
      path.moveTo(size.width * 0.7, y);
      path.lineTo(size.width, y);

      // Nodes along the traces
      canvas.drawCircle(Offset(size.width * 0.3, y), 2, fillPaint);
      canvas.drawCircle(Offset(size.width * 0.7, y), 2, fillPaint);
    }

    // Vertical interconnects
    for (int i = 0; i < 6; i++) {
      final double x = size.width * (i / 6);
      path.moveTo(x, 0);
      path.lineTo(x, size.height * 0.2);
      path.moveTo(x, size.height * 0.8);
      path.lineTo(x, size.height);
    }

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

