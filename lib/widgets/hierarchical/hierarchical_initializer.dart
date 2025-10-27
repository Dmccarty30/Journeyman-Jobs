import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../models/hierarchical/hierarchical_types.dart';
import '../../providers/riverpod/hierarchical_riverpod_provider.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../design_system/app_theme.dart';
import '../../widgets/jj_skeleton_loader.dart';

/// Widget that handles hierarchical data initialization
///
/// This widget manages the loading and error states for the hierarchical
/// data initialization system, providing appropriate UI feedback.
class HierarchicalInitializer extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onRetry;
  final bool showProgressIndicator;

  const HierarchicalInitializer({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.onRetry,
    this.showProgressIndicator = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hierarchicalState = ref.watch(hierarchicalDataProvider);
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => _buildLoading(context),
      error: (error, stackTrace) => _buildAuthError(context, error),
      data: (user) {
        return hierarchicalState.isLoading
            ? _buildLoading(context)
            : hierarchicalState.hasError
                ? _buildError(context, hierarchicalState.error!)
                : child;
      },
    );
  }

  /// Builds loading widget
  Widget _buildLoading(BuildContext context) {
    if (loadingWidget != null) {
      return loadingWidget!;
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Electrical-themed loading animation
            if (showProgressIndicator)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: JJSkeletonLoader(
                    width: 200,
                    height: 60,
                    showCircuitPattern: true,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Loading message
            Text(
              'Initializing IBEW Network...',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.accentCopper,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Loading Union • Local • Member • Job data',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Progress indicators for different hierarchical levels
            _buildHierarchicalProgress(),
          ],
        ),
      ),
    );
  }

  /// Builds error widget
  Widget _buildError(BuildContext context, String error) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.accentCopper,
              ),

              const SizedBox(height: 24),

              // Error title
              Text(
                'Connection Error',
                style: AppTheme.headlineLarge.copyWith(
                  color: AppTheme.accentCopper,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error message
              Text(
                'Unable to load IBEW network data. Please check your connection and try again.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Technical error details (for debugging)
              if (kDebugMode)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry ?? () {
                  // Trigger retry through provider
                  // This would need to be implemented in the provider
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Offline mode button
              TextButton(
                onPressed: () {
                  // Continue with offline/cached data if available
                },
                child: Text(
                  'Continue Offline',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.accentCopper,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds authentication error widget
  Widget _buildAuthError(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Authentication error icon
              Icon(
                Icons.security,
                size: 64,
                color: AppTheme.accentCopper,
              ),

              const SizedBox(height: 24),

              // Error title
              Text(
                'Authentication Error',
                style: AppTheme.headlineLarge.copyWith(
                  color: AppTheme.accentCopper,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error message
              Text(
                'There was an issue with authentication. Please sign in again.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Sign in button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to sign in screen
                  // This would need to be implemented based on routing
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds hierarchical progress indicators
  Widget _buildHierarchicalProgress() {
    return Consumer(
      builder: (context, ref, child) {
        final initializationState = ref.watch(hierarchicalInitializationStateProvider);

        return initializationState.when(
          data: (state) => _buildProgressSteps(state.phase),
          loading: () => _buildProgressSteps(HierarchicalInitializationPhase.initializing),
          error: (error, stackTrace) => _buildProgressSteps(HierarchicalInitializationPhase.error),
        );
      },
    );
  }

  /// Builds progress steps for hierarchical initialization
  Widget _buildProgressSteps(HierarchicalInitializationPhase currentPhase) {
    final steps = [
      _ProgressStep(
        phase: HierarchicalInitializationPhase.initializing,
        title: 'Connecting',
        icon: Icons.wifi,
        isCompleted: _isPhaseCompleted(currentPhase, HierarchicalInitializationPhase.initializing),
        isActive: currentPhase == HierarchicalInitializationPhase.initializing,
      ),
      _ProgressStep(
        phase: HierarchicalInitializationPhase.loadingMinimal,
        title: 'Loading Union',
        icon: Icons.account_balance,
        isCompleted: _isPhaseCompleted(currentPhase, HierarchicalInitializationPhase.loadingMinimal),
        isActive: currentPhase == HierarchicalInitializationPhase.loadingMinimal,
      ),
      _ProgressStep(
        phase: HierarchicalInitializationPhase.loadingHomeLocal,
        title: 'Loading Locals',
        icon: Icons.location_city,
        isCompleted: _isPhaseCompleted(currentPhase, HierarchicalInitializationPhase.loadingHomeLocal),
        isActive: currentPhase == HierarchicalInitializationPhase.loadingHomeLocal,
      ),
      _ProgressStep(
        phase: HierarchicalInitializationPhase.loadingPreferredLocals,
        title: 'Loading Members',
        icon: Icons.people,
        isCompleted: _isPhaseCompleted(currentPhase, HierarchicalInitializationPhase.loadingPreferredLocals),
        isActive: currentPhase == HierarchicalInitializationPhase.loadingPreferredLocals,
      ),
      _ProgressStep(
        phase: HierarchicalInitializationPhase.loadingComprehensive,
        title: 'Loading Jobs',
        icon: Icons.work,
        isCompleted: _isPhaseCompleted(currentPhase, HierarchicalInitializationPhase.loadingComprehensive),
        isActive: currentPhase == HierarchicalInitializationPhase.loadingComprehensive,
      ),
    ];

    return Column(
      children: steps.map((step) => _buildProgressStep(step)).toList(),
    );
  }

  /// Builds individual progress step
  Widget _buildProgressStep(_ProgressStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.isCompleted
                  ? AppTheme.accentCopper
                  : step.isActive
                      ? AppTheme.accentCopper.withValues(alpha:0.7)
                      : AppTheme.textLight.withValues(alpha:0.3),
            ),
            child: Icon(
              step.isCompleted ? Icons.check : step.icon,
              size: 18,
              color: step.isCompleted || step.isActive
                  ? Colors.white
                  : AppTheme.textLight.withValues(alpha:0.7),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              step.title,
              style: AppTheme.bodyMedium.copyWith(
                color: step.isCompleted || step.isActive
                    ? AppTheme.accentCopper
                    : AppTheme.textLight.withValues(alpha:0.7),
                fontWeight: step.isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // Loading indicator
          if (step.isActive)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
              ),
            ),
        ],
      ),
    );
  }

  /// Checks if a phase is completed
  bool _isPhaseCompleted(HierarchicalInitializationPhase current, HierarchicalInitializationPhase phase) {
    if (current == HierarchicalInitializationPhase.error) {
      return false;
    }

    switch (phase) {
      case HierarchicalInitializationPhase.initializing:
        return current.index > HierarchicalInitializationPhase.initializing.index;
      case HierarchicalInitializationPhase.loadingMinimal:
        return current.index > HierarchicalInitializationPhase.loadingMinimal.index;
      case HierarchicalInitializationPhase.loadingHomeLocal:
        return current.index > HierarchicalInitializationPhase.loadingHomeLocal.index;
      case HierarchicalInitializationPhase.loadingPreferredLocals:
        return current.index > HierarchicalInitializationPhase.loadingPreferredLocals.index;
      case HierarchicalInitializationPhase.loadingComprehensive:
        return current == HierarchicalInitializationPhase.completed;
      default:
        return false;
    }
  }
}

/// Progress step for hierarchical initialization
class _ProgressStep {
  final HierarchicalInitializationPhase phase;
  final String title;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  const _ProgressStep({
    required this.phase,
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
  });
}

/// Widget for displaying hierarchical data statistics
class HierarchicalStatsWidget extends ConsumerWidget {
  const HierarchicalStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(hierarchicalStatsProvider);
    final isRefreshing = ref.watch(hierarchicalDataProvider.select((state) => state.isLoading));

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.accentCopper,
                ),
                const SizedBox(width: 8),
                Text(
                  'IBEW Network Statistics',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const Spacer(),
                if (isRefreshing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Statistics grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Locals', stats.totalLocals.toString(), Icons.location_city),
                ),
                Expanded(
                  child: _buildStatItem('Members', stats.totalMembers.toString(), Icons.people),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Jobs', stats.totalJobs.toString(), Icons.work),
                ),
                Expanded(
                  child: _buildStatItem('Available', '${stats.availableJobs}/${stats.availableMembers}', Icons.trending_up),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Last updated
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last updated: ${_formatTime(stats.lastUpdated)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.accentCopper,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}