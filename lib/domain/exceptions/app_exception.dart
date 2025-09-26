
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
