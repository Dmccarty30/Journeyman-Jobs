import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Three-phase rotation meter loading indicator widget.
///
/// Authentic design based on industrial electrical rotation meters
/// used in three-phase power systems monitoring. Features realistic
/// rotation animations with red dot indicator and three-hole mounting
/// pattern typical of electrical panel equipment.
///
/// Used throughout Journeyman Jobs app for loading states where
/// electrical workers will recognize familiar equipment.
///
/// Example:
/// ```dart
/// ThreePhaseRotationMeter(
///   size: 120,
///   clockwise: true,
///   duration: Duration(seconds: 3),
/// )
/// ```
class ThreePhaseRotationMeter extends StatefulWidget {
  /// Size of the meter (width and height)
  final double size;

  /// Rotation direction - true for clockwise, false for counter-clockwise
  final bool clockwise;

  /// Duration of one complete rotation cycle
  final Duration duration;

  /// Whether animation should auto-start
  final bool autoStart;

  /// Custom color scheme - uses IBEW theme if null
  final RotationMeterColors? colors;

  /// Animation curve for realistic motion
  final Curve animationCurve;

  /// Optional semantic label for accessibility
  final String? semanticLabel;

  /// Show rotation speed indicator
  final bool showSpeedIndicator;

  /// Whether to show mounting holes
  final bool showMountingHoles;

  const ThreePhaseRotationMeter({
    super.key,
    this.size = 100.0,
    this.clockwise = true,
    this.duration = const Duration(seconds: 2),
    this.autoStart = true,
    this.colors,
    this.animationCurve = Curves.linear,
    this.semanticLabel,
    this.showSpeedIndicator = false,
    this.showMountingHoles = true,
  });

  @override
  State<ThreePhaseRotationMeter> createState() => _ThreePhaseRotationMeterState();
}

