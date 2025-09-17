import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/analytics_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/offline_data_service.dart';
import '../../services/local_notification_service.dart';
import 'auth_riverpod_provider.dart';
import 'jobs_riverpod_provider.dart';
import 'locals_riverpod_provider.dart';

part 'app_state_riverpod_provider.g.dart';

/// Global app state model
class AppState {
  const AppState({
    this.isConnected = true,
    this.isInitialized = false,
    this.globalError,
    this.performanceMetrics = const <String, dynamic>{},
  });
  final bool isConnected;
  final bool isInitialized;
  final String? globalError;
  final Map<String, dynamic> performanceMetrics;

  AppState copyWith({
    bool? isConnected,
    bool? isInitialized,
    String? globalError,
    Map<String, dynamic>? performanceMetrics,
  }) =>
      AppState(
        isConnected: isConnected ?? this.isConnected,
        isInitialized: isInitialized ?? this.isInitialized,
        globalError: globalError ?? this.globalError,
        performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      );

  AppState clearError() => copyWith();
}

/// Connectivity service provider
@Riverpod()
ConnectivityService connectivityService(ConnectivityServiceRef ref) =>
    ConnectivityService();

final offlineDataServiceProvider = Provider<OfflineDataService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = OfflineDataService(connectivity);
  // Initialize in background; do not await to keep provider synchronous.
  unawaited(service.initialize());
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Notification service adapter (wraps local notification initialization)
class NotificationServiceAdapter {
  Future<void> initialize() async {
    await LocalNotificationService.initialize();
  }
}

@Riverpod()
NotificationServiceAdapter notificationService(NotificationServiceRef ref) =>
    NotificationServiceAdapter();

/// Analytics service adapter wrapping static analytics helpers
class AnalyticsServiceAdapter {
  Future<void> initialize() async {
    // AnalyticsService uses static helper methods; keep a no-op initializer
    // in case future setup is required.
    return;
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) =>
      AnalyticsService.instance.trackAppEvent(
          eventName: eventName, parameters: parameters ?? <String, dynamic>{});
}

@Riverpod()
AnalyticsServiceAdapter analyticsService(AnalyticsServiceRef ref) =>
    AnalyticsServiceAdapter();

/// Connectivity state stream
@Riverpod()
Stream<bool> connectivityStream(ConnectivityStreamRef ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);

  // Create a controller that emits the current connection state and updates
  // whenever the ConnectivityService notifies listeners.
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  // Emit the initial state
  controller.add(connectivityService.isOnline);

  // Listener forwards changes from the ChangeNotifier to the stream
  void listener() {
    if (!controller.isClosed) {
      controller.add(connectivityService.isOnline);
    }
  }

  connectivityService.addListener(listener);

  // Clean up when the provider is disposed
  ref.onDispose(() {
    connectivityService.removeListener(listener);
    controller.close();
  });

  return controller.stream;
}

