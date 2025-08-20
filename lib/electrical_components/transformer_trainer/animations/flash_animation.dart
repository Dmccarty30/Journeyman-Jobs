
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Enhanced flash animation widget for indicating incorrect connections
class FlashAnimationWidget extends StatefulWidget {

  const FlashAnimationWidget({
    required this.controller, super.key,
    this.color = Colors.red,
    this.enhanced = true,
  });
  final AnimationController controller;
  final Color color;
  final bool enhanced;

  @override
  State<FlashAnimationWidget> createState() => _FlashAnimationWidgetState();
}

class _FlashAnimationWidgetState extends State<FlashAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ),);
    
    // Trigger shake when main animation starts
    widget.controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.forward) {
        _shakeController.forward().then((_) {
          _shakeController.reset();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[widget.controller, _shakeController]),
      builder: (BuildContext context, Widget? child) => Transform.translate(
          offset: widget.enhanced ? Offset(
            math.sin(_shakeController.value * 2 * math.pi) * _shakeAnimation.value,
            0,
          ) : Offset.zero,
          child: Stack(
            children: <Widget>[
              // Multiple flash layers for more intensity
              if (widget.enhanced) ...<Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2 * widget.controller.value),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: widget.color.withOpacity(0.6 * widget.controller.value),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.4 * widget.controller.value),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.color.withOpacity(0.8 * widget.controller.value),
                    width: 3,
                  ),
                ),
                child: CustomPaint(
                  painter: LightningBoltPainter(
                    progress: widget.controller.value,
                    color: widget.color,
                    enhanced: widget.enhanced,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
    );
}

/// Enhanced custom painter for drawing dramatic lightning bolt effects
class LightningBoltPainter extends CustomPainter {

  LightningBoltPainter({
    required this.progress,
    required this.color,
    this.enhanced = true,
  });
  final double progress;
  final Color color;
  final bool enhanced;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final Paint paint = Paint()
      ..color = color.withOpacity(progress)
      ..strokeWidth = enhanced ? 5.0 : 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add glow effect for enhanced mode
    if (enhanced) {
      final Paint glowPaint = Paint()
        ..color = color.withOpacity(progress * 0.5)
        ..strokeWidth = 12.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      // Draw glow layer first
      _drawLightningPattern(canvas, glowPaint, size, progress);
    }

    // Draw main lightning pattern
    _drawLightningPattern(canvas, paint, size, progress);

    // Draw electric arc effects
    _drawElectricArcs(canvas, paint, size);
    
    // Add spark effects for enhanced mode
    if (enhanced) {
      _drawSparks(canvas, size, progress);
    }
  }
  
  void _drawLightningPattern(Canvas canvas, Paint paint, Size size, double progress) {
    final _SeededRandom random = _SeededRandom(42); // Use seeded random for consistent animation
    
    // Draw more lightning bolts in enhanced mode
    final int boltCount = enhanced ? 5 : 3;
    for (int i = 0; i < boltCount; i++) {
      final double startX = size.width * random.nextDouble();
      final double startY = size.height * 0.1;
      final double endY = size.height * 0.9;
      
      _drawLightningBolt(
        canvas,
        paint,
        startX,
        startY,
        startX + (random.nextDouble() - 0.5) * (enhanced ? 150 : 100),
        endY,
      );
    }
  }

  /// Draw a more dramatic zigzag lightning bolt
  void _drawLightningBolt(Canvas canvas, Paint paint, double startX, double startY, double endX, double endY) {
    final Path path = Path();
    path.moveTo(startX, startY);

    final int segments = enhanced ? 10 : 6;
    final _SeededRandom random = _SeededRandom(startX.toInt() + startY.toInt());
    
    for (int i = 1; i <= segments; i++) {
      final double t = i / segments;
      // More dramatic zigzag with randomization
      final int zigzagAmount = enhanced ? 25 : 15;
      final double randomOffset = random.nextDouble() * 10 - 5;
      final double x = startX + (endX - startX) * t +
                (i % 2 == 0 ? zigzagAmount : -zigzagAmount) * progress +
                randomOffset;
      final double y = startY + (endY - startY) * t;
      
      if (enhanced && i % 3 == 0) {
        // Add branch - store the current position before branching
        final double currentX = x;
        final double currentY = y;
        final double branchX = x + (random.nextDouble() - 0.5) * 50;
        final double branchY = y + random.nextDouble() * 30;
        path.lineTo(branchX, branchY);
        path.moveTo(currentX, currentY);
      }
      
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  /// Draw enhanced electric arc effects
  void _drawElectricArcs(Canvas canvas, Paint paint, Size size) {
    final Paint arcPaint = Paint()
      ..color = color.withOpacity(progress * 0.7)
      ..strokeWidth = enhanced ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    // Draw more dramatic curved arcs
    final int arcCount = enhanced ? 4 : 2;
    for (int i = 0; i < arcCount; i++) {
      final double centerX = size.width * (0.2 + i * 0.6 / arcCount);
      final double centerY = size.height * (0.3 + (i % 2) * 0.4);
      final double radius = (enhanced ? 40.0 : 30.0) * progress * (1 + i * 0.2);

      final Rect rect = Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      );

      // Draw multiple arc segments for more chaos
      for (int j = 0; j < 3; j++) {
        final double startAngle = j * 2.094; // 120 degrees
        final double sweepAngle = math.pi * progress * (0.5 + j * 0.2);
        
        canvas.drawArc(
          rect,
          startAngle,
          sweepAngle,
          false,
          arcPaint,
        );
      }
    }
  }
  
  /// Draw spark effects for enhanced mode
  void _drawSparks(Canvas canvas, Size size, double progress) {
    final _SeededRandom random = _SeededRandom(100);
    final Paint sparkPaint = Paint()
      ..color = Colors.white.withOpacity(progress * 0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw multiple sparks
    for (int i = 0; i < 12; i++) {
      final double centerX = size.width * random.nextDouble();
      final double centerY = size.height * random.nextDouble();
      final double sparkSize = 5 + random.nextDouble() * 10;
      
      // Draw cross-shaped spark
      canvas.drawLine(
        Offset(centerX - sparkSize * progress, centerY),
        Offset(centerX + sparkSize * progress, centerY),
        sparkPaint,
      );
      canvas.drawLine(
        Offset(centerX, centerY - sparkSize * progress),
        Offset(centerX, centerY + sparkSize * progress),
        sparkPaint,
      );
      
      // Add diagonal lines for more detail
      if (enhanced) {
        final double diagonalSize = sparkSize * 0.7;
        canvas.drawLine(
          Offset(centerX - diagonalSize * progress, centerY - diagonalSize * progress),
          Offset(centerX + diagonalSize * progress, centerY + diagonalSize * progress),
          sparkPaint,
        );
        canvas.drawLine(
          Offset(centerX - diagonalSize * progress, centerY + diagonalSize * progress),
          Offset(centerX + diagonalSize * progress, centerY - diagonalSize * progress),
          sparkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(LightningBoltPainter oldDelegate) => progress != oldDelegate.progress ||
           color != oldDelegate.color ||
           enhanced != oldDelegate.enhanced;
}

/// Simple seeded random number generator for consistent animations
class _SeededRandom {

  _SeededRandom(this._seed);
  int _seed;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x80000000;
  }
}

/// Success flash animation with green color and check marks
class SuccessFlashWidget extends StatelessWidget {

  const SuccessFlashWidget({
    required this.controller, super.key,
  });
  final AnimationController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) => DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2 * controller.value),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: SuccessEffectPainter(
              progress: controller.value,
            ),
            size: Size.infinite,
          ),
        ),
    );
}

