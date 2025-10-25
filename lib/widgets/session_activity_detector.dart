import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riverpod/session_manager_provider.dart';

/// A widget that detects user activity and records it for session grace period tracking.
///
/// This widget wraps child widgets and listens for user interactions:
/// - Tap gestures (taps, long presses)
/// - Pan gestures (scrolling, dragging)
/// - Scale gestures (pinch-to-zoom)
/// - Pointer events (mouse movements, stylus)
/// - Keyboard events
///
/// Each detected interaction resets the session inactivity timer and exits
/// grace period if active, preventing automatic logout while the user is
/// actively using the app.
///
/// Integration with SessionManagerService:
/// - Records activity via session manager provider
/// - Throttles activity recording to prevent performance impact
/// - Works with grace period warning system
///
/// Usage:
/// Wrap your app's content at the MaterialApp level (recommended):
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   return MaterialApp.router(
///     builder: (context, child) => SessionActivityDetector(
///       child: child ?? const SizedBox(),
///     ),
///     routerConfig: router,
///   );
/// }
/// ```
///
/// Note: Only one SessionActivityDetector is needed at the app level.
/// Multiple detectors will work but are unnecessary and slightly less efficient.
class SessionActivityDetector extends ConsumerStatefulWidget {
  /// The child widget to wrap with activity detection.
  final Widget child;

  /// Optional callback triggered when activity is detected.
  ///
  /// This is useful for debugging or implementing custom behavior.
  final VoidCallback? onActivity;

  const SessionActivityDetector({
    super.key,
    required this.child,
    this.onActivity,
  });

  @override
  ConsumerState<SessionActivityDetector> createState() => _SessionActivityDetectorState();
}

class _SessionActivityDetectorState extends ConsumerState<SessionActivityDetector> {
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
  /// 2. Records activity via the session manager provider
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

    // Update session manager
    final sessionManager = ref.read(sessionManagerProvider);
    sessionManager.recordActivity();

    // Trigger optional callback
    widget.onActivity?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Use Listener to capture all pointer events (more comprehensive than GestureDetector)
    return Listener(
      // Detect any pointer events (taps, scrolls, mouse movements)
      onPointerDown: (_) => _recordActivity(),
      onPointerMove: (_) => _recordActivity(),
      onPointerUp: (_) => _recordActivity(),

      // Detect keyboard events
      child: Focus(
        onKeyEvent: (node, event) {
          _recordActivity();
          return KeyEventResult.ignored;
        },

        // Also wrap with GestureDetector for additional gesture support
        child: GestureDetector(
          // Tap gestures
          onTap: _recordActivity,

          // Allow gestures to pass through to child widgets
          behavior: HitTestBehavior.translucent,

          // Render the child widget
          child: widget.child,
        ),
      ),
    );
  }
}
