import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../navigation/app_router.dart';
import '../../electrical_components/circuit_board_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      icon: Icons.electrical_services,
      title: 'Welcome to Journeyman Jobs',
      subtitle: 'Clearing the Books',
      description: 'Your gateway to IBEW electrical opportunities. Connect with electrical contractors across the nation and find your next journeyman position with ease.',
    ),
    WelcomePageData(
      icon: Icons.work,
      title: 'Find Quality Jobs',
      subtitle: 'Browse verified journeyman positions',
      description: 'Access job referrals from IBEW locals nationwide. Filter by classification, location, and pay rate.',
    ),
    WelcomePageData(
      icon: Icons.people,
      title: 'Built for Journeyman',
      subtitle: 'By Journeyman, for Journeyman',
      description: 'Streamlined job search designed specifically for IBEW members and electrical professionals.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _skipToAuth() {
    _navigateToAuth();
  }

  void _navigateToAuth() {
    context.go(AppRouter.auth);
  }

  Widget _buildCustomPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required double fontSize,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthCopper,
        ),
        boxShadow: [
          AppTheme.shadowElectricalSuccess,
          BoxShadow(
            color: AppTheme.accentCopper.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: AppTheme.white,
                  size: AppTheme.iconSm,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    text,
                    style: AppTheme.buttonMedium.copyWith(color: AppTheme.white, fontSize: fontSize),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        children: [
          // Electrical circuit background
          const Positioned.fill(
            child: ElectricalCircuitBackground(
              opacity: 0.08,
              componentDensity: ComponentDensity.high,
              enableCurrentFlow: true,
              enableInteractiveComponents: true,
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: AppTheme.accentCopper.withValues(alpha: 0.5),
                        width: AppTheme.borderWidthCopperThin,
                      ),
                    ),
                    child: TextButton(
                      onPressed: _skipToAuth,
                      child: Text(
                        'Skip',
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.accentCopper,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with animation
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppTheme.buttonGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentCopper,
                              width: AppTheme.borderWidthCopper,
                            ),
                            boxShadow: [
                              AppTheme.shadowElectricalSuccess,
                              BoxShadow(
                                color: AppTheme.accentCopper.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: AppTheme.white,
                          ),
                        )
                        .animate()
                        .scale(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                        ),
                        
                        const SizedBox(height: AppTheme.spacingXl),
                        
                        // Title
                        Text(
                          page.title,
                          style: AppTheme.displaySmall.copyWith(
                            color: AppTheme.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 600),
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 600),
                        ),
                        
                        const SizedBox(height: AppTheme.spacingMd),
                        
                        // Subtitle
                        Text(
                          page.subtitle,
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.accentCopper,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 600),
                          duration: const Duration(milliseconds: 600),
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: const Duration(milliseconds: 600),
                          duration: const Duration(milliseconds: 600),
                        ),
                        
                        const SizedBox(height: AppTheme.spacingLg),
                        
                        // Description
                        Text(
                          page.description,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom section with progress and navigation
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.accentCopper
                              : AppTheme.lightGray.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: _currentPage == index
                              ? Border.all(
                                  color: AppTheme.accentCopper,
                                  width: AppTheme.borderWidthCopperThin,
                                )
                              : null,
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: AppTheme.accentCopper.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      )
                      .animate()
                      .scale(
                        duration: const Duration(milliseconds: 200),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXl),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      // Back button (hidden on first page)
                      if (_currentPage > 0)
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(
                                color: AppTheme.accentCopper,
                                width: AppTheme.borderWidthCopperThin,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingLg,
                                    vertical: AppTheme.spacingMd,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        color: AppTheme.accentCopper,
                                        size: AppTheme.iconSm,
                                      ),
                                      const SizedBox(width: AppTheme.spacingSm),
                                      Text(
                                        'Back',
                                        style: AppTheme.buttonMedium.copyWith(
                                          color: AppTheme.accentCopper,
                                          fontSize: AppTheme.buttonMedium.fontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      
                      const SizedBox(width: AppTheme.spacingMd),
                      
                      // Next/Get Started button
                      Expanded(
                        child: _currentPage == _pages.length - 1
                            ? _buildCustomPrimaryButton(
                                text: 'Get Started',
                                icon: Icons.arrow_forward,
                                onPressed: _nextPage,
                                fontSize: AppTheme.buttonMedium.fontSize! * 0.85,
                              )
                            : Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.buttonGradient,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(
                                    color: AppTheme.accentCopper,
                                    width: AppTheme.borderWidthCopper,
                                  ),
                                  boxShadow: [
                                    AppTheme.shadowElectricalInfo,
                                    BoxShadow(
                                      color: AppTheme.accentCopper.withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _nextPage,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacingLg,
                                        vertical: AppTheme.spacingMd,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppTheme.white,
                                            size: AppTheme.iconSm,
                                          ),
                                          const SizedBox(width: AppTheme.spacingSm),
                                          Text(
                                            'Next',
                                            style: AppTheme.buttonMedium.copyWith(
                                              color: AppTheme.white,
                                              fontSize: AppTheme.buttonMedium.fontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  WelcomePageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
