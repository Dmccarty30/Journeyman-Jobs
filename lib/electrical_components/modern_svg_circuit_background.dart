import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../design_system/app_theme.dart';

class ModernSvgCircuitBackground extends StatefulWidget {
  final double opacity;
  final double animationSpeed;

  const ModernSvgCircuitBackground({
    super.key,
    this.opacity = 0.08,
    this.animationSpeed = 3.0,
  });

  @override
  State<ModernSvgCircuitBackground> createState() => _ModernSvgCircuitBackgroundState();
}

class _ModernSvgCircuitBackgroundState extends State<ModernSvgCircuitBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (10 / widget.animationSpeed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ModernCircuitPainter(
            animationValue: _controller.value,
            opacity: widget.opacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ModernCircuitPainter extends CustomPainter {
  final double animationValue;
  final double opacity;

  _ModernCircuitPainter({
    required this.animationValue,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final navyPaint = Paint()
      ..color = AppTheme.primaryNavy.withValues(alpha: opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final copperGlowPaint = Paint()
      ..color = AppTheme.accentCopper.withValues(alpha: opacity * 2.0)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

    // Generate deterministic paths based on size
    final random = math.Random(42); 
    final int pathCount = 12;
    
    for (int i = 0; i < pathCount; i++) {
      final path = Path();
      double startY = (size.height / pathCount) * i + (random.nextDouble() * 50);
      double startX = -50.0; // Start off-screen
      
      path.moveTo(startX, startY);
      
      double currentX = startX;
      double currentY = startY;
      
      while (currentX < size.width + 50) {
        // Create zigzag pattern (45 degree lines typical in circuit diagrams)
        double segmentLength = 50 + random.nextDouble() * 100;
        
        // Horizontal segment
        currentX += segmentLength;
        path.lineTo(currentX, currentY);
        
        // Angled segment (45 degrees)
        if (random.nextBool()) {
          double angleChange = 30.0;
          if (random.nextBool()) angleChange = -angleChange;
          
          currentX += angleChange.abs();
          currentY += angleChange;
          path.lineTo(currentX, currentY);
        }
      }

      // Draw the base navy trace
      canvas.drawPath(path, navyPaint);

      // Draw animated flow effect
      // We simulate a dash effect that moves
      final PathMetrics pathMetrics = path.computeMetrics();
      for (final PathMetric metric in pathMetrics) {
        final length = metric.length;
        final dashLength = 40.0;
        final gapLength = 120.0;
        
        // Calculate offset based on animation
        final offset = -1 * animationValue * (dashLength + gapLength) * 5; // Speed multiplier
        
        // Extract dashes manually for better control or use simple dash logic
        // For simplicity and glow, we'll draw segments
        
        double distance = offset % (dashLength + gapLength);
        if (distance > 0) distance -= (dashLength + gapLength);

        while (distance < length) {
          final double start = distance;
          final double end = start + dashLength;
          
          // Only draw if visible
          if (end > 0 && start < length) {
             final extractStart = math.max(0.0, start);
             final extractEnd = math.min(length, end);
             
             final extractPath = metric.extractPath(extractStart, extractEnd);
             canvas.drawPath(extractPath, copperGlowPaint);
          }
          
          distance += dashLength + gapLength;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ModernCircuitPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.opacity != opacity;
  }
}
