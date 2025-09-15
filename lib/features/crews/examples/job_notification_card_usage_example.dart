import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/job_model.dart';
import '../widgets/job_notification_card.dart';
import '../models/job_notification.dart';
import '../models/crew_enums.dart';

/// Example demonstrating JobNotificationCard widget usage
/// 
/// Shows various notification states and electrical trade features:
/// - Standard job notification
/// - Priority/Storm work notification  
/// - Expired notification
/// - Different classification badges
class JobNotificationCardUsageExample extends ConsumerWidget {
  const JobNotificationCardUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Notification Cards'),
        backgroundColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Standard notification
          JobNotificationCard(
            notification: _createStandardNotification(),
            job: _createInsideWiremanJob(),
            isRead: false,
            onTap: () => _showSnackBar(context, 'Card tapped'),
            onApply: () => _showSnackBar(context, 'Apply tapped'),
            onShare: () => _showSnackBar(context, 'Share tapped'),
            onDiscuss: () => _showSnackBar(context, 'Discuss tapped'),
            onViewDetails: () => _showSnackBar(context, 'View details tapped'),
            onSave: () => _showSnackBar(context, 'Save tapped'),
          ),

          const SizedBox(height: 16),

          // Priority storm work notification
          JobNotificationCard(
            notification: _createPriorityNotification(),
            job: _createStormJob(),
            isRead: true,
            onTap: () => _showSnackBar(context, 'Storm work tapped'),
            onApply: () => _showSnackBar(context, 'Apply for storm work'),
            onShare: () => _showSnackBar(context, 'Share storm work'),
          ),

          const SizedBox(height: 16),

          // Lineman job notification
          JobNotificationCard(
            notification: _createLinemanNotification(),
            job: _createLinemanJob(),
            isRead: true,
            onTap: () => _showSnackBar(context, 'Lineman job tapped'),
            onApply: () => _showSnackBar(context, 'Apply for lineman work'),
          ),

          const SizedBox(height: 16),

          // Expired notification
          JobNotificationCard(
            notification: _createExpiredNotification(),
            job: _createExpiredJob(),
            isRead: true,
            onTap: () => _showSnackBar(context, 'Expired job tapped'),
          ),

          const SizedBox(height: 16),

