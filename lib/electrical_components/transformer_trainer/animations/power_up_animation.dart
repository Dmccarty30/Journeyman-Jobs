import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Smooth power-up animation for correct connections
class PowerUpAnimation extends StatefulWidget {
  
  const PowerUpAnimation({
    super.key,
    this.onAnimationComplete,
    this.autoStart = true,
    this.connectionPoints = const <Offset>[],
  });
  final VoidCallback? onAnimationComplete;
  final bool autoStart;
  final List<Offset> connectionPoints;

  @override
  State<PowerUpAnimation> createState() => _PowerUpAnimationState();
}

class _PowerUpAnimationState extends State<PowerUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _meterController;
  
  late Animation<double> _powerFlowAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _meterAnimation;
  late Animation<Color?> _colorAnimation;
  
  final List<EnergyParticle> _energyParticles = <EnergyParticle>[];
  final List<ElectricFlow> _electricFlows = <ElectricFlow>[];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _generateElectricFlows();
    
    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _initializeAnimations() {
    // Main power flow animation (2 seconds)
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _powerFlowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ),);
    
    // Color animation from blue to green
    _colorAnimation = ColorTween(
      begin: Colors.blue.shade400,
      end: Colors.green.shade400,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ),);

    // Glow animation (continuous)
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ),);

    // Pulse animation for energy effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ),);

    // Meter animation (gauges)
    _meterController = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );
    _meterAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _meterController,
      curve: Curves.easeOutCubic,
    ),);
  }

  void _generateParticles() {
    // Generate energy particles
    for (int i = 0; i < 20; i++) {
      _energyParticles.add(EnergyParticle(
        position: Offset(
          _random.nextDouble() * 400 - 200,
          _random.nextDouble() * 400 - 200,
        ),
        velocity: Offset(
          _random.nextDouble() * 2 - 1,
          _random.nextDouble() * 2 - 1,
        ),
        size: _random.nextDouble() * 3 + 1,
        color: Colors.cyan.withOpacity(0.8),
        phase: _random.nextDouble() * 2 * math.pi,
      ),);
    }
  }

  void _generateElectricFlows() {
    // Generate flowing electricity paths
    if (widget.connectionPoints.length >= 2) {
      for (int i = 0; i < widget.connectionPoints.length - 1; i++) {
        _electricFlows.add(ElectricFlow(
          start: widget.connectionPoints[i],
          end: widget.connectionPoints[i + 1],
          segments: 20,
        ),);
      }
    } else {
      // Default flow paths if no connection points provided
      _electricFlows.add(ElectricFlow(
        start: const Offset(-100, 0),
        end: const Offset(100, 0),
        segments: 20,
      ),);
      _electricFlows.add(ElectricFlow(
        start: const Offset(0, -100),
        end: const Offset(0, 100),
        segments: 20,
      ),);
    }
  }

  Future<void> _startAnimation() async {
    // Start main power flow
    _mainController.forward();
    
    // Start glow effect
    _glowController.repeat(reverse: true);
    
    // Start pulse effect
    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);
    
    // Start particles
    _particleController.repeat();
    
    // Start meter animation
    await Future.delayed(const Duration(milliseconds: 300));
    _meterController.forward();
    
    // Complete animation after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _meterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[
        _mainController,
        _glowController,
        _pulseController,
        _particleController,
        _meterController,
      ]),
      builder: (BuildContext context, Widget? child) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Background glow effect
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      (_colorAnimation.value ?? Colors.blue)
                          .withOpacity(0.3 * _glowAnimation.value),
                      (_colorAnimation.value ?? Colors.blue)
                          .withOpacity(0.1 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                    stops: const <double>[0, 0.5, 1],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (_colorAnimation.value ?? Colors.blue)
                          .withOpacity(0.5 * _glowAnimation.value),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            // Electric flow lines
            CustomPaint(
              size: const Size(400, 400),
              painter: ElectricFlowPainter(
                flows: _electricFlows,
                progress: _powerFlowAnimation.value,
                color: _colorAnimation.value ?? Colors.blue,
                glowIntensity: _glowAnimation.value,
              ),
            ),
            
            // Energy particles
            CustomPaint(
              size: const Size(400, 400),
              painter: EnergyParticlePainter(
                particles: _energyParticles,
                progress: _particleAnimation.value,
                powerLevel: _powerFlowAnimation.value,
              ),
            ),
            
            // Transformer core glow
            if (_mainController.value > 0.3)
              CustomPaint(
                size: const Size(200, 200),
                painter: TransformerCorePainter(
                  progress: _powerFlowAnimation.value,
                  glowColor: _colorAnimation.value ?? Colors.blue,
                  pulseValue: _pulseAnimation.value,
                ),
              ),
            
            // Power meters/gauges
            Positioned(
              top: 20,
              right: 20,
              child: CustomPaint(
                size: const Size(80, 80),
                painter: PowerMeterPainter(
                  value: _meterAnimation.value,
                  label: 'VOLTAGE',
                  color: Colors.green,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: CustomPaint(
                size: const Size(80, 80),
                painter: PowerMeterPainter(
                  value: _meterAnimation.value * 0.8,
                  label: 'CURRENT',
                  color: Colors.blue,
                ),
              ),
            ),
            
            // Success indicator
            if (_mainController.value >= 1.0)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
          ],
        ),
    );
}

