import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A utility class containing helper functions for crew-related operations.
class CrewUtils {
  /// Validates a crew name based on a set of business rules.
  ///
  /// The rules are:
  /// - Name is required (not null or empty).
  /// - Name must be between 3 and 50 characters long.
  /// - Name can only contain alphanumeric characters, spaces, hyphens, and underscores.
  ///
  /// Returns a `String` with an error message if validation fails, otherwise returns `null`.
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

  /// Calculates the next sequential counter for a new crew ID to ensure uniqueness.
  ///
  /// This function queries Firestore for existing crew IDs that start with
  /// the given [crewName] and have been created within the last 24 hours.
  /// It finds the highest counter used in that period and returns the next integer.
  /// This helps prevent ID collisions in high-frequency creation scenarios.
  ///
  /// - [crewName]: The base name for the crew.
  /// - [firestore]: The `FirebaseFirestore` instance to use for the query.
  ///
  /// Returns a `Future<int>` representing the next available counter.
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

  /// Calculates the great-circle distance between two geographic points using the Haversine formula.
  ///
  /// - [lat1], [lon1]: Latitude and longitude of the first point.
  /// - [lat2], [lon2]: Latitude and longitude of the second point.
  ///
  /// Returns the distance in kilometers.
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

  /// Converts degrees to radians.
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// A convenience wrapper for [calculateHaversineDistance].
  ///
  /// Calculates the distance between two geographic coordinates.
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