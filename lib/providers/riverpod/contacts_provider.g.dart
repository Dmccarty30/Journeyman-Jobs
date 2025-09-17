// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsServiceHash() => r'f3e405828353d7b9e91d11934effa26646c263e5';

/// Provider for the contacts service
///
/// Copied from [contactsService].
@ProviderFor(contactsService)
final contactsServiceProvider = AutoDisposeProvider<ContactsService>.internal(
  contactsService,
  name: r'contactsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsServiceRef = AutoDisposeProviderRef<ContactsService>;
String _$contactsHash() => r'4cd3558100fe29f6b63a6b1c23b61e94d11fc237';

/// Provider for managing contact list for job sharing
///
/// Copied from [Contacts].
@ProviderFor(Contacts)
final contactsProvider =
    AutoDisposeAsyncNotifierProvider<Contacts, List<UserModel>>.internal(
  Contacts.new,
  name: r'contactsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$contactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Contacts = AutoDisposeAsyncNotifier<List<UserModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
