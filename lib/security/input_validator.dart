/// Security input validation layer for Journeyman Jobs app.
///
/// Provides comprehensive validation and sanitization for:
/// - Firestore query parameters (prevent injection attacks)
/// - Email and password validation
/// - String length and format validation
/// - Number range validation
/// - URL and special character sanitization
///
/// All validators throw [ValidationException] on failure with descriptive messages.
///
/// Example usage:
/// ```dart
/// // Validate email
/// final email = InputValidator.sanitizeEmail('user@example.com');
///
/// // Validate Firestore field
/// final field = InputValidator.sanitizeFirestoreField('userName');
///
/// // Validate password
/// InputValidator.validatePassword('SecurePass123!');
/// ```
library;

import 'package:meta/meta.dart';

/// Exception thrown when input validation fails.
///
/// Contains a descriptive message about what validation failed and why.
class ValidationException implements Exception {
  final String message;
  final String? fieldName;

  const ValidationException(this.message, {this.fieldName});

  @override
  String toString() => fieldName != null
      ? 'ValidationException in $fieldName: $message'
      : 'ValidationException: $message';
}

/// Comprehensive input validator for security-critical operations.
///
/// All methods are static for easy access without instantiation.
/// Validators throw [ValidationException] on failure.
@immutable
class InputValidator {
  const InputValidator._(); // Prevent instantiation

  // ============================================================================
  // EMAIL VALIDATION
  // ============================================================================

  /// Email validation regex (RFC 5322 simplified)
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  /// Validates and sanitizes an email address.
  ///
  /// Requirements:
  /// - Must match standard email format (RFC 5322 simplified)
  /// - Maximum length: 254 characters
  /// - Must contain @ symbol with valid domain
  ///
  /// Returns the trimmed and lowercased email.
  ///
  /// Throws [ValidationException] if:
  /// - Email is empty
  /// - Email is too long (>254 chars)
  /// - Email format is invalid
  ///
  /// Example:
  /// ```dart
  /// final email = InputValidator.sanitizeEmail('  User@Example.COM  ');
  /// // Returns: 'user@example.com'
  /// ```
  static String sanitizeEmail(String email) {
    final trimmed = email.trim().toLowerCase();

    if (trimmed.isEmpty) {
      throw const ValidationException('Email cannot be empty', fieldName: 'email');
    }

    if (trimmed.length > 254) {
      throw const ValidationException(
        'Email is too long (max 254 characters)',
        fieldName: 'email',
      );
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      throw const ValidationException(
        'Invalid email format',
        fieldName: 'email',
      );
    }

    return trimmed;
  }

  // ============================================================================
  // PASSWORD VALIDATION
  // ============================================================================

  /// Validates password strength.
  ///
  /// Requirements:
  /// - Minimum length: 8 characters
  /// - Maximum length: 128 characters
  /// - Must contain at least one uppercase letter
  /// - Must contain at least one lowercase letter
  /// - Must contain at least one number
  /// - Must contain at least one special character (!@#$%^&*()_+-=[]{}|;:,.<>?)
  ///
  /// Throws [ValidationException] if password doesn't meet requirements.
  ///
  /// Note: This method validates but does NOT sanitize (passwords should not be modified).
  ///
  /// Example:
  /// ```dart
  /// InputValidator.validatePassword('SecurePass123!'); // Valid
  /// InputValidator.validatePassword('weak'); // Throws ValidationException
  /// ```
  static void validatePassword(String password) {
    if (password.isEmpty) {
      throw const ValidationException(
        'Password cannot be empty',
        fieldName: 'password',
      );
    }

    if (password.length < 8) {
      throw const ValidationException(
        'Password must be at least 8 characters long',
        fieldName: 'password',
      );
    }

    if (password.length > 128) {
      throw const ValidationException(
        'Password is too long (max 128 characters)',
        fieldName: 'password',
      );
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw const ValidationException(
        'Password must contain at least one uppercase letter',
        fieldName: 'password',
      );
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      throw const ValidationException(
        'Password must contain at least one lowercase letter',
        fieldName: 'password',
      );
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      throw const ValidationException(
        'Password must contain at least one number',
        fieldName: 'password',
      );
    }

    if (!password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      throw const ValidationException(
        'Password must contain at least one special character',
        fieldName: 'password',
      );
    }
  }

  // ============================================================================
  // FIRESTORE FIELD SANITIZATION (Injection Prevention)
  // ============================================================================

