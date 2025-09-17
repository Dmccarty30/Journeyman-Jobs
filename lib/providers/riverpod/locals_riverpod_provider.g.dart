// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locals_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localByIdHash() => r'5ede38d2f3227af0e8f46fe2c44f963c95c0b105';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Riverpod provider that fetches a single local by ID.
///
/// Copied from [localById].
@ProviderFor(localById)
const localByIdProvider = LocalByIdFamily();

/// Riverpod provider that fetches a single local by ID.
///
/// Copied from [localById].
class LocalByIdFamily extends Family<AsyncValue<LocalsRecord?>> {
  /// Riverpod provider that fetches a single local by ID.
  ///
  /// Copied from [localById].
  const LocalByIdFamily();

  /// Riverpod provider that fetches a single local by ID.
  ///
  /// Copied from [localById].
  LocalByIdProvider call(
    String localId,
  ) {
    return LocalByIdProvider(
      localId,
    );
  }

  @override
  LocalByIdProvider getProviderOverride(
    covariant LocalByIdProvider provider,
  ) {
    return call(
      provider.localId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'localByIdProvider';
}

/// Riverpod provider that fetches a single local by ID.
///
/// Copied from [localById].
class LocalByIdProvider extends AutoDisposeFutureProvider<LocalsRecord?> {
  /// Riverpod provider that fetches a single local by ID.
  ///
  /// Copied from [localById].
  LocalByIdProvider(
    String localId,
  ) : this._internal(
          (ref) => localById(
            ref as LocalByIdRef,
            localId,
          ),
          from: localByIdProvider,
          name: r'localByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localByIdHash,
          dependencies: LocalByIdFamily._dependencies,
          allTransitiveDependencies: LocalByIdFamily._allTransitiveDependencies,
          localId: localId,
        );

  LocalByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.localId,
  }) : super.internal();

  final String localId;

