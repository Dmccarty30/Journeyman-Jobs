import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/concurrent_operations.dart';
import '../core_providers.dart' hide AuthService;

part 'auth_riverpod_provider.g.dart';

/// Provides a stream of the current user's `UserModel`.
final userModelStreamProvider = StreamProvider.autoDispose<UserModel>((ref) {
  final firestoreService = ref.watch(realFirestoreServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return Stream.error('User not logged in');
  }

  return firestoreService.getUserStream(user.uid).map(
        (snapshot) => UserModel.fromFirestore(snapshot),
      );
});

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
    bool clearError = false,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        lastSignInDuration: lastSignInDuration ?? this.lastSignInDuration,
        signInSuccessRate: signInSuccessRate ?? this.signInSuccessRate,
      );

  AuthState clearError() => copyWith(clearError: true);
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

/// Provider for the current user's ID only.
/// This prevents unnecessary rebuilds when other user properties change.
@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(currentUserProvider)?.uid;
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

    // Listen to auth state changes
    ref.listen(authStateStreamProvider,
        (AsyncValue<User?>? previous, AsyncValue<User?> next) {
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
        operation: () =>
            ref.read(authServiceProvider).signInWithEmailAndPassword(
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
