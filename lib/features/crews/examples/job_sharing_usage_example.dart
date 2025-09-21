import 'package:flutter/foundation.dart';
import '../models/group_bid.dart';
import '../models/crew_enums.dart';
import '../../../services/job_sharing_service.dart';

/// Example usage of extended JobSharingService for crew coordination
///
/// Demonstrates IBEW electrical worker workflows for storm work,
/// crew coordination, and group bidding processes.
class JobSharingUsageExample {
  final JobSharingService _jobSharingService = JobSharingService();

  /// Example: Storm work coordination flow
  ///
  /// Demonstrates how a foreman shares urgent storm work with crew
  /// and coordinates responses for emergency restoration.
  Future<void> stormWorkCoordinationExample() async {
    try {
      // 1. Foreman discovers storm work opportunity
      const jobId = 'storm_job_florida_2024';
      const crewId = 'lightning_crew_local_123';
      const urgentMessage = '''
      🌪️ URGENT STORM WORK - Hurricane recovery in Pensacola, FL

      Details:
      - Rate: \$65/hr + per diem
      - Duration: 2-4 weeks
      - Housing provided
      - Start: Tomorrow 6 AM

      Need immediate responses - job starts in 12 hours!
      ''';

      // 2. Share job to crew with priority flag
      final notificationId = await _jobSharingService.shareJobToCrew(
        jobId,
        crewId,
        urgentMessage,
        isPriority: true, // Storm work gets priority
        expiresAt: DateTime.now().add(const Duration(hours: 8)),
      );

      debugPrint('Storm work shared to crew: $notificationId');

      // 3. Crew members respond (this would happen from their devices)
      await _simulateCrewResponses(notificationId);

      // 4. Check responses and coordinate
      final responses = await _jobSharingService.getJobNotificationResponses(
        notificationId,
      );

      final interestedMembers = responses.entries
          .where((entry) => entry.value.type == ResponseType.accepted)
          .map((entry) => entry.key)
          .toList();

      debugPrint('Interested crew members: ${interestedMembers.length}');

      // 5. If enough interest, create group bid
      if (interestedMembers.length >= 3) {
        await _createStormWorkGroupBid(
          crewId,
          jobId,
          notificationId,
          interestedMembers,
        );
      }
    } catch (e) {
      debugPrint('Storm work coordination failed: $e');
    }
  }

  /// Example: Regular job sharing and crew coordination
  ///
  /// Demonstrates standard workflow for non-emergency electrical work
  Future<void> regularJobSharingExample() async {
    try {
      // 1. Share regular transmission work
      const jobId = 'transmission_project_texas';
      const crewId = 'high_voltage_crew_456';
      const message = '''
      High voltage transmission project in Dallas area

      - Rate: \$52/hr
      - Duration: 8 weeks
      - Commercial project
      - Local 20 jurisdiction

      Good opportunity for summer work!
      ''';

      final notificationId = await _jobSharingService.shareJobToCrew(
        jobId,
        crewId,
        message,
        isPriority: false,
        expiresAt: DateTime.now().add(const Duration(days: 3)),
      );
      
      debugPrint('Regular job shared: $notificationId');

      // 2. Auto-calculate match score
      final matchScore = await _jobSharingService.calculateCrewMatchScore(
        jobId,
        crewId,
      );

      debugPrint('Job match score: ${(matchScore * 100).toStringAsFixed(1)}%');

      // 3. Auto-share similar jobs if enabled
      final autoSharedJobs = await _jobSharingService.autoShareMatchingJobs(
        crewId,
      );

      debugPrint('Auto-shared ${autoSharedJobs.length} matching jobs');
    } catch (e) {
      debugPrint('Regular job sharing failed: $e');
    }
  }