/// App state notifier
@Riverpod()
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    // Listen to connectivity changes
    ref.listen(connectivityStreamProvider,
        (AsyncValue<bool>? previous, AsyncValue<bool> next) {
      next.when(
        data: (bool isConnected) {
          state = state.copyWith(isConnected: isConnected);

          // Track connectivity events
          AnalyticsService.instance.trackAppEvent(
            eventName: 'connectivity_changed',
            parameters: <String, dynamic>{'is_connected': isConnected},
          );
        },
        loading: () {},
        error: (Object error, StackTrace stackTrace) {
          state = state.copyWith(globalError: 'Connectivity error: $error');
        },
      );
    });

    _initializeApp();
    return const AppState();
  }

  /// Initialize the application
  Future<void> _initializeApp() async {
    try {
      // Initialize services
      await Future.wait<void>(<Future<void>>[
        ref.read(notificationServiceProvider).initialize(),
      ]);

      // Load initial data if user is authenticated
      final bool isAuthenticated = ref.read(isAuthenticatedProvider);
      if (isAuthenticated) {
        await _loadInitialData();
      }

      state = state.copyWith(isInitialized: true);

      // Track app initialization
      AnalyticsService.instance.trackAppEvent(
          eventName: 'app_initialized', parameters: <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(
        globalError: 'Failed to initialize app: $e',
        isInitialized:
            true, // Still mark as initialized to prevent infinite loading
      );
    }
  }

  /// Load initial data for authenticated users
  Future<void> _loadInitialData() async {
    try {
      await Future.wait(<Future<void>>[
        ref.read(jobsNotifierProvider.notifier).loadJobs(),
        ref.read(localsProvider.notifier).loadLocals(),
      ]);
    } catch (e) {
      // Don't set global error for data loading failures
      // Individual providers will handle their own errors
    }
  }

  /// Refresh all data
  Future<void> refreshAppData() async {
    try {
      final bool isAuthenticated = ref.read(isAuthenticatedProvider);

      if (isAuthenticated) {
        await Future.wait<void>(<Future<void>>[
          ref.read(jobsNotifierProvider.notifier).refreshJobs(),
          ref.read(localsProvider.notifier).loadLocals(forceRefresh: true),
        ]);
      }

      // Update performance metrics
      final Map<String, Object> performanceMetrics = <String, Object>{
        'last_refresh': DateTime.now().toIso8601String(),
        'jobs_metrics':
            ref.read(jobsNotifierProvider.notifier).getPerformanceMetrics(),
      };

      state = state.copyWith(performanceMetrics: performanceMetrics);

      // Track refresh event
      AnalyticsService.instance.trackAppEvent(
          eventName: 'app_data_refreshed', parameters: <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(globalError: 'Failed to refresh data: $e');
      rethrow;
    }
  }

  /// Handle user sign in
  Future<void> handleUserSignIn() async {
    try {
      await _loadInitialData();

      // Track sign in event
      AnalyticsService.instance.trackAppEvent(
          eventName: 'user_signed_in', parameters: <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(globalError: 'Failed to load user data: $e');
    }
  }

  /// Handle user sign out
  Future<void> handleUserSignOut() async {
    try {
      // Clear all provider states
      ref.invalidate(jobsNotifierProvider);
      ref.invalidate(localsProvider);

      // Track sign out event
      AnalyticsService.instance.trackAppEvent(
          eventName: 'user_signed_out', parameters: <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(globalError: 'Error during sign out: $e');
    }
  }

  /// Clear global error
  void clearError() {
    state = state.clearError();
  }

  /// Update performance metrics
  void updatePerformanceMetrics(Map<String, dynamic> metrics) {
    final Map<String, dynamic> updatedMetrics =
        Map<String, dynamic>.from(state.performanceMetrics)..addAll(metrics);
    state = state.copyWith(performanceMetrics: updatedMetrics);
  }
}

/// Combined app status provider
@Riverpod()
Map<String, dynamic> appStatus(AppStatusRef ref) {
  final appState = ref.watch(appStateNotifierProvider);
  final authState = ref.watch(authNotifierProvider);
  final jobsState = ref.watch(jobsNotifierProvider);
  final localsState = ref.watch(localsProvider);

  return <String, dynamic>{
    'isInitialized': appState.isInitialized,
    'isConnected': appState.isConnected,
    'isAuthenticated': authState.isAuthenticated,
    'hasGlobalError': appState.globalError != null,
    'isLoadingJobs': jobsState.isLoading,
    'isLoadingLocals': localsState.isLoading,
    'isLoadingAuth': authState.isLoading,
    'jobsCount': jobsState.jobs.length,
    'localsCount': localsState.locals.length,
    'performanceMetrics': appState.performanceMetrics,
  };
}

/// Error aggregation provider
@Riverpod()
List<String> allErrors(AllErrorsRef ref) {
  final List<String> errors = <String>[];

  final appState = ref.watch(appStateNotifierProvider);
  final authState = ref.watch(authNotifierProvider);
  final jobsState = ref.watch(jobsNotifierProvider);
  final localsState = ref.watch(localsProvider);

  if (appState.globalError != null) {
    errors.add('App: ${appState.globalError}');
  }
  if (authState.error != null) {
    errors.add('Auth: ${authState.error}');
  }
  if (jobsState.error != null) {
    errors.add('Jobs: ${jobsState.error}');
  }
  if (localsState.error != null) {
    errors.add('Locals: ${localsState.error}');
  }

  return errors;
}

/// Loading state aggregation provider
@Riverpod()
bool isAnyLoading(IsAnyLoadingRef ref) {
  final appState = ref.watch(appStateNotifierProvider);
  final authState = ref.watch(authNotifierProvider);
  final jobsState = ref.watch(jobsNotifierProvider);
  final localsState = ref.watch(localsProvider);

  return !appState.isInitialized ||
      authState.isLoading ||
      jobsState.isLoading ||
      localsState.isLoading;
}
