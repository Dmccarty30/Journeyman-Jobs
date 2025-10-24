#!/usr/bin/env dart

/// STORM-012: Design System Compliance Lint Tool
///
/// Automated detection of hardcoded design values that should use AppTheme constants.
/// This tool scans Dart files for violations and reports them with severity levels.
///
/// Usage:
///   `dart tools/design_system_lint.dart [options]`
///
/// Options:
///   --fix          Automatically fix violations (interactive)
///   --ci           CI mode: Exit with error code if violations found
///   --verbose      Show detailed violation information
///   --path `dir`   Scan specific directory (default: lib/)
///
/// Exit Codes:
///   0: No violations found
///   1: Violations found (CI mode only)
///   2: Error during execution
library;

import 'dart:io';

// ANSI color codes for terminal output
const String _red = '\x1B[31m';
const String _yellow = '\x1B[33m';
const String _green = '\x1B[32m';
const String _blue = '\x1B[34m';
const String _cyan = '\x1B[36m';
const String _reset = '\x1B[0m';
const String _bold = '\x1B[1m';

void main(List<String> arguments) async {
  final config = _parseArguments(arguments);

  print('$_bold$_cyan');
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║   STORM-012: Design System Compliance Lint Tool          ║');
  print('║   Journeyman Jobs - Electrical Design System             ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print(_reset);

  final scanner = DesignSystemScanner(config);
  final violations = await scanner.scan();

  if (violations.isEmpty) {
    print('$_green$_bold✅ No design system violations found!$_reset\n');
    print('${_green}All files are compliant with AppTheme constants.$_reset');
    exit(0);
  }

  // Report violations
  _reportViolations(violations, config);

  // CI mode: exit with error
  if (config.ciMode) {
    print('\n$_red$_bold❌ CI Check Failed: ${violations.length} violations found$_reset');
    exit(1);
  }

  exit(0);
}

class LintConfig {
  final bool fixMode;
  final bool ciMode;
  final bool verbose;
  final String scanPath;

  LintConfig({
    this.fixMode = false,
    this.ciMode = false,
    this.verbose = false,
    this.scanPath = 'lib/',
  });
}

class Violation {
  final String file;
  final int line;
  final String type;
  final String pattern;
  final String suggestion;
  final String severity; // 'error' or 'warning'

  Violation({
    required this.file,
    required this.line,
    required this.type,
    required this.pattern,
    required this.suggestion,
    required this.severity,
  });
}

class DesignSystemScanner {
  final LintConfig config;
  final List<ViolationPattern> patterns;

  DesignSystemScanner(this.config) : patterns = _createPatterns();

  static List<ViolationPattern> _createPatterns() {
    return [
      // Border Radius Violations
      ViolationPattern(
        type: 'Hardcoded Border Radius',
        regex: RegExp(r'BorderRadius\.circular\((\d+(?:\.\d+)?)\)'),
        severity: 'warning',
        getSuggestion: (match) {
          final value = double.tryParse(match.group(1) ?? '0') ?? 0;
          if (value <= 2) return 'AppTheme.radiusXxs (2px)';
          if (value <= 4) return 'AppTheme.radiusXs (4px)';
          if (value <= 8) return 'AppTheme.radiusSm (8px)';
          if (value <= 12) return 'AppTheme.radiusMd (12px)';
          if (value <= 16) return 'AppTheme.radiusLg (16px)';
          if (value <= 20) return 'AppTheme.radiusXl (20px)';
          return 'AppTheme.radiusXxl (24px)';
        },
        isException: (line, filePath) {
          // Exclude AppTheme definition files
          if (filePath.contains('lib/design_system/app_theme')) return true;
          // Allow if already using AppTheme
          if (line.contains('AppTheme.radius')) return true;
          // Allow calculations based on AppTheme
          if (RegExp(r'AppTheme\.\w+\s*[*/]\s*\d+').hasMatch(line)) return true;
          return false;
        },
      ),

      // Radius.circular Violations
      ViolationPattern(
        type: 'Hardcoded Radius',
        regex: RegExp(r'Radius\.circular\((\d+(?:\.\d+)?)\)'),
        severity: 'warning',
        getSuggestion: (match) {
          final value = double.tryParse(match.group(1) ?? '0') ?? 0;
          if (value <= 4) return 'Radius.circular(AppTheme.radiusXs)';
          if (value <= 8) return 'Radius.circular(AppTheme.radiusSm)';
          if (value <= 12) return 'Radius.circular(AppTheme.radiusMd)';
          return 'Radius.circular(AppTheme.radiusLg)';
        },
        isException: (line, filePath) {
          // Exclude AppTheme definition files
          if (filePath.contains('lib/design_system/app_theme')) return true;
          if (line.contains('AppTheme.radius')) return true;
          return false;
        },
      ),

      // Color Violations
      ViolationPattern(
        type: 'Hardcoded Color Value',
        regex: RegExp(r'Color\((0x[0-9A-F]{8})\)'),
        severity: 'error',
        getSuggestion: (match) {
          final colorHex = match.group(1)?.toUpperCase() ?? '';

          // NOAA weather colors (documented exceptions)
          if (colorHex == '0xFFD8006D') return 'AppTheme.weatherColors[\'hurricane_cat5\']';
          if (colorHex == '0xFFFF0000') return 'AppTheme.weatherColors[\'hurricane_cat4\']';
          if (colorHex == '0xFFFF6060') return 'AppTheme.weatherColors[\'hurricane_cat3\']';
          if (colorHex == '0xFFFFB366') return 'AppTheme.weatherColors[\'hurricane_cat2\']';
          if (colorHex == '0xFFFFD966') return 'AppTheme.weatherColors[\'hurricane_cat1\']';
          if (colorHex == '0xFF00C5FF') return 'AppTheme.weatherColors[\'tropicalStorm\']';
          if (colorHex == '0xFF00FA9A') return 'AppTheme.weatherColors[\'tropicalDepression\']';

          // Common colors
          if (colorHex == '0xFFFFFFFF') return 'AppTheme.white';
          if (colorHex == '0xFF000000') return 'AppTheme.black';
          if (colorHex == '0xFF1A202C') return 'AppTheme.primaryNavy';
          if (colorHex == '0xFFB45309') return 'AppTheme.accentCopper';

          return 'Define in AppTheme or use existing color constant';
        },
        isException: (line, filePath) {
          // Exclude AppTheme definition files
          if (filePath.contains('lib/design_system/app_theme')) return true;
          // Allow if using AppTheme
          if (line.contains('AppTheme.')) return true;
          // Allow Colors.transparent
          if (line.contains('Colors.transparent')) return true;
          return false;
        },
      ),

      // BoxShadow Violations
      ViolationPattern(
        type: 'Custom BoxShadow Definition',
        regex: RegExp(r'BoxShadow\s*\('),
        severity: 'warning',
        getSuggestion: (match) {
          return 'AppTheme.shadowCard (or shadowSm/shadowLg based on use case)';
        },
        isException: (line, filePath) {
          // Exclude AppTheme definition files
          if (filePath.contains('lib/design_system/app_theme')) return true;
          // Allow if already using AppTheme
          if (line.contains('AppTheme.shadow')) return true;
          // Allow BoxShadow as parameter in specific contexts
          if (line.contains('List<BoxShadow>')) return true;
          return false;
        },
      ),

      // Border Width Violations
      ViolationPattern(
        type: 'Hardcoded Border Width',
        regex: RegExp(r'Border\.all\([^)]*width:\s*(\d+(?:\.\d+)?)'),
        severity: 'warning',
        getSuggestion: (match) {
          final value = double.tryParse(match.group(1) ?? '0') ?? 0;
          if (value <= 1) return 'AppTheme.borderWidthThin (1px)';
          if (value <= 1.5) return 'AppTheme.borderWidthMedium (1.5px)';
          if (value <= 2) return 'AppTheme.borderWidthThick (2px)';
          return 'AppTheme.borderWidthCopper (2.5px)';
        },
        isException: (line, filePath) {
          // Exclude AppTheme definition files
          if (filePath.contains('lib/design_system/app_theme')) return true;
          if (line.contains('AppTheme.borderWidth')) return true;
          return false;
        },
      ),
    ];
  }

  Future<List<Violation>> scan() async {
    final violations = <Violation>[];
    final directory = Directory(config.scanPath);

    if (!directory.existsSync()) {
      print('$_red❌ Error: Directory ${config.scanPath} does not exist$_reset');
      exit(2);
    }

    print('${_blue}Scanning ${config.scanPath} for design system violations...$_reset\n');

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileViolations = await _scanFile(entity);
        violations.addAll(fileViolations);
      }
    }

    return violations;
  }

  Future<List<Violation>> _scanFile(File file) async {
    final violations = <Violation>[];
    final lines = await file.readAsLines();
    final relativePath = file.path.replaceAll('\\', '/').replaceFirst(
      RegExp(r'^.*?/(lib/.*)$'),
      r'$1',
    );

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1;

      for (final pattern in patterns) {
        if (pattern.isException(line, relativePath)) continue;

        final matches = pattern.regex.allMatches(line);
        for (final match in matches) {
          violations.add(Violation(
            file: relativePath,
            line: lineNumber,
            type: pattern.type,
            pattern: match.group(0) ?? '',
            suggestion: pattern.getSuggestion(match),
            severity: pattern.severity,
          ));
        }
      }
    }

    return violations;
  }
}

