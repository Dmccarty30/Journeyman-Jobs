import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

import '../../utils/enum_utils.dart';
import 'firestore_util.dart' hide deserializeEnum;

export 'package:flutter/material.dart' show Color, Colors;
export 'package:from_css_color/from_css_color.dart';
export 'enums/enums.dart';
export '../../utils/color_extensions.dart';

typedef StructBuilder<T> = T Function(Map<String, dynamic> data);

abstract class BaseStruct {
  Map<String, dynamic> toSerializableMap();
  String serialize() => json.encode(toSerializableMap());
}

List<T>? getStructList<T>(
  dynamic value,
  StructBuilder<T> structBuilder,
) =>
    value is! List
        ? null
        : value
            .whereType<Map<String, dynamic>>()
            .map((e) => structBuilder(e))
            .toList();

List<T>? getEnumList<T>(
  List<dynamic>? data,
  List<T> enumValues,
) =>
    data?.map((e) => deserializeEnum<T>(e, enumValues))
        .where((e) => e != null)
        .cast<T>()
        .toList();

Color? getSchemaColor(dynamic value) => value is String
    ? fromCssColor(value)
    : value is Color
        ? value
        : null;

List<Color>? getColorsList(List<dynamic>? data) =>
    data?.map((e) => castToType<Color>(e))
        .where((e) => e != null)
        .cast<Color>()
        .toList();

extension MapExtensions on Map<String, dynamic> {
  Map<String, dynamic> get withoutNulls {
    final result = <String, dynamic>{};
    forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }
}

List<T>? getDataList<T>(dynamic value) =>
    value is! List ? null : value.map((e) => castToType<T>(e)!).toList();