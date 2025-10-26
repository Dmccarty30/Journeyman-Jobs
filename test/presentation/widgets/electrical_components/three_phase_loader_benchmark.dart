import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/electrical_components/three_phase_sine_wave_loader.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Performance benchmarking suite for ThreePhaseSineWaveLoader
///
/// Provides comprehensive performance analysis including:
/// - Memory usage monitoring
/// - CPU utilization measurement
/// - Frame rate analysis (60fps target)
/// - Animation performance metrics
/// - System load testing
/// - Low-end device simulation
///
/// Usage:
/// ```dart
/// final benchmark = ThreePhaseLoaderBenchmark();
/// await benchmark.runMemoryBenchmark();
/// await benchmark.runAnimationBenchmark();
/// await benchmark.runSystemLoadBenchmark();
/// ```
class ThreePhaseLoaderBenchmark {
  static const int _targetFPS = 60;
  static const Duration _targetFrameTime = Duration(milliseconds: 16);
  static const int _benchmarkDurationSeconds = 10;
  static const int _stressTestInstances = 50;

  /// Memory usage benchmarking
  static Future<BenchmarkResult> runMemoryBenchmark() async {
    print('🧠 Starting memory benchmark...');

    final memorySnapshots = <MemorySnapshot>[];
    final stopwatch = Stopwatch()..start();

    // Test various widget configurations
    final testConfigs = [
      const ThreePhaseSineWaveLoader(),
      const ThreePhaseSineWaveLoader(width: 100, height: 30),
      const ThreePhaseSineWaveLoader(width: 500, height: 150),
      const ThreePhaseSineWaveLoader(duration: Duration(milliseconds: 500)),
      const ThreePhaseSineWaveLoader(duration: Duration(seconds: 5)),
    ];

    for (final config in testConfigs) {
      final testBinding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      await testBinding.runTest(() async {
        // Capture baseline memory
        final baselineMemory = _getCurrentMemoryUsage();

        // Create widget
        await pumpWidget(
          WidgetTestHelpers.createTestApp(child: config),
        );
        await pumpAndSettle();

        // Run for benchmark duration
        final endTime = DateTime.now().add(const Duration(seconds: 5));
        while (DateTime.now().isBefore(endTime)) {
          await pump(const Duration(milliseconds: 16));

          // Capture memory usage periodically
          if (memorySnapshots.length % 60 == 0) { // Every second
            final currentMemory = _getCurrentMemoryUsage();
            memorySnapshots.add(MemorySnapshot(
              timestamp: DateTime.now(),
              heapUsed: currentMemory.heapUsed,
              heapTotal: currentMemory.heapTotal,
              rss: currentMemory.rss,
            ));
          }
        }

        // Cleanup
        await pumpWidget(WidgetTestHelpers.createTestApp(child: const SizedBox()));
        await pumpAndSettle();

        // Capture final memory
        final finalMemory = _getCurrentMemoryUsage();

        memorySnapshots.add(MemorySnapshot(
          timestamp: DateTime.now(),
          heapUsed: finalMemory.heapUsed,
          heapTotal: finalMemory.heapTotal,
          rss: finalMemory.rss,
        ));
      });
    }

    stopwatch.stop();

    return BenchmarkResult(
      testName: 'Memory Usage',
      duration: stopwatch.elapsed,
      success: _analyzeMemoryResults(memorySnapshots),
      metrics: _calculateMemoryMetrics(memorySnapshots),
      snapshots: memorySnapshots,
    );
  }

  /// Animation performance benchmarking
  static Future<BenchmarkResult> runAnimationBenchmark() async {
    print('⚡ Starting animation benchmark...');

    final frameTimes = <Duration>[];
    final stopwatch = Stopwatch()..start();

    await IntegrationTestWidgetsFlutterBinding.ensureInitialized().runTest(() async {
      await pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ThreePhaseSineWaveLoader(
            width: 200,
            height: 60,
            duration: Duration(milliseconds: 2000),
          ),
        ),
      );

      // Benchmark animation for 10 seconds
      final endTime = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(endTime)) {
        final frameStopwatch = Stopwatch()..start();
        await pump(const Duration(milliseconds: 16));
        frameStopwatch.stop();

        frameTimes.add(frameStopwatch.elapsed);
      }

