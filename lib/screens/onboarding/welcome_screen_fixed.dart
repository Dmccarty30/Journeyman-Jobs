import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../electrical_components/components.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.splashGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    const CircuitPatternBackground(),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          JJElectricalLogo(size: 120),
                          const SizedBox(height: 24),
                          Text(
                            'Journeyman Jobs',
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'IBEW Jobs. Real Workers. Real Opportunities.',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      JJPrimaryButton(
                        text: 'Create Account',
                        size: ButtonSize.large,
                        onPressed: () => context.go('/onboarding'),
                      ),
                      const SizedBox(height: 16),
                      JJSecondaryButton(
                        text: 'Sign In',
                        size: ButtonSize.large,
                        onPressed: () => context.go('/signin'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Join thousands of IBEW electricians finding quality work',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}