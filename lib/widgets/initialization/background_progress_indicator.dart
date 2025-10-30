import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/electrical_components.dart';

/// Subtle background progress indicator for ongoing operations
///
/// This widget provides a minimal, non-intrusive progress indicator that can
/// be displayed behind other content. Features include:
///
/// - Subtle visual progress indicators
/// - Electrical-themed animations and effects
/// - Multiple positioning options (top, bottom, overlay)
/// - Customizable colors and effects
/// - Accessibility support with proper labels
/// - Performance optimized with efficient animations
/// - Support for indeterminate and determinate progress
class BackgroundProgressIndicator extends StatefulWidget {
  /// Current progress value (0.0 to 1.0)
  final double progress;

  /// Whether the progress is indeterminate
  final bool isIndeterminate;

  /// Position of the progress indicator
  final BackgroundProgressPosition position;

  /// Height of the progress indicator
  final double height;

  /// Custom colors for the progress indicator
  final Color? color;

  /// Background color
  final Color? backgroundColor;

  /// Whether to show electrical effects
  final bool showElectricalEffects;

  /// Whether to show percentage text
  final bool showPercentage;

  /// Custom message to display
  final String? message;

  /// Whether to show pulse effects
  final bool showPulse;

  /// Custom animation duration
  final Duration? animationDuration;

  /// Callback when progress indicator is tapped
  final VoidCallback? onTap;

  /// Accessibility label for screen readers
  final String? accessibilityLabel;

  const BackgroundProgressIndicator({
    super.key,
    this.progress = 0.0,
    this.isIndeterminate = false,
    this.position = BackgroundProgressPosition.top,
    this.height = 4.0,
    this.color,
    this.backgroundColor,
    this.showElectricalEffects = true,
    this.showPercentage = false,
    this.message,
    this.showPulse = true,
    this.animationDuration,
    this.onTap,
    this.accessibilityLabel,
  });

  @override
  State<BackgroundProgressIndicator> createState() => _BackgroundProgressIndicatorState();
}

