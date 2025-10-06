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

/// Represents the global state of the application.
///
/// This immutable class holds high-level state information such as connectivity status,
/// initialization status, global errors, and performance metrics.
class AppState {

  /// Creates an instance of the application's global state.
  const AppState({
    this.isConnected = true,
    this.isInitialized = false,
    this.globalError,
    this.performanceMetrics = const <String, dynamic>{},
  });
  /// `true` if the device has an active network connection.
  final bool isConnected;
  /// `true` if the app has completed its initial setup.
  final bool isInitialized;
  /// A global error message, if any, to be displayed to the user.
  final String? globalError;
  /// A map of performance metrics collected during the app's lifecycle.
  final Map<String, dynamic> performanceMetrics;

  /// Creates a new [AppState] instance with updated field values.
  AppState copyWith({
    bool? isConnected,
    bool? isInitialized,
    String? globalError,
    Map<String, dynamic>? performanceMetrics,
  }) => AppState(
      isConnected: isConnected ?? this.isConnected,
      isInitialized: isInitialized ?? this.isInitialized,
      globalError: globalError ?? this.globalError,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );

  /// Returns a new [AppState] instance with the `globalError` field cleared.
  AppState clearError() => copyWith(globalError: null);
}

/// Provides an app-wide instance of [ConnectivityService].
@riverpod
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

/// Provides an app-wide instance of [OfflineDataService].
///
/// This provider initializes the service in the background and manages its lifecycle.
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

/// An adapter class that wraps the static [LocalNotificationService] for easier
/// integration with Riverpod's dependency injection system.
class NotificationServiceAdapter {
  /// Initializes the underlying [LocalNotificationService].
  Future<void> initialize() async {
    await LocalNotificationService.initialize();
  }
}

/// Provides an instance of [NotificationServiceAdapter].
@riverpod
NotificationServiceAdapter notificationService(Ref ref) => NotificationServiceAdapter();

/// An adapter class that wraps the static methods of [AnalyticsService].
///
/// This allows for a more consistent provider-based architecture and easier testing.
class AnalyticsServiceAdapter {
  /// A placeholder for initialization logic if ever needed.
  Future<void> initialize() async {
    // AnalyticsService uses static helper methods; keep a no-op initializer
    // in case future setup is required.
    return;
  }

  /// Logs a custom analytics event.
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) => AnalyticsService.logCustomEvent(eventName, parameters ?? <String, dynamic>{});

  /// Fetches performance metrics from the analytics service.
  Future<Map<String, dynamic>> getPerformanceMetrics() => AnalyticsService.getPerformanceMetrics();
}

/// Provides an instance of [AnalyticsServiceAdapter].
@riverpod
AnalyticsServiceAdapter analyticsService(Ref ref) => AnalyticsServiceAdapter();

/// Provides a stream of the device's connectivity status.
///
/// It listens to the [ConnectivityService] `ChangeNotifier` and exposes its
/// `isOnline` status as a boolean stream.
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

/// The main state notifier for the application's global [AppState].
///
/// This notifier manages the app's initialization process, listens to connectivity
/// changes, and orchestrates high-level data loading and state transitions
/// such as sign-in, sign-out, and data refreshes.
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    // Listen to connectivity changes
    ref.listen(connectivityStreamProvider, (AsyncValue<bool>? previous, AsyncValue<bool> next) {
      next.when(
        data: (bool isConnected) {
          state = state.copyWith(isConnected: isConnected);
          
          // Track connectivity events
          AnalyticsService.logCustomEvent(
            'connectivity_changed',
            <String, dynamic>{'is_connected': isConnected},
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

  /// Kicks off the asynchronous initialization of the application.
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
      AnalyticsService.logCustomEvent('app_initialized', <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(
        globalError: 'Failed to initialize app: $e',
        isInitialized: true, // Still mark as initialized to prevent infinite loading
      );
    }
  }

  /// Loads the essential initial data required for an authenticated user session.
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

  /// Triggers a full refresh of all application data.
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

  /// Handles the necessary state updates and data loading after a user signs in.
  Future<void> handleUserSignIn() async {
    try {
      await _loadInitialData();
      
      // Track sign in event
      AnalyticsService.logCustomEvent('user_signed_in', <String, dynamic>{});
    } catch (e) {
      state = state.copyWith(globalError: 'Failed to load user data: $e');
    }
  }

  /// Handles the necessary state cleanup after a user signs out.
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

  /// Clears any global error message from the application state.
  void clearError() {
    state = state.clearError();
  }

  /// Updates the performance metrics in the application state.
  void updatePerformanceMetrics(Map<String, dynamic> metrics) {
    final Map<String, dynamic> updatedMetrics = Map<String, dynamic>.from(state.performanceMetrics)
      ..addAll(metrics);
    state = state.copyWith(performanceMetrics: updatedMetrics);
  }
}

/// A provider that combines various states into a single, convenient status map.
///
/// This is useful for quickly checking the overall status of the app from the UI,
/// for example, to show a global loading indicator or an error banner.
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

/// A provider that aggregates all current error messages from different parts
/// of the application state into a single list.
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

/// A provider that aggregates the loading status from various providers
/// into a single boolean value.
///
/// Returns `true` if any major part of the app is currently in a loading state.
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
