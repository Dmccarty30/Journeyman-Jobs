// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_data_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offlineDataService)
const offlineDataServiceProvider = OfflineDataServiceProvider._();

final class OfflineDataServiceProvider
    extends
        $FunctionalProvider<
          OfflineDataService,
          OfflineDataService,
          OfflineDataService
        >
    with $Provider<OfflineDataService> {
  const OfflineDataServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineDataServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineDataServiceHash();

  @$internal
  @override
  $ProviderElement<OfflineDataService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OfflineDataService create(Ref ref) {
    return offlineDataService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineDataService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineDataService>(value),
    );
  }
}

String _$offlineDataServiceHash() =>
    r'7ff475bcff93f81de22c2da9e6db3608cdc8b47e';
