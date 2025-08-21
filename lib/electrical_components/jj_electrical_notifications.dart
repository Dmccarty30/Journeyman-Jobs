import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// Unified electrical-themed notification widgets
/// Includes toast, snack bar, and tooltip with lightning animations
class JJElectricalNotifications {
  
  /// Shows an electrical-themed toast notification
  static void showElectricalToast({
    required BuildContext context,
    required String message,
    ElectricalNotificationType type = ElectricalNotificationType.info,
    Duration duration = const Duration(seconds: 3),
    bool showLightning = true,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: ElectricalToast(
          message: message,
          type: type,
          showLightning: showLightning,
          onDismiss: () => overlayEntry.remove(),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
  
  /// Shows an electrical-themed snack bar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showElectricalSnackBar({
    required BuildContext context,
    required String message,
    ElectricalNotificationType type = ElectricalNotificationType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ElectricalSnackBarContent(
          message: message,
          type: type,
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: _getTypeColor(type),
                onPressed: onActionPressed ?? () {},
              )
            : null,
      ),
    );
  }
  
  /// Creates an electrical-themed tooltip
  static Widget electricalTooltip({
    required String message,
    required Widget child,
    ElectricalNotificationType type = ElectricalNotificationType.info,
  }) {
    return ElectricalTooltip(
      message: message,
      type: type,
      child: child,
    );
  }
  
  static Color _getTypeColor(ElectricalNotificationType type) {
    switch (type) {
      case ElectricalNotificationType.success:
        return const Color(0xFF10B981); // Green
      case ElectricalNotificationType.warning:
        return const Color(0xFFFFD700); // Yellow
      case ElectricalNotificationType.error:
        return const Color(0xFFDC2626); // Red
      case ElectricalNotificationType.info:
      default:
        return const Color(0xFF00D4FF); // Electric blue
    }
  }
}

/// Notification types with corresponding electrical themes
enum ElectricalNotificationType {
  success,  // Green power indicator
  warning,  // Yellow caution
  error,    // Red danger
  info,     // Blue electrical flow
}

/// Electrical-themed toast widget
class ElectricalToast extends StatefulWidget {
  const ElectricalToast({
    Key? key,
    required this.message,
    required this.onDismiss,
    this.type = ElectricalNotificationType.info,
    this.showLightning = true,
  }) : super(key: key);
  
  final String message;
  final ElectricalNotificationType type;
  final bool showLightning;
  final VoidCallback onDismiss;
  
  @override
  State<ElectricalToast> createState() => _ElectricalToastState();
}

class _ElectricalToastState extends State<ElectricalToast>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _lightningController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _lightningAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Slide in animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    // Lightning animation
    _lightningController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _lightningAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _lightningController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _slideController.forward();
    if (widget.showLightning) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _lightningController.forward();
      });
    }
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _lightningController.dispose();
    super.dispose();
  }
  
  void _dismiss() async {
    await _slideController.reverse();
    widget.onDismiss();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: JJElectricalNotifications._getTypeColor(widget.type),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: JJElectricalNotifications._getTypeColor(widget.type).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Circuit pattern background
              Positioned.fill(
                child: CustomPaint(
                  painter: _MiniCircuitPainter(
                    color: JJElectricalNotifications._getTypeColor(widget.type).withOpacity(0.1),
                  ),
                ),
              ),
              
              // Lightning animation
              if (widget.showLightning)
                AnimatedBuilder(
                  animation: _lightningAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _LightningPainter(
                        progress: _lightningAnimation.value,
                        color: JJElectricalNotifications._getTypeColor(widget.type),
                      ),
                    );
                  },
                ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Type icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: JJElectricalNotifications._getTypeColor(widget.type),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTypeIcon(widget.type),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Message
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Dismiss button
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getTypeIcon(ElectricalNotificationType type) {
    switch (type) {
      case ElectricalNotificationType.success:
        return Icons.check_circle;
      case ElectricalNotificationType.warning:
        return Icons.warning;
      case ElectricalNotificationType.error:
        return Icons.error;
      case ElectricalNotificationType.info:
      default:
        return Icons.info;
    }
  }
}

