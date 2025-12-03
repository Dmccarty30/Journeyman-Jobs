import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/app_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import 'storm_theme.dart';
import '../../models/storm_event.dart';
import '../../widgets/weather/noaa_radar_map.dart';
import '../../services/power_outage_service.dart';
import '../../widgets/storm/power_outage_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../electrical_components/circuit_board_background.dart';
import 'widgets/storm_contractor_card.dart';
import 'widgets/storm_tracker_section.dart';
import 'widgets/fox_weather_widget.dart';

class StormScreen extends StatefulWidget {
  const StormScreen({super.key});

  @override
  State<StormScreen> createState() => _StormScreenState();
}

class _StormScreenState extends State<StormScreen> {
  // Storm Tracker
  // final StormTrackingService _stormTrackingService = StormTrackingService();

  String _selectedRegion = 'All Regions';

  // Power outage tracking
  final PowerOutageService _powerOutageService = PowerOutageService();
  List<PowerOutageState> _powerOutages = [];
  bool _isLoadingOutages = true;

  // Storm Contractors
  List<Map<String, dynamic>> _stormContractors = [];
  bool _isLoadingContractors = true;

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
      description:
          'Major power restoration effort following Category 4 hurricane impact. Multiple transmission lines down, extensive distribution damage.',
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
      description:
          'Ice accumulation caused widespread outages across central Texas. Tree clearing and line repair needed.',
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
      description:
          'Straight-line wind damage to distribution system. Most transmission restored.',
      deploymentDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<StormEvent> get _filteredStorms {
    if (_selectedRegion == 'All Regions') {
      return _activeStorms;
    }
    return _activeStorms
        .where((storm) => storm.region == _selectedRegion)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPowerOutages();
    _loadStormContractors();
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

  Future<void> _loadStormContractors() async {
    try {
      final String response = await DefaultAssetBundle.of(context)
          .loadString('assets/data/storm_roster.json');
      final List<dynamic> jsonList = json.decode(response);
      if (mounted) {
        setState(() {
          _stormContractors = jsonList.cast<Map<String, dynamic>>();
          _isLoadingContractors = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading storm contractors: $e');
      if (mounted) {
        setState(() {
          _isLoadingContractors = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for circuit background
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: StormTheme.stormSurgeGradient,
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.flash_on,
              color: StormTheme.lightningYellow,
              size: AppTheme.iconMd,
              shadows: [StormTheme.lightningGlow],
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
              Icons
                  .notifications_outlined, // Changed to a static icon as it now navigates
              color: AppTheme.white,
            ),
            onPressed: () {
              context.push(AppRouter.notificationSettings);
            },
            tooltip: 'Notifications Settings',
          ),
        ],
      ),
      body: ElectricalCircuitBackground(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Container(
            decoration: BoxDecoration(
              // Removed copper border from primary container
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Storm work stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Storm Activity',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.radar),
                        color: StormTheme.electricBlue,
                        tooltip: 'Weather Radar',
                        onPressed: () => _showWeatherRadar(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Fox Weather Live
                  const FoxWeatherWidget(),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Storm Tracker
                  const StormTrackerSection(),
                  const SizedBox(height: AppTheme.spacingLg),

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.lightGray),
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

                  // Active Storm Events Section
                  Text(
                    'Active Storm Events',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  ..._filteredStorms
                      .map((storm) => StormEventCard(storm: storm)),

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
                        width: 1,
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
                          height: 250, // Increased height for better visibility
                          child: _isLoadingContractors
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.accentCopper,
                                  ),
                                )
                              : _stormContractors.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No storm contractors available',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _stormContractors.length,
                                      itemBuilder: (context, index) {
                                        final contractor =
                                            _stormContractors[index];
                                        return StormContractorCard(
                                            contractor: contractor);
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
        ),
      ),
    );
  }

  Widget _buildStormStatCard(
      String title, String value, IconData icon, Color color) {
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.white,
            color.withValues(alpha: 0.05),
          ],
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
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
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
      decoration: StormTheme.activeStormCardDecoration.copyWith(
        border:
            Border.all(color: _severityColor, width: AppTheme.borderWidthThick),
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
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusXs),
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return StormDetailsSheet(
                storm: storm, scrollController: scrollController);
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
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusXs),
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
