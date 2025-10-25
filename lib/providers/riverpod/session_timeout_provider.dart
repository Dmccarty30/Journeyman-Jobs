import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/session_timeout_service.dart';
import 'auth_riverpod_provider.dart';

part 'session_timeout_provider.g.dart';

/// Session state model for timeout tracking with grace period.
///
/// Grace period workflow:
/// - User becomes idle after 30 minutes of inactivity
/// - Grace period of 15 minutes begins when idle
/// - Warning shown at 10 minutes into grace period (40 minutes total, 5 min before logout)
/// - Logout occurs at 15 minutes into grace period (45 minutes total from last activity)
/// - Any activity during grace period restores the session and resets all timers
class SessionState {
  final bool isActive;
  final DateTime? lastActivity;
  final Duration? timeUntilTimeout;
  final bool isInGracePeriod;
  final DateTime? gracePeriodStartTime;
  final bool warningShown;

  const SessionState({
    this.isActive = false,
    this.lastActivity,
    this.timeUntilTimeout,
    this.isInGracePeriod = false,
    this.gracePeriodStartTime,
    this.warningShown = false,
  });

  SessionState copyWith({
    bool? isActive,
    DateTime? lastActivity,
    Duration? timeUntilTimeout,
    bool? isInGracePeriod,
    DateTime? gracePeriodStartTime,
    bool? warningShown,
  }) {
    return SessionState(
      isActive: isActive ?? this.isActive,
      lastActivity: lastActivity ?? this.lastActivity,
      timeUntilTimeout: timeUntilTimeout ?? this.timeUntilTimeout,
      isInGracePeriod: isInGracePeriod ?? this.isInGracePeriod,
      gracePeriodStartTime: gracePeriodStartTime ?? this.gracePeriodStartTime,
      warningShown: warningShown ?? this.warningShown,
    );
  }
}

