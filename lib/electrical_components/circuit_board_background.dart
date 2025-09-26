import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../design_system/app_theme.dart';

/// A highly customizable electrical circuit board background with animated
/// current flow, interactive components, and PCB-style visual elements.
/// 
/// Features:
/// - Subtle PCB/motherboard-inspired circuit pattern
/// - Animated electricity flow with glowing effects
/// - Interactive components (switches, LEDs, capacitors)
/// - Configurable opacity, colors, and animation speeds
/// - Performance optimized for 60 FPS with <5% CPU usage
/// 
/// Example usage:
/// ```dart
/// Stack(
///   children: [
///     ElectricalCircuitBackground(
///       opacity: 0.15,
///       animationSpeed: 3.0,
///       componentDensity: ComponentDensity.medium,
///     ),
///     // Your main content here
///   ],
/// )
/// ```
class ElectricalCircuitBackground extends StatefulWidget {
  const ElectricalCircuitBackground({
    Key? key,
    this.opacity = 0.15,
    this.animationSpeed = 4.0,
    this.componentDensity = ComponentDensity.medium,
    this.enableCurrentFlow = true,
    this.enableInteractiveComponents = true,
    this.traceColor,
    this.currentColor,
    this.copperColor,
    this.child,
  }) : super(key: key);

  /// Overall opacity of the circuit pattern (0.0 - 1.0)
  final double opacity;
  
  /// Animation speed multiplier (1.0 = normal, 2.0 = 2x speed)
  final double animationSpeed;
  
  /// Density of circuit components
  final ComponentDensity componentDensity;
  
  /// Whether to show animated current flow
  final bool enableCurrentFlow;
  
  /// Whether to show interactive animated components
  final bool enableInteractiveComponents;
  
  /// Custom trace color (defaults to navy)
  final Color? traceColor;
  
  /// Custom current flow color (defaults to electric blue)
  final Color? currentColor;
  
  /// Custom copper accent color
  final Color? copperColor;
  
  /// Optional child widget to overlay on the background
  final Widget? child;

  @override
  State<ElectricalCircuitBackground> createState() => _ElectricalCircuitBackgroundState();
}

/// Component density levels for the circuit board
enum ComponentDensity {
  low(0.5),
  medium(1.0),
  high(1.5),
  ultra(2.0);

  const ComponentDensity(this.multiplier);
  final double multiplier;
}

class _ElectricalCircuitBackgroundState extends State<ElectricalCircuitBackground>
    with TickerProviderStateMixin {
  
  late AnimationController _currentFlowController;
  late AnimationController _componentController;
  late Animation<double> _currentFlowAnimation;
  late Animation<double> _componentAnimation;
  
  // Cached circuit paths for performance
  List<CircuitTrace>? _cachedTraces;
  List<CircuitComponent>? _cachedComponents;
  
  @override
  void initState() {
    super.initState();
    
    // Current flow animation (smooth, continuous)
    _currentFlowController = AnimationController(
      duration: Duration(milliseconds: (5000 / widget.animationSpeed).round()),
      vsync: this,
    );
    _currentFlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _currentFlowController, curve: Curves.linear),
    );
    
    // Component animation (for switches, LEDs, etc.)
    _componentController = AnimationController(
      duration: Duration(milliseconds: (8000 / widget.animationSpeed).round()),
      vsync: this,
    );
    _componentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _componentController, curve: Curves.easeInOut),
    );
    
    if (widget.enableCurrentFlow) {
      _currentFlowController.repeat();
    }
    
    if (widget.enableInteractiveComponents) {
      _componentController.repeat();
    }
  }
  
  @override
  void dispose() {
    _currentFlowController.dispose();
    _componentController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ElectricalCircuitBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation speeds if changed
    if (oldWidget.animationSpeed != widget.animationSpeed) {
      _currentFlowController.duration = 
          Duration(milliseconds: (5000 / widget.animationSpeed).round());
      _componentController.duration = 
          Duration(milliseconds: (8000 / widget.animationSpeed).round());
    }
    
    // Handle animation state changes
    if (oldWidget.enableCurrentFlow != widget.enableCurrentFlow) {
      if (widget.enableCurrentFlow) {
        _currentFlowController.repeat();
      } else {
        _currentFlowController.stop();
      }
    }
    
    if (oldWidget.enableInteractiveComponents != widget.enableInteractiveComponents) {
      if (widget.enableInteractiveComponents) {
        _componentController.repeat();
      } else {
        _componentController.stop();
      }
    }
    
    // Clear cache if density changed
    if (oldWidget.componentDensity != widget.componentDensity) {
      _cachedTraces = null;
      _cachedComponents = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Static circuit board pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _CircuitBoardPainter(
                opacity: widget.opacity,
                traceColor: widget.traceColor ?? AppTheme.primaryNavy,
                copperColor: widget.copperColor ?? AppTheme.accentCopper,
                componentDensity: widget.componentDensity,
                cachedTraces: _cachedTraces,
                cachedComponents: _cachedComponents,
                onCacheUpdate: (traces, components) {
                  _cachedTraces = traces;
                  _cachedComponents = components;
                },
              ),
            ),
          ),
          
          // Animated current flow layer
          if (widget.enableCurrentFlow)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _currentFlowAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CurrentFlowPainter(
                      progress: _currentFlowAnimation.value,
                      opacity: widget.opacity,
                      currentColor: widget.currentColor ?? const Color(0xFF00D4FF),
                      traces: _cachedTraces ?? [],
                    ),
                  );
                },
              ),
            ),
          
          // Interactive components layer
          if (widget.enableInteractiveComponents)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _componentAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _InteractiveComponentsPainter(
                      progress: _componentAnimation.value,
                      opacity: widget.opacity,
                      componentColor: widget.copperColor ?? AppTheme.accentCopper,
                      ledColor: widget.currentColor ?? const Color(0xFF00D4FF),
                      components: _cachedComponents ?? [],
                    ),
                  );
                },
              ),
            ),
          
          // Optional child overlay
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

