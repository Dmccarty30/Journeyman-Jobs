import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Crews feature validation utilities
class CrewValidation {
  /// Validate crew name
  static String? validateCrewName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Crew name is required';
    }
    final trimmed = name.trim();
    if (trimmed.length < 3 || trimmed.length > 50) {
      return 'Crew name must be 3-50 characters long';
    }
    // Allowed: alphanumeric, spaces, hyphens
    if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(trimmed)) {
      return 'Crew name can only contain letters, numbers, spaces, and hyphens';
    }
    return null;
  }

  /// Check crew name uniqueness (requires Firestore access)
  static Future<bool> isCrewNameUnique(String name, FirebaseFirestore firestore) async {
    final trimmed = name.trim().toLowerCase();
    final snapshot = await firestore
        .collection('crews')
        .where('nameLower', isEqualTo: trimmed)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  /// Validate member limit (max 50)
  static bool isUnderMemberLimit(int currentCount) {
    return currentCount < 50;
  }
}

/// Message validation
class MessageValidation {
  /// Validate message content
  static String? validateMessageContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    final trimmed = content.trim();
    if (trimmed.length > 1000) {
      return 'Message too long (max 1000 characters)';
    }
    // Basic content filtering (expand with profanity filter)
    if (_containsInappropriateContent(trimmed)) {
      return 'Message contains inappropriate content';
    }
    return null;
  }

  static bool _containsInappropriateContent(String text) {
    // Simple keyword filter - expand with ML-based filtering
    final inappropriateWords = ['spam', 'viagra', 'casino']; // Example
    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }

  // Spam detection
  static Future<bool> isSpam(String content, String userId, FirebaseFirestore firestore) async {
    // Check recent similar messages
    final recentSnapshot = await firestore
        .collectionGroup('messages')
        .where('senderId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(5)
        .get();

    final recentTexts = recentSnapshot.docs.map((doc) => doc.data()['content'] as String).toList();
    final similarityThreshold = 0.8;
    return recentTexts.any((text) => _calculateSimilarity(content, text) > similarityThreshold);
  }

  static double _calculateSimilarity(String a, String b) {
    // Simple placeholder - implement Levenshtein or Jaccard
    if (a.toLowerCase() == b.toLowerCase()) return 1.0;
    return 0.0;
  }
}

/// Job sharing validation
class JobSharingValidation {
  /// Prevent spam sharing (max 10 shares per hour per user)
  static Future<bool> canShareJob(String userId, FirebaseFirestore firestore) async {
    final counterRef = firestore.collection('counters').doc('job_shares').collection('hourly').doc(userId);
    final now = DateTime.now();
    final hourKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour}';

    final doc = await counterRef.get();
    if (!doc.exists || doc.data()?['hour'] != hourKey) {
      await counterRef.set({'count': 1, 'hour': hourKey});
      return true;
    }

    final count = doc.data()!['count'] as int;
    return count < 10;
  }

  /// Validate job data integrity
  static String? validateJobData(Map<String, dynamic> jobData) {
    if (jobData['id'] == null || jobData['id'].toString().isEmpty) {
      return 'Job ID is required';
    }
    if (jobData['jobType'] == null || jobData['jobType'].toString().isEmpty) {
      return 'Job type is required';
    }
    if (jobData['hourlyRate'] == null || (jobData['hourlyRate'] as num).toDouble() <= 0) {
      return 'Valid hourly rate is required';
    }
    if (jobData['location'] == null) {
      return 'Job location is required';
    }
    return null;
  }
}

/// General validation utilities
class GeneralValidation {
  /// Exponential backoff for retries
  static Future<void> exponentialBackoff({
    required int attempt,
    required Duration baseDelay,
    required int maxAttempts,
  }) async {
    if (attempt >= maxAttempts) throw Exception('Max retry attempts exceeded');
    final delay = baseDelay * pow(2, attempt);
    await Future.delayed(delay);
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?1?\d{9,15}$').hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''));
  }
}
