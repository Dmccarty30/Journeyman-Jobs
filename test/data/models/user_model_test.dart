import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import '../../fixtures/mock_data.dart';
import '../../fixtures/test_constants.dart';

void main() {
  group('User Model Tests', () {
    test('should create User with required fields', () {
      // Arrange & Act
      final user = MockData.createUser(
        uid: TestConstants.testUserId,
        email: TestConstants.testEmail,
        displayName: TestConstants.testUserName,
      );

      // Assert
      expect(user.uid, equals(TestConstants.testUserId));
      expect(user.email, equals(TestConstants.testEmail));
      expect(user.displayName, equals(TestConstants.testUserName));
      expect(user.isActive, isTrue);
    });

    test('should handle IBEW classifications correctly', () {
      // Arrange & Act
      final user = MockData.createUser(
        classification: 'Inside Wireman',
        localNumber: 123,
      );

      // Assert
      expect(user.classification, equals('Inside Wireman'));
      expect(TestConstants.ibewClassifications, contains(user.classification));
      expect(user.localNumber, equals(123));
    });

    test('should store certifications as list', () {
      // Arrange
      final certifications = ['OSHA 30', 'First Aid/CPR', 'Arc Flash Training'];
      
      // Act
      final user = MockData.createUser(certifications: certifications);

      // Assert
      expect(user.certifications, equals(certifications));
      expect(user.certifications, hasLength(3));
      expect(user.certifications, contains('OSHA 30'));
    });

    test('should handle years of experience', () {
      // Arrange & Act
      final user = MockData.createUser();

      // Assert
      expect(user.yearsExperience, isA<int>());
      expect(user.yearsExperience, greaterThanOrEqualTo(0));
    });

    test('should have valid preferred travel distance', () {
      // Arrange & Act
      final user = MockData.createUser();

      // Assert
      expect(user.preferredDistance, isA<int>());
      expect(user.preferredDistance, greaterThan(0));
      expect(user.preferredDistance, lessThanOrEqualTo(500)); // Reasonable max
    });

    test('should track user creation time', () {
      // Arrange & Act
      final user = MockData.createUser();

      // Assert
      expect(user.createdTime, isA<DateTime>());
      expect(user.createdTime.isBefore(DateTime.now()), isTrue);
    });
  });

  group('User Model IBEW Validation Tests', () {
    test('should validate against real IBEW locals', () {
      // Test with known IBEW locals
      for (final localNumber in TestConstants.commonIBEWLocals.take(5)) {
        // Act
        final user = MockData.createUser(localNumber: localNumber);

        // Assert
        expect(user.localNumber, equals(localNumber));
        expect(TestConstants.commonIBEWLocals, contains(user.localNumber));
      }
    });

    test('should validate electrical classifications', () {
      for (final classification in TestConstants.ibewClassifications) {
        // Act
        final user = MockData.createUser(classification: classification);

        // Assert
        expect(user.classification, equals(classification));
        expect(TestConstants.ibewClassifications, contains(user.classification));
      }
    });
  });
}