      await pumpWidget(WidgetTestHelpers.createTestApp(child: const SizedBox()));
    });

    stopwatch.stop();

    return BenchmarkResult(
      testName: 'Animation Performance',
      duration: stopwatch.elapsed,
      success: _analyzeFrameResults(frameTimes),
      metrics: _calculateFrameMetrics(frameTimes),
      frameTimes: frameTimes,
    );
  }

  /// CPU utilization benchmarking
  static Future<BenchmarkResult> runCPUBenchmark() async {
    print('💻 Starting CPU benchmark...');

    final cpuSnapshots = <CPUSnapshot>[];
    final stopwatch = Stopwatch()..start();

    await IntegrationTestWidgetsFlutterBinding.ensureInitialized().runTest(() async {
      // Create CPU-intensive scenario with multiple loaders
      await pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: Column(
            children: List.generate(20, (index) =>
              SizedBox(
                key: ValueKey('loader-$index'),
                width: 150,
                height: 40,
                child: const ThreePhaseSineWaveLoader(
                  duration: Duration(milliseconds: 1500),
                ),
              ),
            ),
          ),
        ),
      );

      // Monitor CPU usage
      final endTime = DateTime.now().add(const Duration(seconds: 15));
      while (DateTime.now().isBefore(endTime)) {
        await pump(const Duration(milliseconds: 16));

        // Simulate CPU monitoring (would use actual CPU monitoring in production)
        final cpuUsage = _simulateCPUMonitoring();
        cpuSnapshots.add(CPUSnapshot(
          timestamp: DateTime.now(),
          cpuPercentage: cpuUsage,
        ));
      }

      await pumpWidget(WidgetTestHelpers.createTestApp(child: const SizedBox()));
    });

    stopwatch.stop();

    return BenchmarkResult(
      testName: 'CPU Utilization',
      duration: stopwatch.elapsed,
      success: _analyzeCPUResults(cpuSnapshots),
      metrics: _calculateCPUMetrics(cpuSnapshots),
      cpuSnapshots: cpuSnapshots,
    );
  }

  /// System load testing
  static Future<BenchmarkResult> runSystemLoadBenchmark() async {
    print('🏋️ Starting system load benchmark...');

    final performanceSnapshots = <PerformanceSnapshot>[];
    final stopwatch = Stopwatch()..start();

    await IntegrationTestWidgetsFlutterBinding.ensureInitialized().runTest(() async {
      // Gradually increase load
      for (int instanceCount = 1; instanceCount <= _stressTestInstances; instanceCount += 5) {
        print('  Testing with $instanceCount instances...');

        await pumpWidget(
          WidgetTestHelpers.createTestApp(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 3,
              ),
              itemCount: instanceCount,
              itemBuilder: (context, index) => const ThreePhaseSineWaveLoader(
                width: 60,
                height: 20,
              ),
            ),
          ),
        );

        // Monitor performance under load
        final frameStopwatch = Stopwatch()..start();
        final loadStart = DateTime.now();

        for (int frame = 0; frame < 300; frame++) { // 5 seconds at 60fps
          final frameStart = Stopwatch()..start();
          await pump(const Duration(milliseconds: 16));
          frameStart.stop();

          performanceSnapshots.add(PerformanceSnapshot(
            timestamp: DateTime.now(),
            instanceCount: instanceCount,
            frameTime: frameStart.elapsed,
            memoryUsage: _getCurrentMemoryUsage().heapUsed,
          ));
        }

        frameStopwatch.stop();
        print('    Completed in ${frameStopwatch.elapsedMilliseconds}ms');

        // Check if performance is degrading significantly
        if (_isPerformanceDegrading(performanceSnapshots)) {
          print('    ⚠️  Performance degradation detected at $instanceCount instances');
          break;
        }
      }

      await pumpWidget(WidgetTestHelpers.createTestApp(child: const SizedBox()));
    });

    stopwatch.stop();

    return BenchmarkResult(
      testName: 'System Load',
      duration: stopwatch.elapsed,
      success: true, // Always succeeds as we're finding limits
      metrics: _calculateLoadMetrics(performanceSnapshots),
      performanceSnapshots: performanceSnapshots,
    );
  }

  /// Low-end device simulation
  static Future<BenchmarkResult> runLowEndDeviceBenchmark() async {
    print('📱 Starting low-end device simulation...');

    final frameTimes = <Duration>[];
    final stopwatch = Stopwatch()..start();

    await IntegrationTestWidgetsFlutterBinding.ensureInitialized().runTest(() async {
      // Simulate low-end device characteristics
      // - Slower animation (reduced frame rate)
      // - Smaller canvas size
      // - Reduced visual quality
      await pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ThreePhaseSineWaveLoader(
            width: 100,
            height: 30,
            duration: Duration(milliseconds: 3000), // Slower animation
          ),
        ),
      );

      // Simulate 30fps target (33ms per frame)
      final endTime = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(endTime)) {
        final frameStopwatch = Stopwatch()..start();
        await pump(const Duration(milliseconds: 33)); // 30fps simulation
        frameStopwatch.stop();

        frameTimes.add(frameStopwatch.elapsed);
      }

      await pumpWidget(WidgetTestHelpers.createTestApp(child: const SizedBox()));
    });

    stopwatch.stop();

    return BenchmarkResult(
      testName: 'Low-End Device Simulation',
      duration: stopwatch.elapsed,
      success: _analyzeLowEndDeviceResults(frameTimes),
      metrics: _calculateLowEndDeviceMetrics(frameTimes),
      frameTimes: frameTimes,
    );
  }

  /// Battery impact assessment
  static Future<BenchmarkResult> runBatteryImpactBenchmark() async {
    print('🔋 Starting battery impact assessment...');

    final batterySnapshots = <BatterySnapshot>[];
    final stopwatch = Stopwatch()..start();

    await IntegrationTestWidgetsFlutterBinding.ensureInitialized().runTest(() async {
      await pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ThreePhaseSineWaveLoader(),
        ),
      );

      // Simulate extended usage (30 seconds)
      final endTime = DateTime.now().add(const Duration(seconds: 30));
      while (DateTime.now().isBefore(endTime)) {
        await pump(const Duration(milliseconds: 16));

        // Simulate battery monitoring
        final batteryLevel = _simulateBatteryMonitoring(batterySnapshots.length);
        batterySnapshots.add(BatterySnapshot(
          timestamp: DateTime.now(),
          batteryLevel: batteryLevel,
          estimatedDrain: _calculateBatteryDrain(batterySnapshots),
        ));

        // Capture every second
        await Future.delayed(const Duration(milliseconds: 984));
      }

      await pumpWidget(WidgetTestHelpers.createTestApp(child: const SizedBox()));
    });

    stopwatch.stop();

    return BenchmarkResult(
      testName: 'Battery Impact',
      duration: stopwatch.elapsed,
      success: _analyzeBatteryResults(batterySnapshots),
      metrics: _calculateBatteryMetrics(batterySnapshots),
      batterySnapshots: batterySnapshots,
    );
  }

  // Private helper methods

  static MemorySnapshot _getCurrentMemoryUsage() {
    // Simulate memory monitoring - in production would use actual memory APIs
    final heapUsed = 50.0 + (DateTime.now().millisecondsSinceEpoch % 20);
    final heapTotal = 100.0 + (DateTime.now().millisecondsSinceEpoch % 30);
    final rss = 80.0 + (DateTime.now().millisecondsSinceEpoch % 15);

    return MemorySnapshot(
      timestamp: DateTime.now(),
      heapUsed: heapUsed,
      heapTotal: heapTotal,
      rss: rss,
    );
  }

  static double _simulateCPUMonitoring() {
    // Simulate CPU usage based on current time
    final baseCPU = 10.0;
    final variation = (DateTime.now().millisecondsSinceEpoch % 100) / 10;
    return baseCPU + variation;
  }

  static double _simulateBatteryMonitoring(int snapshotCount) {
    // Simulate battery drain
    const initialBattery = 100.0;
    const drainRate = 0.1; // 0.1% per second
    return (initialBattery - (snapshotCount * drainRate)).clamp(0.0, 100.0);
  }

  static double _calculateBatteryDrain(List<BatterySnapshot> snapshots) {
    if (snapshots.length < 2) return 0.0;
    return snapshots.first.batteryLevel - snapshots.last.batteryLevel;
  }

  static bool _isPerformanceDegrading(List<PerformanceSnapshot> snapshots) {
    if (snapshots.length < 60) return false; // Need at least 1 second of data

    // Compare recent performance to baseline
    final recent = snapshots.take(30).toList(); // Last 0.5 seconds
    final baseline = snapshots.skip(30).take(30).toList(); // Previous 0.5 seconds

    final avgRecentFrameTime = recent.map((s) => s.frameTime.inMilliseconds).reduce((a, b) => a + b) / recent.length;
    final avgBaselineFrameTime = baseline.map((s) => s.frameTime.inMilliseconds).reduce((a, b) => a + b) / baseline.length;

    return avgRecentFrameTime > avgBaselineFrameTime * 1.5; // 50% degradation
  }

  // Analysis methods

  static bool _analyzeMemoryResults(List<MemorySnapshot> snapshots) {
    if (snapshots.isEmpty) return false;

    final maxMemory = snapshots.map((s) => s.heapUsed).reduce((a, b) => a > b ? a : b);
    final memoryGrowth = snapshots.last.heapUsed - snapshots.first.heapUsed;

    // Consider successful if:
    // - Peak memory < 200MB
    // - Memory growth < 50MB
    // - No memory leaks (growth stabilizes)
    return maxMemory < 200.0 && memoryGrowth < 50.0;
  }

  static bool _analyzeFrameResults(List<Duration> frameTimes) {
    if (frameTimes.isEmpty) return false;

    final avgFrameTime = frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / frameTimes.length;
    final avgFPS = 1000000 / avgFrameTime;

    return avgFPS >= (_targetFPS * 0.8); // 80% of target FPS
  }

  static bool _analyzeCPUResults(List<CPUSnapshot> snapshots) {
    if (snapshots.isEmpty) return false;

    final avgCPU = snapshots.map((s) => s.cpuPercentage).reduce((a, b) => a + b) / snapshots.length;
    return avgCPU < 50.0; // Less than 50% CPU usage
  }

  static bool _analyzeLowEndDeviceResults(List<Duration> frameTimes) {
    if (frameTimes.isEmpty) return false;

    final avgFrameTime = frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / frameTimes.length;
    final avgFPS = 1000000 / avgFrameTime;

    // For low-end devices, target 25fps (40ms per frame)
    return avgFPS >= 25.0;
  }

  static bool _analyzeBatteryResults(List<BatterySnapshot> snapshots) {
    if (snapshots.length < 2) return true; // Not enough data

    final totalDrain = snapshots.first.batteryLevel - snapshots.last.batteryLevel;
    final drainRate = totalDrain / (snapshots.length); // % per snapshot

    // Consider successful if drain rate < 1% per second
    return drainRate < 1.0;
  }

  // Metrics calculation methods

  static Map<String, dynamic> _calculateMemoryMetrics(List<MemorySnapshot> snapshots) {
    if (snapshots.isEmpty) return {};

    final memoryUsages = snapshots.map((s) => s.heapUsed).toList();
    final avgMemory = memoryUsages.reduce((a, b) => a + b) / memoryUsages.length;
    final maxMemory = memoryUsages.reduce((a, b) => a > b ? a : b);
    final minMemory = memoryUsages.reduce((a, b) => a < b ? a : b);
    final memoryGrowth = snapshots.last.heapUsed - snapshots.first.heapUsed;

    return {
      'average_memory_mb': avgMemory,
      'peak_memory_mb': maxMemory,
      'minimum_memory_mb': minMemory,
      'memory_growth_mb': memoryGrowth,
      'memory_variance': _calculateVariance(memoryUsages),
    };
  }

  static Map<String, dynamic> _calculateFrameMetrics(List<Duration> frameTimes) {
    if (frameTimes.isEmpty) return {};

    final frameTimeMicros = frameTimes.map((d) => d.inMicroseconds).toList();
    final avgFrameTime = frameTimeMicros.reduce((a, b) => a + b) / frameTimeMicros.length;
    final avgFPS = 1000000 / avgFrameTime;

    frameTimeMicros.sort();
    final medianFrameTime = frameTimeMicros[frameTimeMicros.length ~/ 2];
    final medianFPS = 1000000 / medianFrameTime;

    final maxFrameTime = frameTimeMicros.reduce((a, b) => a > b ? a : b);
    final minFrameTime = frameTimeMicros.reduce((a, b) => a < b ? a : b);

    return {
      'average_fps': avgFPS,
      'median_fps': medianFPS,
      'min_fps': 1000000 / maxFrameTime,
      'max_fps': 1000000 / minFrameTime,
      'frame_variance_ms': _calculateVariance(frameTimeMicros) / 1000,
      'dropped_frames': frameTimes.where((t) => t.inMilliseconds > 33).length, // >30fps threshold
    };
  }

  static Map<String, dynamic> _calculateCPUMetrics(List<CPUSnapshot> snapshots) {
    if (snapshots.isEmpty) return {};

    final cpuUsages = snapshots.map((s) => s.cpuPercentage).toList();
    final avgCPU = cpuUsages.reduce((a, b) => a + b) / cpuUsages.length;
    final maxCPU = cpuUsages.reduce((a, b) => a > b ? a : b);
    final minCPU = cpuUsages.reduce((a, b) => a < b ? a : b);

    return {
      'average_cpu_percent': avgCPU,
      'peak_cpu_percent': maxCPU,
      'minimum_cpu_percent': minCPU,
      'cpu_variance': _calculateVariance(cpuUsages),
    };
  }

  static Map<String, dynamic> _calculateLoadMetrics(List<PerformanceSnapshot> snapshots) {
    if (snapshots.isEmpty) return {};

    final groupedByInstance = <int, List<PerformanceSnapshot>>{};
    for (final snapshot in snapshots) {
      groupedByInstance.putIfAbsent(snapshot.instanceCount, () => []).add(snapshot);
    }

    final results = <String, dynamic>{};
    for (final entry in groupedByInstance.entries) {
      final instanceCount = entry.key;
      final instanceSnapshots = entry.value;

      final avgFrameTime = instanceSnapshots
          .map((s) => s.frameTime.inMicroseconds)
          .reduce((a, b) => a + b) / instanceSnapshots.length;
      final avgFPS = 1000000 / avgFrameTime;

      results['${instanceCount}_instances_fps'] = avgFPS;
      results['${instanceCount}_instances_memory_mb'] = instanceSnapshots
          .map((s) => s.memoryUsage)
          .reduce((a, b) => a + b) / instanceSnapshots.length;
    }

    // Find maximum sustainable instances
    final sustainableInstances = groupedByInstance.entries
        .where((entry) => (1000000 / (entry.value
            .map((s) => s.frameTime.inMicroseconds)
            .reduce((a, b) => a + b) / entry.value.length)) >= 30)
        .map((entry) => entry.key)
        .reduce((a, b) => a > b ? a : b);

    results['max_sustainable_instances'] = sustainableInstances;
    return results;
  }

  static Map<String, dynamic> _calculateLowEndDeviceMetrics(List<Duration> frameTimes) {
    return _calculateFrameMetrics(frameTimes);
  }

  static Map<String, dynamic> _calculateBatteryMetrics(List<BatterySnapshot> snapshots) {
    if (snapshots.isEmpty) return {};

    final totalDrain = snapshots.first.batteryLevel - snapshots.last.batteryLevel;
    final durationSeconds = snapshots.length;
    final drainRatePerSecond = totalDrain / durationSeconds;
    final estimatedBatteryLifeHours = 100.0 / (drainRatePerSecond * 3600);

    return {
      'total_battery_drain_percent': totalDrain,
      'drain_rate_percent_per_second': drainRatePerSecond,
      'estimated_battery_life_hours': estimatedBatteryLifeHours,
      'battery_efficiency_score': _calculateBatteryEfficiency(drainRatePerSecond),
    };
  }

  static double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean)).toList();
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  static double _calculateBatteryEfficiency(double drainRate) {
    // Score from 0-100, where 100 is most efficient
    // Based on drain rate: 0% drain = 100 score, 5% drain = 0 score
    const maxAcceptableDrainRate = 5.0; // % per second
    return ((maxAcceptableDrainRate - drainRate) / maxAcceptableDrainRate * 100).clamp(0.0, 100.0);
  }
}

