import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';
  
  final List<String> _filters = [
    'all',
    'jobs',
    'safety',
    'system',
    'applications',
  ];

  final Map<String, String> _filterLabels = {
    'all': 'All',
    'jobs': 'Job Alerts',
    'safety': 'Safety',
    'system': 'System',
    'applications': 'Applications',
  };

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'All notifications marked as read',
        );
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to mark notifications as read',
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'jobs':
        return Icons.work_outline;
      case 'safety':
        return Icons.security;
      case 'system':
        return Icons.settings;
      case 'applications':
        return Icons.assignment;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'jobs':
        return AppTheme.accentCopper;
      case 'safety':
        return AppTheme.errorRed;
      case 'system':
        return AppTheme.primaryNavy;
      case 'applications':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: AppTheme.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = filter == _selectedFilter;
                  return Container(
                    margin: const EdgeInsets.only(right: AppTheme.spacingSm),
                    child: JJChip(
                      label: _filterLabels[filter]!,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: user == null
                ? _buildEmptyState('Please sign in to view notifications')
                : StreamBuilder<QuerySnapshot>(
                    stream: _buildNotificationsStream(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildEmptyState('Error loading notifications');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: JJElectricalLoader(
                            message: 'Loading notifications...',
                          ),
                        );
                      }

                      final notifications = snapshot.data?.docs ?? [];

                      if (notifications.isEmpty) {
                        return _buildEmptyState('No notifications yet');
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final data = notification.data() as Map<String, dynamic>;
                          
                          return _buildNotificationCard(
                            notificationId: notification.id,
                            data: data,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildNotificationsStream(String userId) {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (_selectedFilter != 'all') {
      query = query.where('type', isEqualTo: _selectedFilter);
    }

    return query.snapshots();
  }

  Widget _buildNotificationCard({
    required String notificationId,
    required Map<String, dynamic> data,
  }) {
    final isRead = data['isRead'] ?? false;
    final type = data['type'] ?? 'system';
    final title = data['title'] ?? 'Notification';
    final message = data['message'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: JJCard(
        backgroundColor: isRead ? AppTheme.white : AppTheme.accentCopper.withValues(alpha: 0.05),
        onTap: () => _markAsRead(notificationId),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: _getNotificationColor(type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                _getNotificationIcon(type),
                size: AppTheme.iconMd,
                color: _getNotificationColor(type),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primaryNavy,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentCopper,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    message,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      _formatTimestamp(timestamp),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return JJEmptyState(
      title: 'No Notifications',
      subtitle: message,
      icon: Icons.notifications_none,
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// Helper service to create notifications
class NotificationService {
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': data ?? {},
      });
    } catch (e) {
      // Handle error silently or log
      debugPrint('Failed to create notification: $e');
    }
  }

  static Future<void> createJobAlert({
    required String userId,
    required String jobTitle,
    required String company,
    required String location,
  }) async {
    await createNotification(
      userId: userId,
      type: 'jobs',
      title: 'New Job Match',
      message: '$jobTitle at $company in $location matches your preferences.',
      data: {
        'jobTitle': jobTitle,
        'company': company,
        'location': location,
      },
    );
  }

  static Future<void> createSafetyAlert({
    required String userId,
    required String title,
    required String message,
  }) async {
    await createNotification(
      userId: userId,
      type: 'safety',
      title: title,
      message: message,
    );
  }

  static Future<void> createApplicationUpdate({
    required String userId,
    required String jobTitle,
    required String status,
  }) async {
    await createNotification(
      userId: userId,
      type: 'applications',
      title: 'Application Update',
      message: 'Your application for $jobTitle has been $status.',
      data: {
        'jobTitle': jobTitle,
        'status': status,
      },
    );
  }
}