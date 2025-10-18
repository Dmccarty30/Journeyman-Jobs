import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Custom JSON converter for Firestore Timestamp fields
///
/// Handles conversion between Firestore Timestamp and DateTime objects
/// during JSON serialization/deserialization operations.
///
/// Usage in Freezed models:
/// ```dart
/// @JsonSerializable(converters: [TimestampConverter()])
/// @TimestampConverter()
/// final DateTime? timestamp;
/// ```
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;

    if (json is Timestamp) {
      return json.toDate();
    }

    if (json is DateTime) {
      return json;
    }

    if (json is String) {
      return DateTime.tryParse(json);
    }

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    // For Firestore, return Timestamp; for JSON, return ISO string
    return Timestamp.fromDate(object);
  }
}

/// Custom JSON converter for Firestore GeoPoint fields
///
/// Handles conversion between Firestore GeoPoint and Map representation
/// during JSON serialization/deserialization operations.
///
/// JSON format: {"latitude": 37.7749, "longitude": -122.4194}
///
/// Usage in Freezed models:
/// ```dart
/// @JsonSerializable(converters: [GeoPointConverter()])
/// @GeoPointConverter()
/// final GeoPoint? location;
/// ```
class GeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) {
    if (json == null) return null;

    if (json is GeoPoint) {
      return json;
    }

    if (json is Map<String, dynamic>) {
      final lat = json['latitude'] as num?;
      final lng = json['longitude'] as num?;

      if (lat != null && lng != null) {
        return GeoPoint(lat.toDouble(), lng.toDouble());
      }
    }

    // Default GeoPoint if parsing fails
    return const GeoPoint(0, 0);
  }

  @override
  Object? toJson(GeoPoint? object) {
    if (object == null) return null;

    return {
      'latitude': object.latitude,
      'longitude': object.longitude,
    };
  }
}

/// Custom JSON converter for optional GeoPoint fields stored in nested maps
///
/// This converter handles the special case where GeoPoint data might be nested
/// within the jobDetails map structure from legacy data sources.
class OptionalGeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  const OptionalGeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) {
    if (json == null) return null;

    if (json is GeoPoint) {
      return json;
    }

    if (json is Map) {
      final lat = json['latitude'] as num?;
      final lng = json['longitude'] as num?;

      if (lat != null && lng != null) {
        return GeoPoint(lat.toDouble(), lng.toDouble());
      }
    }

    return null; // Return null instead of default for optional fields
  }

  @override
  Object? toJson(GeoPoint? object) {
    if (object == null) return null;

    return {
      'latitude': object.latitude,
      'longitude': object.longitude,
    };
  }
}
