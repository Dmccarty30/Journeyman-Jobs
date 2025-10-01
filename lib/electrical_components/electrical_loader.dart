import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Electrical-themed loading animation widget
/// 
/// Displays an animated lightning bolt or electrical circuit pattern
/// to indicate loading state, matching the app's electrical theme
class ElectricalLoader extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  
  const ElectricalLoader({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFFB45309), // Copper color
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ElectricalLoader> createState() => _ElectricalLoaderState();
}

class _ElectricalLoaderState extends State<ElectricalLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
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
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _LightningBoltPainter(
                  color: widget.color,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LightningBoltPainter extends CustomPainter {
  final Color color;
  final double progress;

  _LightningBoltPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw a stylized lightning bolt
    final path = Path();
    
    // Lightning bolt shape
    path.moveTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.3, size.height * 0.45);
    path.lineTo(size.width * 0.5, size.height * 0.45);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(size.width * 0.7, size.height * 0.55);
    path.lineTo(size.width * 0.5, size.height * 0.55);
    path.close();

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Draw electrical arcs around the bolt
    _drawElectricalArcs(canvas, size, paint);
  }

  void _drawElectricalArcs(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    
    // Draw small electrical arcs
    for (int i = 0; i < 3; i++) {
      final angle = (progress * 2 * math.pi) + (i * 2 * math.pi / 3);
      final radius = size.width * 0.3;
      
      final startX = size.width / 2 + math.cos(angle) * radius;
      final startY = size.height / 2 + math.sin(angle) * radius;
      
      final arcPath = Path();
      arcPath.moveTo(startX, startY);
      
      // Create jagged arc pattern
      for (int j = 1; j <= 3; j++) {
        final t = j / 3;
        final endAngle = angle + math.pi / 6;
        final endRadius = radius * (1 - t * 0.3);
        
        final cpX = size.width / 2 + math.cos(angle + t * (endAngle - angle)) * (endRadius + 5);
        final cpY = size.height / 2 + math.sin(angle + t * (endAngle - angle)) * (endRadius + 5);
        
        final endX = size.width / 2 + math.cos(angle + t * (endAngle - angle)) * endRadius;
        final endY = size.height / 2 + math.sin(angle + t * (endAngle - angle)) * endRadius;
        
        arcPath.lineTo(cpX + (math.Random().nextDouble() - 0.5) * 4, 
                      cpY + (math.Random().nextDouble() - 0.5) * 4);
        arcPath.lineTo(endX, endY);
      }
      
      paint.color = color.withValues(alpha: 0.6 - i * 0.2);
      canvas.drawPath(arcPath, paint);
    }
  }

  @override
  bool shouldRepaint(_LightningBoltPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}