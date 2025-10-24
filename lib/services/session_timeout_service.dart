import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service that manages user session timeout based on inactivity.
///
/// Features:
/// - Tracks user activity across the entire app
/// - Auto-logout after 10 minutes of inactivity (configurable)
/// - Auto-logout when app is closed/terminated
/// - Session persistence tracking
/// - Callbacks for timeout events
///
/// Integration:
/// - Initialize in main.dart after auth initialization
/// - Use ActivityDetector widget to track user interactions
/// - Listen to timeout events for navigation
///
/// Example usage:
/// ```dart
/// final sessionService = SessionTimeoutService();
/// await sessionService.initialize();
///
/// sessionService.onTimeout = () async {
///   // Handle timeout - navigate to auth screen
///   await authService.signOut();
///   router.go('/auth');
/// };
///
/// // Track user activity
/// sessionService.recordActivity();
/// ```
class SessionTimeoutService {
  /// Singleton instance
  static final SessionTimeoutService _instance = SessionTimeoutService._internal();
  factory SessionTimeoutService() => _instance;
  SessionTimeoutService._internal();

  // ============================================================================
  // Configuration Constants
  // ============================================================================

  /// Inactivity timeout duration (10 minutes)
  static const Duration timeoutDuration = Duration(minutes: 10);

  /// How often to check for timeout (30 seconds)
  static const Duration _checkInterval = Duration(seconds: 30);

  /// SharedPreferences key for last activity timestamp
  static const String _lastActivityKey = 'last_activity_timestamp';

  /// SharedPreferences key for session active flag
  static const String _sessionActiveKey = 'session_active';

  // ============================================================================
  // State Management
  // ============================================================================

  /// Timer for periodic timeout checks
  Timer? _timeoutCheckTimer;

  /// Timestamp of last user activity
  DateTime? _lastActivityTime;

  /// Whether the service is currently active
  bool _isActive = false;

  /// Whether user is currently authenticated
  bool _isAuthenticated = false;

  /// Callback for timeout events
  VoidCallback? onTimeout;

  /// Callback for session state changes
  ValueChanged<bool>? onSessionStateChanged;

  // ============================================================================
  // Lifecycle Management
  // ============================================================================

  /// Initializes the session timeout service.
  ///
  /// This method:
  /// 1. Loads persisted session state
  /// 2. Checks if session expired during app closure
  /// 3. Starts timeout monitoring if user is authenticated
  ///
  /// Should be called after auth initialization to check session validity.
  Future<void> initialize() async {
    if (_isActive) {
      debugPrint('[SessionTimeout] Service already initialized');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if there was an active session when app was closed
      final hadActiveSession = prefs.getBool(_sessionActiveKey) ?? false;

      if (hadActiveSession) {
        // App was closed with active session - this means session expired
        debugPrint('[SessionTimeout] App was closed with active session - session expired');

        // Clear session state
        await _clearSessionState();

        // Trigger timeout callback if set
        if (onTimeout != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            onTimeout?.call();
          });
        }
      }

