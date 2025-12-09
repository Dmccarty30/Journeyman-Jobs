
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
  AuthError(super.message, {super.code});
}

/// Network and connectivity errors
class NetworkError extends AppException {
  NetworkError(super.message, {super.code});
}

/// Permission and authorization errors
class PermissionError extends AppException {
  PermissionError(super.message, {super.code});
}

/// Offline connectivity errors
class OfflineError extends AppException {
  OfflineError(super.message, {super.code});
}

/// Data validation errors
class ValidationError extends AppException {
  ValidationError(super.message, {super.code});
}

/// Storage and file operation errors
class StorageError extends AppException {
  StorageError(super.message, {super.code});
}
