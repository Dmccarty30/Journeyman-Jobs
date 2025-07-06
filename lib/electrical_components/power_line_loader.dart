import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Power Line Loading Animation
/// 
/// A transmission line-inspired loading indicator that shows electrical
/// power flowing between transmission towers. Features animated pulse
/// with dynamic spark effects to represent electrical energy.
/// 
/// Example usage:
/// ```dart
/// PowerLineLoader(
///   width: 200,
///   height: 60,
///   lineColor: Colors.navy,
///   pulseColor: Colors.orange,
///   duration: Duration(milliseconds: 1500),
/// )
/// ```
class PowerLineLoader extends StatefulWidget {
  /// Width of the loader
  final double width;
  
  /// Height of the loader
  final double height;
  
  /// Color of the power lines and towers
  final Color? lineColor;
  
  /// Color of the electrical pulse and sparks
  final Color? pulseColor;
  
  /// Duration of one complete animation cycle
  final Duration duration;

  const PowerLineLoader({
    Key? key,
    this.width = 200,
    this.height = 60,
    this.lineColor,
    this.pulseColor,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<PowerLineLoader> createState() => _PowerLineLoaderState();
}

class _PowerLineLoaderState extends State<PowerLineLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: PowerLinePainter(
              progress: _animation.value,
              lineColor: widget.lineColor ?? const Color(0xFF1A202C), // Navy
              pulseColor: widget.pulseColor ?? const Color(0xFFB45309), // Copper
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class PowerLinePainter extends CustomPainter {
  final double progress;
  final Color lineColor;
  final Color pulseColor;

  PowerLinePainter({
    required this.progress,
    required this.lineColor,
    required this.pulseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final pulsePaint = Paint()
      ..color = pulseColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw power line towers
    _drawTower(canvas, size, 0);
    _drawTower(canvas, size, size.width);
    
    // Draw power lines (3 lines for 3-phase)
    final lineY = size.height * 0.3;
    
    for (int i = 0; i < 3; i++) {
      final y = lineY + (i * 8);
      final sagY = y + (4 * math.sin(math.pi * 0.5)); // Add slight sag to lines
      
      // Create path for sagging power line
      final path = Path();
      path.moveTo(20, y);
      path.quadraticBezierTo(
        size.width / 2, sagY,
        size.width - 20, y,
      );
      canvas.drawPath(path, linePaint);
    }
    
    // Draw electrical pulse traveling along the main line
    final pulseX = 20 + (progress * (size.width - 40));
    
    // Calculate Y position on the curved line
    final t = (pulseX - 20) / (size.width - 40);
    final pulseY = _getQuadraticY(
      20, lineY,
      size.width / 2, lineY + 4,
      size.width - 20, lineY,
      t
    );
    
    // Draw pulse glow effect
    final glowPaint = Paint()
      ..color = pulseColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(pulseX, pulseY), 8, glowPaint);
    
    // Draw main pulse
    canvas.drawCircle(Offset(pulseX, pulseY), 4, pulsePaint..style = PaintingStyle.fill);
    
    // Draw electrical spark effect
    _drawSparkEffect(canvas, Offset(pulseX, pulseY), progress);
  }

  double _getQuadraticY(double x0, double y0, double x1, double y1, 
                        double x2, double y2, double t) {
    final mt = 1 - t;
    return mt * mt * y0 + 2 * mt * t * y1 + t * t * y2;
  }

  void _drawTower(Canvas canvas, Size size, double x) {
    final towerPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final towerX = x == 0 ? 20.0 : size.width - 20;
    final towerBottom = size.height * 0.8;
    final towerTop = size.height * 0.2;
    
    // Draw tower pole
    canvas.drawLine(
      Offset(towerX, towerBottom),
      Offset(towerX, towerTop),
      towerPaint,
    );
    
    // Draw cross beams
    canvas.drawLine(
      Offset(towerX - 15, towerTop + 10),
      Offset(towerX + 15, towerTop + 10),
      towerPaint,
    );
    
    // Draw support struts
    canvas.drawLine(
      Offset(towerX - 10, towerBottom),
      Offset(towerX, towerTop + 20),
      towerPaint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(towerX + 10, towerBottom),
      Offset(towerX, towerTop + 20),
      towerPaint,
    );
  }

  void _drawSparkEffect(Canvas canvas, Offset center, double progress) {
    final sparkPaint = Paint()
      ..color = pulseColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Create random number generator based on progress for consistent animation
    final sparkSeed = (progress * 1000).toInt();
    final random = math.Random(sparkSeed);
    
    // Draw electrical sparks around the pulse
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (progress * math.pi * 2);
      final sparkLength = 8 + (6 * math.sin(progress * math.pi * 4 + i));
      
      // Create lightning-like path
      final sparkPath = Path();
      sparkPath.moveTo(center.dx, center.dy);
      
      var currentX = center.dx;
      var currentY = center.dy;
      final segments = 3;
      
      for (int j = 0; j < segments; j++) {
        final segmentLength = sparkLength / segments;
        final deviation = (random.nextDouble() - 0.5) * 4;
        
        currentX += segmentLength * math.cos(angle) + deviation;
        currentY += segmentLength * math.sin(angle) + deviation;
        
        sparkPath.lineTo(currentX, currentY);
      }
      
      // Fade sparks based on progress
      final sparkOpacity = 0.8 + 0.2 * math.sin(progress * math.pi * 8 + i);
      sparkPaint.color = pulseColor.withOpacity(sparkOpacity);
      
      canvas.drawPath(sparkPath, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PowerLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}