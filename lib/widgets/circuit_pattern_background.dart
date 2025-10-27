import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// Background widget with animated electrical circuit pattern
///
/// Displays a subtle circuit trace pattern in the background,
/// useful for adding electrical theming to screens and components.
class CircuitPatternBackground extends StatelessWidget {
  /// Opacity of the circuit pattern (0.0 to 1.0)
  final double opacity;

  /// Color of the circuit traces
  final Color color;

  /// Whether to animate the circuit pattern
  final bool animate;

  const CircuitPatternBackground({
    super.key,
    this.opacity = 0.1,
    this.color = AppTheme.accentCopper,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        painter: CircuitPatternPainter(
          color: color,
          animate: animate,
        ),
        child: Container(),
      ),
    );
  }
}

/// Custom painter for circuit pattern background
class CircuitPatternPainter extends CustomPainter {
  final Color color;
  final bool animate;

  const CircuitPatternPainter({
    required this.color,
    this.animate = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final circuitPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw grid of circuit traces
    final gridSpacing = 40.0;

    // Horizontal traces
    for (double y = 0; y < size.height; y += gridSpacing) {
      final path = Path();
      path.moveTo(0, y);

      for (double x = 0; x < size.width; x += gridSpacing / 2) {
        // Add small vertical jogs to create circuit-like pattern
        if (x % gridSpacing == 0) {
          path.lineTo(x, y);
          path.lineTo(x, y + 10);
          path.lineTo(x + gridSpacing / 2, y + 10);
          path.lineTo(x + gridSpacing / 2, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    // Vertical traces
    for (double x = 0; x < size.width; x += gridSpacing) {
      final path = Path();
      path.moveTo(x, 0);

      for (double y = 0; y < size.height; y += gridSpacing / 2) {
        // Add small horizontal jogs
        if (y % gridSpacing == 0) {
          path.lineTo(x, y);
          path.lineTo(x + 10, y);
          path.lineTo(x + 10, y + gridSpacing / 2);
          path.lineTo(x, y + gridSpacing / 2);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    // Add connection points at intersections
    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        // Draw small circle at intersection
        canvas.drawCircle(
          Offset(x, y),
          2.5,
          circuitPaint,
        );

        // Draw slightly larger circle outline
        canvas.drawCircle(
          Offset(x, y),
          4,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CircuitPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.animate != animate;
  }
}