  /// Example: Group bid creation and management
  ///
  /// Shows how crews coordinate to submit group applications
  Future<void> groupBiddingExample() async {
    try {
      const crewId = 'substation_specialists_789';
      const jobId = 'substation_upgrade_arizona';
      const notificationId = 'notification_substation_job';

      // 1. Create comprehensive group bid
      final bidTerms = BidTerms(
        proposedRate: 58.0, // Competitive rate for substation work
        startDate: DateTime.now().add(const Duration(days: 14)),
        estimatedDuration: 12, // 12 weeks
        certificationsCovered: [
          'NECA Substation Certification',
          'OSHA 10-Hour',
          'High Voltage Safety',
          'CPR/First Aid',
        ],
        additionalTerms: 'Crew has specialized substation testing equipment',
        housingRequested: true,
        transportationRequested: true,
        preferredSchedule: '4x10 schedule preferred',
        crewEquipment: [
          'High voltage test equipment',
          'Insulated tools',
          'Safety equipment',
        ],
        perDiemRequested: 120.0, // $120/day per person
      );

      final groupBid = GroupBid(
        id: '', // Will be generated
        crewId: crewId,
        jobId: jobId,
        jobNotificationId: notificationId,
        participatingMembers: [
          'foreman_mike_123',
          'journeyman_sarah_456',
          'journeyman_tom_789',
          'apprentice_alex_012',
        ],
        memberRoles: {
          'foreman_mike_123': 'Lead Foreman',
          'journeyman_sarah_456': 'Test Technician',
          'journeyman_tom_789': 'Installation Specialist',
          'apprentice_alex_012': 'Apprentice Electrician',
        },
        submittedAt: DateTime.now(),
        status: GroupBidStatus.draft,
        terms: bidTerms,
        createdByUserId: 'foreman_mike_123',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // 2. Create the group bid
      final bidId = await _jobSharingService.createGroupBid(groupBid);
      debugPrint('Group bid created: $bidId');

      // 3. Submit to employer
      await _jobSharingService.submitGroupBid(bidId);
      debugPrint('Group bid submitted successfully');

      // 4. Simulate employer response (this would come from external system)
      await Future.delayed(const Duration(seconds: 2));

      await _jobSharingService.updateBidStatus(
        bidId,
        GroupBidStatus.accepted,
        employerResponse: 'Congratulations! Your crew has been selected for this project. Please contact our project manager to finalize details.',
      );

      debugPrint('Bid accepted! Crew got the job.');
    } catch (e) {
      debugPrint('Group bidding failed: $e');
    }
  }

  /// Example: Crew performance analytics
  ///
  /// Shows how to track crew job sharing performance
  Future<void> crewAnalyticsExample() async {
    try {
      const crewId = 'analytics_demo_crew';

      // Get comprehensive crew job history
      final history = await _jobSharingService.getCrewJobHistory(crewId);

      debugPrint('=== Crew Performance Analytics ===');
      debugPrint('Total job shares: ${history['total_job_shares']}');
      debugPrint('Total group bids: ${history['total_group_bids']}');
      debugPrint('Accepted bids: ${history['accepted_bids']}');
      debugPrint('Success rate: ${history['success_rate'].toStringAsFixed(1)}%');
      debugPrint('Avg response rate: ${history['average_response_rate'].toStringAsFixed(1)}%');

      // Analyze recent activity
      final recentNotifications = history['recent_notifications'] as List;
      final recentBids = history['recent_bids'] as List;

      debugPrint('\n=== Recent Activity ===');
      debugPrint('Recent notifications: ${recentNotifications.length}');
      debugPrint('Recent bids: ${recentBids.length}');

      // Performance insights
      if (history['success_rate'] > 75) {
        debugPrint('\n✅ High-performing crew! Great job coordination.');
      } else if (history['success_rate'] > 50) {
        debugPrint('\n⚠️ Moderate performance. Consider improving response times.');
      } else {
        debugPrint('\n❌ Low success rate. Review bidding strategy and job matching.');
      }
    } catch (e) {
      debugPrint('Analytics failed: $e');
    }
  }

  /// Example: Offline-capable job response
  ///
  /// Shows how electrical workers can respond even with limited connectivity
  Future<void> offlineJobResponseExample() async {
    try {
      const notificationId = 'offline_job_notification';
      const userId = 'field_worker_555';

      // Simulate worker in field with intermittent connectivity
      debugPrint('Worker responding to job from remote location...');

      await _jobSharingService.respondToJobNotification(
        notificationId,
        userId,
        ResponseType.accepted,
        note: 'Available for this job. Currently finishing up in Tampa, can start Monday.',
      );

      debugPrint('Response recorded successfully despite connectivity issues');
    } catch (e) {
      debugPrint('Offline response failed: $e');
      // In real app, this would queue for retry when connectivity returns
    }
  }

  /// Helper: Simulate crew member responses to storm work
  Future<void> _simulateCrewResponses(String notificationId) async {
    final responses = [
      {'userId': 'journeyman_bob_123', 'response': ResponseType.accepted, 'note': 'Ready for storm work!'},
      {'userId': 'apprentice_lisa_456', 'response': ResponseType.accepted, 'note': 'Available, have storm experience'},
      {'userId': 'operator_carlos_789', 'response': ResponseType.accepted, 'note': 'Bucket truck ready'},
      {'userId': 'journeyman_dave_012', 'response': ResponseType.declined, 'note': 'Family commitment this week'},
    ];

    for (final response in responses) {
      await _jobSharingService.respondToJobNotification(
        notificationId,
        response['userId'] as String,
        response['response'] as ResponseType,
        note: response['note'] as String,
      );
    }
  }

  /// Helper: Create group bid for storm work
  Future<void> _createStormWorkGroupBid(
    String crewId,
    String jobId,
    String notificationId,
    List<String> members,
  ) async {
    final bidTerms = BidTerms(
      proposedRate: 65.0, // Match the storm work rate
      startDate: DateTime.now().add(const Duration(hours: 12)),
      estimatedDuration: 3, // 3 weeks estimated
      housingRequested: true,
      transportationRequested: true,
      additionalTerms: 'Crew has storm restoration experience and all required certifications',
      crewEquipment: [
        'Storm response vehicles',
        'Emergency restoration equipment',
        'Safety gear for storm conditions',
      ],
    );

    final groupBid = GroupBid(
      id: '',
      crewId: crewId,
      jobId: jobId,
      jobNotificationId: notificationId,
      participatingMembers: members,
      memberRoles: _assignStormWorkRoles(members),
      submittedAt: DateTime.now(),
      terms: bidTerms,
      createdByUserId: members.first, // First member is foreman
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    final bidId = await _jobSharingService.createGroupBid(groupBid);
    await _jobSharingService.submitGroupBid(bidId);

    debugPrint('Storm work group bid submitted: $bidId');
  }

  /// Helper: Assign roles for storm work
  Map<String, String> _assignStormWorkRoles(List<String> members) {
    final roles = <String, String>{};

    for (int i = 0; i < members.length; i++) {
      switch (i) {
        case 0:
          roles[members[i]] = 'Foreman';
          break;
        case 1:
          roles[members[i]] = 'Lead Journeyman';
          break;
        case 2:
          roles[members[i]] = 'Equipment Operator';
          break;
        default:
          roles[members[i]] = 'Journeyman Lineman';
      }
    }

    return roles;
  }
}

/// Example usage runner
void main() async {
  final example = JobSharingUsageExample();

  debugPrint('🌩️ Running storm work coordination example...');
  await example.stormWorkCoordinationExample();

  debugPrint('\n🔌 Running regular job sharing example...');
  await example.regularJobSharingExample();

  debugPrint('\n👥 Running group bidding example...');
  await example.groupBiddingExample();

  debugPrint('\n📊 Running crew analytics example...');
  await example.crewAnalyticsExample();

  debugPrint('\n📱 Running offline response example...');
  await example.offlineJobResponseExample();

  debugPrint('\n✅ All examples completed!');
}