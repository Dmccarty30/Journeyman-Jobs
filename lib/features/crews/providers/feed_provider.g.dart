// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for feed filter state

@ProviderFor(FeedFilter)
const feedFilterProvider = FeedFilterProvider._();

/// Provider for feed filter state
final class FeedFilterProvider
    extends $NotifierProvider<FeedFilter, FeedFilterState> {
  /// Provider for feed filter state
  const FeedFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedFilterHash();

  @$internal
  @override
  FeedFilter create() => FeedFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedFilterState>(value),
    );
  }
}

String _$feedFilterHash() => r'41a29a9cd555fe77c11aac9736342aadc6bb77d7';

/// Provider for feed filter state

abstract class _$FeedFilter extends $Notifier<FeedFilterState> {
  FeedFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedFilterState, FeedFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedFilterState, FeedFilterState>,
              FeedFilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Stream provider for crew posts with real-time updates

@ProviderFor(crewPostsStream)
const crewPostsStreamProvider = CrewPostsStreamFamily._();

/// Stream provider for crew posts with real-time updates

final class CrewPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// Stream provider for crew posts with real-time updates
  const CrewPostsStreamProvider._({
    required CrewPostsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crewPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crewPostsStreamHash();

  @override
  String toString() {
    return r'crewPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    final argument = this.argument as String;
    return crewPostsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewPostsStreamHash() => r'b38d329c77bbbdfafc4953a70611f7887334e744';

/// Stream provider for crew posts with real-time updates

final class CrewPostsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Post>>, String> {
  const CrewPostsStreamFamily._()
    : super(
        retry: null,
        name: r'crewPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for crew posts with real-time updates

  CrewPostsStreamProvider call(String crewId) =>
      CrewPostsStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewPostsStreamProvider';
}

/// Provider for crew posts (converts stream to AsyncValue)

@ProviderFor(crewPosts)
const crewPostsProvider = CrewPostsFamily._();

/// Provider for crew posts (converts stream to AsyncValue)

final class CrewPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  /// Provider for crew posts (converts stream to AsyncValue)
  const CrewPostsProvider._({
    required CrewPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crewPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crewPostsHash();

  @override
  String toString() {
    return r'crewPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    final argument = this.argument as String;
    return crewPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewPostsHash() => r'f01689962d331b29be280ae076619f7646049bc6';

/// Provider for crew posts (converts stream to AsyncValue)

final class CrewPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Post>>, String> {
  const CrewPostsFamily._()
    : super(
        retry: null,
        name: r'crewPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for crew posts (converts stream to AsyncValue)

  CrewPostsProvider call(String crewId) =>
      CrewPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewPostsProvider';
}

/// Stream provider for global feed with real-time updates

@ProviderFor(globalFeedStream)
const globalFeedStreamProvider = GlobalFeedStreamProvider._();

/// Stream provider for global feed with real-time updates

final class GlobalFeedStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// Stream provider for global feed with real-time updates
  const GlobalFeedStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalFeedStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalFeedStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    return globalFeedStream(ref);
  }
}

String _$globalFeedStreamHash() => r'92d5c5ff5eac42be2a8d6d339eb669893fec8a2a';

/// Provider for global feed (converts stream to AsyncValue)

@ProviderFor(globalFeed)
const globalFeedProvider = GlobalFeedProvider._();

/// Provider for global feed (converts stream to AsyncValue)

final class GlobalFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// Provider for global feed (converts stream to AsyncValue)
  const GlobalFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalFeedHash();

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    return globalFeed(ref);
  }
}

String _$globalFeedHash() => r'59727fc631bac8371425e8095b31887e40b67c75';

/// Provider for filtered and sorted posts based on crew or global context

@ProviderFor(filteredPosts)
const filteredPostsProvider = FilteredPostsFamily._();

/// Provider for filtered and sorted posts based on crew or global context

final class FilteredPostsProvider
    extends $FunctionalProvider<List<Post>, List<Post>, List<Post>>
    with $Provider<List<Post>> {
  /// Provider for filtered and sorted posts based on crew or global context
  const FilteredPostsProvider._({
    required FilteredPostsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'filteredPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredPostsHash();

  @override
  String toString() {
    return r'filteredPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Post> create(Ref ref) {
    final argument = this.argument as String?;
    return filteredPosts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Post> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Post>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredPostsHash() => r'441f5578be504055b7472f1f5c9530f91e972f19';

/// Provider for filtered and sorted posts based on crew or global context

final class FilteredPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<Post>, String?> {
  const FilteredPostsFamily._()
    : super(
        retry: null,
        name: r'filteredPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for filtered and sorted posts based on crew or global context

  FilteredPostsProvider call(String? crewId) =>
      FilteredPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'filteredPostsProvider';
}

/// Stream provider for post comments with real-time updates

@ProviderFor(postCommentsStream)
const postCommentsStreamProvider = PostCommentsStreamFamily._();

/// Stream provider for post comments with real-time updates

final class PostCommentsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostComment>>,
          List<PostComment>,
          Stream<List<PostComment>>
        >
    with
        $FutureModifier<List<PostComment>>,
        $StreamProvider<List<PostComment>> {
  /// Stream provider for post comments with real-time updates
  const PostCommentsStreamProvider._({
    required PostCommentsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postCommentsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCommentsStreamHash();

  @override
  String toString() {
    return r'postCommentsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostComment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostComment>> create(Ref ref) {
    final argument = this.argument as String;
    return postCommentsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCommentsStreamHash() =>
    r'77f42eaa0b1059cd1df4749a472786235e77bcfe';

/// Stream provider for post comments with real-time updates

final class PostCommentsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostComment>>, String> {
  const PostCommentsStreamFamily._()
    : super(
        retry: null,
        name: r'postCommentsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for post comments with real-time updates

  PostCommentsStreamProvider call(String postId) =>
      PostCommentsStreamProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsStreamProvider';
}

/// Provider for post comments (converts stream to AsyncValue)

@ProviderFor(postComments)
const postCommentsProvider = PostCommentsFamily._();

/// Provider for post comments (converts stream to AsyncValue)

final class PostCommentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostComment>>,
          List<PostComment>,
          Stream<List<PostComment>>
        >
    with
        $FutureModifier<List<PostComment>>,
        $StreamProvider<List<PostComment>> {
  /// Provider for post comments (converts stream to AsyncValue)
  const PostCommentsProvider._({
    required PostCommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCommentsHash();

  @override
  String toString() {
    return r'postCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostComment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostComment>> create(Ref ref) {
    final argument = this.argument as String;
    return postComments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCommentsHash() => r'41091163f2749f427054395010391c7855d0aba5';

/// Provider for post comments (converts stream to AsyncValue)

final class PostCommentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostComment>>, String> {
  const PostCommentsFamily._()
    : super(
        retry: null,
        name: r'postCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for post comments (converts stream to AsyncValue)

  PostCommentsProvider call(String postId) =>
      PostCommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsProvider';
}

/// Provider to check if any filters are active

@ProviderFor(hasActiveFeedFilters)
const hasActiveFeedFiltersProvider = HasActiveFeedFiltersProvider._();

/// Provider to check if any filters are active

final class HasActiveFeedFiltersProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if any filters are active
  const HasActiveFeedFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasActiveFeedFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasActiveFeedFiltersHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasActiveFeedFilters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasActiveFeedFiltersHash() =>
    r'25c0884274646fe2f90a6dd2e5f642017e6bdb77';

/// Provider to get filter summary text

@ProviderFor(feedFilterSummary)
const feedFilterSummaryProvider = FeedFilterSummaryProvider._();

/// Provider to get filter summary text

final class FeedFilterSummaryProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider to get filter summary text
  const FeedFilterSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedFilterSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedFilterSummaryHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return feedFilterSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$feedFilterSummaryHash() => r'de1e0d4eff0c533598be202d0626442b04ade1aa';

/// Provider for archived posts (history)

@ProviderFor(archivedPosts)
const archivedPostsProvider = ArchivedPostsFamily._();

/// Provider for archived posts (history)

final class ArchivedPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  /// Provider for archived posts (history)
  const ArchivedPostsProvider._({
    required ArchivedPostsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'archivedPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$archivedPostsHash();

  @override
  String toString() {
    return r'archivedPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    final argument = this.argument as String?;
    return archivedPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ArchivedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$archivedPostsHash() => r'ae7731b14f17ffecff1a557c89e5de6327c4672f';

/// Provider for archived posts (history)

final class ArchivedPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Post>>, String?> {
  const ArchivedPostsFamily._()
    : super(
        retry: null,
        name: r'archivedPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for archived posts (history)

  ArchivedPostsProvider call(String? crewId) =>
      ArchivedPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'archivedPostsProvider';
}
