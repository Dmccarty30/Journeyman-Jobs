import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// Electrical-themed page transitions with lightning and spark effects
class JJElectricalPageTransitions {
  
  /// Lightning strike transition - dramatic entrance with electrical bolts
  static PageRouteBuilder<T> lightningTransition<T>({
    required Widget child,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Lightning entrance effect
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LightningTransitionPainter(
                    progress: animation.value,
                    isReverse: false,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
            
            // Page content with fade and scale
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final scaleValue = 0.8 + (animation.value * 0.2);
                final fadeValue = animation.value;
                
                return Transform.scale(
                  scale: scaleValue,
                  child: Opacity(
                    opacity: fadeValue,
                    child: child,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  /// Circuit slide transition - slides in like connecting electrical circuits
  static PageRouteBuilder<T> circuitSlideTransition<T>({
    required Widget child,
    required RouteSettings settings,
    SlideDirection direction = SlideDirection.fromRight,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: _getSlideOffset(direction),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));
        
        return Stack(
          children: [
            // Circuit connection animation
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CircuitConnectionPainter(
                    progress: animation.value,
                    direction: direction,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
            
            // Sliding content
            SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          ],
        );
      },
    );
  }
  
  /// Spark reveal transition - page appears with electrical sparks
  static PageRouteBuilder<T> sparkRevealTransition<T>({
    required Widget child,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Spark effects
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SparkRevealPainter(
                    progress: animation.value,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
            
            // Revealing content with circular mask
            ClipPath(
              clipper: _CircularRevealClipper(animation.value),
              child: child,
            ),
          ],
        );
      },
    );
  }
  
  /// Power surge transition - content surges into view with electrical energy
  static PageRouteBuilder<T> powerSurgeTransition<T>({
    required Widget child,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Stack(
              children: [
                // Power surge background
                CustomPaint(
                  painter: _PowerSurgePainter(
                    progress: animation.value,
                  ),
                  child: const SizedBox.expand(),
                ),
                
                // Content with electric glow
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(animation.value * 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 0.9 + (animation.value * 0.1),
                    child: Opacity(
                      opacity: animation.value,
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  static Offset _getSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
    }
  }
}

enum SlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Lightning transition painter
class _LightningTransitionPainter extends CustomPainter {
  final double progress;
  final bool isReverse;
  
  _LightningTransitionPainter({
    required this.progress,
    required this.isReverse,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.4)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);
    
    // Multiple lightning bolts across screen
    final boltCount = 5;
    for (int i = 0; i < boltCount; i++) {
      final xPos = (i + 1) * size.width / (boltCount + 1);
      _drawLightningBolt(canvas, xPos, size.height, progress, paint, glowPaint);
    }
  }
  
  void _drawLightningBolt(Canvas canvas, double x, double height, double progress, Paint paint, Paint glowPaint) {
    final random = math.Random(x.toInt());
    final path = Path();
    
    final segments = 6;
    final segmentHeight = height / segments;
    var currentX = x;
    var currentY = 0.0;
    
    path.moveTo(currentX, currentY);
    
    for (int i = 1; i <= segments; i++) {
      final targetY = i * segmentHeight * progress;
      final zigzagAmount = (random.nextDouble() - 0.5) * 40;
      currentX += zigzagAmount;
      
      path.lineTo(currentX, targetY);
      
      if (targetY >= height * progress) break;
    }
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _LightningTransitionPainter ||
        oldDelegate.progress != progress;
  }
}

/// Circuit connection painter
class _CircuitConnectionPainter extends CustomPainter {
  final double progress;
  final SlideDirection direction;
  
  _CircuitConnectionPainter({
    required this.progress,
    required this.direction,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final paint = Paint()
      ..color = AppTheme.accentCopper.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
    
    // Draw connecting circuits based on slide direction
    switch (direction) {
      case SlideDirection.fromRight:
        _drawHorizontalCircuits(canvas, size, progress, paint, glowPaint, true);
        break;
      case SlideDirection.fromLeft:
        _drawHorizontalCircuits(canvas, size, progress, paint, glowPaint, false);
        break;
      case SlideDirection.fromTop:
        _drawVerticalCircuits(canvas, size, progress, paint, glowPaint, false);
        break;
      case SlideDirection.fromBottom:
        _drawVerticalCircuits(canvas, size, progress, paint, glowPaint, true);
        break;
    }
  }
  
  void _drawHorizontalCircuits(Canvas canvas, Size size, double progress, Paint paint, Paint glowPaint, bool fromRight) {
    final traceCount = 4;
    for (int i = 0; i < traceCount; i++) {
      final y = (i + 1) * size.height / (traceCount + 1);
      final startX = fromRight ? size.width * (1 - progress) : 0;
      final endX = fromRight ? size.width : size.width * progress;
      
      final path = Path();
      path.moveTo(startX.toDouble(), y);
      path.lineTo(endX, y);
      
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
      
      // Connection points
      if (progress > 0.5) {
        canvas.drawCircle(Offset(endX, y), 3, paint..style = PaintingStyle.fill);
      }
    }
  }
  
  void _drawVerticalCircuits(Canvas canvas, Size size, double progress, Paint paint, Paint glowPaint, bool fromBottom) {
    final traceCount = 4;
    for (int i = 0; i < traceCount; i++) {
      final x = (i + 1) * size.width / (traceCount + 1);
      final startY = fromBottom ? size.height * (1 - progress) : 0;
      final endY = fromBottom ? size.height : size.height * progress;
      
      final path = Path();
      path.moveTo(x, startY.toDouble());
      path.lineTo(x, endY);
      
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
      
      // Connection points
      if (progress > 0.5) {
        canvas.drawCircle(Offset(x, endY), 3, paint..style = PaintingStyle.fill);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CircuitConnectionPainter ||
        oldDelegate.progress != progress;
  }
}

/// Spark reveal painter
class _SparkRevealPainter extends CustomPainter {
  final double progress;
  
  _SparkRevealPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final currentRadius = progress * maxRadius;
    
    final sparkPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Create sparks around the reveal circle
    final sparkCount = 16;
    final random = math.Random(42);
    
    for (int i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * math.pi * 2;
      final sparkDistance = currentRadius + random.nextDouble() * 20;
      final sparkX = center.dx + math.cos(angle) * sparkDistance;
      final sparkY = center.dy + math.sin(angle) * sparkDistance;
      
      final sparkSize = (1.0 - progress) * 5 * (0.5 + random.nextDouble());
      canvas.drawCircle(Offset(sparkX, sparkY), sparkSize, sparkPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _SparkRevealPainter ||
        oldDelegate.progress != progress;
  }
}

/// Circular reveal clipper
class _CircularRevealClipper extends CustomClipper<Path> {
  final double progress;
  
  _CircularRevealClipper(this.progress);
  
  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final currentRadius = progress * maxRadius;
    
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: currentRadius));
    return path;
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is! _CircularRevealClipper ||
        oldClipper.progress != progress;
  }
}

/// Power surge painter
class _PowerSurgePainter extends CustomPainter {
  final double progress;
  
  _PowerSurgePainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    // Electric field effect
    final fieldPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.1 * progress)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Offset.zero & size, fieldPaint);
    
    // Energy waves
    final wavePaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.3 * (1 - progress))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + i * 0.3) % 1.0;
      final waveRadius = waveProgress * size.width;
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        waveRadius,
        wavePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _PowerSurgePainter ||
        oldDelegate.progress != progress;
  }
}

/// Extension to easily apply electrical transitions to PageRoutes
extension ElectricalTransitionExtension on Widget {
  PageRouteBuilder<T> withLightningTransition<T>(RouteSettings settings) {
    return JJElectricalPageTransitions.lightningTransition<T>(
      child: this,
      settings: settings,
    );
  }
  
  PageRouteBuilder<T> withCircuitSlideTransition<T>(
    RouteSettings settings, {
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    return JJElectricalPageTransitions.circuitSlideTransition<T>(
      child: this,
      settings: settings,
      direction: direction,
    );
  }
  
  PageRouteBuilder<T> withSparkRevealTransition<T>(RouteSettings settings) {
    return JJElectricalPageTransitions.sparkRevealTransition<T>(
      child: this,
      settings: settings,
    );
  }
  
  PageRouteBuilder<T> withPowerSurgeTransition<T>(RouteSettings settings) {
    return JJElectricalPageTransitions.powerSurgeTransition<T>(
      child: this,
      settings: settings,
    );
  }
}