/// Custom painter for success effects (check marks and sparkles)
class SuccessEffectPainter extends CustomPainter {

  SuccessEffectPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final Paint paint = Paint()
      ..color = Colors.green.withOpacity(progress)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw check mark
    _drawCheckMark(canvas, paint, size);

    // Draw sparkle effects
    _drawSparkles(canvas, paint, size);
  }

  /// Draw an animated check mark
  void _drawCheckMark(Canvas canvas, Paint paint, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    const double checkSize = 20;

    final Path path = Path();
    
    // Left part of check mark
    if (progress > 0.3) {
      path.moveTo(centerX - checkSize, centerY);
      path.lineTo(centerX - checkSize / 3, centerY + checkSize / 2);
    }
    
    // Right part of check mark
    if (progress > 0.6) {
      path.moveTo(centerX - checkSize / 3, centerY + checkSize / 2);
      path.lineTo(centerX + checkSize, centerY - checkSize / 2);
    }

    canvas.drawPath(path, paint);
  }

  /// Draw sparkle effects around the success indicator
  void _drawSparkles(Canvas canvas, Paint paint, Size size) {
    final Paint sparklePaint = Paint()
      ..color = Colors.green.withOpacity(progress * 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final _SeededRandom random = _SeededRandom(123);
    
    for (int i = 0; i < 6; i++) {
      final double x = size.width * random.nextDouble();
      final double y = size.height * random.nextDouble();
      final double sparkleSize = 8.0 * progress;

      // Draw sparkle as a cross
      canvas.drawLine(
        Offset(x - sparkleSize, y),
        Offset(x + sparkleSize, y),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(x, y - sparkleSize),
        Offset(x, y + sparkleSize),
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(SuccessEffectPainter oldDelegate) => progress != oldDelegate.progress;
}
