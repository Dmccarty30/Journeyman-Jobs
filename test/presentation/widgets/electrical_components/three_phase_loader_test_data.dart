import 'package:flutter/material.dart';
import 'package:journeyman_jobs/electrical_components/three_phase_sine_wave_loader.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Test data and mock utilities for ThreePhaseSineWaveLoader testing
///
/// Provides realistic test scenarios, mock configurations, and validation
/// utilities specific to electrical industry requirements and three-phase power systems.
class ThreePhaseLoaderTestData {

  // Standard electrical three-phase color configurations
  static const Map<String, ThreePhaseColors> standardColorSchemes = {
    'IEC_Standard': ThreePhaseColors(
      phase1: Color(0xFFB45309), // Brown/Copper (L1)
      phase2: Color(0xFF000000), // Black (L2)
      phase3: Color(0xFF0000FF), // Blue (L3)
    ),
    'US_Standard': ThreePhaseColors(
      phase1: Color(0xFFB45309), // Orange/Copper (A phase)
      phase2: Color(0xFF3182CE), // Blue (B phase)
      phase3: Color(0xFF38A169), // Green (C phase)
    ),
    'App_Theme': ThreePhaseColors(
      phase1: AppTheme.accentCopper,
      phase2: AppTheme.primaryNavy,
      phase3: AppTheme.successGreen,
    ),
    'High_Contrast': ThreePhaseColors(
      phase1: Color(0xFFFF9500), // Bright Orange
      phase2: Color(0xFF007AFF), // Bright Blue
      phase3: Color(0xFF34C759), // Bright Green
    ),
  };

  // Performance testing configurations
  static const List<LoaderConfiguration> performanceConfigs = [
    LoaderConfiguration(
      name: 'Default',
      width: 200,
      height: 60,
      duration: Duration(milliseconds: 2000),
      description: 'Standard configuration for most use cases',
    ),
    LoaderConfiguration(
      name: 'Small_Inline',
      width: 80,
      height: 25,
      duration: Duration(milliseconds: 1500),
      description: 'Small loader for inline loading indicators',
    ),
    LoaderConfiguration(
      name: 'Large_FullScreen',
      width: 400,
      height: 120,
      duration: Duration(milliseconds: 3000),
      description: 'Large loader for full-screen loading',
    ),
    LoaderConfiguration(
      name: 'Minimal',
      width: 40,
      height: 15,
      duration: Duration(milliseconds: 1000),
      description: 'Minimal loader for tight spaces',
    ),
    LoaderConfiguration(
      name: 'Extended',
      width: 600,
      height: 180,
      duration: Duration(milliseconds: 5000),
      description: 'Extended loader for long operations',
    ),
  ];

  // Edge case configurations
  static const List<LoaderConfiguration> edgeCaseConfigs = [
    LoaderConfiguration(
      name: 'Zero_Size',
      width: 0,
      height: 0,
      duration: Duration(milliseconds: 2000),
      description: 'Zero dimensions - should handle gracefully',
    ),
    LoaderConfiguration(
      name: 'Minimum_Size',
      width: 1,
      height: 1,
      duration: Duration(milliseconds: 2000),
      description: 'Minimum possible size',
    ),
    LoaderConfiguration(
      name: 'Maximum_Size',
      width: 2000,
      height: 1000,
      duration: Duration(milliseconds: 2000),
      description: 'Very large size - should handle efficiently',
    ),
    LoaderConfiguration(
      name: 'Zero_Duration',
      width: 200,
      height: 60,
      duration: Duration.zero,
      description: 'Zero animation duration',
    ),
    LoaderConfiguration(
      name: 'Long_Duration',
      width: 200,
      height: 60,
      duration: Duration(minutes: 10),
      description: 'Very long animation duration',
    ),
    LoaderConfiguration(
      name: 'Ultra_Fast',
      width: 200,
      height: 60,
      duration: Duration(milliseconds: 100),
      description: 'Extremely fast animation',
    ),
  ];

