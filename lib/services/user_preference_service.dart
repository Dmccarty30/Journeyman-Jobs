import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for users
  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  /// Updates a user's preferences in Firestore.
  ///
  /// The preferences map can contain any key-value pairs representing user choices.
  Future<void> updatePreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _usersCollection.doc(userId).update({
        'preferences': FieldValue.arrayUnion([preferences]), // Or merge/set a map directly
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user preferences for $userId: $e');
      rethrow;
    }
  }

  /// Updates a user's notification settings in Firestore.
  ///
  /// The settings map can contain specific notification configuration.
  Future<void> updateNotificationSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _usersCollection.doc(userId).update({
        'notificationSettings': FieldValue.arrayUnion([settings]), // Or merge/set a map directly
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user notification settings for $userId: $e');
      rethrow;
    }
  }

  /// Retrieves a user's preferences from Firestore.
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data()?['preferences'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error retrieving user preferences for $userId: $e');
    }
    return null;
  }

  /// Retrieves a user's notification settings from Firestore.
  Future<Map<String, dynamic>?> getUserNotificationSettings(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data()?['notificationSettings'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error retrieving user notification settings for $userId: $e');
    }
    return null;
  }
}
