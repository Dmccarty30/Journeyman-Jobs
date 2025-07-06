import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 3-Phase Sine Wave Loader
/// 
/// Displays three electrical sine waves representing AC power phases.
/// Each wave is offset by 120 degrees (2π/3 radians) to accurately
/// represent three-phase electrical power.
/// 
/// Example usage:
/// ```dart
/// ThreePhaseSineWaveLoader(
///   width: 200,
///   height: 60,
///   primaryColor: Colors.orange,
///   secondaryColor: Colors.blue,
///   tertiaryColor: Colors.green,
///   duration: Duration(milliseconds: 2000),
/// )
/// ```
class ThreePhaseSineWaveLoader extends StatefulWidget {
  /// Width of the loader
  final double width;
  
  /// Height of the loader
  final double height;
  
  /// Color of the first phase (L1)
  final Color? primaryColor;
  
  /// Color of the second phase (L2)
  final Color? secondaryColor;
  
  /// Color of the third phase (L3)
  final Color? tertiaryColor;
  
  /// Duration of one complete animation cycle
  final Duration duration;

  const ThreePhaseSineWaveLoader({
    Key? key,
    this.width = 200,
    this.height = 60,
    this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<ThreePhaseSineWaveLoader> createState() => _ThreePhaseSineWaveLoaderState();
}

class _ThreePhaseSineWaveLoaderState extends State<ThreePhaseSineWaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
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
            painter: SineWavePainter(
              phase: _animation.value,
              primaryColor: widget.primaryColor ?? const Color(0xFFB45309), // Copper
              secondaryColor: widget.secondaryColor ?? const Color(0xFF3182CE), // Info Blue
              tertiaryColor: widget.tertiaryColor ?? const Color(0xFF38A169), // Success Green
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class SineWavePainter extends CustomPainter {
  final double phase;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  SineWavePainter({
    required this.phase,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final amplitude = size.height * 0.3;
    
    // Paint for each phase
    final paint1 = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final paint2 = Paint()
      ..color = secondaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final paint3 = Paint()
      ..color = tertiaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw three sine waves with 120° phase difference
    _drawSineWave(canvas, size, paint1, centerY, amplitude, phase);
    _drawSineWave(canvas, size, paint2, centerY, amplitude, phase + (2 * math.pi / 3));
    _drawSineWave(canvas, size, paint3, centerY, amplitude, phase + (4 * math.pi / 3));
  }

  void _drawSineWave(Canvas canvas, Size size, Paint paint, double centerY, 
                     double amplitude, double phaseShift) {
    final path = Path();
    final frequency = 2; // 2 cycles across the width
    
    for (int x = 0; x <= size.width.toInt(); x++) {
      final normalizedX = x / size.width;
      final y = centerY + amplitude * math.sin(frequency * 2 * math.pi * normalizedX + phaseShift);
      
      if (x == 0) {
        path.moveTo(x.toDouble(), y);
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SineWavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}