  // Real-world usage scenarios
  static const List<LoadingScenario> realisticScenarios = [
    LoadingScenario(
      name: 'Firebase_Data_Load',
      context: 'Loading user data from Firestore',
      expectedDuration: Duration(milliseconds: 2000),
      config: LoaderConfiguration(
        name: 'Firebase_Load',
        width: 150,
        height: 45,
        duration: Duration(milliseconds: 2000),
      ),
    ),
    LoadingScenario(
      name: 'Job_Search',
      context: 'Searching for electrical jobs',
      expectedDuration: Duration(milliseconds: 3000),
      config: LoaderConfiguration(
        name: 'Job_Search',
        width: 250,
        height: 75,
        duration: Duration(milliseconds: 3000),
      ),
    ),
    LoadingScenario(
      name: 'Union_Directory_Load',
      context: 'Loading IBEW local directory',
      expectedDuration: Duration(milliseconds: 1500),
      config: LoaderConfiguration(
        name: 'Union_Load',
        width: 200,
        height: 60,
        duration: Duration(milliseconds: 1500),
      ),
    ),
    LoadingScenario(
      name: 'Weather_Data_Fetch',
      context: 'Fetching storm weather data',
      expectedDuration: Duration(milliseconds: 2500),
      config: LoaderConfiguration(
        name: 'Weather_Load',
        width: 180,
        height: 55,
        duration: Duration(milliseconds: 2500),
      ),
    ),
    LoadingScenario(
      name: 'Crew_Sync',
      context: 'Synchronizing crew data',
      expectedDuration: Duration(milliseconds: 4000),
      config: LoaderConfiguration(
        name: 'Crew_Sync',
        width: 220,
        height: 65,
        duration: Duration(milliseconds: 4000),
      ),
    ),
  ];

  // Mock widget builders
  static Widget buildStandardLoader({Key? key}) {
    return const ThreePhaseSineWaveLoader(
      key: key,
      width: 200,
      height: 60,
      duration: Duration(milliseconds: 2000),
    );
  }

  static Widget buildCustomLoader({
    Key? key,
    double width = 200,
    double height = 60,
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Duration? duration,
  }) {
    return ThreePhaseSineWaveLoader(
      key: key,
      width: width,
      height: height,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      duration: duration ?? const Duration(milliseconds: 2000),
    );
  }

  static Widget buildElectricalPanelLoader({Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'THREE-PHASE POWER MONITOR',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const ThreePhaseSineWaveLoader(
            width: 300,
            height: 90,
            primaryColor: Color(0xFFFF9500), // Bright Orange
            secondaryColor: Color(0xFF007AFF), // Bright Blue
            tertiaryColor: Color(0xFF34C759), // Bright Green
            duration: Duration(milliseconds: 2000),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('L1', style: TextStyle(color: Colors.orange, fontSize: 12)),
              Text('L2', style: TextStyle(color: Colors.blue, fontSize: 12)),
              Text('L3', style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildMultiLoaderGrid({int count = 12}) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(
            child: ThreePhaseSineWaveLoader(
              width: 80,
              height: 25,
              duration: Duration(milliseconds: 1500),
            ),
          ),
        );
      },
    );
  }

  // Validation utilities
  static bool isValidThreePhaseConfiguration(ThreePhaseSineWaveLoader loader) {
    return loader.width > 0 &&
           loader.height > 0 &&
           loader.duration.inMilliseconds > 0 &&
           loader.primaryColor != null &&
           loader.secondaryColor != null &&
           loader.tertiaryColor != null;
  }

  static bool isElectricalIndustryCompliant({
    required Color phase1,
    required Color phase2,
    required Color phase3,
  }) {
    // Check if colors match electrical industry standards
    final validPhase1Colors = [
      const Color(0xFFB45309), // Copper
      const Color(0xFF92400E), // Brown
      const Color(0xFFD97706), // Amber
      Colors.orange,
    ];

    final validPhase2Colors = [
      const Color(0xFF3182CE), // Blue
      const Color(0xFF2563EB), // Dark Blue
      Colors.black,
      const Color(0xFF6B7280), // Gray
    ];

    final validPhase3Colors = [
      const Color(0xFF38A169), // Green
      const Color(0xFF10B981), // Emerald
      Colors.red,
      const Color(0xFFDC2626), // Dark Red
    ];

    return validPhase1Colors.any((color) => _colorMatch(color, phase1)) &&
           validPhase2Colors.any((color) => _colorMatch(color, phase2)) &&
           validPhase3Colors.any((color) => _colorMatch(color, phase3));
  }

  static bool _colorMatch(Color a, Color b) {
    return a.value == b.value;
  }

