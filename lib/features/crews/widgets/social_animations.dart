import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../design_system/app_theme.dart';

/// Core animation utilities and constants for social interactions
class SocialAnimations {
  // Animation durations
  static const Duration likeAnimationDuration = Duration(milliseconds: 400);
  static const Duration reactionAnimationDuration = Duration(milliseconds: 500);
  static const Duration commentAnimationDuration = Duration(milliseconds: 350);
  static const Duration particleAnimationDuration = Duration(milliseconds: 600);
  static const Duration typingAnimationDuration = Duration(milliseconds: 1000);
  static const Duration pullToRefreshDuration = Duration(milliseconds: 500);
  
  // Animation curves
  static const Curve likeCurve = Curves.easeOutBack;
  static const Curve reactionCurve = Curves.elasticOut;
  static const Curve commentCurve = Curves.easeInOutCubic;
  static const Curve particleCurve = Curves.easeOutCubic;
  static const Curve typingCurve = Curves.easeInOut;
  
  // Social animation colors
  static Color get likeColor => AppTheme.errorRed;
  static Color get likeColorStart => AppTheme.mediumGray;
  static Color get likeColorTransition => AppTheme.accentCopper;
  static Color get reactionGlowColor => AppTheme.accentCopper.withValues(alpha: 0.6);
  static Color get particleCopperColor => AppTheme.accentCopper;
  static Color get particleGoldColor => AppTheme.secondaryCopper;
  static Color get commentBorderColor => AppTheme.accentCopper;
  
  // Particle system for effects
  static List<Particle> generateParticles({
    required int count,
    required Size area,
    required Color color,
    double minSize = 2.0,
    double maxSize = 6.0,
  }) {
    final random = math.Random();
    return List.generate(count, (index) {
      return Particle(
        position: Offset(
          random.nextDouble() * area.width,
          random.nextDouble() * area.height,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 4,
          (random.nextDouble() - 0.5) * 4 - 2,
        ),
        size: minSize + random.nextDouble() * (maxSize - minSize),
        color: color,
        lifetime: particleAnimationDuration,
        fadeOutAfter: Duration(milliseconds: random.nextInt(300) + 200),
      );
    });
  }
}

/// Particle class for particle effects
class Particle {
  final Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final Duration lifetime;
  final Duration fadeOutAfter;
  
  const Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifetime,
    required this.fadeOutAfter,
  });
  
  Particle update(Duration elapsed) {
    final newPosition = Offset(
      position.dx + velocity.dx,
      position.dy + velocity.dy + (elapsed.inMilliseconds * 0.001),
    );
    
    return Particle(
      position: newPosition,
      velocity: velocity * 0.98, // Air resistance
      size: size * 0.99, // Slight shrinkage
      color: color,
      lifetime: lifetime - elapsed,
      fadeOutAfter: fadeOutAfter - elapsed,
    );
  }
}

/// Animated particle widget
/// Animated particle widget
class AnimatedParticle extends StatelessWidget {
  final Particle particle;
  final double progress;
  
  const AnimatedParticle({
    super.key,
    required this.particle,
    required this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    final opacity = particle.fadeOutAfter.inMilliseconds > 0
        ? (particle.fadeOutAfter.inMilliseconds / SocialAnimations.particleAnimationDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    
    return Positioned(
      left: particle.position.dx,
      top: particle.position.dy,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SocialAnimations.particleCopperColor.withValues(alpha: 0.5),
                blurRadius: particle.size * 0.5,
                spreadRadius: particle.size * 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// Animated heart widget with electrical theme
class AnimatedHeart extends StatelessWidget {
  final double scale;
  final Color color;
  final double opacity;
  final bool showGlow;
  
  const AnimatedHeart({
    super.key,
    required this.scale,
    this.color = Colors.red,
    this.opacity = 1.0,
    this.showGlow = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: SocialAnimations.likeAnimationDuration,
      curve: SocialAnimations.likeCurve,
      child: AnimatedContainer(
        duration: SocialAnimations.likeAnimationDuration,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: SocialAnimations.reactionGlowColor,
                    blurRadius: 20 * scale,
                    spreadRadius: 10 * scale,
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.favorite,
          color: color.withValues(alpha: opacity),
          size: 28,
        ),
      ),
    );
  }
}

/// Typing indicator widget
class TypingIndicator extends StatefulWidget {
  final int dotCount;
  final Color color;
  final double size;
  
  const TypingIndicator({
    super.key,
    this.dotCount = 3,
    this.color = Colors.grey,
    this.size = 8.0,
  });
  
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SocialAnimations.typingAnimationDuration,
      vsync: this,
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.dotCount, (index) {
            final animationValue = math.sin(
              (_controller.value * 2 * math.pi) + (index * math.pi / 4),
            );
            final opacity = (animationValue + 1) / 2;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

/// Electrical arc animation for pull-to-refresh
class ElectricalArc extends StatelessWidget {
  final Animation<double> animation;
  final Color arcColor;
  final double strokeWidth;
  
  const ElectricalArc({
    super.key,
    required this.animation,
    this.arcColor = Colors.cyan,
    this.strokeWidth = 2.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ElectricalArcPainter(
            progress: animation.value,
            arcColor: arcColor,
            strokeWidth: strokeWidth,
          ),
        );
      },
    );
  }
}

/// Custom painter for electrical arc effect
class ElectricalArcPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final double strokeWidth;
  
  const ElectricalArcPainter({
    required this.progress,
    required this.arcColor,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arcColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Create electrical arc effect
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // Draw main arc
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
    );
    
    canvas.drawPath(path, paint);
    
    // Add electrical sparks
    if (progress > 0.5) {
      final sparkPaint = Paint()
        ..color = arcColor.withValues(alpha: 0.7)
        ..strokeWidth = strokeWidth * 0.5
        ..style = PaintingStyle.stroke;
      
      // Random spark positions
      for (int i = 0; i < 5; i++) {
        final angle = math.pi * 2 * (progress + i * 0.2);
        final sparkStart = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        final sparkEnd = Offset(
          sparkStart.dx + (math.Random().nextDouble() - 0.5) * 20,
          sparkStart.dy + (math.Random().nextDouble() - 0.5) * 20,
        );
        
        canvas.drawLine(sparkStart, sparkEnd, sparkPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(ElectricalArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}