/// Energy particle model
class EnergyParticle {

  EnergyParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.phase,
  });
  Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final double phase;

  void update(double dt, double powerLevel) {
    // Particles move in circular patterns with power influence
    final double angle = phase + dt * 2 * math.pi;
    final double radius = 50 * powerLevel;
    position += velocity * dt * 30;
    position += Offset(
      math.cos(angle) * radius * dt,
      math.sin(angle) * radius * dt,
    );
    
    // Wrap around
    if (position.dx > 200) position = Offset(-200, position.dy);
    if (position.dx < -200) position = Offset(200, position.dy);
    if (position.dy > 200) position = Offset(position.dx, -200);
    if (position.dy < -200) position = Offset(position.dx, 200);
  }
}

/// Electric flow path model
class ElectricFlow {

  ElectricFlow({
    required this.start,
    required this.end,
    required this.segments,
  }) {
    final math.Random random = math.Random();
    for (int i = 0; i < segments; i++) {
      segmentPhases.add(random.nextDouble() * 2 * math.pi);
    }
  }
  final Offset start;
  final Offset end;
  final int segments;
  final List<double> segmentPhases = <double>[];
}

/// Electric flow painter
class ElectricFlowPainter extends CustomPainter {

  ElectricFlowPainter({
    required this.flows,
    required this.progress,
    required this.color,
    required this.glowIntensity,
  });
  final List<ElectricFlow> flows;
  final double progress;
  final Color color;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    for (final ElectricFlow flow in flows) {
      _drawElectricFlow(canvas, center, flow);
    }
  }

  void _drawElectricFlow(Canvas canvas, Offset center, ElectricFlow flow) {
    final Path path = Path();
    final Offset flowStart = center + flow.start;
    final Offset flowEnd = center + flow.end;
    
    path.moveTo(flowStart.dx, flowStart.dy);
    
    // Create animated electric path with jitter
    for (int i = 0; i <= flow.segments; i++) {
      final double t = i / flow.segments;
      final Offset basePoint = Offset.lerp(flowStart, flowEnd, t)!;
      final double phase = flow.segmentPhases[i % flow.segmentPhases.length];
      final double jitter = math.sin(phase + progress * 4 * math.pi) * 5 * glowIntensity;
      
      final double perpendicular = (flowEnd - flowStart).direction + math.pi / 2;
      final Offset jitterOffset = Offset(
        math.cos(perpendicular) * jitter,
        math.sin(perpendicular) * jitter,
      );
      
      path.lineTo(
        basePoint.dx + jitterOffset.dx,
        basePoint.dy + jitterOffset.dy,
      );
    }
    
    // Main flow line
    final Paint mainPaint = Paint()
      ..color = color.withOpacity(0.8 * progress)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(path, mainPaint);
    
    // Glow effect
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.3 * progress * glowIntensity)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawPath(path, glowPaint);
    
    // Traveling light effect
    if (progress > 0) {
      final Offset lightPosition = Offset.lerp(
        flowStart,
        flowEnd,
        (progress * 3) % 1.0,
      )!;
      
      final Paint lightPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(lightPosition, 5, lightPaint);
    }
  }

  @override
  bool shouldRepaint(ElectricFlowPainter oldDelegate) => true;
}

