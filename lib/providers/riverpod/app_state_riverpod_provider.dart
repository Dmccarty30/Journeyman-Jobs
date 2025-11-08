import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/analytics_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/offline_data_service.dart';
import '../../services/local_notification_service.dart';
import '../../utils/error_handler.dart';
import 'auth_riverpod_provider.dart';
import 'jobs_riverpod_provider.dart';
import 'locals_riverpod_provider.dart';

part 'app_state_riverpod_provider.g.dart';

/// Global app state model
class AppState {
  static const Object _sentinel = Object();

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
    Object? globalError = _sentinel,
    Map<String, dynamic>? performanceMetrics,
  }) =>
      AppState(
        isConnected: isConnected ?? this.isConnected,
        isInitialized: isInitialized ?? this.isInitialized,
        globalError:
            globalError == _sentinel ? this.globalError : globalError as String?,
        performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      );

  AppState clearError() => copyWith(globalError: null);
}

/// Connectivity service provider
@riverpod
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

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

@riverpod
NotificationServiceAdapter notificationService(Ref ref) => NotificationServiceAdapter();

/// Analytics service adapter wrapping static analytics helpers
class AnalyticsServiceAdapter {
  Future<void> initialize() async {
    // AnalyticsService uses static helper methods; keep a no-op initializer
    // in case future setup is required.
    return;
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) => AnalyticsService.logCustomEvent(eventName, parameters ?? <String, dynamic>{});

  Future<Map<String, dynamic>> getPerformanceMetrics() => AnalyticsService.getPerformanceMetrics();
}

@riverpod
AnalyticsServiceAdapter analyticsService(Ref ref) => AnalyticsServiceAdapter();

/// Connectivity state stream
@riverpod
Stream<bool> connectivityStream(Ref ref) {
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
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    // Initialize app asynchronously (not blocking build). This is called once.
    _initializeApp();

    // Listen for connectivity changes to update state reactively.
    ref.listen(connectivityStreamProvider,
        (AsyncValue<bool>? previous, AsyncValue<bool> next) {
      if (next.hasError && !next.isRefreshing) {
        state = state.copyWith(globalError: 'Connectivity error: ${next.error}');
        return;
      }

      if (next.hasValue) {
        final bool isConnected = next.value!;
        state = state.copyWith(isConnected: isConnected);

        // Only log if connectivity actually changed.
        if (previous != null && previous.hasValue) {
          final previousConnected = previous.value;
          if (previousConnected != isConnected) {
            AnalyticsService.logCustomEvent(
              'connectivity_changed',
              <String, dynamic>{'is_connected': isConnected},
            );
          }
        }
      }
    });

    // Return initial state. Connectivity will be updated by the listener,
    // and isInitialized will be updated by _initializeApp.
    final bool initialIsConnected = ref.read(connectivityServiceProvider).isOnline;
    return AppState(isConnected: initialIsConnected);
  }

  /// Initialize the application
  Future<void> _initializeApp() async {
    // Guard against multiple initializations.
    if (state.isInitialized) return;

    final success = await ErrorHandler.handleAsyncOperation<bool>(
      () async {
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
        AnalyticsService.logCustomEvent('app_initialized', <String, dynamic>{});
        
        return true; // Return success indicator
      },
      operationName: 'initializeApp',
      errorMessage: 'Failed to initialize app',
      showToast: false,
      context: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (success == null) {
      // Error already handled by ErrorHandler
      state = state.copyWith(
        globalError: 'Failed to initialize app',
        isInitialized: true, // Still mark as initialized to prevent infinite loading
      );
    }
  }

  /// Load initial data for authenticated users
  Future<void> _loadInitialData() async {
    try {
      await Future.wait(<Future<void>>[
        ref.read(jobsProvider.notifier).loadJobs(),
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
          ref.read(jobsProvider.notifier).refreshJobs(),
          ref.read(localsProvider.notifier).loadLocals(forceRefresh: true),
        ]);
      }

      // Update performance metrics
      final Map<String, Object> performanceMetrics = <String, Object>{
        'last_refresh': DateTime.now().toIso8601String(),
        'jobs_metrics': ref.read(jobsProvider.notifier).getPerformanceMetrics(),
      };

      state = state.copyWith(performanceMetrics: performanceMetrics);
      
      // Track refresh event
      AnalyticsService.logCustomEvent('app_data_refreshed', <String, dynamic>{});
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
      AnalyticsService.logCustomEvent('user_signed_in', <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(globalError: 'Failed to load user data: $e');
    }
  }

  /// Handle user sign out
  Future<void> handleUserSignOut() async {
    try {
      // Clear all provider states
      ref.invalidate(jobsProvider);
      ref.invalidate(localsProvider);
      
      // Track sign out event
      AnalyticsService.logCustomEvent('user_signed_out', <String, dynamic>{});
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
    final Map<String, dynamic> updatedMetrics = Map<String, dynamic>.from(state.performanceMetrics)
      ..addAll(metrics);
    state = state.copyWith(performanceMetrics: updatedMetrics);
  }
}

/// Combined app status provider
@riverpod
Map<String, dynamic> appStatus(Ref ref) {
  final appState = ref.watch(appStateProvider);
  final authState = ref.watch(authProvider);
  final jobsState = ref.watch(jobsProvider);
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
@riverpod
List<String> allErrors(Ref ref) {
  final List<String> errors = <String>[];
  
  final appState = ref.watch(appStateProvider);
  final authState = ref.watch(authProvider);
  final jobsState = ref.watch(jobsProvider);
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
@riverpod
bool isAnyLoading(Ref ref) {
  final appState = ref.watch(appStateProvider);
  final authState = ref.watch(authProvider);
  final jobsState = ref.watch(jobsProvider);
  final localsState = ref.watch(localsProvider);

  return !appState.isInitialized ||
         authState.isLoading ||
         jobsState.isLoading ||
         localsState.isLoading;
}