class _ThreePhaseRotationMeterState extends State<ThreePhaseRotationMeter>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  // Acceleration/deceleration controllers for realistic motion
  late AnimationController _accelerationController;
  late Animation<double> _accelerationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.autoStart) {
      startRotation();
    }
  }

  void _setupAnimations() {
    // Main rotation controller
    _rotationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.clockwise ? 2 * math.pi : -2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: widget.animationCurve,
    ));

    // Acceleration controller for realistic startup
    _accelerationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _accelerationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _accelerationController,
      curve: Curves.easeOutQuad,
    ));
  }

  /// Start the rotation animation
  void startRotation() {
    _accelerationController.forward().then((_) {
      _rotationController.repeat();
    });
  }

  /// Stop the rotation animation
  void stopRotation() {
    _accelerationController.reverse().then((_) {
      _rotationController.stop();
    });
  }

  /// Reset rotation to starting position
  void resetRotation() {
    _rotationController.reset();
    _accelerationController.reset();
  }

  @override
  void didUpdateWidget(ThreePhaseRotationMeter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation if duration changed
    if (widget.duration != oldWidget.duration) {
      _rotationController.duration = widget.duration;
    }

    // Restart with new direction if changed
    if (widget.clockwise != oldWidget.clockwise) {
      resetRotation();
      if (widget.autoStart) {
        startRotation();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _accelerationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? RotationMeterColors.ibewTheme();

    return Semantics(
      label: widget.semanticLabel ?? 'Loading indicator',
      value: 'Three-phase rotation meter showing loading animation',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationAnimation, _accelerationAnimation]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * _accelerationAnimation.value,
              child: CustomPaint(
                painter: _RotationMeterPainter(
                  colors: colors,
                  showMountingHoles: widget.showMountingHoles,
                  showSpeedIndicator: widget.showSpeedIndicator,
                ),
                size: Size(widget.size, widget.size),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for rendering the three-phase rotation meter
class _RotationMeterPainter extends CustomPainter {
  final RotationMeterColors colors;
  final bool showMountingHoles;
  final bool showSpeedIndicator;

  _RotationMeterPainter({
    required this.colors,
    required this.showMountingHoles,
    required this.showSpeedIndicator,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw meter components from back to front
    _drawMountingHoles(canvas, center, radius);
    _drawOuterRing(canvas, center, radius);
    _drawInnerDial(canvas, center, radius);
    _drawRotationIndicators(canvas, center, radius);
    _drawSpeedIndicator(canvas, center, radius);
    _drawRedDotIndicator(canvas, center, radius);
    _drawGlassEffect(canvas, center, radius);
  }

  /// Draw the three mounting holes characteristic of electrical meters
  void _drawMountingHoles(Canvas canvas, Offset center, double radius) {
    if (!showMountingHoles) return;

    final holeRadius = radius * 0.08;
    final holeDistance = radius * 0.85;

    // Three holes at 120-degree intervals
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120 * math.pi / 180) - math.pi / 2;
      final holeCenter = Offset(
        center.dx + math.cos(angle) * holeDistance,
        center.dy + math.sin(angle) * holeDistance,
      );

      final holePaint = Paint()
        ..color = colors.mountingHoleColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(holeCenter, holeRadius, holePaint);

      // Add shadow effect
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha:0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(holeCenter, holeRadius, shadowPaint);
    }
  }

  /// Draw the outer ring with metallic appearance
  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.outerRingLight,
          colors.outerRingDark,
          colors.outerRingLight,
        ],
        stops: const [0.0, 0.5, 1.0],
        center: Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, ringPaint);

    // Add border
    final borderPaint = Paint()
      ..color = colors.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02;

    canvas.drawCircle(center, radius * 0.98, borderPaint);
  }

  /// Draw the inner dial with measurement markings
  void _drawInnerDial(Canvas canvas, Offset center, double radius) {
    final innerRadius = radius * 0.85;

    // Inner dial background
    final dialPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.innerDialLight,
          colors.innerDialDark,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, dialPaint);

    // Draw scale markings
    _drawScaleMarkings(canvas, center, innerRadius);
  }

  /// Draw measurement scale markings around the dial
  void _drawScaleMarkings(Canvas canvas, Offset center, double radius) {
    final markingPaint = Paint()
      ..color = colors.markingColor
      ..strokeWidth = radius * 0.008
      ..strokeCap = StrokeCap.round;

    // Major markings (every 30 degrees)
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 * math.pi / 180) - math.pi / 2;
      final innerPoint = Offset(
        center.dx + math.cos(angle) * radius * 0.75,
        center.dy + math.sin(angle) * radius * 0.75,
      );
      final outerPoint = Offset(
        center.dx + math.cos(angle) * radius * 0.85,
        center.dy + math.sin(angle) * radius * 0.85,
      );

      canvas.drawLine(innerPoint, outerPoint, markingPaint);
    }

    // Minor markings (every 10 degrees)
    final minorPaint = Paint()
      ..color = colors.markingColor.withValues(alpha:0.5)
      ..strokeWidth = radius * 0.004;

    for (int i = 0; i < 36; i++) {
      if (i % 3 != 0) { // Skip major markings
        final angle = (i * 10 * math.pi / 180) - math.pi / 2;
        final innerPoint = Offset(
          center.dx + math.cos(angle) * radius * 0.80,
          center.dy + math.sin(angle) * radius * 0.80,
        );
        final outerPoint = Offset(
          center.dx + math.cos(angle) * radius * 0.85,
          center.dy + math.sin(angle) * radius * 0.85,
        );

        canvas.drawLine(innerPoint, outerPoint, minorPaint);
      }
    }
  }

  /// Draw rotation phase indicators
  void _drawRotationIndicators(Canvas canvas, Offset center, double radius) {
    final indicatorRadius = radius * 0.6;
    final indicatorPaint = Paint()
      ..color = colors.phaseIndicatorColor
      ..strokeWidth = radius * 0.02
      ..strokeCap = StrokeCap.round;

    // Three phase indicators at 120-degree intervals
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120 * math.pi / 180);
      final start = Offset(
        center.dx + math.cos(angle) * indicatorRadius * 0.5,
        center.dy + math.sin(angle) * indicatorRadius * 0.5,
      );
      final end = Offset(
        center.dx + math.cos(angle) * indicatorRadius,
        center.dy + math.sin(angle) * indicatorRadius,
      );

      canvas.drawLine(start, end, indicatorPaint);
    }
  }

  /// Draw optional speed indicator
  void _drawSpeedIndicator(Canvas canvas, Offset center, double radius) {
    if (!showSpeedIndicator) return;

    final speedText = '3600 RPM';
    final textStyle = TextStyle(
      color: colors.textColor,
      fontSize: radius * 0.12,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: speedText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy + radius * 0.25,
    );

    textPainter.paint(canvas, textOffset);
  }

  /// Draw the distinctive red dot indicator
  void _drawRedDotIndicator(Canvas canvas, Offset center, double radius) {
    final dotPosition = Offset(
      center.dx + radius * 0.85,
      center.dy,
    );

    // Red dot with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha:0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(
      Offset(dotPosition.dx + 2, dotPosition.dy + 2),
      radius * 0.08,
      shadowPaint,
    );

    final dotPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.redDotLight,
          colors.redDotDark,
        ],
      ).createShader(
        Rect.fromCircle(center: dotPosition, radius: radius * 0.08),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotPosition, radius * 0.08, dotPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(dotPosition.dx - radius * 0.02, dotPosition.dy - radius * 0.02),
      radius * 0.03,
      highlightPaint,
    );
  }

  /// Add glass reflection effect for realism
  void _drawGlassEffect(Canvas canvas, Offset center, double radius) {
    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha:0.4),
          Colors.white.withValues(alpha:0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
        center: const Alignment(-0.5, -0.5),
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 0.8),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.8, glassPaint);
  }

  @override
  bool shouldRepaint(_RotationMeterPainter oldDelegate) {
    return oldDelegate.colors != colors ||
           oldDelegate.showMountingHoles != showMountingHoles ||
           oldDelegate.showSpeedIndicator != showSpeedIndicator;
  }
}

