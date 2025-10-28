import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/optimized_auth_service.dart';
import '../../utils/concurrent_operations.dart';

part 'optimized_auth_riverpod_provider.g.dart';

/// Enhanced authentication state model with performance tracking
@immutable
class OptimizedAuthState {
  const OptimizedAuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.lastOperationDuration,
    this.signInMetrics,
    this.sessionInfo,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final Duration? lastOperationDuration;
  final SignInMetrics? signInMetrics;
  final SessionInfo? sessionInfo;

  bool get isAuthenticated => user != null;

  OptimizedAuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    Duration? lastOperationDuration,
    SignInMetrics? signInMetrics,
    SessionInfo? sessionInfo,
    bool clearError = false,
  }) {
    return OptimizedAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastOperationDuration: lastOperationDuration ?? this.lastOperationDuration,
      signInMetrics: signInMetrics ?? this.signInMetrics,
      sessionInfo: sessionInfo ?? this.sessionInfo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizedAuthState &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastOperationDuration == other.lastOperationDuration &&
          signInMetrics == other.signInMetrics &&
          sessionInfo == other.sessionInfo;

  @override
  int get hashCode => Object.hash(
        user,
        isLoading,
        error,
        lastOperationDuration,
        signInMetrics,
        sessionInfo,
      );

  @override
  String toString() => 'OptimizedAuthState('
      'user: ${user?.uid ?? 'null'}, '
      'isLoading: $isLoading, '
      'error: $error, '
      'isAuthenticated: $isAuthenticated'
      ')';
}

/// Enhanced authentication metrics tracking
@immutable
class SignInMetrics {
  const SignInMetrics({
    required this.totalAttempts,
    required this.successfulSignIns,
    required this.averageSignInTime,
    required this.lastSignInTime,
    required this.successRate,
    required this.failureReasons,
  });

  final int totalAttempts;
  final int successfulSignIns;
  final Duration averageSignInTime;
  final DateTime? lastSignInTime;
  final double successRate;
  final Map<String, int> failureReasons;

  SignInMetrics copyWith({
    int? totalAttempts,
    int? successfulSignIns,
    Duration? averageSignInTime,
    DateTime? lastSignInTime,
    double? successRate,
    Map<String, int>? failureReasons,
  }) {
    return SignInMetrics(
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successfulSignIns: successfulSignIns ?? this.successfulSignIns,
      averageSignInTime: averageSignInTime ?? this.averageSignInTime,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      successRate: successRate ?? this.successRate,
      failureReasons: failureReasons ?? this.failureReasons,
    );
  }
}

/// Session information for enhanced monitoring
@immutable
class SessionInfo {
  const SessionInfo({
    required this.sessionStart,
    required this.lastActivity,
    required this.sessionDuration,
    required this.isSessionValid,
    required this.tokenRefreshCount,
  });

  final DateTime sessionStart;
  final DateTime lastActivity;
  final Duration sessionDuration;
  final bool isSessionValid;
  final int tokenRefreshCount;

  SessionInfo copyWith({
    DateTime? sessionStart,
    DateTime? lastActivity,
    Duration? sessionDuration,
    bool? isSessionValid,
    int? tokenRefreshCount,
  }) {
    return SessionInfo(
      sessionStart: sessionStart ?? this.sessionStart,
      lastActivity: lastActivity ?? this.lastActivity,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      isSessionValid: isSessionValid ?? this.isSessionValid,
      tokenRefreshCount: tokenRefreshCount ?? this.tokenRefreshCount,
    );
  }
}

/// Enhanced AuthService provider with lazy initialization
@riverpod
class OptimizedAuthService extends _$OptimizedAuthService {
  @override
  Future<OptimizedAuthService> build() async {
    final service = OptimizedAuthService();

    // Initialize the service
    await service.initialize();

    // Ensure proper disposal
    ref.onDispose(() => service.dispose());

    return service;
  }
}

/// Enhanced auth state stream provider with error recovery
@riverpod
class AuthStateStream extends _$AuthStateStream {
  @override
  Stream<User?> build() async* {
    final authServiceAsync = ref.watch(optimizedAuthProvider.future);

    yield* authServiceAsync.then(
      (service) => service.authStateChanges.handleError(
        (error) {
          debugPrint('[AuthStateStream] Error: $error');
          // Continue with null user on error
          return null as User?;
        },
      ),
    ).asStream();
  }
}

