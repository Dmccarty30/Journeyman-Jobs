import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/safety_incident.dart';
import '../../models/safety_reminder.dart';
import '../../navigation/app_router.dart';
import 'incident_report_screen.dart';

class ElectricalSafetyDashboard extends StatefulWidget {
  const ElectricalSafetyDashboard({super.key});

  @override
  State<ElectricalSafetyDashboard> createState() => _ElectricalSafetyDashboardState();
}

class _ElectricalSafetyDashboardState extends State<ElectricalSafetyDashboard> {
  final int _safetyDaysCount = 127; // This would come from a data source
  late SafetyReminder _todaysReminder;
  final List<SafetyIncident> _recentIncidents = []; // Mock data for now

  // Safety statistics - would come from database in real app
  final Map<String, int> _safetyStats = {
    'totalIncidents': 23,
    'resolvedIncidents': 18,
    'pendingIncidents': 5,
    'nearMisses': 12,
    'arcFlashIncidents': 2,
    'electricalShocks': 1,
    'equipmentFailures': 8,
  };

  @override
  void initState() {
    super.initState();
    _todaysReminder = ElectricalSafetyReminders.getDailyReminder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                size: 20,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Safety Dashboard',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.white),
            onPressed: () {
              _showSafetyAlerts();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safety Status Header
            _buildSafetyStatusCard(),
            
            const SizedBox(height: AppTheme.spacingLg),

            // Daily Safety Reminder
            _buildDailySafetyReminder(),
            
            const SizedBox(height: AppTheme.spacingLg),

            // Safety Statistics
            Text(
              'Safety Statistics',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildSafetyStatsGrid(),
            
            const SizedBox(height: AppTheme.spacingLg),

            // Quick Actions
            Text(
              'Safety Actions',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildQuickActionsGrid(),
            
            const SizedBox(height: AppTheme.spacingLg),

            // Recent Safety Reminders
            _buildRecentReminders(),
            
            const SizedBox(height: AppTheme.spacingXxl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncidentReportScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.errorRed,
        foregroundColor: AppTheme.white,
        icon: const Icon(Icons.report_problem),
        label: const Text('Report Incident'),
      ),
    );
  }

  Widget _buildSafetyStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.successGreen,
            AppTheme.successGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppTheme.white,
                size: AppTheme.iconLg,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Safety Status: GOOD',
                style: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            '$_safetyDaysCount Days',
            style: AppTheme.displaySmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Since last electrical incident',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppTheme.white,
                  size: AppTheme.iconSm,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Keep up the excellent safety record!',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySafetyReminder() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowSm],
        border: Border(
          left: BorderSide(
            width: 4,
            color: _getReminderPriorityColor(_todaysReminder.priority),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: _getReminderPriorityColor(_todaysReminder.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  _getReminderIcon(_todaysReminder.category),
                  color: _getReminderPriorityColor(_todaysReminder.priority),
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Safety Reminder',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _todaysReminder.title,
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: _getReminderPriorityColor(_todaysReminder.priority),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  _todaysReminder.priority.displayName.toUpperCase(),
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            _todaysReminder.message,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          if (_todaysReminder.source != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Source: ${_todaysReminder.source}',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSafetyStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.spacingMd,
      mainAxisSpacing: AppTheme.spacingMd,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Incidents',
          _safetyStats['totalIncidents'].toString(),
          Icons.warning_outlined,
          AppTheme.infoBlue,
        ),
        _buildStatCard(
          'Resolved',
          _safetyStats['resolvedIncidents'].toString(),
          Icons.check_circle_outlined,
          AppTheme.successGreen,
        ),
        _buildStatCard(
          'Pending',
          _safetyStats['pendingIncidents'].toString(),
          Icons.pending_outlined,
          AppTheme.warningYellow,
        ),
        _buildStatCard(
          'Near Misses',
          _safetyStats['nearMisses'].toString(),
          Icons.near_me_outlined,
          AppTheme.accentCopper,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppTheme.iconMd),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.spacingMd,
      mainAxisSpacing: AppTheme.spacingMd,
      childAspectRatio: 1.0,
      children: [
        _buildActionCard(
          'Report Incident',
          Icons.report_problem,
          AppTheme.errorRed,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncidentReportScreen(),
            ),
          ),
        ),
        _buildActionCard(
          'Safety Check-in',
          Icons.security_outlined,
          AppTheme.successGreen,
          () => _showSafetyCheckin(),
        ),
        _buildActionCard(
          'PPE Inspection',
          Icons.shield_outlined,
          AppTheme.infoBlue,
          () => _showPPEInspection(),
        ),
        _buildActionCard(
          'Emergency Contacts',
          Icons.emergency_outlined,
          AppTheme.warningYellow,
          () => _showEmergencyContacts(),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return JJCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.white,
              size: AppTheme.iconLg,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReminders() {
    final recentReminders = ElectricalSafetyReminders.getAllActiveReminders().take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Safety Reminders',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            TextButton(
              onPressed: () => _showAllReminders(),
              child: Text(
                'View All',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.accentCopper,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ...recentReminders.map((reminder) => _buildReminderListItem(reminder)).toList(),
      ],
    );
  }

  Widget _buildReminderListItem(SafetyReminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border(
          left: BorderSide(
            width: 3,
            color: _getReminderPriorityColor(reminder.priority),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: _getReminderPriorityColor(reminder.priority).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              _getReminderIcon(reminder.category),
              color: _getReminderPriorityColor(reminder.priority),
              size: AppTheme.iconSm,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  reminder.category.displayName,
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _getReminderPriorityColor(reminder.priority).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              reminder.priority.displayName,
              style: AppTheme.labelSmall.copyWith(
                color: _getReminderPriorityColor(reminder.priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getReminderPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return AppTheme.successGreen;
      case ReminderPriority.medium:
        return AppTheme.infoBlue;
      case ReminderPriority.high:
        return AppTheme.warningYellow;
      case ReminderPriority.urgent:
        return AppTheme.errorRed;
    }
  }

  IconData _getReminderIcon(SafetyCategory category) {
    switch (category) {
      case SafetyCategory.electrical:
        return Icons.electrical_services;
      case SafetyCategory.ppe:
        return Icons.shield;
      case SafetyCategory.lockout:
        return Icons.lock;
      case SafetyCategory.arcFlash:
        return Icons.flash_on;
      case SafetyCategory.emergency:
        return Icons.emergency;
      case SafetyCategory.tools:
        return Icons.build;
      case SafetyCategory.environment:
        return Icons.eco;
      case SafetyCategory.general:
        return Icons.security;
    }
  }

  void _showSafetyAlerts() {
    JJBottomSheet.show(
      context: context,
      title: 'Safety Alerts',
      child: Column(
        children: [
          if (_safetyStats['pendingIncidents']! > 0)
            ListTile(
              leading: const Icon(Icons.warning, color: AppTheme.warningYellow),
              title: Text('${_safetyStats['pendingIncidents']} Pending Incidents'),
              subtitle: const Text('Require immediate attention'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          const ListTile(
            leading: Icon(Icons.schedule, color: AppTheme.infoBlue),
            title: Text('Daily Safety Meeting'),
            subtitle: Text('Tomorrow at 7:00 AM'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  void _showAllReminders() {
    JJBottomSheet.show(
      context: context,
      title: 'All Safety Reminders',
      child: Column(
        children: ElectricalSafetyReminders.getAllActiveReminders()
            .map((reminder) => _buildReminderListItem(reminder))
            .toList(),
      ),
    );
  }

  void _showSafetyCheckin() {
    JJBottomSheet.show(
      context: context,
      title: 'Safety Check-in',
      child: Column(
        children: [
          Text(
            'Complete your daily safety check-in:',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          CheckboxListTile(
            title: const Text('PPE inspected and worn'),
            value: false,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: const Text('Work area assessed for hazards'),
            value: false,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: const Text('Emergency procedures reviewed'),
            value: false,
            onChanged: (value) {},
          ),
          const SizedBox(height: AppTheme.spacingLg),
          JJPrimaryButton(
            text: 'Complete Check-in',
            onPressed: () {
              Navigator.pop(context);
              JJSnackBar.showSuccess(
                context: context,
                message: 'Safety check-in completed successfully!',
              );
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showPPEInspection() {
    JJBottomSheet.show(
      context: context,
      title: 'PPE Inspection',
      child: Column(
        children: [
          Text(
            'Inspect the following PPE items before starting work:',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const ListTile(
            leading: Icon(Icons.visibility, color: AppTheme.infoBlue),
            title: Text('Safety Glasses'),
            subtitle: Text('Check for cracks, scratches, or damage'),
          ),
          const ListTile(
            leading: Icon(Icons.construction, color: AppTheme.warningYellow),
            title: Text('Hard Hat'),
            subtitle: Text('Inspect shell and suspension system'),
          ),
          const ListTile(
            leading: Icon(Icons.shield, color: AppTheme.errorRed),
            title: Text('Arc-rated Clothing'),
            subtitle: Text('Check for tears, burns, or contamination'),
          ),
          const ListTile(
            leading: Icon(Icons.pan_tool, color: AppTheme.successGreen),
            title: Text('Insulated Gloves'),
            subtitle: Text('Look for punctures or degradation'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContacts() {
    JJBottomSheet.show(
      context: context,
      title: 'Emergency Contacts',
      child: const Column(
        children: [
          ListTile(
            leading: Icon(Icons.local_hospital, color: AppTheme.errorRed),
            title: Text('Emergency Services'),
            subtitle: Text('911'),
          ),
          ListTile(
            leading: Icon(Icons.security, color: AppTheme.infoBlue),
            title: Text('Site Security'),
            subtitle: Text('(555) 123-4567'),
          ),
          ListTile(
            leading: Icon(Icons.business, color: AppTheme.primaryNavy),
            title: Text('Safety Manager'),
            subtitle: Text('John Smith - (555) 987-6543'),
          ),
          ListTile(
            leading: Icon(Icons.electrical_services, color: AppTheme.warningYellow),
            title: Text('Electrical Emergency'),
            subtitle: Text('(555) 111-2222'),
          ),
        ],
      ),
    );
  }
}
