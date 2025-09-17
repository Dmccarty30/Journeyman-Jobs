// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'087414bb6bee00d72012934e1a5bee629fc9f82d';

/// AuthService provider
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$authStateStreamHash() => r'1dbee8ac1590937318f7c85a7afb20730f1f4c70';

/// Auth state stream provider
///
/// Copied from [authStateStream].
@ProviderFor(authStateStream)
final authStateStreamProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateStreamRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'2c9954d8e0c05f10e8d7235a732c652026c25f15';

/// Current user provider
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$isAuthenticatedHash() => r'45336f82b98678239b4891278406d2e18cc88e4d';

/// Convenience provider for auth state
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isRouteProtectedHash() => r'49b195b8de0146f75b51ea267a30ee74bb704b5c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Route guard provider
///
/// Copied from [isRouteProtected].
@ProviderFor(isRouteProtected)
const isRouteProtectedProvider = IsRouteProtectedFamily();

/// Route guard provider
///
/// Copied from [isRouteProtected].
class IsRouteProtectedFamily extends Family<bool> {
  /// Route guard provider
  ///
  /// Copied from [isRouteProtected].
  const IsRouteProtectedFamily();

  /// Route guard provider
  ///
  /// Copied from [isRouteProtected].
  IsRouteProtectedProvider call(
    String routePath,
  ) {
    return IsRouteProtectedProvider(
      routePath,
    );
  }

  @override
  IsRouteProtectedProvider getProviderOverride(
    covariant IsRouteProtectedProvider provider,
  ) {
    return call(
      provider.routePath,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isRouteProtectedProvider';
}

/// Route guard provider
///
/// Copied from [isRouteProtected].
class IsRouteProtectedProvider extends AutoDisposeProvider<bool> {
  /// Route guard provider
  ///
  /// Copied from [isRouteProtected].
  IsRouteProtectedProvider(
    String routePath,
  ) : this._internal(
          (ref) => isRouteProtected(
            ref as IsRouteProtectedRef,
            routePath,
          ),
          from: isRouteProtectedProvider,
          name: r'isRouteProtectedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isRouteProtectedHash,
          dependencies: IsRouteProtectedFamily._dependencies,
          allTransitiveDependencies:
              IsRouteProtectedFamily._allTransitiveDependencies,
          routePath: routePath,
        );

  IsRouteProtectedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routePath,
  }) : super.internal();

  final String routePath;

  @override
  Override overrideWith(
    bool Function(IsRouteProtectedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsRouteProtectedProvider._internal(
        (ref) => create(ref as IsRouteProtectedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routePath: routePath,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsRouteProtectedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsRouteProtectedProvider && other.routePath == routePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsRouteProtectedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `routePath` of this provider.
  String get routePath;
}

class _IsRouteProtectedProviderElement extends AutoDisposeProviderElement<bool>
    with IsRouteProtectedRef {
  _IsRouteProtectedProviderElement(super.provider);

  @override
  String get routePath => (origin as IsRouteProtectedProvider).routePath;
}

String _$authNotifierHash() => r'4a5bcff076f36afe85f8cceae95c3b3ae0faac53';

/// Auth state notifier for managing authentication operations
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
