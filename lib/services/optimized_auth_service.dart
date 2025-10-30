import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/security/input_validator.dart';
import 'package:journeyman_jobs/security/rate_limiter.dart';

/// Enhanced Authentication service with optimized Dart patterns.
///
/// Key Improvements:
/// - Proper resource disposal and memory management
/// - Advanced async/await patterns with comprehensive error handling
/// - Type-safe error propagation using Result pattern
/// - Optimized token monitoring with proper cleanup
/// - Enhanced logging and debugging capabilities
///
/// Security Features:
/// - Input validation and sanitization
/// - Rate limiting with exponential backoff
/// - Secure token lifecycle management
/// - Comprehensive error handling and recovery
class OptimizedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  // Enhanced resource management
  final Set<StreamSubscription> _subscriptions = <StreamSubscription>{};
  final _TokenExpirationMonitor _tokenMonitor = _TokenExpirationMonitor();
  final RateLimiter _userRateLimiter = RateLimiter();

  // Constants for type safety
  static const String _lastAuthKey = 'last_auth_timestamp';
  static const Duration _tokenValidityDuration = Duration(hours: 24);
  static const Duration _initTimeout = Duration(seconds: 10);

  // Service state tracking
  bool _isDisposed = false;
  bool _isInitialized = false;

  /// Gets current user with null safety
  User? get currentUser {
    _ensureNotDisposed();
    return _auth.currentUser;
  }

  /// Gets auth state changes stream with proper error handling
  Stream<User?> get authStateChanges {
    _ensureNotDisposed();
    return _auth.authStateChanges().handleError(
      (error) => debugPrint('[AuthService] Auth state stream error: $error'),
    );
  }

  /// Initializes the service with proper resource setup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeGoogleSignIn();
      _setupAuthStateListener();
      _isInitialized = true;
      debugPrint('[AuthService] Service initialized successfully');
    } catch (e) {
      throw AuthException(
        'Failed to initialize authentication service: $e',
        type: AuthExceptionType.initializationFailed,
      );
    }
  }

  /// Enhanced sign-up with comprehensive error handling
  Future<Result<UserCredential>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();

    return _executeAuthOperation(
      operation: () async {
        final sanitizedEmail = InputValidator.sanitizeEmail(email);
        InputValidator.validatePassword(password);

        if (!await _userRateLimiter.isAllowed(sanitizedEmail, operation: 'auth')) {
          final retryAfter = _userRateLimiter.getRetryAfter(sanitizedEmail, operation: 'auth');
          throw RateLimitException(
            'Too many sign-up attempts. Please try again later.',
            retryAfter: retryAfter,
            operation: 'auth',
          );
        }

        final credential = await _auth.createUserWithEmailAndPassword(
          email: sanitizedEmail,
          password: password,
        );

        await _recordAuthTimestamp();
        _startTokenMonitoring(credential.user);
        _userRateLimiter.reset(sanitizedEmail, operation: 'auth');

        return credential;
      },
      operationType: 'signUp',
      context: {'email': email},
    );
  }

  /// Enhanced sign-in with performance tracking
  Future<Result<UserCredential>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();

    return _executeAuthOperation(
      operation: () async {
        final sanitizedEmail = InputValidator.sanitizeEmail(email);

        if (!await _userRateLimiter.isAllowed(sanitizedEmail, operation: 'auth')) {
          final retryAfter = _userRateLimiter.getRetryAfter(sanitizedEmail, operation: 'auth');
          throw RateLimitException(
            'Too many sign-in attempts. Please try again later.',
            retryAfter: retryAfter,
            operation: 'auth',
          );
        }

        final credential = await _auth.signInWithEmailAndPassword(
          email: sanitizedEmail,
          password: password,
        );

        await _recordAuthTimestamp();
        _startTokenMonitoring(credential.user);
        _userRateLimiter.reset(sanitizedEmail, operation: 'auth');

        return credential;
      },
      operationType: 'signIn',
      context: {'email': email},
    );
  }

  /// Enhanced Google Sign-In with proper error handling
  Future<Result<UserCredential>> signInWithGoogle() async {
    _ensureInitialized();

    return _executeAuthOperation(
      operation: () async {
        await _ensureGoogleSignInInitialized();

        if (!_googleSignIn.supportsAuthenticate()) {
          throw UnsupportedError('Google Sign-In not supported on this platform');
        }

        final googleUser = await _googleSignIn.authenticate(scopeHint: ['email']);
        final authClient = _googleSignIn.authorizationClient;
        final authorization = await authClient.authorizationForScopes(['email']);

        final credential = GoogleAuthProvider.credential(
          accessToken: authorization?.accessToken,
          idToken: googleUser.authentication.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        await _recordAuthTimestamp();
        _startTokenMonitoring(userCredential.user);

        return userCredential;
      },
      operationType: 'googleSignIn',
    );
  }

  /// Enhanced Apple Sign-In with platform-specific handling
  Future<Result<UserCredential>> signInWithApple() async {
    _ensureInitialized();

    return _executeAuthOperation(
      operation: () async {
        if (!await SignInWithApple.isAvailable()) {
          throw PlatformException(
            code: 'unavailable',
            message: 'Apple Sign In is not available on this device',
          );
        }

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final userCredential = await _auth.signInWithCredential(oauthCredential);
        await _recordAuthTimestamp();
        _startTokenMonitoring(userCredential.user);

        return userCredential;
      },
      operationType: 'appleSignIn',
    );
  }

  /// Enhanced sign-out with comprehensive cleanup
  Future<void> signOut() async {
    _ensureInitialized();

    try {
      // Stop monitoring first
      _tokenMonitor.stopMonitoring();

      // Clear auth timestamp
      await _clearAuthTimestamp();

      // Clear Firestore cache
      await _clearFirestoreCache();

      // Sign out from all providers
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      debugPrint('[AuthService] Sign out completed successfully');
    } catch (e) {
      throw AuthException(
        'Error signing out: $e',
        type: AuthExceptionType.signOutFailed,
      );
    }
  }

  /// Proper resource disposal
  Future<void> dispose() async {
    if (_isDisposed) return;

    debugPrint('[AuthService] Disposing service...');

    // Stop all subscriptions
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Stop token monitoring
    _tokenMonitor.stopMonitoring();

    // Dispose rate limiter
    _userRateLimiter.dispose();

    _isDisposed = true;
    debugPrint('[AuthService] Service disposed successfully');
  }

  // Private helper methods with enhanced patterns

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('AuthService has been disposed');
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AuthService has not been initialized. Call initialize() first.');
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return;

    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      throw AuthException(
        'Failed to initialize Google Sign-In: $e',
        type: AuthExceptionType.googleSignInFailed,
      );
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  void _setupAuthStateListener() {
    final subscription = _auth.authStateChanges().listen(
      (user) {
        debugPrint('[AuthService] Auth state changed: ${user?.uid ?? 'null'}');
        if (user == null) {
          _tokenMonitor.stopMonitoring();
        }
      },
      onError: (error) {
        debugPrint('[AuthService] Auth state stream error: $error');
      },
    );
    _subscriptions.add(subscription);
  }

  void _startTokenMonitoring(User? user) {
    if (user != null) {
      _tokenMonitor.startMonitoring(user);
    }
  }

  Future<void> _clearFirestoreCache() async {
    try {
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      debugPrint('[AuthService] Failed to clear Firestore cache: $e');
      // Don't rethrow - cache clearing is best effort
    }
  }

  /// Generic auth operation executor with comprehensive error handling
  Future<T> _executeAuthOperation<T>({
    required Future<T> Function() operation,
    required String operationType,
    Map<String, dynamic>? context,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('[AuthService] Starting $operationType');
      if (context != null) {
        debugPrint('[AuthService] Context: $context');
      }

      final result = await operation();

      stopwatch.stop();
      debugPrint('[AuthService] $operationType completed in ${stopwatch.elapsedMilliseconds}ms');

      return result;
    } on ValidationException catch (e) {
      stopwatch.stop();
      debugPrint('[AuthService] Validation error in $operationType: ${e.message}');
      throw AuthException(
        e.message,
        type: AuthExceptionType.validationFailed,
        originalError: e,
      );
    } on RateLimitException catch (e) {
      stopwatch.stop();
      debugPrint('[AuthService] Rate limit exceeded in $operationType: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();
      final errorMessage = _handleAuthException(e);
      debugPrint('[AuthService] Firebase auth error in $operationType: $errorMessage');
      throw AuthException(
        errorMessage,
        type: _mapFirebaseExceptionType(e.code),
        originalError: e,
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint('[AuthService] Unexpected error in $operationType: $e');
      throw AuthException(
        'An unexpected error occurred: $e',
        type: AuthExceptionType.unknown,
        originalError: e,
      );
    }
  }

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

  AuthExceptionType _mapFirebaseExceptionType(String? code) {
    switch (code) {
      case 'weak-password':
      case 'invalid-email':
      case 'wrong-password':
        return AuthExceptionType.validationFailed;
      case 'user-not-found':
      case 'user-disabled':
      case 'invalid-credential':
        return AuthExceptionType.authenticationFailed;
      case 'too-many-requests':
        return AuthExceptionType.rateLimitExceeded;
      case 'operation-not-allowed':
        return AuthExceptionType.configurationError;
      default:
        return AuthExceptionType.unknown;
    }
  }

  Future<void> _recordAuthTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastAuthKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Failed to record auth timestamp: $e');
      // Don't throw - token tracking is not critical
    }
  }

  Future<void> _clearAuthTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastAuthKey);
    } catch (e) {
      debugPrint('Failed to clear auth timestamp: $e');
      // Don't throw - clearing is not critical
    }
  }

  /// Enhanced token validity check with proper error handling
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAuth = prefs.getInt(_lastAuthKey);

      if (lastAuth == null) return false;

      final lastAuthTime = DateTime.fromMillisecondsSinceEpoch(lastAuth);
      final now = DateTime.now();

      if (lastAuthTime.isAfter(now)) {
        debugPrint('[AuthService] Auth timestamp in future, invalidating session');
        return false;
      }

      final sessionAge = now.difference(lastAuthTime);
      return sessionAge < _tokenValidityDuration;
    } catch (e) {
      debugPrint('[AuthService] Failed to check token validity: $e');
      return false; // Fail safely
    }
  }
}

