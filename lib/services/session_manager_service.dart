import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages user session with inactivity detection and grace period.
///
/// This service implements a two-tier timeout system:
/// 1. Idle Detection: After 2 minutes of inactivity, enters grace period
/// 2. Grace Period: 5-minute countdown before automatic sign-out
///
/// Features:
/// - Detects user inactivity after 2 minutes
/// - Provides 5-minute grace period before sign-out
/// - Shows warning notification at 4-minute mark
/// - Activity during grace period resets all timers
/// - Handles app lifecycle (background/foreground)
/// - Comprehensive logging for debugging
///
/// Timeline:
/// - 0:00 - User activity detected
/// - 2:00 - Inactivity detected, grace period starts
/// - 6:00 - Warning notification shown (4 minutes into grace period)
/// - 7:00 - Automatic sign-out (5-minute grace period complete)
///
/// Integration:
/// ```dart
/// final sessionManager = SessionManagerService();
/// sessionManager.initialize();
///
/// // Record activity to reset timers
/// sessionManager.recordActivity();
///
/// // Listen for grace period state changes
/// sessionManager.addListener(() {
///   if (sessionManager.isInGracePeriod) {
///     // Show warning UI
///   }
/// });
/// ```
class SessionManagerService extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseAuth _auth;

  // ============================================================================
  // Configuration Constants
  // ============================================================================

  /// Duration of inactivity before grace period starts (2 minutes)
  static const Duration inactivityDuration = Duration(minutes: 2);

  /// Duration of grace period before automatic sign-out (5 minutes)
  static const Duration gracePeriodDuration = Duration(minutes: 5);

  /// When to show warning during grace period (4 minutes = 1 minute before sign-out)
  static const Duration warningDuration = Duration(minutes: 4);

  // ============================================================================
  // Timers
  // ============================================================================

  /// Timer that monitors for inactivity
  Timer? _inactivityTimer;

  /// Timer that counts down the grace period
  Timer? _gracePeriodTimer;

  /// Timer for periodic state updates during grace period
  Timer? _gracePeriodUpdateTimer;

  // ============================================================================
  // State Management
  // ============================================================================

  /// Whether currently in grace period
  bool _isInGracePeriod = false;

  /// Whether warning notification has been shown
  bool _hasShownWarning = false;

  /// Timestamp of last user activity
  DateTime? _lastActivityTime;

  /// Timestamp when grace period started
  DateTime? _gracePeriodStartTime;

  /// Whether the service is initialized
  bool _isInitialized = false;

  /// Whether user is authenticated
  bool _isAuthenticated = false;

  // ============================================================================
  // Getters
  // ============================================================================

  /// Returns true if currently in grace period
  bool get isInGracePeriod => _isInGracePeriod;

  /// Returns timestamp of last activity
  DateTime? get lastActivityTime => _lastActivityTime;

  /// Returns timestamp when grace period started
  DateTime? get gracePeriodStartTime => _gracePeriodStartTime;

  /// Returns true if service is initialized
  bool get isInitialized => _isInitialized;

  /// Returns true if warning has been shown
  bool get hasShownWarning => _hasShownWarning;

  /// Calculate remaining grace period time
  ///
  /// Returns null if not in grace period, otherwise returns remaining duration.
  /// Duration is never negative (minimum is Duration.zero).
  Duration? get remainingGracePeriod {
    if (!_isInGracePeriod || _gracePeriodStartTime == null) {
      return null;
    }

    final elapsed = DateTime.now().difference(_gracePeriodStartTime!);
    final remaining = gracePeriodDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Calculate time until inactivity timeout
  ///
  /// Returns null if no activity recorded, otherwise returns remaining duration
  /// until grace period starts.
  Duration? get timeUntilInactivity {
    if (_lastActivityTime == null || _isInGracePeriod) {
      return null;
    }

    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = inactivityDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  // ============================================================================
  // Constructor
  // ============================================================================

  SessionManagerService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize the session manager
  ///
  /// This method:
  /// 1. Registers as app lifecycle observer
  /// 2. Listens to auth state changes
  /// 3. Starts monitoring if user is authenticated
  ///
  /// Should be called once during app initialization.
  void initialize() {
    if (_isInitialized) {
      debugPrint('[SessionManager] Already initialized');
      return;
    }

    debugPrint('[SessionManager] Initializing session manager...');

    // Register as lifecycle observer to handle app pause/resume
    WidgetsBinding.instance.addObserver(this);

    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      _isAuthenticated = user != null;

      if (user != null) {
        debugPrint('[SessionManager] User authenticated, starting activity monitoring');
        recordActivity();
      } else {
        debugPrint('[SessionManager] User signed out, stopping monitoring');
        _stopAllTimers();
        _isInGracePeriod = false;
        _hasShownWarning = false;
        _lastActivityTime = null;
        _gracePeriodStartTime = null;
        notifyListeners();
      }
    });

    _isInitialized = true;
    debugPrint('[SessionManager] Initialization complete');
  }

  // ============================================================================
  // Activity Recording
  // ============================================================================

  /// Record user activity - resets all timers
  ///
  /// Call this method whenever user interacts with the app:
  /// - Taps/clicks
  /// - Scrolling
  /// - Text input
  /// - Navigation
  ///
  /// If in grace period, exits grace period and returns to normal monitoring.
  void recordActivity() {
    if (!_isAuthenticated || !_isInitialized) {
      return;
    }

    final now = DateTime.now();

    debugPrint('[SessionManager] Activity recorded at $now');

    // Update last activity time
    _lastActivityTime = now;

    // If in grace period, exit it
    if (_isInGracePeriod) {
      debugPrint('[SessionManager] ✅ Activity resumed during grace period - exiting grace period');
      _exitGracePeriod();
    }

    // Reset inactivity timer
    _resetInactivityTimer();

    notifyListeners();
  }

  // ============================================================================
  // Timer Management
  // ============================================================================

  /// Start/reset inactivity detection timer
  ///
  /// Starts a 2-minute timer. When it expires, grace period begins.
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _hasShownWarning = false;

    _inactivityTimer = Timer(inactivityDuration, () {
      debugPrint('[SessionManager] ⏰ Inactivity detected - starting grace period');
      _startGracePeriod();
    });

    debugPrint('[SessionManager] Inactivity timer reset - will trigger in ${inactivityDuration.inMinutes} minutes');
  }

  /// Start grace period countdown
  ///
  /// Begins the 5-minute grace period before automatic sign-out.
  /// Schedules warning notification at 4-minute mark.
  void _startGracePeriod() {
    if (_isInGracePeriod) {
      debugPrint('[SessionManager] Grace period already active');
      return;
    }

    final now = DateTime.now();

    debugPrint('[SessionManager] ═══════════════════════════════════════');
    debugPrint('[SessionManager] 🚨 GRACE PERIOD STARTED at $now');
    debugPrint('[SessionManager] Duration: ${gracePeriodDuration.inMinutes} minutes');
    debugPrint('[SessionManager] Warning at: ${warningDuration.inMinutes} minutes');
    debugPrint('[SessionManager] Sign-out at: ${gracePeriodDuration.inMinutes} minutes');
    debugPrint('[SessionManager] ═══════════════════════════════════════');

    _isInGracePeriod = true;
    _gracePeriodStartTime = now;
    _hasShownWarning = false;

    notifyListeners();

    // Schedule warning notification at 4-minute mark
    Timer(warningDuration, () {
      if (_isInGracePeriod && !_hasShownWarning) {
        debugPrint('[SessionManager] ⚠️ WARNING: ${gracePeriodDuration.inMinutes - warningDuration.inMinutes} minute(s) until automatic sign-out');
        _hasShownWarning = true;
        notifyListeners();
      }
    });

    // Schedule automatic sign-out at end of grace period
    _gracePeriodTimer = Timer(gracePeriodDuration, () {
      if (_isInGracePeriod) {
        debugPrint('[SessionManager] ⏰ Grace period expired - signing out user');
        _performAutomaticSignOut();
      }
    });

    // Start periodic updates for UI countdown (every second)
    _gracePeriodUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isInGracePeriod) {
        notifyListeners();
      }
    });
  }

  /// Exit grace period (activity resumed)
  ///
  /// Cancels grace period timer and returns to normal activity monitoring.
  void _exitGracePeriod() {
    debugPrint('[SessionManager] Exiting grace period - activity resumed');

    _isInGracePeriod = false;
    _gracePeriodStartTime = null;
    _hasShownWarning = false;
    _gracePeriodTimer?.cancel();
    _gracePeriodUpdateTimer?.cancel();

    notifyListeners();
  }

  /// Stop all active timers
  ///
  /// Cancels all timers and cleans up resources.
  void _stopAllTimers() {
    _inactivityTimer?.cancel();
    _gracePeriodTimer?.cancel();
    _gracePeriodUpdateTimer?.cancel();

    _inactivityTimer = null;
    _gracePeriodTimer = null;
    _gracePeriodUpdateTimer = null;

    debugPrint('[SessionManager] All timers stopped');
  }

  // ============================================================================
  // Sign-out Management
  // ============================================================================

  /// Perform automatic sign-out
  ///
  /// Signs out the user after grace period expires.
  /// Cleans up all state and timers.
  Future<void> _performAutomaticSignOut() async {
    try {
      debugPrint('[SessionManager] ═══════════════════════════════════════');
      debugPrint('[SessionManager] 🔒 AUTOMATIC SIGN-OUT TRIGGERED');
      debugPrint('[SessionManager] Last activity: $_lastActivityTime');
      debugPrint('[SessionManager] Grace period start: $_gracePeriodStartTime');
      debugPrint('[SessionManager] ═══════════════════════════════════════');

      await _auth.signOut();

      _stopAllTimers();
      _isInGracePeriod = false;
      _gracePeriodStartTime = null;
      _lastActivityTime = null;
      _hasShownWarning = false;

      notifyListeners();

      debugPrint('[SessionManager] ✅ Sign-out completed successfully');
    } catch (e) {
      debugPrint('[SessionManager] ❌ ERROR during sign-out: $e');
    }
  }

  // ============================================================================
  // App Lifecycle Handling
  // ============================================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[SessionManager] 📱 App resumed - recording activity');
        recordActivity();
        break;

      case AppLifecycleState.paused:
        debugPrint('[SessionManager] 📱 App paused - timers continue in background');
        // Timers continue running in background
        break;

      case AppLifecycleState.inactive:
        debugPrint('[SessionManager] 📱 App inactive');
        break;

      case AppLifecycleState.detached:
        debugPrint('[SessionManager] 📱 App detached');
        break;

      case AppLifecycleState.hidden:
        debugPrint('[SessionManager] 📱 App hidden');
        break;
    }
  }

  // ============================================================================
  // Cleanup
  // ============================================================================

  @override
  void dispose() {
    debugPrint('[SessionManager] Disposing session manager...');
    WidgetsBinding.instance.removeObserver(this);
    _stopAllTimers();
    super.dispose();
  }
}
