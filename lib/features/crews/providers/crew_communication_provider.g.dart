// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_communication_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, duplicate_ignore

String _$crewCommunicationServiceHash() =>
    r'a8b7c6d5e4f3g2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// CrewCommunicationService provider
///
/// Copied from Dart SDK
final crewCommunicationServiceProvider =
    AutoDisposeProvider<CrewCommunicationService>.internal(
  crewCommunicationService,
  name: r'crewCommunicationServiceProvider',
  debugGetCreateSourceHash: _$crewCommunicationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewCommunicationServiceRef
    = AutoDisposeProviderRef<CrewCommunicationService>;

String _$communicationConnectivityServiceHash() =>
    r'b8a7c6d5e4f3g2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Connectivity service provider for communication
///
/// Copied from Dart SDK
final communicationConnectivityServiceProvider =
    AutoDisposeProvider<ConnectivityService>.internal(
  communicationConnectivityService,
  name: r'communicationConnectivityServiceProvider',
  debugGetCreateSourceHash: _$communicationConnectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunicationConnectivityServiceRef
    = AutoDisposeProviderRef<ConnectivityService>;

String _$crewMessagesHash() => r'c8b7a6d5e4f3g2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for getting messages for a specific crew
///
/// Copied from Dart SDK
final crewMessagesProvider = AutoDisposeStreamProviderFamily<
    List<CrewCommunication>, String>.internal(
  crewMessages,
  name: r'crewMessagesProvider',
  debugGetCreateSourceHash: _$crewMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewMessagesRef = AutoDisposeStreamProviderRef<List<CrewCommunication>>;

String _$crewUnreadCountHash() =>
    r'd8c7b6a5e4f3g2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for getting unread count for a specific crew
///
/// Copied from Dart SDK
final crewUnreadCountProvider =
    AutoDisposeStreamProviderFamily<int, String>.internal(
  crewUnreadCount,
  name: r'crewUnreadCountProvider',
  debugGetCreateSourceHash: _$crewUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewUnreadCountRef = AutoDisposeStreamProviderRef<int>;

String _$hasUnreadMessagesHash() =>
    r'e8d7c6b5a4f3g2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for checking if any crew has unread messages
///
/// Copied from Dart SDK
final hasUnreadMessagesProvider = AutoDisposeProvider<bool>.internal(
  hasUnreadMessages,
  name: r'hasUnreadMessagesProvider',
  debugGetCreateSourceHash: _$hasUnreadMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasUnreadMessagesRef = AutoDisposeProviderRef<bool>;

String _$totalUnreadCountHash() =>
    r'f8e7d6c5b4a3g2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for getting total unread count across all crews
///
/// Copied from Dart SDK
final totalUnreadCountProvider = AutoDisposeProvider<int>.internal(
  totalUnreadCount,
  name: r'totalUnreadCountProvider',
  debugGetCreateSourceHash: _$totalUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadCountRef = AutoDisposeProviderRef<int>;

String _$isAnyCrewLoadingHash() =>
    r'g8f7e6d5c4b3a2h1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for checking if any crew is currently loading
///
/// Copied from Dart SDK
final isAnyCrewLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAnyCrewLoading,
  name: r'isAnyCrewLoadingProvider',
  debugGetCreateSourceHash: _$isAnyCrewLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAnyCrewLoadingRef = AutoDisposeProviderRef<bool>;

String _$allCommunicationErrorsHash() =>
    r'h8g7f6e5d4c3b2a1i0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for getting all crew communication errors
///
/// Copied from Dart SDK
final allCommunicationErrorsProvider =
    AutoDisposeProvider<List<String>>.internal(
  allCommunicationErrors,
  name: r'allCommunicationErrorsProvider',
  debugGetCreateSourceHash: _$allCommunicationErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCommunicationErrorsRef = AutoDisposeProviderRef<List<String>>;

String _$hasPendingOfflineMessagesHash() =>
    r'i8h7g6f5e4d3c2b1a0j9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for checking if there are pending offline messages
///
/// Copied from Dart SDK
final hasPendingOfflineMessagesProvider = AutoDisposeProvider<bool>.internal(
  hasPendingOfflineMessages,
  name: r'hasPendingOfflineMessagesProvider',
  debugGetCreateSourceHash: _$hasPendingOfflineMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasPendingOfflineMessagesRef = AutoDisposeProviderRef<bool>;

String _$offlineMessageCountHash() =>
    r'j8i7h6g5f4e3d2c1b0a9k8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Provider for getting offline message count
///
/// Copied from Dart SDK
final offlineMessageCountProvider = AutoDisposeProvider<int>.internal(
  offlineMessageCount,
  name: r'offlineMessageCountProvider',
  debugGetCreateSourceHash: _$offlineMessageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineMessageCountRef = AutoDisposeProviderRef<int>;

String _$crewCommunicationNotifierHash() =>
    r'k8j7i6h5g4f3e2d1c0b9a8l7m6n5o4p3q2r1s0t9u8v7w6x5y4z3a2b1';

/// Main CrewCommunicationProvider for managing real-time crew communication
///
/// Copied from Dart SDK
final crewCommunicationNotifierProvider = AutoDisposeNotifierProvider<
    CrewCommunicationNotifier, CrewCommunicationState>.internal(
  CrewCommunicationNotifier.new,
  name: r'crewCommunicationNotifierProvider',
  debugGetCreateSourceHash: _$crewCommunicationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CrewCommunicationNotifier
    = AutoDisposeNotifier<CrewCommunicationState>;
@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrewCommunicationNotifierRef
    = AutoDisposeNotifierProviderRef<CrewCommunicationState>;