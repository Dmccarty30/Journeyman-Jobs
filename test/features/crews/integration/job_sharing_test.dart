import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// These imports will fail until models are implemented (TDD requirement)
import '../../../../lib/features/crews/models/job_notification.dart';
import '../../../../lib/features/crews/models/group_bid.dart';
import '../../../../lib/features/crews/services/crew_job_sharing_service.dart';
import '../../../../lib/models/job_model.dart';
import '../../../../lib/models/user_model.dart';

@GenerateMocks([http.Client])
import 'job_sharing_test.mocks.dart';

/// CONTRACT TEST (T009): Crew Job Sharing API Integration
/// 
/// Tests validate Firebase Cloud Functions API contracts for crew job sharing.
/// Written FIRST and MUST FAIL before any implementation exists (TDD).
/// 
/// Validates against: docs/features/Crews/contracts/crew-management-api.yaml
/// Tests Firebase functions in: functions/src/crews.js
/// 
/// Focus: IBEW electrical job sharing, storm work coordination, group bidding
void main() {
  group('Crew Job Sharing Contract Test (T009)', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late MockUser mockForeman;
    late MockUser mockLineman;
    late CrewJobSharingService jobSharingService;
    late MockClient httpClient;

    setUpAll(() {
      // Set up Firebase emulator environment for realistic testing
    });

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
      httpClient = MockClient();

      // Create test electrical workers with IBEW context
      mockForeman = MockUser(
        uid: 'foreman-001',
        email: 'foreman@ibew26.org',
        displayName: 'Mike Rodriguez',
      );

      mockLineman = MockUser(
        uid: 'lineman-002',
        email: 'jlineman@ibew125.org',
        displayName: 'Sarah Johnson',
      );

      when(auth.currentUser).thenReturn(mockForeman);

      // Initialize service (this will fail until implemented)
      jobSharingService = CrewJobSharingService(
        firestore: firestore,
        auth: auth,
        httpClient: httpClient,
      );

      // Set up test data for electrical jobs and crews
      await _setupElectricalJobsAndCrewData();
    });

    /// T009: Contract test POST /crews/{crewId}/jobs
    /// Tests sharing electrical jobs with crew coordination
    group('T009: POST /crews/{crewId}/jobs Contract', () {
      testWidgets('should share storm work job with crew successfully', (tester) async {
        // Arrange: Share high-priority storm restoration job
        const crewId = 'crew_storm_001';
        const jobId = 'job_hurricane_restoration_fl';
        final shareRequest = {
          'jobId': jobId,
          'message': 'Urgent: Hurricane restoration work in Florida. $50/hr + per diem. All hands needed!',
          'isPriority': true,
          'stormEvent': 'Hurricane Milton',
          'estimatedDuration': '3-4 weeks',
          'housingProvided': true,
        };

        // Mock successful job sharing response
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'id': 'notification_001',
            'jobId': jobId,
            'crewId': crewId,
            'sharedByUserId': 'foreman-001',
            'message': 'Urgent: Hurricane restoration work in Florida. \$50/hr + per diem. All hands needed!',
            'timestamp': DateTime.now().toIso8601String(),
            'memberResponses': {},
            'groupBidStatus': 'pending',
            'isPriority': true,
            'viewCount': 0,
            'responseCount': 0,
            'stormEvent': 'Hurricane Milton',
            'jobDetails': {
              'title': 'Hurricane Milton Restoration - Florida',
              'rate': 50.0,
              'location': 'Tampa Bay, FL',
              'classification': 'journeyman_lineman',
              'jobType': 'storm_work',
              'duration': '3-4 weeks',
              'requirements': ['bucket_truck', 'storm_restoration_cert'],
            }
          }),
          201,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Share storm job with crew
        final result = await jobSharingService.shareJobToCrew(
          crewId: crewId,
          jobId: jobId,
          message: shareRequest['message'] as String,
          isPriority: true,
          stormEvent: 'Hurricane Milton',
        );

        // Assert: Validate API contract compliance
        expect(result.success, isTrue, reason: 'Job sharing should succeed');
        expect(result.data, isNotNull, reason: 'Should return job notification');
        
        final notification = result.data as JobNotification;
        expect(notification.id, equals('notification_001'));
        expect(notification.jobId, equals(jobId));
        expect(notification.crewId, equals(crewId));
        expect(notification.sharedByUserId, equals('foreman-001'));
        expect(notification.isPriority, isTrue, reason: 'Storm work should be priority');
        expect(notification.stormEvent, equals('Hurricane Milton'));
        expect(notification.groupBidStatus, equals(GroupBidStatus.pending));
        expect(notification.memberResponses.isEmpty, isTrue, reason: 'No initial responses');

        // Verify electrical job context
        expect(notification.jobDetails?.classification, equals('journeyman_lineman'));
        expect(notification.jobDetails?.jobType, equals('storm_work'));
        expect(notification.jobDetails?.requirements, contains('storm_restoration_cert'));

        // Verify HTTP contract
        verify(httpClient.post(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs'),
          headers: {
            'Authorization': 'Bearer ${await auth.currentUser!.getIdToken()}',
            'Content-Type': 'application/json',
          },
          body: json.encode(shareRequest),
        )).called(1);
      });

      testWidgets('should share commercial electrical job with crew', (tester) async {
        // Arrange: Share regular commercial job
        const crewId = 'crew_commercial_002';
        const jobId = 'job_commercial_office_tx';
        final shareRequest = {
          'jobId': jobId,
          'message': 'Commercial office building in Dallas. Looking for inside wiremen. 6 month project.',
          'isPriority': false,
        };

        // Mock successful commercial job sharing
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'id': 'notification_002',
            'jobId': jobId,
            'crewId': crewId,
            'sharedByUserId': 'foreman-001',
            'message': 'Commercial office building in Dallas. Looking for inside wiremen. 6 month project.',
            'timestamp': DateTime.now().toIso8601String(),
            'memberResponses': {},
            'groupBidStatus': 'pending',
            'isPriority': false,
            'viewCount': 0,
            'responseCount': 0,
            'jobDetails': {
              'title': 'Commercial Office Building - Dallas',
              'rate': 38.50,
              'location': 'Dallas, TX',
              'classification': 'inside_wireman',
              'jobType': 'commercial',
              'duration': '6 months',
              'requirements': ['conduit_bending', 'blueprint_reading'],
            }
          }),
          201,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Share commercial job
        final result = await jobSharingService.shareJobToCrew(
          crewId: crewId,
          jobId: jobId,
          message: shareRequest['message'] as String,
          isPriority: false,
        );

        // Assert: Validate commercial job sharing
        expect(result.success, isTrue);
        final notification = result.data as JobNotification;
        expect(notification.isPriority, isFalse, reason: 'Regular work not priority');
        expect(notification.jobDetails?.classification, equals('inside_wireman'));
        expect(notification.jobDetails?.jobType, equals('commercial'));
        expect(notification.jobDetails?.duration, equals('6 months'));
      });

      testWidgets('should reject sharing already shared job', (tester) async {
        // Arrange: Job already shared to crew
        const crewId = 'crew_storm_001';
        const jobId = 'job_already_shared';

        // Mock already shared error
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'error': 'Job already shared to crew or invalid job ID',
            'details': {
              'job': 'This job has already been shared to this crew'
            }
          }),
          400,
          headers: {'content-type': 'application/json'},
        ));

        // Act & Assert: Expect duplicate sharing failure
        expect(
          () => jobSharingService.shareJobToCrew(
            crewId: crewId,
            jobId: jobId,
            message: 'Duplicate sharing attempt',
          ),
          throwsA(isA<CrewJobSharingException>()
            .having((e) => e.code, 'code', equals('job-already-shared'))
            .having((e) => e.message, 'message', contains('already been shared'))
          ),
        );
      });

      testWidgets('should reject sharing invalid job ID', (tester) async {
        // Arrange: Non-existent job ID
        const crewId = 'crew_storm_001';
        const invalidJobId = 'job_does_not_exist';

        // Mock invalid job error
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'error': 'Job already shared to crew or invalid job ID',
            'details': {
              'job': 'Job not found or no longer available'
            }
          }),
          400,
          headers: {'content-type': 'application/json'},
        ));

        // Act & Assert: Expect invalid job failure
        expect(
          () => jobSharingService.shareJobToCrew(
            crewId: crewId,
            jobId: invalidJobId,
            message: 'Sharing non-existent job',
          ),
          throwsA(isA<CrewJobSharingException>()
            .having((e) => e.code, 'code', equals('invalid-job'))
          ),
        );
      });

      testWidgets('should reject sharing from non-member', (tester) async {
        // Arrange: User not a member of crew
        const crewId = 'crew_restricted';
        const jobId = 'job_valid';

        // Mock not a member error
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'error': 'Not a crew member',
            'details': {
              'permission': 'Only crew members can share jobs'
            }
          }),
          403,
          headers: {'content-type': 'application/json'},
        ));

        // Act & Assert: Expect access denied failure
        expect(
          () => jobSharingService.shareJobToCrew(
            crewId: crewId,
            jobId: jobId,
            message: 'Unauthorized sharing attempt',
          ),
          throwsA(isA<CrewJobSharingException>()
            .having((e) => e.code, 'code', equals('not-crew-member'))
          ),
        );
      });
    });

    /// Tests for member responses to job notifications
    group('Job Notification Response Tests', () {
      testWidgets('should handle member interest response to storm job', (tester) async {
        // Arrange: Member responds with interest to storm work
        const crewId = 'crew_storm_001';
        const notificationId = 'notification_001';
        final responseRequest = {
          'response': 'interested',
          'note': 'Available for full duration. Have bucket truck certification.',
          'availableStartDate': '2024-03-15',
          'certifications': ['storm_restoration', 'bucket_truck', 'osha_30']
        };

        // Mock successful response recording
        when(httpClient.post(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs/$notificationId/respond'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'success': true,
            'response': 'interested',
            'userId': 'lineman-002',
            'timestamp': DateTime.now().toIso8601String(),
            'note': 'Available for full duration. Have bucket truck certification.',
            'certifications': ['storm_restoration', 'bucket_truck', 'osha_30']
          }),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Respond with interest
        final result = await jobSharingService.respondToJobNotification(
          crewId: crewId,
          notificationId: notificationId,
          response: MemberResponse.interested,
          note: 'Available for full duration. Have bucket truck certification.',
          certifications: ['storm_restoration', 'bucket_truck', 'osha_30'],
        );

        // Assert: Validate response recording
        expect(result.success, isTrue);
        expect(result.data['response'], equals('interested'));
        expect(result.data['certifications'], contains('storm_restoration'));
        expect(result.data['note'], isNotNull);
      });

      testWidgets('should handle member applied response with conditions', (tester) async {
        // Arrange: Member applies with specific conditions
        const crewId = 'crew_commercial_002';
        const notificationId = 'notification_002';
        final responseRequest = {
          'response': 'conditional_yes',
          'note': 'Can work if housing assistance provided. Need 2 weeks notice.',
          'conditions': ['housing_assistance', 'two_weeks_notice']
        };

        // Mock conditional application response
        when(httpClient.post(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs/$notificationId/respond'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'success': true,
            'response': 'conditional_yes',
            'userId': 'foreman-001',
            'timestamp': DateTime.now().toIso8601String(),
            'note': 'Can work if housing assistance provided. Need 2 weeks notice.',
            'conditions': ['housing_assistance', 'two_weeks_notice']
          }),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Respond conditionally
        final result = await jobSharingService.respondToJobNotification(
          crewId: crewId,
          notificationId: notificationId,
          response: MemberResponse.conditionalYes,
          note: 'Can work if housing assistance provided. Need 2 weeks notice.',
          conditions: ['housing_assistance', 'two_weeks_notice'],
        );

        // Assert: Validate conditional response
        expect(result.success, isTrue);
        expect(result.data['response'], equals('conditional_yes'));
        expect(result.data['conditions'], contains('housing_assistance'));
      });

      testWidgets('should handle member not interested response', (tester) async {
        // Arrange: Member declines job opportunity
        const crewId = 'crew_storm_001';
        const notificationId = 'notification_001';

        // Mock not interested response
        when(httpClient.post(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs/$notificationId/respond'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'success': true,
            'response': 'not_interested',
            'userId': 'lineman-002',
            'timestamp': DateTime.now().toIso8601String(),
            'note': 'Already committed to another project'
          }),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Decline opportunity
        final result = await jobSharingService.respondToJobNotification(
          crewId: crewId,
          notificationId: notificationId,
          response: MemberResponse.notInterested,
          note: 'Already committed to another project',
        );

        // Assert: Validate decline response
        expect(result.success, isTrue);
        expect(result.data['response'], equals('not_interested'));
      });

      testWidgets('should reject response to non-existent job notification', (tester) async {
        // Arrange: Non-existent notification ID
        const crewId = 'crew_storm_001';
        const invalidNotificationId = 'notification_invalid';

        // Mock not found error
        when(httpClient.post(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs/$invalidNotificationId/respond'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'error': 'Job notification not found',
            'details': {
              'notification': 'Notification may have been removed or expired'
            }
          }),
          404,
          headers: {'content-type': 'application/json'},
        ));

        // Act & Assert: Expect not found failure
        expect(
          () => jobSharingService.respondToJobNotification(
            crewId: crewId,
            notificationId: invalidNotificationId,
            response: MemberResponse.interested,
          ),
          throwsA(isA<CrewJobSharingException>()
            .having((e) => e.code, 'code', equals('notification-not-found'))
          ),
        );
      });
    });

    /// Tests for retrieving crew job notifications
    group('GET /crews/{crewId}/jobs Contract', () {
      testWidgets('should retrieve crew job notifications with electrical context', (tester) async {
        // Arrange: Crew has multiple shared jobs
        const crewId = 'crew_storm_001';
        final mockNotifications = [
          {
            'id': 'notification_001',
            'jobId': 'job_hurricane_restoration_fl',
            'crewId': crewId,
            'sharedByUserId': 'foreman-001',
            'message': 'Urgent storm restoration work needed',
            'timestamp': '2024-03-10T08:00:00.000Z',
            'memberResponses': {
              'lineman-002': {
                'type': 'interested',
                'timestamp': '2024-03-10T08:30:00.000Z',
                'note': 'Available immediately'
              }
            },
            'groupBidStatus': 'coordinating',
            'isPriority': true,
            'viewCount': 3,
            'responseCount': 1,
            'stormEvent': 'Hurricane Milton',
            'jobDetails': {
              'title': 'Hurricane Milton Restoration',
              'classification': 'journeyman_lineman',
              'rate': 50.0,
              'location': 'Florida',
            }
          },
          {
            'id': 'notification_002',
            'jobId': 'job_commercial_office_tx',
            'crewId': crewId,
            'sharedByUserId': 'foreman-001',
            'message': 'Long-term commercial project',
            'timestamp': '2024-03-09T14:00:00.000Z',
            'memberResponses': {},
            'groupBidStatus': 'pending',
            'isPriority': false,
            'viewCount': 2,
            'responseCount': 0,
            'jobDetails': {
              'title': 'Commercial Office Building',
              'classification': 'inside_wireman',
              'rate': 38.50,
              'location': 'Dallas, TX',
            }
          }
        ];

        // Mock successful notifications retrieval
        when(httpClient.get(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode(mockNotifications),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Get crew job notifications
        final result = await jobSharingService.getCrewJobNotifications(crewId);

        // Assert: Validate retrieved notifications
        expect(result.success, isTrue);
        final notifications = result.data as List<JobNotification>;
        expect(notifications.length, equals(2));

        // Validate storm work notification
        final stormNotification = notifications.firstWhere((n) => n.isPriority);
        expect(stormNotification.stormEvent, equals('Hurricane Milton'));
        expect(stormNotification.groupBidStatus, equals(GroupBidStatus.coordinating));
        expect(stormNotification.memberResponses.length, equals(1));
        expect(stormNotification.jobDetails?.classification, equals('journeyman_lineman'));

        // Validate commercial notification
        final commercialNotification = notifications.firstWhere((n) => !n.isPriority);
        expect(commercialNotification.groupBidStatus, equals(GroupBidStatus.pending));
        expect(commercialNotification.memberResponses.isEmpty, isTrue);
        expect(commercialNotification.jobDetails?.classification, equals('inside_wireman'));
      });

      testWidgets('should filter job notifications by status', (tester) async {
        // Arrange: Request only submitted group bids
        const crewId = 'crew_storm_001';
        final queryParams = {'status': 'submitted'};

        // Mock filtered results
        when(httpClient.get(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs?status=submitted'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode([
            {
              'id': 'notification_003',
              'jobId': 'job_submitted_bid',
              'crewId': crewId,
              'groupBidStatus': 'submitted',
              'isPriority': false,
              'memberResponses': {
                'foreman-001': {'type': 'interested'},
                'lineman-002': {'type': 'interested'},
                'electrician-003': {'type': 'interested'}
              }
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Get filtered notifications
        final result = await jobSharingService.getCrewJobNotifications(
          crewId,
          status: GroupBidStatus.submitted,
        );

        // Assert: Validate filtered results
        expect(result.success, isTrue);
        final notifications = result.data as List<JobNotification>;
        expect(notifications.length, equals(1));
        expect(notifications.first.groupBidStatus, equals(GroupBidStatus.submitted));
      });

      testWidgets('should handle pagination for large notification lists', (tester) async {
        // Arrange: Request with limit
        const crewId = 'crew_active';
        final queryParams = {'limit': '10'};

        // Mock paginated response
        when(httpClient.get(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs?limit=10'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode([]), // Empty for brevity, would contain 10 items
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Get limited notifications
        final result = await jobSharingService.getCrewJobNotifications(
          crewId,
          limit: 10,
        );

        // Assert: Validate pagination respected
        expect(result.success, isTrue);
        verify(httpClient.get(
          Uri.parse('${jobSharingService.baseUrl}/crews/$crewId/jobs?limit=10'),
          headers: anyNamed('headers'),
        )).called(1);
      });
    });

    group('Electrical Worker Job Matching', () {
      testWidgets('should validate job classification matches crew specializations', (tester) async {
        // Arrange: Share lineman job with inside wireman crew
        const crewId = 'crew_inside_wiremen';
        const jobId = 'job_transmission_lines'; // Requires journeyman_lineman

        // Mock classification mismatch error
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'error': 'Job classification does not match crew specializations',
            'details': {
              'jobClassification': 'journeyman_lineman',
              'crewSpecializations': ['inside_wireman', 'commercial'],
              'suggestion': 'Share with transmission or distribution crews instead'
            }
          }),
          400,
          headers: {'content-type': 'application/json'},
        ));

        // Act & Assert: Expect classification mismatch failure
        expect(
          () => jobSharingService.shareJobToCrew(
            crewId: crewId,
            jobId: jobId,
            message: 'Transmission line work - wrong crew type',
          ),
          throwsA(isA<CrewJobSharingException>()
            .having((e) => e.code, 'code', equals('classification-mismatch'))
            .having((e) => e.details?['suggestion'], 'suggestion', 
                   contains('transmission or distribution crews'))
          ),
        );
      });

      testWidgets('should handle storm work priority escalation', (tester) async {
        // Arrange: Storm work automatically gets priority status
        const crewId = 'crew_storm_001';
        const stormJobId = 'job_emergency_restoration';

        // Mock automatic priority escalation
        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'id': 'notification_storm_001',
            'jobId': stormJobId,
            'crewId': crewId,
            'isPriority': true, // Automatically set for storm work
            'stormEvent': 'Emergency Restoration',
            'urgencyLevel': 'critical',
            'responseDeadline': DateTime.now().add(Duration(hours: 4)).toIso8601String(),
            'jobDetails': {
              'classification': 'journeyman_lineman',
              'jobType': 'storm_work',
              'urgency': 'critical',
            }
          }),
          201,
          headers: {'content-type': 'application/json'},
        ));

        // Act: Share emergency restoration job
        final result = await jobSharingService.shareJobToCrew(
          crewId: crewId,
          jobId: stormJobId,
          message: 'Emergency power restoration needed now!',
        );

        // Assert: Validate automatic priority escalation
        expect(result.success, isTrue);
        final notification = result.data as JobNotification;
        expect(notification.isPriority, isTrue, 
               reason: 'Storm work should automatically be priority');
        expect(notification.urgencyLevel, equals('critical'));
        expect(notification.responseDeadline, isNotNull);
      });
    });
  });
}

