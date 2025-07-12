import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Power Line Loader
/// 
/// Animates electrical transmission lines with power flowing through them.
/// Features transmission towers and animated electrical energy flowing
/// from left to right through the power lines.
/// 
/// Example usage:
/// ```dart
/// PowerLineLoader(
///   width: 300,
///   height: 80,
///   pulseColor: AppTheme.accentCopper,
///   lineColor: AppTheme.darkGray,
/// )
/// ```
class PowerLineLoader extends StatefulWidget {
  /// Width of the loader
  final double width;
  
  /// Height of the loader
  final double height;
  
  /// Duration of one complete animation cycle
  final Duration duration;
  
  /// Color of the electrical pulse/energy
  final Color pulseColor;
  
  /// Color of the transmission lines
  final Color lineColor;
  
  /// Color of the transmission towers
  final Color towerColor;
  
  /// Number of energy pulses visible at once
  final int pulseCount;

  const PowerLineLoader({
    super.key,
    this.width = 300,
    this.height = 80,
    this.duration = const Duration(seconds: 3),
    this.pulseColor = const Color(0xFFB45309), // Copper
    this.lineColor = const Color(0xFF4A5568), // Dark Gray
    this.towerColor = const Color(0xFF2D3748), // Navy
    this.pulseCount = 3,
  });

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
      CurvedAnimation(parent: _controller, curve: Curves.linear),
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
              pulseColor: widget.pulseColor,
              lineColor: widget.lineColor,
              towerColor: widget.towerColor,
              pulseCount: widget.pulseCount,
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
  final Color pulseColor;
  final Color lineColor;
  final Color towerColor;
  final int pulseCount;

  PowerLinePainter({
    required this.progress,
    required this.pulseColor,
    required this.lineColor,
    required this.towerColor,
    required this.pulseCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw transmission towers
    _drawTransmissionTowers(canvas, size);
    
    // Draw power lines
    _drawPowerLines(canvas, size);
    
    // Draw animated energy pulses
    _drawEnergyPulses(canvas, size);
  }

  void _drawTransmissionTowers(Canvas canvas, Size size) {
    final towerPaint = Paint()
      ..color = towerColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final towerSpacing = size.width / 4;
    final towerHeight = size.height * 0.7;
    final towerWidth = size.width * 0.06;
    
    // Draw 3 transmission towers
    for (int i = 0; i < 3; i++) {
      final centerX = towerSpacing + (i * towerSpacing);
      final baseY = size.height * 0.85;
      final topY = baseY - towerHeight;
      
      // Main tower pole
      canvas.drawLine(
        Offset(centerX, baseY),
        Offset(centerX, topY),
        towerPaint,
      );
      
      // Cross arms
      final armWidth = towerWidth / 2;
      final arm1Y = topY + towerHeight * 0.2;
      final arm2Y = topY + towerHeight * 0.4;
      
      // Top cross arm
      canvas.drawLine(
        Offset(centerX - armWidth, arm1Y),
        Offset(centerX + armWidth, arm1Y),
        towerPaint,
      );
      
      // Bottom cross arm
      canvas.drawLine(
        Offset(centerX - armWidth * 0.8, arm2Y),
        Offset(centerX + armWidth * 0.8, arm2Y),
        towerPaint,
      );
      
      // Support struts
      canvas.drawLine(
        Offset(centerX - armWidth * 0.3, topY),
        Offset(centerX - armWidth * 0.6, arm1Y),
        towerPaint,
      );
      canvas.drawLine(
        Offset(centerX + armWidth * 0.3, topY),
        Offset(centerX + armWidth * 0.6, arm1Y),
        towerPaint,
      );
    }
  }

  void _drawPowerLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final towerSpacing = size.width / 4;
    final lineHeight1 = size.height * 0.35;
    final lineHeight2 = size.height * 0.45;
    final lineHeight3 = size.height * 0.55;
    
    // Draw three sets of power lines (3-phase system)
    for (int line = 0; line < 3; line++) {
      final y = line == 0 ? lineHeight1 : (line == 1 ? lineHeight2 : lineHeight3);
      
      // Draw lines between towers with slight sag
      for (int i = 0; i < 2; i++) {
        final startX = towerSpacing + (i * towerSpacing);
        final endX = towerSpacing + ((i + 1) * towerSpacing);
        final midX = (startX + endX) / 2;
        final sagY = y + 8; // Small sag in the middle
        
        // Draw curved line to simulate cable sag
        final path = Path();
        path.moveTo(startX, y);
        path.quadraticBezierTo(midX, sagY, endX, y);
        canvas.drawPath(path, linePaint);
      }
    }
  }

  void _drawEnergyPulses(Canvas canvas, Size size) {
    final pulsePaint = Paint()
      ..color = pulseColor
      ..style = PaintingStyle.fill;

    final towerSpacing = size.width / 4;
    final lineHeight1 = size.height * 0.35;
    final lineHeight2 = size.height * 0.45;
    final lineHeight3 = size.height * 0.55;
    
    final pulseSpacing = 1.0 / pulseCount;
    
    // Draw energy pulses on each line
    for (int line = 0; line < 3; line++) {
      final y = line == 0 ? lineHeight1 : (line == 1 ? lineHeight2 : lineHeight3);
      final lineOffset = line * 0.2; // Offset pulses on different lines
      
      for (int pulse = 0; pulse < pulseCount; pulse++) {
        // Calculate pulse position with different phase for each line
        final pulseProgress = ((progress + lineOffset + (pulse * pulseSpacing)) % 1.0);
        final pulseX = towerSpacing + (pulseProgress * (size.width - 2 * towerSpacing));
        
        // Draw energy pulse as a glowing circle
        final pulseRadius = 3.0 + (2.0 * math.sin(progress * 2 * math.pi * 4));
        
        // Outer glow
        final glowPaint = Paint()
          ..color = pulseColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(pulseX, y), pulseRadius * 2, glowPaint);
        
        // Inner bright pulse
        canvas.drawCircle(Offset(pulseX, y), pulseRadius, pulsePaint);
        
        // Spark effect
        final sparkPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(pulseX, y), pulseRadius * 0.5, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PowerLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}