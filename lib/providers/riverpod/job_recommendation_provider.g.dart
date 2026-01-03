// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_recommendation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionService)
final subscriptionServiceProvider = SubscriptionServiceProvider._();

final class SubscriptionServiceProvider extends $FunctionalProvider<
    SubscriptionService,
    SubscriptionService,
    SubscriptionService> with $Provider<SubscriptionService> {
  SubscriptionServiceProvider._()
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
    r'08f145933608d07f7d311b22eb1df6ac2cf92f58';

@ProviderFor(jobRecommendations)
final jobRecommendationsProvider = JobRecommendationsProvider._();

final class JobRecommendationsProvider extends $FunctionalProvider<
        AsyncValue<List<JobSuggestion>>,
        List<JobSuggestion>,
        FutureOr<List<JobSuggestion>>>
    with
        $FutureModifier<List<JobSuggestion>>,
        $FutureProvider<List<JobSuggestion>> {
  JobRecommendationsProvider._()
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
    r'ab772d6821e02bd06014ba5eda5c92f0f906e381';
