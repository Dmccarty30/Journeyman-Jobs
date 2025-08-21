import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/app_theme.dart';

/// Electrical-themed interactive widgets with responsive feedback
/// Includes buttons, text fields, dropdowns with spark and glow effects

/// Electrical button with spark animation on tap
class JJElectricalButton extends StatefulWidget {
  const JJElectricalButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
    this.sparkColor,
    this.glowColor,
    this.enableSparks = true,
    this.enableGlow = true,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Color? sparkColor;
  final Color? glowColor;
  final bool enableSparks;
  final bool enableGlow;

  @override
  State<JJElectricalButton> createState() => _JJElectricalButtonState();
}

class _JJElectricalButtonState extends State<JJElectricalButton>
    with TickerProviderStateMixin {
  late AnimationController _sparkController;
  late AnimationController _glowController;
  late AnimationController _pressController;
  
  late Animation<double> _sparkAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pressAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _sparkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _pressAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _sparkController.dispose();
    _glowController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    if (widget.enableGlow) {
      _glowController.forward();
    }
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _glowController.reverse();
    
    if (widget.enableSparks) {
      _sparkController.forward().then((_) {
        _sparkController.reset();
      });
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _glowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressAnimation, _glowAnimation, _sparkAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: widget.enableGlow
                    ? [
                        BoxShadow(
                          color: (widget.glowColor ?? const Color(0xFF00D4FF))
                              .withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Base button
                  ElevatedButton(
                    onPressed: null, // Handle gesture above
                    style: widget.style ??
                        ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: AppTheme.accentCopper,
                              width: _isPressed ? 2 : 1,
                            ),
                          ),
                        ),
                    child: widget.child,
                  ),
                  
                  // Spark effect
                  if (widget.enableSparks && _sparkAnimation.value > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _SparkEffectPainter(
                            progress: _sparkAnimation.value,
                            color: widget.sparkColor ?? const Color(0xFF00D4FF),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Electrical text field with current flow animation
class JJElectricalTextField extends StatefulWidget {
  const JJElectricalTextField({
    Key? key,
    this.controller,
    this.decoration,
    this.onChanged,
    this.onFocusChanged,
    this.currentColor,
    this.traceColor,
    this.enableCurrentFlow = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  }) : super(key: key);

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChanged;
  final Color? currentColor;
  final Color? traceColor;
  final bool enableCurrentFlow;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  State<JJElectricalTextField> createState() => _JJElectricalTextFieldState();
}

class _JJElectricalTextFieldState extends State<JJElectricalTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _currentFlowController;
  late Animation<double> _currentFlowAnimation;
  late FocusNode _focusNode;
  
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _currentFlowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _currentFlowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _currentFlowController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _currentFlowController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused && widget.enableCurrentFlow) {
      _currentFlowController.repeat();
    } else {
      _currentFlowController.stop();
      _currentFlowController.reset();
    }
    
    widget.onFocusChanged?.call(_isFocused);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: (widget.currentColor ?? const Color(0xFF00D4FF))
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Current flow animation
          if (widget.enableCurrentFlow && _isFocused)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _currentFlowAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _TextFieldCurrentPainter(
                      progress: _currentFlowAnimation.value,
                      currentColor: widget.currentColor ?? const Color(0xFF00D4FF),
                    ),
                  );
                },
              ),
            ),
          
          // Text field
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            decoration: (widget.decoration ?? const InputDecoration()).copyWith(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.traceColor ?? AppTheme.accentCopper,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.currentColor ?? const Color(0xFF00D4FF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.traceColor ?? AppTheme.accentCopper,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Electrical dropdown with spark selection effects
class JJElectricalDropdown<T> extends StatefulWidget {
  const JJElectricalDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.sparkColor,
    this.enableSparks = true,
  }) : super(key: key);

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final Widget? hint;
  final Color? sparkColor;
  final bool enableSparks;

  @override
  State<JJElectricalDropdown<T>> createState() => _JJElectricalDropdownState<T>();
}

class _JJElectricalDropdownState<T> extends State<JJElectricalDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;
  late Animation<double> _sparkAnimation;

  @override
  void initState() {
    super.initState();
    
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _sparkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  void _handleChanged(T? value) {
    if (widget.enableSparks) {
      _sparkController.forward().then((_) {
        _sparkController.reset();
      });
    }
    
    HapticFeedback.selectionClick();
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.accentCopper),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: _handleChanged,
            hint: widget.hint,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            dropdownColor: AppTheme.primaryNavy,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        
        // Spark effect
        if (widget.enableSparks)
          AnimatedBuilder(
            animation: _sparkAnimation,
            builder: (context, child) {
              if (_sparkAnimation.value == 0) return const SizedBox.shrink();
              
              return Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DropdownSparkPainter(
                      progress: _sparkAnimation.value,
                      color: widget.sparkColor ?? const Color(0xFF00D4FF),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Spark effect painter for buttons
class _SparkEffectPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparkEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1 - progress)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    final sparkCount = 12;
    final maxRadius = 25.0;

    for (int i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * math.pi * 2;
      final distance = progress * maxRadius * (0.5 + random.nextDouble());
      final sparkSize = (1 - progress) * 3 * (0.3 + random.nextDouble());
      
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = size.height / 2 + math.sin(angle) * distance;
      
      canvas.drawCircle(Offset(x, y), sparkSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _SparkEffectPainter ||
        oldDelegate.progress != progress;
  }
}

/// Current flow painter for text fields
class _TextFieldCurrentPainter extends CustomPainter {
  final double progress;
  final Color currentColor;

  _TextFieldCurrentPainter({
    required this.progress,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = currentColor.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = currentColor.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

    // Current flow along the border
    final borderPath = Path();
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    
    borderPath.addRRect(rect);
    
    final pathMetrics = borderPath.computeMetrics().first;
    final totalLength = pathMetrics.length;
    
    // Animated current pulse
    final pulseLength = totalLength * 0.2;
    final pulseStart = (progress * totalLength) % totalLength;
    final pulseEnd = (pulseStart + pulseLength) % totalLength;
    
    Path currentPath;
    if (pulseEnd > pulseStart) {
      currentPath = pathMetrics.extractPath(pulseStart, pulseEnd);
    } else {
      currentPath = pathMetrics.extractPath(pulseStart, totalLength);
      currentPath.addPath(
        pathMetrics.extractPath(0, pulseEnd),
        Offset.zero,
      );
    }
    
    canvas.drawPath(currentPath, glowPaint);
    canvas.drawPath(currentPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _TextFieldCurrentPainter ||
        oldDelegate.progress != progress;
  }
}

/// Spark painter for dropdowns
class _DropdownSparkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DropdownSparkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8 * (1 - progress))
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Electric arc effect
    final startPoint = Offset(size.width - 30, size.height / 2);
    final endPoint = Offset(size.width - 10, size.height / 2);
    
    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    
    // Zigzag arc
    final segments = 5;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = startPoint.dx + (endPoint.dx - startPoint.dx) * t;
      final y = startPoint.dy + math.sin(t * math.pi * 4) * 3 * progress;
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _DropdownSparkPainter ||
        oldDelegate.progress != progress;
  }
}