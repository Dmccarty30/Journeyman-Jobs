import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service for managing contacts for job sharing functionality
class ContactsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all contacts for the current user
  Future<List<UserModel>> getContacts() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final contactsQuery = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .orderBy('firstName')
          .get();

      final contacts = <UserModel>[];
      for (final doc in contactsQuery.docs) {
        final contactData = doc.data();
        // Get the full user data from the users collection
        final userDoc = await _firestore
            .collection('users')
            .doc(contactData['userId'])
            .get();
        
        if (userDoc.exists) {
          contacts.add(UserModel.fromFirestore(userDoc));
        }
      }

      return contacts;
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  /// Add a contact for the current user
  Future<void> addContact(UserModel contact) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .doc(contact.uid)
          .set({
        'userId': contact.uid,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  /// Remove a contact
  Future<void> removeContact(String contactId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove contact: $e');
    }
  }

  /// Update contact information
  Future<void> updateContact(UserModel contact) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Update the user document in the users collection
      await _firestore
          .collection('users')
          .doc(contact.uid)
          .update(contact.toJson());
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  /// Search contacts by name or email
  Future<List<UserModel>> searchContacts(String query) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final contacts = await getContacts();
      final lowercaseQuery = query.toLowerCase();
      
      return contacts.where((contact) {
        return contact.fullName.toLowerCase().contains(lowercaseQuery) ||
               contact.email.toLowerCase().contains(lowercaseQuery) ||
               contact.homeLocal.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search contacts: $e');
    }
  }

  /// Find users by email for adding new contacts
  Future<List<UserModel>> findUsersByEmail(String email) async {
    try {
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(5)
          .get();

      return usersQuery.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to find users by email: $e');
    }
  }

  /// Check if a user is already a contact
  Future<bool> isContact(String userId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .doc(userId)
          .get();
      
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}