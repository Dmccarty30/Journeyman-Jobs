// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locals_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localByIdHash() => r'6e50ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7i';

/// Auto-dispose provider for local by ID
///
/// Copied from [localById].
@ProviderFor(localById)
final localByIdProvider = AutoDisposeFutureProviderFamily<LocalsRecord?, String>.internal(
  localById,
  name: r'localByIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localByIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocalByIdRef = AutoDisposeFutureProviderRef<LocalsRecord?>;
String _$localsByStateHash() => r'5d4fac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7j';

/// Auto-dispose provider for locals by state
///
/// Copied from [localsByState].
@ProviderFor(localsByState)
final localsByStateProvider = AutoDisposeProviderFamily<List<LocalsRecord>, String>.internal(
  localsByState,
  name: r'localsByStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localsByStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocalsByStateRef = AutoDisposeProviderRef<List<LocalsRecord>>;
String _$localsByClassificationHash() => r'4c3eac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7k';

/// Auto-dispose provider for locals by classification
///
/// Copied from [localsByClassification].
@ProviderFor(localsByClassification)
final localsByClassificationProvider = AutoDisposeProviderFamily<List<LocalsRecord>, String>.internal(
  localsByClassification,
  name: r'localsByClassificationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localsByClassificationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocalsByClassificationRef = AutoDisposeProviderRef<List<LocalsRecord>>;
String _$searchedLocalsHash() => r'3b2dac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7l';

/// Auto-dispose provider for searching locals
///
/// Copied from [searchedLocals].
@ProviderFor(searchedLocals)
final searchedLocalsProvider = AutoDisposeProviderFamily<List<LocalsRecord>, String>.internal(
  searchedLocals,
  name: r'searchedLocalsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchedLocalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SearchedLocalsRef = AutoDisposeProviderRef<List<LocalsRecord>>;
String _$allStatesHash() => r'2a1cac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7m';

/// Provider for all unique states
///
/// Copied from [allStates].
@ProviderFor(allStates)
final allStatesProvider = AutoDisposeProvider<List<String>>.internal(
  allStates,
  name: r'allStatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allStatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllStatesRef = AutoDisposeProviderRef<List<String>>;
String _$allClassificationsHash() => r'190bac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7n';

/// Provider for all unique classifications
///
/// Copied from [allClassifications].
@ProviderFor(allClassifications)
final allClassificationsProvider = AutoDisposeProvider<List<String>>.internal(
  allClassifications,
  name: r'allClassificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allClassificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllClassificationsRef = AutoDisposeProviderRef<List<String>>;
String _$localsNotifierHash() => r'089aac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7o';

/// Locals notifier for managing union local data
///
/// Copied from [LocalsNotifier].
@ProviderFor(LocalsNotifier)
final localsNotifierProvider = NotifierProvider<LocalsNotifier, LocalsState>.internal(
  LocalsNotifier.new,
  name: r'localsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocalsNotifier = Notifier<LocalsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member