/// Enhanced current user provider with caching
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  AsyncValue<User?> build() {
    final authStateAsync = ref.watch(authStateStreamProvider);

    return authStateAsync.when(
      data: (user) => AsyncValue.data(user),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }
}

/// Enhanced authentication state provider with comprehensive tracking
@riverpod
class OptimizedAuthNotifier extends _$OptimizedAuthNotifier {
  ConcurrentOperationManager? _operationManager;
  SignInMetrics? _signInMetrics;
  SessionInfo? _sessionInfo;
  Timer? _sessionMonitorTimer;
  int _tokenRefreshCount = 0;

  @override
  OptimizedAuthState build() {
    // Initialize operation manager
    _operationManager = ConcurrentOperationManager();

    // Initialize metrics
    _signInMetrics = const SignInMetrics(
      totalAttempts: 0,
      successfulSignIns: 0,
      averageSignInTime: Duration.zero,
      lastSignInTime: null,
      successRate: 0.0,
      failureReasons: {},
    );

    // Watch auth state stream for real-time updates
    final authStateAsync = ref.watch(authStateStreamProvider);

    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          _startSessionMonitoring(user);
          _updateSessionInfo(user);
        } else {
          _stopSessionMonitoring();
          _sessionInfo = null;
        }

        return OptimizedAuthState(
          user: user,
          isLoading: false,
          error: null,
          signInMetrics: _signInMetrics,
          sessionInfo: _sessionInfo,
        );
      },
      loading: () => const OptimizedAuthState(
        isLoading: true,
      ),
      error: (error, stackTrace) => OptimizedAuthState(
        isLoading: false,
        error: error.toString(),
        signInMetrics: _signInMetrics,
        sessionInfo: _sessionInfo,
      ),
    );
  }

  /// Enhanced sign-in with comprehensive metrics tracking
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_operationManager?.isOperationInProgress(OperationType.signIn) ?? false) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    _updateSignInMetrics(totalAttempts: (_signInMetrics?.totalAttempts ?? 0) + 1);

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final service = await ref.read(optimizedAuthProvider.future);

      final result = await _operationManager!.executeOperation(
        type: OperationType.signIn,
        operation: () => service.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

      stopwatch.stop();

      final credential = result.dataOrThrow;
      _updateSignInMetrics(
        successfulSignIns: (_signInMetrics?.successfulSignIns ?? 0) + 1,
        lastSignInTime: DateTime.now(),
        averageSignInTime: _calculateAverageSignInTime(stopwatch.elapsed),
      );

      state = state.copyWith(
        isLoading: false,
        lastOperationDuration: stopwatch.elapsed,
        signInMetrics: _signInMetrics,
      );

      debugPrint('[AuthNotifier] Sign in completed in ${stopwatch.elapsedMilliseconds}ms');

    } catch (e) {
      stopwatch.stop();

      _updateSignInMetrics(
        failureReasons: _updateFailureReasons(e.toString()),
      );

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastOperationDuration: stopwatch.elapsed,
        signInMetrics: _signInMetrics,
      );

      debugPrint('[AuthNotifier] Sign in failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  /// Enhanced sign-out with comprehensive cleanup
  Future<void> signOut() async {
    if (_operationManager?.isOperationInProgress(OperationType.signOut) ?? false) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final service = await ref.read(optimizedAuthProvider.future);

      await _operationManager!.executeOperation(
        type: OperationType.signOut,
        operation: () => service.signOut(),
      );

      stopwatch.stop();

      // Reset metrics on sign out
      _sessionInfo = null;
      _tokenRefreshCount = 0;

      state = state.copyWith(
        isLoading: false,
        lastOperationDuration: stopwatch.elapsed,
        sessionInfo: null,
      );

      debugPrint('[AuthNotifier] Sign out completed in ${stopwatch.elapsedMilliseconds}ms');

    } catch (e) {
      stopwatch.stop();

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastOperationDuration: stopwatch.elapsed,
      );

      debugPrint('[AuthNotifier] Sign out failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  /// Clear authentication error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Enhanced session monitoring with proper cleanup
  void _startSessionMonitoring(User user) {
    _stopSessionMonitoring(); // Ensure no duplicate timers

    _sessionMonitorTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateSessionInfo(user),
    );

    debugPrint('[AuthNotifier] Session monitoring started for user: ${user.uid}');
  }

  void _stopSessionMonitoring() {
    _sessionMonitorTimer?.cancel();
    _sessionMonitorTimer = null;
  }

  void _updateSessionInfo(User user) async {
    try {
      final service = await ref.read(optimizedAuthProvider.future);
      final isValid = await service.isTokenValid();

      final now = DateTime.now();
      final sessionStart = _sessionInfo?.sessionStart ?? now;

      _sessionInfo = SessionInfo(
        sessionStart: sessionStart,
        lastActivity: now,
        sessionDuration: now.difference(sessionStart),
        isSessionValid: isValid,
        tokenRefreshCount: _tokenRefreshCount,
      );

      // Update state with new session info
      if (state.mounted) {
        state = state.copyWith(sessionInfo: _sessionInfo);
      }

      // Handle session expiration
      if (!isValid) {
        debugPrint('[AuthNotifier] Session expired, signing out');
        await signOut();
      }

    } catch (e) {
      debugPrint('[AuthNotifier] Failed to update session info: $e');
    }
  }

  void _updateSignInMetrics({
    int? totalAttempts,
    int? successfulSignIns,
    Duration? averageSignInTime,
    DateTime? lastSignInTime,
    Map<String, int>? failureReasons,
  }) {
    final current = _signInMetrics;
    final total = totalAttempts ?? (current?.totalAttempts ?? 0);
    final successful = successfulSignIns ?? (current?.successfulSignIns ?? 0);
    final avgTime = averageSignInTime ?? (current?.averageSignInTime ?? Duration.zero);
    final lastTime = lastSignInTime ?? current?.lastSignInTime;
    final failures = failureReasons ?? (current?.failureReasons ?? {});
    final successRate = total > 0 ? successful / total : 0.0;

    _signInMetrics = SignInMetrics(
      totalAttempts: total,
      successfulSignIns: successful,
      averageSignInTime: avgTime,
      lastSignInTime: lastTime,
      successRate: successRate,
      failureReasons: failures,
    );
  }

  Duration _calculateAverageSignInTime(Duration newTime) {
    final current = _signInMetrics;
    final successful = current?.successfulSignIns ?? 0;

    if (successful == 0) return newTime;

    final currentAverage = current?.averageSignInTime ?? Duration.zero;
    final totalMilliseconds = currentAverage.inMilliseconds * successful + newTime.inMilliseconds;

    return Duration(milliseconds: totalMilliseconds ~/ (successful + 1));
  }

  Map<String, int> _updateFailureReasons(String error) {
    final current = _signInMetrics?.failureReasons ?? {};
    final reason = _categorizeError(error);

    final updated = Map<String, int>.from(current);
    updated[reason] = (updated[reason] ?? 0) + 1;

    return updated;
  }

  String _categorizeError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('password') || lowerError.contains('credential')) {
      return 'invalid_credentials';
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'network_error';
    } else if (lowerError.contains('rate') || lowerError.contains('too many')) {
      return 'rate_limit';
    } else if (lowerError.contains('disabled') || lowerError.contains('banned')) {
      return 'account_disabled';
    } else {
      return 'unknown_error';
    }
  }

  @override
  void dispose() {
    _stopSessionMonitoring();
    _operationManager?.dispose();
    super.dispose();
  }
}