class ViolationPattern {
  final String type;
  final RegExp regex;
  final String severity;
  final String Function(Match) getSuggestion;
  final bool Function(String line, String filePath) isException;

  ViolationPattern({
    required this.type,
    required this.regex,
    required this.severity,
    required this.getSuggestion,
    required this.isException,
  });
}

void _reportViolations(List<Violation> violations, LintConfig config) {
  // Group violations by file
  final byFile = <String, List<Violation>>{};
  for (final v in violations) {
    byFile.putIfAbsent(v.file, () => []).add(v);
  }

  // Count by severity
  final errors = violations.where((v) => v.severity == 'error').length;
  final warnings = violations.where((v) => v.severity == 'warning').length;

  print('$_bold${_red}Found ${violations.length} design system violations:$_reset');
  print('  $_red● Errors: $errors$_reset');
  print('  $_yellow● Warnings: $warnings$_reset\n');

  // Report by file
  final sortedFiles = byFile.keys.toList()..sort();
  for (final file in sortedFiles) {
    final fileViolations = byFile[file]!;
    final errorCount = fileViolations.where((v) => v.severity == 'error').length;
    final warningCount = fileViolations.where((v) => v.severity == 'warning').length;

    print('$_bold$file$_reset');
    print('  ${_red}$errorCount errors$_reset, ${_yellow}$warningCount warnings$_reset\n');

    for (final v in fileViolations) {
      final severityColor = v.severity == 'error' ? _red : _yellow;
      final severityIcon = v.severity == 'error' ? '✖' : '⚠';

      print('  $severityColor$severityIcon Line ${v.line}: ${v.type}$_reset');
      if (config.verbose) {
        print('    Pattern: $_cyan${v.pattern}$_reset');
      }
      print('    Suggestion: $_green${v.suggestion}$_reset\n');
    }
  }

  // Summary with remediation guidance
  print('$_bold${_cyan}Remediation Summary:$_reset');
  print('  Total files affected: ${byFile.length}');
  print('  Average violations per file: ${(violations.length / byFile.length).toStringAsFixed(1)}');
  print('  Estimated fix time: ${_estimateFixTime(violations)}\n');

  print('$_bold${_blue}Next Steps:$_reset');
  print('  1. Review violations above');
  print('  2. Replace hardcoded values with AppTheme constants');
  print('  3. Run tests to verify changes');
  print('  4. Re-run this lint tool to validate\n');

  print('${_cyan}For detailed migration guide, see:$_reset');
  print('  docs/design_system/STORM_SCREEN_DESIGN_REFERENCE.md\n');
}

