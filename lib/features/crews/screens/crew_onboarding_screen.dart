import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../navigation/app_router.dart';

class CrewOnboardingScreen extends StatefulWidget {
  const CrewOnboardingScreen({super.key});

  @override
  State<CrewOnboardingScreen> createState() => _CrewOnboardingScreenState();
}

class _CrewOnboardingScreenState extends State<CrewOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
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
                child: const Icon(
                  Icons.group_work,
                  size: 60,
                  color: AppTheme.white,
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
              ),
              
              const SizedBox(height: AppTheme.spacingXl),
              
              // Title
              Text(
                'Get Started with Crews',
                style: AppTheme.displaySmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 600),
              ).slideY(
                begin: 0.2,
                end: 0,
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 600),
              ),
              
              const SizedBox(height: AppTheme.spacingMd),
              
              // Subtitle
              Text(
                'Build your crew and start collaborating',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 600),
              ).slideY(
                begin: 0.2,
                end: 0,
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 600),
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Description
              Text(
                'Create your own crew to access crew features, messaging, and job sharing. Get started below to build your team.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 600),
              ).slideY(
                begin: 0.2,
                end: 0,
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 600),
              ),
              
              const SizedBox(height: AppTheme.spacingXxl),
              
              // Create Crew Button (Primary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go(AppRouter.createCrew);
                  },
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
                  label: const Text('Next', style: TextStyle(color: AppTheme.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 1000),
                duration: const Duration(milliseconds: 600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
