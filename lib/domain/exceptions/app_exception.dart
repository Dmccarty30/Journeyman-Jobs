
/// Base class for all custom exceptions in the application.
///
/// Provides a structured way to handle errors with a message and an optional code.
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Authentication-related errors
class AuthError extends AppException {
  AuthError(String message, {String? code}) : super(message, code: code);
}

/// Network and connectivity errors
class NetworkError extends AppException {
  NetworkError(String message, {String? code}) : super(message, code: code);
}

/// Permission and authorization errors
class PermissionError extends AppException {
  PermissionError(String message, {String? code}) : super(message, code: code);
}

/// Offline connectivity errors
class OfflineError extends AppException {
  OfflineError(String message, {String? code}) : super(message, code: code);
}

/// Data validation errors
class ValidationError extends AppException {
  ValidationError(String message, {String? code}) : super(message, code: code);
}

/// Storage and file operation errors
class StorageError extends AppException {
  StorageError(String message, {String? code}) : super(message, code: code);
}
