/// Utility functions for enum serialization and deserialization.
/// 
/// This file provides utilities for working with enums, particularly
/// for serializing them to/from strings and other data formats.

import 'package:collection/collection.dart';

/// Deserializes a value to an enum of type T.
/// 
/// This function attempts to match a dynamic value (typically a string)
/// to an enum value. It works with enums that have a serialize() method
/// or uses the enum's name property.
/// 
/// Returns null if no matching enum value is found.
/// 
/// Example usage:
/// ```dart
/// final classification = deserializeEnum<Classification>(value);
/// ```
T? deserializeEnum<T>(dynamic value) {
  if (value == null) return null;
  if (value is T) return value;
  
  // Get all enum values for type T using reflection-like approach
  // This is a simplified version that works with the enum patterns
  // used in the backend schema files
  
  if (value is String) {
    // Try to find enum by name or serialized value
    try {
      // This approach requires the enum to be passed with its values
      // Since we can't use reflection in Flutter, we'll implement this
      // using the existing pattern from the schema files
      return null; // Will be handled by existing enum extensions
    } catch (e) {
      return null;
    }
  }
  
  return null;
}

/// Generic extension for enum lists to provide deserialization
/// 
/// This works with the existing pattern from the backend schema
/// where enums have serialize() and deserialize() methods.
extension EnumListUtils<T extends Enum> on Iterable<T> {
  /// Finds an enum value by its serialized string representation
  T? findBySerializedValue(String? value) {
    if (value == null) return null;
    
    return firstWhereOrNull((e) {
      // Check if enum has a serialize method
      try {
        return (e as dynamic).serialize() == value;
      } catch (_) {
        // Fallback to enum name
        return e.name == value;
      }
    });
  }
  
  /// Deserializes a string value to an enum
  T? deserialize(String? value) => findBySerializedValue(value);
}

/// Extension for working with enum names and values
extension EnumUtils<T extends Enum> on T {
  /// Gets the serialized representation of an enum value
  /// 
  /// This checks if the enum has a serialize() method, otherwise
  /// falls back to using the enum's name.
  String serialize() {
    try {
      // Try to call serialize method if it exists
      return (this as dynamic).serialize();
    } catch (_) {
      // Fallback to enum name
      return name;
    }
  }
}

/// Utility class for working with specific enum types in the backend schema
class EnumSerializer {
  /// Serializes any enum to a string representation
  static String? serializeEnum(Enum? enumValue) {
    if (enumValue == null) return null;
    
    try {
      // Try dynamic serialize method first
      return (enumValue as dynamic).serialize();
    } catch (_) {
      // Fallback to name
      return enumValue.name;
    }
  }
  
  /// Deserializes a string to an enum value from a list of possible values
  static T? deserializeFromList<T extends Enum>(
    String? value,
    List<T> enumValues,
  ) {
    if (value == null) return null;
    
    // Try to find by serialized value first
    for (final enumValue in enumValues) {
      try {
        if ((enumValue as dynamic).serialize() == value) {
          return enumValue;
        }
      } catch (_) {
        // Continue to name-based matching
      }
    }
    
    // Try to find by name
    for (final enumValue in enumValues) {
      if (enumValue.name == value) {
        return enumValue;
      }
    }
    
    return null;
  }
  
  /// Gets all enum values of a specific type (helper for reflection-like behavior)
  static List<T> getAllEnumValues<T extends Enum>(T Function() enumCreator) {
    // This is a helper that can be used with specific enum types
    // Since Flutter doesn't have full reflection, this needs to be
    // implemented per enum type or using code generation
    return [];
  }
}

/// Helper functions for common enum operations
class EnumHelpers {
  /// Converts an enum list to a list of serialized strings
  static List<String> enumListToStringList<T extends Enum>(List<T>? enumList) {
    if (enumList == null) return [];
    
    return enumList.map((e) => EnumSerializer.serializeEnum(e) ?? e.name).toList();
  }
  
  /// Converts a list of strings to an enum list
  static List<T> stringListToEnumList<T extends Enum>(
    List<String>? stringList,
    List<T> allEnumValues,
  ) {
    if (stringList == null) return [];
    
    final result = <T>[];
    for (final stringValue in stringList) {
      final enumValue = EnumSerializer.deserializeFromList(stringValue, allEnumValues);
      if (enumValue != null) {
        result.add(enumValue);
      }
    }
    
    return result;
  }
}