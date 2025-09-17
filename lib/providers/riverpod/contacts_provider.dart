import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user_model.dart';
import '../../services/contacts_service.dart';

part 'contacts_provider.g.dart';

/// Provider for managing contact list for job sharing
@riverpod
class Contacts extends _$Contacts {
  @override
  Future<List<UserModel>> build() async {
    final service = ref.read(contactsServiceProvider);
    return service.getContacts();
  }

  /// Add a new contact
  Future<void> addContact(UserModel contact) async {
    final service = ref.read(contactsServiceProvider);
    await service.addContact(contact);
    ref.invalidateSelf();
  }

  /// Remove a contact
  Future<void> removeContact(String contactId) async {
    final service = ref.read(contactsServiceProvider);
    await service.removeContact(contactId);
    ref.invalidateSelf();
  }

  /// Update contact information
  Future<void> updateContact(UserModel contact) async {
    final service = ref.read(contactsServiceProvider);
    await service.updateContact(contact);
    ref.invalidateSelf();
  }

  /// Search contacts by name or email
  Future<List<UserModel>> searchContacts(String query) async {
    final service = ref.read(contactsServiceProvider);
    return service.searchContacts(query);
  }
}

/// Provider for the contacts service
@riverpod
ContactsService contactsService(ContactsServiceRef ref) {
  return ContactsService();
}