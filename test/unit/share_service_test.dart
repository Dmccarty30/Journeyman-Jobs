import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Mocks
@GenerateMocks([
  FirebaseAnalytics,
])
import 'share_service_test.mocks.dart';

// Mock ShareService since it doesn't exist yet - we'll create a comprehensive test
// that defines the expected behavior
class ShareService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseAnalytics analytics;

  ShareService({
    required this.firestore,
    required this.auth,
    required this.analytics,
  });

  Future<ShareResult> shareJob(String jobId, ShareTarget target) async {
    // Implementation will be based on these tests
    throw UnimplementedError();
  }

  Future<User?> detectUserByContact(String contact) async {
    // Implementation will be based on these tests
    throw UnimplementedError();
  }

  Future<void> sendJobInvitation(String jobId, String contact, ShareMethod method) async {
    // Implementation will be based on these tests
    throw UnimplementedError();
  }

  Future<List<User>> getCrewMembers(String userId) async {
    // Implementation will be based on these tests
    throw UnimplementedError();
  }
}

// Test models
enum ShareMethod { email, sms, deepLink, inApp }
enum ShareTargetType { existingUser, newUser, phoneNumber, crew }

class ShareTarget {
  final ShareTargetType type;
  final String contact;
  final String? displayName;
  final List<String>? crewIds;

  ShareTarget({
    required this.type,
    required this.contact,
    this.displayName,
    this.crewIds,
  });
}

class ShareResult {
  final bool success;
  final ShareTargetType targetType;
  final ShareMethod method;
  final String? invitationId;
  final String? deepLink;
  final String? errorMessage;

  ShareResult({
    required this.success,
    required this.targetType,
    required this.method,
    this.invitationId,
    this.deepLink,
    this.errorMessage,
  });
}

