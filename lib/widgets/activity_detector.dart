import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/providers/riverpod/session_timeout_provider.dart';
import 'package:journeyman_jobs/services/consolidated_session_service.dart';

/// A widget that detects user activity and records it for session timeout tracking.
///
/// This widget wraps child widgets and listens for user interactions:
/// - Tap gestures (taps, long presses)
/// - Pan gestures (scrolling, dragging)
/// - Scale gestures (pinch-to-zoom)
/// - Vertical/horizontal drag gestures
///
/// Each detected interaction resets the session timeout timer, preventing
/// automatic logout while the user is actively using the app.
///
/// Usage:
/// Wrap your app's content or individual screens with this widget to track activity.
///
/// Example 1 - Wrap entire app (recommended):
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return MaterialApp.router(
///     builder: (context, child) => ActivityDetector(
///       child: child ?? const SizedBox(),
///     ),
///     routerConfig: AppRouter.router,
///   );
/// }
/// ```
///
/// Example 2 - Wrap individual screens:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return ActivityDetector(
///     child: Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: Center(child: Text('Content')),
///     ),
///   );
/// }
/// ```
///
/// Note: Only one ActivityDetector is needed at the app level.
/// Multiple detectors will work but are unnecessary and slightly less efficient.
class ActivityDetector extends ConsumerStatefulWidget {
  /// The child widget to wrap with activity detection.
  final Widget child;

  /// Optional callback triggered when activity is detected.
  ///
  /// This is useful for debugging or implementing custom behavior.
  final VoidCallback? onActivity;

  const ActivityDetector({
    super.key,
    required this.child,
    this.onActivity,
  });

  @override
  ConsumerState<ActivityDetector> createState() => _ActivityDetectorState();
}

class _ActivityDetectorState extends ConsumerState<ActivityDetector> {
  /// Throttling to prevent excessive activity recording.
  ///
  /// We only record activity once per second to avoid performance impact
  /// from high-frequency gestures like scrolling.
  DateTime? _lastActivityRecorded;
  static const _throttleDuration = Duration(seconds: 1);

  /// Records user activity if throttle period has elapsed.
  ///
  /// This method:
  /// 1. Checks if enough time has passed since last recording (throttle)
  /// 2. Records activity via the session timeout provider
  /// 3. Triggers optional callback if provided
  void _recordActivity() {
    final now = DateTime.now();

    // Throttle: only record if enough time has passed since last recording
    if (_lastActivityRecorded != null) {
      final elapsed = now.difference(_lastActivityRecorded!);
      if (elapsed < _throttleDuration) {
        return; // Skip recording - too soon
      }
    }

    // Record activity
    _lastActivityRecorded = now;

    // Record activity using the consolidated session service
    final sessionService = ConsolidatedSessionService();
    if (sessionService.isInitialized) {
      sessionService.recordActivity();
    }

    // Also update the existing session timeout provider for compatibility
    final notifier = ref.read(sessionTimeoutProvider.notifier);
    notifier.recordActivity();

    // Trigger optional callback
    widget.onActivity?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap child with GestureDetector to capture all user interactions
    return GestureDetector(
      // Tap gestures
      onTap: _recordActivity,
      onTapDown: (_) => _recordActivity(),
      onTapCancel: _recordActivity,

      // Long press gestures
      onLongPress: _recordActivity,
      onLongPressStart: (_) => _recordActivity(),

      // Scale gestures (includes pan/pinch-to-zoom)
      // Note: Scale gestures are a superset of pan gestures, so we only use scale handlers
      onScaleStart: (_) => _recordActivity(),
      onScaleUpdate: (_) => _recordActivity(),
      onScaleEnd: (_) => _recordActivity(),

      // Note: Do not combine vertical/horizontal drags with scale gestures.
      // Keeping pan + scale avoids the GestureDetector assertion.

      // Allow gestures to pass through to child widgets
      behavior: HitTestBehavior.translucent,

      // Render the child widget
      child: widget.child,
    );
  }
}

/// A notification widget that displays a warning when session timeout is approaching.
///
/// This widget monitors the session state and shows a banner when the user
/// has been inactive for a certain period (e.g., 8 minutes of 10-minute timeout).
///
/// Features:
/// - Shows warning banner when timeout is approaching
/// - Displays time remaining until timeout
/// - Allows user to dismiss warning
/// - Automatically dismisses when user activity is detected
///
/// Usage:
/// Wrap your app's scaffold or main content area:
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return SessionTimeoutWarning(
///     child: Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: MyContent(),
///     ),
///   );
/// }
/// ```
class SessionTimeoutWarning extends ConsumerWidget {
  /// The child widget to display.
  final Widget child;

  /// Time threshold to start showing warning (default: 2 minutes before timeout).
  ///
  /// For 10-minute timeout, warning shows after 8 minutes of inactivity.
  final Duration warningThreshold;

  const SessionTimeoutWarning({
    super.key,
    required this.child,
    this.warningThreshold = const Duration(minutes: 2),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch session state for timeout information
    final sessionState = ref.watch(sessionTimeoutProvider);

    // Calculate if warning should be shown
    final shouldShowWarning = sessionState.isActive &&
        sessionState.timeUntilTimeout != null &&
        sessionState.timeUntilTimeout! <= warningThreshold &&
        sessionState.timeUntilTimeout! > Duration.zero;

    return Column(
      children: [
        // Show warning banner if timeout approaching
        if (shouldShowWarning)
          _buildWarningBanner(context, ref, sessionState.timeUntilTimeout!),

        // Main content
        Expanded(child: child),
      ],
    );
  }

  /// Builds the warning banner displayed when timeout is approaching.
  Widget _buildWarningBanner(
    BuildContext context,
    WidgetRef ref,
    Duration timeRemaining,
  ) {
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;

    return Material(
      color: Colors.orange.shade700,
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Warning icon
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),

            const SizedBox(width: 12),

            // Warning message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Session Timeout Warning',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You will be logged out in ${minutes}m ${seconds}s due to inactivity.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Stay logged in button
            TextButton(
              onPressed: () {
                // Record activity using the consolidated session service
                final sessionService = ConsolidatedSessionService();
                if (sessionService.isInitialized) {
                  sessionService.recordActivity();
                }

                // Also update the existing provider for compatibility
                final notifier = ref.read(sessionTimeoutProvider.notifier);
                notifier.recordActivity();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Stay Logged In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
