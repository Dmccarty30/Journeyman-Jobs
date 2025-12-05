// This file is auto generated, do not modify manually.

import 'package:collection/collection.dart';

extension EnumExtension on Enum {
  String serialize() => name;
}

T? deserializeEnum<T>(String? value, Iterable<T> values) {
  if (value == null) return null;
  return values.firstWhereOrNull((e) => e.toString().split('.').last == value);
}