// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Feed filter notifier with persistence (using Riverpod 3.0 pattern)

@ProviderFor(FeedFilterNotifier)
const feedFilterProvider = FeedFilterNotifierProvider._();

/// Feed filter notifier with persistence (using Riverpod 3.0 pattern)
final class FeedFilterNotifierProvider
    extends $NotifierProvider<FeedFilterNotifier, FeedFilter> {
  /// Feed filter notifier with persistence (using Riverpod 3.0 pattern)
  const FeedFilterNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedFilterNotifierHash();

  @$internal
  @override
  FeedFilterNotifier create() => FeedFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedFilter>(value),
    );
  }
}

String _$feedFilterNotifierHash() =>
    r'5717aff65c85ccae54515766f747065da723a0d0';

/// Feed filter notifier with persistence (using Riverpod 3.0 pattern)

abstract class _$FeedFilterNotifier extends $Notifier<FeedFilter> {
  FeedFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedFilter, FeedFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FeedFilter, FeedFilter>, FeedFilter, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
