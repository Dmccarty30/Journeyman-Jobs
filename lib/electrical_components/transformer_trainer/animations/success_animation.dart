
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Enhanced success animation widget for correct connections
class SuccessAnimationWidget extends StatefulWidget {

  const SuccessAnimationWidget({
    required this.controller, required this.child, super.key,
    this.enhanced = true,
  });
  final AnimationController controller;
  final Widget child;
  final bool enhanced;

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ),);
    
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.elasticOut,
    ),);
    
    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeInOut,
    ),);
    
    if (widget.enhanced) {
      _rotationController.repeat();
    }
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[widget.controller, _rotationController]),
      builder: (BuildContext context, _) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Rotating success rays (enhanced mode)
            if (widget.enhanced)
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: SuccessRaysPainter(
                    progress: widget.controller.value,
                    color: Colors.green,
                  ),
                ),
              ),
            
            // Main content with scale and glow
            Transform.scale(
              scale: _scaleAnimation.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    // Primary glow
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.5 * _glowAnimation.value),
                      spreadRadius: 15 * _glowAnimation.value,
                      blurRadius: 20 * _glowAnimation.value,
                    ),
                    // Secondary glow (enhanced)
                    if (widget.enhanced)
                      BoxShadow(
                        color: Colors.lightGreen.withValues(alpha: 0.3 * _glowAnimation.value),
                        spreadRadius: 25 * _glowAnimation.value,
                        blurRadius: 30 * _glowAnimation.value,
                      ),
                  ],
                ),
                child: widget.child,
              ),
            ),
            
            // Success particles (enhanced mode)
            if (widget.enhanced)
              CustomPaint(
                size: const Size(300, 300),
                painter: SuccessParticlesPainter(
                  progress: widget.controller.value,
                ),
              ),
          ],
        ),
    );
}

/// Enhanced pulse animation for highlighting correct connections
class PulseAnimationWidget extends StatefulWidget {

  const PulseAnimationWidget({
    required this.controller, required this.child, super.key,
    this.color = Colors.green,
    this.enhanced = true,
  });
  final AnimationController controller;
  final Widget child;
  final Color color;
  final bool enhanced;

  @override
  State<PulseAnimationWidget> createState() => _PulseAnimationWidgetState();
}

class _PulseAnimationWidgetState extends State<PulseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ),);
    
    if (widget.enhanced) {
      _waveController.repeat();
    }
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[widget.controller, _waveController]),
      builder: (BuildContext context, _) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Multiple pulse waves (enhanced mode)
            if (widget.enhanced)
              ...List.generate(3, (int index) {
                final double delay = index * 0.3;
                final double progress = (_waveAnimation.value - delay).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 1.0 + progress * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withValues(alpha: (1 - progress) * 0.5),
                        width: 3,
                      ),
                    ),
                    width: 100,
                    height: 100,
                  ),
                );
              }),
            
            // Main pulse effect
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.6 * widget.controller.value),
                    spreadRadius: widget.enhanced ? 15 : 10 * widget.controller.value,
                    blurRadius: widget.enhanced ? 25 : 20 * widget.controller.value,
                  ),
                  // Extra glow layer for enhanced mode
                  if (widget.enhanced)
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3 * widget.controller.value),
                      spreadRadius: 30 * widget.controller.value,
                      blurRadius: 40 * widget.controller.value,
                    ),
                ],
              ),
              child: widget.child,
            ),
            
            // Success check mark overlay (enhanced mode)
            if (widget.enhanced && widget.controller.value > 0.5)
              Opacity(
                opacity: (widget.controller.value - 0.5) * 2,
                child: Icon(
                  Icons.check_circle,
                  color: widget.color,
                  size: 40,
                ),
              ),
          ],
        ),
    );
}

/// Custom painter for success rays
class SuccessRaysPainter extends CustomPainter {

  SuccessRaysPainter({
    required this.progress,
    required this.color,
  });
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    const int rayCount = 12;
    
    for (int i = 0; i < rayCount; i++) {
      final double angle = (i / rayCount) * 2 * math.pi;
      const double innerRadius = 30;
      final double outerRadius = 100.0 * progress;
      
      final Offset innerPoint = center + Offset(
        math.cos(angle) * innerRadius,
        math.sin(angle) * innerRadius,
      );
      
      final Offset outerPoint = center + Offset(
        math.cos(angle) * outerRadius,
        math.sin(angle) * outerRadius,
      );
      
      final Paint paint = Paint()
        ..shader = ui.Gradient.linear(
          innerPoint,
          outerPoint,
          <Color>[
            color.withValues(alpha: 0.8 * progress),
            color.withValues(alpha: 0),
          ],
        )
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  @override
  bool shouldRepaint(SuccessRaysPainter oldDelegate) => progress != oldDelegate.progress || color != oldDelegate.color;
}

/// Custom painter for success particles
class SuccessParticlesPainter extends CustomPainter {

  SuccessParticlesPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final math.Random random = math.Random(42);
    const int particleCount = 20;
    
    for (int i = 0; i < particleCount; i++) {
      final double angle = random.nextDouble() * 2 * math.pi;
      final double distance = 50 + random.nextDouble() * 100;
      final double particleProgress = (progress * 2 - i / particleCount).clamp(0.0, 1.0);
      
      if (particleProgress > 0) {
        final Offset position = center + Offset(
          math.cos(angle) * distance * particleProgress,
          math.sin(angle) * distance * particleProgress,
        );
        
        final Paint paint = Paint()
          ..color = Colors.lightGreen.withValues(alpha: 1 - particleProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        // Draw star-shaped particle
        _drawStar(canvas, position, 5 * (1 - particleProgress * 0.5), paint);
      }
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final Path path = Path();
    const int points = 5;
    
    for (int i = 0; i < points * 2; i++) {
      final double angle = (i / (points * 2)) * 2 * math.pi - math.pi / 2;
      final double r = i.isEven ? radius : radius * 0.5;
      final Offset point = center + Offset(
        math.cos(angle) * r,
        math.sin(angle) * r,
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SuccessParticlesPainter oldDelegate) => progress != oldDelegate.progress;
}
