// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storm_contractor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stormContractorRepositoryHash() =>
    r'efe1fec1ccd87534f9fc211f6d6bf30bde9a78f5';

/// Storm contractor repository provider
///
/// Copied from [stormContractorRepository].
@ProviderFor(stormContractorRepository)
final stormContractorRepositoryProvider =
    AutoDisposeProvider<StormContractorRepository>.internal(
  stormContractorRepository,
  name: r'stormContractorRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stormContractorRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StormContractorRepositoryRef
    = AutoDisposeProviderRef<StormContractorRepository>;
String _$stormContractorsStreamHash() =>
    r'410b8da262c13029a42bd5b9aa399e6f4a4c265c';

/// Storm contractors stream provider
///
/// Copied from [stormContractorsStream].
@ProviderFor(stormContractorsStream)
final stormContractorsStreamProvider =
    AutoDisposeStreamProvider<List<StormContractor>>.internal(
  stormContractorsStream,
  name: r'stormContractorsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stormContractorsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StormContractorsStreamRef
    = AutoDisposeStreamProviderRef<List<StormContractor>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
