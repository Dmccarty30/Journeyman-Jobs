import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/hierarchical/hierarchical_types.dart';
import '../../services/hierarchical/hierarchical_initialization_service.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../widgets/initialization/initialization_widgets.dart';

/// Main progressive loading screen for hierarchical initialization system
///
/// This screen displays the initialization progress for 13 stages across 5 levels,
/// providing users with clear visual feedback about which features are available
/// and what's still loading. Features include:
///
/// - Real-time progress tracking with estimated time remaining
/// - Stage-by-stage visualization with electrical theme
/// - Feature availability cards showing ready vs loading features
/// - Error recovery with retry options
/// - Background progress indicators
/// - Accessibility compliance (WCAG 2.1 AA)
/// - Mobile-first responsive design
class InitializationProgressScreen extends StatefulWidget {
  /// Service for managing initialization flow
  final HierarchicalInitializationService initializationService;

  /// Callback when initialization is complete or user wants to proceed
  final VoidCallback? onInitializationComplete;

  /// Callback when user wants to skip to available features
  final VoidCallback? onSkipToAvailable;

  /// Whether to show the skip button when core features are ready
  final bool showSkipButton;

  /// Custom message to display during initialization
  final String? customMessage;

  const InitializationProgressScreen({
    super.key,
    required this.initializationService,
    this.onInitializationComplete,
    this.onSkipToAvailable,
    this.showSkipButton = true,
    this.customMessage,
  });

  @override
  State<InitializationProgressScreen> createState() => _InitializationProgressScreenState();
}