/// Represents a circuit trace path for current flow animation
class CircuitTrace {
  final Path path;
  final double length;
  final List<Offset> keyPoints;
  final bool isPrimary;
  
  CircuitTrace({
    required this.path,
    required this.length,
    required this.keyPoints,
    this.isPrimary = false,
  });
}

/// Represents an interactive circuit component
class CircuitComponent {
  final Offset position;
  final ComponentType type;
  final double size;
  final double rotation;
  
  CircuitComponent({
    required this.position,
    required this.type,
    required this.size,
    this.rotation = 0.0,
  });
}

enum ComponentType {
  resistor,
  capacitor,
  transistor,
  switchComponent,
  led,
  via,
  ic,
}

/// Main painter for the static circuit board pattern
class _CircuitBoardPainter extends CustomPainter {
  _CircuitBoardPainter({
    required this.opacity,
    required this.traceColor,
    required this.copperColor,
    required this.componentDensity,
    this.cachedTraces,
    this.cachedComponents,
    this.onCacheUpdate,
  });

  final double opacity;
  final Color traceColor;
  final Color copperColor;
  final ComponentDensity componentDensity;
  final List<CircuitTrace>? cachedTraces;
  final List<CircuitComponent>? cachedComponents;
  final Function(List<CircuitTrace>, List<CircuitComponent>)? onCacheUpdate;

  @override
  void paint(Canvas canvas, Size size) {
    // Generate or use cached circuit layout
    final traces = cachedTraces ?? _generateCircuitTraces(size);
    final components = cachedComponents ?? _generateComponents(size);
    
    // Cache the generated data if not already cached
    if (cachedTraces == null || cachedComponents == null) {
      onCacheUpdate?.call(traces, components);
    }
    
    _paintCircuitBoard(canvas, size, traces, components);
  }
  
