import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/storm_event.dart';
import '../../widgets/weather/noaa_radar_map.dart';
import '../../widgets/contractor_card.dart';
import '../../services/power_outage_service.dart';
import '../../widgets/storm/power_outage_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../electrical_components/circuit_board_background.dart'; // Added import for electrical background
import '../../providers/riverpod/contractor_provider.dart'; // Added import for contractor provider

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
  bool _isPowerOutageExpanded = true;
  
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

  Future<bool> _checkAdminStatus(String uid) async {
    // TODO: Check if current user is admin
    // final isAdmin = await _checkAdminStatus(currentUser.uid);
    // if (!isAdmin) return SizedBox.shrink();
    return false; // Placeholder - implement admin check logic
  }

  List<PowerOutageState> get _sortedPowerOutages {
    final sorted = List<PowerOutageState>.from(_powerOutages);
    sorted.sort((a, b) {
      // Sort by state name alphabetically
      return a.stateName.compareTo(b.stateName);
    });
    return sorted;
  }

  Widget _buildStormDetailCard(String title, String description, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.lightGray,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            description,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for circuit background
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy, // Blue app bar per theme
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
      body: Stack(
        children: [
          // Circuit board background properly positioned
          const Positioned.fill(
            child: ElectricalCircuitBackground(
              opacity: 0.08,
              componentDensity: ComponentDensity.high,
              enableCurrentFlow: true,
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.accentCopper,
                  width: AppTheme.borderWidthCopper * 0.5,
                ),
                boxShadow: [
                  AppTheme.shadowElectricalInfo,
                ],
              ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emergency alert banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryNavy, AppTheme.accentCopper],
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

                  // Power outage section with toggle
                  if (_powerOutages.isNotEmpty) ...[
                    PowerOutageSummary(outages: _powerOutages),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Power outage toggle header
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.accentCopper.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _isPowerOutageExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppTheme.primaryNavy,
                        ),
                        title: Text(
                          'Power Outages by State',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        subtitle: Text(
                          '${_powerOutages.length} states with active outages',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _isPowerOutageExpanded = !_isPowerOutageExpanded;
                          });
                        },
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.infoBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text(
                            _isPowerOutageExpanded ? 'COLLAPSE' : 'EXPAND',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.infoBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Expandable power outage cards
                    if (_isPowerOutageExpanded) ...[
                      const SizedBox(height: AppTheme.spacingMd),

                      if (_isLoadingOutages)
                        Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accentCopper,
                          ),
                        )
                      else
                        ..._sortedPowerOutages.map((outage) => PowerOutageCard(
                          outageData: outage,
                          onTap: () => _showOutageDetails(context, outage),
                        )),
                    ],

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
                            border: Border.all(
                  color: AppTheme.accentCopper,
                  width: AppTheme.borderWidthCopper * 0.5,
                ),
                boxShadow: [
                  AppTheme.shadowElectricalInfo,
                ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRegion,
                              isExpanded: true,
                              items: _regions.map((region) {
                                return DropdownMenuItem<String>(
                                  value: region,
                                  child: Text(region),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRegion = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Emergency Declarations Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: [AppTheme.shadowMd],
                      border: Border.all(
                        color: AppTheme.accentCopper.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.video_library,
                              color: AppTheme.primaryNavy,
                              size: AppTheme.iconMd,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                                    'Emergency Declarations',
                                    style: AppTheme.headlineSmall.copyWith(
                                      color: AppTheme.primaryNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacingSm,
                                      vertical: AppTheme.spacingXs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningYellow.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                                    ),
                                    child: Text(
                                      'ADMIN ONLY',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: AppTheme.warningYellow,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              Text(
                                'Real-time video updates from emergency management',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              // TODO: Implement video player widget
                              // Use video_player package or chewie for video playback
                              // Videos should be uploaded by admins via Firebase Storage
                              // Display in a ListView with thumbnail, title, timestamp
                              // Example:
                              // VideoPlayerWidget(
                              //   videoUrl: 'https://storage.googleapis.com/...',
                              //   thumbnail: 'https://...',
                              //   title: 'Governor Emergency Declaration - Hurricane Milton',
                              //   timestamp: DateTime.now(),
                              // )
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightGray.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(
                                    color: AppTheme.accentCopper.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.video_library_outlined,
                                      size: 48,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(height: AppTheme.spacingSm),
                                    Text(
                                      'Video player coming soon',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Admin video upload functionality',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // TODO: Add video upload functionality for admins
                              // TODO: Implement video player with controls
                              // TODO: Add video metadata (title, description, timestamp)
                              // TODO: Implement video list with pagination
                            ],
                          ),
                        ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Storm Contractors Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: [AppTheme.shadowMd],
                      border: Border.all(
                        color: AppTheme.accentCopper.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group_outlined,
                              color: AppTheme.primaryNavy,
                              size: AppTheme.iconMd,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              'Storm Contractors',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        SizedBox(
                          height: 200, // Fixed height for the list
                          child: Consumer(
                            builder: (context, ref, child) {
                              final asyncContractors = ref.watch(contractorsStreamProvider);
                              return asyncContractors.when(
                                data: (contractors) {
                                  if (contractors.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No contractors available',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: contractors.length,
                                    itemBuilder: (context, index) {
                                      final contractor = contractors[index];
                                      return ContractorCard(contractor: contractor);
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.accentCopper,
                                  ),
                                ),
                                error: (error, stack) => Center(
                                  child: Text(
                                    'Error loading contractors: $error',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.errorRed,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXl),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ),
        ],
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
          color: color.withValues(alpha: 0.2),
          width: 0.5,
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

  void _showWeatherRadar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            title: Text(
              'Live Weather Radar',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const NoaaRadarMap(),
        ),
      ),
    );
  }

  void _showOutageDetails(BuildContext context, PowerOutageState outage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
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
                  // Title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          outage.stateName,
                          style: AppTheme.displaySmall.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  // Outage info
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.infoBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.infoBlue.withValues(alpha: 0.3),
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
                          icon: FontAwesomeIcons.userGroup,
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
      },
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

  static void _showStormDetails(BuildContext context, StormEvent storm) {
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
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${storm.openPositions}',
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
                          'Avg. Pay Rate',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
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
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Description
            Text(
              'Description',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              storm.description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // What to Expect
            Text(
              'What to Expect',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Extended hours, challenging conditions, and a rewarding experience helping communities recover.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
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
                    icon: FontAwesomeIcons.userGroup,
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
      ),
    );
  }
}