  /// Allowed characters for Firestore field names (alphanumeric + underscore)
  static final RegExp _firestoreFieldRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  /// Sanitizes Firestore field names to prevent injection attacks.
  ///
  /// Requirements:
  /// - Only alphanumeric characters and underscores allowed
  /// - Maximum length: 1500 characters (Firestore limit)
  /// - Cannot be empty
  ///
  /// Returns the sanitized field name.
  ///
  /// Throws [ValidationException] if:
  /// - Field name is empty
  /// - Field name is too long
  /// - Field name contains invalid characters
  ///
  /// Example:
  /// ```dart
  /// final field = InputValidator.sanitizeFirestoreField('user_name');
  /// // Returns: 'user_name'
  ///
  /// InputValidator.sanitizeFirestoreField('user.name'); // Throws (invalid char)
  /// ```
  static String sanitizeFirestoreField(String fieldName) {
    final trimmed = fieldName.trim();

    if (trimmed.isEmpty) {
      throw const ValidationException(
        'Field name cannot be empty',
        fieldName: 'firestoreField',
      );
    }

    if (trimmed.length > 1500) {
      throw const ValidationException(
        'Field name is too long (max 1500 characters)',
        fieldName: 'firestoreField',
      );
    }

    if (!_firestoreFieldRegex.hasMatch(trimmed)) {
      throw const ValidationException(
        'Field name contains invalid characters (only alphanumeric and underscore allowed)',
        fieldName: 'firestoreField',
      );
    }

    return trimmed;
  }

  /// Sanitizes Firestore document IDs.
  ///
  /// Requirements:
  /// - Must not contain: / (forward slash)
  /// - Maximum length: 1500 characters (Firestore limit)
  /// - Cannot be empty
  /// - Cannot be "." or ".."
  ///
  /// Returns the sanitized document ID.
  ///
  /// Throws [ValidationException] if validation fails.
  ///
  /// Example:
  /// ```dart
  /// final docId = InputValidator.sanitizeDocumentId('user-123');
  /// // Returns: 'user-123'
  /// ```
  static String sanitizeDocumentId(String documentId) {
    final trimmed = documentId.trim();

    if (trimmed.isEmpty) {
      throw const ValidationException(
        'Document ID cannot be empty',
        fieldName: 'documentId',
      );
    }

    if (trimmed == '.' || trimmed == '..') {
      throw const ValidationException(
        'Document ID cannot be "." or ".."',
        fieldName: 'documentId',
      );
    }

    if (trimmed.length > 1500) {
      throw const ValidationException(
        'Document ID is too long (max 1500 characters)',
        fieldName: 'documentId',
      );
    }

    if (trimmed.contains('/')) {
      throw const ValidationException(
        'Document ID cannot contain forward slash (/)',
        fieldName: 'documentId',
      );
    }

    return trimmed;
  }

  /// Sanitizes Firestore collection paths.
  ///
  /// Validates that the collection path has the correct structure:
  /// - Odd number of segments (collections are at odd positions)
  /// - Each segment is a valid document ID or field name
  /// - No empty segments
  ///
  /// Returns the sanitized collection path.
  ///
  /// Example:
  /// ```dart
  /// final path = InputValidator.sanitizeCollectionPath('users/123/settings');
  /// // Returns: 'users/123/settings'
  /// ```
  static String sanitizeCollectionPath(String path) {
    final trimmed = path.trim();

    if (trimmed.isEmpty) {
      throw const ValidationException(
        'Collection path cannot be empty',
        fieldName: 'collectionPath',
      );
    }

    final segments = trimmed.split('/');

    // Collection paths must have odd number of segments
    if (segments.length.isEven) {
      throw const ValidationException(
        'Invalid collection path (must have odd number of segments)',
        fieldName: 'collectionPath',
      );
    }

    // Validate each segment
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i].trim();

      if (segment.isEmpty) {
        throw const ValidationException(
          'Collection path contains empty segment',
          fieldName: 'collectionPath',
        );
      }

