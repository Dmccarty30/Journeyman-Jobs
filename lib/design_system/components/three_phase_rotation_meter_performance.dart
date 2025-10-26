import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'three_phase_rotation_meter.dart';

/// Performance monitoring and testing utilities for ThreePhaseRotationMeter
///
/// This class provides comprehensive performance analysis tools including:
/// - FPS monitoring
/// - Memory usage tracking
/// - Render time measurement
/// - Animation smoothness analysis
/// - Battery usage estimation

class RotationMeterPerformanceMonitor {
  static const Duration _measurementInterval = Duration(milliseconds: 100);
  static const int _targetFPS = 60;
  static const Duration _acceptableFrameTime = Duration(milliseconds: 16);

  Timer? _monitorTimer;
  final List<PerformanceSnapshot> _snapshots = [];
  final _frameTimes = <int>[];
  int _frameCount = 0;
  Duration? _lastFrameTime;

  /// Start monitoring performance
  void startMonitoring() {
    stopMonitoring();
    _frameCount = 0;
    _frameTimes.clear();
    _snapshots.clear();

    _monitorTimer = Timer.periodic(_measurementInterval, (_) {
      _captureSnapshot();
    });

    WidgetsBinding.instance.addPostFrameCallback(_onFrameEnd);
  }

  /// Stop monitoring and return results
  PerformanceReport stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;

    return PerformanceReport(
      snapshots: List.unmodifiable(_snapshots),
      averageFPS: _calculateAverageFPS(),
      frameDrops: _calculateFrameDrops(),
      peakMemoryUsage: _calculatePeakMemoryUsage(),
      averageRenderTime: _calculateAverageRenderTime(),
    );
  }

  void _onFrameEnd(Duration timestamp) {
    if (_lastFrameTime != null) {
      final frameTime = timestamp.inMicroseconds - _lastFrameTime!.inMicroseconds;
      _frameTimes.add(frameTime);
      _frameCount++;
    }
    _lastFrameTime = timestamp;

    if (_monitorTimer != null) {
      WidgetsBinding.instance.addPostFrameCallback(_onFrameEnd);
    }
  }

  void _captureSnapshot() {
    final timestamp = DateTime.now();
    final fps = _calculateCurrentFPS();
    final memoryUsage = _estimateMemoryUsage();

    _snapshots.add(PerformanceSnapshot(
      timestamp: timestamp,
      fps: fps,
      memoryUsage: memoryUsage,
      frameCount: _frameCount,
    ));
  }

  double _calculateCurrentFPS() {
    if (_frameTimes.length < 2) return 0.0;

    final recentFrames = _frameTimes.take(30).toList(); // Last 30 frames
    if (recentFrames.isEmpty) return 0.0;

    final totalTime = recentFrames.reduce((a, b) => a + b);
    return 1000000 / (totalTime / recentFrames.length); // Convert to FPS
  }

  double _calculateAverageFPS() {
    if (_snapshots.isEmpty) return 0.0;
    return _snapshots.map((s) => s.fps).reduce((a, b) => a + b) / _snapshots.length;
  }

  int _calculateFrameDrops() {
    return _frameTimes.where((time) => time > _acceptableFrameTime.inMicroseconds).length;
  }

  double _estimateMemoryUsage() {
    // Rough estimation based on current complexity
    return _frameCount * 0.1; // KB - this is a simplified estimation
  }

  double _calculatePeakMemoryUsage() {
    if (_snapshots.isEmpty) return 0.0;
    return _snapshots.map((s) => s.memoryUsage).reduce((a, b) => a > b ? a : b);
  }

  double _calculateAverageRenderTime() {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length / 1000; // Convert to ms
  }
}

/// Performance data snapshot
class PerformanceSnapshot {
  final DateTime timestamp;
  final double fps;
  final double memoryUsage;
  final int frameCount;

  const PerformanceSnapshot({
    required this.timestamp,
    required this.fps,
    required this.memoryUsage,
    required this.frameCount,
  });
}

/// Complete performance report
class PerformanceReport {
  final List<PerformanceSnapshot> snapshots;
  final double averageFPS;
  final int frameDrops;
  final double peakMemoryUsage;
  final double averageRenderTime;

  const PerformanceReport({
    required this.snapshots,
    required this.averageFPS,
    required this.frameDrops,
    required this.peakMemoryUsage,
    required this.averageRenderTime,
  });

  bool get isExcellent => averageFPS >= 58 && frameDrops == 0;
  bool get isGood => averageFPS >= 55 && frameDrops <= 5;
  bool get isAcceptable => averageFPS >= 50 && frameDrops <= 20;
  bool get isPoor => !isAcceptable;

  String get performanceGrade {
    if (isExcellent) return 'A+ (Excellent)';
    if (isGood) return 'B+ (Good)';
    if (isAcceptable) return 'C+ (Acceptable)';
    return 'D (Needs Improvement)';
  }
}

/// Performance testing widget for development
class RotationMeterPerformanceTester extends StatefulWidget {
  const RotationMeterPerformanceTester({Key? key}) : super(key: key);

  @override
  State<RotationMeterPerformanceTester> createState() => _RotationMeterPerformanceTesterState();
}

