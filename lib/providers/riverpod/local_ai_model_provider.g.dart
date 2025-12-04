// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_ai_model_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localModelService)
const localModelServiceProvider = LocalModelServiceProvider._();

final class LocalModelServiceProvider extends $FunctionalProvider<
    LocalModelService,
    LocalModelService,
    LocalModelService> with $Provider<LocalModelService> {
  const LocalModelServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localModelServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localModelServiceHash();

  @$internal
  @override
  $ProviderElement<LocalModelService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalModelService create(Ref ref) {
    return localModelService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalModelService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalModelService>(value),
    );
  }
}

String _$localModelServiceHash() => r'5990a5d853897d7c8ccf32a269bfdf970b7defb4';

@ProviderFor(modelInitializer)
const modelInitializerProvider = ModelInitializerProvider._();

final class ModelInitializerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const ModelInitializerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'modelInitializerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$modelInitializerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return modelInitializer(ref);
  }
}

String _$modelInitializerHash() => r'f442dd7a5b2fde2c5b9c25cedc1253db6aa814dc';
