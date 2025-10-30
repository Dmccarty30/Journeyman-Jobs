import 'package:flutter/material.dart' show Container, EdgeInsets, SizedBox, LinearProgressIndicator, AlwaysStoppedAnimation, VoidCallback, Widget, Color, StatefulWidget, Key, State, BuildContext, StatelessWidget, Text, TextStyle, MainAxisSize, Column, Colors, BorderRadius, Border, BoxDecoration, FontWeight, CrossAxisAlignment, Expanded, Row, Semantics, ConnectionState, Center, FutureBuilder, Scaffold, ListView, ListTile, ElevatedButton;
import 'package:journeyman_jobs/design_system/components/three_phase_rotation_meter.dart';

import '../app_theme.dart' show AppTheme;

/// Three-Phase Rotation Meter Integration Guide
///
/// This guide provides comprehensive documentation for integrating the
/// ThreePhaseRotationMeter widget throughout the Journeyman Jobs app.
///
/// Table of Contents:
/// 1. Quick Start
/// 2. Usage Patterns
/// 3. Performance Considerations
/// 4. Accessibility Implementation
/// 5. Integration Examples
/// 6. Troubleshooting

/// QUICK START GUIDE
/// ==================
///
/// 1. Import the widget:
/// ```dart
/// import 'package:journeyman_jobs/design_system/components/three_phase_rotation_meter.dart';
/// ```
///
/// 2. Basic usage:
/// ```dart
/// ThreePhaseRotationMeter(
///   size: 80,
///   clockwise: true,
///   duration: Duration(seconds: 2),
/// )
/// ```
///
/// 3. Themed usage:
/// ```dart
/// ThreePhaseRotationMeter(
///   size: 100,
///   colors: RotationMeterColors.ibewTheme(),
///   showSpeedIndicator: true,
/// )
/// ```

/// USAGE PATTERNS
/// ===============
///
/// Different loading contexts require different meter configurations:

