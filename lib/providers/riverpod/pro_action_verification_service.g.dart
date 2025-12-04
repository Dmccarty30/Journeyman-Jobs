// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_action_verification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(proActionVerificationService)
const proActionVerificationServiceProvider =
    ProActionVerificationServiceProvider._();

final class ProActionVerificationServiceProvider extends $FunctionalProvider<
    ProActionVerificationService,
    ProActionVerificationService,
    ProActionVerificationService> with $Provider<ProActionVerificationService> {
  const ProActionVerificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'proActionVerificationServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$proActionVerificationServiceHash();

  @$internal
  @override
  $ProviderElement<ProActionVerificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProActionVerificationService create(Ref ref) {
    return proActionVerificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProActionVerificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProActionVerificationService>(value),
    );
  }
}

String _$proActionVerificationServiceHash() =>
    r'a412631f47c7540c1e4fc247a8b47bfa009ad7d0';
