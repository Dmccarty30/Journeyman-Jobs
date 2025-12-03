import 'package:flutter/material.dart';
import 'package:journeyman_jobs/electrical_components/jj_circuit_breaker_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../electrical_components/circuit_board_background.dart';

class JobSearchPreferencesScreen extends StatefulWidget {
  const JobSearchPreferencesScreen({super.key});

  @override
  State<JobSearchPreferencesScreen> createState() => _JobSearchPreferencesScreenState();
}

class _JobSearchPreferencesScreenState extends State<JobSearchPreferencesScreen> {
  double _defaultSearchRadius = 50.0;
  String _units = 'Miles';
  bool _autoApplyEnabled = false;
  double _minimumHourlyRate = 35.0;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _defaultSearchRadius = prefs.getDouble('default_search_radius') ?? 50.0;
      _units = prefs.getString('units') ?? 'Miles';
      _autoApplyEnabled = prefs.getBool('auto_apply') ?? false;
      _minimumHourlyRate = prefs.getDouble('minimum_hourly_rate') ?? 35.0;
    });
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Job Search Preferences',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryNavy,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Stack(
        children: [
          ElectricalCircuitBackground(
            opacity: 0.35,
            componentDensity: ComponentDensity.high,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Search Filters'),
                _buildSettingsCard([
                  _buildSliderTile(
                    icon: Icons.location_on,
                    title: 'Default Search Radius',
                    subtitle: '${_defaultSearchRadius.toInt()} $_units',
                    value: _defaultSearchRadius,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    onChanged: (value) {
                      setState(() => _defaultSearchRadius = value);
                      _saveSetting('default_search_radius', value);
                    },
                  ),
                  const Divider(height: 1),
                  _buildDropdownTile(
                    icon: Icons.straighten,
                    title: 'Distance Units',
                    value: _units,
                    options: ['Miles', 'Kilometers'],
                    onChanged: (value) {
                      setState(() => _units = value!);
                      _saveSetting('units', value);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    icon: Icons.attach_money,
                    title: 'Minimum Hourly Rate',
                    subtitle: '\$${_minimumHourlyRate.toStringAsFixed(2)}/hr',
                    value: _minimumHourlyRate,
                    min: 20,
                    max: 100,
                    divisions: 80,
                    onChanged: (value) {
                      setState(() => _minimumHourlyRate = value);
                      _saveSetting('minimum_hourly_rate', value);
                    },
                  ),
                ]),
                
                const SizedBox(height: AppTheme.spacingLg),

                _buildSectionHeader('Application Automation'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.flash_auto,
                    title: 'Auto-Apply',
                    subtitle: 'Automatically apply to matching jobs',
                    value: _autoApplyEnabled,
                    onChanged: (value) {
                      setState(() => _autoApplyEnabled = value);
                      _saveSetting('auto_apply', value);
                    },
                  ),
                ]),
                
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(List<Widget> children) {
    return JJCard(
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildSwitchTile({
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
  
  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
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
            child: Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: DropdownButton<String>(
              value: value,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              isDense: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.accentCopper,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.accentCopper,
              inactiveTrackColor: AppTheme.borderLight,
              thumbColor: AppTheme.accentCopper,
              overlayColor: AppTheme.accentCopper.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}