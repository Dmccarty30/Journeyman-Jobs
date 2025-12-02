  import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {

  

  

  

  
  // Language & Region
  String _selectedLanguage = 'English';
  String _dateFormat = 'MM/DD/YYYY';
  String _timeFormat = '12-hour';
  
  // Storm Work Settings
  double _stormAlertRadius = 100.0;
  double _stormRateMultiplier = 1.5;
  String _units = 'miles';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Appearance
      // Removed as these settings are now handled by AppearanceDisplayScreen
      
      // Job Search
      // Removed as these settings are now handled by JobSearchPreferencesScreen
      
      // Data & Storage
      // Removed as these settings are now handled by DataStorageScreen
      
      // Privacy & Security
      // Removed as these settings are now handled by PrivacySecurityScreen
      
      // Language & Region
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _dateFormat = prefs.getString('date_format') ?? 'MM/DD/YYYY';
      _timeFormat = prefs.getString('time_format') ?? '12-hour';
      
      // Storm Work
      _stormAlertRadius = prefs.getDouble('storm_alert_radius') ?? 100.0;
      _stormRateMultiplier = prefs.getDouble('storm_rate_multiplier') ?? 1.5;
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
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'App Settings',
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

            
            const SizedBox(height: AppTheme.spacingLg),
            

            

            

            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Language & Region
            _buildSectionHeader('Language & Region'),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Language',
                value: _selectedLanguage,
                options: ['English', 'Spanish', 'French'],
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  _saveSetting('language', value);
                },
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.calendar_today,
                title: 'Date Format',
                value: _dateFormat,
                options: ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                onChanged: (value) {
                  setState(() => _dateFormat = value!);
                  _saveSetting('date_format', value);
                },
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.access_time,
                title: 'Time Format',
                value: _timeFormat,
                options: ['12-hour', '24-hour'],
                onChanged: (value) {
                  setState(() => _timeFormat = value!);
                  _saveSetting('time_format', value);
                },
              ),
            ]),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Storm Work Settings
            _buildSectionHeader('Storm Work Settings'),
            _buildSettingsCard([
              _buildSliderTile(
                icon: Icons.warning_amber,
                title: 'Storm Alert Radius',
                subtitle: '${_stormAlertRadius.toInt()} $_units',
                value: _stormAlertRadius,
                min: 50,
                max: 500,
                divisions: 45,
                onChanged: (value) {
                  setState(() => _stormAlertRadius = value);
                  _saveSetting('storm_alert_radius', value);
                },
              ),
              const Divider(height: 1),
              _buildSliderTile(
                icon: Icons.trending_up,
                title: 'Minimum Rate Multiplier',
                subtitle: '${_stormRateMultiplier}x regular rate',
                value: _stormRateMultiplier,
                min: 1.0,
                max: 3.0,
                divisions: 20,
                onChanged: (value) {
                  setState(() => _stormRateMultiplier = value);
                  _saveSetting('storm_rate_multiplier', value);
                },
              ),
            ]),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // About Section
            _buildSectionHeader('About'),
            _buildSettingsCard([
              _buildInfoTile(
                icon: Icons.info_outline,
                title: 'Version',
                value: '1.0.0',
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () {
                  // Navigate to terms
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'View privacy policy',
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                onTap: () {
                  // Navigate to help
                },
              ),
            ]),
            
            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
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
  
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
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
              Icon(
                Icons.chevron_right,
                color: AppTheme.textLight,
                size: AppTheme.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
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
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
