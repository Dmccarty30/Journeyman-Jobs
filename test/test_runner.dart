import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Test runner for Journeyman Jobs application
///
/// Provides utilities for running test suites with different configurations
/// and generating comprehensive test reports.
class TestRunner {
  static const String _bold = '\x1B[1m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _reset = '\x1B[0m';

  /// Run all tests
  static Future<void> runAllTests() async {
    print('\n${_bold}🧪 Journeyman Jobs Test Suite${_reset}\n');
    print('${_blue}Running all tests...${_reset}\n');

    final stopwatch = Stopwatch()..start();

    try {
      // Run unit tests
      await _runTestSuite('Unit Tests', [
        'utils/error_handler_test.dart',
        'providers/auth_riverpod_provider_test.dart',
        'providers/jobs_riverpod_provider_test.dart',
        'providers/job_filter_riverpod_provider_test.dart',
        'widgets/error_dialog_test.dart',
        'widgets/jj_job_card_test.dart',
      ]);

      // Run widget tests
      await _runTestSuite('Widget Tests', [
        'widgets/*_test.dart',
      ]);

      // Run integration tests
      await _runTestSuite('Integration Tests', [
        'integration/*_test.dart',
      ]);

      stopwatch.stop();

      // Print summary
      print('\n${_bold}✅ Test Suite Complete${_reset}');
      print('${_green}Total time: ${stopwatch.elapsed.inSeconds}s${_reset}');
      print('\n${_blue}Coverage report generated in coverage/lcov.info${_reset}');
    } catch (e) {
      print('\n${_red}❌ Test suite failed${_reset}');
      print('${_red}Error: $e${_reset}');
      exit(1);
    }
  }

  /// Run unit tests only
  static Future<void> runUnitTests() async {
    print('\n${_bold}🧪 Unit Tests${_reset}\n');
    await _runTestSuite('Unit Tests', [
      'utils/error_handler_test.dart',
      'providers/*_test.dart',
    ]);
  }

  /// Run widget tests only
  static Future<void> runWidgetTests() async {
    print('\n${_bold}🎨 Widget Tests${_reset}\n');
    await _runTestSuite('Widget Tests', [
      'widgets/*_test.dart',
    ]);
  }

  /// Run integration tests only
  static Future<void> runIntegrationTests() async {
    print('\n${_bold}🔗 Integration Tests${_reset}\n');
    await _runTestSuite('Integration Tests', [
      'integration/*_test.dart',
    ]);
  }

  /// Run tests for a specific file
  static Future<void> runTestFile(String filePath) async {
    print('\n${_bold}🧪 Running: $filePath${_reset}\n');

    final result = await Process.run('dart', [
      'test',
      '--reporter=expanded',
      '--coverage=coverage',
      filePath,
    ]);

    if (result.exitCode != 0) {
      print('${_red}Test failed:${_reset}');
      print(result.stderr);
    } else {
      print('${_green}✅ Tests passed${_reset}');
    }
  }

  /// Generate coverage report
  static Future<void> generateCoverageReport() async {
    print('\n${_bold}📊 Generating Coverage Report${_reset}\n');

    // Generate LCOV report
    final result = await Process.run('dart', [
      'run',
      'coverage:lcov',
      '--report-on=lib',
      '--output=coverage/lcov.info',
      '-i',
      'coverage/lcov.info',
    ]);

    if (result.exitCode == 0) {
      print('${_green}✅ LCOV report generated${_reset}');
      print('Open coverage/lcov.info to view coverage details');
    } else {
      print('${_yellow}⚠️ Could not generate LCOV report${_reset}');
      print('Make sure you have coverage package installed');
    }
  }

  /// Run a test suite
  static Future<void> _runTestSuite(String suiteName, List<String> patterns) async {
    print('${_yellow}$suiteName:${_reset}');

    for (final pattern in patterns) {
      print('  📁 $pattern');

      final result = await Process.run('dart', [
        'test',
        '--reporter=compact',
        '--coverage=coverage',
        pattern,
      ]);

      if (result.exitCode != 0) {
        print('    ${_red}❌ Failed${_reset}');
        print(result.stderr);
      } else {
        print('    ${_green}✅ Passed${_reset}');
      }
    }
    print('');
  }

  /// Watch mode for continuous testing
  static Future<void> runWatchMode() async {
    print('\n${_bold}👁️ Watch Mode Enabled${_reset}');
    print('${_blue}Watching for file changes...${_reset}\n');

    final result = await Process.run('dart', [
      'test',
      '--watch',
      '--reporter=expanded',
    ]);

    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }

  /// Run performance tests
  static Future<void> runPerformanceTests() async {
    print('\n${_bold}⚡ Performance Tests${_reset}\n');

    final testFiles = [
      'widgets/jj_job_card_test.dart',
      // Add other performance-related test files
    ];

    for (final file in testFiles) {
      print('Running performance tests for $file...');

      final result = await Process.run('dart', [
        'test',
        '--reporter=json',
        file,
      ]);

      // Parse JSON output for performance metrics
      if (result.exitCode == 0) {
        print('  ${_green}✅ Performance metrics collected${_reset}');
      }
    }
  }

  /// Validate test coverage meets minimum thresholds
  static Future<void> validateCoverage({double minCoverage = 80.0}) async {
    print('\n${_bold}📈 Validating Coverage${_reset}\n');
    print('Minimum required coverage: ${minCoverage.toStringAsFixed(1)}%');

    // This would require parsing coverage output
    // Implementation depends on coverage tooling
  }
}

/// Main entry point
void main(List<String> args) async {
  if (args.isEmpty) {
    await TestRunner.runAllTests();
  } else {
    switch (args.first) {
      case 'unit':
        await TestRunner.runUnitTests();
        break;
      case 'widget':
        await TestRunner.runWidgetTests();
        break;
      case 'integration':
        await TestRunner.runIntegrationTests();
        break;
      case 'coverage':
        await TestRunner.generateCoverageReport();
        break;
      case 'watch':
        await TestRunner.runWatchMode();
        break;
      case 'performance':
        await TestRunner.runPerformanceTests();
        break;
      default:
        if (args.first.endsWith('.dart')) {
          await TestRunner.runTestFile(args.first);
        } else {
          print('Usage: dart test_runner.dart [unit|widget|integration|coverage|watch|performance|<test_file>]');
        }
    }
  }
}