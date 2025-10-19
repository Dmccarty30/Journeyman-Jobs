import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Electrical-themed skeleton loader with shimmer animation.
///
/// Displays animated loading placeholder maintaining IBEW electrical theme.
/// Useful for showing loading states while data fetches or auth initializes.
///
/// Features:
/// - Shimmer animation effect with copper and navy gradient
/// - Configurable dimensions and border radius
/// - Optional electrical circuit pattern overlay
/// - 60fps animation performance with efficient rendering
///
/// Example:
/// ```dart
/// JJSkeletonLoader(
///   width: double.infinity,
///   height: 80,
///   borderRadius: 12,
/// )
/// ```
class JJSkeletonLoader extends StatefulWidget {
  /// Width of the skeleton loader. Use double.infinity for full width.
  final double width;

  /// Height of the skeleton loader.
  final double height;

  /// Border radius for rounded corners.
  final double borderRadius;

  /// Optional margin around the skeleton loader.
  final EdgeInsetsGeometry? margin;

  /// Whether to show electrical circuit pattern overlay.
  final bool showCircuitPattern;

  const JJSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
    this.showCircuitPattern = false,
  });

  @override
  State<JJSkeletonLoader> createState() => _JJSkeletonLoaderState();
}

class _JJSkeletonLoaderState extends State<JJSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation controller
    // 1500ms duration provides smooth, professional shimmer effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Create animation that moves shimmer from left to right
    // Range of -2 to 2 ensures gradient covers full width with smooth transitions
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Clean up animation controller to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  // Navy with low opacity for subtle base
                  AppTheme.primaryNavy.withValues(alpha: 0.1),
                  // Copper accent for shimmer highlight
                  AppTheme.accentCopper.withValues(alpha: 0.2),
                  // Navy again to complete shimmer wave
                  AppTheme.primaryNavy.withValues(alpha: 0.1),
                ],
                // Clamp animation values to 0.0-1.0 range to prevent gradient errors
                // This ensures gradient stops are always valid even during animation
                stops: [
                  (_animation.value - 1).clamp(0.0, 1.0),
                  _animation.value.clamp(0.0, 1.0),
                  (_animation.value + 1).clamp(0.0, 1.0),
                ],
              ),
            ),
            // Add optional circuit pattern overlay for enhanced electrical theme
            child: widget.showCircuitPattern
                ? CustomPaint(
                    painter: _CircuitPatternPainter(),
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// Circuit pattern painter for electrical theme overlay.
///
/// Draws simple circuit lines to enhance the electrical theme
/// of skeleton loaders. Uses copper color at low opacity to
/// avoid overwhelming the shimmer animation.
class _CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCopper.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw simple circuit trace pattern
    // Creates a path that resembles electrical circuit board traces
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.3, size.height / 2);
    path.lineTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
