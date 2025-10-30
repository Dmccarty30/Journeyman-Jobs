import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../electrical_components/electrical_components.dart';

/// Error recovery widget for initialization failures
///
/// This widget provides users with clear error information and recovery options
/// when initialization fails. Features include:
///
/// - Detailed error messages with technical information
/// - Multiple recovery options (retry, skip, contact support)
/// - Electrical-themed error states with animations
/// - Accessibility support for error announcements
/// - Optional error reporting and diagnostics
/// - Graceful degradation and fallback options
/// - Integration with app navigation and support systems
class ErrorRecoveryWidget extends StatefulWidget {
  /// The error message to display
  final String error;

  /// Optional stack trace for technical details
  final StackTrace? stackTrace;

  /// Callback when user wants to retry the operation
  final VoidCallback? onRetry;

  /// Callback when user wants to dismiss the error
  final VoidCallback? onDismiss;

  /// Callback when user wants to contact support
  final VoidCallback? onContactSupport;

  /// Callback when user wants to view diagnostics
  final VoidCallback? onViewDiagnostics;

  /// Whether the error can be dismissed
  final bool canDismiss;

  /// Whether to show technical details
  final bool showTechnicalDetails;

  /// Whether to show contact support option
  final bool showContactSupport;

  /// Whether to show diagnostics option
  final bool showDiagnostics;

  /// Custom error title
  final String? title;

  /// Custom error description
  final String? description;

  /// Suggested recovery actions
  final List<String>? suggestedActions;

  const ErrorRecoveryWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.onDismiss,
    this.onContactSupport,
    this.onViewDiagnostics,
    this.canDismiss = false,
    this.showTechnicalDetails = false,
    this.showContactSupport = true,
    this.showDiagnostics = true,
    this.title,
    this.description,
    this.suggestedActions,
  });

  @override
  State<ErrorRecoveryWidget> createState() => _ErrorRecoveryWidgetState();
}

