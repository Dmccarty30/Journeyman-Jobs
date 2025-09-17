// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactServiceHash() => r'a067c088d7460889c4dc91c10d5465b679dbfe75';

/// Provider for ContactService instance
///
/// Copied from [contactService].
@ProviderFor(contactService)
final contactServiceProvider = AutoDisposeProvider<ContactService>.internal(
  contactService,
  name: r'contactServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactServiceRef = AutoDisposeProviderRef<ContactService>;
String _$contactPermissionHash() => r'316783111713d5cb21c4786dd5fe3128922fdf69';

/// Provider for checking if contacts permission is granted
///
/// Copied from [contactPermission].
@ProviderFor(contactPermission)
final contactPermissionProvider = AutoDisposeFutureProvider<bool>.internal(
  contactPermission,
  name: r'contactPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactPermissionRef = AutoDisposeFutureProviderRef<bool>;
String _$selectedContactCountHash() =>
    r'a87723b3c9af1e11c8950d5cc563fd520e0d6e17';

/// Provider for selected contact count
///
/// Copied from [selectedContactCount].
@ProviderFor(selectedContactCount)
final selectedContactCountProvider = AutoDisposeProvider<int>.internal(
  selectedContactCount,
  name: r'selectedContactCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedContactCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedContactCountRef = AutoDisposeProviderRef<int>;
String _$filteredContactCountHash() =>
    r'9a43d88dde780e2097eb3d574088d6a5e72ee5ff';

/// Provider for filtered contact count
///
/// Copied from [filteredContactCount].
@ProviderFor(filteredContactCount)
final filteredContactCountProvider = AutoDisposeProvider<int>.internal(
  filteredContactCount,
  name: r'filteredContactCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredContactCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredContactCountRef = AutoDisposeProviderRef<int>;
String _$hasActiveSearchHash() => r'016e734aeb3db67baccaa19a8ad6a7e99ef91cf1';

/// Provider for checking if search is active
///
/// Copied from [hasActiveSearch].
@ProviderFor(hasActiveSearch)
final hasActiveSearchProvider = AutoDisposeProvider<bool>.internal(
  hasActiveSearch,
  name: r'hasActiveSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasActiveSearchRef = AutoDisposeProviderRef<bool>;
String _$contactStateNotifierHash() =>
    r'ff4001a7422d2f4c6763a3b9271272b21249ccda';

/// Provider for contact state management
///
/// Copied from [ContactStateNotifier].
@ProviderFor(ContactStateNotifier)
final contactStateNotifierProvider =
    AutoDisposeNotifierProvider<ContactStateNotifier, ContactState>.internal(
  ContactStateNotifier.new,
  name: r'contactStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContactStateNotifier = AutoDisposeNotifier<ContactState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
