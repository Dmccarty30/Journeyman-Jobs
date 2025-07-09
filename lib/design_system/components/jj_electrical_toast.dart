import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../illustrations/electrical_illustrations.dart';

/// Enum for different toast types with electrical themes
enum JJToastType {
  success,
  error,
  warning,
  info,
  power, // Custom electrical-themed variant
}

/// Electrical-themed toast component that matches the app design system
class JJElectricalToast extends StatelessWidget {
  final String message;
  final JJToastType type;
  final Duration? duration;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool showIcon;
  final bool showAnimation;
  final Widget? customIcon;

  const JJElectricalToast({
    super.key,
    required this.message,
    this.type = JJToastType.info,
    this.duration,
    this.onDismiss,
    this.actionLabel,
    this.onActionPressed,
    this.showIcon = true,
    this.showAnimation = true,
    this.customIcon,
  });

  /// Show a success toast with electrical theme
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showAnimation = true,
  }) {
    _showToast(
      context: context,
      toast: JJElectricalToast(
        message: message,
        type: JJToastType.success,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showAnimation: showAnimation,
      ),
    );
  }

  /// Show an error toast with electrical theme
  static void showError({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showAnimation = true,
  }) {
    _showToast(
      context: context,
      toast: JJElectricalToast(
        message: message,
        type: JJToastType.error,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showAnimation: showAnimation,
      ),
    );
  }

  /// Show a warning toast with electrical theme
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showAnimation = true,
  }) {
    _showToast(
      context: context,
      toast: JJElectricalToast(
        message: message,
        type: JJToastType.warning,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showAnimation: showAnimation,
      ),
    );
  }

  /// Show an info toast with electrical theme
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showAnimation = true,
  }) {
    _showToast(
      context: context,
      toast: JJElectricalToast(
        message: message,
        type: JJToastType.info,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showAnimation: showAnimation,
      ),
    );
  }

  /// Show a power/electrical-themed toast
  static void showPower({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showAnimation = true,
  }) {
    _showToast(
      context: context,
      toast: JJElectricalToast(
        message: message,
        type: JJToastType.power,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showAnimation: showAnimation,
      ),
    );
  }

  /// Custom toast with user-defined icon
  static void showCustom({
    required BuildContext context,
    required String message,
    required Widget icon,
    JJToastType type = JJToastType.info,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showAnimation = true,
  }) {
    _showToast(
      context: context,
      toast: JJElectricalToast(
        message: message,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showAnimation: showAnimation,
        customIcon: icon,
      ),
    );
  }

  /// Internal method to show the toast using OverlayEntry
  static void _showToast({
    required BuildContext context,
    required JJElectricalToast toast,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        toast: toast,
        onDismiss: () {
          overlayEntry.remove();
          toast.onDismiss?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    final duration = toast.duration ?? _getDefaultDuration(toast.type);
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        toast.onDismiss?.call();
      }
    });
  }

  /// Get default duration based on toast type
  static Duration _getDefaultDuration(JJToastType type) {
    switch (type) {
      case JJToastType.success:
        return const Duration(seconds: 3);
      case JJToastType.error:
        return const Duration(seconds: 5);
      case JJToastType.warning:
        return const Duration(seconds: 4);
      case JJToastType.info:
        return const Duration(seconds: 3);
      case JJToastType.power:
        return const Duration(seconds: 4);
    }
  }

  /// Get theme configuration for each toast type
  _ToastTheme _getToastTheme() {
    switch (type) {
      case JJToastType.success:
        return _ToastTheme(
          backgroundColor: AppTheme.successGreen,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.check_circle,
          illustration: ElectricalIllustration.success,
        );
      case JJToastType.error:
        return _ToastTheme(
          backgroundColor: AppTheme.errorRed,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.error,
          illustration: ElectricalIllustration.maintenance,
        );
      case JJToastType.warning:
        return _ToastTheme(
          backgroundColor: AppTheme.warningYellow,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.warning,
          illustration: ElectricalIllustration.voltMeter,
        );
      case JJToastType.info:
        return _ToastTheme(
          backgroundColor: AppTheme.primaryNavy,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.info,
          illustration: ElectricalIllustration.circuitBoard,
        );
      case JJToastType.power:
        return _ToastTheme(
          backgroundColor: AppTheme.accentCopper,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.flash_on,
          illustration: ElectricalIllustration.powerGrid,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getToastTheme();
    
    Widget iconWidget;
    if (customIcon != null) {
      iconWidget = customIcon!;
    } else if (showIcon) {
      iconWidget = _ElectricalToastIcon(
        theme: theme,
        showAnimation: showAnimation,
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 32,
        minHeight: 56,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          AppTheme.shadowLg,
          // Add an electrical glow effect
          BoxShadow(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon || customIcon != null) ...[
            iconWidget,
            const SizedBox(width: AppTheme.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: AppTheme.bodyMedium.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  TextButton(
                    onPressed: onActionPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.textColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel!,
                      style: AppTheme.labelMedium.copyWith(
                        color: theme.textColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          // Electrical-themed progress indicator
          _ElectricalProgressIndicator(
            color: theme.textColor,
            duration: duration ?? _getDefaultDuration(type),
          ),
        ],
      ),
    );
  }
}

/// Theme configuration for toast types
class _ToastTheme {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final ElectricalIllustration illustration;

  const _ToastTheme({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.illustration,
  });
}

/// Electrical-themed toast icon with animations
class _ElectricalToastIcon extends StatelessWidget {
  final _ToastTheme theme;
  final bool showAnimation;

  const _ElectricalToastIcon({
    required this.theme,
    required this.showAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.iconColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: theme.iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          theme.icon,
          size: AppTheme.iconSm,
          color: theme.iconColor,
        ),
      ),
    );

    if (showAnimation) {
      iconWidget = iconWidget
          .animate()
          .scale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          )
          .then()
          .shimmer(
            duration: const Duration(milliseconds: 800),
            color: theme.iconColor.withValues(alpha: 0.3),
          );
    }

    return iconWidget;
  }
}

/// Electrical-themed progress indicator for toast duration
class _ElectricalProgressIndicator extends StatefulWidget {
  final Color color;
  final Duration duration;

  const _ElectricalProgressIndicator({
    required this.color,
    required this.duration,
  });

  @override
  State<_ElectricalProgressIndicator> createState() =>
      _ElectricalProgressIndicatorState();
}

class _ElectricalProgressIndicatorState
    extends State<_ElectricalProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 4,
      height: 40,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ElectricalProgressPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for electrical-themed progress indicator
class _ElectricalProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ElectricalProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      trackPaint,
    );

    // Progress indicator with electrical styling
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final progressHeight = size.height * progress;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, progressHeight),
      progressPaint,
    );

    // Add electrical sparks effect
    if (progress > 0.1) {
      final sparkPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1;

      for (int i = 0; i < 3; i++) {
        final sparkY = progressHeight + (i * 2);
        if (sparkY < size.height) {
          canvas.drawCircle(
            Offset(size.width / 2, sparkY),
            1,
            sparkPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ElectricalProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Overlay widget to position and animate the toast
class _ToastOverlay extends StatefulWidget {
  final JJElectricalToast toast;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.toast,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + AppTheme.spacingMd,
      left: AppTheme.spacingMd,
      right: AppTheme.spacingMd,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _dismiss,
          onPanUpdate: (details) {
            if (details.delta.dy < -5) {
              _dismiss();
            }
          },
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.toast,
            ),
          ),
        ),
      ),
    );
  }
}