import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => code != null ? '$code: $message' : message;
}

/// Records errors to Firebase Crashlytics for monitoring
Future<void> recordError(dynamic exception, StackTrace stackTrace, {bool fatal = false}) async {
  try {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace, fatal: fatal);
  } catch (e) {
    debugPrint('Failed to record error to Crashlytics: $e');
  }
}