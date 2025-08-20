import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/storm_event.dart';
import '../../widgets/weather/noaa_radar_map.dart';
import '../../services/location_service.dart';
import '../../services/power_outage_service.dart';
import '../../widgets/storm/power_outage_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/notification_badge.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/app_router.dart';
// import '../../models/power_grid_status.dart'; // TODO: Uncomment when power grid status is implemented
// import '../../../electrical_components/electrical_components.dart'; // Temporarily disabled

class StormScreen extends StatefulWidget {
  const StormScreen({super.key});

  @override
  State<StormScreen> createState() => _StormScreenState();
}

class _StormScreenState extends State<StormScreen> {

  // TODO: Use when power grid status cards are implemented
  // final List<PowerGridStatus> _powerGridStatuses = PowerGridMockData.getSampleData();

  // TODO: Implement power grid status cards when needed
  /*List<Widget> _buildPowerGridStatusCards() {
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
              'Load: ${status.loadPercentage.toStringAsFixed(1)}%, Affected Customers: ${status.affectedCustomers}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Voltage Level: ${status.voltageLevel.toStringAsFixed(1)} kV',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            if (status.activeHazards.isNotEmpty)
              Wrap(
                spacing: AppTheme.spacingSm,
                children: status.activeHazards.map((hazard) {
                  return Chip(
                    backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                    label: Text(
                      hazard,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentCopper,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    }).toList();
  }*/
  bool _notificationsEnabled = false;
  String _selectedRegion = 'All Regions';
  
  // Power outage tracking
  final PowerOutageService _powerOutageService = PowerOutageService();
  List<PowerOutageState> _powerOutages = [];
  bool _isLoadingOutages = true;
  
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
  void initState() {
    super.initState();
    _loadPowerOutages();
  }

  @override
  void dispose() {
    _powerOutageService.dispose();
    super.dispose();
  }