/// Provides the singleton session timeout service instance.
///
/// This provider creates and manages the SessionTimeoutService lifecycle.
/// The service is initialized when first accessed and disposed when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionTimeoutServiceProvider);
/// await sessionService.startSession(); // After successful login
/// sessionService.recordActivity(); // On user interaction
/// await sessionService.endSession(); // On logout
/// ```
@riverpod
SessionTimeoutService sessionTimeoutService(Ref ref) {
  final service = SessionTimeoutService();

  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Manages session timeout state and coordinates with auth system.
///
/// This notifier:
/// - Monitors authentication state changes
/// - Starts/stops session timeout monitoring based on auth state
/// - Handles timeout events and triggers logout
/// - Updates session state for UI consumers
///
/// The notifier automatically:
/// - Starts session monitoring when user authenticates
/// - Stops session monitoring when user logs out
/// - Triggers logout when session times out
///
/// Example usage:
/// ```dart
/// final sessionState = ref.watch(sessionTimeoutNotifierProvider);
/// if (sessionState.isActive) {
///   final timeLeft = sessionState.timeUntilTimeout;
///   // Show timeout warning if needed
/// }
/// ```
@riverpod
class SessionTimeoutNotifier extends _$SessionTimeoutNotifier {
  SessionTimeoutService? _service;
  bool _initialized = false;

  @override
  SessionState build() {
    // Watch authentication state to start/stop session monitoring
    final authState = ref.watch(authStateProvider);

    // Initialize service on first build
    if (!_initialized) {
      _initializeService();
      _initialized = true;
    }

    // React to auth state changes
    authState.whenData((user) {
      if (user != null && _service?.isSessionActive != true) {
        // User authenticated and session not active - start session
        _startSession();
      } else if (user == null && _service?.isSessionActive == true) {
        // User logged out and session still active - end session
        _endSession();
      }
    });

    return const SessionState();
  }

  /// Initializes the session timeout service with callbacks.
  ///
  /// Sets up three callbacks:
  /// 1. onTimeout: Handles final logout after grace period expires
  /// 2. onWarning: Shows warning notification 1 minute before logout
  /// 3. onSessionStateChanged: Updates session state for UI
  Future<void> _initializeService() async {
    _service = ref.read(sessionTimeoutServiceProvider);

    // Configure timeout callback to handle session expiration
    _service?.onTimeout = () async {
      // Session timed out - sign out user
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      // Update state to reflect timeout
      state = const SessionState(isActive: false);
    };

    // Configure warning callback (4 minutes into grace period)
    _service?.onWarning = () {
      // Update state to reflect warning
      state = SessionState(
        isActive: state.isActive,
        lastActivity: _service?.lastActivity,
        timeUntilTimeout: _service?.timeUntilTimeout,
        isInGracePeriod: _service?.isInGracePeriod ?? false,
        gracePeriodStartTime: _service?.gracePeriodStartTime,
        warningShown: true,
      );

      // Note: UI can watch for warningShown to display notification
      // The notification UI will be handled by a listener in the app
    };

    // Configure session state change callback
    _service?.onSessionStateChanged = (isActive) {
      state = SessionState(
        isActive: isActive,
        lastActivity: _service?.lastActivity,
        timeUntilTimeout: _service?.timeUntilTimeout,
        isInGracePeriod: _service?.isInGracePeriod ?? false,
        gracePeriodStartTime: _service?.gracePeriodStartTime,
        warningShown: _service?.warningShown ?? false,
      );
    };

    // Initialize the service
    await _service?.initialize();
  }

  /// Starts session timeout monitoring.
  ///
  /// Called automatically when user authenticates.
  Future<void> _startSession() async {
    await _service?.startSession();

    state = SessionState(
      isActive: true,
      lastActivity: _service?.lastActivity,
      timeUntilTimeout: _service?.timeUntilTimeout,
      isInGracePeriod: false,
      gracePeriodStartTime: null,
      warningShown: false,
    );
  }

  /// Ends session timeout monitoring.
  ///
  /// Called automatically when user logs out.
  Future<void> _endSession() async {
    await _service?.endSession();

    state = const SessionState(isActive: false);
  }

  /// Records user activity and resets timeout timer.
  ///
  /// Call this method whenever user interacts with the app.
  /// This is typically handled automatically by the ActivityDetector widget.
  /// If user was in grace period, this will resume normal session.
  Future<void> recordActivity() async {
    await _service?.recordActivity();

    // Update state with new activity time and grace period info
    state = SessionState(
      isActive: state.isActive,
      lastActivity: _service?.lastActivity,
      timeUntilTimeout: _service?.timeUntilTimeout,
      isInGracePeriod: _service?.isInGracePeriod ?? false,
      gracePeriodStartTime: _service?.gracePeriodStartTime,
      warningShown: _service?.warningShown ?? false,
    );
  }

  /// Manually triggers session timeout (for testing or explicit logout).
  Future<void> triggerTimeout() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();

    state = const SessionState(isActive: false);
  }

  /// Returns current session state information.
  SessionState getState() => state;
}

/// Provides a stream that emits session state updates.
///
/// Use this to reactively update UI based on session state changes.
///
/// This stream is designed to be consumed by the UI to show a live countdown
/// or reflect the current session status. It listens to the [sessionTimeoutProvider]
/// and emits a new state whenever the notifier's state changes.
final sessionStateStreamProvider = StreamProvider.autoDispose<SessionState>((ref) {
  final controller = StreamController<SessionState>.broadcast();

  // When the provider is first read, immediately get the latest state from the notifier and add it to the stream.
  controller.add(ref.read(sessionTimeoutProvider));

  // Listen to the notifier for any subsequent state changes.
  final sub = ref.listen<SessionState>(sessionTimeoutProvider, (previous, next) {
    // When the notifier's state changes, add the new state to our stream.
    controller.add(next);
  }, fireImmediately: false);

  // When the provider is disposed (e.g., all listeners are removed),
  // we clean up by closing the subscription and the stream controller.
  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});