/// Enhanced authentication status provider with additional metadata
@riverpod
class AuthenticationStatus extends _$AuthenticationStatus {
  @override
  AuthenticationStatusInfo build() {
    final authState = ref.watch(optimizedAuthNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);

    return AuthenticationStatusInfo(
      isAuthenticated: authState.isAuthenticated,
      isLoading: authState.isLoading,
      hasError: authState.error != null,
      userId: currentUser.value?.uid,
      email: currentUser.value?.email,
      isEmailVerified: currentUser.value?.emailVerified ?? false,
      creationTime: currentUser.value?.metadata.creationTime,
      lastSignInTime: currentUser.value?.metadata.lastSignInTime,
      provider: currentUser.value?.providerData.map((p) => p.providerId).toList(),
    );
  }
}

/// Enhanced authentication status information
@immutable
class AuthenticationStatusInfo {
  const AuthenticationStatusInfo({
    required this.isAuthenticated,
    required this.isLoading,
    required this.hasError,
    this.userId,
    this.email,
    this.isEmailVerified = false,
    this.creationTime,
    this.lastSignInTime,
    this.provider = const [],
  });

  final bool isAuthenticated;
  final bool isLoading;
  final bool hasError;
  final String? userId;
  final String? email;
  final bool isEmailVerified;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;
  final List<String> provider;

