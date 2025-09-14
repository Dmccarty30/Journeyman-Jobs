import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

@GenerateMocks([FirebaseAnalytics])
import 'user_detection_test.mocks.dart';

// UserDetectionService - responsible for finding users by various contact methods
class UserDetectionService {
  final FirebaseFirestore firestore;
  final FirebaseAnalytics analytics;

  UserDetectionService({
    required this.firestore,
    required this.analytics,
  });

  Future<DetectionResult> detectUserByContact(String contact) async {
    // Implementation based on tests
    throw UnimplementedError();
  }

  Future<List<UserMatch>> searchUsersByPartialContact(String partial) async {
    // Implementation based on tests
    throw UnimplementedError();
  }

  Future<QuickSignupEligibility> checkQuickSignupEligibility(String contact) async {
    // Implementation based on tests
    throw UnimplementedError();
  }

  Future<ContactValidationResult> validateContact(String contact) async {
    // Implementation based on tests
    throw UnimplementedError();
  }

  Future<void> trackDetectionAttempt(String contact, DetectionResult result) async {
    // Implementation based on tests
    throw UnimplementedError();
  }
}

// Test models
enum ContactType { email, phoneNumber, ibewId, unknown }
enum DetectionStatus { found, notFound, multipleMatches, error }
enum SignupEligibility { eligible, blocked, requiresVerification, unknown }

class DetectionResult {
  final DetectionStatus status;
  final ContactType contactType;
  final UserProfile? user;
  final List<UserProfile>? multipleMatches;
  final String? errorMessage;
  final bool isVerified;

  DetectionResult({
    required this.status,
    required this.contactType,
    this.user,
    this.multipleMatches,
    this.errorMessage,
    this.isVerified = false,
  });
}

class UserProfile {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? ibewNumber;
  final String displayName;
  final int? ibewLocal;
  final String? classification;
  final bool isVerified;
  final DateTime lastActive;
  final List<String> fcmTokens;

  UserProfile({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.ibewNumber,
    required this.displayName,
    this.ibewLocal,
    this.classification,
    this.isVerified = false,
    required this.lastActive,
    this.fcmTokens = const [],
  });
}

class UserMatch {
  final UserProfile user;
  final double confidence;
  final String matchReason;

  UserMatch({
    required this.user,
    required this.confidence,
    required this.matchReason,
  });
}

class QuickSignupEligibility {
  final SignupEligibility eligibility;
  final String? reason;
  final Map<String, dynamic>? suggestedData;

  QuickSignupEligibility({
    required this.eligibility,
    this.reason,
    this.suggestedData,
  });
}

class ContactValidationResult {
  final bool isValid;
  final ContactType type;
  final String? normalizedContact;
  final List<String> warnings;
  final List<String> errors;

  ContactValidationResult({
    required this.isValid,
    required this.type,
    this.normalizedContact,
    this.warnings = const [],
    this.errors = const [],
  });
}

