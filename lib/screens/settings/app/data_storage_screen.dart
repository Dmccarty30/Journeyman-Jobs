import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/electrical_components/jj_circuit_breaker_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/widgets/design_system_widgets.dart';
import '../../../electrical_components/circuit_board_background.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  bool _offlineModeEnabled = false;
  bool _autoDownloadEnabled = true;
  bool _wifiOnlyDownloads = true;
  String _cacheSize = 'Calculating...';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _offlineModeEnabled = prefs.getBool('offline_mode') ?? false;
      _autoDownloadEnabled = prefs.getBool('auto_download') ?? true;
      _wifiOnlyDownloads = prefs.getBool('wifi_only_downloads') ?? true;
    });
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    }
  }
  
  Future<void> _calculateCacheSize() async {
    // Simulate cache size calculation
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _cacheSize = '156 MB'; // Placeholder value
      });
    }
  }
  
  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: AppTheme.warningYellow,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              'Clear Cache?',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        content: Text(
          'This will delete all cached data including offline union directories and weather maps. You\'ll need to re-download them.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          JJPrimaryButton(
            text: 'Clear Cache',
            onPressed: () async {
              Navigator.of(context).pop();
              // Simulate cache clearing
              JJSnackBar.showSuccess(
                context: context,
                message: 'Cache cleared successfully',
              );
              _calculateCacheSize(); // Recalculate after clearing
            },
            width: 120,
            variant: JJButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Data & Storage',
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
                _buildSectionHeader('Offline Access'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.offline_pin,
                    title: 'Offline Mode',
                    subtitle: 'Download union data for offline access',
                    value: _offlineModeEnabled,
                    onChanged: (value) {
                      setState(() => _offlineModeEnabled = value);
                      _saveSetting('offline_mode', value);
                    },
                  ),
                ]),
                
                const SizedBox(height: AppTheme.spacingLg), 
                
                _buildSectionHeader('Downloads'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.download,
                    title: 'Auto-Download',
                    subtitle: 'Weather maps and union updates',
                    value: _autoDownloadEnabled,
                    onChanged: (value) {
                      setState(() => _autoDownloadEnabled = value);
                      _saveSetting('auto_download', value);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.wifi,
                    title: 'Wi-Fi Only Downloads',
                    subtitle: 'Limit downloads to Wi-Fi connections',
                    value: _wifiOnlyDownloads,
                    onChanged: (value) {
                      setState(() => _wifiOnlyDownloads = value);
                      _saveSetting('wifi_only_downloads', value);
                    },
                  ),
                ]),
                
                const SizedBox(height: AppTheme.spacingLg), 

                _buildSectionHeader('Cache Management'),
                _buildSettingsCard([
                  _buildActionTile(
                    icon: Icons.cleaning_services,
                    title: 'Clear Cache',
                    subtitle: 'Current size: $_cacheSize',
                    onTap: _clearCache,
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
}
