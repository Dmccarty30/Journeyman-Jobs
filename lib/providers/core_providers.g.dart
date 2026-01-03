// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityService)
final connectivityServiceProvider = ConnectivityServiceProvider._();

final class ConnectivityServiceProvider extends $FunctionalProvider<
    ConnectivityService,
    ConnectivityService,
    ConnectivityService> with $Provider<ConnectivityService> {
  ConnectivityServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'727a38c43053e3ab88d851490a50df4cabdeb29e';

@ProviderFor(FeedPostsNotifier)
final feedPostsProvider = FeedPostsNotifierFamily._();

final class FeedPostsNotifierProvider
    extends $AsyncNotifierProvider<FeedPostsNotifier, List<TailboardPost>> {
  FeedPostsNotifierProvider._(
      {required FeedPostsNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'feedPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedPostsNotifierHash();

  @override
  String toString() {
    return r'feedPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FeedPostsNotifier create() => FeedPostsNotifier();

  @override
  bool operator ==(Object other) {
    return other is FeedPostsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedPostsNotifierHash() => r'c28ccdb46569c46d1177d5733299f6ae3673d39f';

final class FeedPostsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<FeedPostsNotifier, AsyncValue<List<TailboardPost>>,
            List<TailboardPost>, FutureOr<List<TailboardPost>>, String> {
  FeedPostsNotifierFamily._()
      : super(
          retry: null,
          name: r'feedPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FeedPostsNotifierProvider call(
    String crewId,
  ) =>
      FeedPostsNotifierProvider._(argument: crewId, from: this);

  @override
  String toString() => r'feedPostsProvider';
}

abstract class _$FeedPostsNotifier extends $AsyncNotifier<List<TailboardPost>> {
  late final _$args = ref.$arg as String;
  String get crewId => _$args;

  FutureOr<List<TailboardPost>> build(
    String crewId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TailboardPost>>, List<TailboardPost>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TailboardPost>>, List<TailboardPost>>,
        AsyncValue<List<TailboardPost>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(JobsNotifier)
final jobsProvider = JobsNotifierFamily._();

final class JobsNotifierProvider
    extends $AsyncNotifierProvider<JobsNotifier, List<Job>> {
  JobsNotifierProvider._(
      {required JobsNotifierFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'jobsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobsNotifierHash();

  @override
  String toString() {
    return r'jobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JobsNotifier create() => JobsNotifier();

  @override
  bool operator ==(Object other) {
    return other is JobsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobsNotifierHash() => r'66820b3d77a6373e2f16bcab44b22069d660e4ec';

final class JobsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<JobsNotifier, AsyncValue<List<Job>>, List<Job>,
            FutureOr<List<Job>>, String> {
  JobsNotifierFamily._()
      : super(
          retry: null,
          name: r'jobsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  JobsNotifierProvider call(
    String crewId,
  ) =>
      JobsNotifierProvider._(argument: crewId, from: this);

  @override
  String toString() => r'jobsProvider';
}

abstract class _$JobsNotifier extends $AsyncNotifier<List<Job>> {
  late final _$args = ref.$arg as String;
  String get crewId => _$args;

  FutureOr<List<Job>> build(
    String crewId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Job>>, List<Job>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Job>>, List<Job>>,
        AsyncValue<List<Job>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
