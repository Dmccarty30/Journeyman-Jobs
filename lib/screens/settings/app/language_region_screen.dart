import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../electrical_components/circuit_board_background.dart';

class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  String _selectedLanguage = 'English';
  String _dateFormat = 'MM/DD/YYYY';
  String _timeFormat = '12-hour';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _dateFormat = prefs.getString('date_format') ?? 'MM/DD/YYYY';
      _timeFormat = prefs.getString('time_format') ?? '12-hour';
    });
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Language & Region',
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
                _buildSectionHeader('Regional Preferences'),
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
}