import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'session_timeout_service.dart';

/// Monitors app lifecycle and validates auth session on app resume.
///
/// This service:
/// - Monitors app state changes (foreground/background)
/// - Validates session when app resumes from background
/// - Proactively refreshes tokens on app resume
/// - Signs out expired sessions (>24 hours)
/// - Handles session timeout on app closure (auto-logout requirement)
///
/// Integration:
/// - Initialize in main.dart after Firebase initialization
/// - Dispose when app is shutting down
///
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// final sessionTimeoutService = SessionTimeoutService();
/// final lifecycleService = AppLifecycleService(authService, sessionTimeoutService);
/// lifecycleService.initialize();
/// ```
class AppLifecycleService extends WidgetsBindingObserver {
  final AuthService _authService;
  final SessionTimeoutService? _sessionTimeoutService;

  AppLifecycleService(
    this._authService, [
    this._sessionTimeoutService,
  ]);

  /// Initializes lifecycle monitoring.
  ///
  /// Registers this service as a WidgetsBindingObserver to receive
  /// app lifecycle events.
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[Lifecycle] App lifecycle monitoring initialized');
  }

  /// Disposes lifecycle monitoring.
  ///
  /// Unregisters this service from receiving lifecycle events.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[Lifecycle] App lifecycle monitoring disposed');
  }

  /// Called when the app lifecycle state changes.
  ///
  /// Handles different lifecycle states:
  /// - resumed: Validate session and refresh tokens
  /// - paused: App moved to background (no action needed)
  /// - detached: App is about to close - end session for auto-logout
  /// - inactive: App lost focus temporarily
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[Lifecycle] App resumed, validating session');
        _validateSessionOnResume();
        break;

      case AppLifecycleState.detached:
        // App is closing - end session to trigger auto-logout requirement
        debugPrint('[Lifecycle] App detached (closing), ending session');
        _handleAppClosure();
        break;

      case AppLifecycleState.paused:
        debugPrint('[Lifecycle] App paused (backgrounded)');
        // No action needed - session timeout will handle inactivity
        break;

      case AppLifecycleState.inactive:
        debugPrint('[Lifecycle] App inactive (lost focus)');
        // No action needed - temporary state
        break;

      case AppLifecycleState.hidden:
        debugPrint('[Lifecycle] App hidden');
        // No action needed on newer Flutter versions
        break;
    }
  }

  /// Validates auth session when app resumes.
  ///
  /// This method:
  /// 1. Checks if user is currently authenticated
  /// 2. Validates session age (<24 hours)
  /// 3. Signs out if session expired
  /// 4. Refreshes token if session valid
  /// 5. Restarts session timeout monitoring
  ///
  /// Prevents mid-session auth errors by ensuring token freshness.
  Future<void> _validateSessionOnResume() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if session is still valid (24-hour check)
      final isValid = await _authService.isTokenValid();

      if (!isValid) {
        debugPrint('[Lifecycle] Session expired on app resume (>24 hours), signing out');

        // Session expired - sign out user
        await _authService.signOut();

        // End session timeout monitoring
        await _sessionTimeoutService?.endSession();
      } else {
        // Session valid - proactively refresh token to prevent expiration
        try {
          await user.getIdToken(true); // Force token refresh

          debugPrint('[Lifecycle] Token refreshed successfully on app resume');

          // Restart session timeout monitoring (records activity)
          if (_sessionTimeoutService?.isSessionActive != true) {
            await _sessionTimeoutService?.startSession();
          } else {
            // Session already active - just record activity
            await _sessionTimeoutService?.recordActivity();
          }
        } catch (e) {
          debugPrint('[Lifecycle] Token refresh failed on app resume: $e');

          // Token refresh failed - likely auth issue, sign out to be safe
          await _authService.signOut();
          await _sessionTimeoutService?.endSession();
        }
      }
    }
  }

  /// Handles app closure event.
  ///
  /// When the app is closing (detached state), this method:
  /// 1. Ends the session timeout monitoring
  /// 2. Marks session as inactive in persistent storage
  /// 3. Next app launch will detect session was closed and require re-auth
  ///
  /// This implements the "auto-logout when app is closed" requirement.
  Future<void> _handleAppClosure() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _sessionTimeoutService != null) {
      // End session - this marks session as inactive
      // On next app launch, initialize() will detect the inactive session
      // and trigger auto-logout
      await _sessionTimeoutService.endSession();

      debugPrint('[Lifecycle] Session ended due to app closure');
    }
  }
}