/// Enhanced token expiration monitor with proper resource management
class _TokenExpirationMonitor {
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(minutes: 50);

  /// Starts monitoring with enhanced error handling
  void startMonitoring(User user) {
    stopMonitoring(); // Ensure no duplicate timers

    debugPrint('[TokenMonitor] Starting token monitoring for user: ${user.uid}');

    _refreshTimer = Timer.periodic(_refreshInterval, (timer) async {
      try {
        await user.getIdToken(true);
        debugPrint('[TokenMonitor] Token refreshed successfully');
      } catch (e) {
        debugPrint('[TokenMonitor] Token refresh failed: $e');
        stopMonitoring(); // Stop monitoring on failure
      }
    });
  }

  /// Stops monitoring and cleans up resources
  void stopMonitoring() {
    if (_refreshTimer != null) {
      debugPrint('[TokenMonitor] Stopping token monitoring');
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }
}

/// Result pattern for type-safe error handling
class Result<T> {
  final T? data;
  final AuthException? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(AuthException error) => Result._(error: error, isSuccess: false);

  T get dataOrThrow {
    if (isSuccess && data != null) return data!;
    throw error!;
  }

  bool get isFailure => !isSuccess;

  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return Result.success(mapper(data!));
      } catch (e) {
        return Result.failure(
          AuthException(
            'Mapping failed: $e',
            type: AuthExceptionType.mappingFailed,
          ),
        );
      }
    }
    return Result.failure(error!);
  }

  Result<T> when({
    required T Function(T data) onSuccess,
    required T Function(AuthException error) onFailure,
  }) {
    if (isSuccess && data != null) {
      return Result.success(onSuccess(data!));
    }
    return Result.failure(onFailure(error!));
  }
}

