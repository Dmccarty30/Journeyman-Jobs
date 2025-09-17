// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$crewMemberServiceHash() => r'ace5726e547204589b54d4d5e1432471641e5f3c';

/// Provider for CrewMemberService instance
///
/// Copied from [crewMemberService].
@ProviderFor(crewMemberService)
final crewMemberServiceProvider =
    AutoDisposeProvider<CrewMemberService>.internal(
  crewMemberService,
  name: r'crewMemberServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crewMemberServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewMemberServiceRef = AutoDisposeProviderRef<CrewMemberService>;
String _$crewMembersStreamHash() => r'088e161174e65b67dfadae8b741a76a105fba292';

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

/// Provider for crew members by crew ID with real-time updates
///
/// Copied from [crewMembersStream].
@ProviderFor(crewMembersStream)
const crewMembersStreamProvider = CrewMembersStreamFamily();

/// Provider for crew members by crew ID with real-time updates
///
/// Copied from [crewMembersStream].
class CrewMembersStreamFamily extends Family<AsyncValue<List<CrewMember>>> {
  /// Provider for crew members by crew ID with real-time updates
  ///
  /// Copied from [crewMembersStream].
  const CrewMembersStreamFamily();

  /// Provider for crew members by crew ID with real-time updates
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

/// Provider for crew members by crew ID with real-time updates
///
/// Copied from [crewMembersStream].
class CrewMembersStreamProvider
    extends AutoDisposeStreamProvider<List<CrewMember>> {
  /// Provider for crew members by crew ID with real-time updates
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

String _$pendingInvitationsHash() =>
    r'8e207612cc3fc4048ae94564a303ac6cc4214eb2';

/// Provider for pending invitations
///
/// Copied from [pendingInvitations].
@ProviderFor(pendingInvitations)
final pendingInvitationsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  pendingInvitations,
  name: r'pendingInvitationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingInvitationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingInvitationsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$crewMemberDetailsHash() => r'8167fbcdcc3ba3de8264b877cd35b30015d11cfd';

/// Provider for specific crew member details
///
/// Copied from [crewMemberDetails].
@ProviderFor(crewMemberDetails)
const crewMemberDetailsProvider = CrewMemberDetailsFamily();

/// Provider for specific crew member details
///
/// Copied from [crewMemberDetails].
class CrewMemberDetailsFamily extends Family<AsyncValue<CrewMember?>> {
  /// Provider for specific crew member details
  ///
  /// Copied from [crewMemberDetails].
  const CrewMemberDetailsFamily();

  /// Provider for specific crew member details
  ///
  /// Copied from [crewMemberDetails].
  CrewMemberDetailsProvider call(
    String crewId,
    String userId,
  ) {
    return CrewMemberDetailsProvider(
      crewId,
      userId,
    );
  }

  @override
  CrewMemberDetailsProvider getProviderOverride(
    covariant CrewMemberDetailsProvider provider,
  ) {
    return call(
      provider.crewId,
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
  String? get name => r'crewMemberDetailsProvider';
}

/// Provider for specific crew member details
///
/// Copied from [crewMemberDetails].
class CrewMemberDetailsProvider extends AutoDisposeFutureProvider<CrewMember?> {
  /// Provider for specific crew member details
  ///
  /// Copied from [crewMemberDetails].
  CrewMemberDetailsProvider(
    String crewId,
    String userId,
  ) : this._internal(
          (ref) => crewMemberDetails(
            ref as CrewMemberDetailsRef,
            crewId,
            userId,
          ),
          from: crewMemberDetailsProvider,
          name: r'crewMemberDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$crewMemberDetailsHash,
          dependencies: CrewMemberDetailsFamily._dependencies,
          allTransitiveDependencies:
              CrewMemberDetailsFamily._allTransitiveDependencies,
          crewId: crewId,
          userId: userId,
        );

  CrewMemberDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.crewId,
    required this.userId,
  }) : super.internal();

  final String crewId;
  final String userId;

  @override
  Override overrideWith(
    FutureOr<CrewMember?> Function(CrewMemberDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CrewMemberDetailsProvider._internal(
        (ref) => create(ref as CrewMemberDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        crewId: crewId,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CrewMember?> createElement() {
    return _CrewMemberDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMemberDetailsProvider &&
        other.crewId == crewId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, crewId.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CrewMemberDetailsRef on AutoDisposeFutureProviderRef<CrewMember?> {
  /// The parameter `crewId` of this provider.
  String get crewId;

  /// The parameter `userId` of this provider.
  String get userId;
}

class _CrewMemberDetailsProviderElement
    extends AutoDisposeFutureProviderElement<CrewMember?>
    with CrewMemberDetailsRef {
  _CrewMemberDetailsProviderElement(super.provider);

  @override
  String get crewId => (origin as CrewMemberDetailsProvider).crewId;
  @override
  String get userId => (origin as CrewMemberDetailsProvider).userId;
}

String _$crewMemberStateNotifierHash() =>
    r'd7f6c3c1a81620c899485374ef83122a858fc115';

/// Main provider for crew member state management
///
/// Copied from [CrewMemberStateNotifier].
@ProviderFor(CrewMemberStateNotifier)
final crewMemberStateNotifierProvider = AutoDisposeNotifierProvider<
    CrewMemberStateNotifier, CrewMemberState>.internal(
  CrewMemberStateNotifier.new,
  name: r'crewMemberStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crewMemberStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CrewMemberStateNotifier = AutoDisposeNotifier<CrewMemberState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
