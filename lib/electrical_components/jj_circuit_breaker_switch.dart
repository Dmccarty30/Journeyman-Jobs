import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../design_system/app_theme.dart';

/// A custom switch widget that simulates a real electrical circuit breaker
/// with authentic housing, physical switch animation, and electrical effects
class JJCircuitBreakerSwitch extends StatefulWidget {
  /// Whether the switch is currently on
  final bool value;
  
  /// Callback when the switch state changes
  final ValueChanged<bool>? onChanged;
  
  /// Optional label to display on the switch housing
  final String? label;
  
  /// Size of the circuit breaker switch
  final JJCircuitBreakerSize size;
  
  /// Whether to show electrical arc effects when toggling
  final bool showElectricalEffects;

  const JJCircuitBreakerSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.size = JJCircuitBreakerSize.medium,
    this.showElectricalEffects = true,
  });

  @override
  State<JJCircuitBreakerSwitch> createState() => _JJCircuitBreakerSwitchState();
}

/// Size variants for the circuit breaker switch
enum JJCircuitBreakerSize {
  small(width: 54, height: 72, fontSize: 7),
  medium(width: 72, height: 90, fontSize: 9),
  large(width: 90, height: 108, fontSize: 11);

  const JJCircuitBreakerSize({
    required this.width,
    required this.height,
    required this.fontSize,
  });

  final double width;
  final double height;
  final double fontSize;
}