String _estimateFixTime(List<Violation> violations) {
  final minutes = (violations.length * 0.5).ceil(); // 30 seconds per violation
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours > 0) {
    return '$hours hour${hours > 1 ? 's' : ''}, $remainingMinutes minutes';
  }
  return '$remainingMinutes minutes';
}

LintConfig _parseArguments(List<String> arguments) {
  bool fixMode = false;
  bool ciMode = false;
  bool verbose = false;
  String scanPath = 'lib/';

  for (var i = 0; i < arguments.length; i++) {
    switch (arguments[i]) {
      case '--fix':
        fixMode = true;
        break;
      case '--ci':
        ciMode = true;
        break;
      case '--verbose':
      case '-v':
        verbose = true;
        break;
      case '--path':
        if (i + 1 < arguments.length) {
          scanPath = arguments[++i];
        }
        break;
      case '--help':
      case '-h':
        _printHelp();
        exit(0);
    }
  }

  return LintConfig(
    fixMode: fixMode,
    ciMode: ciMode,
    verbose: verbose,
    scanPath: scanPath,
  );
}

void _printHelp() {
  print('''
$_bold$_cyan
╔═══════════════════════════════════════════════════════════╗
║   STORM-012: Design System Compliance Lint Tool          ║
║   Journeyman Jobs - Electrical Design System             ║
╚═══════════════════════════════════════════════════════════╝
$_reset

${_bold}USAGE:$_reset
  dart tools/design_system_lint.dart [options]

${_bold}OPTIONS:$_reset
  --fix             Automatically fix violations (interactive)
  --ci              CI mode: Exit with error code if violations found
  --verbose, -v     Show detailed violation information
  --path <dir>      Scan specific directory (default: lib/)
  --help, -h        Show this help message

${_bold}EXAMPLES:$_reset
  # Scan lib/ directory (default)
  dart tools/design_system_lint.dart

  # Scan with detailed output
  dart tools/design_system_lint.dart --verbose

  # Run in CI pipeline
  dart tools/design_system_lint.dart --ci

  # Scan specific directory
  dart tools/design_system_lint.dart --path lib/widgets

${_bold}EXIT CODES:$_reset
  0   No violations found
  1   Violations found (CI mode only)
  2   Error during execution

${_bold}VIOLATIONS DETECTED:$_reset
  • Hardcoded border radius (should use AppTheme.radius*)
  • Hardcoded colors (should use AppTheme color constants)
  • Custom BoxShadow definitions (should use AppTheme.shadow*)
  • Hardcoded border widths (should use AppTheme.borderWidth*)

${_bold}DOCUMENTATION:$_reset
  See docs/design_system/STORM_SCREEN_DESIGN_REFERENCE.md
  for migration examples and best practices.
''');
}