  // Performance test data
  static List<Widget> createPerformanceTestWidgets() {
    return [
      // Single instance
      buildStandardLoader(key: const Key('single')),

      // Multiple instances (performance stress test)
      ...List.generate(20, (index) =>
        buildStandardLoader(key: Key('multi-$index'))),

      // Different sizes
      buildCustomLoader(
        key: const Key('small'),
        width: 50,
        height: 15,
      ),
      buildCustomLoader(
        key: const Key('medium'),
        width: 150,
        height: 45,
      ),
      buildCustomLoader(
        key: const Key('large'),
        width: 400,
        height: 120,
      ),

      // Different durations
      buildCustomLoader(
        key: const Key('fast'),
        duration: const Duration(milliseconds: 500),
      ),
      buildCustomLoader(
        key: const Key('slow'),
        duration: const Duration(seconds: 5),
      ),
    ];
  }

  // Accessibility test data
  static Widget buildAccessibilityTestLoader({
    required String semanticLabel,
    bool reducedMotion = false,
    bool highContrast = false,
  }) {
    final loader = buildStandardLoader();

    return Semantics(
      label: semanticLabel,
      child: loader,
    );
  }

  // Mock scenarios for integration testing
  static Widget buildFirebaseLoadingScenario() {
    return Column(
      children: [
        const Text('Loading Job Data...'),
        const SizedBox(height: 16),
        buildStandardLoader(),
        const SizedBox(height: 8),
        const Text(
          'Retrieving available electrical positions',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  static Widget buildJobSearchScenario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Searching IBEW Job Listings...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const ThreePhaseSineWaveLoader(
            width: 250,
            height: 75,
          ),
          const SizedBox(height: 12),
          Text(
            'Finding positions matching your skills',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  static Widget buildCrewSyncScenario() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy.withValues(alpha: 0.1),
            AppTheme.accentCopper.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.people_alt,
            size: 48,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(height: 16),
          const Text(
            'Syncing Crew Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          const ThreePhaseSineWaveLoader(
            width: 200,
            height: 60,
            duration: Duration(milliseconds: 3000),
          ),
          const SizedBox(height: 12),
          Text(
            'Updating member availability',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data classes for test configurations
class ThreePhaseColors {
  final Color phase1;
  final Color phase2;
  final Color phase3;

  const ThreePhaseColors({
    required this.phase1,
    required this.phase2,
    required this.phase3,
  });
}

class LoaderConfiguration {
  final String name;
  final double width;
  final double height;
  final Duration duration;
  final String description;

  const LoaderConfiguration({
    required this.name,
    required this.width,
    required this.height,
    required this.duration,
    required this.description,
  });
}

class LoadingScenario {
  final String name;
  final String context;
  final Duration expectedDuration;
  final LoaderConfiguration config;

  const LoadingScenario({
    required this.name,
    required this.context,
    required this.expectedDuration,
    required this.config,
  });
}

/// Mock electrical data for testing
class MockElectricalData {
  static const List<Map<String, dynamic>> threePhaseReadings = [
    {
      'timestamp': '2025-01-20T10:00:00Z',
      'phase1_voltage': 120.0,
      'phase2_voltage': 120.0,
      'phase3_voltage': 120.0,
      'phase1_current': 15.5,
      'phase2_current': 16.2,
      'phase3_current': 14.8,
      'frequency': 60.0,
      'power_factor': 0.95,
    },
    {
      'timestamp': '2025-01-20T10:01:00Z',
      'phase1_voltage': 119.8,
      'phase2_voltage': 120.2,
      'phase3_voltage': 119.9,
      'phase1_current': 16.1,
      'phase2_current': 15.9,
      'phase3_current': 15.3,
      'frequency': 59.98,
      'power_factor': 0.94,
    },
  ];

  static const Map<String, String> electricalTerms = {
    'L1': 'Phase 1 - Line 1',
    'L2': 'Phase 2 - Line 2',
    'L3': 'Phase 3 - Line 3',
    'N': 'Neutral',
    'G': 'Ground',
    'Hz': 'Hertz - Frequency',
    'V': 'Volts - Voltage',
    'A': 'Amperes - Current',
    'kW': 'Kilowatts - Power',
    'PF': 'Power Factor',
  };

  static const Map<String, dynamic> electricalSystemSpecs = {
    'system_type': 'Three-Phase AC',
    'voltage_level': '120/208V',
    'frequency': '60 Hz',
    'phase_angle': '120°',
    'connection_type': 'Wye (Star)',
    'grounding': 'Solidly Grounded',
    'protection': 'Circuit Breakers',
    'monitoring': 'Digital Meters',
  };
}