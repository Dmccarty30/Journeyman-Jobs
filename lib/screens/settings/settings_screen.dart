import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../navigation/app_router.dart';
import '../../services/onboarding_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _ticketNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists && mounted) {
          setState(() {
            _ticketNumber = doc.data()?['ticket_number']?.toString();
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.accentCopper,
                  width: AppTheme.borderWidthThin,
                ),
                boxShadow: [AppTheme.shadowMd],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: AppTheme.iconXl,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    user?.displayName ?? user?.email ?? 'Journeyman',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  if (_isLoading)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Text(
                      _ticketNumber != null ? 'Ticket #$_ticketNumber' : 'IBEW Member',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  const SizedBox(height: AppTheme.spacingLg),
                  JJPrimaryButton(
                    text: 'Edit Profile',
                    icon: Icons.edit,
                    onPressed: () {
                      context.push(AppRouter.profile);
                    },
                    isFullWidth: true,
                    variant: JJButtonVariant.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Menu sections
            _buildMenuSection(
              'Account',
              [
                _MenuOption(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Manage your personal information',
                  onTap: () => context.push(AppRouter.profile),
                ),
                _MenuOption(
                  icon: Icons.badge_outlined,
                  title: 'Training & Certificates',
                  subtitle: 'Track your professional credentials',
                  onTap: () => context.push(AppRouter.training),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            _buildMenuSection(
              'Support',
              [
                _MenuOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get assistance and FAQ',
                  onTap: () => context.push(AppRouter.help),
                ),
                _MenuOption(
                  icon: Icons.library_books_outlined,
                  title: 'Resources',
                  subtitle: 'Useful documents and links',
                  onTap: () => context.push(AppRouter.resources),
                ),
                _MenuOption(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  onTap: () => context.push(AppRouter.feedback),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            _buildMenuSection(
              'App',
              [
                _MenuOption(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => context.push(AppRouter.notificationSettings),
                ),
                _MenuOption(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Control your data and privacy',
                  onTap: () {
                    // TODO: Show privacy settings
                  },
                ),
                _MenuOption(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Sign out button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.accentCopper,
                  width: AppTheme.borderWidthThin,
                ),
                boxShadow: [AppTheme.shadowSm],
              ),
              child: Column(
                children: [
                  JJSecondaryButton(
                    text: 'Sign Out',
                    icon: Icons.logout,
                    onPressed: _signOut,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXxl),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingSm),
          child: Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthThin,
            ),
            boxShadow: [AppTheme.shadowSm],
          ),
          child: Column(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isLast = index == options.length - 1;
              
              return Column(
                children: [
                  _buildMenuItem(option),
                  if (!isLast) 
                    const Divider(
                      height: 1,
                      indent: AppTheme.spacingXl,
                      endIndent: AppTheme.spacingMd,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuOption option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  option.icon,
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
                      option.title,
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        option.subtitle!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textLight,
                size: AppTheme.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.electrical_services,
                color: AppTheme.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            const Text('Journeyman Jobs'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: _showDebugOptions,
              child: const Text('Version 1.0.0'),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'The premier job discovery app for IBEW Journeymen.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Clearing the Books.',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.accentCopper,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDebugOptions() {
    Navigator.pop(context); // Close about dialog first
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.bug_report,
              color: AppTheme.warningYellow,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Debug Options',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.warningYellow,
              ),
            ),
          ],
        ),
        content: Text(
          'This will reset your onboarding status and force you to complete onboarding again on next app restart.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final onboardingService = OnboardingService();
              await onboardingService.resetOnboarding();
              if (context.mounted) {
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Onboarding status reset. Restart app to test.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningYellow,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Reset Onboarding'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        AppRouter.goToWelcome(context);
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error signing out. Please try again.',
        );
      }
    }
  }
}

class _MenuOption {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}