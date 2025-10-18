// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Connectivity service provider

@ProviderFor(connectivityService)
const connectivityServiceProvider = ConnectivityServiceProvider._();

/// Connectivity service provider

final class ConnectivityServiceProvider
    extends
        $FunctionalProvider<
          ConnectivityService,
          ConnectivityService,
          ConnectivityService
        >
    with $Provider<ConnectivityService> {
  /// Connectivity service provider
  const ConnectivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'fe947b36f73c7e039fb04b7b9dd605f6ed10e715';

@ProviderFor(notificationService)
const notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationServiceAdapter,
          NotificationServiceAdapter,
          NotificationServiceAdapter
        >
    with $Provider<NotificationServiceAdapter> {
  const NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationServiceAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationServiceAdapter create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationServiceAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationServiceAdapter>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'fb3c063b7fdea39af2e2b78234bad97723ce172e';

@ProviderFor(analyticsService)
const analyticsServiceProvider = AnalyticsServiceProvider._();

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsServiceAdapter,
          AnalyticsServiceAdapter,
          AnalyticsServiceAdapter
        >
    with $Provider<AnalyticsServiceAdapter> {
  const AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsServiceAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalyticsServiceAdapter create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsServiceAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsServiceAdapter>(value),
    );
  }
}

String _$analyticsServiceHash() => r'4ccdc6ead800c7ff2969519a91583607d65cc34e';

/// Connectivity state stream

@ProviderFor(connectivityStream)
const connectivityStreamProvider = ConnectivityStreamProvider._();

/// Connectivity state stream

final class ConnectivityStreamProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Connectivity state stream
  const ConnectivityStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStreamHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return connectivityStream(ref);
  }
}

String _$connectivityStreamHash() =>
    r'9a74892d7b82b588c7d9005b074e4b24858e44ef';

/// App state notifier

@ProviderFor(AppStateNotifier)
const appStateProvider = AppStateNotifierProvider._();

/// App state notifier
final class AppStateNotifierProvider
    extends $NotifierProvider<AppStateNotifier, AppState> {
  /// App state notifier
  const AppStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStateNotifierHash();

  @$internal
  @override
  AppStateNotifier create() => AppStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppState>(value),
    );
  }
}

String _$appStateNotifierHash() => r'b12551d308751c520dc8454291ea70950b5d9951';

/// App state notifier

abstract class _$AppStateNotifier extends $Notifier<AppState> {
  AppState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppState, AppState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppState, AppState>,
              AppState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Combined app status provider

@ProviderFor(appStatus)
const appStatusProvider = AppStatusProvider._();

/// Combined app status provider

final class AppStatusProvider
    extends
        $FunctionalProvider<
          Map<String, dynamic>,
          Map<String, dynamic>,
          Map<String, dynamic>
        >
    with $Provider<Map<String, dynamic>> {
  /// Combined app status provider
  const AppStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStatusHash();

  @$internal
  @override
  $ProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, dynamic> create(Ref ref) {
    return appStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$appStatusHash() => r'2b8a98e1ff7821ac751a47031119ccddc53921bb';

/// Error aggregation provider

@ProviderFor(allErrors)
const allErrorsProvider = AllErrorsProvider._();

/// Error aggregation provider

final class AllErrorsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Error aggregation provider
  const AllErrorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allErrorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allErrorsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return allErrors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$allErrorsHash() => r'db33f9c461727381281fcefbe4d0f919206db04d';

/// Loading state aggregation provider

@ProviderFor(isAnyLoading)
const isAnyLoadingProvider = IsAnyLoadingProvider._();

/// Loading state aggregation provider

final class IsAnyLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Loading state aggregation provider
  const IsAnyLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAnyLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAnyLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAnyLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAnyLoadingHash() => r'09c518b3c185e6a1331db32d987280ad5ee3b5b7';
