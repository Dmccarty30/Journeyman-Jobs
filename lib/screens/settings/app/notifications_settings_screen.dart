import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../services/notification_permission_service.dart';
import '../../../navigation/app_router.dart';

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
    'crews',
  ];

  final Map<String, String> _filterLabels = {
    'all': 'All',
    'jobs': 'Job Alerts',
    'safety': 'Safety',
    'system': 'System',
    'applications': 'Applications',
    'storm': 'Storm Work',
    'crews': 'Crews',
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
            variant: JJButtonVariant.danger,
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
      case 'crews':
        return Icons.group;
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
      case 'crews':
        return AppTheme.accentCopper;
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
      case 'crews':
        // Navigate to crews screen
        final crewId = data['crewId'] as String?;
        if (crewId != null) {
          context.go('${AppRouter.crews}/$crewId');
        } else {
          context.go(AppRouter.crews);
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

  Stream<QuerySnapshot> _buildNotificationsStream(String userId) {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (_selectedFilter != 'all') {
      query = query.where('type', isEqualTo: _selectedFilter);
    }

    return query.snapshots();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            message,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot notification) {
    final data = notification.data() as Map<String, dynamic>;
    final type = data['type'] as String? ?? 'system';
    final title = data['title'] as String? ?? 'Notification';
    final body = data['body'] as String? ?? '';
    final isRead = data['isRead'] as bool? ?? false;
    final createdAt = data['createdAt'] as Timestamp?;
    final notificationData = data['data'] as Map<String, dynamic>? ?? {};

    final timeAgo = createdAt != null
        ? _formatTimeAgo(createdAt.toDate())
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _markAsRead(notification.id);
          _handleNotificationTap(type, notificationData);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  _getNotificationIcon(type),
                  color: _getNotificationColor(type),
                  size: AppTheme.iconSm,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              color: isRead ? AppTheme.textSecondary : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (timeAgo.isNotEmpty)
                          Text(
                            timeAgo,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        body,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Unread indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent, // Changed to transparent
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
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
      body: Stack(
        children: [
          ElectricalCircuitBackground( // Added background
            opacity: 0.35,
            componentDensity: ComponentDensity.high,
          ),
          TabBarView(
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
                              return _buildNotificationCard(notification);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          // Settings Tab
          _isLoadingSettings
              ? const Center(
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
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          side: BorderSide(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notifications',
                                      style: AppTheme.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingXs),
                                    Text(
                                      'Enable or disable all notifications',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _notificationsEnabled,
                                onChanged: _handleMasterToggle,
                                activeThumbColor: AppTheme.accentCopper,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      // Notification types
                      Text(
                        'Notification Types',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          side: BorderSide(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSettingsRow(
                              'Job Alerts',
                              'Get notified about new job opportunities',
                              _jobAlertsEnabled,
                              (value) {
                                setState(() {
                                  _jobAlertsEnabled = value;
                                });
                                _savePreference('job_alerts_enabled', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              'Union Updates',
                              'Important updates from your union',
                              _unionUpdatesEnabled,
                              (value) {
                                setState(() {
                                  _unionUpdatesEnabled = value;
                                });
                                _savePreference('union_updates_enabled', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              'System Notifications',
                              'App updates and system messages',
                              _systemNotificationsEnabled,
                              (value) {
                                setState(() {
                                  _systemNotificationsEnabled = value;
                                });
                                _savePreference('system_notifications_enabled', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              'Storm Work',
                              'Emergency storm work opportunities',
                              _stormWorkEnabled,
                              (value) {
                                setState(() {
                                  _stormWorkEnabled = value;
                                });
                                _savePreference('storm_work_enabled', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              'Union Reminders',
                              'Reminders for union events and deadlines',
                              _unionRemindersEnabled,
                              (value) {
                                setState(() {
                                  _unionRemindersEnabled = value;
                                });
                                _savePreference('union_reminders_enabled', value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      // Sound & Vibration
                      Text(
                        'Sound & Vibration',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          side: BorderSide(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSettingsRow(
                              'Sound',
                              'Play sound for notifications',
                              _soundEnabled,
                              (value) {
                                setState(() {
                                  _soundEnabled = value;
                                });
                                _savePreference('sound_enabled', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              'Vibration',
                              'Vibrate for notifications',
                              _vibrationEnabled,
                              (value) {
                                setState(() {
                                  _vibrationEnabled = value;
                                });
                                _savePreference('vibration_enabled', value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      // Quiet Hours
                      Text(
                        'Quiet Hours',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          side: BorderSide(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSettingsRow(
                              'Quiet Hours',
                              'Silence notifications during specified hours',
                              _quietHoursEnabled,
                              (value) {
                                setState(() {
                                  _quietHoursEnabled = value;
                                });
                                _savePreference('quiet_hours_enabled', value);
                              },
                            ),
                            if (_quietHoursEnabled) ...[
                              _buildDivider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingMd,
                                  vertical: AppTheme.spacingSm,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => _selectQuietHoursTime(true),
                                        child: Text(
                                          'Start: ${_quietHoursStart.format(context)}',
                                          style: AppTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'to',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => _selectQuietHoursTime(false),
                                        child: Text(
                                          'End: ${_quietHoursEnd.format(context)}',
                                          style: AppTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentCopper,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.borderLight,
      indent: AppTheme.spacingMd,
      endIndent: AppTheme.spacingMd,
    );
  }
}
