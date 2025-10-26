import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/security/input_validator.dart';

/// Comprehensive unit tests for InputValidator security layer.
///
/// Tests cover:
/// - Email validation and sanitization
/// - Password strength validation
/// - Firestore field/document/collection sanitization
/// - String validation and length checks
/// - Number range validation
/// - IBEW-specific validation (local numbers, classifications, wages)
void main() {
  group('InputValidator - Email Validation', () {
    test('should accept valid email addresses', () {
      expect(
        InputValidator.sanitizeEmail('user@example.com'),
        equals('user@example.com'),
      );

      expect(
        InputValidator.sanitizeEmail('test.user+tag@subdomain.example.org'),
        equals('test.user+tag@subdomain.example.org'),
      );

      expect(
        InputValidator.sanitizeEmail('user123@test-domain.co.uk'),
        equals('user123@test-domain.co.uk'),
      );
    });

    test('should trim and lowercase emails', () {
      expect(
        InputValidator.sanitizeEmail('  User@Example.COM  '),
        equals('user@example.com'),
      );
    });

    test('should reject empty emails', () {
      expect(
        () => InputValidator.sanitizeEmail(''),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('cannot be empty'),
        )),
      );

      expect(
        () => InputValidator.sanitizeEmail('   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject emails longer than 254 characters', () {
      final longEmail = '${'a' * 250}@test.com';
      expect(
        () => InputValidator.sanitizeEmail(longEmail),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        )),
      );
    });

    test('should reject invalid email formats', () {
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'user@',
        'user @example.com',
        'user@example',
        'user..name@example.com',
        'user@.example.com',
      ];

      for (final email in invalidEmails) {
        expect(
          () => InputValidator.sanitizeEmail(email),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid email format'),
          )),
          reason: 'Should reject: $email',
        );
      }
    });
  });

  group('InputValidator - Password Validation', () {
    test('should accept strong passwords', () {
      expect(
        () => InputValidator.validatePassword('SecurePass123!'),
        returnsNormally,
      );

      expect(
        () => InputValidator.validatePassword('Tr0ng@Pass'),
        returnsNormally,
      );

      expect(
        () => InputValidator.validatePassword('C0mpl3x!P@ssw0rd'),
        returnsNormally,
      );
    });

    test('should reject passwords shorter than 8 characters', () {
      expect(
        () => InputValidator.validatePassword('Short1!'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('at least 8 characters'),
        )),
      );
    });

    test('should reject passwords longer than 128 characters', () {
      final longPassword = 'A1!' + ('a' * 130);
      expect(
        () => InputValidator.validatePassword(longPassword),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        )),
      );
    });

    test('should reject passwords without uppercase letters', () {
      expect(
        () => InputValidator.validatePassword('lowercase123!'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('uppercase letter'),
        )),
      );
    });

    test('should reject passwords without lowercase letters', () {
      expect(
        () => InputValidator.validatePassword('UPPERCASE123!'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('lowercase letter'),
        )),
      );
    });

    test('should reject passwords without numbers', () {
      expect(
        () => InputValidator.validatePassword('NoNumbers!'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('number'),
        )),
      );
    });

    test('should reject passwords without special characters', () {
      expect(
        () => InputValidator.validatePassword('NoSpecial123'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('special character'),
        )),
      );
    });

    test('should reject empty passwords', () {
      expect(
        () => InputValidator.validatePassword(''),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('cannot be empty'),
        )),
      );
    });
  });

  group('InputValidator - Firestore Field Sanitization', () {
    test('should accept valid Firestore field names', () {
      expect(
        InputValidator.sanitizeFirestoreField('userName'),
        equals('userName'),
      );

      expect(
        InputValidator.sanitizeFirestoreField('user_name_123'),
        equals('user_name_123'),
      );

      expect(
        InputValidator.sanitizeFirestoreField('_private'),
        equals('_private'),
      );
    });

    test('should reject field names with invalid characters', () {
      final invalidFields = [
        'user.name', // dot
        'user-name', // hyphen
        'user name', // space
        'user@name', // special char
        'user/name', // slash
      ];

      for (final field in invalidFields) {
        expect(
          () => InputValidator.sanitizeFirestoreField(field),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('invalid characters'),
          )),
          reason: 'Should reject: $field',
        );
      }
    });

    test('should reject empty field names', () {
      expect(
        () => InputValidator.sanitizeFirestoreField(''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject field names longer than 1500 characters', () {
      final longField = 'a' * 1501;
      expect(
        () => InputValidator.sanitizeFirestoreField(longField),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        )),
      );
    });
  });

  group('InputValidator - Firestore Document ID Sanitization', () {
    test('should accept valid document IDs', () {
      expect(
        InputValidator.sanitizeDocumentId('user123'),
        equals('user123'),
      );

      expect(
        InputValidator.sanitizeDocumentId('user-123_abc'),
        equals('user-123_abc'),
      );
    });

    test('should reject document IDs with forward slash', () {
      expect(
        () => InputValidator.sanitizeDocumentId('user/123'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('forward slash'),
        )),
      );
    });

    test('should reject "." and ".." document IDs', () {
      expect(
        () => InputValidator.sanitizeDocumentId('.'),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidator.sanitizeDocumentId('..'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject empty document IDs', () {
      expect(
        () => InputValidator.sanitizeDocumentId(''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject document IDs longer than 1500 characters', () {
      final longId = 'a' * 1501;
      expect(
        () => InputValidator.sanitizeDocumentId(longId),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidator - Firestore Collection Path Sanitization', () {
    test('should accept valid collection paths', () {
      expect(
        InputValidator.sanitizeCollectionPath('users'),
        equals('users'),
      );

      expect(
        InputValidator.sanitizeCollectionPath('users/123/settings'),
        equals('users/123/settings'),
      );

      expect(
        InputValidator.sanitizeCollectionPath('crews/crew1/messages/msg1/replies'),
        equals('crews/crew1/messages/msg1/replies'),
      );
    });

    test('should reject paths with even number of segments', () {
      expect(
        () => InputValidator.sanitizeCollectionPath('users/123'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('odd number of segments'),
        )),
      );
    });

    test('should reject paths with empty segments', () {
      expect(
        () => InputValidator.sanitizeCollectionPath('users//settings'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('empty segment'),
        )),
      );
    });

    test('should reject empty paths', () {
      expect(
        () => InputValidator.sanitizeCollectionPath(''),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidator - String Validation', () {
    test('should validate string within length bounds', () {
      expect(
        InputValidator.validateString(
          'Valid String',
          minLength: 5,
          maxLength: 20,
        ),
        equals('Valid String'),
      );
    });

    test('should trim strings by default', () {
      expect(
        InputValidator.validateString('  Trimmed  '),
        equals('Trimmed'),
      );
    });

    test('should not trim when trim=false', () {
      expect(
        InputValidator.validateString('  Not Trimmed  ', trim: false),
        equals('  Not Trimmed  '),
      );
    });

    test('should reject strings shorter than minLength', () {
      expect(
        () => InputValidator.validateString('Hi', minLength: 5),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('at least 5 characters'),
        )),
      );
    });

    test('should reject strings longer than maxLength', () {
      expect(
        () => InputValidator.validateString('Too long string', maxLength: 5),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        )),
      );
    });

    test('should reject empty strings by default', () {
      expect(
        () => InputValidator.validateString(''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should allow empty strings when allowEmpty=true', () {
      expect(
        InputValidator.validateString('', allowEmpty: true),
        equals(''),
      );
    });
  });

  group('InputValidator - Sanitize For Display', () {
    test('should remove control characters', () {
      final input = 'User\x00\x1F\x7FInput';
      final sanitized = InputValidator.sanitizeForDisplay(input);
      expect(sanitized, equals('UserInput'));
    });

    test('should remove zero-width characters', () {
      final input = 'User\u200B\u200C\u200D\uFEFFInput';
      final sanitized = InputValidator.sanitizeForDisplay(input);
      expect(sanitized, equals('UserInput'));
    });

    test('should not modify normal strings', () {
      final input = 'Normal User Input 123!';
      expect(
        InputValidator.sanitizeForDisplay(input),
        equals(input),
      );
    });
  });

  group('InputValidator - Number Range Validation', () {
    test('should accept integers within range', () {
      expect(
        () => InputValidator.validateIntRange(5, min: 1, max: 10),
        returnsNormally,
      );

      expect(
        () => InputValidator.validateIntRange(1, min: 1, max: 10),
        returnsNormally,
      );

      expect(
        () => InputValidator.validateIntRange(10, min: 1, max: 10),
        returnsNormally,
      );
    });

    test('should reject integers below minimum', () {
      expect(
        () => InputValidator.validateIntRange(0, min: 1, max: 10),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('must be between 1 and 10'),
        )),
      );
    });

    test('should reject integers above maximum', () {
      expect(
        () => InputValidator.validateIntRange(11, min: 1, max: 10),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should accept doubles within range', () {
      expect(
        () => InputValidator.validateDoubleRange(5.5, min: 1.0, max: 10.0),
        returnsNormally,
      );
    });

    test('should reject NaN values', () {
      expect(
        () => InputValidator.validateDoubleRange(double.nan, min: 1.0, max: 10.0),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('cannot be NaN'),
        )),
      );
    });

    test('should reject infinite values', () {
      expect(
        () => InputValidator.validateDoubleRange(
          double.infinity,
          min: 1.0,
          max: 10.0,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('cannot be infinite'),
        )),
      );
    });

    test('should reject doubles out of range', () {
      expect(
        () => InputValidator.validateDoubleRange(0.5, min: 1.0, max: 10.0),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidator.validateDoubleRange(10.1, min: 1.0, max: 10.0),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidator - IBEW Local Number Validation', () {
    test('should accept valid local numbers', () {
      expect(
        () => InputValidator.validateLocalNumber(1),
        returnsNormally,
      );

      expect(
        () => InputValidator.validateLocalNumber(123),
        returnsNormally,
      );

      expect(
        () => InputValidator.validateLocalNumber(9999),
        returnsNormally,
      );
    });

    test('should reject local number 0', () {
      expect(
        () => InputValidator.validateLocalNumber(0),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject negative local numbers', () {
      expect(
        () => InputValidator.validateLocalNumber(-5),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject local numbers above 9999', () {
      expect(
        () => InputValidator.validateLocalNumber(10000),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidator - IBEW Classification Validation', () {
    test('should accept valid classifications', () {
      final validClassifications = [
        'Inside Wireman',
        'Journeyman Lineman',
        'Tree Trimmer',
        'Equipment Operator',
        'Inside Journeyman Electrician',
      ];

      for (final classification in validClassifications) {
        expect(
          InputValidator.validateClassification(classification),
          equals(classification),
          reason: 'Should accept: $classification',
        );
      }
    });

    test('should trim classification names', () {
      expect(
        InputValidator.validateClassification('  Inside Wireman  '),
        equals('Inside Wireman'),
      );
    });

    test('should reject invalid classifications', () {
      final invalidClassifications = [
        'Electrician',
        'Apprentice',
        'Foreman',
        'Invalid Classification',
      ];

      for (final classification in invalidClassifications) {
        expect(
          () => InputValidator.validateClassification(classification),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid classification'),
          )),
          reason: 'Should reject: $classification',
        );
      }
    });
  });

  group('InputValidator - Wage Validation', () {
    test('should accept valid wages', () {
      expect(
        () => InputValidator.validateWage(1.0),
        returnsNormally,
      );

      expect(
        () => InputValidator.validateWage(50.00),
        returnsNormally,
      );

      expect(
        () => InputValidator.validateWage(999.99),
        returnsNormally,
      );
    });

    test('should reject wages below \$1', () {
      expect(
        () => InputValidator.validateWage(0.99),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidator.validateWage(0.0),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject wages above \$999.99', () {
      expect(
        () => InputValidator.validateWage(1000.0),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject NaN and infinity wages', () {
      expect(
        () => InputValidator.validateWage(double.nan),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidator.validateWage(double.infinity),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('ValidationException', () {
    test('should format message without field name', () {
      const exception = ValidationException('Test error');
      expect(
        exception.toString(),
        equals('ValidationException: Test error'),
      );
    });

    test('should format message with field name', () {
      const exception = ValidationException('Test error', fieldName: 'email');
      expect(
        exception.toString(),
        equals('ValidationException in email: Test error'),
      );
    });
  });
}