class _ErrorRecoveryWidgetState extends State<ErrorRecoveryWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _shakeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _showTechnicalDetails = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _showTechnicalDetails = widget.showTechnicalDetails;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildErrorCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: AppTheme.errorRed,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                AppTheme.shadowLg,
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error header
                _buildErrorHeader(),

                // Error content
                _buildErrorContent(),

                // Error actions
                _buildErrorActions(),

                // Technical details (if shown)
                if (_showTechnicalDetails) _buildTechnicalDetails(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXl),
          topRight: Radius.circular(AppTheme.radiusXl),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.errorRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Error icon with animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.errorRed.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppTheme.white,
                    size: AppTheme.iconLg,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // Error title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Initialization Failed',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  widget.description ?? 'An error occurred during app initialization',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Dismiss button (if allowed)
          if (widget.canDismiss)
            IconButton(
              onPressed: widget.onDismiss,
              icon: const Icon(Icons.close),
              color: AppTheme.textLight,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.errorRed.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error,
                      size: AppTheme.iconSm,
                      color: AppTheme.errorRed,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      'Error Details',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  widget.error,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Suggested actions
          if (widget.suggestedActions != null && widget.suggestedActions!.isNotEmpty) ...[
            Text(
              'Suggested Actions:',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...widget.suggestedActions!.map((action) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: AppTheme.iconSm,
                    color: AppTheme.warningYellow,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      action,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: AppTheme.spacingLg),
          ],

          // Recovery options
          Text(
            'Recovery Options:',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorActions() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        children: [
          // Retry button
          if (widget.onRetry != null)
            JJButton(
              text: _isRetrying ? 'Retrying...' : 'Retry Initialization',
              onPressed: _isRetrying ? null : _handleRetry,
              variant: JJButtonVariant.primary,
              isFullWidth: true,
              isLoading: _isRetrying,
              icon: Icons.refresh,
            ),

          if (widget.onRetry != null) const SizedBox(height: AppTheme.spacingMd),

          // Secondary actions
          Row(
            children: [
              // Contact support
              if (widget.showContactSupport && widget.onContactSupport != null)
                Expanded(
                  child: JJButton(
                    text: 'Contact Support',
                    onPressed: widget.onContactSupport,
                    variant: JJButtonVariant.outline,
                    icon: Icons.support_agent,
                  ),
                ),

              if (widget.showContactSupport && widget.onContactSupport != null &&
                  widget.showDiagnostics && widget.onViewDiagnostics != null)
                const SizedBox(width: AppTheme.spacingMd),

              // View diagnostics
              if (widget.showDiagnostics && widget.onViewDiagnostics != null)
                Expanded(
                  child: JJButton(
                    text: 'Diagnostics',
                    onPressed: widget.onViewDiagnostics,
                    variant: JJButtonVariant.secondary,
                    icon: Icons.bug_report,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Technical details toggle
          GestureDetector(
            onTap: _toggleTechnicalDetails,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.lightGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    _showTechnicalDetails
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Technical Details',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingLg),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.primaryNavy.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                size: AppTheme.iconSm,
                color: AppTheme.primaryNavy,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Technical Information',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Stack trace (if available)
          if (widget.stackTrace != null) ...[
            Text(
              'Stack Trace:',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                widget.stackTrace.toString(),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],

          // System information
          _buildSystemInfo(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY();
  }

  Widget _buildSystemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Information:',
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        _buildInfoRow('Platform', Theme.of(context).platform.name),
        _buildInfoRow('Error Time', DateTime.now().toString()),
        _buildInfoRow('App Version', '1.0.0'), // This should come from app config
        if (widget.canRetry)
          _buildInfoRow('Can Retry', 'Yes'),
        if (widget.canDismiss)
          _buildInfoRow('Can Dismiss', 'Yes'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRetry() async {
    if (_isRetrying || widget.onRetry == null) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      await widget.onRetry!();
    } catch (e) {
      // If retry fails, shake the animation
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  void _toggleTechnicalDetails() {
    setState(() {
      _showTechnicalDetails = !_showTechnicalDetails;
    });
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error recovery options model
@immutable
class ErrorRecoveryOptions {
  final bool canRetry;
  final bool canSkip;
  final bool canDismiss;
  final bool canContactSupport;
  final bool canReportBug;
  final bool canViewDiagnostics;

  const ErrorRecoveryOptions({
    this.canRetry = true,
    this.canSkip = false,
    this.canDismiss = false,
    this.canContactSupport = true,
    this.canReportBug = true,
    this.canViewDiagnostics = true,
  });
}

/// Extension for easy error recovery option creation
extension ErrorRecoveryOptionsExtension on ErrorRecoveryOptions {
  static ErrorRecoveryOptions forCriticalError() => const ErrorRecoveryOptions(
    canRetry: true,
    canSkip: false,
    canDismiss: false,
    canContactSupport: true,
    canReportBug: true,
    canViewDiagnostics: true,
  );

  static ErrorRecoveryOptions forNonCriticalError() => const ErrorRecoveryOptions(
    canRetry: true,
    canSkip: true,
    canDismiss: true,
    canContactSupport: true,
    canReportBug: false,
    canViewDiagnostics: false,
  );

  static ErrorRecoveryOptions forNetworkError() => const ErrorRecoveryOptions(
    canRetry: true,
    canSkip: true,
    canDismiss: true,
    canContactSupport: false,
    canReportBug: false,
    canViewDiagnostics: true,
  );
}

/// Accessibility helper for error recovery widget
extension ErrorRecoveryAccessibility on ErrorRecoveryWidget {
  /// Get screen reader announcements for error states
  Map<String, String> getAccessibilityAnnouncements() {
    return {
      'error_occurred': 'Error occurred during initialization',
      'retry_available': 'Retry option is available',
      'contact_support': 'Contact support option is available',
      'technical_details': 'Technical details can be expanded',
      'error_dismissible': canDismiss ? 'Error can be dismissed' : 'Error cannot be dismissed',
    };
  }

  /// Get semantic labels for screen readers
  String getSemanticLabel(String action) {
    switch (action) {
      case 'retry':
        return 'Retry initialization';
      case 'dismiss':
        return 'Dismiss error message';
      case 'contact_support':
        return 'Contact customer support';
      case 'view_diagnostics':
        return 'View technical diagnostics';
      case 'toggle_details':
        return _showTechnicalDetails
            ? 'Hide technical details'
            : 'Show technical details';
      default:
        return action;
    }
  }
}