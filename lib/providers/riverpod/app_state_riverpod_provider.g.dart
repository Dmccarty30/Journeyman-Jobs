// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityServiceHash() =>
    r'677485e07ca6fa8073f9617c75776c018263e026';

/// Connectivity service provider
///
/// Copied from [connectivityService].
@ProviderFor(connectivityService)
final connectivityServiceProvider =
    AutoDisposeProvider<ConnectivityService>.internal(
  connectivityService,
  name: r'connectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityServiceRef = AutoDisposeProviderRef<ConnectivityService>;
String _$notificationServiceHash() =>
    r'7a12f8dfd99c00e00ecdc934505845fe28698b1c';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider =
    AutoDisposeProvider<NotificationServiceAdapter>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef
    = AutoDisposeProviderRef<NotificationServiceAdapter>;
String _$analyticsServiceHash() => r'dbfd5f7e297d796707b3a6af30cf2d0028f81961';

/// See also [analyticsService].
@ProviderFor(analyticsService)
final analyticsServiceProvider =
    AutoDisposeProvider<AnalyticsServiceAdapter>.internal(
  analyticsService,
  name: r'analyticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsServiceRef = AutoDisposeProviderRef<AnalyticsServiceAdapter>;
String _$connectivityStreamHash() =>
    r'1a0eab65059dfe3bf1fcfc224841e1869cd933d7';

/// Connectivity state stream
///
/// Copied from [connectivityStream].
@ProviderFor(connectivityStream)
final connectivityStreamProvider = AutoDisposeStreamProvider<bool>.internal(
  connectivityStream,
  name: r'connectivityStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStreamRef = AutoDisposeStreamProviderRef<bool>;
String _$appStatusHash() => r'2e22fe27e9f782a583c2783fe8da780b44287e30';

/// Combined app status provider
///
/// Copied from [appStatus].
@ProviderFor(appStatus)
final appStatusProvider = AutoDisposeProvider<Map<String, dynamic>>.internal(
  appStatus,
  name: r'appStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppStatusRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$allErrorsHash() => r'ee3b5e282c8832fa8ae4d1236b20beeddc5335c2';

/// Error aggregation provider
///
/// Copied from [allErrors].
@ProviderFor(allErrors)
final allErrorsProvider = AutoDisposeProvider<List<String>>.internal(
  allErrors,
  name: r'allErrorsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllErrorsRef = AutoDisposeProviderRef<List<String>>;
String _$isAnyLoadingHash() => r'75a001ebb3183d10d1e98ce2e26c074572445613';

/// Loading state aggregation provider
///
/// Copied from [isAnyLoading].
@ProviderFor(isAnyLoading)
final isAnyLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAnyLoading,
  name: r'isAnyLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isAnyLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAnyLoadingRef = AutoDisposeProviderRef<bool>;
String _$appStateNotifierHash() => r'3298fc1cdba3bceea07370249832197fbd6e0236';

/// App state notifier
///
/// Copied from [AppStateNotifier].
@ProviderFor(AppStateNotifier)
final appStateNotifierProvider =
    AutoDisposeNotifierProvider<AppStateNotifier, AppState>.internal(
  AppStateNotifier.new,
  name: r'appStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppStateNotifier = AutoDisposeNotifier<AppState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