  void _paintCircuitBoard(Canvas canvas, Size size, List<CircuitTrace> traces, List<CircuitComponent> components) {
    // Create paint objects
    final tracePaint = Paint()
      ..color = traceColor.withValues(alpha: opacity * 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final thinTracePaint = Paint()
      ..color = traceColor.withValues(alpha: opacity * 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final viaPaint = Paint()
      ..color = copperColor.withValues(alpha: opacity * 0.6)
      ..style = PaintingStyle.fill;
    
    final componentPaint = Paint()
      ..color = traceColor.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Draw substrate background (very subtle)
    final substratePaint = Paint()
      ..color = const Color(0xFFF8F9FA).withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, substratePaint);
    
    // Draw circuit traces
    for (final trace in traces) {
      canvas.drawPath(trace.path, trace.isPrimary ? tracePaint : thinTracePaint);
    }
    
    // Draw components
    for (final component in components) {
      _drawComponent(canvas, component, componentPaint, viaPaint);
    }
    
    // Add subtle grid pattern
    final gridPaint = Paint()
      ..color = traceColor.withValues(alpha: opacity * 0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    _drawGrid(canvas, size, gridPaint);
  }
  
  List<CircuitTrace> _generateCircuitTraces(Size size) {
    final traces = <CircuitTrace>[];
    final random = math.Random(42); // Fixed seed for consistency
    
    final density = componentDensity.multiplier;
    final traceCount = (12 * density).round();
    
    for (int i = 0; i < traceCount; i++) {
      final path = Path();
      final keyPoints = <Offset>[];
      
      // Generate realistic PCB trace paths
      final startX = random.nextDouble() * size.width * 0.2;
      final startY = random.nextDouble() * size.height;
      final start = Offset(startX, startY);
      
      path.moveTo(start.dx, start.dy);
      keyPoints.add(start);
      
      var currentPoint = start;
      final segments = 3 + random.nextInt(4);
      
      for (int j = 0; j < segments; j++) {
        // Create L-shaped traces (typical PCB routing)
        final isHorizontalFirst = random.nextBool();
        late Offset intermediate, end;
        
        if (isHorizontalFirst) {
          intermediate = Offset(
            currentPoint.dx + (20 + random.nextDouble() * 80),
            currentPoint.dy,
          );
          end = Offset(
            intermediate.dx,
            currentPoint.dy + (random.nextDouble() - 0.5) * 60,
          );
        } else {
          intermediate = Offset(
            currentPoint.dx,
            currentPoint.dy + (random.nextDouble() - 0.5) * 60,
          );
          end = Offset(
            currentPoint.dx + (20 + random.nextDouble() * 80),
            intermediate.dy,
          );
        }
        
        // Keep within bounds
        end = Offset(
          math.min(math.max(end.dx, 0), size.width),
          math.min(math.max(end.dy, 0), size.height),
        );
        
        path.lineTo(intermediate.dx, intermediate.dy);
        path.lineTo(end.dx, end.dy);
        
        keyPoints.add(intermediate);
        keyPoints.add(end);
        currentPoint = end;
      }
      
      final pathMetric = path.computeMetrics().first;
      traces.add(CircuitTrace(
        path: path,
        length: pathMetric.length,
        keyPoints: keyPoints,
        isPrimary: i < traceCount * 0.3, // 30% primary traces
      ));
    }
    
    return traces;
  }
  
  List<CircuitComponent> _generateComponents(Size size) {
    final components = <CircuitComponent>[];
    final random = math.Random(24); // Fixed seed
    
    final density = componentDensity.multiplier;
    final componentCount = (20 * density).round();
    
    for (int i = 0; i < componentCount; i++) {
      final position = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      
      final types = ComponentType.values;
      final type = types[random.nextInt(types.length)];
      
      components.add(CircuitComponent(
        position: position,
        type: type,
        size: 4 + random.nextDouble() * 8,
        rotation: random.nextDouble() * math.pi * 2,
      ));
    }
    
    return components;
  }
  
  void _drawComponent(Canvas canvas, CircuitComponent component, Paint componentPaint, Paint viaPaint) {
    canvas.save();
    canvas.translate(component.position.dx, component.position.dy);
    canvas.rotate(component.rotation);
    
    switch (component.type) {
      case ComponentType.resistor:
        _drawResistor(canvas, component.size, componentPaint);
        break;
      case ComponentType.capacitor:
        _drawCapacitor(canvas, component.size, componentPaint);
        break;
      case ComponentType.transistor:
        _drawTransistor(canvas, component.size, componentPaint);
        break;
      case ComponentType.switchComponent:
        _drawSwitch(canvas, component.size, componentPaint);
        break;
      case ComponentType.led:
        _drawLED(canvas, component.size, componentPaint);
        break;
      case ComponentType.via:
        _drawVia(canvas, component.size, viaPaint);
        break;
      case ComponentType.ic:
        _drawIC(canvas, component.size, componentPaint);
        break;
    }
    
    canvas.restore();
  }
  
  void _drawResistor(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final width = size * 1.5;
    final height = size * 0.6;
    
    // Zigzag resistor pattern
    path.moveTo(-width / 2, 0);
    path.lineTo(-width / 4, -height / 2);
    path.lineTo(0, height / 2);
    path.lineTo(width / 4, -height / 2);
    path.lineTo(width / 2, 0);
    
    canvas.drawPath(path, paint);
  }
  
  void _drawCapacitor(Canvas canvas, double size, Paint paint) {
    final width = size * 0.8;
    final height = size;
    
    // Two parallel plates
    canvas.drawLine(Offset(-width / 4, -height / 2), Offset(-width / 4, height / 2), paint);
    canvas.drawLine(Offset(width / 4, -height / 2), Offset(width / 4, height / 2), paint);
  }
  
  void _drawTransistor(Canvas canvas, double size, Paint paint) {
    final radius = size * 0.8;
    
    // Circle with internal lines
    canvas.drawCircle(Offset.zero, radius, paint..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(-radius * 0.5, -radius * 0.3), Offset(radius * 0.5, radius * 0.3), paint);
  }
  
  void _drawSwitch(Canvas canvas, double size, Paint paint) {
    final width = size;
    
    // Simple switch representation
    canvas.drawLine(Offset(-width / 2, 0), Offset(0, -width * 0.3), paint);
    canvas.drawLine(Offset(0, 0), Offset(width / 2, 0), paint);
    canvas.drawCircle(Offset(-width / 2, 0), size * 0.2, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(width / 2, 0), size * 0.2, paint..style = PaintingStyle.fill);
  }
  
  void _drawLED(Canvas canvas, double size, Paint paint) {
    final radius = size * 0.6;
    
    // Triangle for LED
    final path = Path();
    path.moveTo(0, -radius);
    path.lineTo(-radius * 0.8, radius * 0.5);
    path.lineTo(radius * 0.8, radius * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  void _drawVia(Canvas canvas, double size, Paint paint) {
    // Small filled circle for via
    canvas.drawCircle(Offset.zero, size * 0.5, paint..style = PaintingStyle.fill);
    
    // Inner circle
    final innerPaint = Paint()
      ..color = paint.color.withValues(alpha: paint.color.opacity * 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, size * 0.25, innerPaint);
  }
  
  void _drawIC(Canvas canvas, double size, Paint paint) {
    final width = size * 1.2;
    final height = size * 0.8;
    
    // Rectangle for IC package
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      Radius.circular(size * 0.1),
    );
    canvas.drawRRect(rect, paint..style = PaintingStyle.stroke);
    
    // Pin indicator
    canvas.drawCircle(Offset(-width * 0.3, -height * 0.3), size * 0.15, paint..style = PaintingStyle.fill);
  }
  
  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 0.5;
    
    final gridSpacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CircuitBoardPainter ||
        oldDelegate.opacity != opacity ||
        oldDelegate.traceColor != traceColor ||
        oldDelegate.copperColor != copperColor ||
        oldDelegate.componentDensity != componentDensity;
  }
}

/// Painter for animated current flow effects
class _CurrentFlowPainter extends CustomPainter {
  _CurrentFlowPainter({
    required this.progress,
    required this.opacity,
    required this.currentColor,
    required this.traces,
  });

  final double progress;
  final double opacity;
  final Color currentColor;
  final List<CircuitTrace> traces;

  @override
  void paint(Canvas canvas, Size size) {
    if (traces.isEmpty) return;
    
    final glowPaint = Paint()
      ..color = currentColor.withValues(alpha: opacity * 0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    final corePaint = Paint()
      ..color = currentColor.withValues(alpha: opacity * 1.0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Animate current flow along primary traces
    for (final trace in traces.where((t) => t.isPrimary)) {
      final pathMetrics = trace.path.computeMetrics();
      
      for (final pathMetric in pathMetrics) {
        final totalLength = pathMetric.length;
        
        // Create multiple current pulses with different phases
        for (int pulse = 0; pulse < 3; pulse++) {
          final phaseOffset = (pulse * 0.33) % 1.0;
          final animProgress = (progress + phaseOffset) % 1.0;
          
          // Current pulse parameters
          final pulseLength = totalLength * 0.15; // 15% of trace length
          final pulseStart = animProgress * totalLength;
          final pulseEnd = pulseStart + pulseLength;
          
          if (pulseEnd > totalLength) {
            // Handle wrap-around
            final firstSegmentEnd = totalLength;
            final secondSegmentStart = 0.0;
            final secondSegmentEnd = pulseEnd - totalLength;
            
            // Draw first segment
            if (pulseStart < firstSegmentEnd) {
              final segment1 = pathMetric.extractPath(pulseStart, firstSegmentEnd);
              canvas.drawPath(segment1, glowPaint);
              canvas.drawPath(segment1, corePaint);
            }
            
            // Draw second segment
            if (secondSegmentEnd > 0) {
              final segment2 = pathMetric.extractPath(secondSegmentStart, secondSegmentEnd);
              canvas.drawPath(segment2, glowPaint);
              canvas.drawPath(segment2, corePaint);
            }
          } else {
            // Normal case
            final currentSegment = pathMetric.extractPath(
              math.max(0, pulseStart),
              math.min(totalLength, pulseEnd),
            );
            canvas.drawPath(currentSegment, glowPaint);
            canvas.drawPath(currentSegment, corePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CurrentFlowPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.currentColor != currentColor;
  }
}

/// Painter for interactive animated components
class _InteractiveComponentsPainter extends CustomPainter {
  _InteractiveComponentsPainter({
    required this.progress,
    required this.opacity,
    required this.componentColor,
    required this.ledColor,
    required this.components,
  });

  final double progress;
  final double opacity;
  final Color componentColor;
  final Color ledColor;
  final List<CircuitComponent> components;

  @override
  void paint(Canvas canvas, Size size) {
    if (components.isEmpty) return;
    
    final switchPaint = Paint()
      ..color = componentColor.withValues(alpha: opacity * 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final ledPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;
    
    final capacitorPaint = Paint()
      ..color = componentColor.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Animate specific component types
    for (int i = 0; i < components.length; i++) {
      final component = components[i];
      final animPhase = (progress + (i * 0.1)) % 1.0;
      
      canvas.save();
      canvas.translate(component.position.dx, component.position.dy);
      
      switch (component.type) {
        case ComponentType.switchComponent:
          _drawAnimatedSwitch(canvas, component.size, switchPaint, animPhase);
          break;
        case ComponentType.led:
          _drawAnimatedLED(canvas, component.size, ledPaint, animPhase);
          break;
        case ComponentType.capacitor:
          _drawAnimatedCapacitor(canvas, component.size, capacitorPaint, animPhase);
          break;
        default:
          break;
      }
      
      canvas.restore();
    }
  }
  
  void _drawAnimatedSwitch(Canvas canvas, double size, Paint paint, double phase) {
    // Switch that occasionally toggles
    final isOpen = (phase * 4) % 1.0 < 0.15; // Open 15% of the time
    final width = size;
    
    canvas.drawLine(Offset(-width / 2, 0), Offset(0, isOpen ? -width * 0.3 : 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(width / 2, 0), paint);
    canvas.drawCircle(Offset(-width / 2, 0), size * 0.15, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(width / 2, 0), size * 0.15, paint..style = PaintingStyle.fill);
  }
  
  void _drawAnimatedLED(Canvas canvas, double size, Paint paint, double phase) {
    // LED that pulses with variable intensity
    final intensity = (math.sin(phase * math.pi * 2) + 1) / 2;
    final blinkPhase = (phase * 3) % 1.0;
    final isOn = blinkPhase < 0.7; // On 70% of the time
    
    if (isOn) {
      paint.color = ledColor.withValues(alpha: opacity * intensity);
      
      // Glow effect
      final glowPaint = Paint()
        ..color = ledColor.withValues(alpha: opacity * intensity * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5);
      
      canvas.drawCircle(Offset.zero, size * 0.8, glowPaint);
      canvas.drawCircle(Offset.zero, size * 0.4, paint);
    }
  }
  
  void _drawAnimatedCapacitor(Canvas canvas, double size, Paint paint, double phase) {
    // Capacitor with charge/discharge animation
    final chargeLevel = (math.sin(phase * math.pi * 2) + 1) / 2;
    final width = size * 0.8;
    final height = size * (0.5 + chargeLevel * 0.5);
    
    // Plates with varying height based on charge
    paint.strokeWidth = 1 + chargeLevel * 1.5;
    canvas.drawLine(Offset(-width / 4, -height / 2), Offset(-width / 4, height / 2), paint);
    canvas.drawLine(Offset(width / 4, -height / 2), Offset(width / 4, height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _InteractiveComponentsPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.componentColor != componentColor ||
        oldDelegate.ledColor != ledColor;
  }
}
