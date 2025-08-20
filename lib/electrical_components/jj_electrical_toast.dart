import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/app_theme.dart';

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

  /// A toast widget that displays a message with an optional icon, action button, and animation.
  ///
  /// Parameters:
  /// - [message]: The text to display.
  /// - [type]: The visual style of the toast (default: [JJToastType.info]).
  /// - [duration]: How long the toast stays visible; if null, a default based on [type] is used.
  /// - [onDismiss]: Callback invoked when the toast is dismissed.
  /// - [actionLabel]: Text for an optional action button.
  /// - [onActionPressed]: Callback for the action button press.
  /// - [showIcon]: Whether to display the default icon for the toast type.
  /// - [showAnimation]: Whether to animate the toast appearance.
  /// - [customIcon]: Custom widget to use as the icon instead of the default.
  const JJElectricalToast({
    required this.message, super.key,
    this.type = JJToastType.info,
    this.duration,
    this.onDismiss,
    this.actionLabel,
    this.onActionPressed,
    this.showIcon = true,
    this.showAnimation = true,
    this.customIcon,
  });
  /// The message displayed in the toast.
  final String message;
  /// The type of toast determining its visual style.
  final JJToastType type;
  /// Optional custom duration; if omitted, a default is used.
  final Duration? duration;
  /// Callback invoked when the toast is dismissed.
  final VoidCallback? onDismiss;
  /// Optional label for an action button.
  final String? actionLabel;
  /// Callback for when the action button is pressed.
  final VoidCallback? onActionPressed;
  /// Whether to show the default icon.
  final bool showIcon;
  /// Whether to animate the toast.
  final bool showAnimation;
  /// Optional custom icon widget.
  final Widget? customIcon;

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
    final OverlayState overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => _ToastOverlay(
        toast: toast,
        onDismiss: () {
          overlayEntry.remove();
          toast.onDismiss?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    final Duration duration = toast.duration ?? _getDefaultDuration(toast.type);
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
        return const _ToastTheme(
          backgroundColor: AppTheme.successGreen,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.check_circle,
          // Using a generic icon as placeholder; replace with appropriate illustration if needed.
          illustration: Icons.flash_on,
        );
      case JJToastType.error:
        return const _ToastTheme(
          backgroundColor: AppTheme.errorRed,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.error,
          illustration: Icons.build,
        );
      case JJToastType.warning:
        return const _ToastTheme(
          backgroundColor: AppTheme.warningYellow,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.warning,
          illustration: Icons.bolt,
        );
      case JJToastType.info:
        return const _ToastTheme(
          backgroundColor: AppTheme.primaryNavy,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.info,
          illustration: Icons.memory,
        );
      case JJToastType.power:
        return const _ToastTheme(
          backgroundColor: AppTheme.accentCopper,
          iconColor: AppTheme.white,
          textColor: AppTheme.white,
          icon: Icons.flash_on,
          illustration: Icons.power,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ToastTheme theme = _getToastTheme();
    
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
        boxShadow: <BoxShadow>[
          AppTheme.shadowLg,
          // Add an electrical glow effect
          BoxShadow(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showIcon || customIcon != null) ...<Widget>[
            iconWidget,
            const SizedBox(width: AppTheme.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message,
                  style: AppTheme.bodyMedium.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (actionLabel != null) ...<Widget>[
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

  const _ToastTheme({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.illustration,
  });
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  /// Illustration displayed alongside the toast.
  final IconData? illustration;
}

/// Electrical-themed toast icon with animations
class _ElectricalToastIcon extends StatelessWidget {

  const _ElectricalToastIcon({
    required this.theme,
    required this.showAnimation,
  });
  final _ToastTheme theme;
  final bool showAnimation;

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
            end: const Offset(1, 1),
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

  const _ElectricalProgressIndicator({
    required this.color,
    required this.duration,
  });
  final Color color;
  final Duration duration;

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
    _animation = Tween<double>(begin: 1, end: 0).animate(
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
  Widget build(BuildContext context) => SizedBox(
      width: 4,
      height: 40,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) => CustomPaint(
            painter: _ElectricalProgressPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          ),
      ),
    );
}

/// Custom painter for electrical-themed progress indicator
class _ElectricalProgressPainter extends CustomPainter {

  _ElectricalProgressPainter({
    required this.progress,
    required this.color,
  });
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final Paint trackPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      trackPaint,
    );

    // Progress indicator with electrical styling
    final Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final double progressHeight = size.height * progress;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, progressHeight),
      progressPaint,
    );

    // Add electrical sparks effect
    if (progress > 0.1) {
      final Paint sparkPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1;

      for (int i = 0; i < 3; i++) {
        final double sparkY = progressHeight + (i * 2);
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
  bool shouldRepaint(covariant _ElectricalProgressPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Overlay widget to position and animate the toast
class _ToastOverlay extends StatefulWidget {

  const _ToastOverlay({
    required this.toast,
    required this.onDismiss,
  });
  final JJElectricalToast toast;
  final VoidCallback onDismiss;

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
    ),);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ),);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) => Positioned(
      top: MediaQuery.of(context).viewPadding.top + AppTheme.spacingMd,
      left: AppTheme.spacingMd,
      right: AppTheme.spacingMd,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _dismiss,
          onPanUpdate: (DragUpdateDetails details) {
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