class _BackgroundProgressIndicatorState extends State<BackgroundProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  Timer? _sparkleTimer;
  final List<SparkleParticle> _sparkles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSparkleEffects();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _sparkleTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    final duration = widget.animationDuration ?? const Duration(milliseconds: 800);

    _progressController = AnimationController(
      duration: duration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1.5),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeOutBack,
    ));

    if (!widget.isIndeterminate) {
      _progressController.forward();
    }

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _startSparkleEffects() {
    if (!widget.showElectricalEffects) return;

    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted && _sparkles.length < 5) {
        setState(() {
          _sparkles.add(SparkleParticle(
            position: (widget.progress * 300.0) + (DateTime.now().millisecond % 100),
            size: 2.0 + (DateTime.now().millisecond % 4),
            opacity: 0.6 + (DateTime.now().millisecond % 40) / 100.0,
          ));
        });

        // Remove old sparkles
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _sparkles.removeWhere((sparkle) =>
                  sparkle.createdAt.difference(DateTime.now()).inSeconds > 2);
            });
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(BackgroundProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress && !widget.isIndeterminate) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward();
    }

    if (oldWidget.isIndeterminate != widget.isIndeterminate) {
      if (widget.isIndeterminate) {
        _progressController.repeat();
      } else {
        _progressController.stop();
        _progressController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == BackgroundProgressPosition.top ? 0.0 : null,
      bottom: widget.position == BackgroundProgressPosition.bottom ? 0.0 : null,
      left: 0.0,
      right: 0.0,
      child: Semantics(
        label: widget.accessibilityLabel ?? _getAccessibilityLabel(),
        value: '${(widget.progress * 100).toInt()}%',
        liveRegion: true,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: widget.height + (widget.message != null ? 40 : 0),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? _getBackgroundColor(),
              boxShadow: widget.showElectricalEffects ? _getElectricalShadow() : null,
            ),
            child: Stack(
              children: [
                // Background track
                _buildBackgroundTrack(),

                // Progress bar with electrical effects
                _buildProgressBar(),

                // Electrical sparkles
                if (widget.showElectricalEffects) _buildSparkles(),

                // Message and percentage
                if (widget.message != null || widget.showPercentage)
                  _buildMessageAndPercentage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundTrack() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppTheme.lightGray.withValues(alpha: 0.3),
          borderRadius: widget.position == BackgroundProgressPosition.overlay
              ? BorderRadius.circular(widget.height / 2)
              : null,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (widget.isIndeterminate) {
      return _buildIndeterminateProgress();
    } else {
      return _buildDeterminateProgress();
    }
  }

  Widget _buildDeterminateProgress() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: _getProgressGradient(),
                borderRadius: widget.position == BackgroundProgressPosition.overlay
                    ? BorderRadius.circular(widget.height / 2)
                    : null,
                boxShadow: widget.showElectricalEffects
                    ? [
                        BoxShadow(
                          color: (widget.color ?? AppTheme.accentCopper).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Electrical circuit pattern overlay
                  if (widget.showElectricalEffects)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CircuitPatternPainter(
                          color: AppTheme.white.withValues(alpha: 0.1),
                          progress: _progressAnimation.value,
                        ),
                      ),
                    ),

                  // Leading glow effect
                  if (widget.showPulse && widget.progress > 0.01)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 20,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.centerRight,
                                radius: _pulseAnimation.value,
                                colors: [
                                  AppTheme.white.withValues(alpha: 0.6),
                                  AppTheme.white.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildIndeterminateProgress() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          width: 50.0,
          margin: EdgeInsets.only(
            left: (_progressController.value * MediaQuery.of(context).size.width) % MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            gradient: _getProgressGradient(),
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: widget.showElectricalEffects
                ? [
                    BoxShadow(
                      color: (widget.color ?? AppTheme.accentCopper).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }

  Widget _buildSparkles() {
    return Positioned.fill(
      child: Stack(
        children: _sparkles.map((sparkle) {
          return Positioned(
            left: sparkle.position,
            top: widget.height / 2 - sparkle.size / 2,
            child: AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Container(
                  width: sparkle.size,
                  height: sparkle.size,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: sparkle.opacity * _sparkleAnimation.value),
                    borderRadius: BorderRadius.circular(sparkle.size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.white.withValues(alpha: sparkle.opacity * 0.5),
                        blurRadius: sparkle.size,
                      ),
                    ],
                  ),
                );
              },
            ).animate(controller: _sparkleController).fadeIn().scale(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageAndPercentage() {
    if (widget.position == BackgroundProgressPosition.top) {
      return Positioned(
        top: widget.height + 4,
        left: 0,
        right: 0,
        child: _buildMessageContent(),
      );
    } else {
      return Positioned(
        bottom: widget.height + 4,
        left: 0,
        right: 0,
        child: _buildMessageContent(),
      );
    }
  }

  Widget _buildMessageContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.message != null) ...[
          Flexible(
            child: Text(
              widget.message!,
              style: AppTheme.labelSmall.copyWith(
                color: widget.color ?? AppTheme.accentCopper,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.showPercentage) const SizedBox(width: AppTheme.spacingSm),
        ],
        if (widget.showPercentage)
          Text(
            '${(widget.progress * 100).toInt()}%',
            style: AppTheme.labelSmall.copyWith(
              color: widget.color ?? AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (widget.position) {
      case BackgroundProgressPosition.top:
      case BackgroundProgressPosition.bottom:
        return AppTheme.white.withValues(alpha: 0.1);
      case BackgroundProgressPosition.overlay:
        return Colors.transparent;
    }
  }

  LinearGradient _getProgressGradient() {
    final baseColor = widget.color ?? AppTheme.accentCopper;

    return LinearGradient(
      colors: [
        baseColor.withValues(alpha: 0.8),
        baseColor,
        baseColor.withValues(alpha: 0.9),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  List<BoxShadow> _getElectricalShadow() {
    final baseColor = widget.color ?? AppTheme.accentCopper;

    return [
      BoxShadow(
        color: baseColor.withValues(alpha: 0.3),
        blurRadius: 12,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: baseColor.withValues(alpha: 0.1),
        blurRadius: 24,
        spreadRadius: 4,
      ),
    ];
  }

  String _getAccessibilityLabel() {
    if (widget.message != null) {
      return '${widget.message}: ${(widget.progress * 100).toInt()}% complete';
    } else {
      return 'Progress: ${(widget.progress * 100).toInt()}% complete';
    }
  }
}

/// Position options for background progress indicator
enum BackgroundProgressPosition {
  /// Top of the screen
  top,

  /// Bottom of the screen
  bottom,

  /// Overlay on content
  overlay,
}

/// Sparkle particle for electrical effects
@immutable
class SparkleParticle {
  final double position;
  final double size;
  final double opacity;
  final DateTime createdAt;

  const SparkleParticle({
    required this.position,
    required this.size,
    required this.opacity,
  }) : createdAt = DateTime.now();
}

/// Custom painter for electrical circuit patterns
class CircuitPatternPainter extends CustomPainter {
  final Color color;
  final double progress;

  const CircuitPatternPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw simple circuit pattern
    final path = Path();
    final segmentWidth = size.width / 10;

    for (int i = 0; i < 10; i++) {
      final x = i * segmentWidth;
      if (x <= size.width * progress) {
        // Draw horizontal line
        path.moveTo(x, size.height / 2);
        path.lineTo(x + segmentWidth * 0.8, size.height / 2);

        // Draw vertical connection
        if (i % 2 == 0) {
          path.moveTo(x + segmentWidth * 0.4, size.height / 2);
          path.lineTo(x + segmentWidth * 0.4, size.height * 0.3);
        } else {
          path.moveTo(x + segmentWidth * 0.4, size.height / 2);
          path.lineTo(x + segmentWidth * 0.4, size.height * 0.7);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CircuitPatternPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Minimal progress bar with electrical styling
class MinimalElectricalProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final bool showGlow;

  const MinimalElectricalProgressBar({
    super.key,
    required this.progress,
    this.height = 2.0,
    this.color,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color ?? AppTheme.accentCopper,
                (color ?? AppTheme.accentCopper).withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: (color ?? AppTheme.accentCopper).withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// Circular progress indicator with electrical theme
class CircularElectricalProgressIndicator extends StatefulWidget {
  final double progress;
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showGlow;

  const CircularElectricalProgressIndicator({
    super.key,
    required this.progress,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.0,
    this.showGlow = true,
  });

  @override
  State<CircularElectricalProgressIndicator> createState() => _CircularElectricalProgressIndicatorState();
}

class _CircularElectricalProgressIndicatorState extends State<CircularElectricalProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: widget.progress,
                color: widget.color ?? AppTheme.accentCopper,
                strokeWidth: widget.strokeWidth,
                showGlow: widget.showGlow,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool showGlow;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.showGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppTheme.lightGray.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (showGlow) {
      progressPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 2);
    }

    final sweepAngle = (progress * 2 * 3.14159) - (3.14159 / 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Electrical arc effect
    if (progress > 0.1 && progress < 1.0) {
      final arcPaint = Paint()
        ..color = AppTheme.white.withValues(alpha: 0.6)
        ..strokeWidth = strokeWidth / 2
        ..style = PaintingStyle.stroke;

      final arcProgress = progress + 0.05;
      final arcSweepAngle = (arcProgress * 2 * 3.14159) - (3.14159 / 2);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        arcSweepAngle - 0.1,
        0.1,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}