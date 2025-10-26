import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/riverpod/theme_riverpod_provider.dart';
import '../../providers/riverpod/app_settings_riverpod_provider.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  String _cacheSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();

    // Load settings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(appSettingsProvider.notifier).loadSettings(user.uid);
      }
    });
  }

  /// Get current user ID or empty string if not authenticated
  String _getUserId() {
    final user = ref.read(currentUserProvider);
    return user?.uid ?? '';
  }
  
  Future<void> _calculateCacheSize() async {
    // Simulate cache size calculation
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _cacheSize = '156 MB';
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
              _calculateCacheSize();
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
            // Appearance Section
            _buildSectionHeader('Appearance & Display'),
            _buildSettingsCard([
              Consumer(
                builder: (context, ref, _) {
                  final mode = ref.watch(themeModeNotifierProvider);
                  final _ = ref.watch(currentAppSettingsProvider);
                  final userId = _getUserId();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: Text(
                          'Appearance',
                          style: AppTheme.titleMedium,
                        ),
                        subtitle: const Text('Choose Light, Dark, or System'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: mode,
                        onChanged: (m) async {
                          if (m != null) {
                            // Update both theme provider and app settings
                            await ref.read(themeModeNotifierProvider.notifier).setThemeMode(m);
                            if (userId.isNotEmpty) {
                              ref.read(appSettingsProvider.notifier).updateThemeMode(userId, 'light');
                            }
                          }
                        },
                        title: const Text('Light'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: mode,
                        onChanged: (m) async {
                          if (m != null) {
                            await ref.read(themeModeNotifierProvider.notifier).setThemeMode(m);
                            if (userId.isNotEmpty) {
                              ref.read(appSettingsProvider.notifier).updateThemeMode(userId, 'dark');
                            }
                          }
                        },
                        title: const Text('Dark'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: mode,
                        onChanged: (m) async {
                          if (m != null) {
                            await ref.read(themeModeNotifierProvider.notifier).setThemeMode(m);
                            if (userId.isNotEmpty) {
                              ref.read(appSettingsProvider.notifier).updateThemeMode(userId, 'system');
                            }
                          }
                        },
                        title: const Text('System'),
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 1),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(currentAppSettingsProvider);
                  final userId = _getUserId();

                  return _buildSwitchTile(
                    icon: Icons.contrast,
                    title: 'High Contrast',
                    subtitle: 'Better visibility in bright sunlight',
                    value: settings.highContrastMode,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateHighContrastMode(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'High contrast ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
              const Divider(height: 1),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(currentAppSettingsProvider);
                  final userId = _getUserId();

                  return _buildSwitchTile(
                    icon: Icons.bolt,
                    title: 'Electrical Effects',
                    subtitle: 'Animations and visual effects',
                    value: settings.electricalEffects,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateElectricalEffects(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Electrical effects ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
              const Divider(height: 1),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(currentAppSettingsProvider);
                  final userId = _getUserId();

                  return _buildDropdownTile(
                    icon: Icons.text_fields,
                    title: 'Font Size',
                    value: settings.fontSize,
                    options: ['Small', 'Medium', 'Large', 'Extra Large'],
                    onChanged: (value) async {
                      if (value != null && userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateFontSize(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Font size updated to $value',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ]),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Job Search Preferences
            _buildSectionHeader('Job Search Preferences'),
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(currentAppSettingsProvider);
                final userId = _getUserId();

                return _buildSettingsCard([
                  _buildSliderTile(
                    icon: Icons.location_on,
                    title: 'Default Search Radius',
                    subtitle: '${settings.defaultSearchRadius.toInt()} ${settings.distanceUnits}',
                    value: settings.defaultSearchRadius,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateSearchRadius(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Search radius updated to ${value.toInt()} ${settings.distanceUnits}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildDropdownTile(
                    icon: Icons.straighten,
                    title: 'Distance Units',
                    value: settings.distanceUnits,
                    options: ['Miles', 'Kilometers'],
                    onChanged: (value) async {
                      if (value != null && userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateDistanceUnits(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Distance units updated to $value',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    icon: Icons.attach_money,
                    title: 'Minimum Hourly Rate',
                    subtitle: '\$${settings.minimumHourlyRate.toStringAsFixed(2)}/hr',
                    value: settings.minimumHourlyRate,
                    min: 20,
                    max: 100,
                    divisions: 80,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateMinimumHourlyRate(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Minimum hourly rate updated to \$${value.toStringAsFixed(2)}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.flash_auto,
                    title: 'Auto-Apply',
                    subtitle: 'Automatically apply to matching jobs',
                    value: settings.autoApplyEnabled,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateAutoApply(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Auto-apply ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                ]);
              },
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Data & Storage
            _buildSectionHeader('Data & Storage'),
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(currentAppSettingsProvider);
                final userId = _getUserId();

                return _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.offline_pin,
                    title: 'Offline Mode',
                    subtitle: 'Download union data for offline access',
                    value: settings.offlineModeEnabled,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateOfflineMode(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Offline mode ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.download,
                    title: 'Auto-Download',
                    subtitle: 'Weather maps and union updates',
                    value: settings.autoDownloadEnabled,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateAutoDownload(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Auto-download ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.wifi,
                    title: 'Wi-Fi Only Downloads',
                    subtitle: 'Limit downloads to Wi-Fi connections',
                    value: settings.wifiOnlyDownloads,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateWifiOnlyDownloads(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Wi-Fi only downloads ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildActionTile(
                    icon: Icons.cleaning_services,
                    title: 'Clear Cache',
                    subtitle: 'Current size: $_cacheSize',
                    onTap: _clearCache,
                  ),
                ]);
              },
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Privacy & Security
            _buildSectionHeader('Privacy & Security'),
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(currentAppSettingsProvider);
                final userId = _getUserId();

                return _buildSettingsCard([
                  _buildDropdownTile(
                    icon: Icons.visibility,
                    title: 'Profile Visibility',
                    value: settings.profileVisibility,
                    options: ['Public', 'Union Members Only', 'Private'],
                    onChanged: (value) async {
                      if (value != null && userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateProfileVisibility(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Profile visibility updated to $value',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.location_on,
                    title: 'Location Services',
                    subtitle: 'Used for job and weather alerts',
                    value: settings.locationServicesEnabled,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateLocationServices(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Location services ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric Login',
                    subtitle: 'Use Face ID or Touch ID',
                    value: settings.biometricLoginEnabled,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateBiometricLogin(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Biometric login ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.security,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Extra security for your account',
                    value: settings.twoFactorEnabled,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateTwoFactor(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Two-factor authentication ${value ? 'enabled' : 'disabled'}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                ]);
              },
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Language & Region
            _buildSectionHeader('Language & Region'),
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(currentAppSettingsProvider);
                final userId = _getUserId();

                return _buildSettingsCard([
                  _buildDropdownTile(
                    icon: Icons.language,
                    title: 'Language',
                    value: settings.language,
                    options: ['English', 'Spanish', 'French'],
                    onChanged: (value) async {
                      if (value != null && userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateLanguage(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Language updated to $value',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildDropdownTile(
                    icon: Icons.calendar_today,
                    title: 'Date Format',
                    value: settings.dateFormat,
                    options: ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                    onChanged: (value) async {
                      if (value != null && userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateDateFormat(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Date format updated to $value',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildDropdownTile(
                    icon: Icons.access_time,
                    title: 'Time Format',
                    value: settings.timeFormat,
                    options: ['12-hour', '24-hour'],
                    onChanged: (value) async {
                      if (value != null && userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateTimeFormat(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Time format updated to $value',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                ]);
              },
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Storm Work Settings
            _buildSectionHeader('Storm Work Settings'),
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(currentAppSettingsProvider);
                final userId = _getUserId();

                return _buildSettingsCard([
                  _buildSliderTile(
                    icon: Icons.warning_amber,
                    title: 'Storm Alert Radius',
                    subtitle: '${settings.stormAlertRadius.toInt()} ${settings.distanceUnits}',
                    value: settings.stormAlertRadius,
                    min: 50,
                    max: 500,
                    divisions: 45,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateStormAlertRadius(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Storm alert radius updated to ${value.toInt()} ${settings.distanceUnits}',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    icon: Icons.trending_up,
                    title: 'Minimum Rate Multiplier',
                    subtitle: '${settings.stormRateMultiplier.toStringAsFixed(1)}x regular rate',
                    value: settings.stormRateMultiplier,
                    min: 1.0,
                    max: 3.0,
                    divisions: 20,
                    onChanged: (value) async {
                      if (userId.isNotEmpty) {
                        try {
                          await ref.read(appSettingsProvider.notifier).updateStormRateMultiplier(userId, value);
                          if (context.mounted) {
                            JJSnackBar.showSuccess(
                              context: context,
                              message: 'Storm rate multiplier updated to ${value.toStringAsFixed(1)}x',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            JJSnackBar.showError(
                              context: context,
                              message: 'Failed to save setting',
                            );
                          }
                        }
                      }
                    },
                  ),
                ]);
              },
            ),
            
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
  
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isLoading = ref.watch(appSettingsLoadingProvider);

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
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
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
