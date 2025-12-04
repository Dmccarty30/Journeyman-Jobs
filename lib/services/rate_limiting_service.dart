import 'package:cloud_firestore/cloud_firestore.dart';

class RateLimitingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for rate limits
  CollectionReference<Map<String, dynamic>> get _rateLimitsCollection => _firestore.collection('rate_limits');

  /// Checks if a user is rate-limited for a specific action.
  ///
  /// [userId]: The ID of the user.
  /// [actionType]: The type of action being performed (e.g., 'ai_recommendation_request', 'ai_chat_message').
  /// [limit]: The maximum number of actions allowed within the [windowDuration].
  /// [windowDuration]: The time window for the rate limit (e.g., 60 seconds for 1 request/minute).
  Future<bool> isRateLimited(String userId, String actionType, {int limit = 5, Duration windowDuration = const Duration(minutes: 1)}) async {
    final DateTime now = DateTime.now();
    final DateTime windowStart = now.subtract(windowDuration);

    try {
      final QuerySnapshot snapshot = await _rateLimitsCollection
          .where('userId', isEqualTo: userId)
          .where('actionType', isEqualTo: actionType)
          .where('timestamp', isGreaterThanOrEqualTo: windowStart)
          .get();

      return snapshot.docs.length >= limit;
    } catch (e) {
      print('Error checking rate limit for $userId, $actionType: $e');
      // Default to not rate-limited in case of error, to avoid blocking legitimate users.
      return false;
    }
  }

  /// Records an action taken by a user for rate-limiting purposes.
  ///
  /// [userId]: The ID of the user.
  /// [actionType]: The type of action being performed.
  Future<void> recordAction(String userId, String actionType) async {
    try {
      await _rateLimitsCollection.add({
        'userId': userId,
        'actionType': actionType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording action for $userId, $actionType: $e');
      // Log the error but don't rethrow, as a failed record shouldn't halt the user action.
    }
  }
}
