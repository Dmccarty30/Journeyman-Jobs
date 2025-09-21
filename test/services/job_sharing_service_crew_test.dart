import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:journeyman_jobs/services/job_sharing_service.dart';
import 'package:journeyman_jobs/features/crews/models/job_notification.dart';
import 'package:journeyman_jobs/features/crews/models/group_bid.dart';
import 'package:journeyman_jobs/features/crews/models/crew_enums.dart';
import '../mocks/firebase_mocks.dart';

/// Test suite for crew-specific job sharing functionality
///
/// Tests extended JobSharingService methods for IBEW crew coordination,
/// including job notifications, group bids, and offline support.
void main() {
  group('JobSharingService Crew Extensions', () {
    late JobSharingService jobSharingService;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      // Setup default mocks
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user_id');
      when(mockUser.displayName).thenReturn('Test User');

      jobSharingService = JobSharingService();
      // Inject mocks (assuming service accepts them for testing)
    });

    group('shareJobToCrew', () {
      test('successfully shares job to crew', () async {
        // Arrange
        const jobId = 'test_job_id';
        const crewId = 'test_crew_id';
        const message = 'Check out this storm work opportunity!';

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'memberIds': ['test_user_id', 'member_1', 'member_2'],
          'name': 'Test Crew',
        });

        final mockCrewRef = MockDocumentReference();
        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(mockCrewRef);
        when(mockCrewRef.get()).thenAnswer((_) async => mockCrewDoc);

        // Mock duplicate check
        final mockNotificationsQuery = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([]);
        when(mockNotificationsQuery.limit(1)).thenReturn(mockNotificationsQuery);
        when(mockNotificationsQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);

        final mockNotificationsCollection = MockCollectionReference();
        when(mockCrewRef.collection('jobNotifications'))
            .thenReturn(mockNotificationsCollection);
        when(mockNotificationsCollection
                .where('jobId', isEqualTo: jobId))
            .thenReturn(mockNotificationsQuery);
        when(mockNotificationsQuery
                .where('timestamp', isGreaterThan: any))
            .thenReturn(mockNotificationsQuery);

        // Mock document creation
        final mockNotificationDoc = MockDocumentReference();
        when(mockNotificationDoc.id).thenReturn('notification_id');
        when(mockNotificationsCollection.doc()).thenReturn(mockNotificationDoc);
        when(mockNotificationDoc.set(any)).thenAnswer((_) async {});

        // Act
        final result = await jobSharingService.shareJobToCrew(
          jobId,
          crewId,
          message,
          isPriority: true,
        );

        // Assert
        expect(result, equals('notification_id'));
        verify(mockNotificationDoc.set(any)).called(1);
      });

      test('throws exception when user not crew member', () async {
        // Arrange
        const jobId = 'test_job_id';
        const crewId = 'test_crew_id';
        const message = 'Check out this job!';

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'memberIds': ['other_user_1', 'other_user_2'],
          'name': 'Test Crew',
        });

        final mockCrewRef = MockDocumentReference();
        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(mockCrewRef);
        when(mockCrewRef.get()).thenAnswer((_) async => mockCrewDoc);

        // Act & Assert
        expect(
          () => jobSharingService.shareJobToCrew(jobId, crewId, message),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User is not a member of this crew'),
          )),
        );
      });

      test('throws exception for duplicate share within 24 hours', () async {
        // Arrange
        const jobId = 'test_job_id';
        const crewId = 'test_crew_id';
        const message = 'Check out this job!';

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'memberIds': ['test_user_id', 'member_1'],
          'name': 'Test Crew',
        });

        final mockCrewRef = MockDocumentReference();
        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(mockCrewRef);
        when(mockCrewRef.get()).thenAnswer((_) async => mockCrewDoc);

        // Mock duplicate found
        final mockNotificationsQuery = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockExistingDoc = MockQueryDocumentSnapshot();
        when(mockQuerySnapshot.docs).thenReturn([mockExistingDoc]);
        when(mockNotificationsQuery.limit(1)).thenReturn(mockNotificationsQuery);
        when(mockNotificationsQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);

        final mockNotificationsCollection = MockCollectionReference();
        when(mockCrewRef.collection('jobNotifications'))
            .thenReturn(mockNotificationsCollection);
        when(mockNotificationsCollection
                .where('jobId', isEqualTo: jobId))
            .thenReturn(mockNotificationsQuery);
        when(mockNotificationsQuery
                .where('timestamp', isGreaterThan: any))
            .thenReturn(mockNotificationsQuery);

        // Act & Assert
        expect(
          () => jobSharingService.shareJobToCrew(jobId, crewId, message),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Job already shared to this crew within 24 hours'),
          )),
        );
      });
    });

    group('respondToJobNotification', () {
      test('successfully records member response', () async {
        // Arrange
        const notificationId = 'test_notification_id';
        const userId = 'test_user_id';
        const response = ResponseType.accepted;
        const note = 'I\'m available for this storm work';

        final existingNotification = JobNotification(
          id: notificationId,
          jobId: 'job_id',
          crewId: 'crew_id',
          sharedByUserId: 'sharer_id',
          timestamp: DateTime.now(),
          memberResponses: {},
          isPriority: true,
        );

        final mockNotificationDoc = MockQueryDocumentSnapshot();
        when(mockNotificationDoc.data())
            .thenReturn(existingNotification.toMap());
        when(mockNotificationDoc.reference)
            .thenReturn(MockDocumentReference());

        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([mockNotificationDoc]);

        final mockQuery = MockQuery();
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(mockFirestore.collectionGroup('jobNotifications'))
            .thenReturn(MockCollectionGroup());
        when(MockCollectionGroup().where('id', isEqualTo: notificationId))
            .thenReturn(mockQuery);

        when(mockNotificationDoc.reference.update(any))
            .thenAnswer((_) async => null);

        // Act
        await jobSharingService.respondToJobNotification(
          notificationId,
          userId,
          response,
          note: note,
        );

        // Assert
        verify(mockNotificationDoc.reference.update(any)).called(1);
      });

      test('throws exception when notification not found', () async {
        // Arrange
        const notificationId = 'nonexistent_notification';
        const userId = 'test_user_id';
        const response = ResponseType.accepted;

        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([]);

        final mockQuery = MockQuery();
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(mockFirestore.collectionGroup('jobNotifications'))
            .thenReturn(MockCollectionGroup());
        when(MockCollectionGroup().where('id', isEqualTo: notificationId))
            .thenReturn(mockQuery);

        // Act & Assert
        expect(
          () => jobSharingService.respondToJobNotification(
            notificationId,
            userId,
            response,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Job notification not found'),
          )),
        );
      });
    });

    group('createGroupBid', () {
      test('successfully creates group bid', () async {
        // Arrange
        final bidTerms = BidTerms(
          proposedRate: 45.0,
          startDate: DateTime.now().add(const Duration(days: 7)),
          estimatedDuration: 4,
          housingRequested: true,
          transportationRequested: true,
        );

        final groupBid = GroupBid(
          id: '', // Will be set by service
          crewId: 'test_crew_id',
          jobId: 'test_job_id',
          jobNotificationId: 'test_notification_id',
          participatingMembers: ['member_1', 'member_2', 'member_3'],
          memberRoles: {
            'member_1': 'Foreman',
            'member_2': 'Journeyman',
            'member_3': 'Apprentice',
          },
          submittedAt: DateTime.now(),
          terms: bidTerms,
          createdByUserId: 'test_user_id',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        final mockCrewRef = MockDocumentReference();
        final mockBidsCollection = MockCollectionReference();
        final mockBidDoc = MockDocumentReference();

        when(mockFirestore.collection('crews').doc('test_crew_id'))
            .thenReturn(mockCrewRef);
        when(mockCrewRef.collection('groupBids'))
            .thenReturn(mockBidsCollection);
        when(mockBidsCollection.doc()).thenReturn(mockBidDoc);
        when(mockBidDoc.id).thenReturn('generated_bid_id');
        when(mockBidDoc.set(any)).thenAnswer((_) async {});

        // Act
        final result = await jobSharingService.createGroupBid(groupBid);

        // Assert
        expect(result, equals('generated_bid_id'));
        verify(mockBidDoc.set(any)).called(1);
      });

      test('throws exception for bid with no participating members', () async {
        // Arrange
        final bidTerms = BidTerms(
          proposedRate: 45.0,
          startDate: DateTime.now().add(const Duration(days: 7)),
          estimatedDuration: 4,
        );

        final groupBid = GroupBid(
          id: '',
          crewId: 'test_crew_id',
          jobId: 'test_job_id',
          jobNotificationId: 'test_notification_id',
          participatingMembers: [], // Empty list
          submittedAt: DateTime.now(),
          terms: bidTerms,
          createdByUserId: 'test_user_id',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => jobSharingService.createGroupBid(groupBid),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Group bid must have at least one participating member'),
          )),
        );
      });

      test('throws exception for bid with zero rate', () async {
        // Arrange
        final bidTerms = BidTerms(
          proposedRate: 0.0, // Invalid rate
          startDate: DateTime.now().add(const Duration(days: 7)),
          estimatedDuration: 4,
        );

        final groupBid = GroupBid(
          id: '',
          crewId: 'test_crew_id',
          jobId: 'test_job_id',
          jobNotificationId: 'test_notification_id',
          participatingMembers: ['member_1'],
          submittedAt: DateTime.now(),
          terms: bidTerms,
          createdByUserId: 'test_user_id',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => jobSharingService.createGroupBid(groupBid),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Proposed rate must be greater than 0'),
          )),
        );
      });
    });

    group('calculateCrewMatchScore', () {
      test('calculates high match score for well-matched job', () async {
        // Arrange
        const jobId = 'test_job_id';
        const crewId = 'test_crew_id';

        final mockJobDoc = MockDocumentSnapshot();
        when(mockJobDoc.exists).thenReturn(true);
        when(mockJobDoc.data()).thenReturn({
          'type': 'stormWork',
          'payRate': 50.0,
          'state': 'FL',
          'company': 'ABC Electric',
        });

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'preferences': {
            'acceptedJobTypes': ['stormWork', 'transmissionWork'],
            'minimumCrewRate': 45.0,
            'preferredStates': ['FL', 'TX', 'LA'],
            'preferredCompanies': ['ABC Electric', 'XYZ Power'],
            'blacklistedCompanies': [],
          }
        });

        when(mockFirestore.collection('jobs').doc(jobId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockJobDoc);

        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockCrewDoc);

        // Act
        final matchScore = await jobSharingService.calculateCrewMatchScore(
          jobId,
          crewId,
        );

        // Assert
        expect(matchScore, greaterThan(0.8)); // High match expected
      });

      test('calculates low match score for poorly-matched job', () async {
        // Arrange
        const jobId = 'test_job_id';
        const crewId = 'test_crew_id';

        final mockJobDoc = MockDocumentSnapshot();
        when(mockJobDoc.exists).thenReturn(true);
        when(mockJobDoc.data()).thenReturn({
          'type': 'insideWireman',
          'payRate': 25.0, // Below minimum
          'state': 'AK', // Not preferred
          'company': 'Bad Company',
        });

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'preferences': {
            'acceptedJobTypes': ['stormWork', 'transmissionWork'],
            'minimumCrewRate': 45.0,
            'preferredStates': ['FL', 'TX', 'LA'],
            'preferredCompanies': ['ABC Electric'],
            'blacklistedCompanies': ['Bad Company'],
          }
        });

        when(mockFirestore.collection('jobs').doc(jobId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockJobDoc);

        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockCrewDoc);

        // Act
        final matchScore = await jobSharingService.calculateCrewMatchScore(
          jobId,
          crewId,
        );

        // Assert
        expect(matchScore, lessThan(0.3)); // Low match expected
      });

      test('returns 0 for non-existent job', () async {
        // Arrange
        const jobId = 'nonexistent_job_id';
        const crewId = 'test_crew_id';

        final mockJobDoc = MockDocumentSnapshot();
        when(mockJobDoc.exists).thenReturn(false);

        when(mockFirestore.collection('jobs').doc(jobId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockJobDoc);

        // Act
        final matchScore = await jobSharingService.calculateCrewMatchScore(
          jobId,
          crewId,
        );

        // Assert
        expect(matchScore, equals(0.0));
      });
    });

    group('getCrewJobNotifications', () {
      test('returns stream of job notifications for crew', () async {
        // Arrange
        const crewId = 'test_crew_id';

        final notification1 = JobNotification(
          id: 'notification_1',
          jobId: 'job_1',
          crewId: crewId,
          sharedByUserId: 'user_1',
          timestamp: DateTime.now(),
          isPriority: true,
        );

        final notification2 = JobNotification(
          id: 'notification_2',
          jobId: 'job_2',
          crewId: crewId,
          sharedByUserId: 'user_2',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isPriority: false,
        );

        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();

        when(mockDoc1.data()).thenReturn(notification1.toMap());
        when(mockDoc2.data()).thenReturn(notification2.toMap());
        when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

        final mockQuery = MockQuery();
        when(mockQuery.orderBy('isPriority', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('timestamp', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));

        final mockCrewRef = MockDocumentReference();
        final mockNotificationsCollection = MockCollectionReference();

        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(mockCrewRef);
        when(mockCrewRef.collection('jobNotifications'))
            .thenReturn(mockNotificationsCollection);
        when(mockNotificationsCollection.orderBy('isPriority', descending: true))
            .thenReturn(mockQuery);

        // Act
        final stream = jobSharingService.getCrewJobNotifications(crewId);
        final notifications = await stream.first;

        // Assert
        expect(notifications, hasLength(2));
        expect(notifications.first.id, equals('notification_1'));
        expect(notifications.first.isPriority, isTrue);
      });
    });

    group('autoShareMatchingJobs', () {
      test('auto-shares jobs that meet match threshold', () async {
        // Arrange
        const crewId = 'test_crew_id';

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'preferences': {
            'autoShareMatchingJobs': true,
            'matchThreshold': 80,
            'acceptedJobTypes': ['stormWork'],
            'minimumCrewRate': 40.0,
          },
          'memberIds': ['test_user_id', 'member_1'],
        });

        final mockJobDoc = MockQueryDocumentSnapshot();
        when(mockJobDoc.id).thenReturn('job_1');
        when(mockJobDoc.data()).thenReturn({
          'type': 'stormWork',
          'payRate': 50.0,
          'state': 'FL',
          'isActive': true,
          'createdAt': Timestamp.now(),
        });

        final mockJobsQuery = MockQuery();
        final mockJobsSnapshot = MockQuerySnapshot();
        when(mockJobsSnapshot.docs).thenReturn([mockJobDoc]);
        when(mockJobsSnapshot.size).thenReturn(1);

        when(mockJobsQuery.where('isActive', isEqualTo: true))
            .thenReturn(mockJobsQuery);
        when(mockJobsQuery.limit(50)).thenReturn(mockJobsQuery);
        when(mockJobsQuery.get()).thenAnswer((_) async => mockJobsSnapshot);

        when(mockFirestore.collection('jobs'))
            .thenReturn(MockCollectionReference());
        when(MockCollectionReference()
                .where('createdAt', isGreaterThan: any))
            .thenReturn(mockJobsQuery);

        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockCrewDoc);

        // Mock existing share check (none found)
        final mockExistingShareQuery = MockQuery();
        final mockExistingSnapshot = MockQuerySnapshot();
        when(mockExistingSnapshot.docs).thenReturn([]);
        when(mockExistingShareQuery.limit(1)).thenReturn(mockExistingShareQuery);
        when(mockExistingShareQuery.get())
            .thenAnswer((_) async => mockExistingSnapshot);

        // Act
        final sharedJobIds = await jobSharingService.autoShareMatchingJobs(crewId);

        // Assert
        expect(sharedJobIds, isNotEmpty);
        expect(sharedJobIds, contains('job_1'));
      });

      test('returns empty list when auto-sharing disabled', () async {
        // Arrange
        const crewId = 'test_crew_id';

        final mockCrewDoc = MockDocumentSnapshot();
        when(mockCrewDoc.exists).thenReturn(true);
        when(mockCrewDoc.data()).thenReturn({
          'preferences': {
            'autoShareMatchingJobs': false, // Disabled
            'matchThreshold': 80,
          }
        });

        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(MockDocumentReference());
        when(MockDocumentReference().get())
            .thenAnswer((_) async => mockCrewDoc);

        // Act
        final sharedJobIds = await jobSharingService.autoShareMatchingJobs(crewId);

        // Assert
        expect(sharedJobIds, isEmpty);
      });
    });

    group('getCrewJobHistory', () {
      test('returns comprehensive job history with statistics', () async {
        // Arrange
        const crewId = 'test_crew_id';

        final notification = JobNotification(
          id: 'notification_1',
          jobId: 'job_1',
          crewId: crewId,
          sharedByUserId: 'user_1',
          timestamp: DateTime.now(),
          memberResponses: {
            'user_1': MemberResponse(
              userId: 'user_1',
              type: ResponseType.accepted,
              timestamp: DateTime.now(),
            ),
            'user_2': MemberResponse(
              userId: 'user_2',
              type: ResponseType.accepted,
              timestamp: DateTime.now(),
            ),
          },
          responseCount: 2,
        );

        final bid = GroupBid(
          id: 'bid_1',
          crewId: crewId,
          jobId: 'job_1',
          jobNotificationId: 'notification_1',
          participatingMembers: ['user_1', 'user_2'],
          submittedAt: DateTime.now(),
          status: GroupBidStatus.accepted,
          terms: BidTerms(
            proposedRate: 45.0,
            startDate: DateTime.now(),
            estimatedDuration: 4,
          ),
          createdByUserId: 'user_1',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        // Mock notifications query
        final mockNotificationsQuery = MockQuery();
        final mockNotificationsSnapshot = MockQuerySnapshot();
        final mockNotificationDoc = MockQueryDocumentSnapshot();

        when(mockNotificationDoc.data()).thenReturn(notification.toMap());
        when(mockNotificationsSnapshot.docs).thenReturn([mockNotificationDoc]);

        when(mockNotificationsQuery.orderBy('timestamp', descending: true))
            .thenReturn(mockNotificationsQuery);
        when(mockNotificationsQuery.limit(100)).thenReturn(mockNotificationsQuery);
        when(mockNotificationsQuery.get())
            .thenAnswer((_) async => mockNotificationsSnapshot);

        // Mock bids query
        final mockBidsQuery = MockQuery();
        final mockBidsSnapshot = MockQuerySnapshot();
        final mockBidDoc = MockQueryDocumentSnapshot();

        when(mockBidDoc.data()).thenReturn(bid.toMap());
        when(mockBidsSnapshot.docs).thenReturn([mockBidDoc]);

        when(mockBidsQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockBidsQuery);
        when(mockBidsQuery.limit(50)).thenReturn(mockBidsQuery);
        when(mockBidsQuery.get()).thenAnswer((_) async => mockBidsSnapshot);

        final mockCrewRef = MockDocumentReference();
        when(mockFirestore.collection('crews').doc(crewId))
            .thenReturn(mockCrewRef);
        when(mockCrewRef.collection('jobNotifications'))
            .thenReturn(MockCollectionReference());
        when(MockCollectionReference()
                .orderBy('timestamp', descending: true))
            .thenReturn(mockNotificationsQuery);
        when(mockCrewRef.collection('groupBids'))
            .thenReturn(MockCollectionReference());
        when(MockCollectionReference()
                .orderBy('createdAt', descending: true))
            .thenReturn(mockBidsQuery);

        // Act
        final history = await jobSharingService.getCrewJobHistory(crewId);

        // Assert
        expect(history['total_job_shares'], equals(1));
        expect(history['total_group_bids'], equals(1));
        expect(history['accepted_bids'], equals(1));
        expect(history['success_rate'], equals(100.0));
        expect(history['average_response_rate'], equals(100.0));
        expect(history['recent_notifications'], isNotEmpty);
        expect(history['recent_bids'], isNotEmpty);
      });
    });
  });
}