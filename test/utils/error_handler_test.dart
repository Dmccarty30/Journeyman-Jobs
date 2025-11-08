import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../lib/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    setUp(() {
      // Reset error handler state before each test
      ErrorHandler.resetTestMode();
    });

    group('handleAsyncOperation', () {
      test('should return result when operation succeeds', () async {
        // Arrange
        const expectedResult = 'success';

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => expectedResult,
          operationName: 'test_operation',
          errorMessage: 'Failed to test',
          showToast: false,
        );

        // Assert
        expect(result, equals(expectedResult));
      });

      test('should return null when operation throws', () async {
        // Arrange
        const testError = Exception('Test error');

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw testError,
          operationName: 'test_operation',
          errorMessage: 'Failed to test',
          showToast: false,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return default value when operation throws and default is provided', () async {
        // Arrange
        const defaultValue = 'default';

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw Exception('Test error'),
          operationName: 'test_operation',
          errorMessage: 'Failed to test',
          defaultValue: defaultValue,
          showToast: false,
        );

        // Assert
        expect(result, equals(defaultValue));
      });

      test('should handle network errors correctly', () async {
        // Arrange
        final networkError = SocketException('Network unreachable');

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw networkError,
          operationName: 'network_operation',
          errorMessage: 'Network operation failed',
          showToast: false,
        );

        // Assert
        expect(result, isNull);
      });

      test('should handle Firebase auth errors correctly', () async {
        // Arrange
        final authError = FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found',
        );

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw authError,
          operationName: 'auth_operation',
          errorMessage: 'Authentication failed',
          showToast: false,
        );

        // Assert
        expect(result, isNull);
      });

      test('should handle Firestore errors correctly', () async {
        // Arrange
        final firestoreError = FirebaseException(
          code: 'permission-denied',
          message: 'Permission denied',
        );

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw firestoreError,
          operationName: 'firestore_operation',
          errorMessage: 'Database operation failed',
          showToast: false,
        );

        // Assert
        expect(result, isNull);
      });

      test('should preserve context information', () async {
        // Arrange
        final context = {'userId': 'test123', 'attempt': 1};
        var capturedContext;

        // Act
        await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw Exception('Test error'),
          operationName: 'context_test',
          errorMessage: 'Failed',
          showToast: false,
          context: context,
          onCaptureContext: (ctx) => capturedContext = ctx,
        );

        // Assert
        expect(capturedContext, isNotNull);
        expect(capturedContext['userId'], equals('test123'));
        expect(capturedContext['attempt'], equals(1));
      });
    });

    group('getErrorMessage', () {
      test('should return friendly message for SocketException', () {
        // Arrange
        final error = SocketException('Connection refused');

        // Act
        final message = ErrorHandler.getErrorMessage(error);

        // Assert
        expect(message, contains('network'));
        expect(message, contains('connection'));
      });

      test('should return friendly message for TimeoutException', () {
        // Arrange
        final error = TimeoutException('Request timeout', const Duration(seconds: 30));

        // Act
        final message = ErrorHandler.getErrorMessage(error);

        // Assert
        expect(message, contains('timeout'));
      });

      test('should return friendly message for FirebaseAuthException', () {
        // Arrange
        final error = FirebaseAuthException(
          code: 'user-disabled',
          message: 'User account has been disabled',
        );

        // Act
        final message = ErrorHandler.getErrorMessage(error);

        // Assert
        expect(message, contains('disabled'));
        expect(message, contains('contact support'));
      });

      test('should return friendly message for FirebaseException', () {
        // Arrange
        final error = FirebaseException(
          code: 'unavailable',
          message: 'Service unavailable',
        );

        // Act
        final message = ErrorHandler.getErrorMessage(error);

        // Assert
        expect(message, contains('unavailable'));
        expect(message, contains('try again'));
      });

      test('should return generic message for unknown errors', () {
        // Arrange
        final error = Exception('Unknown error');

        // Act
        final message = ErrorHandler.getErrorMessage(error);

        // Assert
        expect(message, contains('unexpected error'));
      });

      test('should handle error with code field', () {
        // Arrange
        final error = PlatformException(
          code: 'ERROR_CODE',
          message: 'Error with code',
        );

        // Act
        final message = ErrorHandler.getErrorMessage(error);

        // Assert
        expect(message, contains('ERROR_CODE'));
      });
    });

    group('getErrorCategory', () {
      test('should categorize network errors correctly', () {
        // Arrange & Act
        final category1 = ErrorHandler.getErrorCategory(SocketException('Network error'));
        final category2 = ErrorHandler.getErrorCategory(TimeoutException('Timeout'));
        final category3 = ErrorHandler.getErrorCategory(
          Exception('Network connection failed')
        );

        // Assert
        expect(category1, equals(ErrorCategory.network));
        expect(category2, equals(ErrorCategory.network));
        expect(category3, equals(ErrorCategory.network));
      });

      test('should categorize permission errors correctly', () {
        // Arrange & Act
        final category1 = ErrorHandler.getErrorCategory(
          Exception('Permission denied')
        );
        final category2 = ErrorHandler.getErrorCategory(
          Exception('Unauthorized access')
        );
        final category3 = ErrorHandler.getErrorCategory(
          FirebaseAuthException(code: 'permission-denied', message: '')
        );

        // Assert
        expect(category1, equals(ErrorCategory.permission));
        expect(category2, equals(ErrorCategory.permission));
        expect(category3, equals(ErrorCategory.permission));
      });

      test('should categorize validation errors correctly', () {
        // Arrange & Act
        final category = ErrorHandler.getErrorCategory(
          Exception('Validation failed')
        );

        // Assert
        expect(category, equals(ErrorCategory.validation));
      });

      test('should categorize unknown errors as system', () {
        // Arrange & Act
        final category = ErrorHandler.getErrorCategory(
          Exception('Unknown system error')
        );

        // Assert
        expect(category, equals(ErrorCategory.system));
      });
    });

    group('Test Mode', () {
      test('should track errors in test mode', () async {
        // Arrange
        ErrorHandler.enableTestMode();

        // Act
        await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw Exception('Test error'),
          operationName: 'test_error',
          errorMessage: 'Test failed',
          showToast: false,
        );

        // Assert
        final errors = ErrorHandler.getTestErrors();
        expect(errors, isNotEmpty);
        expect(errors.length, equals(1));
        expect(errors.first.operationName, equals('test_error'));
        expect(errors.first.errorMessage, contains('Test failed'));
      });

      test('should clear test errors', () async {
        // Arrange
        ErrorHandler.enableTestMode();
        await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw Exception('Test error'),
          operationName: 'test',
          errorMessage: 'Failed',
          showToast: false,
        );

        // Act
        ErrorHandler.clearTestErrors();

        // Assert
        final errors = ErrorHandler.getTestErrors();
        expect(errors, isEmpty);
      });
    });

    group('Error Recovery', () {
      test('should retry operation on recoverable errors', () async {
        // Arrange
        var attemptCount = 0;

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async {
            attemptCount++;
            if (attemptCount < 3) {
              throw SocketException('Temporary network error');
            }
            return 'success';
          },
          operationName: 'retry_operation',
          errorMessage: 'Operation failed',
          showToast: false,
          maxRetries: 3,
        );

        // Assert
        expect(result, equals('success'));
        expect(attemptCount, equals(3));
      });

      test('should fail after max retries', () async {
        // Arrange
        var attemptCount = 0;

        // Act
        final result = await ErrorHandler.handleAsyncOperation<String>(
          operation: () async {
            attemptCount++;
            throw SocketException('Persistent network error');
          },
          operationName: 'persistent_error',
          errorMessage: 'Operation failed',
          showToast: false,
          maxRetries: 2,
        );

        // Assert
        expect(result, isNull);
        expect(attemptCount, equals(2));
      });
    });

    group('Logging', () {
      test('should log errors with proper context', () async {
        // Arrange
        final loggedErrors = <Map<String, dynamic>>[];

        // Act
        await ErrorHandler.handleAsyncOperation<String>(
          operation: () async => throw Exception('Test error'),
          operationName: 'logging_test',
          errorMessage: 'Failed',
          showToast: false,
          context: {'key': 'value'},
          onLogError: (error, context) {
            loggedErrors.add({'error': error.toString(), 'context': context});
          },
        );

        // Assert
        expect(loggedErrors, isNotEmpty);
        expect(loggedErrors.first['error'], contains('Test error'));
        expect(loggedErrors.first['context']['key'], equals('value'));
      });
    });
  });
}