void main() {
  group('ShareService Tests', () {
    late ShareService shareService;
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseAnalytics mockAnalytics;
    late MockUser mockUser;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockAnalytics = MockFirebaseAnalytics();
      mockUser = MockUser(
        uid: 'test-user-123',
        email: 'test@ibew.org',
        displayName: 'Test Journeyman',
      );

      shareService = ShareService(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      );
    });

    group('Job Sharing Core Logic', () {
      test('should share job to existing user successfully', () async {
        // Arrange
        const jobId = 'job-123';
        const targetEmail = 'colleague@ibew.org';
        
        // Create existing user in Firestore
        await fakeFirestore.collection('users').doc('colleague-456').set({
          'email': targetEmail,
          'displayName': 'Colleague Worker',
          'ibewLocal': 26,
          'classification': 'Journeyman Lineman',
          'phoneNumber': '+15551234567',
          'fcmTokens': ['fcm-token-123'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Create job in Firestore
        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Storm Restoration - IBEW Local 26',
          'description': 'Emergency line restoration work needed',
          'local': 26,
          'classification': 'Journeyman Lineman',
          'payRate': 55.50,
          'location': 'Tacoma, WA',
          'startDate': DateTime.now().add(Duration(days: 3)),
          'urgent': true,
          'stormWork': true,
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.existingUser,
          contact: targetEmail,
          displayName: 'Colleague Worker',
        );

        // Act
        final result = await shareService.shareJob(jobId, target);

        // Assert
        expect(result.success, isTrue);
        expect(result.targetType, ShareTargetType.existingUser);
        expect(result.method, ShareMethod.inApp);
        expect(result.invitationId, isNotNull);
        
        // Verify notification was created
        final notifications = await fakeFirestore
            .collection('notifications')
            .where('recipientId', isEqualTo: 'colleague-456')
            .get();
        expect(notifications.docs.length, 1);
        
        final notification = notifications.docs.first.data();
        expect(notification['type'], 'job_share');
        expect(notification['jobId'], jobId);
        expect(notification['senderId'], 'test-user-123');
        expect(notification['senderName'], 'Test Journeyman');

        // Verify analytics event
        verify(mockAnalytics.logEvent(
          name: 'job_shared',
          parameters: {
            'job_id': jobId,
            'share_method': 'in_app',
            'target_type': 'existing_user',
            'is_storm_work': true,
          },
        )).called(1);
      });

      test('should handle sharing to non-user email', () async {
        // Arrange
        const jobId = 'job-456';
        const nonUserEmail = 'newworker@gmail.com';
        
        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Commercial Wiring - IBEW Local 134',
          'description': 'Large commercial project in Chicago',
          'local': 134,
          'classification': 'Inside Wireman',
          'payRate': 52.75,
          'location': 'Chicago, IL',
          'startDate': DateTime.now().add(Duration(days: 7)),
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.newUser,
          contact: nonUserEmail,
        );

        // Act
        final result = await shareService.shareJob(jobId, target);

        // Assert
        expect(result.success, isTrue);
        expect(result.targetType, ShareTargetType.newUser);
        expect(result.method, ShareMethod.email);
        expect(result.deepLink, isNotNull);
        expect(result.deepLink, contains('invite'));
        expect(result.deepLink, contains(jobId));

        // Verify invitation was created
        final invitations = await fakeFirestore
            .collection('invitations')
            .where('email', isEqualTo: nonUserEmail)
            .get();
        expect(invitations.docs.length, 1);
        
        final invitation = invitations.docs.first.data();
        expect(invitation['jobId'], jobId);
        expect(invitation['senderId'], 'test-user-123');
        expect(invitation['type'], 'job_share');
        expect(invitation['status'], 'pending');

        // Verify analytics
        verify(mockAnalytics.logEvent(
          name: 'job_shared',
          parameters: {
            'job_id': jobId,
            'share_method': 'email',
            'target_type': 'new_user',
            'is_storm_work': false,
          },
        )).called(1);
      });

      test('should handle sharing to phone number', () async {
        // Arrange
        const jobId = 'job-789';
        const phoneNumber = '+15551234567';
        
        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Transmission Line Maintenance',
          'description': 'High voltage transmission work',
          'local': 77,
          'classification': 'Journeyman Lineman',
          'payRate': 58.25,
          'location': 'Seattle, WA',
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.phoneNumber,
          contact: phoneNumber,
        );

        // Act
        final result = await shareService.shareJob(jobId, target);

        // Assert
        expect(result.success, isTrue);
        expect(result.targetType, ShareTargetType.phoneNumber);
        expect(result.method, ShareMethod.sms);
        expect(result.deepLink, isNotNull);

        // Verify SMS invitation was created
        final smsInvitations = await fakeFirestore
            .collection('sms_invitations')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();
        expect(smsInvitations.docs.length, 1);

        final smsInvitation = smsInvitations.docs.first.data();
        expect(smsInvitation['jobId'], jobId);
        expect(smsInvitation['message'], contains('Journeyman Jobs'));
        expect(smsInvitation['deepLink'], isNotNull);
      });

      test('should handle crew sharing', () async {
        // Arrange
        const jobId = 'job-crew-123';
        const crewMemberIds = ['crew-1', 'crew-2', 'crew-3'];
        
        // Create crew members
        for (int i = 0; i < crewMemberIds.length; i++) {
          await fakeFirestore.collection('users').doc(crewMemberIds[i]).set({
            'email': 'crew${i + 1}@ibew.org',
            'displayName': 'Crew Member ${i + 1}',
            'ibewLocal': 98,
            'classification': 'Journeyman Lineman',
            'fcmTokens': ['fcm-token-crew-${i + 1}'],
          });
        }

        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Storm Crew Needed - Hurricane Response',
          'description': 'Multi-person crew needed for storm restoration',
          'local': 98,
          'classification': 'Journeyman Lineman',
          'payRate': 65.00,
          'crewSize': 4,
          'stormWork': true,
          'urgent': true,
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.crew,
          contact: 'storm-crew-alpha',
          crewIds: crewMemberIds,
        );

        // Act
        final result = await shareService.shareJob(jobId, target);

        // Assert
        expect(result.success, isTrue);
        expect(result.targetType, ShareTargetType.crew);
        expect(result.method, ShareMethod.inApp);

        // Verify all crew members got notifications
        final notifications = await fakeFirestore
            .collection('notifications')
            .where('type', isEqualTo: 'crew_job_share')
            .get();
        expect(notifications.docs.length, 3);

        // Verify crew sharing record
        final crewShares = await fakeFirestore
            .collection('crew_shares')
            .where('jobId', isEqualTo: jobId)
            .get();
        expect(crewShares.docs.length, 1);
        
        final crewShare = crewShares.docs.first.data();
        expect(crewShare['crewName'], 'storm-crew-alpha');
        expect(crewShare['memberIds'], crewMemberIds);
        expect(crewShare['sharedBy'], 'test-user-123');
      });
    });

    group('User Detection', () {
      test('should detect existing user by email', () async {
        // Arrange
        const email = 'electrician@ibew.org';
        await fakeFirestore.collection('users').doc('user-123').set({
          'email': email,
          'displayName': 'Expert Electrician',
          'ibewLocal': 46,
          'verified': true,
        });

        // Act
        final user = await shareService.detectUserByContact(email);

        // Assert
        expect(user, isNotNull);
        expect(user!.uid, 'user-123');
        expect(user.email, email);
      });

      test('should detect existing user by phone number', () async {
        // Arrange
        const phoneNumber = '+15551234567';
        await fakeFirestore.collection('users').doc('user-456').set({
          'phoneNumber': phoneNumber,
          'displayName': 'Lineman Pro',
          'ibewLocal': 1,
          'classification': 'Journeyman Lineman',
        });

        // Act
        final user = await shareService.detectUserByContact(phoneNumber);

        // Assert
        expect(user, isNotNull);
        expect(user!.uid, 'user-456');
        expect(user.phoneNumber, phoneNumber);
      });

      test('should return null for non-existing contact', () async {
        // Act
        final user = await shareService.detectUserByContact('nobody@example.com');

        // Assert
        expect(user, isNull);
      });

      test('should handle malformed contact input', () async {
        // Act & Assert
        expect(
          () => shareService.detectUserByContact('invalid-email'),
          throwsArgumentError,
        );
        expect(
          () => shareService.detectUserByContact('123'), // Invalid phone
          throwsArgumentError,
        );
      });
    });

    group('Crew Management', () {
      test('should get crew members for user', () async {
        // Arrange
        const userId = 'foreman-123';
        const crewMemberIds = ['crew-1', 'crew-2', 'crew-3'];
        
        // Create crew relationship
        await fakeFirestore.collection('crews').doc('crew-alpha').set({
          'foremanId': userId,
          'memberIds': crewMemberIds,
          'name': 'Alpha Storm Crew',
          'local': 26,
          'active': true,
        });

        // Create crew members
        for (int i = 0; i < crewMemberIds.length; i++) {
          await fakeFirestore.collection('users').doc(crewMemberIds[i]).set({
            'email': 'member${i + 1}@ibew.org',
            'displayName': 'Crew Member ${i + 1}',
            'ibewLocal': 26,
            'classification': 'Journeyman Lineman',
          });
        }

        // Act
        final crewMembers = await shareService.getCrewMembers(userId);

        // Assert
        expect(crewMembers.length, 3);
        expect(crewMembers.every((member) => member.uid.startsWith('crew-')), isTrue);
        expect(crewMembers.map((m) => m.displayName), 
               containsAll(['Crew Member 1', 'Crew Member 2', 'Crew Member 3']));
      });

      test('should return empty list for user with no crew', () async {
        // Act
        final crewMembers = await shareService.getCrewMembers('solo-worker');

        // Assert
        expect(crewMembers, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle Firestore errors gracefully', () async {
        // Arrange - Create a mock that throws
        final mockFirestore = MockFirebaseFirestore();
        when(mockFirestore.collection('jobs')).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'unavailable'),
        );

        final errorService = ShareService(
          firestore: mockFirestore,
          auth: mockAuth,
          analytics: mockAnalytics,
        );

        final target = ShareTarget(
          type: ShareTargetType.existingUser,
          contact: 'test@example.com',
        );

        // Act
        final result = await errorService.shareJob('job-123', target);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('unavailable'));
      });

      test('should handle authentication errors', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        final target = ShareTarget(
          type: ShareTargetType.existingUser,
          contact: 'test@example.com',
        );

        // Act
        final result = await shareService.shareJob('job-123', target);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('not authenticated'));
      });

      test('should handle non-existent job', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.existingUser,
          contact: 'test@example.com',
        );

        // Act
        final result = await shareService.shareJob('non-existent-job', target);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Job not found'));
      });

      test('should handle rate limiting', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        
        await fakeFirestore.collection('jobs').doc('job-123').set({
          'title': 'Test Job',
          'local': 1,
        });

        // Create recent share attempts to trigger rate limit
        for (int i = 0; i < 10; i++) {
          await fakeFirestore.collection('share_attempts').add({
            'userId': 'test-user-123',
            'timestamp': FieldValue.serverTimestamp(),
            'jobId': 'job-123',
          });
        }

        final target = ShareTarget(
          type: ShareTargetType.existingUser,
          contact: 'test@example.com',
        );

        // Act
        final result = await shareService.shareJob('job-123', target);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('rate limit'));
      });
    });

    group('Deep Link Generation', () {
      test('should generate proper deep links for job invitations', () async {
        // Arrange
        const jobId = 'job-deeplink-123';
        const email = 'newuser@example.com';
        
        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Test Job for Deep Link',
          'local': 58,
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.newUser,
          contact: email,
        );

        // Act
        final result = await shareService.shareJob(jobId, target);

        // Assert
        expect(result.deepLink, isNotNull);
        expect(result.deepLink, startsWith('https://journeymanjobs.app/invite'));
        expect(result.deepLink, contains('job=$jobId'));
        expect(result.deepLink, contains('ref=test-user-123'));
        
        // Verify deep link contains proper UTM parameters
        final uri = Uri.parse(result.deepLink!);
        expect(uri.queryParameters['utm_source'], 'job_share');
        expect(uri.queryParameters['utm_medium'], 'email');
        expect(uri.queryParameters['utm_campaign'], 'user_referral');
      });

      test('should include special parameters for storm work', () async {
        // Arrange
        const jobId = 'storm-job-123';
        
        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Emergency Storm Work',
          'stormWork': true,
          'urgent': true,
          'local': 98,
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.newUser,
          contact: 'stormworker@example.com',
        );

        // Act
        final result = await shareService.shareJob(jobId, target);

        // Assert
        expect(result.deepLink, contains('storm=true'));
        expect(result.deepLink, contains('urgent=true'));
      });
    });

    group('Analytics Tracking', () {
      test('should track all sharing events with proper parameters', () async {
        // Arrange
        const jobId = 'analytics-job-123';
        
        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Analytics Test Job',
          'local': 134,
          'classification': 'Inside Wireman',
          'stormWork': false,
          'payRate': 45.50,
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.newUser,
          contact: 'analytics@example.com',
        );

        // Act
        await shareService.shareJob(jobId, target);

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'job_shared',
          parameters: {
            'job_id': jobId,
            'share_method': 'email',
            'target_type': 'new_user',
            'is_storm_work': false,
            'job_local': 134,
            'job_classification': 'Inside Wireman',
            'job_pay_rate': 45.50,
            'sender_id': 'test-user-123',
          },
        )).called(1);

        verify(mockAnalytics.setUserProperty(
          name: 'shares_sent_count',
          value: '1',
        )).called(1);
      });
    });

    group('Notification Handling', () {
      test('should create proper notification for in-app sharing', () async {
        // Arrange
        const jobId = 'notification-job-123';
        const recipientEmail = 'recipient@ibew.org';
        
        await fakeFirestore.collection('users').doc('recipient-456').set({
          'email': recipientEmail,
          'displayName': 'Recipient User',
          'ibewLocal': 46,
          'fcmTokens': ['fcm-token-recipient'],
        });

        await fakeFirestore.collection('jobs').doc(jobId).set({
          'title': 'Notification Test Job',
          'description': 'Testing notification creation',
          'local': 46,
          'classification': 'Inside Wireman',
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final target = ShareTarget(
          type: ShareTargetType.existingUser,
          contact: recipientEmail,
          displayName: 'Recipient User',
        );

        // Act
        await shareService.shareJob(jobId, target);

        // Assert
        final notifications = await fakeFirestore
            .collection('notifications')
            .where('recipientId', isEqualTo: 'recipient-456')
            .where('type', isEqualTo: 'job_share')
            .get();

        expect(notifications.docs.length, 1);
        
        final notification = notifications.docs.first.data();
        expect(notification['title'], 'Job Shared with You');
        expect(notification['body'], contains('Test Journeyman shared'));
        expect(notification['body'], contains('Notification Test Job'));
        expect(notification['jobId'], jobId);
        expect(notification['senderId'], 'test-user-123');
        expect(notification['senderName'], 'Test Journeyman');
        expect(notification['read'], false);
        expect(notification['timestamp'], isNotNull);
        expect(notification['deepLink'], contains('job/$jobId'));
      });
    });
  });
}