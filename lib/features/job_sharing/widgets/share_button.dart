import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';

/// Share button with electrical theme and lightning animation
/// 
/// Features:
/// - Copper gradient background with lightning bolt icon
/// - Electrical pulse animation on tap
/// - Circuit pattern subtle overlay
/// - Customizable size and color variants
class JJShareButton extends StatefulWidget {
  /// The callback when the share button is pressed
  final VoidCallback? onPressed;
  
  /// Size variant of the button
  final JJShareButtonSize size;
  
  /// Style variant of the button
  final JJShareButtonVariant variant;
  
  /// Whether the button is in a loading state
  final bool isLoading;
  
  /// Optional tooltip text
  final String? tooltip;

  const JJShareButton({
    Key? key,
    required this.onPressed,
    this.size = JJShareButtonSize.medium,
    this.variant = JJShareButtonVariant.primary,
    this.isLoading = false,
    this.tooltip,
  }) : super(key: key);

  @override
  State<JJShareButton> createState() => _JJShareButtonState();
}

class _JJShareButtonState extends State<JJShareButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pulseController.forward().then((_) {
        _pulseController.reverse();
        setState(() => _isPressed = false);
      });
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();
    
    Widget button = AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: buttonConfig.size,
            height: buttonConfig.size,
            decoration: BoxDecoration(
              gradient: _isPressed ? buttonConfig.pressedGradient : buttonConfig.gradient,
              borderRadius: BorderRadius.circular(buttonConfig.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                if (_isPressed)
                  BoxShadow(
                    color: AppTheme.accentCopper.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(buttonConfig.borderRadius),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circuit pattern overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(buttonConfig.borderRadius),
                        ),
                        child: CustomPaint(
                          painter: CircuitPatternPainter(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1.0,
                          ),
                        ),
                      ),
                    ),
                    
                    // Loading or icon
                    if (widget.isLoading)
                      SizedBox(
                        width: buttonConfig.iconSize,
                        height: buttonConfig.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            buttonConfig.iconColor,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.flash_on_rounded,
                        size: buttonConfig.iconSize,
                        color: buttonConfig.iconColor,
                      )
                        .animate(trigger: _isPressed)
                        .shimmer(
                          duration: 400.ms,
                          color: Colors.white.withOpacity(0.8),
                        )
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.2, 1.2),
                          duration: 200.ms,
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.size) {
      case JJShareButtonSize.small:
        return _ButtonConfig(
          size: 36.0,
          iconSize: 18.0,
          borderRadius: AppTheme.radiusSm,
          gradient: widget.variant == JJShareButtonVariant.primary
              ? AppTheme.buttonGradient
              : _getSecondaryGradient(),
          pressedGradient: widget.variant == JJShareButtonVariant.primary
              ? _getPressedPrimaryGradient()
              : _getPressedSecondaryGradient(),
          iconColor: Colors.white,
        );
      case JJShareButtonSize.medium:
        return _ButtonConfig(
          size: 48.0,
          iconSize: 24.0,
          borderRadius: AppTheme.radiusMd,
          gradient: widget.variant == JJShareButtonVariant.primary
              ? AppTheme.buttonGradient
              : _getSecondaryGradient(),
          pressedGradient: widget.variant == JJShareButtonVariant.primary
              ? _getPressedPrimaryGradient()
              : _getPressedSecondaryGradient(),
          iconColor: Colors.white,
        );
      case JJShareButtonSize.large:
        return _ButtonConfig(
          size: 64.0,
          iconSize: 32.0,
          borderRadius: AppTheme.radiusLg,
          gradient: widget.variant == JJShareButtonVariant.primary
              ? AppTheme.buttonGradient
              : _getSecondaryGradient(),
          pressedGradient: widget.variant == JJShareButtonVariant.primary
              ? _getPressedPrimaryGradient()
              : _getPressedSecondaryGradient(),
          iconColor: Colors.white,
        );
    }
  }

  LinearGradient _getSecondaryGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppTheme.primaryNavy,
        AppTheme.secondaryNavy,
      ],
    );
  }

  LinearGradient _getPressedPrimaryGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFFD69E2E), // Light Copper
        AppTheme.accentCopper,
      ],
    );
  }

  LinearGradient _getPressedSecondaryGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppTheme.secondaryNavy,
        AppTheme.darkGray,
      ],
    );
  }
}

/// Configuration for different button variants
class _ButtonConfig {
  final double size;
  final double iconSize;
  final double borderRadius;
  final LinearGradient gradient;
  final LinearGradient pressedGradient;
  final Color iconColor;

  const _ButtonConfig({
    required this.size,
    required this.iconSize,
    required this.borderRadius,
    required this.gradient,
    required this.pressedGradient,
    required this.iconColor,
  });
}

/// Size variants for the share button
enum JJShareButtonSize {
  small,
  medium,
  large,
}

/// Style variants for the share button
enum JJShareButtonVariant {
  primary,
  secondary,
}

/// Custom painter for circuit pattern overlay
class CircuitPatternPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CircuitPatternPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 4;

    // Draw subtle circuit lines
    canvas.drawLine(
      Offset(centerX - radius, centerY),
      Offset(centerX + radius, centerY),
      paint,
    );
    
    canvas.drawLine(
      Offset(centerX, centerY - radius),
      Offset(centerX, centerY + radius),
      paint,
    );

    // Draw small circuit nodes
    final nodeRadius = strokeWidth * 1.5;
    canvas.drawCircle(Offset(centerX - radius / 2, centerY), nodeRadius, paint);
    canvas.drawCircle(Offset(centerX + radius / 2, centerY), nodeRadius, paint);
    canvas.drawCircle(Offset(centerX, centerY - radius / 2), nodeRadius, paint);
    canvas.drawCircle(Offset(centerX, centerY + radius / 2), nodeRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
