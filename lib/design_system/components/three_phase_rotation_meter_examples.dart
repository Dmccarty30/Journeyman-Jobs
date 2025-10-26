import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import 'three_phase_rotation_meter.dart';

/// Example implementations demonstrating various uses of ThreePhaseRotationMeter
/// throughout the Journeyman Jobs app. Shows different configurations for
/// different loading contexts and screen types.
class ThreePhaseRotationMeterExamples extends StatelessWidget {
  const ThreePhaseRotationMeterExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Rotation Meter Examples'),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Loading States'),
            _buildBasicExamples(),
            const SizedBox(height: 32),
            _buildSectionTitle('Themed Variations'),
            _buildThemedExamples(),
            const SizedBox(height: 32),
            _buildSectionTitle('Size Variations'),
            _buildSizeExamples(),
            const SizedBox(height: 32),
            _buildSectionTitle('Interactive Controls'),
            _buildInteractiveExample(),
            const SizedBox(height: 32),
            _buildSectionTitle('Real-world Integration'),
            _buildRealWorldExamples(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accentCopper,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBasicExamples() {
    return Card(
      color: AppTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Standard Loading',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExampleCard(
                  'Clockwise',
                  ThreePhaseRotationMeter(
                    size: 60,
                    clockwise: true,
                    duration: const Duration(seconds: 2),
                  ),
                ),
                _buildExampleCard(
                  'Counter-clockwise',
                  ThreePhaseRotationMeter(
                    size: 60,
                    clockwise: false,
                    duration: const Duration(seconds: 2),
                  ),
                ),
                _buildExampleCard(
                  'Fast Rotation',
                  ThreePhaseRotationMeter(
                    size: 60,
                    clockwise: true,
                    duration: const Duration(seconds: 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedExamples() {
    return Card(
      color: AppTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Color Themes',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExampleCard(
                  'IBEW Navy',
                  ThreePhaseRotationMeter(
                    size: 60,
                    colors: RotationMeterColors.ibewTheme(),
                  ),
                ),
                _buildExampleCard(
                  'IBEW Copper',
                  ThreePhaseRotationMeter(
                    size: 60,
                    colors: RotationMeterColors.copperTheme(),
                  ),
                ),
                _buildExampleCard(
                  'With Speed',
                  ThreePhaseRotationMeter(
                    size: 60,
                    showSpeedIndicator: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeExamples() {
    return Card(
      color: AppTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Size Variations',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExampleCard(
                  'Small\n(40px)',
                  ThreePhaseRotationMeter(
                    size: 40,
                    showMountingHoles: false, // Too small to see holes clearly
                  ),
                ),
                _buildExampleCard(
                  'Medium\n(80px)',
                  ThreePhaseRotationMeter(size: 80),
                ),
                _buildExampleCard(
                  'Large\n(120px)',
                  ThreePhaseRotationMeter(size: 120),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveExample() {
    return InteractiveRotationMeterDemo();
  }

  Widget _buildRealWorldExamples() {
    return Card(
      color: AppTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-world Usage Examples',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildJobSearchLoadingExample(),
            const SizedBox(height: 16),
            _buildStormTrackingExample(),
            const SizedBox(height: 16),
            _buildUnionDataSyncExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSearchLoadingExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const ThreePhaseRotationMeter(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Searching Jobs',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Scanning union job boards...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStormTrackingExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ThreePhaseRotationMeter(
            size: 40,
            colors: RotationMeterColors.copperTheme(),
            duration: const Duration(milliseconds: 800), // Faster for urgency
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Storm',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Updating radar data...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnionDataSyncExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ThreePhaseRotationMeter(
            size: 40,
            showSpeedIndicator: true,
            duration: const Duration(seconds: 3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syncing Union Data',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Updating 797+ IBEW locals...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String label, Widget meter) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: meter,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Interactive demo showing rotation meter controls
class InteractiveRotationMeterDemo extends StatefulWidget {
  const InteractiveRotationMeterDemo({Key? key}) : super(key: key);

  @override
  State<InteractiveRotationMeterDemo> createState() => _InteractiveRotationMeterDemoState();
}

class _InteractiveRotationMeterDemoState extends State<InteractiveRotationMeterDemo>
    with TickerProviderStateMixin {
  bool _isRunning = true;
  bool _clockwise = true;
  double _speed = 2.0; // seconds per rotation
  bool _showHoles = true;
  bool _showSpeed = false;
  RotationMeterColors _colors = RotationMeterColors.ibewTheme();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Interactive Controls',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // The meter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ThreePhaseRotationMeter(
                key: ValueKey(_isRunning),
                size: 80,
                clockwise: _clockwise,
                duration: Duration(seconds: _speed.round()),
                autoStart: _isRunning,
                showMountingHoles: _showHoles,
                showSpeedIndicator: _showSpeed,
                colors: _colors,
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isRunning = !_isRunning),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.red : Colors.green,
                  ),
                  child: Text(_isRunning ? 'Stop' : 'Start'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _clockwise = !_clockwise),
                  child: Text(_clockwise ? 'Reverse' : 'Forward'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _showHoles = !_showHoles),
                  child: Text(_showHoles ? 'Hide Holes' : 'Show Holes'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _showSpeed = !_showSpeed),
                  child: Text(_showSpeed ? 'Hide Speed' : 'Show Speed'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Speed slider
            Row(
              children: [
                Text(
                  'Speed:',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: 0.5,
                    max: 5.0,
                    divisions: 9,
                    onChanged: (value) => setState(() => _speed = value),
                  ),
                ),
                Text(
                  '${_speed.toStringAsFixed(1)}s',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),

            // Theme selector
            Row(
              children: [
                Text(
                  'Theme:',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 8),
                DropdownButton<RotationMeterColors>(
                  value: _colors,
                  items: const [
                    DropdownMenuItem(
                      value: RotationMeterColors.ibewTheme(),
                      child: Text('IBEW Navy'),
                    ),
                    DropdownMenuItem(
                      value: RotationMeterColors.copperTheme(),
                      child: Text('IBEW Copper'),
                    ),
                  ],
                  onChanged: (colors) {
                    if (colors != null) setState(() => _colors = colors);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}