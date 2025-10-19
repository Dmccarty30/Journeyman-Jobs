
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

/// Exception thrown when attempting an operation that requires authentication
/// while the user is not currently authenticated.
///
/// This exception should trigger a redirect to the login screen.
/// Used for defense-in-depth security at the data provider level.
///
/// Example usage:
/// ```dart
/// if (currentUser == null) {
///   throw UnauthenticatedException(
///     'User must be authenticated to access IBEW locals directory',
///   );
/// }
/// ```
class UnauthenticatedException extends AuthError {
  UnauthenticatedException(
    String message, {
    String? code = 'unauthenticated',
  }) : super(message, code: code);

  @override
  String toString() => 'UnauthenticatedException: $message';
}

/// Exception thrown when an authenticated user lacks required permissions
/// for a specific operation.
///
/// Used to differentiate between unauthenticated users and authenticated users
/// who lack necessary permissions.
///
/// Example usage:
/// ```dart
/// if (!hasPermission) {
///   throw InsufficientPermissionsException(
///     'You do not have permission to delete this crew',
///     requiredPermission: 'crew:delete',
///   );
/// }
/// ```
class InsufficientPermissionsException extends PermissionError {
  final String requiredPermission;

  InsufficientPermissionsException(
    String message, {
    required this.requiredPermission,
    String? code = 'insufficient-permissions',
  }) : super(message, code: code);

  @override
  String toString() =>
      'InsufficientPermissionsException: $message (requires: $requiredPermission)';
}
