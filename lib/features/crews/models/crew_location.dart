import 'package:cloud_firestore/cloud_firestore.dart';

class CrewLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;

  CrewLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.zipCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'geopoint': GeoPoint(latitude, longitude),
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }

  factory CrewLocation.fromJson(Map<String, dynamic> json) {
    final geopoint = json['geopoint'] as GeoPoint;
    return CrewLocation(
      latitude: geopoint.latitude,
      longitude: geopoint.longitude,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
    );
  }

  // Factory method to create a CrewLocation from Firestore data
  factory CrewLocation.fromFirestore(dynamic data) {
    if (data is GeoPoint) {
      // If the data is directly a GeoPoint
      return CrewLocation(
        latitude: data.latitude,
        longitude: data.longitude,
        address: null,
        city: null,
        state: null,
        zipCode: null,
      );
    } else if (data is Map<String, dynamic>) {
      // If the data is a map with geopoint and other fields
      if (data.containsKey('geopoint') && data['geopoint'] is GeoPoint) {
        final geopoint = data['geopoint'] as GeoPoint;
        return CrewLocation(
          latitude: geopoint.latitude,
          longitude: geopoint.longitude,
          address: data['address'] as String?,
          city: data['city'] as String?,
          state: data['state'] as String?,
          zipCode: data['zipCode'] as String?,
        );
      } else {
        // If the data is a map with latitude and longitude directly
        return CrewLocation(
          latitude: data['latitude'] is double ? data['latitude'] : (data['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: data['longitude'] is double ? data['longitude'] : (data['longitude'] as num?)?.toDouble() ?? 0.0,
          address: data['address'] as String?,
          city: data['city'] as String?,
          state: data['state'] as String?,
          zipCode: data['zipCode'] as String?,
        );
      }
    }
    throw ArgumentError('Invalid data format for CrewLocation.fromFirestore');
  }

  // Method to convert CrewLocation to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'geopoint': GeoPoint(latitude, longitude),
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}