class _InitializationProgressScreenState extends State<InitializationProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  StreamSubscription<HierarchicalInitializationState>? _stateSubscription;
  HierarchicalInitializationState _currentState = HierarchicalInitializationState.idle();

  // Stage progress tracking
  final Map<InitializationStage, StageProgress> _stageProgress = {};
  Duration _estimatedTimeRemaining = Duration.zero;
  DateTime _startTime = DateTime.now();

  // Feature availability tracking
  final Set<String> _availableFeatures = {};
  final Set<String> _loadingFeatures = {};

  bool _hasError = false;
  String? _errorMessage;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _subscribeToInitializationState();
    _initializeStageProgress();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _subscribeToInitializationState() {
    _stateSubscription = widget.initializationService.initializationStateStream.listen(
      _onInitializationStateChanged,
      onError: _onInitializationError,
    );
  }

  void _initializeStageProgress() {
    // Initialize all stages with default progress
    for (final stage in InitializationStage.values) {
      _stageProgress[stage] = StageProgress(
        stage: stage,
        status: StageStatus.pending,
        progress: 0.0,
        startTime: DateTime.now(),
      );
    }
  }

  void _onInitializationStateChanged(HierarchicalInitializationState state) {
    setState(() {
      _currentState = state;
      _hasError = state.hasError;
      _errorMessage = state.error;

      if (state.isCompleted) {
        _canProceed = true;
        _updateAllStagesCompleted();
        _progressController.forward();
      } else if (state.isInitializing) {
        _updateStageProgress(state.phase);
        _updateFeatureAvailability(state.phase);
        _updateEstimatedTimeRemaining();
      }
    });
  }

  void _onInitializationError(dynamic error) {
    setState(() {
      _hasError = true;
      _errorMessage = error.toString();
    });
  }

  void _updateStageProgress(HierarchicalInitializationPhase phase) {
    final stage = _getStageFromPhase(phase);
    if (stage != null) {
      _stageProgress[stage] = StageProgress(
        stage: stage,
        status: StageStatus.inProgress,
        progress: 0.5, // Midpoint for in-progress
        startTime: _stageProgress[stage]?.startTime ?? DateTime.now(),
      );

      // Mark dependencies as completed
      for (final dependency in stage.dependsOn) {
        if (_stageProgress[dependency]?.status != StageStatus.completed) {
          _stageProgress[dependency] = StageProgress(
            stage: dependency,
            status: StageStatus.completed,
            progress: 1.0,
            startTime: _stageProgress[dependency]?.startTime ?? DateTime.now(),
          );
        }
      }
    }
  }

  void _updateAllStagesCompleted() {
    for (final stage in InitializationStage.values) {
      _stageProgress[stage] = StageProgress(
        stage: stage,
        status: StageStatus.completed,
        progress: 1.0,
        startTime: _stageProgress[stage]?.startTime ?? DateTime.now(),
      );
    }
  }

  void _updateFeatureAvailability(HierarchicalInitializationPhase phase) {
    setState(() {
      // Core features available after Level 1 completion
      if (phase.index >= HierarchicalInitializationPhase.loadingHomeLocal.index) {
        _availableFeatures.addAll(['Profile', 'Basic Jobs', 'Local Directory']);
      }

      // Enhanced features available after Level 2 completion
      if (phase.index >= HierarchicalInitializationPhase.loadingPreferredLocals.index) {
        _availableFeatures.addAll(['Advanced Job Search', 'Job Matching', 'Crew Basic']);
        _loadingFeatures.remove('Advanced Job Search');
        _loadingFeatures.remove('Job Matching');
      }

      // Full features available after completion
      if (phase == HierarchicalInitializationPhase.completed) {
        _availableFeatures.addAll(['Crew Management', 'Weather Services', 'Offline Sync']);
        _loadingFeatures.clear();
      }
    });
  }

  void _updateEstimatedTimeRemaining() {
    final elapsed = DateTime.now().difference(_startTime);
    final completedStages = _stageProgress.values
        .where((progress) => progress.status == StageStatus.completed)
        .length;
    final totalStages = InitializationStage.values.length;

    if (completedStages > 0) {
      final avgTimePerStage = elapsed.inMilliseconds / completedStages;
      final remainingStages = totalStages - completedStages;
      _estimatedTimeRemaining = Duration(milliseconds: (avgTimePerStage * remainingStages).round());
    }
  }

  InitializationStage? _getStageFromPhase(HierarchicalInitializationPhase phase) {
    switch (phase) {
      case HierarchicalInitializationPhase.loadingGuestData:
        return InitializationStage.firebaseCore;
      case HierarchicalInitializationPhase.loadingMinimal:
        return InitializationStage.userProfile;
      case HierarchicalInitializationPhase.loadingHomeLocal:
        return InitializationStage.localsDirectory;
      case HierarchicalInitializationPhase.loadingPreferredLocals:
        return InitializationStage.jobsData;
      case HierarchicalInitializationPhase.loadingComprehensive:
        return InitializationStage.crewFeatures;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        children: [
          // Circuit board background pattern
          const Positioned.fill(
            child: CircuitBoardBackground(
              opacity: 0.1,
              animate: true,
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  // Header section
                  _buildHeader(),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Progress overview
                  _buildProgressOverview(),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Stage progress list
                  Expanded(
                    child: _buildStagesList(),
                  ),

                  // Feature availability section
                  _buildFeatureAvailability(),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),

          // Background progress indicator
          _buildBackgroundProgress(),

          // Error overlay if needed
          if (_hasError) _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App logo/title with electrical animation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.electricalGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [AppTheme.shadowElectricalInfo],
                    ),
                    child: const Icon(
                      Icons.electrical_services,
                      color: AppTheme.white,
                      size: AppTheme.iconLg,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journeyman Jobs',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powering Your Career',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCopper,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingLg),

        // Custom message or status
        Text(
          widget.customMessage ?? _getStatusMessage(),
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms).slideY(),
      ],
    );
  }

  String _getStatusMessage() {
    if (_hasError) {
      return 'Initialization encountered an issue';
    } else if (_currentState.isCompleted) {
      return 'All systems ready - Welcome aboard!';
    } else if (_currentState.isInitializing) {
      return 'Powering up your electrical career tools...';
    } else {
      return 'Initializing Journeyman Jobs...';
    }
  }

  Widget _buildProgressOverview() {
    final overallProgress = _calculateOverallProgress();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: overallProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.electricalGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Progress stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(overallProgress * 100).toInt()}% Complete',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTimeRemaining(_estimatedTimeRemaining),
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(delay: 200.ms);
  }

  double _calculateOverallProgress() {
    final completedStages = _stageProgress.values
        .where((progress) => progress.status == StageStatus.completed)
        .length;
    final totalStages = InitializationStage.values.length;
    return totalStages > 0 ? completedStages / totalStages : 0.0;
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inSeconds <= 0) return 'Almost done...';
    if (duration.inSeconds < 60) return '${duration.inSeconds}s remaining';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m remaining';
    return '${duration.inMinutes}m remaining';
  }

  Widget _buildStagesList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: InitializationStage.values.length,
      itemBuilder: (context, index) {
        final stage = InitializationStage.values[index];
        final progress = _stageProgress[stage]!;

        return Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: StageProgressIndicator(
            stage: stage,
            progress: progress,
            showLevelBadge: true,
            compact: false,
          ),
        );
      },
    );
  }

  Widget _buildFeatureAvailability() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Availability',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Available features
          if (_availableFeatures.isNotEmpty) ...[
            FeatureAvailabilityCard(
              features: _availableFeatures.toList(),
              status: FeatureStatus.available,
              onFeatureTap: _onFeatureTap,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],

          // Loading features
          if (_loadingFeatures.isNotEmpty) ...[
            FeatureAvailabilityCard(
              features: _loadingFeatures.toList(),
              status: FeatureStatus.loading,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(delay: 400.ms);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action button
        JJButton(
          text: _getPrimaryButtonText(),
          onPressed: _getPrimaryAction(),
          variant: JJButtonVariant.primary,
          isFullWidth: true,
          isLoading: _currentState.isInitializing && !_canProceed,
        ),

        // Skip button (when available)
        if (_showSkipButton && _canProceed && !_currentState.isCompleted) ...[
          const SizedBox(height: AppTheme.spacingMd),
          JJButton(
            text: 'Continue with Available Features',
            onPressed: widget.onSkipToAvailable,
            variant: JJButtonVariant.outline,
            isFullWidth: true,
          ),
        ],

        // Retry button (when error)
        if (_hasError) ...[
          const SizedBox(height: AppTheme.spacingMd),
          JJButton(
            text: 'Retry Initialization',
            onPressed: _retryInitialization,
            variant: JJButtonVariant.secondary,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  String _getPrimaryButtonText() {
    if (_hasError) return 'View Error Details';
    if (_currentState.isCompleted) return 'Get Started';
    if (_canProceed) return 'Continue to App';
    return 'Initializing...';
  }

  VoidCallback? _getPrimaryAction() {
    if (_hasError) return _showErrorDetails;
    if (_currentState.isCompleted) return widget.onInitializationComplete;
    if (_canProceed) return widget.onInitializationComplete;
    return null;
  }

  Widget _buildBackgroundProgress() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 4,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentCopper.withValues(alpha: 0.8),
                  AppTheme.accentCopper,
                ],
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _calculateOverallProgress(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCopper.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return ErrorRecoveryWidget(
      error: _errorMessage ?? 'Unknown error occurred',
      onRetry: _retryInitialization,
      onDismiss: () => setState(() => _hasError = false),
      canDismiss: _canProceed,
    );
  }

  void _onFeatureTap(String feature) {
    // Handle feature tap - could navigate to specific feature
    debugPrint('Feature tapped: $feature');
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _initializeStageProgress();
      _startTime = DateTime.now();
    });

    widget.initializationService.initializeForCurrentUser(
      forceRefresh: true,
      strategy: HierarchicalInitializationStrategy.adaptive,
    );
  }

  void _showErrorDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: SingleChildScrollView(
          child: Text(
            _errorMessage ?? 'Unknown error occurred during initialization.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Progress data for individual initialization stages
@immutable
class StageProgress {
  final InitializationStage stage;
  final StageStatus status;
  final double progress;
  final DateTime startTime;
  final DateTime? endTime;
  final String? error;

  const StageProgress({
    required this.stage,
    required this.status,
    required this.progress,
    required this.startTime,
    this.endTime,
    this.error,
  });

  Duration? get duration {
    if (endTime != null) return endTime!.difference(startTime);
    return null;
  }
}

/// Feature status for availability cards
enum FeatureStatus {
  available,
  loading,
  comingSoon,
}

/// Accessibility extension for initialization progress screen
extension InitializationProgressAccessibility on InitializationProgressScreen {
  /// Get semantic descriptions for screen readers
  Map<String, String> getSemanticLabels() {
    return {
      'overall_progress': 'Initialization is ${(this as dynamic)._calculateOverallProgress() * 100}% complete',
      'time_remaining': 'Estimated time remaining: ${(this as dynamic)._formatTimeRemaining((this as dynamic)._estimatedTimeRemaining)}',
      'available_features': 'Available features: ${(this as dynamic)._availableFeatures.join(", ")}',
      'loading_features': 'Currently loading: ${(this as dynamic)._loadingFeatures.join(", ")}',
    };
  }
}