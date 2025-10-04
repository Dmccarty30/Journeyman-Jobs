// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// FeedService provider

@ProviderFor(feedService)
const feedServiceProvider = FeedServiceProvider._();

/// FeedService provider

final class FeedServiceProvider
    extends $FunctionalProvider<FeedService, FeedService, FeedService>
    with $Provider<FeedService> {
  /// FeedService provider
  const FeedServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedServiceHash();

  @$internal
  @override
  $ProviderElement<FeedService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedService create(Ref ref) {
    return feedService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedService>(value),
    );
  }
}

String _$feedServiceHash() => r'e4adaf3d0765ea270bafbca76dcd9d0be6570ba1';

/// Stream of posts for a specific crew

@ProviderFor(crewPostsStream)
const crewPostsStreamProvider = CrewPostsStreamFamily._();

/// Stream of posts for a specific crew

final class CrewPostsStreamProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, Stream<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $StreamProvider<List<PostModel>> {
  /// Stream of posts for a specific crew
  const CrewPostsStreamProvider._(
      {required CrewPostsStreamFamily super.from,
      required String super.argument})
      : super(
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
  $StreamProviderElement<List<PostModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<PostModel>> create(Ref ref) {
    final argument = this.argument as String;
    return crewPostsStream(
      ref,
      argument,
    );
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

String _$crewPostsStreamHash() => r'077f84fa21f3daa701a55dfaaac8ec36a2a7407e';

/// Stream of posts for a specific crew

final class CrewPostsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostModel>>, String> {
  const CrewPostsStreamFamily._()
      : super(
          retry: null,
          name: r'crewPostsStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Stream of posts for a specific crew

  CrewPostsStreamProvider call(
    String crewId,
  ) =>
      CrewPostsStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewPostsStreamProvider';
}

/// Posts for a specific crew

@ProviderFor(crewPosts)
const crewPostsProvider = CrewPostsFamily._();

/// Posts for a specific crew

final class CrewPostsProvider extends $FunctionalProvider<List<PostModel>,
    List<PostModel>, List<PostModel>> with $Provider<List<PostModel>> {
  /// Posts for a specific crew
  const CrewPostsProvider._(
      {required CrewPostsFamily super.from, required String super.argument})
      : super(
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
  $ProviderElement<List<PostModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PostModel> create(Ref ref) {
    final argument = this.argument as String;
    return crewPosts(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PostModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PostModel>>(value),
    );
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

String _$crewPostsHash() => r'0c949d27dfd0d9bff6ff13c8a4df676666e15413';

/// Posts for a specific crew

final class CrewPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<PostModel>, String> {
  const CrewPostsFamily._()
      : super(
          retry: null,
          name: r'crewPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Posts for a specific crew

  CrewPostsProvider call(
    String crewId,
  ) =>
      CrewPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewPostsProvider';
}

/// Stream of comments for a specific post

@ProviderFor(postCommentsStream)
const postCommentsStreamProvider = PostCommentsStreamFamily._();

/// Stream of comments for a specific post

final class PostCommentsStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Comment>>, List<Comment>, Stream<List<Comment>>>
    with $FutureModifier<List<Comment>>, $StreamProvider<List<Comment>> {
  /// Stream of comments for a specific post
  const PostCommentsStreamProvider._(
      {required PostCommentsStreamFamily super.from,
      required String super.argument})
      : super(
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
  $StreamProviderElement<List<Comment>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Comment>> create(Ref ref) {
    final argument = this.argument as String;
    return postCommentsStream(
      ref,
      argument,
    );
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
    r'8942384cfb49a6d2662a0d5c85b19751fd1ee14b';

/// Stream of comments for a specific post

final class PostCommentsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Comment>>, String> {
  const PostCommentsStreamFamily._()
      : super(
          retry: null,
          name: r'postCommentsStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Stream of comments for a specific post

  PostCommentsStreamProvider call(
    String postId,
  ) =>
      PostCommentsStreamProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsStreamProvider';
}

/// Comments for a specific post

@ProviderFor(postComments)
const postCommentsProvider = PostCommentsFamily._();

/// Comments for a specific post

final class PostCommentsProvider
    extends $FunctionalProvider<List<Comment>, List<Comment>, List<Comment>>
    with $Provider<List<Comment>> {
  /// Comments for a specific post
  const PostCommentsProvider._(
      {required PostCommentsFamily super.from, required String super.argument})
      : super(
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
  $ProviderElement<List<Comment>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Comment> create(Ref ref) {
    final argument = this.argument as String;
    return postComments(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Comment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Comment>>(value),
    );
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

String _$postCommentsHash() => r'cad9b27b842d60097dfb39bc36f7237b689993d8';

/// Comments for a specific post

final class PostCommentsFamily extends $Family
    with $FunctionalFamilyOverride<List<Comment>, String> {
  const PostCommentsFamily._()
      : super(
          retry: null,
          name: r'postCommentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Comments for a specific post

  PostCommentsProvider call(
    String postId,
  ) =>
      PostCommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsProvider';
}

/// Provider to get posts for selected crew

@ProviderFor(selectedCrewPosts)
const selectedCrewPostsProvider = SelectedCrewPostsProvider._();

/// Provider to get posts for selected crew

final class SelectedCrewPostsProvider extends $FunctionalProvider<
    List<PostModel>,
    List<PostModel>,
    List<PostModel>> with $Provider<List<PostModel>> {
  /// Provider to get posts for selected crew
  const SelectedCrewPostsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCrewPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCrewPostsHash();

  @$internal
  @override
  $ProviderElement<List<PostModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PostModel> create(Ref ref) {
    return selectedCrewPosts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PostModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PostModel>>(value),
    );
  }
}

String _$selectedCrewPostsHash() => r'6ddf7494c30e1a5834db03f4904e6eb09caa0b77';

/// Provider to get pinned posts for a crew

@ProviderFor(pinnedPosts)
const pinnedPostsProvider = PinnedPostsFamily._();

/// Provider to get pinned posts for a crew

final class PinnedPostsProvider extends $FunctionalProvider<List<PostModel>,
    List<PostModel>, List<PostModel>> with $Provider<List<PostModel>> {
  /// Provider to get pinned posts for a crew
  const PinnedPostsProvider._(
      {required PinnedPostsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'pinnedPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pinnedPostsHash();

  @override
  String toString() {
    return r'pinnedPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<PostModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PostModel> create(Ref ref) {
    final argument = this.argument as String;
    return pinnedPosts(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PostModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PostModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PinnedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pinnedPostsHash() => r'22cb2b07bb0e668982183bdcac5c549501ca8d75';

/// Provider to get pinned posts for a crew

final class PinnedPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<PostModel>, String> {
  const PinnedPostsFamily._()
      : super(
          retry: null,
          name: r'pinnedPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get pinned posts for a crew

  PinnedPostsProvider call(
    String crewId,
  ) =>
      PinnedPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'pinnedPostsProvider';
}

/// Provider to get recent posts (non-pinned) for a crew

@ProviderFor(recentPosts)
const recentPostsProvider = RecentPostsFamily._();

/// Provider to get recent posts (non-pinned) for a crew

final class RecentPostsProvider extends $FunctionalProvider<List<PostModel>,
    List<PostModel>, List<PostModel>> with $Provider<List<PostModel>> {
  /// Provider to get recent posts (non-pinned) for a crew
  const RecentPostsProvider._(
      {required RecentPostsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'recentPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentPostsHash();

  @override
  String toString() {
    return r'recentPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<PostModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PostModel> create(Ref ref) {
    final argument = this.argument as String;
    return recentPosts(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PostModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PostModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecentPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentPostsHash() => r'b5c902ee9c81f010cb8cf78dd95fa61d844c6781';

/// Provider to get recent posts (non-pinned) for a crew

final class RecentPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<PostModel>, String> {
  const RecentPostsFamily._()
      : super(
          retry: null,
          name: r'recentPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get recent posts (non-pinned) for a crew

  RecentPostsProvider call(
    String crewId,
  ) =>
      RecentPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'recentPostsProvider';
}

/// Provider to get posts by a specific author

@ProviderFor(postsByAuthor)
const postsByAuthorProvider = PostsByAuthorFamily._();

/// Provider to get posts by a specific author

final class PostsByAuthorProvider extends $FunctionalProvider<List<PostModel>,
    List<PostModel>, List<PostModel>> with $Provider<List<PostModel>> {
  /// Provider to get posts by a specific author
  const PostsByAuthorProvider._(
      {required PostsByAuthorFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'postsByAuthorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postsByAuthorHash();

  @override
  String toString() {
    return r'postsByAuthorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<PostModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PostModel> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return postsByAuthor(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PostModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PostModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostsByAuthorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postsByAuthorHash() => r'94523172b090bbc482f0193b136f72b0de4a5741';

/// Provider to get posts by a specific author

final class PostsByAuthorFamily extends $Family
    with
        $FunctionalFamilyOverride<
            List<PostModel>,
            (
              String,
              String,
            )> {
  const PostsByAuthorFamily._()
      : super(
          retry: null,
          name: r'postsByAuthorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get posts by a specific author

  PostsByAuthorProvider call(
    String crewId,
    String authorId,
  ) =>
      PostsByAuthorProvider._(argument: (
        crewId,
        authorId,
      ), from: this);

  @override
  String toString() => r'postsByAuthorProvider';
}

/// Provider for post creation notifier

@ProviderFor(postCreationNotifier)
const postCreationProvider = PostCreationNotifierProvider._();

/// Provider for post creation notifier

final class PostCreationNotifierProvider extends $FunctionalProvider<
    PostCreationNotifier,
    PostCreationNotifier,
    PostCreationNotifier> with $Provider<PostCreationNotifier> {
  /// Provider for post creation notifier
  const PostCreationNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postCreationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postCreationNotifierHash();

  @$internal
  @override
  $ProviderElement<PostCreationNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostCreationNotifier create(Ref ref) {
    return postCreationNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostCreationNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostCreationNotifier>(value),
    );
  }
}

String _$postCreationNotifierHash() =>
    r'adca49ffd817ee1e6eafc9b6b00d952d9c37a364';

/// Stream of post creation state

@ProviderFor(postCreationState)
const postCreationStateProvider = PostCreationStateProvider._();

/// Stream of post creation state

final class PostCreationStateProvider extends $FunctionalProvider<
    AsyncValue<String?>,
    AsyncValue<String?>,
    AsyncValue<String?>> with $Provider<AsyncValue<String?>> {
  /// Stream of post creation state
  const PostCreationStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postCreationStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postCreationStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<String?>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<String?> create(Ref ref) {
    return postCreationState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$postCreationStateHash() => r'4abf3cc72137c3ba6ff0c208203d4a5ea1b3c7bb';

/// Provider for post update notifier

@ProviderFor(postUpdateNotifier)
const postUpdateProvider = PostUpdateNotifierProvider._();

/// Provider for post update notifier

final class PostUpdateNotifierProvider extends $FunctionalProvider<
    PostUpdateNotifier,
    PostUpdateNotifier,
    PostUpdateNotifier> with $Provider<PostUpdateNotifier> {
  /// Provider for post update notifier
  const PostUpdateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postUpdateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postUpdateNotifierHash();

  @$internal
  @override
  $ProviderElement<PostUpdateNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostUpdateNotifier create(Ref ref) {
    return postUpdateNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostUpdateNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostUpdateNotifier>(value),
    );
  }
}

String _$postUpdateNotifierHash() =>
    r'b26a1b333a91d7ca44a5f6712629393d6ea53661';

/// Stream of post update state

@ProviderFor(postUpdateState)
const postUpdateStateProvider = PostUpdateStateProvider._();

/// Stream of post update state

final class PostUpdateStateProvider extends $FunctionalProvider<
    AsyncValue<void>,
    AsyncValue<void>,
    AsyncValue<void>> with $Provider<AsyncValue<void>> {
  /// Stream of post update state
  const PostUpdateStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postUpdateStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postUpdateStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<void>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<void> create(Ref ref) {
    return postUpdateState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$postUpdateStateHash() => r'891150164b0a1fba3fdb79798a2a09351e7b9edf';

/// Provider for reaction notifier

@ProviderFor(reactionNotifier)
const reactionProvider = ReactionNotifierProvider._();

/// Provider for reaction notifier

final class ReactionNotifierProvider extends $FunctionalProvider<
    ReactionNotifier,
    ReactionNotifier,
    ReactionNotifier> with $Provider<ReactionNotifier> {
  /// Provider for reaction notifier
  const ReactionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reactionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reactionNotifierHash();

  @$internal
  @override
  $ProviderElement<ReactionNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReactionNotifier create(Ref ref) {
    return reactionNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReactionNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReactionNotifier>(value),
    );
  }
}

String _$reactionNotifierHash() => r'82089bf49cb8dd28fa332f32db59bc3568954181';

/// Stream of reaction state

@ProviderFor(reactionState)
const reactionStateProvider = ReactionStateProvider._();

/// Stream of reaction state

final class ReactionStateProvider extends $FunctionalProvider<AsyncValue<void>,
    AsyncValue<void>, AsyncValue<void>> with $Provider<AsyncValue<void>> {
  /// Stream of reaction state
  const ReactionStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reactionStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reactionStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<void>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<void> create(Ref ref) {
    return reactionState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$reactionStateHash() => r'bfad753898de78e38b25cd32ab919878443b835d';

/// Provider for comment notifier

@ProviderFor(commentNotifier)
const commentProvider = CommentNotifierProvider._();

/// Provider for comment notifier

final class CommentNotifierProvider extends $FunctionalProvider<CommentNotifier,
    CommentNotifier, CommentNotifier> with $Provider<CommentNotifier> {
  /// Provider for comment notifier
  const CommentNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentNotifierHash();

  @$internal
  @override
  $ProviderElement<CommentNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommentNotifier create(Ref ref) {
    return commentNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentNotifier>(value),
    );
  }
}

String _$commentNotifierHash() => r'a3c4fdcf94232f02dbb52dc995f0a51b46506e2f';

/// Stream of comment state

@ProviderFor(commentState)
const commentStateProvider = CommentStateProvider._();

/// Stream of comment state

final class CommentStateProvider extends $FunctionalProvider<
    AsyncValue<String?>,
    AsyncValue<String?>,
    AsyncValue<String?>> with $Provider<AsyncValue<String?>> {
  /// Stream of comment state
  const CommentStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<String?>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<String?> create(Ref ref) {
    return commentState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$commentStateHash() => r'ed50389c1f8fb3a1e0af7bcabe5fe4813e2b960d';

/// Provider to get crew post statistics

@ProviderFor(crewPostStats)
const crewPostStatsProvider = CrewPostStatsFamily._();

/// Provider to get crew post statistics

final class CrewPostStatsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider to get crew post statistics
  const CrewPostStatsProvider._(
      {required CrewPostStatsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'crewPostStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewPostStatsHash();

  @override
  String toString() {
    return r'crewPostStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return crewPostStats(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewPostStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewPostStatsHash() => r'71ef9f6c8917ec6626f75cd26caf6096bca2a3e7';

/// Provider to get crew post statistics

final class CrewPostStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  const CrewPostStatsFamily._()
      : super(
          retry: null,
          name: r'crewPostStatsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get crew post statistics

  CrewPostStatsProvider call(
    String crewId,
  ) =>
      CrewPostStatsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewPostStatsProvider';
}

/// Provider to get reaction counts for a post

@ProviderFor(postReactionCounts)
const postReactionCountsProvider = PostReactionCountsFamily._();

/// Provider to get reaction counts for a post

final class PostReactionCountsProvider extends $FunctionalProvider<
    Map<ReactionType, int>,
    Map<ReactionType, int>,
    Map<ReactionType, int>> with $Provider<Map<ReactionType, int>> {
  /// Provider to get reaction counts for a post
  const PostReactionCountsProvider._(
      {required PostReactionCountsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'postReactionCountsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postReactionCountsHash();

  @override
  String toString() {
    return r'postReactionCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<ReactionType, int>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<ReactionType, int> create(Ref ref) {
    final argument = this.argument as String;
    return postReactionCounts(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<ReactionType, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<ReactionType, int>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostReactionCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postReactionCountsHash() =>
    r'e4a4ded429820b262633faf28142bedf7bb10037';

/// Provider to get reaction counts for a post

final class PostReactionCountsFamily extends $Family
    with $FunctionalFamilyOverride<Map<ReactionType, int>, String> {
  const PostReactionCountsFamily._()
      : super(
          retry: null,
          name: r'postReactionCountsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get reaction counts for a post

  PostReactionCountsProvider call(
    String postId,
  ) =>
      PostReactionCountsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postReactionCountsProvider';
}

/// Provider to check if current user has reacted to a post

@ProviderFor(userReactionToPost)
const userReactionToPostProvider = UserReactionToPostFamily._();

/// Provider to check if current user has reacted to a post

final class UserReactionToPostProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider to check if current user has reacted to a post
  const UserReactionToPostProvider._(
      {required UserReactionToPostFamily super.from,
      required (
        String,
        ReactionType,
      )
          super.argument})
      : super(
          retry: null,
          name: r'userReactionToPostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userReactionToPostHash();

  @override
  String toString() {
    return r'userReactionToPostProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (
      String,
      ReactionType,
    );
    return userReactionToPost(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserReactionToPostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userReactionToPostHash() =>
    r'f7a1695e7ae1664c5eef73e75f299facaee2d6a4';

/// Provider to check if current user has reacted to a post

final class UserReactionToPostFamily extends $Family
    with
        $FunctionalFamilyOverride<
            bool,
            (
              String,
              ReactionType,
            )> {
  const UserReactionToPostFamily._()
      : super(
          retry: null,
          name: r'userReactionToPostProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if current user has reacted to a post

  UserReactionToPostProvider call(
    String postId,
    ReactionType reactionType,
  ) =>
      UserReactionToPostProvider._(argument: (
        postId,
        reactionType,
      ), from: this);

  @override
  String toString() => r'userReactionToPostProvider';
}
