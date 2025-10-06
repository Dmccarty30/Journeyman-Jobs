// This file is auto generated, do not modify manually.

import 'package:collection/collection.dart';

/// An extension on the base [Enum] class to provide serialization capabilities.
extension EnumExtension on Enum {
  /// Serializes the enum value to its string representation.
  ///
  /// This is a convenience method that returns the `name` property of the enum,
  /// which is the string representation of the enum value itself.
  /// Example: `MyEnum.myValue.serialize()` returns `'myValue'`.
  String serialize() => name;
}

/// A generic function to deserialize a string into an enum value of type [T].
///
/// It safely handles `null` values and finds the corresponding enum value from
/// a list of possible [values].
///
/// - [value]: The string to deserialize.
/// - [values]: An iterable of all possible values for the enum [T] (e.g., `MyEnum.values`).
///
/// Returns the deserialized enum value of type [T], or `null` if the string
/// does not match any enum value or is `null`.
T? deserializeEnum<T>(String? value, Iterable<T> values) {
  if (value == null) return null;
  return values.firstWhereOrNull((e) => e.toString().split('.').last == value);
}