import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/hierarchical/hierarchical_types.dart';
import '../../../electrical_components/electrical_components.dart';

/// Individual stage progress indicator for hierarchical initialization
///
/// This widget displays the progress of a single initialization stage with
/// electrical-themed animations, level badges, and accessibility support.
/// Features include:
///
/// - Visual progress indicators with electrical animations
/// - Level badges (0-4) for hierarchical structure
/// - Status icons (pending, in-progress, completed, failed)
/// - Estimated time display
/// - Compact and expanded modes
/// - Accessibility labels for screen readers
/// - Error states with retry indicators
class StageProgressIndicator extends StatefulWidget {
  /// The initialization stage to display
  final InitializationStage stage;

  /// Progress information for this stage
  final StageProgress progress;

  /// Whether to show the level badge
  final bool showLevelBadge;

  /// Whether to show the estimated time
  final bool showEstimatedTime;

  /// Whether to use compact layout
  final bool compact;

  /// Callback when stage is tapped
  final VoidCallback? onTap;

  /// Custom styling options
  final StageProgressStyle? style;

  const StageProgressIndicator({
    super.key,
    required this.stage,
    required this.progress,
    this.showLevelBadge = true,
    this.showEstimatedTime = true,
    this.compact = false,
    this.onTap,
    this.style,
  });

  @override
  State<StageProgressIndicator> createState() => _StageProgressIndicatorState();
}

