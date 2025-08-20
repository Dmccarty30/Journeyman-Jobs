// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityServiceHash() => r'7f61ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7i';

/// Connectivity service provider
///
/// Copied from [connectivityService].
@ProviderFor(connectivityService)
final connectivityServiceProvider = Provider<ConnectivityService>.internal(
  connectivityService,
  name: r'connectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ConnectivityServiceRef = ProviderRef<ConnectivityService>;
String _$notificationServiceHash() => r'6e50ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7j';

/// Notification service provider
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$analyticsServiceHash() => r'5d4fac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7k';

/// Analytics service provider
///
/// Copied from [analyticsService].
@ProviderFor(analyticsService)
final analyticsServiceProvider = Provider<AnalyticsService>.internal(
  analyticsService,
  name: r'analyticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalyticsServiceRef = ProviderRef<AnalyticsService>;
String _$connectivityStreamHash() => r'4c3eac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7l';

/// Connectivity state stream
///
/// Copied from [connectivityStream].
@ProviderFor(connectivityStream)
final connectivityStreamProvider = StreamProvider<bool>.internal(
  connectivityStream,
  name: r'connectivityStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ConnectivityStreamRef = StreamProviderRef<bool>;
String _$appStatusHash() => r'3b2dac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7m';

/// Combined app status provider
///
/// Copied from [appStatus].
@ProviderFor(appStatus)
final appStatusProvider = AutoDisposeProvider<Map<String, dynamic>>.internal(
  appStatus,
  name: r'appStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppStatusRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$allErrorsHash() => r'2a1cac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7n';

/// Error aggregation provider
///
/// Copied from [allErrors].
@ProviderFor(allErrors)
final allErrorsProvider = AutoDisposeProvider<List<String>>.internal(
  allErrors,
  name: r'allErrorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllErrorsRef = AutoDisposeProviderRef<List<String>>;
String _$isAnyLoadingHash() => r'190bac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7o';

/// Loading state aggregation provider
///
/// Copied from [isAnyLoading].
@ProviderFor(isAnyLoading)
final isAnyLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAnyLoading,
  name: r'isAnyLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAnyLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAnyLoadingRef = AutoDisposeProviderRef<bool>;
String _$appStateNotifierHash() => r'089aac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7p';

/// App state notifier
///
/// Copied from [AppStateNotifier].
@ProviderFor(AppStateNotifier)
final appStateNotifierProvider = NotifierProvider<AppStateNotifier, AppState>.internal(
  AppStateNotifier.new,
  name: r'appStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppStateNotifier = Notifier<AppState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member