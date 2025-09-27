import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/analytics_service.dart';

/// Service for managing user profile operations related to crews.
/// Provides methods for querying and updating crew-related fields in user profiles.
class UserProfileService {
  final FirebaseFirestore _firestore;

  // Collection names
  static const String _usersCollection = 'users';

  UserProfileService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// Gets the user's crews array from their profile.
  ///
  /// Returns a list of crew IDs (List<String>?) or null if the field doesn't exist.
  /// Handles null by returning an empty list.
  Future<List<String>?> getUserCrews(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      final crews = userDoc.data()?['crews'] as List<dynamic>?;
      return crews?.cast<String>();
    } catch (e) {
      if (e is FirebaseException) {
        rethrow;
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to get user crews: $e',
      );
    }
  }

  /// Gets the user's current crew ID from their profile.
  ///
  /// Returns the current crew ID (String?) or null if not set.
  Future<String?> getCurrentCrewId(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return userDoc.data()?['currentCrewId'] as String?;
    } catch (e) {
      if (e is FirebaseException) {
        rethrow;
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to get current crew ID: $e',
      );
    }
  }

  /// Updates the user's crews array.
  ///
  /// [newCrews] - The new list of crew IDs to set.
  /// Uses merge to preserve other fields in the user document.
  Future<void> updateUserCrews(String userId, List<String> newCrews) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(
            {'crews': newCrews},
            SetOptions(merge: true),
          );
    } catch (e) {
      if (e is FirebaseException) {
        rethrow;
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to update user crews: $e',
      );
    }
  }

  /// Sets the user's current crew ID.
  ///
  /// [crewId] - The crew ID to set as current, or null to clear it.
  /// Uses merge to preserve other fields in the user document.
  Future<void> setCurrentCrewId(String userId, String? crewId) async {
    try {
      // Get the old crew ID for analytics
      final oldCrewId = await getCurrentCrewId(userId);

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(
            {'currentCrewId': crewId},
            SetOptions(merge: true),
          );

      // Log analytics event for crew switch
      if (oldCrewId != crewId) {
        await AnalyticsService.logCustomEvent('crew_switched', {
          'from': oldCrewId ?? 'none',
          'to': crewId ?? 'none',
          'userId': userId,
        });
      }
    } catch (e) {
      if (e is FirebaseException) {
        rethrow;
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to set current crew ID: $e',
      );
    }
  }

  /// Atomically adds a crew to the user's crews array and sets it as current.
  ///
  /// This method ensures atomicity using a Firestore transaction:
  /// 1. Gets the current user document
  /// 2. Appends the crewId to the crews array (initializes if null)
  /// 3. Sets currentCrewId to the provided crewId
  ///
  /// [userId] - The user ID
  /// [crewId] - The crew ID to add and set as current
  Future<void> addToCrewsAndSetCurrent(String userId, String crewId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection(_usersCollection).doc(userId);
        final userDoc = await transaction.get(userRef);

        List<String> updatedCrews;
        if (userDoc.exists) {
          final currentCrews = userDoc.data()?['crews'] as List<dynamic>?;
          updatedCrews = currentCrews?.cast<String>() ?? [];
          if (!updatedCrews.contains(crewId)) {
            updatedCrews.add(crewId);
          }
        } else {
          updatedCrews = [crewId];
        }

        transaction.set(
          userRef,
          {
            'crews': updatedCrews,
            'currentCrewId': crewId,
          },
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      if (e is FirebaseException) {
        rethrow;
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to add to crews and set current: $e',
      );
    }
  }

  /// Stream of user's crews array for real-time updates.
  ///
  /// Returns a stream that emits the user's crews array whenever it changes.
  /// Emits null if the field doesn't exist or the document doesn't exist.
  Stream<List<String>?> userCrewsStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return [];
      }
      final crews = snapshot.data()?['crews'] as List<dynamic>?;
      return crews?.cast<String>();
    });
  }

  /// Stream of user's current crew ID for real-time updates.
  ///
  /// Returns a stream that emits the user's current crew ID whenever it changes.
  /// Emits null if the field doesn't exist or the document doesn't exist.
  Stream<String?> currentCrewIdStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return snapshot.data()?['currentCrewId'] as String?;
    });
  }
}