/// Electrical-themed snack bar content
class ElectricalSnackBarContent extends StatefulWidget {
  const ElectricalSnackBarContent({
    Key? key,
    required this.message,
    this.type = ElectricalNotificationType.info,
  }) : super(key: key);
  
  final String message;
  final ElectricalNotificationType type;
  
  @override
  State<ElectricalSnackBarContent> createState() => _ElectricalSnackBarContentState();
}

class _ElectricalSnackBarContentState extends State<ElectricalSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _glowController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: JJElectricalNotifications._getTypeColor(widget.type)
                  .withOpacity(_glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: JJElectricalNotifications._getTypeColor(widget.type)
                    .withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Circuit traces
              Positioned.fill(
                child: CustomPaint(
                  painter: _SnackBarCircuitPainter(
                    color: JJElectricalNotifications._getTypeColor(widget.type)
                        .withOpacity(0.2),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Electrical-themed tooltip
class ElectricalTooltip extends StatefulWidget {
  const ElectricalTooltip({
    Key? key,
    required this.message,
    required this.child,
    this.type = ElectricalNotificationType.info,
  }) : super(key: key);
  
  final String message;
  final Widget child;
  final ElectricalNotificationType type;
  
  @override
  State<ElectricalTooltip> createState() => _ElectricalTooltipState();
}

class _ElectricalTooltipState extends State<ElectricalTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;
  late Animation<double> _sparkAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sparkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _sparkController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.message,
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: JJElectricalNotifications._getTypeColor(widget.type),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: JJElectricalNotifications._getTypeColor(widget.type).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      onTriggered: () {
        _sparkController.forward().then((_) {
          _sparkController.reset();
        });
      },
      child: Stack(
        children: [
          widget.child,
          
          // Spark effect on hover/tap
          AnimatedBuilder(
            animation: _sparkAnimation,
            builder: (context, child) {
              if (_sparkAnimation.value == 0) return const SizedBox.shrink();
              
              return Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SparkEffectPainter(
                      progress: _sparkAnimation.value,
                      color: JJElectricalNotifications._getTypeColor(widget.type),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Mini circuit pattern painter for toast backgrounds
class _MiniCircuitPainter extends CustomPainter {
  final Color color;
  
  _MiniCircuitPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw simple circuit traces
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.3);
    
    canvas.drawPath(path, paint);
    
    // Add connection points
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 2, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 2, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Lightning bolt painter for dramatic entrances
class _LightningPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _LightningPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
    
    // Lightning bolt path
    final path = Path();
    final centerX = size.width * 0.1;
    final height = size.height * progress;
    
    path.moveTo(centerX, 0);
    path.lineTo(centerX + 8, height * 0.3);
    path.lineTo(centerX - 4, height * 0.5);
    path.lineTo(centerX + 6, height * 0.8);
    path.lineTo(centerX - 2, height);
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _LightningPainter ||
        oldDelegate.progress != progress;
  }
}

/// Circuit painter for snack bar backgrounds
class _SnackBarCircuitPainter extends CustomPainter {
  final Color color;
  
  _SnackBarCircuitPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Horizontal traces
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2), paint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.8), paint);
    
    // Vertical connections
    for (double x = 40; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, size.height * 0.2), Offset(x, size.height * 0.8), paint);
      canvas.drawCircle(Offset(x, size.height * 0.2), 2, paint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, size.height * 0.8), 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Spark effect painter for tooltips
class _SparkEffectPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _SparkEffectPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    final sparkCount = 8;
    final radius = progress * 30;
    
    for (int i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * math.pi * 2;
      final sparkRadius = radius * (0.5 + random.nextDouble() * 0.5);
      final x = size.width / 2 + math.cos(angle) * sparkRadius;
      final y = size.height / 2 + math.sin(angle) * sparkRadius;
      
      canvas.drawCircle(
        Offset(x, y),
        (1.0 - progress) * 3,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _SparkEffectPainter ||
        oldDelegate.progress != progress;
  }
}