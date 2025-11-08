// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tailboard_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// TailboardService provider

@ProviderFor(tailboardService)
const tailboardServiceProvider = TailboardServiceProvider._();

/// TailboardService provider

final class TailboardServiceProvider
    extends
        $FunctionalProvider<
          TailboardService,
          TailboardService,
          TailboardService
        >
    with $Provider<TailboardService> {
  /// TailboardService provider
  const TailboardServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tailboardServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tailboardServiceHash();

  @$internal
  @override
  $ProviderElement<TailboardService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TailboardService create(Ref ref) {
    return tailboardService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TailboardService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TailboardService>(value),
    );
  }
}

String _$tailboardServiceHash() => r'a008ee27926f60cfa4901bb94d74ed464864c13b';

/// Stream of tailboard data for a specific crew

@ProviderFor(tailboardStream)
const tailboardStreamProvider = TailboardStreamFamily._();

/// Stream of tailboard data for a specific crew

final class TailboardStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Tailboard?>,
          Tailboard?,
          Stream<Tailboard?>
        >
    with $FutureModifier<Tailboard?>, $StreamProvider<Tailboard?> {
  /// Stream of tailboard data for a specific crew
  const TailboardStreamProvider._({
    required TailboardStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tailboardStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tailboardStreamHash();

  @override
  String toString() {
    return r'tailboardStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Tailboard?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Tailboard?> create(Ref ref) {
    final argument = this.argument as String;
    return tailboardStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TailboardStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tailboardStreamHash() => r'695857c8ddee060db4eee0951e34af3a35c347c8';

/// Stream of tailboard data for a specific crew

final class TailboardStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Tailboard?>, String> {
  const TailboardStreamFamily._()
    : super(
        retry: null,
        name: r'tailboardStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream of tailboard data for a specific crew

  TailboardStreamProvider call(String crewId) =>
      TailboardStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'tailboardStreamProvider';
}

/// Tailboard data for a specific crew

@ProviderFor(tailboard)
const tailboardProvider = TailboardFamily._();

/// Tailboard data for a specific crew

final class TailboardProvider
    extends $FunctionalProvider<Tailboard?, Tailboard?, Tailboard?>
    with $Provider<Tailboard?> {
  /// Tailboard data for a specific crew
  const TailboardProvider._({
    required TailboardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tailboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tailboardHash();

  @override
  String toString() {
    return r'tailboardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Tailboard?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Tailboard? create(Ref ref) {
    final argument = this.argument as String;
    return tailboard(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Tailboard? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Tailboard?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TailboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tailboardHash() => r'fa23afa0b876bc3812f4d9ba8a32eb46fed7f492';

/// Tailboard data for a specific crew

final class TailboardFamily extends $Family
    with $FunctionalFamilyOverride<Tailboard?, String> {
  const TailboardFamily._()
    : super(
        retry: null,
        name: r'tailboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tailboard data for a specific crew

  TailboardProvider call(String crewId) =>
      TailboardProvider._(argument: crewId, from: this);

  @override
  String toString() => r'tailboardProvider';
}

/// Stream of suggested jobs for a specific crew

@ProviderFor(suggestedJobsStream)
const suggestedJobsStreamProvider = SuggestedJobsStreamFamily._();

/// Stream of suggested jobs for a specific crew

final class SuggestedJobsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SuggestedJob>>,
          List<SuggestedJob>,
          Stream<List<SuggestedJob>>
        >
    with
        $FutureModifier<List<SuggestedJob>>,
        $StreamProvider<List<SuggestedJob>> {
  /// Stream of suggested jobs for a specific crew
  const SuggestedJobsStreamProvider._({
    required SuggestedJobsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'suggestedJobsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$suggestedJobsStreamHash();

  @override
  String toString() {
    return r'suggestedJobsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SuggestedJob>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SuggestedJob>> create(Ref ref) {
    final argument = this.argument as String;
    return suggestedJobsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SuggestedJobsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$suggestedJobsStreamHash() =>
    r'efb34b414d0f7334aff624a0338809d3a8204261';

/// Stream of suggested jobs for a specific crew

final class SuggestedJobsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SuggestedJob>>, String> {
  const SuggestedJobsStreamFamily._()
    : super(
        retry: null,
        name: r'suggestedJobsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream of suggested jobs for a specific crew

  SuggestedJobsStreamProvider call(String crewId) =>
      SuggestedJobsStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'suggestedJobsStreamProvider';
}

/// Suggested jobs for a specific crew

@ProviderFor(suggestedJobs)
const suggestedJobsProvider = SuggestedJobsFamily._();

/// Suggested jobs for a specific crew

final class SuggestedJobsProvider
    extends
        $FunctionalProvider<
          List<SuggestedJob>,
          List<SuggestedJob>,
          List<SuggestedJob>
        >
    with $Provider<List<SuggestedJob>> {
  /// Suggested jobs for a specific crew
  const SuggestedJobsProvider._({
    required SuggestedJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'suggestedJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$suggestedJobsHash();

  @override
  String toString() {
    return r'suggestedJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<SuggestedJob>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SuggestedJob> create(Ref ref) {
    final argument = this.argument as String;
    return suggestedJobs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SuggestedJob> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SuggestedJob>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SuggestedJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$suggestedJobsHash() => r'e303329f20467388185be8fc3f897e27fa60eb12';

/// Suggested jobs for a specific crew

final class SuggestedJobsFamily extends $Family
    with $FunctionalFamilyOverride<List<SuggestedJob>, String> {
  const SuggestedJobsFamily._()
    : super(
        retry: null,
        name: r'suggestedJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Suggested jobs for a specific crew

  SuggestedJobsProvider call(String crewId) =>
      SuggestedJobsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'suggestedJobsProvider';
}

/// Stream of activity items for a specific crew

@ProviderFor(activityItemsStream)
const activityItemsStreamProvider = ActivityItemsStreamFamily._();

/// Stream of activity items for a specific crew

final class ActivityItemsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActivityItem>>,
          List<ActivityItem>,
          Stream<List<ActivityItem>>
        >
    with
        $FutureModifier<List<ActivityItem>>,
        $StreamProvider<List<ActivityItem>> {
  /// Stream of activity items for a specific crew
  const ActivityItemsStreamProvider._({
    required ActivityItemsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activityItemsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activityItemsStreamHash();

  @override
  String toString() {
    return r'activityItemsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ActivityItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ActivityItem>> create(Ref ref) {
    final argument = this.argument as String;
    return activityItemsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityItemsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activityItemsStreamHash() =>
    r'4f0b46dfabbe0656f1e29e0011a9a18a27be7b5f';

/// Stream of activity items for a specific crew

final class ActivityItemsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ActivityItem>>, String> {
  const ActivityItemsStreamFamily._()
    : super(
        retry: null,
        name: r'activityItemsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream of activity items for a specific crew

  ActivityItemsStreamProvider call(String crewId) =>
      ActivityItemsStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'activityItemsStreamProvider';
}

/// Activity items for a specific crew

@ProviderFor(activityItems)
const activityItemsProvider = ActivityItemsFamily._();

/// Activity items for a specific crew

final class ActivityItemsProvider
    extends
        $FunctionalProvider<
          List<ActivityItem>,
          List<ActivityItem>,
          List<ActivityItem>
        >
    with $Provider<List<ActivityItem>> {
  /// Activity items for a specific crew
  const ActivityItemsProvider._({
    required ActivityItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activityItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activityItemsHash();

  @override
  String toString() {
    return r'activityItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ActivityItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ActivityItem> create(Ref ref) {
    final argument = this.argument as String;
    return activityItems(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ActivityItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ActivityItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activityItemsHash() => r'841e87d99067ed028ea34d09ee152447c18dd9b5';

/// Activity items for a specific crew

final class ActivityItemsFamily extends $Family
    with $FunctionalFamilyOverride<List<ActivityItem>, String> {
  const ActivityItemsFamily._()
    : super(
        retry: null,
        name: r'activityItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Activity items for a specific crew

  ActivityItemsProvider call(String crewId) =>
      ActivityItemsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'activityItemsProvider';
}

/// Stream of tailboard posts for a specific crew

@ProviderFor(tailboardPostsStream)
const tailboardPostsStreamProvider = TailboardPostsStreamFamily._();

/// Stream of tailboard posts for a specific crew

final class TailboardPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TailboardPost>>,
          List<TailboardPost>,
          Stream<List<TailboardPost>>
        >
    with
        $FutureModifier<List<TailboardPost>>,
        $StreamProvider<List<TailboardPost>> {
  /// Stream of tailboard posts for a specific crew
  const TailboardPostsStreamProvider._({
    required TailboardPostsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tailboardPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tailboardPostsStreamHash();

  @override
  String toString() {
    return r'tailboardPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TailboardPost>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TailboardPost>> create(Ref ref) {
    final argument = this.argument as String;
    return tailboardPostsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TailboardPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tailboardPostsStreamHash() =>
    r'6511db6f51b379e6f051201a88c63c719cb953d1';

/// Stream of tailboard posts for a specific crew

final class TailboardPostsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TailboardPost>>, String> {
  const TailboardPostsStreamFamily._()
    : super(
        retry: null,
        name: r'tailboardPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream of tailboard posts for a specific crew

  TailboardPostsStreamProvider call(String crewId) =>
      TailboardPostsStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'tailboardPostsStreamProvider';
}

/// Tailboard posts for a specific crew

@ProviderFor(tailboardPosts)
const tailboardPostsProvider = TailboardPostsFamily._();

/// Tailboard posts for a specific crew

final class TailboardPostsProvider
    extends
        $FunctionalProvider<
          List<TailboardPost>,
          List<TailboardPost>,
          List<TailboardPost>
        >
    with $Provider<List<TailboardPost>> {
  /// Tailboard posts for a specific crew
  const TailboardPostsProvider._({
    required TailboardPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tailboardPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tailboardPostsHash();

  @override
  String toString() {
    return r'tailboardPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TailboardPost>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TailboardPost> create(Ref ref) {
    final argument = this.argument as String;
    return tailboardPosts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TailboardPost> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TailboardPost>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TailboardPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tailboardPostsHash() => r'f1c16958095d817e1fac103fca5b586b9945b807';

/// Tailboard posts for a specific crew

final class TailboardPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<TailboardPost>, String> {
  const TailboardPostsFamily._()
    : super(
        retry: null,
        name: r'tailboardPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tailboard posts for a specific crew

  TailboardPostsProvider call(String crewId) =>
      TailboardPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'tailboardPostsProvider';
}

/// Provider to get unread activity items count for current user

@ProviderFor(unreadActivityCount)
const unreadActivityCountProvider = UnreadActivityCountFamily._();

/// Provider to get unread activity items count for current user

final class UnreadActivityCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get unread activity items count for current user
  const UnreadActivityCountProvider._({
    required UnreadActivityCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'unreadActivityCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unreadActivityCountHash();

  @override
  String toString() {
    return r'unreadActivityCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return unreadActivityCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadActivityCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadActivityCountHash() =>
    r'86d9ee11212a452fdb5fff88e495efd4f498e771';

/// Provider to get unread activity items count for current user

final class UnreadActivityCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  const UnreadActivityCountFamily._()
    : super(
        retry: null,
        name: r'unreadActivityCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get unread activity items count for current user

  UnreadActivityCountProvider call(String crewId) =>
      UnreadActivityCountProvider._(argument: crewId, from: this);

  @override
  String toString() => r'unreadActivityCountProvider';
}

/// Provider to get pinned posts for a specific crew

@ProviderFor(pinnedPosts)
const pinnedPostsProvider = PinnedPostsFamily._();

/// Provider to get pinned posts for a specific crew

final class PinnedPostsProvider
    extends
        $FunctionalProvider<
          List<TailboardPost>,
          List<TailboardPost>,
          List<TailboardPost>
        >
    with $Provider<List<TailboardPost>> {
  /// Provider to get pinned posts for a specific crew
  const PinnedPostsProvider._({
    required PinnedPostsFamily super.from,
    required String super.argument,
  }) : super(
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
  $ProviderElement<List<TailboardPost>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TailboardPost> create(Ref ref) {
    final argument = this.argument as String;
    return pinnedPosts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TailboardPost> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TailboardPost>>(value),
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

String _$pinnedPostsHash() => r'336120e1f716c5aa7e15579d9da98744da7959c5';

/// Provider to get pinned posts for a specific crew

final class PinnedPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<TailboardPost>, String> {
  const PinnedPostsFamily._()
    : super(
        retry: null,
        name: r'pinnedPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get pinned posts for a specific crew

  PinnedPostsProvider call(String crewId) =>
      PinnedPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'pinnedPostsProvider';
}

/// Provider to get recent posts (non-pinned) for a specific crew

@ProviderFor(recentPosts)
const recentPostsProvider = RecentPostsFamily._();

/// Provider to get recent posts (non-pinned) for a specific crew

final class RecentPostsProvider
    extends
        $FunctionalProvider<
          List<TailboardPost>,
          List<TailboardPost>,
          List<TailboardPost>
        >
    with $Provider<List<TailboardPost>> {
  /// Provider to get recent posts (non-pinned) for a specific crew
  const RecentPostsProvider._({
    required RecentPostsFamily super.from,
    required String super.argument,
  }) : super(
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
  $ProviderElement<List<TailboardPost>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TailboardPost> create(Ref ref) {
    final argument = this.argument as String;
    return recentPosts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TailboardPost> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TailboardPost>>(value),
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

String _$recentPostsHash() => r'c18014a0c38466a58c9485731b0bd79a8d371734';

/// Provider to get recent posts (non-pinned) for a specific crew

final class RecentPostsFamily extends $Family
    with $FunctionalFamilyOverride<List<TailboardPost>, String> {
  const RecentPostsFamily._()
    : super(
        retry: null,
        name: r'recentPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get recent posts (non-pinned) for a specific crew

  RecentPostsProvider call(String crewId) =>
      RecentPostsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'recentPostsProvider';
}

/// Provider to get posts by a specific author

@ProviderFor(postsByAuthor)
const postsByAuthorProvider = PostsByAuthorFamily._();

/// Provider to get posts by a specific author

final class PostsByAuthorProvider
    extends
        $FunctionalProvider<
          List<TailboardPost>,
          List<TailboardPost>,
          List<TailboardPost>
        >
    with $Provider<List<TailboardPost>> {
  /// Provider to get posts by a specific author
  const PostsByAuthorProvider._({
    required PostsByAuthorFamily super.from,
    required (String, String) super.argument,
  }) : super(
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
  $ProviderElement<List<TailboardPost>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TailboardPost> create(Ref ref) {
    final argument = this.argument as (String, String);
    return postsByAuthor(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TailboardPost> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TailboardPost>>(value),
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

String _$postsByAuthorHash() => r'771cd1e79ae78e8b225cc3774e273552009c1b12';

/// Provider to get posts by a specific author

final class PostsByAuthorFamily extends $Family
    with $FunctionalFamilyOverride<List<TailboardPost>, (String, String)> {
  const PostsByAuthorFamily._()
    : super(
        retry: null,
        name: r'postsByAuthorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get posts by a specific author

  PostsByAuthorProvider call(String crewId, String authorId) =>
      PostsByAuthorProvider._(argument: (crewId, authorId), from: this);

  @override
  String toString() => r'postsByAuthorProvider';
}

/// Provider to get suggested jobs with high match score (>70)

@ProviderFor(highMatchJobs)
const highMatchJobsProvider = HighMatchJobsFamily._();

/// Provider to get suggested jobs with high match score (>70)

final class HighMatchJobsProvider
    extends
        $FunctionalProvider<
          List<SuggestedJob>,
          List<SuggestedJob>,
          List<SuggestedJob>
        >
    with $Provider<List<SuggestedJob>> {
  /// Provider to get suggested jobs with high match score (>70)
  const HighMatchJobsProvider._({
    required HighMatchJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'highMatchJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$highMatchJobsHash();

  @override
  String toString() {
    return r'highMatchJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<SuggestedJob>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SuggestedJob> create(Ref ref) {
    final argument = this.argument as String;
    return highMatchJobs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SuggestedJob> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SuggestedJob>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HighMatchJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$highMatchJobsHash() => r'788c29e47c6777d56f85bdb9e02bf5131067ed8a';

/// Provider to get suggested jobs with high match score (>70)

final class HighMatchJobsFamily extends $Family
    with $FunctionalFamilyOverride<List<SuggestedJob>, String> {
  const HighMatchJobsFamily._()
    : super(
        retry: null,
        name: r'highMatchJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get suggested jobs with high match score (>70)

  HighMatchJobsProvider call(String crewId) =>
      HighMatchJobsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'highMatchJobsProvider';
}

/// Provider to get jobs not yet viewed by current user

@ProviderFor(unviewedJobs)
const unviewedJobsProvider = UnviewedJobsFamily._();

/// Provider to get jobs not yet viewed by current user

final class UnviewedJobsProvider
    extends
        $FunctionalProvider<
          List<SuggestedJob>,
          List<SuggestedJob>,
          List<SuggestedJob>
        >
    with $Provider<List<SuggestedJob>> {
  /// Provider to get jobs not yet viewed by current user
  const UnviewedJobsProvider._({
    required UnviewedJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'unviewedJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unviewedJobsHash();

  @override
  String toString() {
    return r'unviewedJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<SuggestedJob>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SuggestedJob> create(Ref ref) {
    final argument = this.argument as String;
    return unviewedJobs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SuggestedJob> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SuggestedJob>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnviewedJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unviewedJobsHash() => r'32bdb1addbfa5dee81dbe5779fd268c4ecb0bace';

/// Provider to get jobs not yet viewed by current user

final class UnviewedJobsFamily extends $Family
    with $FunctionalFamilyOverride<List<SuggestedJob>, String> {
  const UnviewedJobsFamily._()
    : super(
        retry: null,
        name: r'unviewedJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get jobs not yet viewed by current user

  UnviewedJobsProvider call(String crewId) =>
      UnviewedJobsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'unviewedJobsProvider';
}

/// Provider to get jobs applied by crew members

@ProviderFor(appliedJobs)
const appliedJobsProvider = AppliedJobsFamily._();

/// Provider to get jobs applied by crew members

final class AppliedJobsProvider
    extends
        $FunctionalProvider<
          List<SuggestedJob>,
          List<SuggestedJob>,
          List<SuggestedJob>
        >
    with $Provider<List<SuggestedJob>> {
  /// Provider to get jobs applied by crew members
  const AppliedJobsProvider._({
    required AppliedJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'appliedJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appliedJobsHash();

  @override
  String toString() {
    return r'appliedJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<SuggestedJob>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SuggestedJob> create(Ref ref) {
    final argument = this.argument as String;
    return appliedJobs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SuggestedJob> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SuggestedJob>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppliedJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appliedJobsHash() => r'eca87aec178f86e2122d5351e5bdc06a14180fd7';

/// Provider to get jobs applied by crew members

final class AppliedJobsFamily extends $Family
    with $FunctionalFamilyOverride<List<SuggestedJob>, String> {
  const AppliedJobsFamily._()
    : super(
        retry: null,
        name: r'appliedJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get jobs applied by crew members

  AppliedJobsProvider call(String crewId) =>
      AppliedJobsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'appliedJobsProvider';
}

/// Provider to get tailboard analytics

@ProviderFor(tailboardAnalytics)
const tailboardAnalyticsProvider = TailboardAnalyticsFamily._();

/// Provider to get tailboard analytics

final class TailboardAnalyticsProvider
    extends
        $FunctionalProvider<
          TailboardAnalytics?,
          TailboardAnalytics?,
          TailboardAnalytics?
        >
    with $Provider<TailboardAnalytics?> {
  /// Provider to get tailboard analytics
  const TailboardAnalyticsProvider._({
    required TailboardAnalyticsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tailboardAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tailboardAnalyticsHash();

  @override
  String toString() {
    return r'tailboardAnalyticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TailboardAnalytics?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TailboardAnalytics? create(Ref ref) {
    final argument = this.argument as String;
    return tailboardAnalytics(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TailboardAnalytics? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TailboardAnalytics?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TailboardAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tailboardAnalyticsHash() =>
    r'4ce2612a24e7d86f013bc66c5b3b3dc44f354bcf';

/// Provider to get tailboard analytics

final class TailboardAnalyticsFamily extends $Family
    with $FunctionalFamilyOverride<TailboardAnalytics?, String> {
  const TailboardAnalyticsFamily._()
    : super(
        retry: null,
        name: r'tailboardAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get tailboard analytics

  TailboardAnalyticsProvider call(String crewId) =>
      TailboardAnalyticsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'tailboardAnalyticsProvider';
}

/// Provider to get tailboard engagement rate

@ProviderFor(engagementRate)
const engagementRateProvider = EngagementRateFamily._();

/// Provider to get tailboard engagement rate

final class EngagementRateProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider to get tailboard engagement rate
  const EngagementRateProvider._({
    required EngagementRateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'engagementRateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$engagementRateHash();

  @override
  String toString() {
    return r'engagementRateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return engagementRate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EngagementRateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$engagementRateHash() => r'e25abfa2815ce7fcbc775eccc2c72cd8c4b11f26';

/// Provider to get tailboard engagement rate

final class EngagementRateFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  const EngagementRateFamily._()
    : super(
        retry: null,
        name: r'engagementRateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get tailboard engagement rate

  EngagementRateProvider call(String crewId) =>
      EngagementRateProvider._(argument: crewId, from: this);

  @override
  String toString() => r'engagementRateProvider';
}

/// Provider to get total posts count

@ProviderFor(totalPostsCount)
const totalPostsCountProvider = TotalPostsCountFamily._();

/// Provider to get total posts count

final class TotalPostsCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get total posts count
  const TotalPostsCountProvider._({
    required TotalPostsCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalPostsCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalPostsCountHash();

  @override
  String toString() {
    return r'totalPostsCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return totalPostsCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TotalPostsCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalPostsCountHash() => r'517d94ff86cc487db7560fd04565ccac56cae564';

/// Provider to get total posts count

final class TotalPostsCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  const TotalPostsCountFamily._()
    : super(
        retry: null,
        name: r'totalPostsCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get total posts count

  TotalPostsCountProvider call(String crewId) =>
      TotalPostsCountProvider._(argument: crewId, from: this);

  @override
  String toString() => r'totalPostsCountProvider';
}

/// Provider to get total activities count

@ProviderFor(totalActivitiesCount)
const totalActivitiesCountProvider = TotalActivitiesCountFamily._();

/// Provider to get total activities count

final class TotalActivitiesCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get total activities count
  const TotalActivitiesCountProvider._({
    required TotalActivitiesCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalActivitiesCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalActivitiesCountHash();

  @override
  String toString() {
    return r'totalActivitiesCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return totalActivitiesCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TotalActivitiesCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalActivitiesCountHash() =>
    r'a1f66d01b1eb183fe804f94f6eef7add1d72dbe9';

/// Provider to get total activities count

final class TotalActivitiesCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  const TotalActivitiesCountFamily._()
    : super(
        retry: null,
        name: r'totalActivitiesCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get total activities count

  TotalActivitiesCountProvider call(String crewId) =>
      TotalActivitiesCountProvider._(argument: crewId, from: this);

  @override
  String toString() => r'totalActivitiesCountProvider';
}

/// Provider to get total suggested jobs count

@ProviderFor(totalSuggestedJobsCount)
const totalSuggestedJobsCountProvider = TotalSuggestedJobsCountFamily._();

/// Provider to get total suggested jobs count

final class TotalSuggestedJobsCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get total suggested jobs count
  const TotalSuggestedJobsCountProvider._({
    required TotalSuggestedJobsCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalSuggestedJobsCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalSuggestedJobsCountHash();

  @override
  String toString() {
    return r'totalSuggestedJobsCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return totalSuggestedJobsCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TotalSuggestedJobsCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalSuggestedJobsCountHash() =>
    r'39a4c54679855d9039c9841e321f8bef2a0f425e';

/// Provider to get total suggested jobs count

final class TotalSuggestedJobsCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  const TotalSuggestedJobsCountFamily._()
    : super(
        retry: null,
        name: r'totalSuggestedJobsCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get total suggested jobs count

  TotalSuggestedJobsCountProvider call(String crewId) =>
      TotalSuggestedJobsCountProvider._(argument: crewId, from: this);

  @override
  String toString() => r'totalSuggestedJobsCountProvider';
}

/// Provider to check if tailboard is loaded

@ProviderFor(isTailboardLoaded)
const isTailboardLoadedProvider = IsTailboardLoadedFamily._();

/// Provider to check if tailboard is loaded

final class IsTailboardLoadedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if tailboard is loaded
  const IsTailboardLoadedProvider._({
    required IsTailboardLoadedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isTailboardLoadedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isTailboardLoadedHash();

  @override
  String toString() {
    return r'isTailboardLoadedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isTailboardLoaded(ref, argument);
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
    return other is IsTailboardLoadedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isTailboardLoadedHash() => r'8fa28e30ff5816ed31611c8aba883a0ac8867a17';

/// Provider to check if tailboard is loaded

final class IsTailboardLoadedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsTailboardLoadedFamily._()
    : super(
        retry: null,
        name: r'isTailboardLoadedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to check if tailboard is loaded

  IsTailboardLoadedProvider call(String crewId) =>
      IsTailboardLoadedProvider._(argument: crewId, from: this);

  @override
  String toString() => r'isTailboardLoadedProvider';
}

/// Provider to get last updated timestamp

@ProviderFor(tailboardLastUpdated)
const tailboardLastUpdatedProvider = TailboardLastUpdatedFamily._();

/// Provider to get last updated timestamp

final class TailboardLastUpdatedProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// Provider to get last updated timestamp
  const TailboardLastUpdatedProvider._({
    required TailboardLastUpdatedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tailboardLastUpdatedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tailboardLastUpdatedHash();

  @override
  String toString() {
    return r'tailboardLastUpdatedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    final argument = this.argument as String;
    return tailboardLastUpdated(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TailboardLastUpdatedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tailboardLastUpdatedHash() =>
    r'8f25d27b5c7b35f738b71963e4ef1d160d7c7d37';

/// Provider to get last updated timestamp

final class TailboardLastUpdatedFamily extends $Family
    with $FunctionalFamilyOverride<DateTime?, String> {
  const TailboardLastUpdatedFamily._()
    : super(
        retry: null,
        name: r'tailboardLastUpdatedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get last updated timestamp

  TailboardLastUpdatedProvider call(String crewId) =>
      TailboardLastUpdatedProvider._(argument: crewId, from: this);

  @override
  String toString() => r'tailboardLastUpdatedProvider';
}

/// Provider to get crew calendar

@ProviderFor(crewCalendar)
const crewCalendarProvider = CrewCalendarFamily._();

/// Provider to get crew calendar

final class CrewCalendarProvider
    extends $FunctionalProvider<CrewCalendar?, CrewCalendar?, CrewCalendar?>
    with $Provider<CrewCalendar?> {
  /// Provider to get crew calendar
  const CrewCalendarProvider._({
    required CrewCalendarFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crewCalendarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crewCalendarHash();

  @override
  String toString() {
    return r'crewCalendarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CrewCalendar?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrewCalendar? create(Ref ref) {
    final argument = this.argument as String;
    return crewCalendar(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrewCalendar? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrewCalendar?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewCalendarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewCalendarHash() => r'9b3d4ffdf2d6a6ed1f2edcc07e980ef8f5cb7e8f';

/// Provider to get crew calendar

final class CrewCalendarFamily extends $Family
    with $FunctionalFamilyOverride<CrewCalendar?, String> {
  const CrewCalendarFamily._()
    : super(
        retry: null,
        name: r'crewCalendarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get crew calendar

  CrewCalendarProvider call(String crewId) =>
      CrewCalendarProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewCalendarProvider';
}

/// Provider to get recent messages

@ProviderFor(recentMessages)
const recentMessagesProvider = RecentMessagesFamily._();

/// Provider to get recent messages

final class RecentMessagesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Provider to get recent messages
  const RecentMessagesProvider._({
    required RecentMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recentMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentMessagesHash();

  @override
  String toString() {
    return r'recentMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    final argument = this.argument as String;
    return recentMessages(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecentMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentMessagesHash() => r'd62a6143bf8668517e0923ee013ecea78df28fa2';

/// Provider to get recent messages

final class RecentMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<String>, String> {
  const RecentMessagesFamily._()
    : super(
        retry: null,
        name: r'recentMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get recent messages

  RecentMessagesProvider call(String crewId) =>
      RecentMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'recentMessagesProvider';
}

/// Provider to get activity by type

@ProviderFor(activitiesByType)
const activitiesByTypeProvider = ActivitiesByTypeFamily._();

/// Provider to get activity by type

final class ActivitiesByTypeProvider
    extends
        $FunctionalProvider<
          List<ActivityItem>,
          List<ActivityItem>,
          List<ActivityItem>
        >
    with $Provider<List<ActivityItem>> {
  /// Provider to get activity by type
  const ActivitiesByTypeProvider._({
    required ActivitiesByTypeFamily super.from,
    required (String, ActivityType) super.argument,
  }) : super(
         retry: null,
         name: r'activitiesByTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activitiesByTypeHash();

  @override
  String toString() {
    return r'activitiesByTypeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<ActivityItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ActivityItem> create(Ref ref) {
    final argument = this.argument as (String, ActivityType);
    return activitiesByType(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ActivityItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ActivityItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActivitiesByTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activitiesByTypeHash() => r'cbd0752e4336650f5453e86d9befc0ec3992b696';

/// Provider to get activity by type

final class ActivitiesByTypeFamily extends $Family
    with $FunctionalFamilyOverride<List<ActivityItem>, (String, ActivityType)> {
  const ActivitiesByTypeFamily._()
    : super(
        retry: null,
        name: r'activitiesByTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get activity by type

  ActivitiesByTypeProvider call(String crewId, ActivityType type) =>
      ActivitiesByTypeProvider._(argument: (crewId, type), from: this);

  @override
  String toString() => r'activitiesByTypeProvider';
}

/// Provider to get recent activities (last 7 days)

@ProviderFor(recentActivities)
const recentActivitiesProvider = RecentActivitiesFamily._();

/// Provider to get recent activities (last 7 days)

final class RecentActivitiesProvider
    extends
        $FunctionalProvider<
          List<ActivityItem>,
          List<ActivityItem>,
          List<ActivityItem>
        >
    with $Provider<List<ActivityItem>> {
  /// Provider to get recent activities (last 7 days)
  const RecentActivitiesProvider._({
    required RecentActivitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recentActivitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentActivitiesHash();

  @override
  String toString() {
    return r'recentActivitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ActivityItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ActivityItem> create(Ref ref) {
    final argument = this.argument as String;
    return recentActivities(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ActivityItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ActivityItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecentActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentActivitiesHash() => r'c82c70514c85fd9e205c2b408559a4eabf901cc4';

/// Provider to get recent activities (last 7 days)

final class RecentActivitiesFamily extends $Family
    with $FunctionalFamilyOverride<List<ActivityItem>, String> {
  const RecentActivitiesFamily._()
    : super(
        retry: null,
        name: r'recentActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get recent activities (last 7 days)

  RecentActivitiesProvider call(String crewId) =>
      RecentActivitiesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'recentActivitiesProvider';
}

/// Provider to get activities by actor

@ProviderFor(activitiesByActor)
const activitiesByActorProvider = ActivitiesByActorFamily._();

/// Provider to get activities by actor

final class ActivitiesByActorProvider
    extends
        $FunctionalProvider<
          List<ActivityItem>,
          List<ActivityItem>,
          List<ActivityItem>
        >
    with $Provider<List<ActivityItem>> {
  /// Provider to get activities by actor
  const ActivitiesByActorProvider._({
    required ActivitiesByActorFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'activitiesByActorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activitiesByActorHash();

  @override
  String toString() {
    return r'activitiesByActorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<ActivityItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ActivityItem> create(Ref ref) {
    final argument = this.argument as (String, String);
    return activitiesByActor(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ActivityItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ActivityItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActivitiesByActorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activitiesByActorHash() => r'ab85fe28f6de78ca59f115ebcdcca1e28ecf5de7';

/// Provider to get activities by actor

final class ActivitiesByActorFamily extends $Family
    with $FunctionalFamilyOverride<List<ActivityItem>, (String, String)> {
  const ActivitiesByActorFamily._()
    : super(
        retry: null,
        name: r'activitiesByActorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get activities by actor

  ActivitiesByActorProvider call(String crewId, String actorId) =>
      ActivitiesByActorProvider._(argument: (crewId, actorId), from: this);

  @override
  String toString() => r'activitiesByActorProvider';
}
