import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication service that handles Firebase Auth operations and token management.
///
/// Supports:
/// - Email/password authentication
/// - Google Sign-In
/// - Apple Sign-In
/// - Token age tracking for limited offline support (24-hour session)
/// - Automatic token refresh (50-minute intervals)
/// - Session expiration monitoring
/// - Password reset
/// - Account management (update email, password, delete account)
///
/// Token Lifecycle:
/// - Firebase tokens expire after ~60 minutes
/// - Automatic refresh occurs every 50 minutes (preventive)
/// - Sessions expire after 24 hours (user requirement)
/// - App lifecycle triggers token validation on resume
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  // Token monitoring for automatic refresh
  final _TokenExpirationMonitor _tokenMonitor = _TokenExpirationMonitor();

  // Token validity tracking constants
  static const String _lastAuthKey = 'last_auth_timestamp';
  static const Duration _tokenValidityDuration = Duration(hours: 24);

  // Initialize Google Sign-In
  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
  }

  // Ensure Google Sign-In is initialized
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Record successful authentication timestamp for token tracking
      await _recordAuthTimestamp();

      // Start token expiration monitoring
      if (credential.user != null) {
        _tokenMonitor.startMonitoring(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email & Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Record successful authentication timestamp for token tracking
      await _recordAuthTimestamp();

      // Start token expiration monitoring
      if (credential.user != null) {
        _tokenMonitor.startMonitoring(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure Google Sign-In is initialized
      await _ensureGoogleSignInInitialized();

      // Check if authenticate is supported
      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError('Google Sign-In not supported on this platform');
      }

      // Trigger the authentication flow with v7 API
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // Get authorization client for accessing tokens
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);

      // Record successful authentication timestamp for token tracking
      await _recordAuthTimestamp();

      // Start token expiration monitoring
      if (userCredential.user != null) {
        _tokenMonitor.startMonitoring(userCredential.user!);
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In error: ${e.code.name} - ${e.description}');
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Apple Sign In
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential from the credential returned by Apple
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Record successful authentication timestamp for token tracking
      await _recordAuthTimestamp();

      // Start token expiration monitoring
      if (userCredential.user != null) {
        _tokenMonitor.startMonitoring(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Stop token monitoring
      _tokenMonitor.stopMonitoring();

      // Clear auth timestamp before signing out
      await _clearAuthTimestamp();

      // Clear Firestore cache to prevent stale data
      try {
        await FirebaseFirestore.instance.terminate();
        await FirebaseFirestore.instance.clearPersistence();
      } catch (e) {
        // Cache clearing is best-effort - log but don't block sign-out
        debugPrint('[AuthService] Failed to clear Firestore cache: $e');
      }

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Email
  Future<void> updateEmail({required String newEmail}) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Password
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============================================================================
  // Token Age Tracking (for limited offline support)
  // ============================================================================

  /// Records the current timestamp as last successful authentication.
  ///
  /// This should be called after any successful sign-in operation to track
  /// when the user last authenticated. Used for token validity checks.
  ///
  /// Implementation note: This is private and called internally by sign-in methods.
  Future<void> _recordAuthTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastAuthKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Log error but don't throw - token tracking is not critical
      debugPrint('Failed to record auth timestamp: $e');
    }
  }

  /// Checks if the stored auth session is still valid (< 24 hours old).
  ///
  /// Returns true if:
  /// - A timestamp exists in storage AND
  /// - The timestamp is less than 24 hours old AND
  /// - The timestamp is not in the future (no clock skew)
  ///
  /// Returns false if:
  /// - No timestamp exists (first launch or cleared data) OR
  /// - Timestamp is older than 24 hours OR
  /// - Timestamp is in the future (clock skew detected)
  ///
  /// This is used for limited offline support - after 24 hours, we should
  /// require re-authentication for security (user requirement).
  ///
  /// Note: This checks SESSION age (24 hours), not Firebase token age (60 minutes).
  /// Firebase tokens are automatically refreshed by the token monitor.
  ///
  /// Example usage:
  /// ```dart
  /// if (!await authService.isTokenValid()) {
  ///   // Session expired (>24 hours) - require re-authentication
  ///   await authService.signOut();
  /// }
  /// ```
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAuth = prefs.getInt(_lastAuthKey);

      if (lastAuth == null) return false;

      final lastAuthTime = DateTime.fromMillisecondsSinceEpoch(lastAuth);
      final now = DateTime.now();

      // Check for future timestamp (clock skew)
      if (lastAuthTime.isAfter(now)) {
        debugPrint('[AuthService] Auth timestamp in future, invalidating session');
        return false;
      }

      final sessionAge = now.difference(lastAuthTime);

      return sessionAge < _tokenValidityDuration; // 24 hours
    } catch (e) {
      // Log error and assume invalid to be safe
      debugPrint('[AuthService] Failed to check token validity: $e');
      return false;
    }
  }

  /// Clears the stored auth timestamp.
  ///
  /// This should be called when the user signs out to ensure clean state.
  Future<void> _clearAuthTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastAuthKey);
    } catch (e) {
      // Log error but don't throw - clearing is not critical
      debugPrint('Failed to clear auth timestamp: $e');
    }
  }

  // ============================================================================
  // Error Handling
  // ============================================================================

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'The supplied credential is invalid.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

// ============================================================================
// Token Expiration Monitor (Private Class)
// ============================================================================

/// Monitors Firebase Auth token expiration and refreshes proactively.
///
/// Firebase tokens expire after ~60 minutes. This monitor refreshes tokens
/// every 50 minutes to prevent mid-session permission denied errors.
///
/// Lifecycle:
/// - Started when user signs in (all sign-in methods)
/// - Stopped when user signs out
/// - Automatically stops on refresh failure (user likely signed out)
///
/// Implementation note: This is a private class used only by AuthService.
class _TokenExpirationMonitor {
  Timer? _refreshTimer;

  /// Token refresh interval (50 minutes to stay ahead of 60-minute expiration)
  static const _refreshInterval = Duration(minutes: 50);

  /// Starts monitoring the Firebase Auth token for the given user.
  ///
  /// Sets up a periodic timer that refreshes the token every 50 minutes.
  /// If a timer is already active, it will be cancelled and replaced.
  ///
  /// Parameters:
  /// - user: The Firebase User whose token should be monitored
  void startMonitoring(User user) {
    // Cancel any existing timer to prevent duplicates
    stopMonitoring();

    debugPrint('[TokenMonitor] Starting token monitoring for user: ${user.uid}');

    _refreshTimer = Timer.periodic(_refreshInterval, (timer) async {
      try {
        // Force token refresh (true parameter)
        await user.getIdToken(true);

        debugPrint('[TokenMonitor] Token refreshed successfully');
      } catch (e) {
        debugPrint('[TokenMonitor] Token refresh failed: $e');

        // Stop monitoring if refresh fails (user likely signed out or network issue)
        stopMonitoring();
      }
    });
  }

  /// Stops monitoring the token.
  ///
  /// Cancels the periodic refresh timer. Safe to call even if no timer is active.
  void stopMonitoring() {
    if (_refreshTimer != null) {
      debugPrint('[TokenMonitor] Stopping token monitoring');
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }
}
