import 'package:flutter/foundation.dart';

/// Custom exception types for crew operations
class CrewException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const CrewException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'CrewException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Specific crew operation exceptions
class CrewInvitationException extends CrewException {
  const CrewInvitationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace, required Map<String, dynamic> context,
  });
}

class CrewMessagingException extends CrewException {
  const CrewMessagingException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class CrewValidationException extends CrewException {
  const CrewValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Error codes for standardized error handling
class CrewErrorCodes {
  // General errors
  static const String unknownError = 'UNKNOWN_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String notFound = 'NOT_FOUND';
  static const String timeout = 'TIMEOUT';

  // Invitation errors
  static const String invitationNotFound = 'INVITATION_NOT_FOUND';
  static const String invitationExpired = 'INVITATION_EXPIRED';
  static const String invitationAlreadyResponded = 'INVITATION_ALREADY_RESPONDED';
  static const String cannotInviteSelf = 'CANNOT_INVITE_SELF';
  static const String userAlreadyMember = 'USER_ALREADY_MEMBER';
  static const String invitationAlreadyExists = 'INVITATION_ALREADY_EXISTS';

  // Crew errors
  static const String crewNotFound = 'CREW_NOT_FOUND';
  static const String notCrewMember = 'NOT_CREW_MEMBER';
  static const String notCrewForeman = 'NOT_CREW_FOREMAN';
  static const String cannotRemoveForeman = 'CANNOT_REMOVE_FOREMAN';
  static const String crewNameRequired = 'CREW_NAME_REQUIRED';
  static const String crewNameTooLong = 'CREW_NAME_TOO_LONG';

  // Messaging errors
  // Messaging errors
  static const String messageNotFound = 'MESSAGE_NOT_FOUND';
  static const String messageContentRequired = 'MESSAGE_CONTENT_REQUIRED';
  static const String cannotEditMessageType = 'CANNOT_EDIT_MESSAGE_TYPE';
  static const String cannotEditDeletedMessage = 'CANNOT_EDIT_DELETED_MESSAGE';
  static const String cannotEditOtherMessage = 'CANNOT_EDIT_OTHER_MESSAGE';
  static const String cannotDeleteOtherMessage = 'CANNOT_DELETE_OTHER_MESSAGE';
  // Validation errors
  static const String invalidUserId = 'INVALID_USER_ID';
  static const String invalidCrewId = 'INVALID_CREW_ID';
  static const String invalidMessageContent = 'INVALID_MESSAGE_CONTENT';
  static const String messageContentTooLong = 'MESSAGE_CONTENT_TOO_LONG';
}

/// Error handler for crew operations with user-friendly messages
class CrewErrorHandler {
  static String getErrorMessage(CrewException exception) {
    switch (exception.code) {
      // Network errors
      case CrewErrorCodes.networkError:
        return 'Network connection error. Please check your internet connection and try again.';

      case CrewErrorCodes.timeout:
        return 'Request timed out. Please try again.';

      // Permission errors
      case CrewErrorCodes.permissionDenied:
        return 'You don\'t have permission to perform this action.';

      // Not found errors
      case CrewErrorCodes.invitationNotFound:
        return 'Invitation not found. It may have been deleted or expired.';

      case CrewErrorCodes.crewNotFound:
        return 'Crew not found. It may have been deleted.';

      case CrewErrorCodes.messageNotFound:
        return 'Message not found. It may have been deleted.';

      // Invitation errors
      case CrewErrorCodes.invitationExpired:
        return 'This invitation has expired. Please ask for a new invitation.';

      case CrewErrorCodes.invitationAlreadyResponded:
        return 'You have already responded to this invitation.';

      case CrewErrorCodes.cannotInviteSelf:
        return 'You cannot invite yourself to a crew.';

      case CrewErrorCodes.userAlreadyMember:
        return 'This user is already a member of the crew.';

      case CrewErrorCodes.invitationAlreadyExists:
        return 'An invitation has already been sent to this user.';

      // Crew errors
      case CrewErrorCodes.notCrewMember:
        return 'You are not a member of this crew.';

      case CrewErrorCodes.notCrewForeman:
        return 'Only the crew foreman can perform this action.';

      case CrewErrorCodes.cannotRemoveForeman:
        return 'The crew foreman cannot be removed. Transfer the foreman role first.';

      case CrewErrorCodes.crewNameRequired:
        return 'Crew name is required.';

      case CrewErrorCodes.crewNameTooLong:
        return 'Crew name is too long. Please use a shorter name.';

      // Messaging errors
      case CrewErrorCodes.messageContentRequired:
        return 'Message content is required.';

      case CrewErrorCodes.cannotEditMessageType:
        return 'Only text messages can be edited.';

      case CrewErrorCodes.cannotEditDeletedMessage:
        return 'Cannot edit a deleted message.';

      case CrewErrorCodes.cannotEditOtherMessage:
        return 'You can only edit your own messages.';

      case CrewErrorCodes.cannotDeleteOtherMessage:
        return 'You can only delete your own messages.';

      // Validation errors
      case CrewErrorCodes.invalidUserId:
        return 'Invalid user ID. Please try again.';

      case CrewErrorCodes.invalidCrewId:
        return 'Invalid crew ID. Please try again.';

      case CrewErrorCodes.invalidMessageContent:
        return 'Invalid message content. Please check and try again.';

      case CrewErrorCodes.messageContentTooLong:
        return 'Message is too long. Please use a shorter message.';

      // Default
      default:
        return exception.message.isNotEmpty
            ? exception.message
            : 'An unexpected error occurred. Please try again.';
    }
  }

  static bool isRetryableError(CrewException exception) {
    final retryableCodes = [
      CrewErrorCodes.networkError,
      CrewErrorCodes.timeout,
      CrewErrorCodes.unknownError,
    ];

    return retryableCodes.contains(exception.code);
  }

  static bool isValidationError(CrewException exception) {
    return exception is CrewValidationException ||
           exception.code?.startsWith('INVALID_') == true ||
           exception.code?.endsWith('_REQUIRED') == true ||
           exception.code?.endsWith('_TOO_LONG') == true;
  }
}

/// Validation helpers for crew operations
class CrewValidation {
  static const int maxCrewNameLength = 50;
  static const int maxMessageContentLength = 1000;
  static const int maxInvitationMessageLength = 500;

  /// Validate crew name
  static String? validateCrewName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return CrewErrorCodes.crewNameRequired;
    }

    final trimmedName = name.trim();

    if (trimmedName.length > maxCrewNameLength) {
      return CrewErrorCodes.crewNameTooLong;
    }

    // Check for invalid characters
    if (trimmedName.contains(RegExp(r'[<>\{\}\[\]\|\\]'))) {
      return 'Crew name contains invalid characters';
    }

    return null; // Valid
  }