/// Color configuration for the rotation meter
class RotationMeterColors {
  final Color outerRingLight;
  final Color outerRingDark;
  final Color innerDialLight;
  final Color innerDialDark;
  final Color redDotLight;
  final Color redDotDark;
  final Color borderColor;
  final Color markingColor;
  final Color phaseIndicatorColor;
  final Color textColor;
  final Color mountingHoleColor;

  const RotationMeterColors({
    required this.outerRingLight,
    required this.outerRingDark,
    required this.innerDialLight,
    required this.innerDialDark,
    required this.redDotLight,
    required this.redDotDark,
    required this.borderColor,
    required this.markingColor,
    required this.phaseIndicatorColor,
    required this.textColor,
    required this.mountingHoleColor,
  });

  /// Factory for IBEW-themed colors
  factory RotationMeterColors.ibewTheme() {
    return RotationMeterColors(
      outerRingLight: const Color(0xFFB0BEC5), // Light metal gray
      outerRingDark: const Color(0xFF455A64),    // Dark metal gray
      innerDialLight: const Color(0xFFF5F5F5),   // Light dial
      innerDialDark: const Color(0xFFE0E0E0),    // Medium gray
      redDotLight: const Color(0xFFEF5350),      // Bright red
      redDotDark: const Color(0xFFC62828),       // Dark red
      borderColor: const Color(0xFF37474F),       // Dark border
      markingColor: const Color(0xFF263238),     // Very dark gray
      phaseIndicatorColor: const Color(0xFF1A202C), // IBEW navy
      textColor: const Color(0xFF1A202C),        // IBEW navy text
      mountingHoleColor: const Color(0xFF000000), // Black holes
    );
  }

  /// Factory for copper accent theme
  factory RotationMeterColors.copperTheme() {
    return RotationMeterColors(
      outerRingLight: const Color(0xFFB87333),   // Light copper
      outerRingDark: const Color(0xFF8B5A2B),    // Dark copper
      innerDialLight: const Color(0xFFF5F5F5),   // Light dial
      innerDialDark: const Color(0xFFE0E0E0),    // Medium gray
      redDotLight: const Color(0xFFEF5350),      // Bright red
      redDotDark: const Color(0xFFC62828),       // Dark red
      borderColor: const Color(0xFF8B5A2B),       // Copper border
      markingColor: const Color(0xFF263238),     // Very dark gray
      phaseIndicatorColor: const Color(0xFFB45309), // IBEW copper
      textColor: const Color(0xFFB45309),        // Copper text
      mountingHoleColor: const Color(0xFF000000), // Black holes
    );
  }
}