void main() {
  group('UserDetectionService Tests', () {
    late UserDetectionService detectionService;
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAnalytics mockAnalytics;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAnalytics = MockFirebaseAnalytics();
      
      detectionService = UserDetectionService(
        firestore: fakeFirestore,
        analytics: mockAnalytics,
      );
    });

    group('Email Detection', () {
      test('should detect user by exact email match', () async {
        // Arrange
        const email = 'journeyman@ibew134.org';
        await fakeFirestore.collection('users').doc('user-134-001').set({
          'email': email,
          'displayName': 'Chicago Journeyman',
          'ibewLocal': 134,
          'classification': 'Inside Wireman',
          'isVerified': true,
          'lastActive': DateTime.now().subtract(Duration(hours: 2)),
          'fcmTokens': ['token-134-001'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Act
        final result = await detectionService.detectUserByContact(email);

        // Assert
        expect(result.status, DetectionStatus.found);
        expect(result.contactType, ContactType.email);
        expect(result.user, isNotNull);
        expect(result.user!.uid, 'user-134-001');
        expect(result.user!.email, email);
        expect(result.user!.displayName, 'Chicago Journeyman');
        expect(result.user!.ibewLocal, 134);
        expect(result.isVerified, isTrue);

        // Verify analytics tracking
        verify(mockAnalytics.logEvent(
          name: 'user_detection_attempt',
          parameters: {
            'contact_type': 'email',
            'detection_status': 'found',
            'user_verified': true,
            'ibew_local': 134,
          },
        )).called(1);
      });

      test('should handle case-insensitive email matching', () async {
        // Arrange
        const email = 'LINEMAN@IBEW77.ORG';
        await fakeFirestore.collection('users').doc('user-77-001').set({
          'email': 'lineman@ibew77.org', // lowercase in database
          'displayName': 'Seattle Lineman',
          'ibewLocal': 77,
          'classification': 'Journeyman Lineman',
          'isVerified': true,
          'lastActive': DateTime.now().subtract(Duration(minutes: 30)),
        });

        // Act
        final result = await detectionService.detectUserByContact(email);

        // Assert
        expect(result.status, DetectionStatus.found);
        expect(result.user!.email, 'lineman@ibew77.org');
        expect(result.user!.displayName, 'Seattle Lineman');
      });

      test('should return not found for non-existent email', () async {
        // Act
        final result = await detectionService.detectUserByContact('nonexistent@example.com');

        // Assert
        expect(result.status, DetectionStatus.notFound);
        expect(result.contactType, ContactType.email);
        expect(result.user, isNull);

        verify(mockAnalytics.logEvent(
          name: 'user_detection_attempt',
          parameters: {
            'contact_type': 'email',
            'detection_status': 'not_found',
          },
        )).called(1);
      });

      test('should handle multiple users with same email (edge case)', () async {
        // Arrange - This shouldn't happen but we should handle it gracefully
        const email = 'duplicate@ibew.org';
        
        await fakeFirestore.collection('users').doc('user-1').set({
          'email': email,
          'displayName': 'User One',
          'ibewLocal': 26,
          'lastActive': DateTime.now().subtract(Duration(hours: 1)),
        });
        
        await fakeFirestore.collection('users').doc('user-2').set({
          'email': email,
          'displayName': 'User Two',
          'ibewLocal': 46,
          'lastActive': DateTime.now().subtract(Duration(minutes: 30)),
        });

        // Act
        final result = await detectionService.detectUserByContact(email);

        // Assert
        expect(result.status, DetectionStatus.multipleMatches);
        expect(result.multipleMatches, isNotNull);
        expect(result.multipleMatches!.length, 2);
        expect(result.user, isNull); // No single user returned

        verify(mockAnalytics.logEvent(
          name: 'user_detection_attempt',
          parameters: {
            'contact_type': 'email',
            'detection_status': 'multiple_matches',
            'match_count': 2,
          },
        )).called(1);
      });
    });

    group('Phone Number Detection', () {
      test('should detect user by phone number with normalization', () async {
        // Arrange
        const phoneNumber = '+15551234567';
        await fakeFirestore.collection('users').doc('user-phone-001').set({
          'phoneNumber': phoneNumber,
          'displayName': 'Mobile Journeyman',
          'ibewLocal': 98,
          'classification': 'Tree Trimmer',
          'isVerified': true,
          'lastActive': DateTime.now(),
        });

        // Act - Test various phone formats
        final testFormats = [
          '+15551234567',   // E.164 format
          '15551234567',    // Without +
          '(555) 123-4567', // Formatted
          '555-123-4567',   // Dashed
          '555.123.4567',   // Dotted
          '5551234567',     // Plain digits
        ];

        for (final format in testFormats) {
          final result = await detectionService.detectUserByContact(format);
          
          expect(result.status, DetectionStatus.found, 
                 reason: 'Failed to detect with format: $format');
          expect(result.user!.phoneNumber, phoneNumber);
          expect(result.user!.displayName, 'Mobile Journeyman');
        }
      });

      test('should handle international phone numbers', () async {
        // Arrange
        const internationalPhone = '+441234567890'; // UK number
        await fakeFirestore.collection('users').doc('user-uk-001').set({
          'phoneNumber': internationalPhone,
          'displayName': 'UK Journeyman',
          'ibewLocal': null, // International user
          'classification': 'Electrician',
          'country': 'UK',
          'isVerified': true,
        });

        // Act
        final result = await detectionService.detectUserByContact(internationalPhone);

        // Assert
        expect(result.status, DetectionStatus.found);
        expect(result.user!.phoneNumber, internationalPhone);
        expect(result.user!.displayName, 'UK Journeyman');
      });

      test('should return not found for invalid phone numbers', () async {
        // Act
        final result = await detectionService.detectUserByContact('invalid-phone');

        // Assert
        expect(result.status, DetectionStatus.error);
        expect(result.contactType, ContactType.unknown);
        expect(result.errorMessage, contains('Invalid phone number format'));
      });
    });

    group('IBEW ID Detection', () {
      test('should detect user by IBEW membership number', () async {
        // Arrange
        const ibewNumber = 'IBEW-134-001234';
        await fakeFirestore.collection('users').doc('user-ibew-001').set({
          'ibewNumber': ibewNumber,
          'email': 'member@ibew134.org',
          'displayName': 'IBEW Member 134',
          'ibewLocal': 134,
          'classification': 'Inside Wireman',
          'isVerified': true,
          'membershipStatus': 'active',
        });

        // Act
        final result = await detectionService.detectUserByContact(ibewNumber);

        // Assert
        expect(result.status, DetectionStatus.found);
        expect(result.contactType, ContactType.ibewId);
        expect(result.user!.ibewNumber, ibewNumber);
        expect(result.user!.ibewLocal, 134);
        expect(result.isVerified, isTrue);
      });

      test('should handle various IBEW ID formats', () async {
        // Arrange
        const baseId = '134001234';
        await fakeFirestore.collection('users').doc('user-format-test').set({
          'ibewNumber': 'IBEW-134-001234',
          'displayName': 'Format Test User',
          'ibewLocal': 134,
        });

        // Act - Test different formats
        final testFormats = [
          'IBEW-134-001234',
          'ibew-134-001234',
          'IBEW134001234',
          '134-001234',
          baseId,
        ];

        for (final format in testFormats) {
          final result = await detectionService.detectUserByContact(format);
          expect(result.status, DetectionStatus.found,
                 reason: 'Failed with format: $format');
        }
      });
    });

    group('Contact Validation', () {
      test('should validate and normalize email addresses', () async {
        // Act & Assert
        final validEmails = [
          'test@ibew.org',
          'journeyman@ibew134.org',
          'worker.name+tag@local26.ibew.org',
        ];

        for (final email in validEmails) {
          final result = await detectionService.validateContact(email);
          expect(result.isValid, isTrue, reason: 'Invalid: $email');
          expect(result.type, ContactType.email);
          expect(result.normalizedContact, isNotNull);
        }

        final invalidEmails = [
          'not-an-email',
          '@ibew.org',
          'test@',
          'test.ibew.org',
          '',
        ];

        for (final email in invalidEmails) {
          final result = await detectionService.validateContact(email);
          expect(result.isValid, isFalse, reason: 'Should be invalid: $email');
          expect(result.errors, isNotEmpty);
        }
      });

      test('should validate and normalize phone numbers', () async {
        // Act & Assert
        final validPhones = [
          '+15551234567',
          '(555) 123-4567',
          '555-123-4567',
          '5551234567',
        ];

        for (final phone in validPhones) {
          final result = await detectionService.validateContact(phone);
          expect(result.isValid, isTrue, reason: 'Invalid: $phone');
          expect(result.type, ContactType.phoneNumber);
          expect(result.normalizedContact, matches(r'^\+1\d{10}$'));
        }

        final invalidPhones = [
          '123',
          '555-CALL-NOW',
          '+1234', // Too short
          '+1555123456789', // Too long
        ];

        for (final phone in invalidPhones) {
          final result = await detectionService.validateContact(phone);
          expect(result.isValid, isFalse, reason: 'Should be invalid: $phone');
          expect(result.errors, isNotEmpty);
        }
      });

      test('should provide warnings for suspicious patterns', () async {
        // Act
        final tempEmailResult = await detectionService.validateContact('test@10minutemail.com');
        final personalResult = await detectionService.validateContact('worker@gmail.com');

        // Assert
        expect(tempEmailResult.isValid, isTrue);
        expect(tempEmailResult.warnings, contains('Temporary email provider detected'));

        expect(personalResult.isValid, isTrue);
        expect(personalResult.warnings, contains('Personal email domain'));
      });
    });

    group('Partial Contact Search', () {
      test('should search users by partial email', () async {
        // Arrange
        await fakeFirestore.collection('users').doc('user-1').set({
          'email': 'john.smith@ibew134.org',
          'displayName': 'John Smith',
          'ibewLocal': 134,
          'lastActive': DateTime.now(),
        });

        await fakeFirestore.collection('users').doc('user-2').set({
          'email': 'jane.smith@ibew134.org',
          'displayName': 'Jane Smith',
          'ibewLocal': 134,
          'lastActive': DateTime.now().subtract(Duration(hours: 1)),
        });

        // Act
        final results = await detectionService.searchUsersByPartialContact('smith@ibew134');

        // Assert
        expect(results.length, 2);
        expect(results[0].confidence, greaterThan(results[1].confidence));
        expect(results.every((match) => match.user.email!.contains('smith@ibew134')), isTrue);
        expect(results[0].matchReason, contains('email'));
      });

      test('should search users by partial display name', () async {
        // Arrange
        await fakeFirestore.collection('users').doc('user-mike').set({
          'email': 'mike.johnson@ibew26.org',
          'displayName': 'Mike Johnson',
          'ibewLocal': 26,
          'classification': 'Journeyman Lineman',
        });

        // Act
        final results = await detectionService.searchUsersByPartialContact('Mike John');

        // Assert
        expect(results.length, 1);
        expect(results[0].user.displayName, 'Mike Johnson');
        expect(results[0].matchReason, contains('display name'));
        expect(results[0].confidence, greaterThan(0.8));
      });

      test('should limit search results appropriately', () async {
        // Arrange - Create many users with similar names
        for (int i = 0; i < 20; i++) {
          await fakeFirestore.collection('users').doc('user-common-$i').set({
            'email': 'smith$i@ibew.org',
            'displayName': 'Smith Worker $i',
            'ibewLocal': 1,
          });
        }

        // Act
        final results = await detectionService.searchUsersByPartialContact('smith');

        // Assert
        expect(results.length, lessThanOrEqualTo(10)); // Max 10 results
        expect(results, isSortedBy((match) => -match.confidence)); // Sorted by confidence desc
      });
    });

    group('Quick Signup Eligibility', () {
      test('should determine eligibility for new IBEW member', () async {
        // Arrange
        const email = 'newmember@ibew.org';

        // Act
        final eligibility = await detectionService.checkQuickSignupEligibility(email);

        // Assert
        expect(eligibility.eligibility, SignupEligibility.eligible);
        expect(eligibility.suggestedData, isNotNull);
        expect(eligibility.suggestedData!['domain'], 'ibew.org');
        expect(eligibility.suggestedData!['suggestedLocal'], isNull); // Can't infer from domain
      });

      test('should suggest local from email domain', () async {
        // Arrange
        const email = 'worker@ibew134.org';

        // Act
        final eligibility = await detectionService.checkQuickSignupEligibility(email);

        // Assert
        expect(eligibility.eligibility, SignupEligibility.eligible);
        expect(eligibility.suggestedData!['suggestedLocal'], 134);
        expect(eligibility.suggestedData!['localConfidence'], greaterThan(0.8));
      });

      test('should require verification for suspicious domains', () async {
        // Arrange
        const email = 'test@10minutemail.com';

        // Act
        final eligibility = await detectionService.checkQuickSignupEligibility(email);

        // Assert
        expect(eligibility.eligibility, SignupEligibility.requiresVerification);
        expect(eligibility.reason, contains('temporary email'));
      });

      test('should block known spam domains', () async {
        // Arrange
        const email = 'spam@spammer.com';

        // Create blocked domain
        await fakeFirestore.collection('blocked_domains').doc('spammer.com').set({
          'reason': 'spam',
          'blockedAt': FieldValue.serverTimestamp(),
        });

        // Act
        final eligibility = await detectionService.checkQuickSignupEligibility(email);

        // Assert
        expect(eligibility.eligibility, SignupEligibility.blocked);
        expect(eligibility.reason, contains('blocked domain'));
      });

      test('should handle existing user gracefully', () async {
        // Arrange
        const email = 'existing@ibew.org';
        await fakeFirestore.collection('users').doc('existing-user').set({
          'email': email,
          'displayName': 'Existing User',
          'ibewLocal': 26,
        });

        // Act
        final eligibility = await detectionService.checkQuickSignupEligibility(email);

        // Assert
        expect(eligibility.eligibility, SignupEligibility.blocked);
        expect(eligibility.reason, contains('already exists'));
      });
    });

    group('Analytics and Tracking', () {
      test('should track detection attempts with comprehensive data', () async {
        // Arrange
        const email = 'analytics@ibew134.org';
        await fakeFirestore.collection('users').doc('analytics-user').set({
          'email': email,
          'displayName': 'Analytics User',
          'ibewLocal': 134,
          'classification': 'Inside Wireman',
          'isVerified': true,
          'lastActive': DateTime.now().subtract(Duration(hours: 1)),
        });

        // Act
        final result = await detectionService.detectUserByContact(email);
        await detectionService.trackDetectionAttempt(email, result);

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'user_detection_attempt',
          parameters: {
            'contact_type': 'email',
            'detection_status': 'found',
            'user_verified': true,
            'ibew_local': 134,
            'user_classification': 'Inside Wireman',
            'user_last_active_hours': 1,
            'detection_time_ms': anyNamed('detection_time_ms'),
          },
        )).called(1);

        // Verify detection attempt is stored
        final detectionLogs = await fakeFirestore
            .collection('detection_logs')
            .where('contact', isEqualTo: email)
            .get();
        expect(detectionLogs.docs.length, 1);
        
        final log = detectionLogs.docs.first.data();
        expect(log['contactType'], 'email');
        expect(log['status'], 'found');
        expect(log['userFound'], isTrue);
      });

      test('should track failed detection attempts', () async {
        // Act
        final result = await detectionService.detectUserByContact('notfound@example.com');
        await detectionService.trackDetectionAttempt('notfound@example.com', result);

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'user_detection_attempt',
          parameters: {
            'contact_type': 'email',
            'detection_status': 'not_found',
            'detection_time_ms': anyNamed('detection_time_ms'),
          },
        )).called(1);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle malformed contact input gracefully', () async {
        // Act & Assert
        final invalidInputs = ['', '   ', '\n\t', null];
        
        for (final input in invalidInputs) {
          expect(
            () => detectionService.detectUserByContact(input ?? ''),
            throwsArgumentError,
            reason: 'Should throw for input: $input',
          );
        }
      });

      test('should handle Firestore errors gracefully', () async {
        // This would require mocking Firestore to throw errors
        // For comprehensive testing, you'd want to test network failures,
        // permission errors, etc.
      });

      test('should handle very long contact strings', () async {
        // Arrange
        final longEmail = '${'a' * 1000}@example.com';

        // Act
        final result = await detectionService.validateContact(longEmail);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Email address too long'));
      });

      test('should handle special characters in contact', () async {
        // Arrange
        const specialEmail = 'test+tag@sub.domain.ibew.org';
        await fakeFirestore.collection('users').doc('special-user').set({
          'email': specialEmail,
          'displayName': 'Special User',
        });

        // Act
        final result = await detectionService.detectUserByContact(specialEmail);

        // Assert
        expect(result.status, DetectionStatus.found);
        expect(result.user!.email, specialEmail);
      });
    });
  });
}

// Helper extension for testing
extension on Iterable<UserMatch> {
  bool isSortedBy(num Function(UserMatch) keySelector) {
    if (length <= 1) return true;
    
    for (int i = 0; i < length - 1; i++) {
      if (keySelector(elementAt(i)) < keySelector(elementAt(i + 1))) {
        return false;
      }
    }
    return true;
  }
}