/// Pattern 1: Job Search Loading
/// Use for API calls and data fetching operations
class JobSearchLoadingPattern {
  static Widget build({
    double size = 60,
    VoidCallback? onComplete,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThreePhaseRotationMeter(
          size: size,
          duration: const Duration(milliseconds: 1500),
          colors: RotationMeterColors.ibewTheme(),
          semanticLabel: 'Searching for jobs',
        ),
        const SizedBox(height: 8),
        Text(
          'Searching Jobs...',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Pattern 2: Storm Tracking Loading
/// Use for weather data and storm monitoring
/// Faster rotation for urgency indication
class StormTrackingLoadingPattern {
  static Widget build({
    double size = 80,
    bool isEmergency = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmergency ? Colors.red.withValues(alpha:0.1) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: isEmergency
          ? Border.all(color: Colors.red.withValues(alpha:0.3))
          : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThreePhaseRotationMeter(
            size: size,
            duration: Duration(milliseconds: isEmergency ? 600 : 1200),
            colors: isEmergency
              ? RotationMeterColors.copperTheme()
              : RotationMeterColors.ibewTheme(),
            showSpeedIndicator: true,
            semanticLabel: isEmergency
              ? 'Emergency storm tracking active'
              : 'Tracking storm data',
          ),
          const SizedBox(height: 8),
          Text(
            isEmergency ? '⚠️ Emergency Alert' : 'Tracking Storm',
            style: TextStyle(
              color: isEmergency ? Colors.red : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pattern 3: Data Sync Loading
/// Use for background synchronization operations
class DataSyncLoadingPattern {
  static Widget build({
    required String syncType,
    double progress = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ThreePhaseRotationMeter(
            size: 40,
            duration: const Duration(seconds: 3),
            showSpeedIndicator: true,
            colors: RotationMeterColors.copperTheme(),
            semanticLabel: 'Syncing $syncType data',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syncing $syncType',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// PERFORMANCE CONSIDERATIONS
/// ==========================
///
/// 1. Animation Performance:
///    - The meter uses CustomPainter for optimal rendering
///    - AnimationController ensures smooth 60fps performance
///    - Memory efficient with proper resource disposal
///
/// 2. Size Optimization:
///    - For sizes < 50px, consider disabling mounting holes
///    - Larger sizes (>150px) should be used sparingly
///    - Use appropriate sizing for different contexts
///
/// 3. Battery Life:
///    - Faster rotation speeds use more battery
///    - Consider reducing speed for long-running operations
///    - Auto-stop animations when not visible

/// Performance optimization helper
class PerformanceOptimizedMeter extends StatefulWidget {
  final Widget child;
  final bool visible;

  const PerformanceOptimizedMeter({
    super.key,
    required this.child,
    this.visible = true,
  });

  @override
  State<PerformanceOptimizedMeter> createState() => _PerformanceOptimizedMeterState();
}

class _PerformanceOptimizedMeterState extends State<PerformanceOptimizedMeter> {
  @override
  Widget build(BuildContext context) {
    // Only render when visible to save resources
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}

/// ACCESSIBILITY IMPLEMENTATION
/// ============================
///
/// The ThreePhaseRotationMeter includes comprehensive accessibility support:

/// Accessible wrapper for screen readers
class AccessibleRotationMeter extends StatelessWidget {
  final double size;
  final String? customLabel;
  final String? customHint;
  final bool isImportant;

  const AccessibleRotationMeter({
    super.key,
    this.size = 80,
    this.customLabel,
    this.customHint,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: customLabel ?? 'Loading indicator',
      hint: customHint ?? 'Three-phase rotation meter showing loading animation',
      value: 'Currently active',
      liveRegion: true,
      // Mark as important if this is a critical loading state
      container: isImportant,
      child: ThreePhaseRotationMeter(
        size: size,
        semanticLabel: customLabel,
      ),
    );
  }
}

/// INTEGRATION EXAMPLES
/// ====================
///
/// Real-world integration patterns for common app screens:

/// Example 1: Job Search Screen Integration
class JobSearchScreenIntegration extends StatelessWidget {
  const JobSearchScreenIntegration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search results area
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: JobSearchLoadingPattern.build(size: 100),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return _buildJobList(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _fetchJobs() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    return [];
  }

  Widget _buildJobList(List<dynamic> jobs) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text('Job ${index + 1}'));
      },
    );
  }
}

/// Example 2: Storm Tracking Integration
class StormTrackingIntegration extends StatefulWidget {
  const StormTrackingIntegration({super.key});

  @override
  State<StormTrackingIntegration> createState() => _StormTrackingIntegrationState();
}

class _StormTrackingIntegrationState extends State<StormTrackingIntegration> {
  bool _isLoading = false;
  bool _isEmergency = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
          ? StormTrackingLoadingPattern.build(
              size: 120,
              isEmergency: _isEmergency,
            )
          : ElevatedButton(
              onPressed: _startTracking,
              child: const Text('Start Storm Tracking'),
            ),
      ),
    );
  }

  void _startTracking() async {
    setState(() {
      _isLoading = true;
      _isEmergency = false;
    });

    try {
      await _trackStorm();
    } catch (e) {
      setState(() {
        _isEmergency = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _trackStorm() async {
    // Simulate storm tracking
    await Future.delayed(const Duration(seconds: 3));
  }
}

/// Example 3: Union Data Sync Integration
class UnionDataSyncIntegration extends StatefulWidget {
  const UnionDataSyncIntegration({super.key});

  @override
  State<UnionDataSyncIntegration> createState() => _UnionDataSyncIntegrationState();
}

class _UnionDataSyncIntegrationState extends State<UnionDataSyncIntegration> {
  double _syncProgress = 0.0;
  String _syncType = 'Union Locals';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DataSyncLoadingPattern.build(
          syncType: _syncType,
          progress: _syncProgress,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  void _startSync() async {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _syncProgress = i / 100.0;

        // Change sync type for demonstration
        if (i == 50) {
          _syncType = 'Job Listings';
        } else if (i == 80) {
          _syncType = 'Weather Data';
        }
      });
    }
  }
}

/// TROUBLESHOOTING
/// ================
///
/// Common issues and solutions:

/// Issue 1: Animation not starting
/// Solution: Ensure autoStart is true or call startRotation() manually
///
/// Issue 2: Poor performance on low-end devices
/// Solution: Use smaller sizes and reduce rotation speed
///
/// Issue 3: Accessibility announcements not working
/// Solution: Use the AccessibleRotationMeter wrapper or provide semanticLabel
///
/// Issue 4: Memory leaks
/// Solution: Ensure proper disposal of animation controllers (handled automatically)
///
/// Issue 5: Theme not applying correctly
/// Solution: Check that AppTheme constants are properly imported

/// Debug helper for development
class DebugRotationMeter extends StatelessWidget {
  final Widget meter;
  final String debugInfo;

  const DebugRotationMeter({
    super.key,
    required this.meter,
    this.debugInfo = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        meter,
        if (debugInfo.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              debugInfo,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }
}