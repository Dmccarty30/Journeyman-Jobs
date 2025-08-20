import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// Voltage levels used across electrical-themed UI components.
enum VoltageLevel {
  low,
  medium,
  high,
}

/// Enhanced electrical-themed background components for the app
class EnhancedBackgrounds {
  EnhancedBackgrounds._();

  /// Returns a BoxDecoration appropriate for the given voltage level.
  /// This is used by various widgets (status chips, indicators) that need
  /// a consistent gradient / styling depending on voltage severity.
  static BoxDecoration voltageStatusGradient(
    VoltageLevel level, {
    BorderRadius? borderRadius,
  }) {
    final BorderRadius resolvedRadius =
        borderRadius ?? BorderRadius.circular(AppTheme.radiusSm);

    switch (level) {
      case VoltageLevel.high:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppTheme.errorRed,
              AppTheme.accentCopper,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: resolvedRadius,
        );
      case VoltageLevel.medium:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppTheme.accentCopper,
              AppTheme.primaryNavy,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: resolvedRadius,
        );
      case VoltageLevel.low:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppTheme.offWhite,
              AppTheme.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: resolvedRadius,
        );
    }
  }

  /// Circuit pattern background with animated electricity flow
  static Widget circuitPatternBackground({
    required Widget child,
    double opacity = 0.05,
    Color? patternColor,
    bool animated = false,
  }) =>
      Stack(
        children: <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: CircuitPatternPainter(
                  color: patternColor ?? AppTheme.accentCopper,
                  opacity: opacity,
                  animated: animated,
                ),
              ),
            ),
          ),
          child,
        ],
      );

  /// Gradient background with electrical theme
  static Widget electricalGradient({
    required Widget child,
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors ??
                <Color>[
                  AppTheme.primaryNavy.withValues(alpha: 0.95),
                  AppTheme.secondaryNavy,
                ],
          ),
        ),
        child: child,
      );

  /// Spark effect background for loading states
  static Widget sparkEffectBackground({
    required Widget child,
    bool active = true,
  }) =>
      Stack(
        children: <Widget>[
          if (active)
            const Positioned.fill(
              child: RepaintBoundary(
                child: SparkAnimation(),
              ),
            ),
          child,
        ],
      );

  /// Enhanced card background with subtle circuit pattern
  static Widget enhancedCardBackground({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool showCircuitPattern = true,
  }) =>
      Container(
        margin: margin,
          child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Container(
              padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.accentCopper.withValues(alpha: 0.3),
                  width: AppTheme.borderWidthThin,
                ),
                boxShadow: const <BoxShadow>[AppTheme.shadowSm],
              ),
              child: showCircuitPattern
                  ? Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CircuitPatternPainter(
                              color: AppTheme.accentCopper,
                              opacity: 0.02,
                              animated: false,
                            ),
                          ),
                        ),
                        child,
                      ],
                    )
                  : child,
            ),
          ),
        ),
      );

  /// Grid pattern background for technical screens
  static Widget gridPatternBackground({
    required Widget child,
    double spacing = 20.0,
    Color? gridColor,
    double opacity = 0.1,
  }) =>
      Stack(
        children: <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: GridPatternPainter(
                  spacing: spacing,
                  color: gridColor ?? AppTheme.mediumGray,
                  opacity: opacity,
                ),
              ),
            ),
          ),
          child,
        ],
      );

  /// Lightning bolt accent for headers and titles
  static Widget lightningAccent({
    required Widget child,
    bool showLightning = true,
    AlignmentGeometry alignment = Alignment.topRight,
  }) =>
      Stack(
        children: <Widget>[
          child,
          if (showLightning)
            Positioned(
              top: -10,
              right: -10,
              child: Icon(
                Icons.bolt,
                color: AppTheme.accentCopper.withValues(alpha: 0.3),
                size: 48,
              ),
            ),
        ],
      );
}

/// Circuit pattern painter for background effects
class CircuitPatternPainter extends CustomPainter {
  CircuitPatternPainter({
    required this.color,
    required this.opacity,
    required this.animated,
  });
  final Color color;
  final double opacity;
  final bool animated;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0;
    final math.Random random = math.Random(42); // Consistent pattern

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      if (random.nextBool()) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      if (random.nextBool()) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw connection points
    final Paint dotPaint = Paint()
      ..color = color.withValues(alpha: opacity * 2)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if (random.nextDouble() > 0.7) {
          canvas.drawCircle(Offset(x, y), 2, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CircuitPatternPainter oldDelegate) =>
      color != oldDelegate.color ||
      opacity != oldDelegate.opacity ||
      animated != oldDelegate.animated;
}

/// Grid pattern painter for technical backgrounds
class GridPatternPainter extends CustomPainter {
  GridPatternPainter({
    required this.spacing,
    required this.color,
    required this.opacity,
  });
  final double spacing;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) =>
      spacing != oldDelegate.spacing ||
      color != oldDelegate.color ||
      opacity != oldDelegate.opacity;
}

/// Spark animation for loading states
class SparkAnimation extends StatefulWidget {
  const SparkAnimation({super.key});

  @override
  State<SparkAnimation> createState() => _SparkAnimationState();
}

class _SparkAnimationState extends State<SparkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Spark> _sparks = <Spark>[];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Initialize sparks
    for (int i = 0; i < 20; i++) {
      _sparks.add(Spark(
        position: Offset(
          _random.nextDouble(),
          _random.nextDouble(),
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.5,
          (_random.nextDouble() - 0.5) * 0.5,
        ),
        size: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => CustomPaint(
          painter: SparkPainter(
            sparks: _sparks,
            animation: _controller.value,
          ),
        ),
      );
}

/// Individual spark data
class Spark {
  Spark({
    required this.position,
    required this.velocity,
    required this.size,
  });
  Offset position;
  final Offset velocity;
  final double size;
}

/// Spark painter for animation
class SparkPainter extends CustomPainter {
  SparkPainter({
    required this.sparks,
    required this.animation,
  });
  final List<Spark> sparks;
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.accentCopper.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (final Spark spark in sparks) {
      // Update position
      spark.position = Offset(
        (spark.position.dx + spark.velocity.dx * animation) % 1.0,
        (spark.position.dy + spark.velocity.dy * animation) % 1.0,
      );

      // Draw spark
      canvas.drawCircle(
        Offset(
          spark.position.dx * size.width,
          spark.position.dy * size.height,
        ),
        spark.size * (1.0 - animation * 0.5),
        paint..color = AppTheme.accentCopper.withValues(
          alpha: 0.6 * (1.0 - animation),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(SparkPainter oldDelegate) => true;
}
