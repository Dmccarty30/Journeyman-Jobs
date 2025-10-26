import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/app_theme.dart';

/// Electrical themed loader component with circuit animation
class JJElectricalLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final String? message;
  final Color? color;

  const JJElectricalLoader({
    super.key,
    this.width,
    this.height,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Electrical circuit animation
        Container(
          width: width ?? 200,
          height: height ?? 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                color ?? AppTheme.accentCopper,
                AppTheme.primaryNavy,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            children: [
              // Animated circuit lines
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: const AlwaysStoppedAnimation(0),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ElectricalCircuitPainter(
                        color: AppTheme.white,
                        progress: 0.5,
                      ),
                    );
                  },
                ),
              ),
              // Loading indicator
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        ),
        
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
        ],
      ],
    );
  }
}

/// Custom painter for electrical circuit animation
class ElectricalCircuitPainter extends CustomPainter {
  final Color color;
  final double progress;

  const ElectricalCircuitPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw circuit pattern
    final centerY = size.height / 2;
    final amplitude = size.height * 0.3;
    
    for (double x = 0; x <= size.width; x += 20) {
      final y = centerY + amplitude * sin((x / size.width) * 2 * 3.14159) * progress;
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw connection points
    for (double x = 0; x <= size.width; x += 40) {
      final y = centerY + amplitude * sin((x / size.width) * 2 * 3.14159) * progress;
      
      canvas.drawCircle(
        Offset(x, y),
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ElectricalCircuitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Electrical themed button with circuit effects
class JJElectricalButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const JJElectricalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  State<JJElectricalButton> createState() => _JJElectricalButtonState();
}

class _JJElectricalButtonState extends State<JJElectricalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.backgroundColor ?? AppTheme.accentCopper,
                  (widget.backgroundColor ?? AppTheme.accentCopper).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? AppTheme.accentCopper).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.isLoading ? null : () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onPressed();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor ?? AppTheme.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.text,
                            style: AppTheme.button.copyWith(
                              color: widget.textColor ?? AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Electrical themed card with circuit border effects
class JJElectricalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;

  const JJElectricalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          onTap: onTap,
          child: child,
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

/// Electrical themed input field with circuit effects
class JJElectricalTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? Function(String)? validator;
  final int? maxLines;
  final bool enabled;

  const JJElectricalTextField({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<JJElectricalTextField> createState() => _JJElectricalTextFieldState();
}

class _JJElectricalTextFieldState extends State<JJElectricalTextField> {
  bool _isFocused = false;
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? AppTheme.accentCopper
              : AppTheme.accentCopper.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.accentCopper.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textPrimary,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        validator: widget.validator,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
}