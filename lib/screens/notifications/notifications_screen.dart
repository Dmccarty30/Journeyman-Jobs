import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../services/notification_permission_service.dart';
import '../../services/fcm_service.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../navigation/app_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  
  // Settings state
  bool _isLoadingSettings = true;
  bool _notificationsEnabled = false;
  bool _jobAlertsEnabled = true;
  bool _unionUpdatesEnabled = true;
  bool _systemNotificationsEnabled = true;
  bool _stormWorkEnabled = true;
  bool _unionRemindersEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);
  
  final List<String> _filters = [
    'all',
    'jobs',
    'safety',
    'system',
    'applications',
    'storm',
  ];

  final Map<String, String> _filterLabels = {
    'all': 'All',
    'jobs': 'Job Alerts',
    'safety': 'Safety',
    'system': 'System',
    'applications': 'Applications',
    'storm': 'Storm Work',
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSettings();
    
    // Check for tab query parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.tryParse(GoRouter.of(context).routeInformationProvider.value.uri.toString());
      if (uri != null) {
        final tab = uri.queryParameters['tab'];
        if (tab == 'settings') {
          _tabController.animateTo(1);
        }
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    try {
      _notificationsEnabled = await NotificationPermissionService.areNotificationsEnabled();
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _jobAlertsEnabled = prefs.getBool('job_alerts_enabled') ?? true;
        _unionUpdatesEnabled = prefs.getBool('union_updates_enabled') ?? true;
        _systemNotificationsEnabled = prefs.getBool('system_notifications_enabled') ?? true;
        _stormWorkEnabled = prefs.getBool('storm_work_enabled') ?? true;
        _unionRemindersEnabled = prefs.getBool('union_reminders_enabled') ?? true;
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
        _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
        final startHour = prefs.getInt('quiet_hours_start') ?? 22;
        final endHour = prefs.getInt('quiet_hours_end') ?? 7;
        _quietHoursStart = TimeOfDay(hour: startHour, minute: 0);
        _quietHoursEnd = TimeOfDay(hour: endHour, minute: 0);
        _isLoadingSettings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSettings = false;
      });
      debugPrint('Error loading notification settings: $e');
    }
  }
  
  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving preference $key: $e');
    }
  }

  Future<void> _saveTimePreference(String key, TimeOfDay time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, time.hour);
    } catch (e) {
      debugPrint('Error saving time preference $key: $e');
    }
  }

  Future<void> _handleMasterToggle(bool enabled) async {
    if (enabled && !_notificationsEnabled) {
      final granted = await NotificationPermissionService.handleInitialPermissionFlow(context);
      if (!mounted) return;

      setState(() {
        _notificationsEnabled = granted;
      });

      if (granted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Notifications enabled successfully',
        );
      }
    } else if (!enabled) {
      final confirmed = await _showDisableConfirmationDialog();
      if (!mounted) return;

      if (confirmed) {
        setState(() {
          _notificationsEnabled = false;
        });
        JJSnackBar.showInfo(
          context: context,
          message: 'Notifications disabled. You can re-enable them anytime.',
        );
      }
    }
  }

  Future<bool> _showDisableConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_off,
              color: AppTheme.warningYellow,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              'Disable Notifications?',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        content: Text(
          'You\'ll miss important job alerts and union updates. Are you sure?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          JJPrimaryButton(
            text: 'Disable',
            onPressed: () => Navigator.of(context).pop(true),
            width: 100,
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _selectQuietHoursTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.accentCopper,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });

      await _saveTimePreference(
        isStart ? 'quiet_hours_start' : 'quiet_hours_end',
        picked,
      );
    }
  }

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
      case 'storm':
        return Icons.flash_on;
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
      case 'storm':
        return AppTheme.warningYellow;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _handleNotificationTap(String type, Map<String, dynamic> data) {
    // Navigate based on notification type
    switch (type) {
      case 'jobs':
        // Navigate to jobs screen, optionally with specific job ID
        final jobId = data['jobId'] as String?;
        if (jobId != null) {
          context.go('${AppRouter.jobs}/$jobId');
        } else {
          context.go(AppRouter.jobs);
        }
        break;
      case 'storm':
        // Navigate to storm screen
        context.go(AppRouter.storm);
        break;
      case 'applications':
        // Navigate to applications/applied section
        // This might be in the profile or a dedicated screen
        context.go(AppRouter.profile);
        break;
      case 'union':
      case 'union_updates':
      case 'union_reminders':
        // Navigate to unions/locals screen
        final localNumber = data['localNumber'] as String?;
        if (localNumber != null) {
          context.go('${AppRouter.locals}/$localNumber');
        } else {
          context.go(AppRouter.locals);
        }
        break;
      case 'safety':
        // Safety notifications might go to a safety resources screen
        // For now, stay on notifications
        break;
      case 'system':
      default:
        // System notifications stay on the notifications screen
        break;
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCopper,
          indicatorWeight: 3,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(
              icon: Icon(Icons.notifications_outlined),
              text: 'Notifications',
            ),
            Tab(
              icon: Icon(Icons.settings_outlined),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Notifications Tab
          Column(
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
              // Mark all as read button
              Container(
                color: AppTheme.white,
                padding: const EdgeInsets.only(
                  left: AppTheme.spacingMd,
                  right: AppTheme.spacingMd,
                  bottom: AppTheme.spacingMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(
                        Icons.mark_email_read,
                        size: AppTheme.iconSm,
                      ),
                      label: const Text('Mark all as read'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentCopper,
                      ),
                    ),
                  ],
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
          // Settings Tab
          _isLoadingSettings
              ? Center(
                  child: JJElectricalLoader(
                    message: 'Loading settings...',
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Master toggle
                      _buildMasterToggleSection(),
                      const SizedBox(height: AppTheme.spacingLg),

                      // Notification categories
                      if (_notificationsEnabled) ...[
                        _buildNotificationCategoriesSection(),
                        const SizedBox(height: AppTheme.spacingLg),

                        // Sound and vibration
                        _buildSoundSection(),
                        const SizedBox(height: AppTheme.spacingLg),

                        // Quiet hours
                        _buildQuietHoursSection(),
                      ],
                    ],
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
    final notificationData = data['data'] as Map<String, dynamic>? ?? {};
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: JJCard(
        backgroundColor: isRead ? AppTheme.white : AppTheme.accentCopper.withValues(alpha: 0.05),
        onTap: () {
          _markAsRead(notificationId);
          _handleNotificationTap(type, notificationData);
        },
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

  Widget _buildMasterToggleSection() {
    return JJCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: _notificationsEnabled 
                      ? AppTheme.successGreen.withValues(alpha: 0.1)
                      : AppTheme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  _notificationsEnabled 
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _notificationsEnabled 
                      ? AppTheme.successGreen
                      : AppTheme.textSecondary,
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      _notificationsEnabled
                          ? 'Get instant job alerts and union updates'
                          : 'Enable to receive important notifications',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              JJCircuitBreakerSwitch(
                value: _notificationsEnabled,
                onChanged: _handleMasterToggle,
                size: JJCircuitBreakerSize.small,
                showElectricalEffects: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCategoriesSection() {
    return _buildSection(
      'Notification Types',
      [
        _buildToggleItem(
          icon: Icons.work_outline,
          title: 'Job Alerts',
          subtitle: 'New job postings matching your preferences',
          value: _jobAlertsEnabled,
          onChanged: (value) {
            setState(() => _jobAlertsEnabled = value);
            _savePreference('job_alerts_enabled', value);
            if (value) {
              FCMService.subscribeToTopic('job_alerts');
            } else {
              FCMService.unsubscribeFromTopic('job_alerts');
            }
          },
        ),
        _buildToggleItem(
          icon: Icons.flash_on,
          title: 'Storm Work',
          subtitle: 'Emergency and storm restoration opportunities',
          value: _stormWorkEnabled,
          onChanged: (value) {
            setState(() => _stormWorkEnabled = value);
            _savePreference('storm_work_enabled', value);
            if (value) {
              FCMService.subscribeToTopic('storm_alerts');
            } else {
              FCMService.unsubscribeFromTopic('storm_alerts');
            }
          },
        ),
        _buildToggleItem(
          icon: Icons.people_outline,
          title: 'Union Updates',
          subtitle: 'News and updates from your local',
          value: _unionUpdatesEnabled,
          onChanged: (value) {
            setState(() => _unionUpdatesEnabled = value);
            _savePreference('union_updates_enabled', value);
            if (value) {
              FCMService.subscribeToTopic('union_updates');
            } else {
              FCMService.unsubscribeFromTopic('union_updates');
            }
          },
        ),
        _buildToggleItem(
          icon: Icons.event,
          title: 'Union Meeting Reminders',
          subtitle: 'Remind me about upcoming union meetings',
          value: _unionRemindersEnabled,
          onChanged: (value) {
            setState(() => _unionRemindersEnabled = value);
            _savePreference('union_reminders_enabled', value);
            if (value) {
              FCMService.subscribeToTopic('union_reminders');
            } else {
              FCMService.unsubscribeFromTopic('union_reminders');
            }
          },
        ),
        _buildToggleItem(
          icon: Icons.info_outline,
          title: 'System Notifications',
          subtitle: 'App updates and important announcements',
          value: _systemNotificationsEnabled,
          onChanged: (value) {
            setState(() => _systemNotificationsEnabled = value);
            _savePreference('system_notifications_enabled', value);
            if (value) {
              FCMService.subscribeToTopic('system_updates');
            } else {
              FCMService.unsubscribeFromTopic('system_updates');
            }
          },
        ),
      ],
    );
  }

  Widget _buildSoundSection() {
    return _buildSection(
      'Sound & Vibration',
      [
        _buildToggleItem(
          icon: Icons.volume_up,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() => _soundEnabled = value);
            _savePreference('sound_enabled', value);
          },
        ),
        _buildToggleItem(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() => _vibrationEnabled = value);
            _savePreference('vibration_enabled', value);
          },
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection() {
    return _buildSection(
      'Quiet Hours',
      [
        _buildToggleItem(
          icon: Icons.bedtime,
          title: 'Enable Quiet Hours',
          subtitle: 'Silence notifications during specified times',
          value: _quietHoursEnabled,
          onChanged: (value) {
            setState(() => _quietHoursEnabled = value);
            _savePreference('quiet_hours_enabled', value);
          },
        ),
        if (_quietHoursEnabled) ...[
          const Divider(height: 1),
          _buildTimePickerItem(
            icon: Icons.bedtime,
            title: 'Start Time',
            time: _quietHoursStart,
            onTap: () => _selectQuietHoursTime(true),
          ),
          const Divider(height: 1),
          _buildTimePickerItem(
            icon: Icons.wb_sunny,
            title: 'End Time',
            time: _quietHoursEnd,
            onTap: () => _selectQuietHoursTime(false),
          ),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingSm),
          child: Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        JJCard(
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;
              
              return Column(
                children: [
                  child,
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentCopper,
              size: AppTheme.iconSm,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          JJCircuitBreakerSwitch(
            value: value,
            onChanged: onChanged,
            size: JJCircuitBreakerSize.small,
            showElectricalEffects: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerItem({
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryNavy,
                  size: AppTheme.iconSm,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
              Text(
                time.format(context),
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textLight,
                size: AppTheme.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
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