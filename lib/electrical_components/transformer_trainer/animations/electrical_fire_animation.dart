import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dramatic electrical fire animation for incorrect connections
class ElectricalFireAnimation extends StatefulWidget {
  
  const ElectricalFireAnimation({
    super.key,
    this.onAnimationComplete,
    this.autoStart = true,
  });
  final VoidCallback? onAnimationComplete;
  final bool autoStart;

  @override
  State<ElectricalFireAnimation> createState() => _ElectricalFireAnimationState();
}

class _ElectricalFireAnimationState extends State<ElectricalFireAnimation>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _fireController;
  late AnimationController _sparkController;
  late AnimationController _smokeController;
  late AnimationController _shakeController;
  
  late Animation<double> _explosionScale;
  late Animation<double> _explosionOpacity;
  late Animation<double> _fireFlicker;
  late Animation<double> _sparkAnimation;
  late Animation<double> _smokeRise;
  late Animation<double> _shakeAnimation;
  
  final List<FireParticle> _fireParticles = <FireParticle>[];
  final List<SparkParticle> _sparkParticles = <SparkParticle>[];
  final List<SmokeParticle> _smokeParticles = <SmokeParticle>[];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    
    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _initializeAnimations() {
    // Explosion animation (0.5 seconds)
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _explosionScale = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _explosionController,
      curve: Curves.easeOutCubic,
    ),);
    _explosionOpacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _explosionController,
      curve: const Interval(0.5, 1, curve: Curves.easeOut),
    ),);

    // Fire animation (3 seconds with repeat)
    _fireController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fireFlicker = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.easeInOut,
    ),);

    // Spark animation (1 second)
    _sparkController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _sparkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _sparkController,
      curve: Curves.easeOutQuart,
    ),);

    // Smoke animation (4 seconds)
    _smokeController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _smokeRise = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _smokeController,
      curve: Curves.easeInOut,
    ),);

    // Shake animation (0.3 seconds)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ),);
  }

  void _generateParticles() {
    // Generate fire particles
    for (int i = 0; i < 15; i++) {
      _fireParticles.add(FireParticle(
        position: Offset(
          _random.nextDouble() * 200 - 100,
          _random.nextDouble() * 100 - 50,
        ),
        velocity: Offset(
          _random.nextDouble() * 4 - 2,
          -_random.nextDouble() * 3 - 2,
        ),
        size: _random.nextDouble() * 20 + 10,
        lifespan: _random.nextDouble() * 2 + 1,
        color: _getFireColor(),
      ),);
    }

    // Generate spark particles
    for (int i = 0; i < 30; i++) {
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double speed = _random.nextDouble() * 300 + 100;
      _sparkParticles.add(SparkParticle(
        position: Offset.zero,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        size: _random.nextDouble() * 3 + 1,
        lifespan: _random.nextDouble() * 1.5 + 0.5,
        trail: <Offset>[],
      ),);
    }

    // Generate smoke particles
    for (int i = 0; i < 8; i++) {
      _smokeParticles.add(SmokeParticle(
        position: Offset(
          _random.nextDouble() * 100 - 50,
          _random.nextDouble() * 50,
        ),
        velocity: Offset(
          _random.nextDouble() * 2 - 1,
          -_random.nextDouble() * 2 - 1,
        ),
        size: _random.nextDouble() * 40 + 20,
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ),);
    }
  }

  Color _getFireColor() {
    final List<Color> colors = <Color>[
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.white,
      const Color(0xFFFF6B35),
      const Color(0xFFF77825),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  Future<void> _startAnimation() async {
    // Start shake first
    _shakeController.forward();
    
    // Start explosion
    _explosionController.forward();
    
    // Start sparks
    await Future.delayed(const Duration(milliseconds: 100));
    _sparkController.forward();
    
    // Start fire
    await Future.delayed(const Duration(milliseconds: 200));
    _fireController.repeat(reverse: true);
    
    // Start smoke
    await Future.delayed(const Duration(milliseconds: 300));
    _smokeController.forward();
    
    // Complete animation after 4 seconds
    await Future.delayed(const Duration(seconds: 4));
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _fireController.dispose();
    _sparkController.dispose();
    _smokeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[
        _explosionController,
        _fireController,
        _sparkController,
        _smokeController,
        _shakeController,
      ]),
      builder: (BuildContext context, Widget? child) => Transform.translate(
          offset: Offset(
            math.sin(_shakeController.value * 2 * math.pi) * _shakeAnimation.value,
            math.cos(_shakeController.value * 2 * math.pi) * _shakeAnimation.value * 0.5,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Explosion flash
              if (_explosionController.isAnimating)
                Transform.scale(
                  scale: _explosionScale.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          Colors.white.withValues(alpha: _explosionOpacity.value),
                          Colors.yellow.withValues(alpha: _explosionOpacity.value * 0.8),
                          Colors.orange.withValues(alpha: _explosionOpacity.value * 0.5),
                          Colors.red.withValues(alpha: _explosionOpacity.value * 0.3),
                          Colors.transparent,
                        ],
                        stops: const <double>[0, 0.2, 0.4, 0.6, 1],
                      ),
                    ),
                  ),
                ),
              
              // Fire particles
              CustomPaint(
                size: const Size(400, 400),
                painter: FirePainter(
                  particles: _fireParticles,
                  progress: _fireController.value,
                  flicker: _fireFlicker.value,
                ),
              ),
              
              // Sparks
              CustomPaint(
                size: const Size(400, 400),
                painter: SparkPainter(
                  particles: _sparkParticles,
                  progress: _sparkAnimation.value,
                ),
              ),
              
              // Smoke
              CustomPaint(
                size: const Size(400, 400),
                painter: SmokePainter(
                  particles: _smokeParticles,
                  progress: _smokeRise.value,
                ),
              ),
              
              // Electric arcs
              CustomPaint(
                size: const Size(400, 400),
                painter: ElectricArcPainter(
                  progress: _explosionController.value,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
        ),
    );
}

