// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_job_preference_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userPreferenceService)
const userPreferenceServiceProvider = UserPreferenceServiceProvider._();

final class UserPreferenceServiceProvider extends $FunctionalProvider<
    UserPreferenceService,
    UserPreferenceService,
    UserPreferenceService> with $Provider<UserPreferenceService> {
  const UserPreferenceServiceProvider._()
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
    r'a3c54d242c92dccfe16fbd595ee3e488f872bd43';

@ProviderFor(firestoreService)
const firestoreServiceProvider = FirestoreServiceProvider._();

final class FirestoreServiceProvider extends $FunctionalProvider<
    ResilientFirestoreService,
    ResilientFirestoreService,
    ResilientFirestoreService> with $Provider<ResilientFirestoreService> {
  const FirestoreServiceProvider._()
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

String _$firestoreServiceHash() => r'46e745ea8c8e666283f2656685cd1c439659b1ee';

@ProviderFor(userJobFilterCriteria)
const userJobFilterCriteriaProvider = UserJobFilterCriteriaProvider._();

final class UserJobFilterCriteriaProvider extends $FunctionalProvider<
        AsyncValue<JobFilterCriteria>,
        JobFilterCriteria,
        FutureOr<JobFilterCriteria>>
    with
        $FutureModifier<JobFilterCriteria>,
        $FutureProvider<JobFilterCriteria> {
  const UserJobFilterCriteriaProvider._()
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
    r'100c1b8c152d179630ba27d32daa3fec71910059';

@ProviderFor(userPreferredJobs)
const userPreferredJobsProvider = UserPreferredJobsProvider._();

final class UserPreferredJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  const UserPreferredJobsProvider._()
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

String _$userPreferredJobsHash() => r'4c05bc682eaf5a7299310caefc293500b45157ab';
