import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/app_theme_dark.dart';
import '../../design_system/components/reusable_components.dart';
import '../../electrical_components/circuit_board_background.dart';

/// Dark Mode Preview Screen
///
/// Interactive preview screen that demonstrates the dark mode theme
/// with side-by-side comparisons and live component examples.
/// Shows all the subtle design elements including copper gradients,
/// layered shadows, and electrical animations.
class DarkModePreviewScreen extends StatefulWidget {
  const DarkModePreviewScreen({super.key});

  @override
  State<DarkModePreviewScreen> createState() => _DarkModePreviewScreenState();
}

class _DarkModePreviewScreenState extends State<DarkModePreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _isDarkMode = false;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? AppThemeDark.getThemeData() : Theme.of(context),
      child: Scaffold(
        backgroundColor: _isDarkMode
            ? AppThemeDark.primaryBackground
            : AppTheme.primaryNavy,
        body: Stack(
          children: [
            // Electrical circuit background
            Positioned.fill(
              child: ElectricalCircuitBackground(
                opacity: 0.08,
                componentDensity: ComponentDensity.high,
                enableCurrentFlow: true,
                enableInteractiveComponents: true,
                circuitColor: _isDarkMode
                    ? AppThemeDark.electricalTrace
                    : AppTheme.electricalCircuitTrace,
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar with theme toggle
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: _isDarkMode
                        ? AppThemeDark.primaryBackground.withOpacity(0.9)
                        : AppTheme.primaryNavy.withOpacity(0.9),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Dark Mode Preview',
                        style: (_isDarkMode
                            ? AppThemeDark.headlineSmall
                            : AppTheme.headlineSmall).copyWith(
                          color: _isDarkMode
                              ? AppThemeDark.textPrimary
                              : AppTheme.white,
                          shadows: [
                            Shadow(
                              color: (_isDarkMode
                                  ? AppThemeDark.accentCopperGlow
                                  : AppTheme.accentCopper).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      centerTitle: true,
                    ),
                    leading: _buildBackButton(),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildThemeToggle(),
                      ),
                    ],
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildColorPalette(),
                        const SizedBox(height: 32),
                        _buildComponentShowcase(),
                        const SizedBox(height: 32),
                        _buildAuthPreview(),
                        const SizedBox(height: 32),
                        _buildOnboardingPreview(),
                        const SizedBox(height: 32),
                        _buildInteractiveComponents(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: _isDarkMode
          ? AppThemeDark.backButtonDecoration
          : BoxDecoration(
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopperThin,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                AppTheme.shadowElectricalInfo,
              ],
            ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _isDarkMode ? AppThemeDark.textPrimary : AppTheme.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 3.seconds, color: (_isDarkMode
          ? AppThemeDark.accentCopperGlow
          : AppTheme.accentCopper).withOpacity(0.3));
  }

  Widget _buildThemeToggle() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: (_isDarkMode
                  ? AppThemeDark.accentCopper
                  : AppTheme.accentCopper).withOpacity(_glowAnimation.value),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (_isDarkMode
                    ? AppThemeDark.accentCopperGlow
                    : AppTheme.accentCopper).withOpacity(_glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              _buildToggleOption(
                icon: Icons.light_mode,
                isSelected: !_isDarkMode,
                onTap: () => setState(() => _isDarkMode = false),
              ),
              const SizedBox(width: 4),
              _buildToggleOption(
                icon: Icons.dark_mode,
                isSelected: _isDarkMode,
                onTap: () => setState(() => _isDarkMode = true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (_isDarkMode
                  ? AppThemeDark.buttonGradient
                  : AppTheme.buttonGradient)
              : null,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (_isDarkMode
                        ? AppThemeDark.accentCopperGlow
                        : AppTheme.accentCopper).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? (_isDarkMode
                  ? AppThemeDark.textOnAccent
                  : AppTheme.white)
              : (_isDarkMode
                  ? AppThemeDark.textTertiary
                  : AppTheme.white.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _isDarkMode
          ? AppThemeDark.formContainerDecoration
          : BoxDecoration(
              color: AppTheme.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopperThin,
              ),
              boxShadow: [AppTheme.shadowElectricalInfo],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palette',
            style: (_isDarkMode
                ? AppThemeDark.headlineMedium
                : AppTheme.headlineMedium).copyWith(
              color: _isDarkMode
                  ? AppThemeDark.textPrimary
                  : AppTheme.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (_isDarkMode) ...[
                _colorChip('Background', AppThemeDark.primaryBackground),
                _colorChip('Surface', AppThemeDark.primarySurface),
                _colorChip('Copper', AppThemeDark.accentCopper),
                _colorChip('Copper Light', AppThemeDark.accentCopperLight),
                _colorChip('Copper Glow', AppThemeDark.accentCopperGlow),
                _colorChip('Text Primary', AppThemeDark.textPrimary),
                _colorChip('Text Secondary', AppThemeDark.textSecondary),
                _colorChip('Border', AppThemeDark.borderPrimary),
              ] else ...[
                _colorChip('Navy', AppTheme.primaryNavy),
                _colorChip('Copper', AppTheme.accentCopper),
                _colorChip('Secondary', AppTheme.secondaryCopper),
                _colorChip('White', AppTheme.white),
                _colorChip('Gray', AppTheme.mediumGray),
                _colorChip('Success', AppTheme.successGreen),
                _colorChip('Warning', AppTheme.warningYellow),
                _colorChip('Error', AppTheme.errorRed),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _colorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (_isDarkMode
              ? AppThemeDark.borderPrimary
              : AppTheme.borderLight).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildComponentShowcase() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _isDarkMode
          ? AppThemeDark.formContainerDecoration
          : BoxDecoration(
              color: AppTheme.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopperThin,
              ),
              boxShadow: [AppTheme.shadowElectricalInfo],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Components',
            style: (_isDarkMode
                ? AppThemeDark.headlineMedium
                : AppTheme.headlineMedium).copyWith(
              color: _isDarkMode
                  ? AppThemeDark.textPrimary
                  : AppTheme.white,
            ),
          ),
          const SizedBox(height: 24),

          // Primary Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: _isDarkMode
                ? AppThemeDark.primaryButtonDecoration
                : BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.accentCopper,
                      width: AppTheme.borderWidthCopper,
                    ),
                    boxShadow: [AppTheme.shadowElectricalSuccess],
                  ),
            child: Center(
              child: Text(
                'Primary Button',
                style: (_isDarkMode
                    ? AppThemeDark.buttonLarge
                    : AppTheme.buttonLarge).copyWith(
                  color: _isDarkMode
                      ? AppThemeDark.textOnAccent
                      : AppTheme.white,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 16),

          // Text Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: _isDarkMode
                ? AppThemeDark.textFieldDecoration
                : BoxDecoration(
                    color: AppTheme.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.accentCopper.withOpacity(0.5),
                    ),
                  ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: _isDarkMode
                      ? AppThemeDark.accentCopper
                      : AppTheme.accentCopper,
                ),
                const SizedBox(width: 12),
                Text(
                  'Email Address',
                  style: (_isDarkMode
                      ? AppThemeDark.bodyMedium
                      : AppTheme.bodyMedium).copyWith(
                    color: _isDarkMode
                        ? AppThemeDark.textTertiary
                        : AppTheme.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 16),

          // Chips
          Wrap(
            spacing: 8,
            children: [
              'Electrical', 'Industrial', 'Commercial'
            ].map((label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: _isDarkMode
                    ? AppThemeDark.buttonGradient
                    : AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isDarkMode
                      ? AppThemeDark.accentCopper
                      : AppTheme.accentCopper,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isDarkMode
                        ? AppThemeDark.accentCopperGlow
                        : AppTheme.accentCopper).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: (_isDarkMode
                    ? AppThemeDark.labelMedium
                    : AppTheme.labelMedium).copyWith(
                  color: _isDarkMode
                      ? AppThemeDark.textOnAccent
                      : AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildAuthPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _isDarkMode
          ? AppThemeDark.formContainerDecoration.copyWith(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeDark.primarySurface.withOpacity(0.5),
                  AppThemeDark.primaryBackground,
                ],
              ),
            )
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.white.withOpacity(0.03),
                  AppTheme.primaryNavy,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.accentCopper.withOpacity(0.3),
              ),
              boxShadow: [AppTheme.shadowElectricalInfo],
            ),
      child: Column(
        children: [
          // Logo with animated glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: _isDarkMode
                      ? AppThemeDark.buttonGradient
                      : AppTheme.buttonGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isDarkMode
                        ? AppThemeDark.accentCopper
                        : AppTheme.accentCopper,
                    width: AppTheme.borderWidthCopper,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isDarkMode
                          ? AppThemeDark.accentCopperGlow
                          : AppTheme.accentCopper).withOpacity(
                        0.4 + _glowAnimation.value * 0.3,
                      ),
                      blurRadius: 25 + _glowAnimation.value * 15,
                      spreadRadius: 3 + _glowAnimation.value * 5,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.electrical_services,
                  size: 50,
                  color: _isDarkMode
                      ? AppThemeDark.textOnAccent
                      : AppTheme.white,
                  shadows: [
                    Shadow(
                      color: (_isDarkMode
                          ? AppThemeDark.accentCopperGlow
                          : AppTheme.accentCopper).withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          Text(
            'Join Journeyman Jobs',
            style: (_isDarkMode
                ? AppThemeDark.displaySmall
                : AppTheme.displaySmall).copyWith(
              color: _isDarkMode
                  ? AppThemeDark.textPrimary
                  : AppTheme.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              shadows: [
                Shadow(
                  color: (_isDarkMode
                      ? AppThemeDark.navyDeep
                      : AppTheme.primaryNavy).withOpacity(0.8),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0)
      .then()
      .shimmer(
        duration: 2.seconds,
        color: (_isDarkMode
            ? AppThemeDark.accentCopperGlow
            : AppTheme.accentCopper).withOpacity(0.1),
      );
  }

  Widget _buildOnboardingPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _isDarkMode
          ? AppThemeDark.formContainerDecoration
          : BoxDecoration(
              color: AppTheme.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopperThin,
              ),
              boxShadow: [AppTheme.shadowElectricalInfo],
            ),
      child: Column(
        children: [
          Text(
            'Onboarding Progress',
            style: (_isDarkMode
                ? AppThemeDark.headlineSmall
                : AppTheme.headlineSmall).copyWith(
              color: _isDarkMode
                  ? AppThemeDark.textPrimary
                  : AppTheme.white,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar with animated fill
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: (_isDarkMode
                  ? AppThemeDark.primarySurface
                  : AppTheme.primaryNavy.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isDarkMode
                    ? AppThemeDark.accentCopper.withOpacity(0.5)
                    : AppTheme.accentCopper.withOpacity(0.5),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: constraints.maxWidth * 0.66,
                      decoration: BoxDecoration(
                        gradient: _isDarkMode
                            ? AppThemeDark.buttonGradient
                            : AppTheme.buttonGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: (_isDarkMode
                                ? AppThemeDark.accentCopperGlow
                                : AppTheme.accentCopper).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Step 2 of 3',
            style: (_isDarkMode
                ? AppThemeDark.labelMedium
                : AppTheme.labelMedium).copyWith(
              color: _isDarkMode
                  ? AppThemeDark.textSecondary
                  : AppTheme.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveComponents() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _isDarkMode
          ? AppThemeDark.formContainerDecoration
          : BoxDecoration(
              color: AppTheme.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopperThin,
              ),
              boxShadow: [AppTheme.shadowElectricalInfo],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interactive Elements',
            style: (_isDarkMode
                ? AppThemeDark.headlineMedium
                : AppTheme.headlineMedium).copyWith(
              color: _isDarkMode
                  ? AppThemeDark.textPrimary
                  : AppTheme.white,
            ),
          ),
          const SizedBox(height: 20),

          // Tab Bar with gradient animation (replica of auth screen)
          Container(
            height: 60,
            decoration: _isDarkMode
                ? AppThemeDark.tabBarDecoration
                : BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.accentCopper,
                      width: AppTheme.borderWidthCopper,
                    ),
                    boxShadow: [
                      AppTheme.shadowElectricalInfo,
                      BoxShadow(
                        color: AppTheme.accentCopper.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
            child: Stack(
              children: [
                // Animated indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 40,
                    height: 52,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: _isDarkMode
                          ? AppThemeDark.tabSelectedGradient
                          : LinearGradient(
                              colors: [
                                AppTheme.accentCopper,
                                AppTheme.secondaryCopper,
                                AppTheme.primaryNavy,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd - 4),
                      border: Border.all(
                        color: _isDarkMode
                            ? AppThemeDark.accentCopper
                            : AppTheme.accentCopper,
                        width: AppTheme.borderWidthCopper,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isDarkMode
                              ? AppThemeDark.navyDeep
                              : AppTheme.primaryNavy).withOpacity(0.3),
                          blurRadius: 35,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: (_isDarkMode
                              ? AppThemeDark.accentCopper
                              : AppTheme.accentCopper).withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab labels
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style: (_isDarkMode
                              ? AppThemeDark.labelLarge
                              : AppTheme.labelLarge).copyWith(
                            color: _isDarkMode
                                ? AppThemeDark.textPrimary
                                : AppTheme.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: (_isDarkMode
                                    ? AppThemeDark.navyDeep
                                    : AppTheme.primaryNavy).withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (_isDarkMode
                                ? AppThemeDark.accentCopper
                                : AppTheme.accentCopper).withOpacity(0.3),
                            (_isDarkMode
                                ? AppThemeDark.accentCopper
                                : AppTheme.accentCopper).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Sign In',
                          style: (_isDarkMode
                              ? AppThemeDark.labelLarge
                              : AppTheme.labelLarge).copyWith(
                            color: (_isDarkMode
                                ? AppThemeDark.textTertiary
                                : AppTheme.white.withOpacity(0.7)),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.05, end: 0),
        ],
      ),
    );
  }
}