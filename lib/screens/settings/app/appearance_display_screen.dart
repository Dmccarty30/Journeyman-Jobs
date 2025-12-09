import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/widgets/design_system_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../../electrical_components/circuit_board_background.dart';

class AppearanceDisplayScreen extends StatefulWidget {
  const AppearanceDisplayScreen({super.key});

  @override
  State<AppearanceDisplayScreen> createState() => _AppearanceDisplayScreenState();
}

class _AppearanceDisplayScreenState extends State<AppearanceDisplayScreen> {
  bool _darkModeEnabled = false;
  bool _highContrastMode = false;
  bool _electricalEffects = true;
  String _selectedFontSize = 'Medium';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _darkModeEnabled = prefs.getBool('dark_mode') ?? false;
      _highContrastMode = prefs.getBool('high_contrast') ?? false;
      _electricalEffects = prefs.getBool('electrical_effects') ?? true;
      _selectedFontSize = prefs.getString('font_size') ?? 'Medium';
    });
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
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
          'Appearance & Display',
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
                _buildSectionHeader('Visual Settings'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'TODO: Implement dark theme',
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() => _darkModeEnabled = value);
                      _saveSetting('dark_mode', value);
                      JJSnackBar.showInfo(
                        context: context,
                        message: 'Dark mode coming soon!',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.contrast,
                    title: 'High Contrast',
                    subtitle: 'Better visibility in bright sunlight',
                    value: _highContrastMode,
                    onChanged: (value) {
                      setState(() => _highContrastMode = value);
                      _saveSetting('high_contrast', value);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.bolt,
                    title: 'Electrical Effects',
                    subtitle: 'Animations and visual effects',
                    value: _electricalEffects,
                    onChanged: (value) {
                      setState(() => _electricalEffects = value);
                      _saveSetting('electrical_effects', value);
                    },
                  ),
                  const Divider(height: 1),
                  _buildDropdownTile(
                    icon: Icons.text_fields,
                    title: 'Font Size',
                    value: _selectedFontSize,
                    options: ['Small', 'Medium', 'Large', 'Extra Large'],
                    onChanged: (value) {
                      setState(() => _selectedFontSize = value!);
                      _saveSetting('font_size', value);
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
}