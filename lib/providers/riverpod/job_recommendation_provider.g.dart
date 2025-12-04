// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_recommendation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionService)
const subscriptionServiceProvider = SubscriptionServiceProvider._();

final class SubscriptionServiceProvider extends $FunctionalProvider<
    SubscriptionService,
    SubscriptionService,
    SubscriptionService> with $Provider<SubscriptionService> {
  const SubscriptionServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'subscriptionServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subscriptionServiceHash();

  @$internal
  @override
  $ProviderElement<SubscriptionService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SubscriptionService create(Ref ref) {
    return subscriptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionService>(value),
    );
  }
}

String _$subscriptionServiceHash() =>
    r'd0fd84bd363f36d2b1ad5d1e32e2b1006fcfdae1';

@ProviderFor(jobRecommendations)
const jobRecommendationsProvider = JobRecommendationsProvider._();

final class JobRecommendationsProvider extends $FunctionalProvider<
        AsyncValue<List<JobSuggestion>>,
        List<JobSuggestion>,
        FutureOr<List<JobSuggestion>>>
    with
        $FutureModifier<List<JobSuggestion>>,
        $FutureProvider<List<JobSuggestion>> {
  const JobRecommendationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobRecommendationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobRecommendationsHash();

  @$internal
  @override
  $FutureProviderElement<List<JobSuggestion>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<JobSuggestion>> create(Ref ref) {
    return jobRecommendations(ref);
  }
}

String _$jobRecommendationsHash() =>
    r'fc47bb81ee8b4bd11ffe492457748a2166a6311b';
