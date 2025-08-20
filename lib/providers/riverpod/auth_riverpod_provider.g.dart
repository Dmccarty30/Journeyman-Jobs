// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'9f83ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7i';

/// AuthService provider
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = Provider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthServiceRef = ProviderRef<AuthService>;
String _$authStateStreamHash() => r'8e72ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7j';

/// Auth state stream provider
///
/// Copied from [authStateStream].
@ProviderFor(authStateStream)
final authStateStreamProvider = StreamProvider<User?>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateStreamRef = StreamProviderRef<User?>;
String _$currentUserHash() => r'7d61ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7k';

/// Current user provider
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = Provider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = ProviderRef<User?>;
String _$isAuthenticatedHash() => r'6c50ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7l';

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

typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isRouteProtectedHash() => r'5b4fac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7m';

/// Route guard provider
///
/// Copied from [isRouteProtected].
@ProviderFor(isRouteProtected)
final isRouteProtectedProvider = AutoDisposeProviderFamily<bool, String>.internal(
  isRouteProtected,
  name: r'isRouteProtectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isRouteProtectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsRouteProtectedRef = AutoDisposeProviderRef<bool>;
String _$authNotifierHash() => r'4a3eac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7n';

/// Auth state notifier for managing authentication operations
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = Notifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member