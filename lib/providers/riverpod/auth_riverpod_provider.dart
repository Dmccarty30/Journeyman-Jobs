import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/auth_service.dart';
import '../../utils/concurrent_operations.dart';

part 'auth_riverpod_provider.g.dart';

/// Authentication state model for Riverpod
class AuthState {

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.lastSignInDuration,
    this.signInSuccessRate = 0.0,
  });
  final User? user;
  final bool isLoading;
  final String? error;
  final Duration? lastSignInDuration;
  final double signInSuccessRate;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    Duration? lastSignInDuration,
    double? signInSuccessRate,
  }) => AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastSignInDuration: lastSignInDuration ?? this.lastSignInDuration,
      signInSuccessRate: signInSuccessRate ?? this.signInSuccessRate,
    );

  AuthState clearError() => copyWith();
}

/// AuthService provider
@riverpod
AuthService authService(Ref ref) => AuthService();

/// Auth state stream provider
@riverpod
Stream<User?> authStateStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

/// Provides the current authenticated user wrapped in AsyncValue.
///
/// Use this when you need to distinguish between loading state and unauthenticated state:
/// - AsyncValue.loading: Firebase Auth is still initializing
/// - AsyncValue.data(null): User is confirmed unauthenticated
/// - AsyncValue.data(User): User is authenticated
/// - AsyncValue.error: Auth initialization failed
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   data: (user) => user != null ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => ErrorScreen(error: err),
/// );
/// ```
@riverpod
AsyncValue<User?> authState(Ref ref) {
  return ref.watch(authStateStreamProvider);
}

/// Simple provider that returns current user or null.
///
/// Returns null in two cases:
/// - Auth is still loading (Firebase initializing)
/// - User is confirmed unauthenticated
///
/// Use authState provider if you need to distinguish these states.
///
/// Example usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   // User is authenticated
/// }
/// ```
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.whenOrNull(data: (user) => user);
}

/// Tracks whether Firebase Auth has completed its initial state check.
///
/// Returns `AsyncValue<bool>`:
/// - `AsyncValue.loading`: Auth still initializing
/// - `AsyncValue.data(true)`: Auth initialized (user may be null or User object)
/// - `AsyncValue.error`: Auth initialization failed (but app continues)
///
/// Use this to show loading screens while auth initializes.
///
/// Example usage:
/// ```dart
/// final authInit = ref.watch(authInitializationProvider);
/// authInit.when(
///   loading: () => SplashScreen(),
///   data: (initialized) => initialized ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => HomeScreen(), // Continue on error
/// );
/// ```
@riverpod
class AuthInitialization extends _$AuthInitialization {
  /// Maximum time to wait for auth initialization before proceeding.
  /// Prevents indefinite loading if Firebase Auth has issues.
  static const _maxInitTimeout = Duration(seconds: 5);

  @override
  Future<bool> build() async {
    final authService = ref.watch(authServiceProvider);

    try {
      // Wait for first auth state emission (indicates Firebase Auth is ready)
      // This ensures we know whether user is authenticated or not before proceeding
      await authService.authStateChanges
        .first
        .timeout(_maxInitTimeout);

      return true;
    } on TimeoutException {
      // Auth initialization took too long - proceed anyway to avoid infinite loading
      // This is better than blocking the user indefinitely
      return true;
    } catch (e) {
      // Auth initialization error - log it but don't block the app
      // User can still use offline features or try signing in manually
      return true;
    }
  }
}

/// Auth state notifier for managing authentication operations
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final ConcurrentOperationManager _operationManager;
  int _signInAttempts = 0;
  int _successfulSignIns = 0;

  @override
  AuthState build() {
    _operationManager = ConcurrentOperationManager();

    // Watch the auth state stream to get real-time authentication updates
    final authStateAsync = ref.watch(authStateStreamProvider);

    // Transform AsyncValue<User?> into AuthState using pattern matching
    return authStateAsync.when(
      // User is authenticated - return AuthState with user data
      data: (user) => AuthState(
        user: user,
        isLoading: false,
        error: null,
      ),

      // Authentication status is being checked - return loading state
      loading: () => const AuthState(
        user: null,
        isLoading: true,
        error: null,
      ),

      // Authentication error occurred - return error state
      error: (error, stackTrace) => AuthState(
        user: null,
        isLoading: false,
        error: error.toString(),
      ),
    );
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_operationManager.isOperationInProgress(OperationType.signIn)) {
      return;
    }

    state = state.copyWith(isLoading: true);
    _signInAttempts++;

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      await _operationManager.executeOperation(
        type: OperationType.signIn,
        operation: () => ref.read(authServiceProvider).signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

      stopwatch.stop();
      _successfulSignIns++;
      
      state = state.copyWith(
        isLoading: false,
        lastSignInDuration: stopwatch.elapsed,
        signInSuccessRate: _successfulSignIns / _signInAttempts,
      );
    } catch (e) {
      stopwatch.stop();
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastSignInDuration: stopwatch.elapsed,
        signInSuccessRate: _successfulSignIns / _signInAttempts,
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_operationManager.isOperationInProgress(OperationType.signOut)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _operationManager.executeOperation(
        type: OperationType.signOut,
        operation: () => ref.read(authServiceProvider).signOut(),
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear authentication error
  void clearError() {
    state = state.clearError();
  }

  /// Dispose resources
  void dispose() {
    _operationManager.dispose();
  }
}

/// Convenience provider for auth state
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

/// Route guard provider
@riverpod
bool isRouteProtected(Ref ref, String routePath) {
  // Define protected routes
  const List<String> protectedRoutes = <String>[
    '/profile',
    '/settings',
    '/jobs',
    '/locals',
    '/storm',
    '/tools',
  ];

  return protectedRoutes.any((String route) => routePath.startsWith(route));
}

/// Monitors session validity and triggers re-auth when session expires.
///
/// Checks session age every 5 minutes and invalidates sessions >24 hours old.
/// This ensures compliance with the 24-hour session requirement.
///
/// The monitor:
/// - Runs periodic checks every 5 minutes
/// - Validates session timestamp against 24-hour limit
/// - Automatically signs out expired sessions
/// - Cleans up timer on provider disposal
///
/// Example usage:
/// ```dart
/// final sessionValid = ref.watch(sessionMonitorProvider);
/// if (!sessionValid) {
///   // Session expired - user will be redirected to login
/// }
/// ```
@riverpod
class SessionMonitor extends _$SessionMonitor {
  Timer? _checkTimer;

  /// Session validity check interval (5 minutes)
  static const _checkInterval = Duration(minutes: 5);

  @override
  bool build() {
    // Start monitoring when provider initializes
    _startMonitoring();

    // Clean up timer on dispose
    ref.onDispose(() {
      _checkTimer?.cancel();
    });

    return true; // Session valid initially
  }

  /// Starts periodic session validation checks.
  ///
  /// Runs every 5 minutes to check if session is still within 24-hour window.
  void _startMonitoring() {
    _checkTimer?.cancel();

    _checkTimer = Timer.periodic(_checkInterval, (_) async {
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        final isValid = await authService.isTokenValid();

        if (!isValid) {
          debugPrint('[SessionMonitor] Session expired (>24 hours), signing out');

          // Session expired - force sign out
          await authService.signOut();
          state = false; // Update state to invalid
        }
      }
    });
  }
}
