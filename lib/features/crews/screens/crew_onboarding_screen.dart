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
                'Join the team or build your own',
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
                'Whether you want to create your own crew or join an existing one, get started below to access crew features, messaging, and job sharing.',
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
              
              const SizedBox(height: AppTheme.spacingXl),
              
              // Create Crew Button (Primary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go(AppRouter.createCrew);
                  },
                  icon: const Icon(Icons.add, color: AppTheme.white),
                  label: const Text('Create a Crew', style: TextStyle(color: AppTheme.white)),
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
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Join Crew Button (Outlined)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.go(AppRouter.joinCrew);
                  },
                  icon: const Icon(Icons.group_add, color: AppTheme.accentCopper),
                  label: const Text('Join a Crew', style: TextStyle(color: AppTheme.accentCopper)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentCopper,
                    side: BorderSide(color: AppTheme.accentCopper, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 1200),
                duration: const Duration(milliseconds: 600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