  bool get isFreshUser {
    if (creationTime == null || lastSignInTime == null) return false;
    return lastSignInTime!.difference(creationTime!).inMinutes < 5;
  }

  String? get primaryProvider {
    if (provider.isEmpty) return null;
    return provider.first;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticationStatusInfo &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading &&
          hasError == other.hasError &&
          userId == other.userId &&
          email == other.email &&
          isEmailVerified == other.isEmailVerified &&
          creationTime == other.creationTime &&
          lastSignInTime == other.lastSignInTime &&
          provider.length == other.provider.length;

  @override
  int get hashCode => Object.hash(
        isAuthenticated,
        isLoading,
        hasError,
        userId,
        email,
        isEmailVerified,
        creationTime,
        lastSignInTime,
        provider.length,
      );
}

/// Enhanced route guard provider with dynamic configuration
@riverpod
class RouteGuard extends _$RouteGuard {
  @override
  Map<String, bool> build() {
    final authStatus = ref.watch(authenticationStatusProvider);

    // Define protected routes with their requirements
    final protectedRoutes = <String, RouteRequirement>{
      '/profile': RouteRequirement(authenticated: true),
      '/settings': RouteRequirement(authenticated: true),
      '/jobs': RouteRequirement(authenticated: true),
      '/locals': RouteRequirement(authenticated: true),
      '/storm': RouteRequirement(authenticated: true),
      '/tools': RouteRequirement(authenticated: true),
      '/crews': RouteRequirement(authenticated: true),
      '/tailboard': RouteRequirement(authenticated: true),
    };

    final routeStatus = <String, bool>{};

    for (final entry in protectedRoutes.entries) {
      final route = entry.key;
      final requirement = entry.value;

      if (requirement.authenticated) {
        routeStatus[route] = authStatus.isAuthenticated;
      } else {
        routeStatus[route] = true; // Public routes are always accessible
      }
    }

    return routeStatus;
  }

  bool isRouteProtected(String routePath) {
    final routeStatus = state;
    return routeStatus.containsKey(routePath) && routeStatus[routePath] == false;
  }
}

/// Route requirements for enhanced access control
@immutable
class RouteRequirement {
  const RouteRequirement({
    this.authenticated = false,
    this.emailVerified = false,
    this.roles = const [],
  });

  final bool authenticated;
  final bool emailVerified;
  final List<String> roles;
}

/// Performance monitoring provider for authentication operations
@riverpod
class AuthPerformanceMonitor extends _$AuthPerformanceMonitor {
  @override
  AuthPerformanceMetrics build() {
    final authState = ref.watch(optimizedAuthNotifierProvider);

    return AuthPerformanceMetrics(
      averageSignInTime: authState.signInMetrics?.averageSignInTime ?? Duration.zero,
      successRate: authState.signInMetrics?.successRate ?? 0.0,
      totalAttempts: authState.signInMetrics?.totalAttempts ?? 0,
      sessionUptime: authState.sessionInfo?.sessionDuration ?? Duration.zero,
      tokenRefreshCount: authState.sessionInfo?.tokenRefreshCount ?? 0,
      lastOperationDuration: authState.lastOperationDuration ?? Duration.zero,
    );
  }
}

/// Enhanced performance metrics for authentication
@immutable
class AuthPerformanceMetrics {
  const AuthPerformanceMetrics({
    required this.averageSignInTime,
    required this.successRate,
    required this.totalAttempts,
    required this.sessionUptime,
    required this.tokenRefreshCount,
    required this.lastOperationDuration,
  });

  final Duration averageSignInTime;
  final double successRate;
  final int totalAttempts;
  final Duration sessionUptime;
  final int tokenRefreshCount;
  final Duration lastOperationDuration;

  bool get isPerformant =>
      averageSignInTime.inMilliseconds < 3000 && // Sign in under 3 seconds
      successRate > 0.8; // 80%+ success rate

  @override
  String toString() => 'AuthPerformanceMetrics('
      'avgSignInTime: ${averageSignInTime.inMilliseconds}ms, '
      'successRate: ${(successRate * 100).toStringAsFixed(1)}%, '
      'totalAttempts: $totalAttempts, '
      'sessionUptime: ${sessionUptime.inMinutes}min, '
      'tokenRefreshes: $tokenRefreshCount'
      ')';
}