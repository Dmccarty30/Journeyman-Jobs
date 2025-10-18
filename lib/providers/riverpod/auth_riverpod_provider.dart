import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Current user provider
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
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
