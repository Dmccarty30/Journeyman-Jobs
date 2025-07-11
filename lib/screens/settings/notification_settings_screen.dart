import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../services/notification_permission_service.dart';
import '../../services/fcm_service.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  
  // Permission status
  bool _notificationsEnabled = false;
  
  // Notification categories
  bool _jobAlertsEnabled = true;
  bool _unionUpdatesEnabled = true;
  bool _systemNotificationsEnabled = true;
  bool _stormWorkEnabled = true;
  
  // Reminder settings
  bool _unionRemindersEnabled = true;
  
  // Sound and vibration
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Check permission status
      _notificationsEnabled = await NotificationPermissionService.areNotificationsEnabled();
      
      // Load preferences
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Notification categories
        _jobAlertsEnabled = prefs.getBool('job_alerts_enabled') ?? true;
        _unionUpdatesEnabled = prefs.getBool('union_updates_enabled') ?? true;
        _systemNotificationsEnabled = prefs.getBool('system_notifications_enabled') ?? true;
        _stormWorkEnabled = prefs.getBool('storm_work_enabled') ?? true;
        
        // Reminder settings
        _unionRemindersEnabled = prefs.getBool('union_reminders_enabled') ?? true;
        
        // Sound and vibration
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
        
        // Quiet hours
        _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
        final startHour = prefs.getInt('quiet_hours_start') ?? 22;
        final endHour = prefs.getInt('quiet_hours_end') ?? 7;
        _quietHoursStart = TimeOfDay(hour: startHour, minute: 0);
        _quietHoursEnd = TimeOfDay(hour: endHour, minute: 0);
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
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
      // Request permissions
      final granted = await NotificationPermissionService.handleInitialPermissionFlow(context);
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
      // Show confirmation dialog
      final confirmed = await _showDisableConfirmationDialog();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: Text(
            'Notification Settings',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.primaryNavy,
          iconTheme: const IconThemeData(color: AppTheme.white),
        ),
        body: Center(
          child: JJElectricalLoader(
            message: 'Loading settings...',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: SingleChildScrollView(
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
    );
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