/// Helper function to set up electrical jobs and crew test data
Future<void> _setupElectricalJobsAndCrewData() async {
  // This will fail until models are implemented (TDD requirement)
  // Set up test jobs with electrical worker context
  
  final stormJobData = {
    'id': 'job_hurricane_restoration_fl',
    'title': 'Hurricane Milton Restoration - Florida',
    'classification': 'journeyman_lineman',
    'jobType': 'storm_work',
    'rate': 50.0,
    'location': 'Tampa Bay, FL',
    'duration': '3-4 weeks',
    'requirements': ['bucket_truck', 'storm_restoration_cert', 'cdl_a'],
    'housingProvided': true,
    'perDiem': 75.0,
    'urgency': 'high',
    'stormEvent': 'Hurricane Milton',
    'postedAt': FieldValue.serverTimestamp(),
  };
  
  final commercialJobData = {
    'id': 'job_commercial_office_tx',
    'title': 'Commercial Office Building - Dallas',
    'classification': 'inside_wireman',
    'jobType': 'commercial',
    'rate': 38.50,
    'location': 'Dallas, TX',
    'duration': '6 months',
    'requirements': ['conduit_bending', 'blueprint_reading', 'osha_10'],
    'housingProvided': false,
    'perDiem': 0.0,
    'urgency': 'normal',
    'postedAt': FieldValue.serverTimestamp(),
  };
  
  final crewData = {
    'id': 'crew_storm_001',
    'name': 'Storm Response Team Alpha',
    'leaderId': 'foreman-001',
    'specializations': ['storm_work', 'emergency_restoration', 'transmission'],
    'memberIds': ['foreman-001', 'lineman-002', 'electrician-003'],
  };
  
  // These operations will fail until Firestore models are implemented
  // await firestore.collection('jobs').doc('job_hurricane_restoration_fl').set(stormJobData);
  // await firestore.collection('jobs').doc('job_commercial_office_tx').set(commercialJobData);
  // await firestore.collection('crews').doc('crew_storm_001').set(crewData);
}
