// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_job_preference_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userPreferenceService)
final userPreferenceServiceProvider = UserPreferenceServiceProvider._();

final class UserPreferenceServiceProvider extends $FunctionalProvider<
    UserPreferenceService,
    UserPreferenceService,
    UserPreferenceService> with $Provider<UserPreferenceService> {
  UserPreferenceServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userPreferenceServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPreferenceServiceHash();

  @$internal
  @override
  $ProviderElement<UserPreferenceService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserPreferenceService create(Ref ref) {
    return userPreferenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPreferenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPreferenceService>(value),
    );
  }
}

String _$userPreferenceServiceHash() =>
    r'bf6ee94d25ddb4c5eee685c208a24a008aaf1ca0';

@ProviderFor(firestoreService)
final firestoreServiceProvider = FirestoreServiceProvider._();

final class FirestoreServiceProvider extends $FunctionalProvider<
    ResilientFirestoreService,
    ResilientFirestoreService,
    ResilientFirestoreService> with $Provider<ResilientFirestoreService> {
  FirestoreServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firestoreServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firestoreServiceHash();

  @$internal
  @override
  $ProviderElement<ResilientFirestoreService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResilientFirestoreService create(Ref ref) {
    return firestoreService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResilientFirestoreService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResilientFirestoreService>(value),
    );
  }
}

String _$firestoreServiceHash() => r'c0a202938a21d2841685ee5eb2f0045d9baa2511';

@ProviderFor(userJobFilterCriteria)
final userJobFilterCriteriaProvider = UserJobFilterCriteriaProvider._();

final class UserJobFilterCriteriaProvider extends $FunctionalProvider<
        AsyncValue<JobFilterCriteria>,
        JobFilterCriteria,
        FutureOr<JobFilterCriteria>>
    with
        $FutureModifier<JobFilterCriteria>,
        $FutureProvider<JobFilterCriteria> {
  UserJobFilterCriteriaProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userJobFilterCriteriaProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userJobFilterCriteriaHash();

  @$internal
  @override
  $FutureProviderElement<JobFilterCriteria> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<JobFilterCriteria> create(Ref ref) {
    return userJobFilterCriteria(ref);
  }
}

String _$userJobFilterCriteriaHash() =>
    r'0e3681801678578c910ee7220859e2fe534d6391';

@ProviderFor(userPreferredJobs)
final userPreferredJobsProvider = UserPreferredJobsProvider._();

final class UserPreferredJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  UserPreferredJobsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userPreferredJobsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPreferredJobsHash();

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    return userPreferredJobs(ref);
  }
}

String _$userPreferredJobsHash() => r'4adfafba749f87a995197a1ab1fa4915250fe9ab';
