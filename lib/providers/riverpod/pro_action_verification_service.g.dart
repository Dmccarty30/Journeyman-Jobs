// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_action_verification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(proActionVerificationService)
final proActionVerificationServiceProvider =
    ProActionVerificationServiceProvider._();

final class ProActionVerificationServiceProvider extends $FunctionalProvider<
    ProActionVerificationService,
    ProActionVerificationService,
    ProActionVerificationService> with $Provider<ProActionVerificationService> {
  ProActionVerificationServiceProvider._()
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
    r'2586ad35bb4f389e4dbe09d80e7a967e303e450b';
