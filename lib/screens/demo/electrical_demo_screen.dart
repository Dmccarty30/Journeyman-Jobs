import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

/// Demo screen to showcase all electrical components
/// This screen demonstrates the integrated electrical components library
class ElectricalDemoScreen extends StatefulWidget {
  const ElectricalDemoScreen({super.key});

  @override
  State<ElectricalDemoScreen> createState() => _ElectricalDemoScreenState();
}

class _ElectricalDemoScreenState extends State<ElectricalDemoScreen> {
  bool _circuitBreakerToggle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Electrical Components Demo',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction card
            JJCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Electrical Components Library',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'This demo showcases the integrated electrical components with AppTheme colors and styling.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Loading Indicators Section
            Text(
              'Loading Indicators',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Standard JJ Loading Indicator (now electrical)
            JJCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JJ Loading Indicator (Electrical Meter)',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Center(
                    child: JJLoadingIndicator(
                      message: 'Processing electrical data...',
                    ),
                  ),
                ],
              ),
            ),

            // Three-Phase Loader
            JJCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Three-Phase Sine Wave Loader',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Center(
                    child: JJElectricalLoader(
                      width: 250,
                      height: 60,
                      message: 'Syncing electrical phases...',
                    ),
                  ),
                ],
              ),
            ),

            // Power Line Loader
            JJCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Power Line Transmission Loader',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Center(
                    child: JJPowerLineLoader(
                      width: 280,
                      height: 80,
                      message: 'Transmitting power...',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Interactive Components Section
            Text(
              'Interactive Components',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Circuit Breaker Toggle
            JJCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Circuit Breaker Toggle',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    children: [
                      Text(
                        'Main Power:',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      JJElectricalToggle(
                        isOn: _circuitBreakerToggle,
                        onChanged: (value) {
                          setState(() {
                            _circuitBreakerToggle = value;
                          });
                        },
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Text(
                        _circuitBreakerToggle ? 'ON' : 'OFF',
                        style: AppTheme.labelMedium.copyWith(
                          color: _circuitBreakerToggle 
                              ? AppTheme.successGreen 
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Icons Section
            Text(
              'Electrical Icons',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            JJCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Industry Safety & Infrastructure Icons',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Center(
                              child: JJElectricalIcons.hardHat(
                                size: 48,
                                color: AppTheme.accentCopper,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Hard Hat',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Center(
                              child: JJElectricalIcons.transmissionTower(
                                size: 48,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Transmission\nTower',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Integration Status
            JJCard(
              backgroundColor: AppTheme.successGreen.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: AppTheme.iconMd,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Integration Complete',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'All electrical components have been successfully integrated into the Journeyman Jobs app with proper AppTheme styling and electrical industry theming.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
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
}