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

  /// Idle detection threshold (2 minutes of inactivity)
  static const Duration idleThreshold = Duration(minutes: 2);

  /// Grace period duration after idle detection (5 minutes)
  static const Duration gracePeriodDuration = Duration(minutes: 5);

  /// Total timeout duration (idle + grace period = 7 minutes)
  static const Duration timeoutDuration = Duration(minutes: 7);

  /// Warning notification timing (4 minutes into grace period, 1 minute before timeout)
  /// This means 6 minutes after inactivity (2 min idle + 4 min grace)
  static const Duration warningThreshold = Duration(minutes: 6);

  /// How often to check for timeout (15 seconds for better precision)
  static const Duration _checkInterval = Duration(seconds: 15);

  /// SharedPreferences key for last activity timestamp
  static const String _lastActivityKey = 'last_activity_timestamp';

  /// SharedPreferences key for session active flag
  static const String _sessionActiveKey = 'session_active';

  /// SharedPreferences key for grace period start timestamp
  static const String _gracePeriodStartKey = 'grace_period_start';

  /// SharedPreferences key for warning shown flag
  static const String _warningShownKey = 'warning_shown';

  // ============================================================================
  // State Management
  // ============================================================================

  /// Timer for periodic timeout checks
  Timer? _timeoutCheckTimer;

  /// Timestamp of last user activity
  DateTime? _lastActivityTime;

  /// Timestamp when grace period started (when user became idle)
  DateTime? _gracePeriodStartTime;

  /// Whether the warning notification has been shown
  bool _warningShown = false;

  /// Whether the service is currently active
  bool _isActive = false;

  /// Whether user is currently authenticated
  bool _isAuthenticated = false;

  /// Whether user is currently in grace period
  bool _inGracePeriod = false;

  /// Callback for timeout events
  VoidCallback? onTimeout;

  /// Callback for session state changes
  ValueChanged<bool>? onSessionStateChanged;

  /// Callback for warning notification (4 minutes into grace period)
  VoidCallback? onWarning;

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
  /// If user was in grace period, activity resumes normal session.
  Future<void> recordActivity() async {
    if (!_isAuthenticated || !_isActive) {
      return;
    }

    _lastActivityTime = DateTime.now();

    // Reset grace period state if user was idle
    if (_inGracePeriod) {
      debugPrint('[SessionTimeout] User resumed activity - exiting grace period');
      _inGracePeriod = false;
      _gracePeriodStartTime = null;
      _warningShown = false;

      // Clear grace period from persistent storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_gracePeriodStartKey);
        await prefs.remove(_warningShownKey);
      } catch (e) {
        debugPrint('[SessionTimeout] Failed to clear grace period state: $e');
      }
    }

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
  /// Grace period flow:
  /// 1. After 2 minutes of inactivity → Enter grace period
  /// 2. Grace period duration: 5 minutes
  /// 3. At 4 minutes into grace period (6 min total) → Show warning
  /// 4. At 5 minutes into grace period (7 min total) → Trigger timeout
  /// 5. Any activity during grace period → Reset and exit grace period
  Future<void> _checkForTimeout() async {
    if (_lastActivityTime == null || !_isAuthenticated) {
      return;
    }

    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivityTime!);

    // Check if user has been idle for 2 minutes
    if (!_inGracePeriod && inactiveDuration >= idleThreshold) {
      // User became idle - start grace period
      _inGracePeriod = true;
      _gracePeriodStartTime = now;
      _warningShown = false;

      debugPrint('[SessionTimeout] User idle for ${idleThreshold.inMinutes} minutes - starting ${gracePeriodDuration.inMinutes}-minute grace period');

      // Persist grace period start
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_gracePeriodStartKey, _gracePeriodStartTime!.millisecondsSinceEpoch);
        await prefs.setBool(_warningShownKey, false);
      } catch (e) {
        debugPrint('[SessionTimeout] Failed to persist grace period start: $e');
      }
    }

    // If in grace period, check for warning and timeout
    if (_inGracePeriod && _gracePeriodStartTime != null) {
      final gracePeriodElapsed = now.difference(_gracePeriodStartTime!);
      final totalInactiveTime = inactiveDuration;

      // Show warning at 4 minutes into grace period (6 minutes total inactivity)
      if (!_warningShown && totalInactiveTime >= warningThreshold) {
        _warningShown = true;
        debugPrint('[SessionTimeout] Warning: 1 minute until automatic logout');

        // Persist warning shown state
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_warningShownKey, true);
        } catch (e) {
          debugPrint('[SessionTimeout] Failed to persist warning state: $e');
        }

        // Trigger warning callback
        if (onWarning != null) {
          onWarning!();
        }
      }

      // Check if grace period has expired (5 minutes)
      if (gracePeriodElapsed >= gracePeriodDuration) {
        debugPrint('[SessionTimeout] Grace period expired after ${gracePeriodElapsed.inMinutes} minutes - triggering logout');
        debugPrint('[SessionTimeout] Total inactivity: ${totalInactiveTime.inMinutes} minutes');

        // Stop monitoring and clear state
        _isAuthenticated = false;
        _inGracePeriod = false;
        _stopMonitoring();
        await _clearSessionState();

        // Notify session state changed
        onSessionStateChanged?.call(false);

        // Trigger timeout callback
        if (onTimeout != null) {
          onTimeout!();
        }
      } else {
        // Log remaining time in grace period
        final remainingGraceTime = gracePeriodDuration - gracePeriodElapsed;
        debugPrint('[SessionTimeout] Grace period active - logout in ${remainingGraceTime.inMinutes}m ${remainingGraceTime.inSeconds % 60}s');
      }
    } else if (!_inGracePeriod) {
      // User is active - log time until idle threshold
      final timeUntilIdle = idleThreshold - inactiveDuration;
      if (timeUntilIdle.inSeconds > 0) {
        debugPrint('[SessionTimeout] Session active - idle threshold in ${timeUntilIdle.inMinutes}m ${timeUntilIdle.inSeconds % 60}s');
      }
    }
  }

  /// Clears session state from persistent storage.
  ///
  /// Removes all session-related data including:
  /// - Last activity timestamp
  /// - Session active flag
  /// - Grace period start time
  /// - Warning shown flag
  Future<void> _clearSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActivityKey);
      await prefs.remove(_sessionActiveKey);
      await prefs.remove(_gracePeriodStartKey);
      await prefs.remove(_warningShownKey);

      _lastActivityTime = null;
      _gracePeriodStartTime = null;
      _warningShown = false;
      _inGracePeriod = false;
    } catch (e) {
      debugPrint('[SessionTimeout] Failed to clear session state: $e');
    }
  }

  // ============================================================================
  // Session State Queries
  // ============================================================================

  /// Returns the current session state.
  bool get isSessionActive => _isAuthenticated && _isActive;

  /// Returns whether user is currently in grace period (idle but not logged out yet).
  bool get isInGracePeriod => _inGracePeriod;

  /// Returns the time remaining until timeout.
  ///
  /// Returns null if no activity recorded or session not active.
  /// During grace period, returns time until logout (not time until idle).
  Duration? get timeUntilTimeout {
    if (_lastActivityTime == null || !_isAuthenticated) {
      return null;
    }

    final now = DateTime.now();

    if (_inGracePeriod && _gracePeriodStartTime != null) {
      // In grace period - calculate time remaining in grace period
      final gracePeriodElapsed = now.difference(_gracePeriodStartTime!);
      final remaining = gracePeriodDuration - gracePeriodElapsed;
      return remaining.isNegative ? Duration.zero : remaining;
    } else {
      // Not in grace period - calculate time until idle threshold
      final elapsed = now.difference(_lastActivityTime!);
      final remaining = idleThreshold - elapsed;
      return remaining.isNegative ? Duration.zero : remaining;
    }
  }

  /// Returns the time remaining until the warning notification.
  ///
  /// Returns null if no activity recorded, session not active, or already warned.
  Duration? get timeUntilWarning {
    if (_lastActivityTime == null || !_isAuthenticated || _warningShown) {
      return null;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_lastActivityTime!);
    final remaining = warningThreshold - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns the last activity timestamp.
  DateTime? get lastActivity => _lastActivityTime;

  /// Returns when the grace period started, if currently in grace period.
  DateTime? get gracePeriodStartTime => _gracePeriodStartTime;

  /// Returns whether the warning has been shown.
  bool get warningShown => _warningShown;

  /// Returns whether the service is initialized and active.
  bool get isInitialized => _isActive;
}
