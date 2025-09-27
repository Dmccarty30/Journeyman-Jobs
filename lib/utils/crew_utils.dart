import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility functions for crew operations
class CrewUtils {
  /// Validates crew name according to business rules
  /// Returns error message if invalid, null if valid
  static String? validateCrewName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Crew name is required';
    }
    
    final trimmed = name.trim();
    if (trimmed.length < 3 || trimmed.length > 50) {
      return 'Crew name must be 3-50 characters long';
    }
    
    // Allowed: alphanumeric, spaces, hyphens, underscores
    if (!RegExp(r'^[a-zA-Z0-9\s\-_]+$').hasMatch(trimmed)) {
      return 'Crew name can only contain letters, numbers, spaces, hyphens, and underscores';
    }
    
    return null;
  }

  /// Calculates the next crew ID counter by querying existing crews with the name_timestamp prefix
  /// Returns the next counter value to use for unique ID generation
  static Future<int> calculateCrewIdCounter({
    required String crewName,
    required FirebaseFirestore firestore,
  }) async {
    try {
      final String prefix = '${crewName}_';
      
      // Query for existing crews that start with the name prefix
      final querySnapshot = await firestore
          .collection('crews')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix)
          .where(FieldPath.documentId, isLessThan: '${prefix}z')
          .get();

      int maxCounter = 0;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Parse existing crew IDs to find the highest counter
      for (final doc in querySnapshot.docs) {
        final docId = doc.id;
        if (docId.startsWith(prefix)) {
          // Expected format: name_timestamp_counter
          final parts = docId.split('_');
          if (parts.length >= 3) {
            try {
              final timestamp = int.parse(parts[parts.length - 2]);
              final counter = int.parse(parts.last);
              
              // Only consider recent crews (within last 24 hours) to avoid conflicts
              if (currentTimestamp - timestamp < 86400000) { // 24 hours in milliseconds
                maxCounter = max(maxCounter, counter);
              }
            } catch (e) {
              // Skip invalid format
              continue;
            }
          }
        }
      }

      return maxCounter + 1;
    } catch (e) {
      // If query fails, return 1 as fallback
      return 1;
    }
  }

  /// Calculates the great-circle distance between two points on Earth using the Haversine formula
  /// Returns distance in kilometers
  static double calculateHaversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert degrees to radians
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    // Haversine formula
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Converts degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Calculates distance between two geographic coordinates
  /// Convenience wrapper for haversine calculation
  static double distanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return calculateHaversineDistance(
      lat1: startLatitude,
      lon1: startLongitude,
      lat2: endLatitude,
      lon2: endLongitude,
    );
  }
}