  Future<void> _loadPowerOutages() async {
    try {
      await _powerOutageService.initialize();
      final outages = await _powerOutageService.getPowerOutages();
      if (mounted) {
        setState(() {
          _powerOutages = outages;
          _isLoadingOutages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOutages = false;
        });
      }
    }
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
          NotificationBadge(
            iconColor: AppTheme.white,
            showPopupOnTap: false,
            onTap: () {
              context.push(AppRouter.notifications);
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
                  const SizedBox(height: AppTheme.spacingMd),
                  JJPrimaryButton(
                    text: 'View Live Weather Radar',
                    icon: FontAwesomeIcons.cloudBolt,
                    onPressed: () => _showWeatherRadar(context),
                    isFullWidth: false,
                    variant: JJButtonVariant.primary,
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

            // Power outage section
            if (_powerOutages.isNotEmpty) ...[
              PowerOutageSummary(outages: _powerOutages),
              const SizedBox(height: AppTheme.spacingLg),
              
              Text(
                'Major Power Outages by State',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              if (_isLoadingOutages)
                Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentCopper,
                  ),
                )
              else
                ..._powerOutages.map((outage) => PowerOutageCard(
                  outageData: outage,
                  onTap: () => _showOutageDetails(context, outage),
                )),
              
              const SizedBox(height: AppTheme.spacingLg),
            ],

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
                context: 'jobs', // Uses electrical illustration instead of sun icon
              )
            else
              ..._filteredStorms.map((storm) => StormEventCard(storm: storm)),

            const SizedBox(height: AppTheme.spacingLg),

            // Safety information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.3)),
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

  void _showWeatherRadar(BuildContext context) async {
    // Check location permission first
    final locationService = LocationService();
    final permissionResult = await locationService.requestLocationForRadar();
    
    if (!context.mounted) return;
    
    // Show permission status if needed
    if (!permissionResult['permitted']) {
      final canRetry = permissionResult['canRetry'] ?? false;
      final status = permissionResult['status'];
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.locationCrosshairs,
                color: AppTheme.warningYellow,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text('Location Permission Needed'),
            ],
          ),
          content: Text(
            permissionResult['message'] ?? 'Location permission is required to center the radar on your location.',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            if (status == 'deniedForever')
              TextButton(
                onPressed: () async {
                  await locationService.openAppSettings();
                  Navigator.pop(context);
                },
                child: Text('Open Settings'),
              ),
            if (canRetry)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showWeatherRadar(context); // Retry
                },
                child: Text('Retry'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showRadarWithoutLocation(context);
              },
              child: Text('Continue Without Location'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Permission granted, show radar with user location
    _showRadarWithLocation(
      context,
      permissionResult['latitude'] ?? 39.8283,
      permissionResult['longitude'] ?? -98.5795,
    );
  }
  
  void _showRadarWithLocation(BuildContext context, double lat, double lon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AppTheme.primaryNavy,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            title: Row(
              children: [
                Icon(
                  FontAwesomeIcons.cloudBolt,
                  color: AppTheme.accentCopper,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOAA Weather Radar',
                      style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
                    ),
                    Text(
                      'Official US Government Data',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline, color: AppTheme.white),
                onPressed: () => _showRadarInfo(context),
              ),
            ],
          ),
          body: NoaaRadarMap(
            initialLatitude: lat,
            initialLongitude: lon,
            initialZoom: 8.0,
            showAlerts: true,
            showHurricanes: true,
            onAlertTap: (alert) {
              // Show alert details and affected storm work
              _showAlertDetails(context, alert);
            },
          ),
        ),
      ),
    );
  }
  
  void _showRadarWithoutLocation(BuildContext context) {
    _showRadarWithLocation(context, 39.8283, -98.5795); // US center
  }
  
  void _showRadarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.satelliteDish,
              color: AppTheme.accentCopper,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text('NOAA Radar Guide'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Official NOAA/NWS Radar Data',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Precipitation Intensity:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildInfoRow(Colors.green, 'Light rain (< 0.1"/hr)'),
              _buildInfoRow(Colors.yellow, 'Moderate rain (0.1-0.3"/hr)'),
              _buildInfoRow(Colors.orange, 'Heavy rain (0.3-2.0"/hr)'),
              _buildInfoRow(Colors.red, 'Extreme rain (> 2.0"/hr)'),
              _buildInfoRow(Color(0xFFD8006D), 'Severe/Hail possible'),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Alert Severity Levels:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildInfoRow(Color(0xFFD8006D), 'Extreme - Take Action!'),
              _buildInfoRow(AppTheme.errorRed, 'Severe - Prepare Now'),
              _buildInfoRow(AppTheme.warningYellow, 'Moderate - Be Ready'),
              _buildInfoRow(Colors.orange, 'Minor - Stay Informed'),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Radar Products:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text('\u2022 Base Reflectivity - Precipitation intensity'),
              Text('\u2022 Base Velocity - Storm rotation detection'),
              Text('\u2022 Storm Total - Accumulated rainfall'),
              Text('\u2022 Composite - Full atmosphere scan'),
              const SizedBox(height: AppTheme.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.infoBlue,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        'NOAA radar updates every 4-10 minutes',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.infoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
  
  void _showAlertDetails(BuildContext context, dynamic alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        title: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: _getAlertColorForSeverity(alert.severity),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  alert.event,
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: _getAlertColorForSeverity(alert.severity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child: Text(
                  '${alert.severity} - ${alert.urgency}',
                  style: AppTheme.labelSmall.copyWith(
                    color: _getAlertColorForSeverity(alert.severity),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                alert.headline,
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Description:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                alert.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              if (alert.instruction != null && alert.instruction.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  'Instructions:',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.warningYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    border: Border.all(
                      color: AppTheme.warningYellow.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    alert.instruction,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${_formatAlertTime(alert.expires)}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.infoBlue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.hardHat,
                          color: AppTheme.infoBlue,
                          size: 16,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Storm Work Safety',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.infoBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'This alert may affect power restoration work. Always follow safety protocols and check with supervisors before deployment.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Could navigate to relevant storm work opportunities
            },
            icon: Icon(FontAwesomeIcons.bolt),
            label: Text('View Storm Work'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAlertColorForSeverity(String severity) {
    switch (severity) {
      case 'Extreme':
        return Color(0xFFD8006D);
      case 'Severe':
        return AppTheme.errorRed;
      case 'Moderate':
        return AppTheme.warningYellow;
      case 'Minor':
        return Colors.orange;
      default:
        return AppTheme.infoBlue;
    }
  }
  
  String _formatAlertTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inHours.abs() < 24) {
      if (difference.isNegative) {
        return '${difference.inHours.abs()} hours ago';
      } else {
        return 'in ${difference.inHours} hours';
      }
    }
    
    return '${dateTime.month}/${dateTime.day} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  Widget _buildInfoRow(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(label),
        ],
      ),
    );
  }

  void _showOutageDetails(BuildContext context, PowerOutageState outage) {
    final percentage = _powerOutageService.getOutagePercentage(outage);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: AppTheme.spacingLg,
            right: AppTheme.spacingLg,
            top: AppTheme.spacingLg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                children: [
                  Icon(
                    FontAwesomeIcons.bolt,
                    color: AppTheme.errorRed,
                    size: 32,
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outage.stateName,
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Power Outage Emergency',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _powerOutageService.formatOutageCount(outage.outageCount),
                            style: AppTheme.displaySmall.copyWith(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Without Power',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
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
                        color: AppTheme.warningYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: AppTheme.displaySmall.copyWith(
                              color: AppTheme.warningYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Affected',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Info section
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.infoBlue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.circleInfo,
                          color: AppTheme.infoBlue,
                          size: 16,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Storm Work Opportunity',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.infoBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'This state has significant power outages requiring immediate restoration crews. '
                      'Contact local IBEW unions in ${outage.stateName} for deployment opportunities.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: JJSecondaryButton(
                      text: 'View Jobs',
                      icon: FontAwesomeIcons.briefcase,
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to jobs filtered by state
                      },
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: JJPrimaryButton(
                      text: 'View Unions',
                      icon: FontAwesomeIcons.users,
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to unions filtered by state
                      },
                      isFullWidth: true,
                      variant: JJButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
          color: color.withValues(alpha: 0.2),
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
                  color: color.withValues(alpha: 0.1),
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


class StormEventCard extends StatelessWidget {
  final StormEvent storm;

  const StormEventCard({super.key, required this.storm});

  Color get _severityColor => storm.severityColor;

  String get _timeUntilDeployment => storm.deploymentTimeString;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border.all(color: _severityColor, width: AppTheme.borderWidthThick),
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
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
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
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
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
                        color: AppTheme.accentCopper.withValues(alpha: 0.1),
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

  Color get _severityColor => storm.severityColor;

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
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
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
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
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
                      color: AppTheme.accentCopper.withValues(alpha: 0.1),
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
                    color: AppTheme.primaryNavy.withValues(alpha: 0.1),
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
              variant: JJButtonVariant.primary,
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
