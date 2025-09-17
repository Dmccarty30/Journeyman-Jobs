// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$crewServiceHash() => r'ebf061f82598b90e125e0d5cc0e48a060862815b';

/// Provider for CrewService instance
///
/// Copied from [crewService].
@ProviderFor(crewService)
final crewServiceProvider = AutoDisposeProvider<CrewService>.internal(
  crewService,
  name: r'crewServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$crewServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewServiceRef = AutoDisposeProviderRef<CrewService>;
String _$userCrewsStreamHash() => r'df8a3a8983fc0b270bfeeefcfb105d2857692238';

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

/// Provider for user's crews stream
///
/// Copied from [userCrewsStream].
@ProviderFor(userCrewsStream)
const userCrewsStreamProvider = UserCrewsStreamFamily();

/// Provider for user's crews stream
///
/// Copied from [userCrewsStream].
class UserCrewsStreamFamily extends Family<AsyncValue<List<Crew>>> {
  /// Provider for user's crews stream
  ///
  /// Copied from [userCrewsStream].
  const UserCrewsStreamFamily();

  /// Provider for user's crews stream
  ///
  /// Copied from [userCrewsStream].
  UserCrewsStreamProvider call(
    String userId,
  ) {
    return UserCrewsStreamProvider(
      userId,
    );
  }

  @override
  UserCrewsStreamProvider getProviderOverride(
    covariant UserCrewsStreamProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userCrewsStreamProvider';
}

/// Provider for user's crews stream
///
/// Copied from [userCrewsStream].
class UserCrewsStreamProvider extends AutoDisposeStreamProvider<List<Crew>> {
  /// Provider for user's crews stream
  ///
  /// Copied from [userCrewsStream].
  UserCrewsStreamProvider(
    String userId,
  ) : this._internal(
          (ref) => userCrewsStream(
            ref as UserCrewsStreamRef,
            userId,
          ),
          from: userCrewsStreamProvider,
          name: r'userCrewsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userCrewsStreamHash,
          dependencies: UserCrewsStreamFamily._dependencies,
          allTransitiveDependencies:
              UserCrewsStreamFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserCrewsStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<Crew>> Function(UserCrewsStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserCrewsStreamProvider._internal(
        (ref) => create(ref as UserCrewsStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Crew>> createElement() {
    return _UserCrewsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserCrewsStreamProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserCrewsStreamRef on AutoDisposeStreamProviderRef<List<Crew>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserCrewsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Crew>>
    with UserCrewsStreamRef {
  _UserCrewsStreamProviderElement(super.provider);

  @override
  String get userId => (origin as UserCrewsStreamProvider).userId;
}

String _$crewStreamHash() => r'9db6f69c3b9fe53e3aeabd49db41998ef8f90af1';

/// Provider for specific crew stream
///
/// Copied from [crewStream].
@ProviderFor(crewStream)
const crewStreamProvider = CrewStreamFamily();

/// Provider for specific crew stream
///
/// Copied from [crewStream].
class CrewStreamFamily extends Family<AsyncValue<Crew?>> {
  /// Provider for specific crew stream
  ///
  /// Copied from [crewStream].
  const CrewStreamFamily();

  /// Provider for specific crew stream
  ///
  /// Copied from [crewStream].
  CrewStreamProvider call(
    String crewId,
  ) {
    return CrewStreamProvider(
      crewId,
    );
  }

  @override
  CrewStreamProvider getProviderOverride(
    covariant CrewStreamProvider provider,
  ) {
    return call(
      provider.crewId,
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
  String? get name => r'crewStreamProvider';
}

/// Provider for specific crew stream
///
/// Copied from [crewStream].
class CrewStreamProvider extends AutoDisposeStreamProvider<Crew?> {
  /// Provider for specific crew stream
  ///
  /// Copied from [crewStream].
  CrewStreamProvider(
    String crewId,
  ) : this._internal(
          (ref) => crewStream(
            ref as CrewStreamRef,
            crewId,
          ),
          from: crewStreamProvider,
          name: r'crewStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$crewStreamHash,
          dependencies: CrewStreamFamily._dependencies,
          allTransitiveDependencies:
              CrewStreamFamily._allTransitiveDependencies,
          crewId: crewId,
        );

  CrewStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.crewId,
  }) : super.internal();

  final String crewId;

  @override
  Override overrideWith(
    Stream<Crew?> Function(CrewStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CrewStreamProvider._internal(
        (ref) => create(ref as CrewStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        crewId: crewId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Crew?> createElement() {
    return _CrewStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewStreamProvider && other.crewId == crewId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, crewId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CrewStreamRef on AutoDisposeStreamProviderRef<Crew?> {
  /// The parameter `crewId` of this provider.
  String get crewId;
}

class _CrewStreamProviderElement extends AutoDisposeStreamProviderElement<Crew?>
    with CrewStreamRef {
  _CrewStreamProviderElement(super.provider);

  @override
  String get crewId => (origin as CrewStreamProvider).crewId;
}

String _$crewMembersStreamHash() => r'10eb9bae7a6a7b2273dc4b38f472f057d19fc8b4';

/// Provider for crew members stream
///
/// Copied from [crewMembersStream].
@ProviderFor(crewMembersStream)
const crewMembersStreamProvider = CrewMembersStreamFamily();

/// Provider for crew members stream
///
/// Copied from [crewMembersStream].
class CrewMembersStreamFamily extends Family<AsyncValue<List<CrewMember>>> {
  /// Provider for crew members stream
  ///
  /// Copied from [crewMembersStream].
  const CrewMembersStreamFamily();

  /// Provider for crew members stream
  ///
  /// Copied from [crewMembersStream].
  CrewMembersStreamProvider call(
    String crewId,
  ) {
    return CrewMembersStreamProvider(
      crewId,
    );
  }

  @override
  CrewMembersStreamProvider getProviderOverride(
    covariant CrewMembersStreamProvider provider,
  ) {
    return call(
      provider.crewId,
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
  String? get name => r'crewMembersStreamProvider';
}

/// Provider for crew members stream
///
/// Copied from [crewMembersStream].
class CrewMembersStreamProvider
    extends AutoDisposeStreamProvider<List<CrewMember>> {
  /// Provider for crew members stream
  ///
  /// Copied from [crewMembersStream].
  CrewMembersStreamProvider(
    String crewId,
  ) : this._internal(
          (ref) => crewMembersStream(
            ref as CrewMembersStreamRef,
            crewId,
          ),
          from: crewMembersStreamProvider,
          name: r'crewMembersStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$crewMembersStreamHash,
          dependencies: CrewMembersStreamFamily._dependencies,
          allTransitiveDependencies:
              CrewMembersStreamFamily._allTransitiveDependencies,
          crewId: crewId,
        );

  CrewMembersStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.crewId,
  }) : super.internal();

  final String crewId;

  @override
  Override overrideWith(
    Stream<List<CrewMember>> Function(CrewMembersStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CrewMembersStreamProvider._internal(
        (ref) => create(ref as CrewMembersStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        crewId: crewId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CrewMember>> createElement() {
    return _CrewMembersStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMembersStreamProvider && other.crewId == crewId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, crewId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CrewMembersStreamRef on AutoDisposeStreamProviderRef<List<CrewMember>> {
  /// The parameter `crewId` of this provider.
  String get crewId;
}

class _CrewMembersStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<CrewMember>>
    with CrewMembersStreamRef {
  _CrewMembersStreamProviderElement(super.provider);

  @override
  String get crewId => (origin as CrewMembersStreamProvider).crewId;
}

String _$userCrewCountHash() => r'c2419c35e59d2b005ffc45712f1e3909ed62ae1f';

/// Provider for user's crew count
///
/// Copied from [userCrewCount].
@ProviderFor(userCrewCount)
final userCrewCountProvider = AutoDisposeProvider<int>.internal(
  userCrewCount,
  name: r'userCrewCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userCrewCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserCrewCountRef = AutoDisposeProviderRef<int>;
String _$selectedCrewMemberCountHash() =>
    r'81ab67fc383e194cf5eb6b6bfac5c9e3bc8d31fe';

/// Provider for selected crew member count
///
/// Copied from [selectedCrewMemberCount].
@ProviderFor(selectedCrewMemberCount)
final selectedCrewMemberCountProvider = AutoDisposeProvider<int>.internal(
  selectedCrewMemberCount,
  name: r'selectedCrewMemberCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCrewMemberCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedCrewMemberCountRef = AutoDisposeProviderRef<int>;
String _$canCreateMoreCrewsHash() =>
    r'92fa14989a42dd9a08b7c71abfc945975257aa39';

/// Provider for checking if user can create more crews (max 5)
///
/// Copied from [canCreateMoreCrews].
@ProviderFor(canCreateMoreCrews)
final canCreateMoreCrewsProvider = AutoDisposeProvider<bool>.internal(
  canCreateMoreCrews,
  name: r'canCreateMoreCrewsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canCreateMoreCrewsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanCreateMoreCrewsRef = AutoDisposeProviderRef<bool>;
String _$searchResultsCountHash() =>
    r'd1a2b95e879ce6f2e19abda9f0b97ced45d00c0b';

/// Provider for search results count
///
/// Copied from [searchResultsCount].
@ProviderFor(searchResultsCount)
final searchResultsCountProvider = AutoDisposeProvider<int>.internal(
  searchResultsCount,
  name: r'searchResultsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchResultsCountRef = AutoDisposeProviderRef<int>;
String _$hasActiveCrewSearchHash() =>
    r'ed48d7724f1e0d8939b3f6b349056752bfe21d72';

/// Provider for checking if search is active
///
/// Copied from [hasActiveCrewSearch].
@ProviderFor(hasActiveCrewSearch)
final hasActiveCrewSearchProvider = AutoDisposeProvider<bool>.internal(
  hasActiveCrewSearch,
  name: r'hasActiveCrewSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveCrewSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasActiveCrewSearchRef = AutoDisposeProviderRef<bool>;
String _$crewLoadingHash() => r'9472154d89b540c5a2320a93746e822a5a7132b1';

/// Provider for checking if crew is loading
///
/// Copied from [crewLoading].
@ProviderFor(crewLoading)
final crewLoadingProvider = AutoDisposeProvider<bool>.internal(
  crewLoading,
  name: r'crewLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$crewLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewLoadingRef = AutoDisposeProviderRef<bool>;
String _$crewErrorHash() => r'c01ea59b3393d010dad65ccd79404a327ecccba9';

/// Provider for crew error state
///
/// Copied from [crewError].
@ProviderFor(crewError)
final crewErrorProvider = AutoDisposeProvider<String?>.internal(
  crewError,
  name: r'crewErrorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$crewErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewErrorRef = AutoDisposeProviderRef<String?>;
String _$crewOfflineModeHash() => r'e401171320638f60eba2ffbb5502d79e2cb69ae7';

/// Provider for offline mode status
///
/// Copied from [crewOfflineMode].
@ProviderFor(crewOfflineMode)
final crewOfflineModeProvider = AutoDisposeProvider<bool>.internal(
  crewOfflineMode,
  name: r'crewOfflineModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crewOfflineModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewOfflineModeRef = AutoDisposeProviderRef<bool>;
String _$crewStateNotifierHash() => r'4c4de96469fec61536df70f5f1ca61f9ec8c03f0';

/// Crew state notifier provider
///
/// Copied from [CrewStateNotifier].
@ProviderFor(CrewStateNotifier)
final crewStateNotifierProvider =
    AutoDisposeNotifierProvider<CrewStateNotifier, CrewState>.internal(
  CrewStateNotifier.new,
  name: r'crewStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crewStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CrewStateNotifier = AutoDisposeNotifier<CrewState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
