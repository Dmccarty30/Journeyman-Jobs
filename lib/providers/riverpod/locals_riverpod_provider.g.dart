// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locals_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier that manages loading and searching of locals.

@ProviderFor(LocalsNotifier)
const localsProvider = LocalsNotifierProvider._();

/// Riverpod notifier that manages loading and searching of locals.
final class LocalsNotifierProvider
    extends $NotifierProvider<LocalsNotifier, LocalsState> {
  /// Riverpod notifier that manages loading and searching of locals.
  const LocalsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localsNotifierHash();

  @$internal
  @override
  LocalsNotifier create() => LocalsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalsState>(value),
    );
  }
}

String _$localsNotifierHash() => r'37585d9e427b3bf9acdde66cb93328d36cbafe06';

/// Riverpod notifier that manages loading and searching of locals.

abstract class _$LocalsNotifier extends $Notifier<LocalsState> {
  LocalsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LocalsState, LocalsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocalsState, LocalsState>,
              LocalsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Riverpod provider that fetches a single local by ID.

@ProviderFor(localById)
const localByIdProvider = LocalByIdFamily._();

/// Riverpod provider that fetches a single local by ID.

final class LocalByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalsRecord?>,
          LocalsRecord?,
          FutureOr<LocalsRecord?>
        >
    with $FutureModifier<LocalsRecord?>, $FutureProvider<LocalsRecord?> {
  /// Riverpod provider that fetches a single local by ID.
  const LocalByIdProvider._({
    required LocalByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localByIdHash();

  @override
  String toString() {
    return r'localByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LocalsRecord?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocalsRecord?> create(Ref ref) {
    final argument = this.argument as String;
    return localById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localByIdHash() => r'88f2d158c643afb9ad2a961579c6fb1160605970';

/// Riverpod provider that fetches a single local by ID.

final class LocalByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LocalsRecord?>, String> {
  const LocalByIdFamily._()
    : super(
        retry: null,
        name: r'localByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod provider that fetches a single local by ID.

  LocalByIdProvider call(String localId) =>
      LocalByIdProvider._(argument: localId, from: this);

  @override
  String toString() => r'localByIdProvider';
}

/// Riverpod provider that returns locals filtered by state.

@ProviderFor(localsByState)
const localsByStateProvider = LocalsByStateFamily._();

/// Riverpod provider that returns locals filtered by state.

final class LocalsByStateProvider
    extends
        $FunctionalProvider<
          List<LocalsRecord>,
          List<LocalsRecord>,
          List<LocalsRecord>
        >
    with $Provider<List<LocalsRecord>> {
  /// Riverpod provider that returns locals filtered by state.
  const LocalsByStateProvider._({
    required LocalsByStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localsByStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localsByStateHash();

  @override
  String toString() {
    return r'localsByStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<LocalsRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<LocalsRecord> create(Ref ref) {
    final argument = this.argument as String;
    return localsByState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LocalsRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LocalsRecord>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocalsByStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localsByStateHash() => r'679e8b7e0e7069491671ec211f9e635dcec9fb8d';

/// Riverpod provider that returns locals filtered by state.

final class LocalsByStateFamily extends $Family
    with $FunctionalFamilyOverride<List<LocalsRecord>, String> {
  const LocalsByStateFamily._()
    : super(
        retry: null,
        name: r'localsByStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod provider that returns locals filtered by state.

  LocalsByStateProvider call(String stateName) =>
      LocalsByStateProvider._(argument: stateName, from: this);

  @override
  String toString() => r'localsByStateProvider';
}

/// Riverpod provider that returns locals filtered by classification.

@ProviderFor(localsByClassification)
const localsByClassificationProvider = LocalsByClassificationFamily._();

/// Riverpod provider that returns locals filtered by classification.

final class LocalsByClassificationProvider
    extends
        $FunctionalProvider<
          List<LocalsRecord>,
          List<LocalsRecord>,
          List<LocalsRecord>
        >
    with $Provider<List<LocalsRecord>> {
  /// Riverpod provider that returns locals filtered by classification.
  const LocalsByClassificationProvider._({
    required LocalsByClassificationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localsByClassificationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localsByClassificationHash();

  @override
  String toString() {
    return r'localsByClassificationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<LocalsRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<LocalsRecord> create(Ref ref) {
    final argument = this.argument as String;
    return localsByClassification(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LocalsRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LocalsRecord>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocalsByClassificationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localsByClassificationHash() =>
    r'5bd4e9c9406c1f2246b1eef478161c4601493bba';

/// Riverpod provider that returns locals filtered by classification.

final class LocalsByClassificationFamily extends $Family
    with $FunctionalFamilyOverride<List<LocalsRecord>, String> {
  const LocalsByClassificationFamily._()
    : super(
        retry: null,
        name: r'localsByClassificationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod provider that returns locals filtered by classification.

  LocalsByClassificationProvider call(String classification) =>
      LocalsByClassificationProvider._(argument: classification, from: this);

  @override
  String toString() => r'localsByClassificationProvider';
}

/// Riverpod provider that returns locals matching a search term.

@ProviderFor(searchedLocals)
const searchedLocalsProvider = SearchedLocalsFamily._();

/// Riverpod provider that returns locals matching a search term.

final class SearchedLocalsProvider
    extends
        $FunctionalProvider<
          List<LocalsRecord>,
          List<LocalsRecord>,
          List<LocalsRecord>
        >
    with $Provider<List<LocalsRecord>> {
  /// Riverpod provider that returns locals matching a search term.
  const SearchedLocalsProvider._({
    required SearchedLocalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchedLocalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchedLocalsHash();

  @override
  String toString() {
    return r'searchedLocalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<LocalsRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<LocalsRecord> create(Ref ref) {
    final argument = this.argument as String;
    return searchedLocals(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LocalsRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LocalsRecord>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchedLocalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchedLocalsHash() => r'397212ab6ddf6dbd11529d013bb6d808812e04a4';

/// Riverpod provider that returns locals matching a search term.

final class SearchedLocalsFamily extends $Family
    with $FunctionalFamilyOverride<List<LocalsRecord>, String> {
  const SearchedLocalsFamily._()
    : super(
        retry: null,
        name: r'searchedLocalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod provider that returns locals matching a search term.

  SearchedLocalsProvider call(String searchTerm) =>
      SearchedLocalsProvider._(argument: searchTerm, from: this);

  @override
  String toString() => r'searchedLocalsProvider';
}

@ProviderFor(allStates)
const allStatesProvider = AllStatesProvider._();

final class AllStatesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  const AllStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allStatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allStatesHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return allStates(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$allStatesHash() => r'53d536680dc1bfd63e1afdac1ec7298565533bd5';

@ProviderFor(allClassifications)
const allClassificationsProvider = AllClassificationsProvider._();

final class AllClassificationsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  const AllClassificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allClassificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allClassificationsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return allClassifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$allClassificationsHash() =>
    r'6b12d38f285207c71cce102e05a269c6ba8f3d6e';