          // Notification without actions
          JobNotificationCard(
            notification: _createMinimalNotification(),
            job: _createMinimalJob(),
            isRead: true,
            showActions: false,
            onTap: () => _showSnackBar(context, 'Read-only notification'),
          ),
        ],
      ),
    );
  }

  // Create sample notifications for different scenarios

  JobNotification _createStandardNotification() {
    return JobNotification(
      id: 'notif_1',
      jobId: 'job_1',
      crewId: 'crew_alpha',
      sharedByUserId: 'user_foreman',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      memberResponses: {
        'user_1': MemberResponse(
          userId: 'user_1',
          type: ResponseType.accepted,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          note: 'Interested in this one',
        ),
        'user_2': MemberResponse(
          userId: 'user_2',
          type: ResponseType.pending,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        'user_3': MemberResponse(
          userId: 'user_3',
          type: ResponseType.declined,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          note: 'Already committed to another job',
        ),
      },
      groupBidStatus: GroupBidStatus.draft,
      isPriority: false,
      viewCount: 8,
      responseCount: 2,
      appliedMembers: [],
      message: 'Good overtime opportunity downtown. 50+ hours guaranteed.',
      expiresAt: DateTime.now().add(const Duration(days: 2)),
    );
  }

  JobNotification _createPriorityNotification() {
    return JobNotification(
      id: 'notif_2',
      jobId: 'job_2',
      crewId: 'crew_alpha',
      sharedByUserId: 'user_foreman',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      memberResponses: {
        'user_1': MemberResponse(
          userId: 'user_1',
          type: ResponseType.accepted,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        'user_2': MemberResponse(
          userId: 'user_2',
          type: ResponseType.accepted,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      },
      groupBidStatus: GroupBidStatus.submitted,
      isPriority: true,
      viewCount: 6,
      responseCount: 2,
      appliedMembers: ['user_1', 'user_2'],
      message: 'URGENT: Hurricane restoration crew needed. Double time pay.',
      expiresAt: DateTime.now().add(const Duration(hours: 6)),
    );
  }

  JobNotification _createLinemanNotification() {
    return JobNotification(
      id: 'notif_3',
      jobId: 'job_3',
      crewId: 'crew_alpha',
      sharedByUserId: 'user_foreman',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      memberResponses: {
        'user_1': MemberResponse(
          userId: 'user_1',
          type: ResponseType.accepted,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      },
      groupBidStatus: GroupBidStatus.underReview,
      isPriority: false,
      viewCount: 4,
      responseCount: 1,
      appliedMembers: [],
      message: 'Transmission work near the lake. Excellent crew opportunity.',
      expiresAt: DateTime.now().add(const Duration(days: 5)),
    );
  }

  JobNotification _createExpiredNotification() {
    return JobNotification(
      id: 'notif_4',
      jobId: 'job_4',
      crewId: 'crew_alpha',
      sharedByUserId: 'user_foreman',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      memberResponses: {},
      groupBidStatus: GroupBidStatus.expired,
      isPriority: false,
      viewCount: 12,
      responseCount: 0,
      appliedMembers: [],
      message: 'Missed opportunity - acted too slow.',
      expiresAt: DateTime.now().subtract(const Duration(hours: 6)),
    );
  }

  JobNotification _createMinimalNotification() {
    return JobNotification(
      id: 'notif_5',
      jobId: 'job_5',
      crewId: 'crew_alpha',
      sharedByUserId: 'user_foreman',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      memberResponses: {},
      groupBidStatus: GroupBidStatus.draft,
      isPriority: false,
      viewCount: 1,
      responseCount: 0,
      appliedMembers: [],
    );
  }

  // Create sample jobs for different classifications

  Job _createInsideWiremanJob() {
    return const Job(
      id: 'job_1',
      company: 'Metropolitan Electric Co.',
      location: 'Chicago, IL',
      classification: 'Inside Wireman',
      jobTitle: 'Commercial Electrician - High Rise',
      wage: 52.75,
      hours: 45,
      local: 134,
      jobDescription: 'High-rise commercial building electrical installation. '
          'Modern smart building systems with advanced automation.',
      qualifications: 'Inside Wireman certification, 5+ years experience',
      perDiem: '\$75/day',
      duration: '8 months',
      typeOfWork: 'Commercial',
    );
  }

  Job _createStormJob() {
    return const Job(
      id: 'job_2',
      company: 'Emergency Restoration Inc.',
      location: 'Mobile, AL',
      classification: 'Journeyman Lineman',
      jobTitle: 'Hurricane Restoration Lineman',
      wage: 85.00, // Double time
      hours: 60,
      local: 545,
      jobDescription: 'Emergency power line restoration following hurricane damage. '
          'Overtime guaranteed, housing provided.',
      qualifications: 'Journeyman Lineman, storm experience preferred',
      perDiem: '\$150/day',
      duration: '6-8 weeks',
      typeOfWork: 'Emergency/Storm',
    );
  }

  Job _createLinemanJob() {
    return const Job(
      id: 'job_3',
      company: 'Great Lakes Power Authority',
      location: 'Milwaukee, WI',
      classification: 'Journeyman Lineman',
      jobTitle: 'Transmission Line Construction',
      wage: 58.25,
      hours: 40,
      local: 494,
      jobDescription: 'New 345kV transmission line construction project. '
          'Modern equipment and excellent crew environment.',
      qualifications: 'Journeyman Lineman, transmission experience',
      perDiem: '\$95/day',
      duration: '12 months',
      typeOfWork: 'Transmission',
    );
  }

  Job _createExpiredJob() {
    return const Job(
      id: 'job_4',
      company: 'Urban Infrastructure LLC',
      location: 'Detroit, MI',
      classification: 'Inside Wireman',
      jobTitle: 'Industrial Maintenance Electrician',
      wage: 46.50,
      hours: 40,
      local: 58,
      jobDescription: 'Manufacturing facility electrical maintenance.',
      qualifications: 'Inside Wireman, industrial experience',
      duration: 'Ongoing',
      typeOfWork: 'Industrial',
    );
  }

  Job _createMinimalJob() {
    return const Job(
      id: 'job_5',
      company: 'Quick Electric Services',
      location: 'Springfield, IL',
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
      ),
    );
  }
}