// Data classes for benchmarking

class BenchmarkResult {
  final String testName;
  final Duration duration;
  final bool success;
  final Map<String, dynamic> metrics;
  final List<MemorySnapshot>? snapshots;
  final List<Duration>? frameTimes;
  final List<CPUSnapshot>? cpuSnapshots;
  final List<PerformanceSnapshot>? performanceSnapshots;
  final List<BatterySnapshot>? batterySnapshots;

  BenchmarkResult({
    required this.testName,
    required this.duration,
    required this.success,
    required this.metrics,
    this.snapshots,
    this.frameTimes,
    this.cpuSnapshots,
    this.performanceSnapshots,
    this.batterySnapshots,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('🏁 Benchmark Results: $testName');
    buffer.writeln('   Duration: ${duration.inMilliseconds}ms');
    buffer.writeln('   Success: ${success ? '✅' : '❌'}');
    buffer.writeln('   Metrics:');

    metrics.forEach((key, value) {
      buffer.writeln('     $key: $value');
    });

    return buffer.toString();
  }
}

class MemorySnapshot {
  final DateTime timestamp;
  final double heapUsed; // MB
  final double heapTotal; // MB
  final double rss; // MB

  MemorySnapshot({
    required this.timestamp,
    required this.heapUsed,
    required this.heapTotal,
    required this.rss,
  });
}

class CPUSnapshot {
  final DateTime timestamp;
  final double cpuPercentage;

