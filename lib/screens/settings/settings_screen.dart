import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../navigation/app_router.dart';
import '../../services/onboarding_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/dialogs/user_job_preferences_dialog.dart';
import '../../providers/riverpod/user_preferences_riverpod_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  String? _ticketNumber;
  String? _userName;
  String? _localNumber;
  bool _isLoading = true;

  // Animation controllers for personalized header
  late AnimationController _headerAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Catchy expressions for electrical workers
  final List<String> _catchyExpressions = [
    "⚡ Keeping the Power On!",
    "🔌 Wired for Success",
    "⚡ Sparking Excellence",
    "🔧 High Voltage Professional",
    "⚡ Energizing Communities",
    "🏗️ Building Tomorrow's Grid",
    "⚡ Brotherhood Strong",
    "🔌 Safety First, Quality Always",
    "⚡ Powering Progress",
    "🔧 Union Proud & Skilled",
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
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
          final data = doc.data();
          setState(() {
            _ticketNumber = data?['ticket_number']?.toString();
            _userName = data?['name'] ?? user.displayName ?? 'Brother';
            _localNumber = data?['local_number']?.toString();
            _isLoading = false;
          });
          _headerAnimationController.forward();
        } else if (mounted) {
          setState(() {
            _userName = user.displayName ?? 'Brother';
            _isLoading = false;
          });
          _headerAnimationController.forward();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = user.displayName ?? 'Brother';
            _isLoading = false;
          });
          _headerAnimationController.forward();
        }
      }
    } else {
      setState(() {
        _userName = 'Brother';
        _isLoading = false;
      });
      _headerAnimationController.forward();
    }
  }

  String _getRandomExpression() {
    final now = DateTime.now();
    final index = (now.day + now.hour) % _catchyExpressions.length;
    return _catchyExpressions[index];
  }

  Widget _buildPersonalizedHeader() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryNavy,
              AppTheme.secondaryNavy,
              AppTheme.primaryNavy.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            AppTheme.shadowLg,
            BoxShadow(
              color: AppTheme.accentCopper.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentCopper,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_headerAnimationController, _pulseAnimationController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryNavy,
                    AppTheme.secondaryNavy,
                    AppTheme.primaryNavy.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.accentCopper.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  AppTheme.shadowLg,
                  BoxShadow(
                    color: AppTheme.accentCopper.withValues(alpha: _pulseAnimation.value * 0.3),
                    blurRadius: 20 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile avatar with electrical theme
                  Stack(
                    children: [
                      // Glow effect
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentCopper.withValues(alpha: _pulseAnimation.value * 0.5),
                              blurRadius: 30 * _pulseAnimation.value,
                              spreadRadius: 5 * _pulseAnimation.value,
                            ),
                          ],
                        ),
                      ),
                      // Main avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppTheme.buttonGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.white,
                            width: 3,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.electrical_services,
                                size: AppTheme.iconXl + 8,
                                color: AppTheme.white,
                              ),
                            ),
                            // Sparkle effect
                            Positioned(
                              top: 15,
                              right: 15,
                              child: Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppTheme.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.white.withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Welcome message
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome back, ',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.9),
                          ),
                        ),
                        TextSpan(
                          text: _userName ?? 'Brother',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.accentCopper,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '!',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  // Ticket and Local info
                  if (_ticketNumber != null || _localNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.accentCopper.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_ticketNumber != null) ...[
                            Icon(
                              Icons.badge,
                              size: AppTheme.iconSm,
                              color: AppTheme.accentCopper,
                            ),
                            const SizedBox(width: AppTheme.spacingXs),
                            Text(
                              'Ticket #$_ticketNumber',
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (_ticketNumber != null && _localNumber != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                              width: 1,
                              height: 16,
                              color: AppTheme.accentCopper.withValues(alpha: 0.5),
                            ),
                          if (_localNumber != null) ...[
                            Icon(
                              Icons.location_city,
                              size: AppTheme.iconSm,
                              color: AppTheme.accentCopper,
                            ),
                            const SizedBox(width: AppTheme.spacingXs),
                            Text(
                              'Local $_localNumber',
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Catchy expression
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentCopper.withValues(alpha: 0.8),
                          AppTheme.secondaryCopper.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentCopper.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getRandomExpression(),
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Edit Profile button with electrical styling
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
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
            // Personalized header section
            _buildPersonalizedHeader(),

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
                _MenuOption(
                  icon: Icons.tune_outlined,
                  title: 'Job Preferences',
                  subtitle: 'Set your job preferences',
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      JJSnackBar.showError(
                        context: context,
                        message: 'User not logged in',
                      );
                      return;
                    }
                    final initialPrefs = ref.read(userPreferencesProvider).preferences.preferences;
                    await showDialog(
                      context: context,
                      builder: (context) => UserJobPreferencesDialog(
                        userId: user.uid,
                        isFirstTime: false,
                        initialPreferences: initialPrefs,
                      ),
                    );
                  },
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