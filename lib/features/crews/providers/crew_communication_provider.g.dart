// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_communication_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$crewCommunicationServiceHash() =>
    r'18efef3a558c60ccdb81c547bd6b99fc5391f281';

/// CrewCommunicationService provider
///
/// Copied from [crewCommunicationService].
@ProviderFor(crewCommunicationService)
final crewCommunicationServiceProvider =
    AutoDisposeProvider<CrewCommunicationService>.internal(
  crewCommunicationService,
  name: r'crewCommunicationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crewCommunicationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewCommunicationServiceRef
    = AutoDisposeProviderRef<CrewCommunicationService>;
String _$communicationConnectivityServiceHash() =>
    r'1fe14eb36db31656ea215db71e2c8182bcf90768';

/// Connectivity service provider for communication
///
/// Copied from [communicationConnectivityService].
@ProviderFor(communicationConnectivityService)
final communicationConnectivityServiceProvider =
    AutoDisposeProvider<ConnectivityService>.internal(
  communicationConnectivityService,
  name: r'communicationConnectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$communicationConnectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunicationConnectivityServiceRef
    = AutoDisposeProviderRef<ConnectivityService>;
String _$crewMessagesHash() => r'b8b5600a17833a3e04ba8b8758f45c8b27169e61';

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

/// Provider for getting messages for a specific crew
///
/// Copied from [crewMessages].
@ProviderFor(crewMessages)
const crewMessagesProvider = CrewMessagesFamily();

/// Provider for getting messages for a specific crew
///
/// Copied from [crewMessages].
class CrewMessagesFamily extends Family<AsyncValue<List<CrewCommunication>>> {
  /// Provider for getting messages for a specific crew
  ///
  /// Copied from [crewMessages].
  const CrewMessagesFamily();

  /// Provider for getting messages for a specific crew
  ///
  /// Copied from [crewMessages].
  CrewMessagesProvider call(
    String crewId,
  ) {
    return CrewMessagesProvider(
      crewId,
    );
  }

  @override
  CrewMessagesProvider getProviderOverride(
    covariant CrewMessagesProvider provider,
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
  String? get name => r'crewMessagesProvider';
}

/// Provider for getting messages for a specific crew
///
/// Copied from [crewMessages].
class CrewMessagesProvider
    extends AutoDisposeStreamProvider<List<CrewCommunication>> {
  /// Provider for getting messages for a specific crew
  ///
  /// Copied from [crewMessages].
  CrewMessagesProvider(
    String crewId,
  ) : this._internal(
          (ref) => crewMessages(
            ref as CrewMessagesRef,
            crewId,
          ),
          from: crewMessagesProvider,
          name: r'crewMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$crewMessagesHash,
          dependencies: CrewMessagesFamily._dependencies,
          allTransitiveDependencies:
              CrewMessagesFamily._allTransitiveDependencies,
          crewId: crewId,
        );

  CrewMessagesProvider._internal(
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
    Stream<List<CrewCommunication>> Function(CrewMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CrewMessagesProvider._internal(
        (ref) => create(ref as CrewMessagesRef),
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
  AutoDisposeStreamProviderElement<List<CrewCommunication>> createElement() {
    return _CrewMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMessagesProvider && other.crewId == crewId;
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
mixin CrewMessagesRef on AutoDisposeStreamProviderRef<List<CrewCommunication>> {
  /// The parameter `crewId` of this provider.
  String get crewId;
}

class _CrewMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<CrewCommunication>>
    with CrewMessagesRef {
  _CrewMessagesProviderElement(super.provider);

  @override
  String get crewId => (origin as CrewMessagesProvider).crewId;
}

String _$crewUnreadCountHash() => r'2bd9b9d4861aa4bb69b3908bc6310260a090f2ab';

/// Provider for getting unread count for a specific crew
///
/// Copied from [crewUnreadCount].
@ProviderFor(crewUnreadCount)
const crewUnreadCountProvider = CrewUnreadCountFamily();

/// Provider for getting unread count for a specific crew
///
/// Copied from [crewUnreadCount].
class CrewUnreadCountFamily extends Family<AsyncValue<int>> {
  /// Provider for getting unread count for a specific crew
  ///
  /// Copied from [crewUnreadCount].
  const CrewUnreadCountFamily();

  /// Provider for getting unread count for a specific crew
  ///
  /// Copied from [crewUnreadCount].
  CrewUnreadCountProvider call(
    String crewId,
  ) {
    return CrewUnreadCountProvider(
      crewId,
    );
  }

  @override
  CrewUnreadCountProvider getProviderOverride(
    covariant CrewUnreadCountProvider provider,
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
  String? get name => r'crewUnreadCountProvider';
}

/// Provider for getting unread count for a specific crew
///
/// Copied from [crewUnreadCount].
class CrewUnreadCountProvider extends AutoDisposeStreamProvider<int> {
  /// Provider for getting unread count for a specific crew
  ///
  /// Copied from [crewUnreadCount].
  CrewUnreadCountProvider(
    String crewId,
  ) : this._internal(
          (ref) => crewUnreadCount(
            ref as CrewUnreadCountRef,
            crewId,
          ),
          from: crewUnreadCountProvider,
          name: r'crewUnreadCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$crewUnreadCountHash,
          dependencies: CrewUnreadCountFamily._dependencies,
          allTransitiveDependencies:
              CrewUnreadCountFamily._allTransitiveDependencies,
          crewId: crewId,
        );

  CrewUnreadCountProvider._internal(
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
    Stream<int> Function(CrewUnreadCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CrewUnreadCountProvider._internal(
        (ref) => create(ref as CrewUnreadCountRef),
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
  AutoDisposeStreamProviderElement<int> createElement() {
    return _CrewUnreadCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewUnreadCountProvider && other.crewId == crewId;
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
mixin CrewUnreadCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `crewId` of this provider.
  String get crewId;
}

class _CrewUnreadCountProviderElement
    extends AutoDisposeStreamProviderElement<int> with CrewUnreadCountRef {
  _CrewUnreadCountProviderElement(super.provider);

  @override
  String get crewId => (origin as CrewUnreadCountProvider).crewId;
}

String _$hasUnreadMessagesHash() => r'490064531fd84c7bee9534566d09105b2e18d7f4';

/// Provider for checking if any crew has unread messages
///
/// Copied from [hasUnreadMessages].
@ProviderFor(hasUnreadMessages)
final hasUnreadMessagesProvider = AutoDisposeProvider<bool>.internal(
  hasUnreadMessages,
  name: r'hasUnreadMessagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasUnreadMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasUnreadMessagesRef = AutoDisposeProviderRef<bool>;
String _$totalUnreadCountHash() => r'6bcbaaa194bd0506381f1c2a93aa1c0d2690d9aa';

/// Provider for getting total unread count across all crews
///
/// Copied from [totalUnreadCount].
@ProviderFor(totalUnreadCount)
final totalUnreadCountProvider = AutoDisposeProvider<int>.internal(
  totalUnreadCount,
  name: r'totalUnreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadCountRef = AutoDisposeProviderRef<int>;
String _$isAnyCrewLoadingHash() => r'ce49b584958be8e370f9a620be11a055d9633f8b';

/// Provider for checking if any crew is currently loading
///
/// Copied from [isAnyCrewLoading].
@ProviderFor(isAnyCrewLoading)
final isAnyCrewLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAnyCrewLoading,
  name: r'isAnyCrewLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAnyCrewLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAnyCrewLoadingRef = AutoDisposeProviderRef<bool>;
String _$allCommunicationErrorsHash() =>
    r'ab6ad5052404ac2fb8af9128f516ea452055240d';

/// Provider for getting all crew communication errors
///
/// Copied from [allCommunicationErrors].
@ProviderFor(allCommunicationErrors)
final allCommunicationErrorsProvider =
    AutoDisposeProvider<List<String>>.internal(
  allCommunicationErrors,
  name: r'allCommunicationErrorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCommunicationErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCommunicationErrorsRef = AutoDisposeProviderRef<List<String>>;
String _$hasPendingOfflineMessagesHash() =>
    r'b1f17a2916002ddf5dff039bf28c05799605fc27';

/// Provider for checking if there are pending offline messages
///
/// Copied from [hasPendingOfflineMessages].
@ProviderFor(hasPendingOfflineMessages)
final hasPendingOfflineMessagesProvider = AutoDisposeProvider<bool>.internal(
  hasPendingOfflineMessages,
  name: r'hasPendingOfflineMessagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasPendingOfflineMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasPendingOfflineMessagesRef = AutoDisposeProviderRef<bool>;
String _$offlineMessageCountHash() =>
    r'59474b241b8b5b68496d85f97d92d1b3e6a3486f';

/// Provider for getting offline message count
///
/// Copied from [offlineMessageCount].
@ProviderFor(offlineMessageCount)
final offlineMessageCountProvider = AutoDisposeProvider<int>.internal(
  offlineMessageCount,
  name: r'offlineMessageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offlineMessageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineMessageCountRef = AutoDisposeProviderRef<int>;
String _$crewCommunicationNotifierHash() =>
    r'80c361587a3d439defaeab3137c6f0858a47eb37';

/// Main CrewCommunicationProvider for managing real-time crew communication
///
/// Copied from [CrewCommunicationNotifier].
@ProviderFor(CrewCommunicationNotifier)
final crewCommunicationNotifierProvider = AutoDisposeNotifierProvider<
    CrewCommunicationNotifier, CrewCommunicationState>.internal(
  CrewCommunicationNotifier.new,
  name: r'crewCommunicationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crewCommunicationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CrewCommunicationNotifier
    = AutoDisposeNotifier<CrewCommunicationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
