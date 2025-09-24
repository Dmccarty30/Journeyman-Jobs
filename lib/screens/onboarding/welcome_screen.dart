import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../navigation/app_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipToAuth,
                    child: Text(
                      'Skip',
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.textSecondary,
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
                            boxShadow: [AppTheme.shadowMd],
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
                            color: AppTheme.primaryNavy,
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
                              : AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(4),
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
                          child: JJSecondaryButton(
                            'Back', // Added required positional argument
                            text: 'Back',
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      
                      const SizedBox(width: AppTheme.spacingMd),
                      
                      // Next/Get Started button
                      Expanded(
                        child: JJPrimaryButton(
                          text: _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          icon: _currentPage == _pages.length - 1
                              ? Icons.arrow_forward
                              : Icons.arrow_forward_ios,
                          onPressed: _nextPage,
                          variant: JJButtonVariant.primary,
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