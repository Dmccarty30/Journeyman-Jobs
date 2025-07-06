/// Utility functions for type casting and conversion.
/// 
/// This file provides safe type conversion utilities that replace
/// FlutterFlow's type utilities while maintaining the same functionality.

/// Safely casts a dynamic value to the specified type T.
/// 
/// Returns null if the conversion is not possible or if the value is null.
/// Handles common type conversions and maintains type safety.
/// 
/// Example usage:
/// ```dart
/// final stringValue = castToType<String>(dynamicValue);
/// final intValue = castToType<int>(42.5); // Returns 42
/// final boolValue = castToType<bool>("true"); // Returns true
/// ```
T? castToType<T>(dynamic value) {
  if (value == null) return null;
  if (value is T) return value;
  
  try {
    // Handle String conversions
    if (T == String) {
      return value.toString() as T?;
    }
    
    // Handle int conversions
    if (T == int) {
      if (value is num) return value.toInt() as T?;
      if (value is String) return int.tryParse(value) as T?;
    }
    
    // Handle double conversions
    if (T == double) {
      if (value is num) return value.toDouble() as T?;
      if (value is String) return double.tryParse(value) as T?;
    }
    
    // Handle bool conversions
    if (T == bool) {
      if (value is String) {
        final lowerValue = value.toLowerCase();
        if (lowerValue == 'true' || lowerValue == '1') return true as T?;
        if (lowerValue == 'false' || lowerValue == '0') return false as T?;
      }
      if (value is int) {
        return (value != 0) as T?;
      }
    }
    
    // Handle DateTime conversions
    if (T == DateTime) {
      if (value is String) {
        return DateTime.tryParse(value) as T?;
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value) as T?;
      }
    }
    
    // Handle List conversions
    if (T.toString().startsWith('List<')) {
      if (value is List) {
        return value as T?;
      }
    }
    
    // Handle Map conversions
    if (T.toString().startsWith('Map<')) {
      if (value is Map) {
        return value as T?;
      }
    }
    
  } catch (e) {
    // If any conversion fails, return null instead of throwing
    return null;
  }
  
  // If no conversion is possible, return null
  return null;
}

/// Safely converts a value to an integer.
/// 
/// This is a convenience function that wraps castToType<int> with
/// additional handling for common scenarios.
int? safeInt(dynamic value, {int? defaultValue}) {
  final result = castToType<int>(value);
  return result ?? defaultValue;
}

/// Safely converts a value to a double.
/// 
/// This is a convenience function that wraps castToType<double> with
/// additional handling for common scenarios.
double? safeDouble(dynamic value, {double? defaultValue}) {
  final result = castToType<double>(value);
  return result ?? defaultValue;
}

/// Safely converts a value to a string.
/// 
/// This is a convenience function that wraps castToType<String> with
/// additional handling for common scenarios.
String? safeString(dynamic value, {String? defaultValue}) {
  final result = castToType<String>(value);
  return result ?? defaultValue;
}

/// Safely converts a value to a boolean.
/// 
/// This is a convenience function that wraps castToType<bool> with
/// additional handling for common scenarios.
bool? safeBool(dynamic value, {bool? defaultValue}) {
  final result = castToType<bool>(value);
  return result ?? defaultValue;
}

/// Converts a dynamic value to a Map<String, dynamic> if possible.
/// 
/// This is commonly used when working with Firestore documents
/// and JSON data structures.
Map<String, dynamic>? toStringMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

/// Converts a dynamic value to a List if possible.
/// 
/// This is commonly used when working with Firestore arrays
/// and JSON list structures.
List<T>? toTypedList<T>(dynamic value) {
  if (value == null) return null;
  if (value is List<T>) return value;
  if (value is List) {
    try {
      return value.cast<T>();
    } catch (e) {
      // If direct casting fails, try converting each element
      final result = <T>[];
      for (final item in value) {
        final converted = castToType<T>(item);
        if (converted != null) {
          result.add(converted);
        }
      }
      return result.isNotEmpty ? result : null;
    }
  }
  return null;
}