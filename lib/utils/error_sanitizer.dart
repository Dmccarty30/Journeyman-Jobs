import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Utility class to sanitize errors for user display
class ErrorSanitizer {
  /// Sanitizes an error into a user-friendly message
  static String sanitizeError(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    // Handle Firebase Auth exceptions
    if (error is FirebaseAuthException) {
      return _getUserFriendlyAuthError(error.code);
    }

    // Handle Firebase exceptions
    if (error is FirebaseException) {
      return _getUserFriendlyFirebaseError(error.code);
    }

    // Handle platform exceptions
    if (error is PlatformException) {
      return _getUserFriendlyPlatformError(error.code);
    }

    // Handle network errors
    if (error.toString().toLowerCase().contains('network')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    // Handle timeout errors
    if (error.toString().toLowerCase().contains('timeout')) {
      return 'The operation timed out. Please try again.';
    }

    // Default generic message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get user-friendly auth error messages
  static String _getUserFriendlyAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  /// Get user-friendly Firebase error messages
  static String _getUserFriendlyFirebaseError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      case 'data-loss':
        return 'Data error occurred. Please try again.';
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'failed-precondition':
        return 'Operation failed. Please try again.';
      case 'aborted':
        return 'Operation was cancelled. Please try again.';
      case 'out-of-range':
        return 'Invalid operation. Please check your input.';
      case 'unimplemented':
        return 'This feature is not available yet.';
      case 'internal':
        return 'An internal error occurred. Please try again.';
      case 'deadline-exceeded':
        return 'Operation timed out. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Get user-friendly platform error messages
  static String _getUserFriendlyPlatformError(String code) {
    switch (code) {
      case 'channel-error':
        return 'Communication error. Please restart the app.';
      case 'timeout':
        return 'Operation timed out. Please try again.';
      default:
        return 'A system error occurred. Please try again.';
    }
  }

  /// Sanitizes error for logging purposes (removes sensitive data)
  static String sanitizeForLogging(dynamic error) {
    if (error == null) return 'Unknown error';
    
    String errorString = error.toString();
    
    // Remove potential sensitive data patterns
    // Remove email addresses
    errorString = errorString.replaceAll(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), '[EMAIL]');
    
    // Remove phone numbers
    errorString = errorString.replaceAll(RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), '[PHONE]');
    
    // Remove potential API keys or tokens (long alphanumeric strings)
    errorString = errorString.replaceAll(RegExp(r'\b[a-zA-Z0-9]{32,}\b'), '[TOKEN]');
    
    return errorString;
  }
}