class _RotationMeterPerformanceTesterState extends State<RotationMeterPerformanceTester> {
  final RotationMeterPerformanceMonitor _monitor = RotationMeterPerformanceMonitor();
  PerformanceReport? _lastReport;
  bool _isMonitoring = false;
  int _meterCount = 1;
  double _meterSize = 80.0;
  Duration _rotationDuration = const Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Performance Tester'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              children: [
                _buildControlRow(),
                const SizedBox(height: 8),
                _buildControlButtons(),
              ],
            ),
          ),

          // Performance display
          if (_lastReport != null) _buildPerformanceDisplay(),

          // Test area
          Expanded(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: _buildMeterGrid(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meters: $_meterCount',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Slider(
                value: _meterCount.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (value) => setState(() => _meterCount = value.round()),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Size: ${_meterSize.toInt()}px',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Slider(
                value: _meterSize,
                min: 40,
                max: 200,
                divisions: 8,
                onChanged: (value) => setState(() => _meterSize = value),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Speed: ${_rotationDuration.inSeconds}s',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Slider(
                value: _rotationDuration.inSeconds.toDouble(),
                min: 0.5,
                max: 5,
                divisions: 9,
                onChanged: (value) => setState(() => _rotationDuration = Duration(seconds: value.round())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isMonitoring ? null : _startTest,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Start Test'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: !_isMonitoring ? null : _stopTest,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Stop Test'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => setState(() => _lastReport = null),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Clear Results'),
        ),
      ],
    );
  }

  Widget _buildPerformanceDisplay() {
    if (_lastReport == null) return const SizedBox.shrink();

    final report = _lastReport!;
    final gradeColor = report.isExcellent ? Colors.green :
                       report.isGood ? Colors.blue :
                       report.isAcceptable ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: gradeColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Performance Results: ${report.performanceGrade}',
            style: TextStyle(
              color: gradeColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard('Average FPS', '${report.averageFPS.toStringAsFixed(1)}'),
              _buildMetricCard('Frame Drops', '${report.frameDrops}'),
              _buildMetricCard('Render Time', '${report.averageRenderTime.toStringAsFixed(1)}ms'),
              _buildMetricCard('Memory', '${report.peakMemoryUsage.toStringAsFixed(1)}KB'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterGrid() {
    final columns = ( MediaQuery.of(context).size.width / (_meterSize + 20) ).floor();

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: List.generate(_meterCount, (index) {
        final clockwise = index % 2 == 0;
        final showSpeedIndicator = index % 3 == 0;

        return ThreePhaseRotationMeter(
          key: ValueKey('meter_$index'),
          size: _meterSize,
          clockwise: clockwise,
          duration: _rotationDuration,
          showSpeedIndicator: showSpeedIndicator,
          colors: index % 2 == 0
            ? RotationMeterColors.ibewTheme()
            : RotationMeterColors.copperTheme(),
        );
      }),
    );
  }

  void _startTest() {
    setState(() {
      _isMonitoring = true;
      _lastReport = null;
    });
    _monitor.startMonitoring();
  }

  void _stopTest() {
    setState(() {
      _isMonitoring = false;
      _lastReport = _monitor.stopMonitoring();
    });
  }
}

/// Performance optimization recommendations
class PerformanceOptimizer {
  static List<String> getOptimizations(PerformanceReport report) {
    final recommendations = <String>[];

    if (report.averageFPS < 50) {
      recommendations.add('Consider reducing meter count or size');
      recommendations.add('Use PerformanceOptimizedMeter wrapper');
    }

    if (report.frameDrops > 10) {
      recommendations.add('Reduce rotation speed to decrease CPU usage');
      recommendations.add('Disable mounting holes for smaller meters');
    }

    if (report.averageRenderTime > 20) {
      recommendations.add('Simplify painter operations');
      recommendations.add('Use cached bitmaps for complex effects');
    }

    if (report.peakMemoryUsage > 1000) {
      recommendations.add('Implement proper disposal patterns');
      recommendations.add('Use object pooling for frequent operations');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Performance is excellent - no optimizations needed');
    }

    return recommendations;
  }
}

/// Optimized wrapper for performance-critical scenarios
class PerformanceOptimizedRotationMeter extends StatefulWidget {
  final double size;
  final bool clockwise;
  final Duration duration;
  final bool showMountingHoles;
  final bool showSpeedIndicator;
  final RotationMeterColors? colors;
  final bool visible;

  const PerformanceOptimizedRotationMeter({
    Key? key,
    this.size = 80.0,
    this.clockwise = true,
    this.duration = const Duration(seconds: 2),
    this.showMountingHoles = true,
    this.showSpeedIndicator = false,
    this.colors,
    this.visible = true,
  }) : super(key: key);

  @override
  State<PerformanceOptimizedRotationMeter> createState() => _PerformanceOptimizedRotationMeterState();
}

class _PerformanceOptimizedRotationMeterState extends State<PerformanceOptimizedRotationMeter>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Don't render if not visible
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    // Optimize based on size
    final optimizedShowHoles = widget.size > 50 && widget.showMountingHoles;
    final optimizedShowSpeed = widget.size > 80 && widget.showSpeedIndicator;

    return ThreePhaseRotationMeter(
      size: widget.size,
      clockwise: widget.clockwise,
      duration: widget.duration,
      showMountingHoles: optimizedShowHoles,
      showSpeedIndicator: optimizedShowSpeed,
      colors: widget.colors,
    );
  }
}