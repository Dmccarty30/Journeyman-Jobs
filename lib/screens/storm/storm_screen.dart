import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/power_grid_status.dart';
// import '../../../electrical_components/electrical_components.dart'; // Temporarily disabled

class StormScreen extends StatefulWidget {
  const StormScreen({super.key});

  @override
  State<StormScreen> createState() => _StormScreenState();
}

class _StormScreenState extends State<StormScreen> {

  final List<PowerGridStatus> _powerGridStatuses = PowerGridMockData.generateMockData();

  List<Widget> _buildPowerGridStatusCards() {
    return _powerGridStatuses.map((status) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [AppTheme.shadowSm],
        ),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.power,
                    color: status.stateColor, size: 30),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  status.gridName,
                  style: AppTheme.headlineSmall
                      .copyWith(color: AppTheme.primaryNavy),
                ),
                const Spacer(),
                Text(
                  status.stateLabel,
                  style: AppTheme.bodySmall
                      .copyWith(color: status.stateColor),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Load: ${status.loadPercentage}%, Affected Customers: ${status.affectedCustomers}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Voltage Level: ${status.voltageLevel.label}',
              style: AppTheme.bodySmall.copyWith(
                color: status.voltageLevel.color,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: AppTheme.spacingSm,
              children: status.activeHazards.map((hazard) {
                return Chip(
                  backgroundColor: hazard.severityColor,
                  avatar: Icon(
                    hazard.hazardIcon,
                    size: 16,
                    color: AppTheme.white
                  ),
                  label: Text(
                    hazard.type.toString().split('.').last,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }).toList();
  }
  bool _notificationsEnabled = false;
  String _selectedRegion = 'All Regions';
  
  final List<String> _regions = [
    'All Regions',
    'Southeast',
    'Gulf Coast',
    'Midwest',
    'Northeast',
    'West Coast',
    'Texas',
    'Florida',
  ];

  final List<StormEvent> _activeStorms = [
    StormEvent(
      id: '1',
      name: 'Hurricane Milton Aftermath',
      region: 'Florida',
      severity: 'Critical',
      affectedUtilities: ['Duke Energy', 'FPL', 'Tampa Electric'],
      estimatedDuration: '14-21 days',
      openPositions: 156,
      payRate: '\$65-85/hr',
      perDiem: '\$125/day',
      status: 'Active Restoration',
      description: 'Major power restoration effort following Category 4 hurricane impact. Multiple transmission lines down, extensive distribution damage.',
      deploymentDate: DateTime.now().add(const Duration(days: 1)),
    ),
    StormEvent(
      id: '2',
      name: 'Texas Ice Storm Recovery',
      region: 'Texas',
      severity: 'High',
      affectedUtilities: ['Oncor', 'CenterPoint Energy', 'AEP Texas'],
      estimatedDuration: '7-10 days',
      openPositions: 89,
      payRate: '\$58-72/hr',
      perDiem: '\$110/day',
      status: 'Mobilizing',
      description: 'Ice accumulation caused widespread outages across central Texas. Tree clearing and line repair needed.',
      deploymentDate: DateTime.now().add(const Duration(hours: 18)),
    ),
    StormEvent(
      id: '3',
      name: 'Derecho Damage - Illinois',
      region: 'Midwest',
      severity: 'Moderate',
      affectedUtilities: ['ComEd', 'Ameren Illinois'],
      estimatedDuration: '5-7 days',
      openPositions: 34,
      payRate: '\$54-68/hr',
      perDiem: '\$95/day',
      status: 'Final Phase',
      description: 'Straight-line wind damage to distribution system. Most transmission restored.',
      deploymentDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<StormEvent> get _filteredStorms {
    if (_selectedRegion == 'All Regions') {
      return _activeStorms;
    }
    return _activeStorms.where((storm) => storm.region == _selectedRegion).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.warningYellow,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.flash_on,
              color: AppTheme.white,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Storm Work',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _notificationsEnabled ? Icons.notifications_active : Icons.notifications_outlined,
              color: AppTheme.white,
            ),
            onPressed: () {
              setState(() {
                _notificationsEnabled = !_notificationsEnabled;
              });
              JJSnackBar.showSuccess(
                context: context,
                message: _notificationsEnabled 
                  ? 'Storm work notifications enabled'
                  : 'Storm work notifications disabled',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency alert banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.warningYellow, AppTheme.errorRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                        Icons.warning,
                        color: AppTheme.white,
                        size: AppTheme.iconLg,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          'EMERGENCY WORK AVAILABLE',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Storm restoration work is currently available. These are high-priority assignments with enhanced compensation and rapid deployment.',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Storm work stats
            Text(
              'Current Storm Activity',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            Row(
              children: [
                Expanded(
                  child: _buildStormStatCard(
                    'Active Storms',
                    '${_activeStorms.length}',
                    Icons.storm_outlined,
                    AppTheme.errorRed,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildStormStatCard(
                    'Open Positions',
                    '${_activeStorms.fold(0, (sum, storm) => sum + storm.openPositions)}',
                    Icons.flash_on_outlined,
                    AppTheme.warningYellow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            Row(
              children: [
                Expanded(
                  child: _buildStormStatCard(
                    'Avg Pay Rate',
                    '\$65/hr',
                    Icons.attach_money,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildStormStatCard(
                    'Avg Per Diem',
                    '\$110/day',
                    Icons.hotel,
                    AppTheme.accentCopper,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Region filter
            Row(
              children: [
                Text(
                  'Filter by Region:',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.lightGray),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRegion,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _regions.map((region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Storm events list
            Text(
              'Emergency Assignments',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            if (_filteredStorms.isEmpty)
              JJEmptyState(
                title: 'No Active Storms',
                subtitle: 'No storm restoration work available in the selected region.',
                icon: Icons.wb_sunny,
              )
            else
              ..._filteredStorms.map((storm) => StormEventCard(storm: storm)),

            const SizedBox(height: AppTheme.spacingLg),

            // Safety information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.safety_check,
                        color: AppTheme.infoBlue,
                        size: AppTheme.iconMd,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Storm Work Safety Reminder',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.infoBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    '• Always follow proper safety protocols and use appropriate PPE\n'
                    '• Be aware of hazardous conditions including downed lines and debris\n'
                    '• Maintain situational awareness in emergency work environments\n'
                    '• Report unsafe conditions immediately to supervisors',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStormStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: color, size: AppTheme.iconMd),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class StormEvent {
  final String id;
  final String name;
  final String region;
  final String severity;
  final List<String> affectedUtilities;
  final String estimatedDuration;
  final int openPositions;
  final String payRate;
  final String perDiem;
  final String status;
  final String description;
  final DateTime deploymentDate;

  StormEvent({
    required this.id,
    required this.name,
    required this.region,
    required this.severity,
    required this.affectedUtilities,
    required this.estimatedDuration,
    required this.openPositions,
    required this.payRate,
    required this.perDiem,
    required this.status,
    required this.description,
    required this.deploymentDate,
  });
}

class StormEventCard extends StatelessWidget {
  final StormEvent storm;

  const StormEventCard({super.key, required this.storm});

  Color get _severityColor {
    switch (storm.severity.toLowerCase()) {
      case 'critical':
        return AppTheme.errorRed;
      case 'high':
        return AppTheme.warningYellow;
      case 'moderate':
        return AppTheme.accentCopper;
      default:
        return AppTheme.infoBlue;
    }
  }

  String get _timeUntilDeployment {
    final now = DateTime.now();
    final difference = storm.deploymentDate.difference(now);
    
    if (difference.isNegative) {
      final days = difference.abs().inDays;
      return 'Started ${days}d ago';
    } else if (difference.inHours < 24) {
      return 'Deploying in ${difference.inHours}h';
    } else {
      return 'Deploying in ${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border.all(color: _severityColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () {
            _showStormDetails(context, storm);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _severityColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                            ),
                            child: Text(
                              storm.severity.toUpperCase(),
                              style: AppTheme.labelSmall.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            storm.name,
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            storm.region,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.accentCopper,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${storm.openPositions} positions',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _timeUntilDeployment,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Status and duration
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        storm.status,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      storm.estimatedDuration,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Description
                Text(
                  storm.description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Pay information
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        storm.payRate,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCopper.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        'Per diem ${storm.perDiem}',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.accentCopper,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStormDetails(BuildContext context, StormEvent storm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return StormDetailsSheet(storm: storm, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class StormDetailsSheet extends StatelessWidget {
  final StormEvent storm;
  final ScrollController scrollController;

  const StormDetailsSheet({
    super.key,
    required this.storm,
    required this.scrollController,
  });

  Color get _severityColor {
    switch (storm.severity.toLowerCase()) {
      case 'critical':
        return AppTheme.errorRed;
      case 'high':
        return AppTheme.warningYellow;
      case 'moderate':
        return AppTheme.accentCopper;
      default:
        return AppTheme.infoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: _severityColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                        ),
                        child: Text(
                          '${storm.severity.toUpperCase()} PRIORITY',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        storm.name,
                        style: AppTheme.displaySmall.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        storm.region,
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.accentCopper,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Key metrics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open Positions',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                        Text(
                          '${storm.openPositions}',
                          style: AppTheme.headlineLarge.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          storm.estimatedDuration,
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Pay information
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay Rate',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                        Text(
                          storm.payRate,
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Per Diem',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.accentCopper,
                          ),
                        ),
                        Text(
                          storm.perDiem,
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.accentCopper,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Description
            Text(
              'Storm Details',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              storm.description,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Affected utilities
            Text(
              'Affected Utilities',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: storm.affectedUtilities.map((utility) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    utility,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Action buttons
            JJPrimaryButton(
              text: 'Express Interest',
              icon: Icons.flash_on,
              onPressed: () {
                Navigator.pop(context);
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Interest submitted! You will be contacted with deployment details.',
                );
              },
              isFullWidth: true,
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            JJSecondaryButton(
              text: 'Get Alerts for Similar Events',
              icon: Icons.notifications_active,
              onPressed: () {
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Alert preferences updated',
                );
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}