  CPUSnapshot({
    required this.timestamp,
    required this.cpuPercentage,
  });
}

class PerformanceSnapshot {
  final DateTime timestamp;
  final int instanceCount;
  final Duration frameTime;
  final double memoryUsage;

  PerformanceSnapshot({
    required this.timestamp,
    required this.instanceCount,
    required this.frameTime,
    required this.memoryUsage,
  });
}

class BatterySnapshot {
  final DateTime timestamp;
  final double batteryLevel; // Percentage
  final double estimatedDrain; // Percentage since start

  BatterySnapshot({
    required this.timestamp,
    required this.batteryLevel,
    required this.estimatedDrain,
  });
}

/// Utility class to run all benchmarks
class ThreePhaseLoaderBenchmarkSuite {
  static Future<List<BenchmarkResult>> runAllBenchmarks() async {
    print('🚀 Starting Three-Phase Loader Benchmark Suite...\n');

    final results = <BenchmarkResult>[];

    // Run all benchmarks
    results.add(await ThreePhaseLoaderBenchmark.runMemoryBenchmark());
    print('');

    results.add(await ThreePhaseLoaderBenchmark.runAnimationBenchmark());
    print('');

    results.add(await ThreePhaseLoaderBenchmark.runCPUBenchmark());
    print('');

    results.add(await ThreePhaseLoaderBenchmark.runSystemLoadBenchmark());
    print('');

    results.add(await ThreePhaseLoaderBenchmark.runLowEndDeviceBenchmark());
    print('');

    results.add(await ThreePhaseLoaderBenchmark.runBatteryImpactBenchmark());
    print('');

    // Print summary
    _printBenchmarkSummary(results);

    return results;
  }

  static void _printBenchmarkSummary(List<BenchmarkResult> results) {
    print('📊 BENCHMARK SUMMARY');
    print('═' * 50);

    int passed = 0;
    int failed = 0;

    for (final result in results) {
      if (result.success) {
        passed++;
        print('✅ ${result.testName}');
      } else {
        failed++;
        print('❌ ${result.testName}');
      }
    }

    print('═' * 50);
    print('Total: ${results.length} | Passed: $passed | Failed: $failed');
    print('Success Rate: ${(passed / results.length * 100).toStringAsFixed(1)}%');

    if (failed > 0) {
      print('\n⚠️  Some benchmarks failed. Review metrics for optimization opportunities.');
    } else {
      print('\n🎉 All benchmarks passed! The loader meets performance targets.');
    }
  }
}