/// Energy particle painter
class EnergyParticlePainter extends CustomPainter {

  EnergyParticlePainter({
    required this.particles,
    required this.progress,
    required this.powerLevel,
  });
  final List<EnergyParticle> particles;
  final double progress;
  final double powerLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    for (final EnergyParticle particle in particles) {
      particle.update(0.016, powerLevel);
      
      final Paint paint = Paint()
        ..color = particle.color.withOpacity(powerLevel * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        center + particle.position,
        particle.size * (1 + powerLevel * 0.5),
        paint,
      );
      
      // Draw particle trail
      final Paint trailPaint = Paint()
        ..color = particle.color.withOpacity(powerLevel * 0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        center + particle.position,
        center + particle.position - (particle.velocity * 10),
        trailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(EnergyParticlePainter oldDelegate) => true;
}

/// Transformer core painter
class TransformerCorePainter extends CustomPainter {

  TransformerCorePainter({
    required this.progress,
    required this.glowColor,
    required this.pulseValue,
  });
  final double progress;
  final Color glowColor;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    // Draw transformer core with pulsing glow
    final Paint corePaint = Paint()
      ..color = glowColor.withOpacity(0.3 * progress)
      ..style = PaintingStyle.fill;
    
    // Draw core rectangles (simplified transformer representation)
    final RRect coreRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: 60 * pulseValue,
        height: 80 * pulseValue,
      ),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(coreRect, corePaint);
    
    // Draw windings effect
    final Paint windingPaint = Paint()
      ..color = glowColor.withOpacity(0.6 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Primary winding
    for (int i = 0; i < 5; i++) {
      final double y = center.dy - 30 + i * 15;
      canvas.drawLine(
        Offset(center.dx - 35, y),
        Offset(center.dx - 20, y),
        windingPaint,
      );
    }
    
    // Secondary winding
    for (int i = 0; i < 5; i++) {
      final double y = center.dy - 30 + i * 15;
      canvas.drawLine(
        Offset(center.dx + 20, y),
        Offset(center.dx + 35, y),
        windingPaint,
      );
    }
    
    // Central glow
    final Paint glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        40 * pulseValue,
        <Color>[
          Colors.white.withOpacity(0.8 * progress),
          glowColor.withOpacity(0.5 * progress),
          glowColor.withOpacity(0.1 * progress),
          Colors.transparent,
        ],
        <double>[0, 0.3, 0.7, 1],
      );
    
    canvas.drawCircle(center, 40 * pulseValue, glowPaint);
  }

  @override
  bool shouldRepaint(TransformerCorePainter oldDelegate) => progress != oldDelegate.progress ||
           glowColor != oldDelegate.glowColor ||
           pulseValue != oldDelegate.pulseValue;
}

/// Power meter/gauge painter
class PowerMeterPainter extends CustomPainter {

  PowerMeterPainter({
    required this.value,
    required this.label,
    required this.color,
  });
  final double value;
  final String label;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 10;
    
    // Draw meter background
    final Paint bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Draw meter arc
    final Paint arcPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    const double startAngle = -math.pi * 0.75;
    const double sweepAngle = math.pi * 1.5;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      startAngle,
      sweepAngle * value,
      false,
      arcPaint,
    );
    
    // Draw meter needle
    final double needleAngle = startAngle + sweepAngle * value;
    final Offset needleEnd = center + Offset(
      math.cos(needleAngle) * (radius - 15),
      math.sin(needleAngle) * (radius - 15),
    );
    
    final Paint needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, needleEnd, needlePaint);
    
    // Draw center pivot
    canvas.drawCircle(center, 3, needlePaint..style = PaintingStyle.fill);
    
    // Draw label
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius - 20,
      ),
    );
    
    // Draw value
    final String valueText = '${(value * 100).toInt()}%';
    final TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: valueText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();
    valuePainter.paint(
      canvas,
      Offset(
        center.dx - valuePainter.width / 2,
        center.dy - 5,
      ),
    );
  }

  @override
  bool shouldRepaint(PowerMeterPainter oldDelegate) => value != oldDelegate.value ||
           label != oldDelegate.label ||
           color != oldDelegate.color;
}

extension on Offset {
}