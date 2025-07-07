import 'package:flutter/material.dart';

/// Circuit Breaker Toggle Animation
/// 
/// An animated switch component that looks and feels like an electrical 
/// circuit breaker. Features smooth toggle animation with electrical 
/// symbols (| for ON, O for OFF) and customizable colors.
/// 
/// Example usage:
/// ```dart
/// CircuitBreakerToggle(
///   isOn: _isOn,
///   onChanged: (value) {
///     setState(() {
///       _isOn = value;
///     });
///   },
///   onColor: Colors.green,
///   offColor: Colors.grey,
///   toggleColor: Colors.white,
///   width: 80,
///   height: 40,
/// )
/// ```
class CircuitBreakerToggle extends StatefulWidget {
  /// Current state of the toggle
  final bool isOn;
  
  /// Callback when toggle state changes
  final ValueChanged<bool>? onChanged;
  
  /// Color when toggle is in ON state
  final Color? onColor;
  
  /// Color when toggle is in OFF state
  final Color? offColor;
  
  /// Color of the toggle knob
  final Color? toggleColor;
  
  /// Width of the toggle
  final double width;
  
  /// Height of the toggle
  final double height;

  const CircuitBreakerToggle({
    Key? key,
    required this.isOn,
    this.onChanged,
    this.onColor,
    this.offColor,
    this.toggleColor,
    this.width = 80,
    this.height = 40,
  }) : super(key: key);

  @override
  State<CircuitBreakerToggle> createState() => _CircuitBreakerToggleState();
}

class _CircuitBreakerToggleState extends State<CircuitBreakerToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    if (widget.isOn) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CircuitBreakerToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOn != oldWidget.isOn) {
      if (widget.isOn) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.isOn),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(
            color: const Color(0xFF718096), // Medium Gray
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: CircuitBreakerPainter(
                progress: _animation.value,
                onColor: widget.onColor ?? const Color(0xFF38A169), // Success Green
                offColor: widget.offColor ?? const Color(0xFF718096), // Medium Gray
                toggleColor: widget.toggleColor ?? const Color(0xFFFFFFFF), // White
              ),
              size: Size(widget.width, widget.height),
            );
          },
        ),
      ),
    );
  }
}

class CircuitBreakerPainter extends CustomPainter {
  final double progress;
  final Color onColor;
  final Color offColor;
  final Color toggleColor;

  CircuitBreakerPainter({
    required this.progress,
    required this.onColor,
    required this.offColor,
    required this.toggleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    
    // Background color interpolation
    final backgroundColor = Color.lerp(offColor, onColor, progress)!;
    
    // Draw background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      backgroundPaint,
    );
    
    // Draw toggle knob with shadow effect
    final knobRadius = radius - 4;
    final knobX = progress * (size.width - 2 * radius) + radius;
    
    // Knob shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      Offset(knobX + 1, radius + 1), 
      knobRadius, 
      shadowPaint
    );
    
    // Main knob
    final knobPaint = Paint()
      ..color = toggleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(knobX, radius), knobRadius, knobPaint);
    
    // Draw electrical symbols
    _drawElectricalSymbols(canvas, size, progress);
  }

  void _drawElectricalSymbols(Canvas canvas, Size size, double progress) {
    final symbolPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    // Draw "ON" symbol (line) - visible when ON or transitioning to ON
    if (progress > 0.3) {
      final onOpacity = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      symbolPaint.color = Colors.white.withValues(alpha: 0.8 * onOpacity);
      
      // Vertical line symbol for ON
      canvas.drawLine(
        Offset(size.width * 0.8, size.height * 0.35),
        Offset(size.width * 0.8, size.height * 0.65),
        symbolPaint,
      );
    }
    
    // Draw "OFF" symbol (circle) - visible when OFF or transitioning to OFF
    if (progress < 0.7) {
      final offOpacity = ((0.7 - progress) / 0.7).clamp(0.0, 1.0);
      symbolPaint.color = Colors.white.withValues(alpha: 0.8 * offOpacity);
      
      // Circle symbol for OFF
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.5),
        size.height * 0.15,
        symbolPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircuitBreakerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}