import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Base class for all Firestore records
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, [this.snapshotData]);

  final DocumentReference reference;
  final Map<String, dynamic>? snapshotData;

  Map<String, dynamic> createData();

  void _initializeFields();
}

// Utility functions
T? castToType<T>(dynamic val) {
  if (val == null) {
    return null;
  }
  switch (T) {
    case int:
      return (val is int ? val : int.tryParse(val.toString())) as T?;
    case double:
      return (val is double ? val : double.tryParse(val.toString())) as T?;
    case String:
      return val.toString() as T;
    case bool:
      return (val is bool ? val : val.toString().toLowerCase() == 'true') as T?;
    default:
      return val as T?;
  }
}

// Enum serialization
String? serializeEnum<T>(T? value) {
  if (value == null) {
    return null;
  }
  return value.toString().split('.').last;
}

T? deserializeEnum<T>(String? value, List<T> values) {
  if (value == null) {
    return null;
  }
  return values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => values.first,
  );
}

// Map utilities
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) {
  return data;
}

Map<String, dynamic> mapToFirestore(Map<String, dynamic> data) {
  final result = <String, dynamic>{};
  data.forEach((key, value) {
    if (value != null) {
      result[key] = value;
    }
  });
  return result;
}

// Extensions
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

extension IterableExtensions<T> on Iterable<T?> {
  Iterable<T> get withoutNulls => where((e) => e != null).cast<T>();
}

// Query utilities
Stream<List<T>> queryCollection<T>(
  Query collection,
  T Function(DocumentSnapshot) fromSnapshot, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  return query.snapshots().map((s) => s.docs
      .map(fromSnapshot)
      .where((e) => e != null)
      .toList());
}

Future<List<T>> queryCollectionOnce<T>(
  Query collection,
  T Function(DocumentSnapshot) fromSnapshot, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  return query.get().then((s) => s.docs
      .map(fromSnapshot)
      .where((e) => e != null)
      .toList());
}

// Document utilities
Stream<T?> queryDocument<T>(
  DocumentReference ref,
  T Function(DocumentSnapshot) fromSnapshot,
) {
  return ref.snapshots().map((s) => s.exists ? fromSnapshot(s) : null);
}

Future<T?> queryDocumentOnce<T>(
  DocumentReference ref,
  T Function(DocumentSnapshot) fromSnapshot,
) {
  return ref.get().then((s) => s.exists ? fromSnapshot(s) : null);
}