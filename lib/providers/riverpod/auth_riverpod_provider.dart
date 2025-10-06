import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/auth_service.dart';
import '../../utils/concurrent_operations.dart';

part 'auth_riverpod_provider.g.dart';

/// Represents the state of authentication within the application.
///
/// This immutable class holds the current user, loading status, any errors,
/// and performance metrics related to authentication operations.
class AuthState {

  /// Creates an instance of the authentication state.
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.lastSignInDuration,
    this.signInSuccessRate = 0.0,
  });
  /// The currently authenticated Firebase user, or `null` if not authenticated.
  final User? user;
  /// `true` if an authentication operation is currently in progress.
  final bool isLoading;
  /// A string description of the last authentication error that occurred.
  final String? error;
  /// The duration of the last sign-in attempt.
  final Duration? lastSignInDuration;
  /// The success rate of sign-in attempts as a percentage.
  final double signInSuccessRate;

  /// A convenience getter to check if a user is currently authenticated.
  bool get isAuthenticated => user != null;

  /// Creates a new [AuthState] instance with updated field values.
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

  /// Returns a new [AuthState] instance with the `error` field cleared.
  AuthState clearError() => copyWith(error: null);
}

/// Provides an app-wide instance of [AuthService].
@riverpod
AuthService authService(Ref ref) => AuthService();

/// Provides a stream of the current authentication state from Firebase.
///
/// This stream emits a new [User] object whenever the user signs in or out.
@riverpod
Stream<User?> authStateStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

/// Provides the currently authenticated [User] object, or `null`.
///
/// This is derived from the [authStateStreamProvider] and offers direct,
/// synchronous access to the current user state.
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// The primary state notifier for handling authentication logic.
///
/// This class manages the [AuthState] and exposes methods for signing in,
/// signing out, and handling errors. It uses a [ConcurrentOperationManager]
/// to prevent duplicate operations.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final ConcurrentOperationManager _operationManager;
  int _signInAttempts = 0;
  int _successfulSignIns = 0;

  @override
  AuthState build() {
    _operationManager = ConcurrentOperationManager();
    
    // Listen to auth state changes
    ref.listen(authStateStreamProvider, (AsyncValue<User?>? previous, AsyncValue<User?> next) {
      next.when(
        data: (User? user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
        },
        loading: () {
          state = state.copyWith(isLoading: true);
        },
        error: (Object error, _) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    });

    return const AuthState();
  }

  /// Signs in a user with their email and password.
  ///
  /// Manages the loading state and updates the [AuthState] with the result
  /// of the sign-in attempt, including performance metrics.
  /// Throws an error if the sign-in fails.
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

  /// Signs out the current user.
  ///
  /// Manages the loading state and updates the [AuthState] upon completion.
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

  /// Clears any authentication error message from the state.
  void clearError() {
    state = state.clearError();
  }

  /// Disposes of managed resources, such as the [ConcurrentOperationManager].
  void dispose() {
    _operationManager.dispose();
  }
}

/// A convenience provider that returns a simple boolean indicating if the user is authenticated.
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

/// A utility provider used for route guarding.
///
/// It checks if a given [routePath] matches any of the predefined protected routes
/// that require authentication for access.
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