class _JJCircuitBreakerSwitchState extends State<JJCircuitBreakerSwitch>
    with TickerProviderStateMixin {
  late AnimationController _switchController;
  late AnimationController _arcController;
  late AnimationController _glowController;
  late AnimationController _sparkController;
  
  late Animation<double> _switchPosition;
  late Animation<double> _arcOpacity;
  late Animation<double> _glowIntensity;
  late Animation<double> _sparkRotation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    // Switch toggle animation
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Electrical arc animation
    _arcController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Glow effect animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Spark rotation animation
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _switchPosition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));
    
    _arcOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _arcController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    _glowIntensity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _sparkRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _sparkController,
      curve: Curves.linear,
    ));
    
    // Initialize position based on current value
    if (widget.value) {
      _switchController.value = 1.0;
      if (widget.showElectricalEffects) {
        _startGlowAnimation();
      }
    }
  }
  
  @override
  void didUpdateWidget(JJCircuitBreakerSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _switchController.forward();
        if (widget.showElectricalEffects) {
          _triggerElectricalEffects();
        }
      } else {
        _switchController.reverse();
        _stopGlowAnimation();
      }
    }
  }
  
  @override
  void dispose() {
    _switchController.dispose();
    _arcController.dispose();
    _glowController.dispose();
    _sparkController.dispose();
    super.dispose();
  }
  
  void _triggerElectricalEffects() {
    _arcController.forward().then((_) {
      _arcController.reverse();
    });
    _sparkController.forward().then((_) {
      _sparkController.reset();
    });
    _startGlowAnimation();
  }
  
  void _startGlowAnimation() {
    _glowController.repeat(reverse: true);
  }
  
  void _stopGlowAnimation() {
    _glowController.stop();
    _glowController.reset();
  }
  
  void _handleTap() {
    if (widget.onChanged != null) {
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      widget.onChanged!(!widget.value);
    }
  }
  
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }
  
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _switchController,
          _arcController,
          _glowController,
          _sparkController,
        ]),
        builder: (context, child) {
          return SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: CustomPaint(
              painter: _CircuitBreakerPainter(
                switchPosition: _switchPosition.value,
                arcOpacity: _arcOpacity.value,
                glowIntensity: _glowIntensity.value,
                sparkRotation: _sparkRotation.value,
                isPressed: _isPressed,
                isOn: widget.value,
                label: widget.label,
                size: widget.size,
                showElectricalEffects: widget.showElectricalEffects,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircuitBreakerPainter extends CustomPainter {
  final double switchPosition;
  final double arcOpacity;
  final double glowIntensity;
  final double sparkRotation;
  final bool isPressed;
  final bool isOn;
  final String? label;
  final JJCircuitBreakerSize size;
  final bool showElectricalEffects;

  _CircuitBreakerPainter({
    required this.switchPosition,
    required this.arcOpacity,
    required this.glowIntensity,
    required this.sparkRotation,
    required this.isPressed,
    required this.isOn,
    required this.label,
    required this.size,
    required this.showElectricalEffects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw circuit breaker housing
    _drawHousing(canvas, size, paint);
    
    // Draw terminals and wiring
    _drawTerminals(canvas, size, paint);
    
    // Draw the toggle switch
    _drawToggleSwitch(canvas, size, paint);
    
    // Draw electrical effects if enabled
    if (showElectricalEffects && isOn) {
      _drawElectricalEffects(canvas, size, paint);
    }
    
    // Draw label if provided
    if (label != null) {
      _drawLabel(canvas, size);
    }
    
    // Draw status indicator
    _drawStatusIndicator(canvas, size, paint);
  }
  
  void _drawHousing(Canvas canvas, Size size, Paint paint) {
    final housingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.08),
    );
    
    // Main housing gradient
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.lightGray,
        AppTheme.darkGray,
        AppTheme.lightGray,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(housingRect.outerRect);
    
    canvas.drawRRect(housingRect, paint);
    
    // Housing border
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.primaryNavy;
    paint.strokeWidth = 1.5;
    canvas.drawRRect(housingRect, paint);
    
    // Housing details - screw holes
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.primaryNavy.withValues(alpha: 0.3);
    
    final screwRadius = size.width * 0.03;
    final screwPositions = [
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.1),
      Offset(size.width * 0.15, size.height * 0.9),
      Offset(size.width * 0.85, size.height * 0.9),
    ];
    
    for (final pos in screwPositions) {
      canvas.drawCircle(pos, screwRadius, paint);
      // Screw slot
      paint.color = AppTheme.primaryNavy;
      paint.strokeWidth = 1;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(
        pos - Offset(screwRadius * 0.7, 0),
        pos + Offset(screwRadius * 0.7, 0),
        paint,
      );
    }
  }
  
  void _drawTerminals(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    
    // Top terminal (Line)
    final topTerminal = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.05,
        size.width * 0.4,
        size.height * 0.08,
      ),
      Radius.circular(size.width * 0.02),
    );
    
    // Bottom terminal (Load)
    final bottomTerminal = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.87,
        size.width * 0.4,
        size.height * 0.08,
      ),
      Radius.circular(size.width * 0.02),
    );
    
    // Terminal color based on state
    if (isOn && showElectricalEffects) {
      paint.color = AppTheme.accentCopper;
    } else {
      paint.color = AppTheme.darkGray;
    }
    
    canvas.drawRRect(topTerminal, paint);
    canvas.drawRRect(bottomTerminal, paint);
    
    // Terminal screws
    paint.color = AppTheme.primaryNavy;
    final terminalScrewRadius = size.width * 0.02;
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.09),
      terminalScrewRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.91),
      terminalScrewRadius,
      paint,
    );
  }
  
  void _drawToggleSwitch(Canvas canvas, Size size, Paint paint) {
    final switchTrackRect = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.25,
      size.width * 0.3,
      size.height * 0.5,
    );
    
    // Switch track
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.primaryNavy.withValues(alpha: 0.8);
    final trackRRect = RRect.fromRectAndRadius(
      switchTrackRect,
      Radius.circular(size.width * 0.03),
    );
    canvas.drawRRect(trackRRect, paint);
    
    // Switch handle position
    final handleHeight = size.height * 0.15;
    final handleTop = size.height * 0.3;
    final handleBottom = size.height * 0.55;
    
    // Interpolate handle position
    final handleY = handleTop + (handleBottom - handleTop) * switchPosition;
    
    // Add pressed effect
    final pressOffset = isPressed ? 2.0 : 0.0;
    
    final handleRect = Rect.fromLTWH(
      size.width * 0.3 + pressOffset,
      handleY + pressOffset,
      size.width * 0.4,
      handleHeight,
    );
    
    // Handle gradient
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isOn ? AppTheme.accentCopper : AppTheme.lightGray,
        isOn ? AppTheme.accentCopper.withValues(alpha: 0.7) : AppTheme.darkGray,
      ],
    ).createShader(handleRect);
    
    final handleRRect = RRect.fromRectAndRadius(
      handleRect,
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(handleRRect, paint);
    
    // Handle border
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.primaryNavy;
    paint.strokeWidth = 1.5;
    canvas.drawRRect(handleRRect, paint);
    
    // Handle grip lines
    paint.strokeWidth = 1;
    paint.color = AppTheme.primaryNavy.withValues(alpha: 0.5);
    for (int i = 0; i < 3; i++) {
      final y = handleY + handleHeight * 0.3 + (i * handleHeight * 0.15);
      canvas.drawLine(
        Offset(size.width * 0.35, y),
        Offset(size.width * 0.65, y),
        paint,
      );
    }
  }
  
  void _drawElectricalEffects(Canvas canvas, Size size, Paint paint) {
    if (arcOpacity > 0) {
      _drawElectricalArc(canvas, size, paint);
    }
    
    if (glowIntensity > 0) {
      _drawGlowEffect(canvas, size, paint);
    }
    
    if (sparkRotation > 0) {
      _drawSparks(canvas, size, paint);
    }
  }
  
  void _drawElectricalArc(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = AppTheme.accentCopper.withValues(alpha: arcOpacity * 0.8);
    
    final arcPath = Path();
    final startPoint = Offset(size.width * 0.5, size.height * 0.3);
    final endPoint = Offset(size.width * 0.5, size.height * 0.7);
    
    // Create a curved arc
    arcPath.moveTo(startPoint.dx, startPoint.dy);
    arcPath.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.5,
      endPoint.dx,
      endPoint.dy,
    );
    
    canvas.drawPath(arcPath, paint);
    
    // Secondary arc
    paint.strokeWidth = 1;
    paint.color = AppTheme.accentCopper.withValues(alpha: arcOpacity * 0.4);
    
    final arcPath2 = Path();
    arcPath2.moveTo(startPoint.dx, startPoint.dy);
    arcPath2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      endPoint.dx,
      endPoint.dy,
    );
    
    canvas.drawPath(arcPath2, paint);
  }
  
  void _drawGlowEffect(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    
    // Terminal glow
    final glowRadius = size.width * 0.15 * glowIntensity;
    paint.shader = RadialGradient(
      colors: [
        AppTheme.accentCopper.withValues(alpha: glowIntensity * 0.3),
        AppTheme.accentCopper.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.09),
      radius: glowRadius,
    ));
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.09),
      glowRadius,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.91),
      glowRadius,
      paint,
    );
  }
  
  void _drawSparks(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.color = AppTheme.accentCopper.withValues(alpha: 0.8);
    
    final sparkCount = 6;
    final sparkLength = size.width * 0.08;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    
    for (int i = 0; i < sparkCount; i++) {
      final angle = (i * 2 * math.pi / sparkCount) + sparkRotation;
      final startRadius = size.width * 0.12;
      final endRadius = startRadius + sparkLength;
      
      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );
      
      canvas.drawLine(start, end, paint);
    }
  }
  
  void _drawLabel(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: AppTheme.primaryNavy,
          fontSize: this.size.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.82,
      ),
    );
  }
  
  void _drawStatusIndicator(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    
    final indicatorRadius = size.width * 0.04;
    final indicatorCenter = Offset(size.width * 0.85, size.height * 0.2);
    
    // Status light
    paint.color = isOn ? AppTheme.successGreen : AppTheme.errorRed;
    canvas.drawCircle(indicatorCenter, indicatorRadius, paint);
    
    // Status light border
    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.primaryNavy;
    paint.strokeWidth = 1;
    canvas.drawCircle(indicatorCenter, indicatorRadius, paint);
    
    // Status label
    final statusText = isOn ? 'ON' : 'OFF';
    final statusPainter = TextPainter(
      text: TextSpan(
        text: statusText,
        style: TextStyle(
          color: AppTheme.primaryNavy,
          fontSize: this.size.fontSize * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    statusPainter.layout();
    statusPainter.paint(
      canvas,
      Offset(
        indicatorCenter.dx - statusPainter.width / 2,
        indicatorCenter.dy + indicatorRadius + 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CircuitBreakerPainter oldDelegate) {
    return oldDelegate.switchPosition != switchPosition ||
           oldDelegate.arcOpacity != arcOpacity ||
           oldDelegate.glowIntensity != glowIntensity ||
           oldDelegate.sparkRotation != sparkRotation ||
           oldDelegate.isPressed != isPressed ||
           oldDelegate.isOn != isOn;
  }
}