/// Fire particle model
class FireParticle {

  FireParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifespan,
    required this.color,
  });
  Offset position;
  final Offset velocity;
  final double size;
  final double lifespan;
  final Color color;
  double age = 0;

  void update(double dt) {
    age += dt;
    position += velocity * dt * 60;
  }

  double get opacity => math.max(0, 1 - (age / lifespan));
  bool get isDead => age >= lifespan;
}

/// Spark particle model
class SparkParticle {

  SparkParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifespan,
    required this.trail,
  });
  Offset position;
  final Offset velocity;
  final double size;
  final double lifespan;
  double age = 0;
  List<Offset> trail;

  void update(double dt) {
    age += dt;
    final Offset oldPos = position;
    position += velocity * dt * math.pow(1 - age / lifespan, 2).toDouble();
    
    trail.add(oldPos);
    if (trail.length > 5) {
      trail.removeAt(0);
    }
  }

  double get opacity => math.max(0, 1 - (age / lifespan));
  bool get isDead => age >= lifespan;
}

/// Smoke particle model
class SmokeParticle {

  SmokeParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
  });
  Offset position;
  final Offset velocity;
  final double size;
  final double opacity;
  double age = 0;

  void update(double dt) {
    age += dt;
    position += velocity * dt * 30;
    position += Offset(math.sin(age * 2) * 10, -dt * 20); // Rise and wobble
  }
}

/// Fire painter
class FirePainter extends CustomPainter {

  FirePainter({
    required this.particles,
    required this.progress,
    required this.flicker,
  });
  final List<FireParticle> particles;
  final double progress;
  final double flicker;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    for (final FireParticle particle in particles) {
      particle.update(0.016); // Assuming 60 FPS
      
      if (particle.isDead) continue;
      
      final Paint paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * flicker)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(
        center + particle.position,
        particle.size * (1 + progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FirePainter oldDelegate) => true;
}

/// Spark painter
class SparkPainter extends CustomPainter {

  SparkPainter({
    required this.particles,
    required this.progress,
  });
  final List<SparkParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    for (final SparkParticle particle in particles) {
      particle.update(0.016 * progress);
      
      if (particle.isDead) continue;
      
      // Draw trail
      if (particle.trail.isNotEmpty) {
        final Path path = Path();
        path.moveTo(
          center.dx + particle.trail.first.dx,
          center.dy + particle.trail.first.dy,
        );
        
        for (final Offset point in particle.trail) {
          path.lineTo(center.dx + point.dx, center.dy + point.dy);
        }
        
        final Paint trailPaint = Paint()
          ..color = Colors.yellow.withValues(alpha: particle.opacity * 0.5)
          ..strokeWidth = particle.size * 0.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        
        canvas.drawPath(path, trailPaint);
      }
      
      // Draw spark
      final Paint paint = Paint()
        ..color = Colors.white.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        center + particle.position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SparkPainter oldDelegate) => true;
}

/// Smoke painter
class SmokePainter extends CustomPainter {

  SmokePainter({
    required this.particles,
    required this.progress,
  });
  final List<SmokeParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    for (final SmokeParticle particle in particles) {
      particle.update(0.016 * progress);
      
      final Paint paint = Paint()
        ..color = Colors.grey.withValues(alpha: particle.opacity * (1 - progress * 0.5))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          10 + particle.size * 0.5,
        );
      
      canvas.drawCircle(
        center + particle.position,
        particle.size * (1 + progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SmokePainter oldDelegate) => true;
}

/// Electric arc painter
class ElectricArcPainter extends CustomPainter {

  ElectricArcPainter({
    required this.progress,
    required this.color,
  });
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final Offset center = Offset(size.width / 2, size.height / 2);
    final math.Random random = math.Random(42); // Seeded for consistency
    
    final Paint paint = Paint()
      ..color = color.withValues(alpha: progress)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw multiple electric arcs
    for (int i = 0; i < 5; i++) {
      final double startAngle = random.nextDouble() * 2 * math.pi;
      final double endAngle = startAngle + random.nextDouble() * math.pi;
      final double radius = 50 + random.nextDouble() * 100;
      
      final Path path = Path();
      const int segments = 8;
      
      for (int j = 0; j <= segments; j++) {
        final double t = j / segments;
        final double angle = startAngle + (endAngle - startAngle) * t;
        final double jitter = random.nextDouble() * 20 - 10;
        final double r = radius + jitter;
        
        final Offset point = center + Offset(
          math.cos(angle) * r * progress,
          math.sin(angle) * r * progress,
        );
        
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ElectricArcPainter oldDelegate) => progress != oldDelegate.progress;
}