class _StageProgressIndicatorState extends State<StageProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startProgressAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1.5),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    // Start pulse animation for in-progress stages
    if (widget.progress.status == StageStatus.inProgress) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _startProgressAnimation() {
    if (widget.progress.status == StageStatus.inProgress) {
      _progressController.forward();
    } else if (widget.progress.status == StageStatus.completed) {
      _progressController.value = 1.0;
    } else {
      _progressController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(StageProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animations when progress changes
    if (oldWidget.progress.status != widget.progress.status) {
      if (widget.progress.status == StageStatus.inProgress) {
        _pulseController.repeat(reverse: true);
        _progressController.forward();
      } else if (widget.progress.status == StageStatus.completed) {
        _pulseController.stop();
        _progressController.animateTo(1.0);
      } else {
        _pulseController.stop();
        _progressController.animateTo(0.0);
      }
    }

    if (oldWidget.progress.progress != widget.progress.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? StageProgressStyle.defaultStyle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: _getSemanticLabel(),
      button: widget.onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(style.borderRadius),
          child: Container(
            padding: widget.compact
                ? style.compactPadding
                : style.expandedPadding,
            decoration: _getDecoration(style, isDark),
            child: widget.compact
                ? _buildCompactLayout(style)
                : _buildExpandedLayout(style),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(delay: 50.ms);
  }

  BoxDecoration _getDecoration(StageProgressStyle style, bool isDark) {
    return BoxDecoration(
      color: _getBackgroundColor(isDark),
      borderRadius: BorderRadius.circular(style.borderRadius),
      border: Border.all(
        color: _getBorderColor(),
        width: style.borderWidth,
      ),
      boxShadow: _getBoxShadow(),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (widget.progress.status == StageStatus.failed) {
      return AppTheme.errorRed.withValues(alpha: 0.1);
    } else if (widget.progress.status == StageStatus.completed) {
      return AppTheme.successGreen.withValues(alpha: 0.1);
    } else if (widget.progress.status == StageStatus.inProgress) {
      return AppTheme.accentCopper.withValues(alpha: 0.1);
    } else {
      return isDark
          ? AppTheme.darkSurface.withValues(alpha: 0.5)
          : AppTheme.white.withValues(alpha: 0.8);
    }
  }

  Color _getBorderColor() {
    if (widget.progress.status == StageStatus.failed) {
      return AppTheme.errorRed;
    } else if (widget.progress.status == StageStatus.completed) {
      return AppTheme.successGreen;
    } else if (widget.progress.status == StageStatus.inProgress) {
      return AppTheme.accentCopper;
    } else {
      return AppTheme.lightGray;
    }
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.progress.status == StageStatus.inProgress) {
      return [
        BoxShadow(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (widget.progress.status == StageStatus.failed) {
      return [
        BoxShadow(
          color: AppTheme.errorRed.withValues(alpha: 0.2),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ];
    } else if (widget.progress.status == StageStatus.completed) {
      return [
        BoxShadow(
          color: AppTheme.successGreen.withValues(alpha: 0.2),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ];
    } else {
      return [AppTheme.shadowXs];
    }
  }

  Widget _buildExpandedLayout(StageProgressStyle style) {
    return Row(
      children: [
        // Status icon with electrical animation
        _buildStatusIcon(),

        const SizedBox(width: AppTheme.spacingMd),

        // Stage information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stage name with level badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.stage.displayName,
                      style: style.titleStyle.copyWith(
                        color: _getTextColor(),
                        fontWeight: widget.progress.status == StageStatus.completed
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (widget.showLevelBadge) ...[
                    const SizedBox(width: AppTheme.spacingSm),
                    _buildLevelBadge(),
                  ],
                ],
              ),

              // Stage description
              if (!widget.compact) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  widget.stage.description,
                  style: style.descriptionStyle.copyWith(
                    color: _getTextColor().withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Progress bar and time
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: _buildProgressBar(),
                  ),
                  if (widget.showEstimatedTime) ...[
                    const SizedBox(width: AppTheme.spacingMd),
                    _buildTimeDisplay(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(StageProgressStyle style) {
    return Row(
      children: [
        // Status icon
        _buildStatusIcon(compact: true),

        const SizedBox(width: AppTheme.spacingMd),

        // Stage name and progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.stage.displayName,
                      style: style.compactTitleStyle.copyWith(
                        color: _getTextColor(),
                      ),
                    ),
                  ),
                  if (widget.showLevelBadge) _buildLevelBadge(compact: true),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXs),
              _buildProgressBar(compact: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon({bool compact = false}) {
    final iconSize = compact ? AppTheme.iconSm : AppTheme.iconMd;
    final iconColor = _getIconColor();

    if (widget.progress.status == StageStatus.inProgress) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: iconSize + 8,
              height: iconSize + 8,
              decoration: BoxDecoration(
                gradient: AppTheme.electricalGradient,
                borderRadius: BorderRadius.circular(iconSize / 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCopper.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.electrical_services,
                color: AppTheme.white,
                size: iconSize,
              ),
            ),
          );
        },
      );
    } else if (widget.progress.status == StageStatus.completed) {
      return Container(
        width: iconSize + 8,
        height: iconSize + 8,
        decoration: BoxDecoration(
          color: AppTheme.successGreen,
          borderRadius: BorderRadius.circular(iconSize / 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successGreen.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.check,
          color: AppTheme.white,
          size: iconSize,
        ),
      );
    } else if (widget.progress.status == StageStatus.failed) {
      return Container(
        width: iconSize + 8,
        height: iconSize + 8,
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(iconSize / 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.error,
          color: AppTheme.white,
          size: iconSize,
        ),
      );
    } else {
      return Container(
        width: iconSize + 8,
        height: iconSize + 8,
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(iconSize / 2),
        ),
        child: Icon(
          Icons.schedule,
          color: AppTheme.textLight,
          size: iconSize,
        ),
      );
    }
  }

  Widget _buildLevelBadge({bool compact = false}) {
    final badgeSize = compact ? 20.0 : 24.0;
    final fontSize = compact ? 10.0 : 12.0;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getLevelColor(widget.stage.level),
            _getLevelColor(widget.stage.level).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(badgeSize / 2),
        border: Border.all(
          color: AppTheme.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getLevelColor(widget.stage.level).withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${widget.stage.level}',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({bool compact = false}) {
    final height = compact ? 3.0 : 6.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: _getProgressGradient(),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeDisplay() {
    if (widget.progress.status == StageStatus.completed && widget.progress.duration != null) {
      return Text(
        _formatDuration(widget.progress.duration!),
        style: AppTheme.labelSmall.copyWith(
          color: AppTheme.successGreen,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (widget.progress.status == StageStatus.inProgress) {
      return Text(
        _formatDuration(DateTime.now().difference(widget.progress.startTime)),
        style: AppTheme.labelSmall.copyWith(
          color: AppTheme.accentCopper,
        ),
      );
    } else {
      return Text(
        _formatDuration(widget.stage.estimatedDuration),
        style: AppTheme.labelSmall.copyWith(
          color: AppTheme.textLight,
        ),
      );
    }
  }

  LinearGradient _getProgressGradient() {
    if (widget.progress.status == StageStatus.completed) {
      return LinearGradient(
        colors: [AppTheme.successGreen, AppTheme.successGreen.withValues(alpha: 0.8)],
      );
    } else if (widget.progress.status == StageStatus.failed) {
      return LinearGradient(
        colors: [AppTheme.errorRed, AppTheme.errorRed.withValues(alpha: 0.8)],
      );
    } else {
      return AppTheme.electricalGradient;
    }
  }

  Color _getIconColor() {
    if (widget.progress.status == StageStatus.completed) {
      return AppTheme.successGreen;
    } else if (widget.progress.status == StageStatus.failed) {
      return AppTheme.errorRed;
    } else if (widget.progress.status == StageStatus.inProgress) {
      return AppTheme.accentCopper;
    } else {
      return AppTheme.textLight;
    }
  }

  Color _getTextColor() {
    if (widget.progress.status == StageStatus.completed) {
      return AppTheme.successGreen;
    } else if (widget.progress.status == StageStatus.failed) {
      return AppTheme.errorRed;
    } else {
      return Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return AppTheme.primaryNavy; // Core infrastructure
      case 1:
        return AppTheme.accentCopper; // User data
      case 2:
        return AppTheme.successGreen; // Core data
      case 3:
        return AppTheme.infoBlue; // Features
      case 4:
        return AppTheme.warningYellow; // Advanced
      default:
        return AppTheme.mediumGray;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  String _getSemanticLabel() {
    final status = widget.progress.status.name;
    final stageName = widget.stage.displayName;
    final progress = (widget.progress.progress * 100).toInt();

    return '$stageName stage: $status, $progress% complete. ${widget.stage.description}';
  }
}

/// Styling options for stage progress indicators
@immutable
class StageProgressStyle {
  final TextStyle titleStyle;
  final TextStyle compactTitleStyle;
  final TextStyle descriptionStyle;
  final EdgeInsets expandedPadding;
  final EdgeInsets compactPadding;
  final double borderRadius;
  final double borderWidth;

  const StageProgressStyle({
    required this.titleStyle,
    required this.compactTitleStyle,
    required this.descriptionStyle,
    required this.expandedPadding,
    required this.compactPadding,
    required this.borderRadius,
    required this.borderWidth,
  });

  factory StageProgressStyle.defaultStyle => const StageProgressStyle(
    titleStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    compactTitleStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    descriptionStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    expandedPadding: EdgeInsets.all(16),
    compactPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    borderRadius: 12.0,
    borderWidth: 1.5,
  );

  factory StageProgressStyle.minimal => const StageProgressStyle(
    titleStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    compactTitleStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    descriptionStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    expandedPadding: EdgeInsets.all(12),
    compactPadding: EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    borderRadius: 8.0,
    borderWidth: 1.0,
  );
}

/// Stage status enumeration
enum StageStatus {
  pending,
  inProgress,
  completed,
  failed,
  skipped,
}

/// Extension methods for StageStatus
extension StageStatusExtensions on StageStatus {
  bool get isActive => this == StageStatus.inProgress;
  bool get isComplete => this == StageStatus.completed;
  bool get hasError => this == StageStatus.failed;
  bool get isWaiting => this == StageStatus.pending;
  bool get isSkipped => this == StageStatus.skipped;

  String get displayName {
    switch (this) {
      case StageStatus.pending:
        return 'Pending';
      case StageStatus.inProgress:
        return 'In Progress';
      case StageStatus.completed:
        return 'Completed';
      case StageStatus.failed:
        return 'Failed';
      case StageStatus.skipped:
        return 'Skipped';
    }
  }

  IconData get icon {
    switch (this) {
      case StageStatus.pending:
        return Icons.schedule;
      case StageStatus.inProgress:
        return Icons.electrical_services;
      case StageStatus.completed:
        return Icons.check_circle;
      case StageStatus.failed:
        return Icons.error;
      case StageStatus.skipped:
        return Icons.skip_next;
    }
  }
}