  /// Validate user ID
  static String? validateUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return CrewErrorCodes.invalidUserId;
    }

    if (userId.length < 10) {
      return 'Invalid user ID format';
    }

    return null; // Valid
  }

  /// Validate crew ID
  static String? validateCrewId(String? crewId) {
    if (crewId == null || crewId.trim().isEmpty) {
      return CrewErrorCodes.invalidCrewId;
    }

    if (crewId.length < 10) {
      return 'Invalid crew ID format';
    }

    return null; // Valid
  }

  /// Validate message content
  static String? validateMessageContent(String? content, {bool allowEmpty = false}) {
    if (content == null) {
      return CrewErrorCodes.invalidMessageContent;
    }

    final trimmedContent = content.trim();

    if (!allowEmpty && trimmedContent.isEmpty) {
      return CrewErrorCodes.messageContentRequired;
    }

    if (trimmedContent.length > maxMessageContentLength) {
      return CrewErrorCodes.messageContentTooLong;
    }

    // Check for potentially harmful content
    if (trimmedContent.contains(RegExp(r'<script|javascript:|data:'))) {
      return 'Message contains potentially harmful content';
    }

    return null; // Valid
  }

  /// Validate invitation message
  static String? validateInvitationMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedMessage = message.trim();

    if (trimmedMessage.length > maxInvitationMessageLength) {
      return 'Invitation message is too long';
    }

    // Check for potentially harmful content
    if (trimmedMessage.contains(RegExp(r'<script|javascript:|data:'))) {
      return 'Invitation message contains potentially harmful content';
    }

    return null; // Valid
  }

  /// Validate file size for media uploads
  static String? validateFileSize(int bytes, {int maxSizeBytes = 10 * 1024 * 1024}) {
    if (bytes <= 0) {
      return 'File size is invalid';
    }

    if (bytes > maxSizeBytes) {
      final maxSizeMB = (maxSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must be less than $maxSizeMB MB';
    }

    return null; // Valid
  }

  /// Validate email format
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return null; // Optional field
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Invalid email format';
    }

    return null; // Valid
  }

  /// Validate phone number format
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Invalid phone number format';
    }

    return null; // Valid
  }
}

/// Error reporting utility
class CrewErrorReporter {
  static void reportError(
    CrewException exception, {
    Map<String, dynamic>? context,
    String? userId,
    String? crewId,
  }) {
    // Log the error
    if (context != null) {
    }
    if (exception.originalError != null) {
    }
    if (exception.stackTrace != null) {
    }

    // In a real app, you would also send this to your error tracking service
    // like Firebase Crashlytics, Sentry, etc.
  }

  static void reportValidationErrors(
    List<String> errors, {
    Map<String, dynamic>? context,
    String? userId,
    String? crewId,
  }) {
    if (errors.isEmpty) return;

    final exception = CrewValidationException(
      'Validation failed: ${errors.join(', ')}',
    );

    reportError(
      exception,
      context: context,
      userId: userId,
      crewId: crewId,
    );
  }
}

/// Error handling mixin for crew operations
mixin CrewErrorHandlingMixin {
  /// Handle crew operation errors with user feedback
  Future<T?> handleCrewOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    String? userId,
    String? crewId,
    VoidCallback? onError,
    VoidCallback? onSuccess,
  }) async {
    try {
      final result = await operation();
      onSuccess?.call();
      return result;
    } catch (e) {
      CrewException crewException;

      if (e is CrewException) {
        crewException = e;
      } else {
        crewException = CrewException(
          e.toString(),
          code: CrewErrorCodes.unknownError,
          originalError: e,
        );
      }

      // Report the error
      CrewErrorReporter.reportError(
        crewException,
        context: {'operation': operationName},
        userId: userId,
        crewId: crewId,
      );

      // Call error callback
      onError?.call();

      // In a UI context, you would show a snackbar or dialog
      // This mixin can be used in different contexts, so we don't show UI here
      return null;
    }
  }

  /// Validate input and throw appropriate exception if invalid
  void validateOrThrow<T>(
    T? value,
    String? Function(T?) validator, {
    String fieldName = 'Field',
  }) {
    final error = validator.call(value);
    if (error != null) {
      throw CrewValidationException('$fieldName: $error');
    }
  }

  /// Validate multiple inputs
  void validateMultiple(Map<String, dynamic> fields, Map<String, String? Function(dynamic)> validators) {
    final errors = <String>[];

    validators.forEach((field, validator) {
      final value = fields[field];
      final error = validator(value);
      if (error != null) {
        errors.add('$field: $error');
      }
    });

    if (errors.isNotEmpty) {
      throw CrewValidationException('Validation failed: ${errors.join(', ')}');
    }
  }
}