// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/job_model.dart';
import '../../../models/user_model.dart';
import 'widgets.dart';
import '../models/share_notification_model.dart';

/// Demo screen showcasing job sharing widgets
/// 
/// For development and testing purposes
class JJShareWidgetsDemo extends StatefulWidget {
  const JJShareWidgetsDemo({super.key});

  @override
  State<JJShareWidgetsDemo> createState() => _JJShareWidgetsDemoState();
}

class _JJShareWidgetsDemoState extends State<JJShareWidgetsDemo> {
  bool _isSharing = false;

  // Mock data using existing Job model
  final _mockJob = Job(
    id: 'demo-job-1',
    company: 'IBEW Local 103',
    location: 'Boston, MA',
    wage: 65.0,
    jobTitle: 'Senior Journeyman Electrician',
    jobDescription: 'Seeking experienced journeyman electrician for large commercial project...',
    classification: 'Journeyman',
    local: 103,
    localNumber: 103,
    hours: 40,
    qualifications: 'Valid journeyman license, 5+ years experience',
    datePosted: DateTime.now().subtract(const Duration(days: 2)).toString(),
    typeOfWork: 'Commercial',
  );
final _mockContacts = [
  UserModel(
    uid: 'user-1',
    firstName: 'Mike',
    lastName: 'Johnson',
    email: 'mike.johnson@ibew.org',
    phoneNumber: '555-0101',
    address1: '123 Main St',
    city: 'Boston',
    state: 'MA',
    zipcode: '02101',
    homeLocal: '103',
    ticketNumber: 'T12345',
    classification: 'Journeyman',
    isWorking: true,
    constructionTypes: ['Commercial', 'Residential'],
    networkWithOthers: true,
    careerAdvancements: true,
    betterBenefits: true,
    higherPayRate: true,
    learnNewSkill: true,
    travelToNewLocation: true,
    findLongTermWork: true,
    onboardingStatus: 'completed',
    createdTime: DateTime.now(),
    photoUrl: null,
  ), // Closing parenthesis for the first UserModel
  UserModel(
    uid: 'user-2',
    firstName: 'Sarah',
    lastName: 'Wilson',
    email: 'sarah.wilson@ibew.org',
    phoneNumber: '555-0102',
    address1: '456 Oak Ave',
    city: 'Boston',
    state: 'MA',
    zipcode: '02102',
    homeLocal: '103',
    ticketNumber: 'T67890',
    classification: 'Journeyman',
    isWorking: true,
    constructionTypes: ['Industrial', 'Commercial'],
    networkWithOthers: true,
    careerAdvancements: true,
    betterBenefits: true,
    higherPayRate: true,
    learnNewSkill: true,
    travelToNewLocation: true,
    findLongTermWork: true,
    onboardingStatus: 'completed',
    createdTime: DateTime.now(),
    photoUrl: null,
  ),
  UserModel(
    uid: 'user-3',
    firstName: 'David',
    lastName: 'Chen',
    email: 'david.chen@ibew.org',
    phoneNumber: '555-0103',
    address1: '789 Pine St',
    city: 'Boston',
    state: 'MA',
    zipcode: '02103',
    homeLocal: '103',
    ticketNumber: 'T11111',
    classification: 'Journeyman',
    isWorking: false,
    constructionTypes: ['Residential', 'Industrial'],
    networkWithOthers: true,
    careerAdvancements: true,
    betterBenefits: true,
    higherPayRate: true,
    learnNewSkill: true,
    travelToNewLocation: true,
    findLongTermWork: true,
    onboardingStatus: 'completed',
    createdTime: DateTime.now(),
    photoUrl: null,
  ),
];

  final _mockNotifications = [
    ShareNotificationModel(
      id: 'notif-1',
      type: ShareNotificationType.shareReceived,
      message: 'Mike Johnson shared a job opportunity with you',
      senderName: 'Mike Johnson',
      jobId: 'job-123',
      jobTitle: 'Senior Journeyman Electrician',
      jobCompany: 'IBEW Local 103',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ShareNotificationModel(
      id: 'notif-2',
      type: ShareNotificationType.shareViewed,
      message: 'Sarah Wilson viewed the job you shared',
      senderName: 'Sarah Wilson',
      jobId: 'job-456',
      jobTitle: 'Lineman - Storm Restoration',
      jobCompany: 'IBEW Local 456',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      readAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ShareNotificationModel(
      id: 'notif-3',
      type: ShareNotificationType.jobShared,
      message: 'You shared a job with 3 people',
      jobId: 'job-789',
      jobTitle: 'Equipment Operator',
      jobCompany: 'IBEW Local 789',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      readAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Job Sharing Widgets Demo'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // Share Button Section
          _buildSection(
            title: 'Share Buttons',
            children: [
              const Text(
                'Different sizes and variants:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      JJShareButton(
                        size: JJShareButtonSize.small,
                        onPressed: () => _showShareModal(context),
                        tooltip: 'Share Small',
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Small',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  
                  Column(
                    children: [
                      JJShareButton(
                        size: JJShareButtonSize.medium,
                        onPressed: () => _showShareModal(context),
                        tooltip: 'Share Medium',
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Medium',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  
                  Column(
                    children: [
                      JJShareButton(
                        size: JJShareButtonSize.large,
                        onPressed: () => _showShareModal(context),
                        tooltip: 'Share Large',
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Large',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      JJShareButton(
                        variant: JJShareButtonVariant.secondary,
                        onPressed: () => _showShareModal(context),
                        tooltip: 'Secondary Style',
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Secondary',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  
                  Column(
                    children: [
                      const JJShareButton(
                        isLoading: true,
                        onPressed: null,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Loading',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
          
          // Notifications Section
          _buildSection(
            title: 'Share Notifications',
            children: [
              const Text(
                'Different notification types:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              ..._mockNotifications.map((notification) {
                return JJNotificationCard(
                  notification: notification,
                  onTap: () => _showSnackbar('Notification tapped'),
                  onViewJob: () => _showSnackbar('View job tapped'),
                  onMarkAsRead: () => _showSnackbar('Marked as read'),
                  onDismiss: () => _showSnackbar('Notification dismissed'),
                );
              }).toList(),
            ],
          ),
        ],
      ),
      
      // Floating share button
      floatingActionButton: JJShareButton(
        size: JJShareButtonSize.large,
        onPressed: () => _showShareModal(context),
        tooltip: 'Share Job',
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...children,
        ],
      ),
    );
  }

  void _showShareModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => JJShareModal(
        job: _mockJob,
        contacts: _mockContacts,
        isSharing: _isSharing,
        onShare: (recipients, message) {
          setState(() => _isSharing = true);
          
          // Simulate sharing delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _isSharing = false);
              Navigator.of(context).pop();
              _showSnackbar('Job shared with ${recipients.length} people!');
            }
          });
        },
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentCopper,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}