  @override
  Override overrideWith(
    FutureOr<LocalsRecord?> Function(LocalByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalByIdProvider._internal(
        (ref) => create(ref as LocalByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        localId: localId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<LocalsRecord?> createElement() {
    return _LocalByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalByIdProvider && other.localId == localId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, localId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocalByIdRef on AutoDisposeFutureProviderRef<LocalsRecord?> {
  /// The parameter `localId` of this provider.
  String get localId;
}

class _LocalByIdProviderElement
    extends AutoDisposeFutureProviderElement<LocalsRecord?> with LocalByIdRef {
  _LocalByIdProviderElement(super.provider);

  @override
  String get localId => (origin as LocalByIdProvider).localId;
}

String _$localsByStateHash() => r'06e4b36157a6b42fbdb569c789875911afd0f856';

/// Riverpod provider that returns locals filtered by state.
///
/// Copied from [localsByState].
@ProviderFor(localsByState)
const localsByStateProvider = LocalsByStateFamily();

/// Riverpod provider that returns locals filtered by state.
///
/// Copied from [localsByState].
class LocalsByStateFamily extends Family<List<LocalsRecord>> {
  /// Riverpod provider that returns locals filtered by state.
  ///
  /// Copied from [localsByState].
  const LocalsByStateFamily();

  /// Riverpod provider that returns locals filtered by state.
  ///
  /// Copied from [localsByState].
  LocalsByStateProvider call(
    String stateName,
  ) {
    return LocalsByStateProvider(
      stateName,
    );
  }

  @override
  LocalsByStateProvider getProviderOverride(
    covariant LocalsByStateProvider provider,
  ) {
    return call(
      provider.stateName,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'localsByStateProvider';
}

/// Riverpod provider that returns locals filtered by state.
///
/// Copied from [localsByState].
class LocalsByStateProvider extends AutoDisposeProvider<List<LocalsRecord>> {
  /// Riverpod provider that returns locals filtered by state.
  ///
  /// Copied from [localsByState].
  LocalsByStateProvider(
    String stateName,
  ) : this._internal(
          (ref) => localsByState(
            ref as LocalsByStateRef,
            stateName,
          ),
          from: localsByStateProvider,
          name: r'localsByStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localsByStateHash,
          dependencies: LocalsByStateFamily._dependencies,
          allTransitiveDependencies:
              LocalsByStateFamily._allTransitiveDependencies,
          stateName: stateName,
        );

  LocalsByStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stateName,
  }) : super.internal();

  final String stateName;

  @override
  Override overrideWith(
    List<LocalsRecord> Function(LocalsByStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalsByStateProvider._internal(
        (ref) => create(ref as LocalsByStateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stateName: stateName,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<LocalsRecord>> createElement() {
    return _LocalsByStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalsByStateProvider && other.stateName == stateName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stateName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocalsByStateRef on AutoDisposeProviderRef<List<LocalsRecord>> {
  /// The parameter `stateName` of this provider.
  String get stateName;
}

class _LocalsByStateProviderElement
    extends AutoDisposeProviderElement<List<LocalsRecord>>
    with LocalsByStateRef {
  _LocalsByStateProviderElement(super.provider);

  @override
  String get stateName => (origin as LocalsByStateProvider).stateName;
}

String _$localsByClassificationHash() =>
    r'31029d3342c649ed9a1a9da987b1d0cc83679f97';

/// Riverpod provider that returns locals filtered by classification.
///
/// Copied from [localsByClassification].
@ProviderFor(localsByClassification)
const localsByClassificationProvider = LocalsByClassificationFamily();

/// Riverpod provider that returns locals filtered by classification.
///
/// Copied from [localsByClassification].
class LocalsByClassificationFamily extends Family<List<LocalsRecord>> {
  /// Riverpod provider that returns locals filtered by classification.
  ///
  /// Copied from [localsByClassification].
  const LocalsByClassificationFamily();

  /// Riverpod provider that returns locals filtered by classification.
  ///
  /// Copied from [localsByClassification].
  LocalsByClassificationProvider call(
    String classification,
  ) {
    return LocalsByClassificationProvider(
      classification,
    );
  }

  @override
  LocalsByClassificationProvider getProviderOverride(
    covariant LocalsByClassificationProvider provider,
  ) {
    return call(
      provider.classification,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'localsByClassificationProvider';
}

/// Riverpod provider that returns locals filtered by classification.
///
/// Copied from [localsByClassification].
class LocalsByClassificationProvider
    extends AutoDisposeProvider<List<LocalsRecord>> {
  /// Riverpod provider that returns locals filtered by classification.
  ///
  /// Copied from [localsByClassification].
  LocalsByClassificationProvider(
    String classification,
  ) : this._internal(
          (ref) => localsByClassification(
            ref as LocalsByClassificationRef,
            classification,
          ),
          from: localsByClassificationProvider,
          name: r'localsByClassificationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localsByClassificationHash,
          dependencies: LocalsByClassificationFamily._dependencies,
          allTransitiveDependencies:
              LocalsByClassificationFamily._allTransitiveDependencies,
          classification: classification,
        );

  LocalsByClassificationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classification,
  }) : super.internal();

  final String classification;

  @override
  Override overrideWith(
    List<LocalsRecord> Function(LocalsByClassificationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalsByClassificationProvider._internal(
        (ref) => create(ref as LocalsByClassificationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classification: classification,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<LocalsRecord>> createElement() {
    return _LocalsByClassificationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalsByClassificationProvider &&
        other.classification == classification;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classification.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocalsByClassificationRef on AutoDisposeProviderRef<List<LocalsRecord>> {
  /// The parameter `classification` of this provider.
  String get classification;
}

class _LocalsByClassificationProviderElement
    extends AutoDisposeProviderElement<List<LocalsRecord>>
    with LocalsByClassificationRef {
  _LocalsByClassificationProviderElement(super.provider);

  @override
  String get classification =>
      (origin as LocalsByClassificationProvider).classification;
}

String _$searchedLocalsHash() => r'6de5ccecf9068a1512bcc9bea0acd81c66a2e5da';

/// Riverpod provider that returns locals matching a search term.
///
/// Copied from [searchedLocals].
@ProviderFor(searchedLocals)
const searchedLocalsProvider = SearchedLocalsFamily();

/// Riverpod provider that returns locals matching a search term.
///
/// Copied from [searchedLocals].
class SearchedLocalsFamily extends Family<List<LocalsRecord>> {
  /// Riverpod provider that returns locals matching a search term.
  ///
  /// Copied from [searchedLocals].
  const SearchedLocalsFamily();

  /// Riverpod provider that returns locals matching a search term.
  ///
  /// Copied from [searchedLocals].
  SearchedLocalsProvider call(
    String searchTerm,
  ) {
    return SearchedLocalsProvider(
      searchTerm,
    );
  }

  @override
  SearchedLocalsProvider getProviderOverride(
    covariant SearchedLocalsProvider provider,
  ) {
    return call(
      provider.searchTerm,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchedLocalsProvider';
}

/// Riverpod provider that returns locals matching a search term.
///
/// Copied from [searchedLocals].
class SearchedLocalsProvider extends AutoDisposeProvider<List<LocalsRecord>> {
  /// Riverpod provider that returns locals matching a search term.
  ///
  /// Copied from [searchedLocals].
  SearchedLocalsProvider(
    String searchTerm,
  ) : this._internal(
          (ref) => searchedLocals(
            ref as SearchedLocalsRef,
            searchTerm,
          ),
          from: searchedLocalsProvider,
          name: r'searchedLocalsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchedLocalsHash,
          dependencies: SearchedLocalsFamily._dependencies,
          allTransitiveDependencies:
              SearchedLocalsFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  SearchedLocalsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchTerm,
  }) : super.internal();

  final String searchTerm;

  @override
  Override overrideWith(
    List<LocalsRecord> Function(SearchedLocalsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchedLocalsProvider._internal(
        (ref) => create(ref as SearchedLocalsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<LocalsRecord>> createElement() {
    return _SearchedLocalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchedLocalsProvider && other.searchTerm == searchTerm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchTerm.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchedLocalsRef on AutoDisposeProviderRef<List<LocalsRecord>> {
  /// The parameter `searchTerm` of this provider.
  String get searchTerm;
}

class _SearchedLocalsProviderElement
    extends AutoDisposeProviderElement<List<LocalsRecord>>
    with SearchedLocalsRef {
  _SearchedLocalsProviderElement(super.provider);

  @override
  String get searchTerm => (origin as SearchedLocalsProvider).searchTerm;
}

String _$allStatesHash() => r'4cc2d2fb9668186fa0ef82b30001595372f3b4ca';

/// See also [allStates].
@ProviderFor(allStates)
final allStatesProvider = AutoDisposeProvider<List<String>>.internal(
  allStates,
  name: r'allStatesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allStatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllStatesRef = AutoDisposeProviderRef<List<String>>;
String _$allClassificationsHash() =>
    r'63ee1011e8dd867d3d0ceb6755c1942285f826f1';

/// See also [allClassifications].
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllClassificationsRef = AutoDisposeProviderRef<List<String>>;
String _$localsHash() => r'd7e1b74fba7e22baae3bf6ea967eee9c7f41e6e1';

/// Riverpod notifier that manages loading and searching of locals.
///
/// Copied from [Locals].
@ProviderFor(Locals)
final localsProvider =
    AutoDisposeNotifierProvider<Locals, LocalsState>.internal(
  Locals.new,
  name: r'localsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$localsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Locals = AutoDisposeNotifier<LocalsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
