import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

/// Monitors app lifecycle and validates auth session on app resume.
///
/// This service:
/// - Monitors app state changes (foreground/background)
/// - Validates session when app resumes from background
/// - Proactively refreshes tokens on app resume
/// - Signs out expired sessions (>24 hours)
///
/// Integration:
/// - Initialize in main.dart after Firebase initialization
/// - Dispose when app is shutting down
///
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// final lifecycleService = AppLifecycleService(authService);
/// lifecycleService.initialize();
/// ```
class AppLifecycleService extends WidgetsBindingObserver {
  final AuthService _authService;

  AppLifecycleService(this._authService);

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
  /// Triggers session validation when app resumes from background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[Lifecycle] App resumed, validating session');
      _validateSessionOnResume();
    }
  }

  /// Validates auth session when app resumes.
  ///
  /// This method:
  /// 1. Checks if user is currently authenticated
  /// 2. Validates session age (<24 hours)
  /// 3. Signs out if session expired
  /// 4. Refreshes token if session valid
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
      } else {
        // Session valid - proactively refresh token to prevent expiration
        try {
          await user.getIdToken(true); // Force token refresh

          debugPrint('[Lifecycle] Token refreshed successfully on app resume');
        } catch (e) {
          debugPrint('[Lifecycle] Token refresh failed on app resume: $e');

          // Token refresh failed - likely auth issue, sign out to be safe
          await _authService.signOut();
        }
      }
    }
  }
}