      // Validate document ID segments (even indices)
      if (i.isEven) {
        try {
          sanitizeFirestoreField(segment);
        } catch (e) {
          throw ValidationException(
            'Invalid collection name at position $i: ${(e as ValidationException).message}',
            fieldName: 'collectionPath',
          );
        }
      } else {
        // Validate document ID segments (odd indices)
        try {
          sanitizeDocumentId(segment);
        } catch (e) {
          throw ValidationException(
            'Invalid document ID at position $i: ${(e as ValidationException).message}',
            fieldName: 'collectionPath',
          );
        }
      }
    }

    return trimmed;
  }

  // ============================================================================
  // STRING VALIDATION
  // ============================================================================

  /// Validates string length and sanitizes content.
  ///
  /// Parameters:
  /// - value: The string to validate
  /// - minLength: Minimum allowed length (inclusive, default: 1)
  /// - maxLength: Maximum allowed length (inclusive, default: 1000)
  /// - allowEmpty: Whether empty strings are allowed (default: false)
  /// - trim: Whether to trim whitespace (default: true)
  /// - fieldName: Name of the field for error messages
  ///
  /// Returns the sanitized string (trimmed if trim=true).
  ///
  /// Throws [ValidationException] if validation fails.
  ///
  /// Example:
  /// ```dart
  /// final name = InputValidator.validateString(
  ///   '  John Doe  ',
  ///   minLength: 2,
  ///   maxLength: 50,
  ///   fieldName: 'userName',
  /// );
  /// // Returns: 'John Doe'
  /// ```
  static String validateString(
    String value, {
    int minLength = 1,
    int maxLength = 1000,
    bool allowEmpty = false,
    bool trim = true,
    String fieldName = 'string',
  }) {
    final processed = trim ? value.trim() : value;

    if (!allowEmpty && processed.isEmpty) {
      throw ValidationException(
        '$fieldName cannot be empty',
        fieldName: fieldName,
      );
    }

    if (processed.length < minLength) {
      throw ValidationException(
        '$fieldName must be at least $minLength characters',
        fieldName: fieldName,
      );
    }

    if (processed.length > maxLength) {
      throw ValidationException(
        '$fieldName is too long (max $maxLength characters)',
        fieldName: fieldName,
      );
    }

    return processed;
  }

  /// Sanitizes strings for display (prevents XSS-like issues in logs).
  ///
  /// Removes or escapes potentially dangerous characters:
  /// - Null bytes
  /// - Control characters
  /// - Zero-width characters
  ///
  /// Note: This is primarily for logging safety, not for security against
  /// sophisticated attacks. Always use proper output encoding in UI.
  ///
  /// Example:
  /// ```dart
  /// final safe = InputValidator.sanitizeForDisplay('User\x00Input');
  /// // Returns: 'UserInput' (null byte removed)
  /// ```
  static String sanitizeForDisplay(String value) {
    return value
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control chars
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), ''); // Remove zero-width
  }

  // ============================================================================
  // NUMBER VALIDATION
  // ============================================================================

  /// Validates integer within specified range.
  ///
  /// Parameters:
  /// - value: The integer to validate
  /// - min: Minimum allowed value (inclusive)
  /// - max: Maximum allowed value (inclusive)
  /// - fieldName: Name of the field for error messages
  ///
  /// Throws [ValidationException] if value is out of range.
  ///
  /// Example:
  /// ```dart
  /// InputValidator.validateIntRange(5, min: 1, max: 10); // Valid
  /// InputValidator.validateIntRange(15, min: 1, max: 10); // Throws
  /// ```
  static void validateIntRange(
    int value, {
    required int min,
    required int max,
    String fieldName = 'number',
  }) {
    if (value < min || value > max) {
      throw ValidationException(
        '$fieldName must be between $min and $max (got $value)',
        fieldName: fieldName,
      );
    }
  }

  /// Validates double within specified range.
  ///
  /// Parameters:
  /// - value: The double to validate
  /// - min: Minimum allowed value (inclusive)
  /// - max: Maximum allowed value (inclusive)
  /// - fieldName: Name of the field for error messages
  ///
  /// Throws [ValidationException] if value is out of range or NaN/Infinity.
  ///
  /// Example:
  /// ```dart
  /// InputValidator.validateDoubleRange(5.5, min: 0.0, max: 10.0); // Valid
  /// InputValidator.validateDoubleRange(double.infinity, min: 0.0, max: 10.0); // Throws
  /// ```
  static void validateDoubleRange(
    double value, {
    required double min,
    required double max,
    String fieldName = 'number',
  }) {
    if (value.isNaN) {
      throw ValidationException(
        '$fieldName cannot be NaN',
        fieldName: fieldName,
      );
    }

    if (value.isInfinite) {
      throw ValidationException(
        '$fieldName cannot be infinite',
        fieldName: fieldName,
      );
    }

    if (value < min || value > max) {
      throw ValidationException(
        '$fieldName must be between $min and $max (got $value)',
        fieldName: fieldName,
      );
    }
  }

  // ============================================================================
  // IBEW-SPECIFIC VALIDATION
  // ============================================================================

  /// Validates IBEW local union number.
  ///
  /// Requirements:
  /// - Must be positive integer
  /// - Valid range: 1 to 9999 (covers all existing IBEW locals)
  ///
  /// Throws [ValidationException] if invalid.
  ///
  /// Example:
  /// ```dart
  /// InputValidator.validateLocalNumber(123); // Valid
  /// InputValidator.validateLocalNumber(0); // Throws
  /// ```
  static void validateLocalNumber(int localNumber) {
    validateIntRange(
      localNumber,
      min: 1,
      max: 9999,
      fieldName: 'localNumber',
    );
  }

  /// Validates job classification.
  ///
  /// Valid classifications:
  /// - Inside Wireman
  /// - Journeyman Lineman
  /// - Tree Trimmer
  /// - Equipment Operator
  /// - Inside Journeyman Electrician
  ///
  /// Returns the validated classification.
  ///
  /// Throws [ValidationException] if invalid.
  static String validateClassification(String classification) {
    const validClassifications = {
      'Inside Wireman',
      'Journeyman Lineman',
      'Tree Trimmer',
      'Equipment Operator',
      'Inside Journeyman Electrician',
    };

    final trimmed = classification.trim();

    if (!validClassifications.contains(trimmed)) {
      throw ValidationException(
        'Invalid classification. Must be one of: ${validClassifications.join(", ")}',
        fieldName: 'classification',
      );
    }

    return trimmed;
  }

  /// Validates hourly wage.
  ///
  /// Requirements:
  /// - Must be positive
  /// - Reasonable range: $1.00 to $999.99 per hour
  ///
  /// Throws [ValidationException] if invalid.
  static void validateWage(double wage) {
    validateDoubleRange(
      wage,
      min: 1.0,
      max: 999.99,
      fieldName: 'wage',
    );
  }
}
