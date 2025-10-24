// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the GoRouter instance with auth state reactivity.
///
/// This provider creates a router that automatically refreshes when
/// auth state or onboarding status changes, ensuring navigation guards
/// always have up-to-date authentication information.

@ProviderFor(router)
const routerProvider = RouterProvider._();

/// Provider for the GoRouter instance with auth state reactivity.
///
/// This provider creates a router that automatically refreshes when
/// auth state or onboarding status changes, ensuring navigation guards
/// always have up-to-date authentication information.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provider for the GoRouter instance with auth state reactivity.
  ///
  /// This provider creates a router that automatically refreshes when
  /// auth state or onboarding status changes, ensuring navigation guards
  /// always have up-to-date authentication information.
  const RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'7fe58ac51785922383e2b6ac0397067c4501ea3d';
