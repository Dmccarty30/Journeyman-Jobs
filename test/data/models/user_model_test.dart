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
      expect(user.homeLocal, equals('123'));
    });

    test('should store construction types as list', () {
      // Arrange
      final constructionTypes = ['Commercial', 'Industrial', 'Residential'];
      
      // Act
      final user = MockData.createUser();

      // Assert
      expect(user.constructionTypes, isA<List<String>>());
      expect(user.constructionTypes, isNotEmpty);
    });

    test('should handle career preferences', () {
      // Arrange & Act
      final user = MockData.createUser();

      // Assert
      expect(user.networkWithOthers, isA<bool>());
      expect(user.careerAdvancements, isA<bool>());
    });

    test('should handle phone number information', () {
      // Arrange & Act
      final user = MockData.createUser();

      // Assert
      expect(user.phoneNumber, isA<String>());
      expect(user.phoneNumber, isNotEmpty);
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
        expect(user.homeLocal, equals(localNumber.toString()));
        expect(TestConstants.commonIBEWLocals, contains(localNumber));
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