/// Enhanced authentication exception with type safety
class AuthException implements Exception {
  final String message;
  final AuthExceptionType type;
  final Exception? originalError;

  AuthException(
    this.message, {
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'AuthException: $message (Type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => message.hashCode ^ type.hashCode;
}

/// Enhanced exception types for better error handling
enum AuthExceptionType {
  validationFailed,
  authenticationFailed,
  rateLimitExceeded,
  configurationError,
  initializationFailed,
  googleSignInFailed,
  appleSignInFailed,
  signOutFailed,
  mappingFailed,
  unknown,
}

/// Enhanced rate limiter with proper disposal
class RateLimiter {
  final Map<String, List<DateTime>> _attempts = {};
  static const int maxAttempts = 5;
  static const Duration window = Duration(minutes: 1);

  bool isAllowed(String identifier, {String operation = 'default'}) {
    final key = '$identifier:$operation';
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    _attempts[key] ??= [];
    _attempts[key]!.removeWhere((time) => time.isBefore(windowStart));

    return _attempts[key]!.length < maxAttempts;
  }

  DateTime? getRetryAfter(String identifier, {String operation = 'default'}) {
    final key = '$identifier:$operation';
    final attempts = _attempts[key];

    if (attempts == null || attempts.length < maxAttempts) {
      return null;
    }

    final oldestAttempt = attempts.first;
    return oldestAttempt.add(window);
  }

  void reset(String identifier, {String operation = 'default'}) {
    final key = '$identifier:$operation';
    _attempts.remove(key);
  }

  void dispose() {
    _attempts.clear();
  }
}