      _isActive = true;
      debugPrint('[SessionTimeout] Service initialized');
    } catch (e) {
      debugPrint('[SessionTimeout] Initialization error: $e');
    }
  }

  /// Disposes the service and cleans up resources.
  ///
  /// Cancels timers and marks session as inactive.
  Future<void> dispose() async {
    _stopMonitoring();
    await _clearSessionState();
    _isActive = false;
    debugPrint('[SessionTimeout] Service disposed');
  }

  // ============================================================================
  // Session Management
  // ============================================================================

  /// Starts session timeout monitoring for authenticated user.
  ///
  /// This should be called after successful authentication.
  /// Starts periodic checks and records initial activity.
  Future<void> startSession() async {
    if (!_isActive) {
      debugPrint('[SessionTimeout] Service not initialized, cannot start session');
      return;
    }

    _isAuthenticated = true;
    await recordActivity();
    _startMonitoring();

    // Mark session as active in persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sessionActiveKey, true);
    } catch (e) {
      debugPrint('[SessionTimeout] Failed to mark session as active: $e');
    }

    onSessionStateChanged?.call(true);
    debugPrint('[SessionTimeout] Session started');
  }

  /// Ends session timeout monitoring.
  ///
  /// This should be called when user logs out.
  /// Stops monitoring and clears session state.
  Future<void> endSession() async {
    _isAuthenticated = false;
    _stopMonitoring();
    await _clearSessionState();

    onSessionStateChanged?.call(false);
    debugPrint('[SessionTimeout] Session ended');
  }

  /// Records user activity and resets the timeout timer.
  ///
  /// This should be called whenever user interacts with the app:
  /// - Taps/clicks
  /// - Scrolling
  /// - Text input
  /// - Navigation
  ///
  /// The activity timestamp is persisted to detect timeout across app restarts.
  Future<void> recordActivity() async {
    if (!_isAuthenticated || !_isActive) {
      return;
    }

    _lastActivityTime = DateTime.now();

    // Persist activity timestamp
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastActivityKey, _lastActivityTime!.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[SessionTimeout] Failed to record activity: $e');
    }
  }

  // ============================================================================
  // Timeout Monitoring
  // ============================================================================

  /// Starts periodic timeout monitoring.
  ///
  /// Checks for inactivity every 30 seconds. If user has been inactive
  /// for more than the timeout duration, triggers the timeout callback.
  void _startMonitoring() {
    _stopMonitoring();

    _timeoutCheckTimer = Timer.periodic(_checkInterval, (_) async {
      await _checkForTimeout();
    });

    debugPrint('[SessionTimeout] Monitoring started (timeout: ${timeoutDuration.inMinutes} minutes)');
  }

  /// Stops timeout monitoring.
  ///
  /// Cancels the periodic timer.
  void _stopMonitoring() {
    _timeoutCheckTimer?.cancel();
    _timeoutCheckTimer = null;
  }

  /// Checks if session has timed out due to inactivity.
  ///
  /// If timeout detected:
  /// 1. Stops monitoring
  /// 2. Clears session state
  /// 3. Triggers timeout callback
  Future<void> _checkForTimeout() async {
    if (_lastActivityTime == null || !_isAuthenticated) {
      return;
    }

    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivityTime!);

    if (inactiveDuration >= timeoutDuration) {
      debugPrint('[SessionTimeout] Session timed out after ${inactiveDuration.inMinutes} minutes of inactivity');

      // Stop monitoring and clear state
      _isAuthenticated = false;
      _stopMonitoring();
      await _clearSessionState();

      // Notify session state changed
      onSessionStateChanged?.call(false);

      // Trigger timeout callback
      if (onTimeout != null) {
        onTimeout!();
      }
    } else {
      // Calculate remaining time
      final remainingTime = timeoutDuration - inactiveDuration;
      debugPrint('[SessionTimeout] Session active - timeout in ${remainingTime.inMinutes}m ${remainingTime.inSeconds % 60}s');
    }
  }

  /// Clears session state from persistent storage.
  Future<void> _clearSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActivityKey);
      await prefs.remove(_sessionActiveKey);
      _lastActivityTime = null;
    } catch (e) {
      debugPrint('[SessionTimeout] Failed to clear session state: $e');
    }
  }

  // ============================================================================
  // Session State Queries
  // ============================================================================

  /// Returns the current session state.
  bool get isSessionActive => _isAuthenticated && _isActive;

  /// Returns the time remaining until timeout.
  ///
  /// Returns null if no activity recorded or session not active.
  Duration? get timeUntilTimeout {
    if (_lastActivityTime == null || !_isAuthenticated) {
      return null;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_lastActivityTime!);
    final remaining = timeoutDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns the last activity timestamp.
  DateTime? get lastActivity => _lastActivityTime;

  /// Returns whether the service is initialized and active.
  bool get isInitialized => _isActive;
}
