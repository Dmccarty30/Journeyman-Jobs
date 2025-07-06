import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Electrical Rotation Meter Loader
/// 
/// Displays a meter-style loading indicator that resembles electrical gauges
/// found in power plants and electrical control panels. Features a smooth
/// needle animation with tick marks and an optional label.
/// 
/// Example usage:
/// ```dart
/// ElectricalRotationMeter(
///   size: 120,
///   needleColor: Colors.orange,
///   backgroundColor: Colors.grey[200],
///   arcColor: Colors.navy,
///   label: 'Loading...',
///   duration: Duration(milliseconds: 3000),
/// )
/// ```
class ElectricalRotationMeter extends StatefulWidget {
  /// Diameter of the meter
  final double size;
  
  /// Color of the meter needle
  final Color? needleColor;
  
  /// Background color of the meter face
  final Color? backgroundColor;
  
  /// Color of the meter arc and tick marks
  final Color? arcColor;
  
  /// Optional label displayed below the meter
  final String? label;
  
  /// Duration of one complete oscillation
  final Duration duration;

  const ElectricalRotationMeter({
    Key? key,
    this.size = 120,
    this.needleColor,
    this.backgroundColor,
    this.arcColor,
    this.label,
    this.duration = const Duration(milliseconds: 3000),
  }) : super(key: key);

  @override
  State<ElectricalRotationMeter> createState() => _ElectricalRotationMeterState();
}

class _ElectricalRotationMeterState extends State<ElectricalRotationMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: MeterPainter(
                  progress: _rotationAnimation.value,
                  needleColor: widget.needleColor ?? const Color(0xFFB45309), // Copper
                  backgroundColor: widget.backgroundColor ?? const Color(0xFFE2E8F0), // Light Gray
                  arcColor: widget.arcColor ?? const Color(0xFF1A202C), // Navy
                ),
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF718096), // Text Light
            ),
          ),
        ],
      ],
    );
  }
}

class MeterPainter extends CustomPainter {
  final double progress;
  final Color needleColor;
  final Color backgroundColor;
  final Color arcColor;

  MeterPainter({
    required this.progress,
    required this.needleColor,
    required this.backgroundColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Draw meter arc (3/4 circle)
    final arcPaint = Paint()
      ..color = arcColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -math.pi * 3/4, // Start angle (225°)
      math.pi * 3/2,  // Sweep angle (270°)
      false,
      arcPaint,
    );
    
    // Draw tick marks
    _drawTickMarks(canvas, center, radius);
    
    // Draw needle
    final needleAngle = -math.pi * 3/4 + (progress * math.pi * 3/2);
    _drawNeedle(canvas, center, radius - 20, needleAngle);
    
    // Draw center dot
    final centerPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = arcColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi * 3/4 + (i / 10) * math.pi * 3/2;
      final isMainTick = i % 2 == 0;
      final startRadius = radius - (isMainTick ? 15 : 10);
      final endRadius = radius - 5;
      
      final startPoint = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );
      
      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double length, double angle) {
    // Draw needle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final shadowEndPoint = Offset(
      center.dx + length * math.cos(angle) + 2,
      center.dy + length * math.sin(angle) + 2,
    );
    
    canvas.drawLine(
      Offset(center.dx + 2, center.dy + 2), 
      shadowEndPoint, 
      shadowPaint
    );
    
    // Draw main needle
    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final endPoint = Offset(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    
    canvas.drawLine(center, endPoint, needlePaint);
  }

  @override
  bool shouldRepaint(covariant MeterPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}