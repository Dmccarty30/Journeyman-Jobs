import 'package:cloud_firestore/cloud_firestore.dart';

/// A geographic location represented by latitude and longitude coordinates.
/// 
/// This class provides a simple way to represent and work with geographic
/// coordinates, commonly used for location-based features in the application.
class LatLng {
  /// The latitude coordinate in degrees.
  final double latitude;
  
  /// The longitude coordinate in degrees.
  final double longitude;
  
  /// Creates a new LatLng instance with the specified coordinates.
  /// 
  /// [latitude] must be between -90.0 and 90.0 degrees.
  /// [longitude] must be between -180.0 and 180.0 degrees.
  const LatLng(this.latitude, this.longitude);
  
  /// Returns a string representation of the coordinates.
  @override
  String toString() => 'LatLng($latitude, $longitude)';
  
  /// Compares two LatLng instances for equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;
  
  /// Returns the hash code for this LatLng instance.
  @override
  int get hashCode => Object.hash(latitude, longitude);
  
  /// Converts this LatLng to a Firestore GeoPoint.
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
  
  /// Creates a LatLng from a map representation.
  /// 
  /// Expected format: {'latitude': double, 'longitude': double}
  factory LatLng.fromMap(Map<String, dynamic> map) {
    return LatLng(
      (map['latitude'] as num).toDouble(),
      (map['longitude'] as num).toDouble(),
    );
  }
  
  /// Converts this LatLng to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Extension methods for Firestore GeoPoint to integrate with LatLng.
extension GeoPointExtensions on GeoPoint {
  /// Converts a Firestore GeoPoint to a LatLng instance.
  /// 
  /// This is commonly used when retrieving location data from Firestore
  /// and converting it to the application's LatLng format.
  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// Extension methods for LatLng to provide additional utilities.
extension LatLngExtensions on LatLng {
  /// Calculates the approximate distance between two points using the
  /// Haversine formula. Returns the distance in kilometers.
  double distanceTo(LatLng other) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    
    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
        math.cos(_toRadians(other.latitude)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Converts degrees to radians.
  double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}

/// Helper import for math functions
import 'dart:math' as math;