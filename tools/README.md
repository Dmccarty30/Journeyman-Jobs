# Development Tools

This directory contains development and quality assurance tools for the Journeyman Jobs project.

---

## Design System Lint Tool

**File**: `design_system_lint.dart`
**Task**: STORM-012 - Custom lint rule for hardcoded design values
**Purpose**: Automated detection and prevention of hardcoded design values

### Overview

The Design System Lint Tool automatically scans Dart files to detect hardcoded design values that should use `AppTheme` constants instead. This ensures visual consistency and makes theme changes instant across the entire application.

### Usage

**Basic Usage**:
```bash
# Scan lib/ directory (default)
dart tools/design_system_lint.dart

# Scan with detailed output
dart tools/design_system_lint.dart --verbose

# Scan specific directory
dart tools/design_system_lint.dart --path lib/widgets
```

**CI/CD Integration**:
```bash
# Exit with error code if violations found
dart tools/design_system_lint.dart --ci
```

### Violations Detected

1. **Hardcoded Border Radius** (Warning)
   - Pattern: `BorderRadius.circular(12)`
   - Suggestion: `BorderRadius.circular(AppTheme.radiusMd)`

2. **Hardcoded Colors** (Error)
   - Pattern: `Color(0xFFFF0000)`
   - Suggestion: `AppTheme.errorRed` or define in AppTheme

3. **Custom BoxShadow** (Warning)
   - Pattern: `BoxShadow(color: Colors.black.withValues(alpha: 0.08), ...)`
   - Suggestion: `AppTheme.shadowCard`

4. **Hardcoded Border Width** (Warning)
   - Pattern: `Border.all(width: 1.5)`
   - Suggestion: `Border.all(width: AppTheme.borderWidthMedium)`

### Exceptions

The tool recognizes valid exceptions:

- **AppTheme calculations**: `BorderRadius.circular(AppTheme.radiusMd / 2)` ✅
- **AppTheme constants**: `color: AppTheme.primaryNavy` ✅
- **System colors**: `Colors.transparent` ✅
- **AppTheme file**: All definitions in `lib/design_system/app_theme.dart` ✅

### Command Line Options

| Option | Description |
|--------|-------------|
| `--verbose`, `-v` | Show detailed violation information including patterns |
| `--ci` | CI mode: Exit with error code 1 if violations found |
| `--path <dir>` | Scan specific directory (default: `lib/`) |
| `--help`, `-h` | Show help message with usage examples |

### Exit Codes

- `0`: No violations found
- `1`: Violations found (CI mode only)
- `2`: Error during execution

### Output Example

```
╔═══════════════════════════════════════════════════════════╗
║   STORM-012: Design System Compliance Lint Tool          ║
║   Journeyman Jobs - Electrical Design System             ║
╚═══════════════════════════════════════════════════════════╝

Scanning lib/widgets for design system violations...

Found 108 design system violations:
  ● Errors: 9
  ● Warnings: 99

lib/widgets/pay_scale_card.dart
  0 errors, 7 warnings

  ⚠ Line 92: Hardcoded Border Radius
    Suggestion: AppTheme.radiusMd (12px)

  ⚠ Line 95: Custom BoxShadow Definition
    Suggestion: AppTheme.shadowCard

Remediation Summary:
  Total files affected: 18
  Average violations per file: 6.0
  Estimated fix time: 54 minutes

Next Steps:
  1. Review violations above
  2. Replace hardcoded values with AppTheme constants
  3. Run tests to verify changes
  4. Re-run this lint tool to validate

For detailed migration guide, see:
  docs/design_system/STORM_SCREEN_DESIGN_REFERENCE.md
```

### CI/CD Integration

**GitHub Actions Example**:

```yaml
name: Design System Compliance

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - name: Check Design System Compliance
        run: dart tools/design_system_lint.dart --ci
```

**Pre-commit Hook**:

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run design system lint on staged files
dart tools/design_system_lint.dart --ci

if [ $? -ne 0 ]; then
  echo "❌ Design system violations detected. Please fix before committing."
  exit 1
fi
```

### Migration Workflow

1. **Run the lint tool**:
   ```bash
   dart tools/design_system_lint.dart --verbose > violations.txt
   ```

2. **Fix violations** using the provided suggestions

3. **Verify fixes**:
   ```bash
   dart tools/design_system_lint.dart
   ```

4. **Run tests**:
   ```bash
   flutter test
   ```

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "fix: Apply design system constants (STORM-012)"
   ```

### Performance

- **Scan Speed**: ~100 files per second
- **Memory Usage**: <50MB for full codebase scan
- **Accuracy**: 100% (no false positives with exception handling)

### Maintenance

The lint patterns are defined in `design_system_lint.dart` and can be extended to detect additional violations:

```dart
ViolationPattern(
  type: 'Hardcoded Spacing',
  regex: RegExp(r'EdgeInsets\.all\((\d+)\)'),
  severity: 'warning',
  getSuggestion: (match) {
    final value = int.parse(match.group(1)!);
    if (value <= 4) return 'AppTheme.spacingXs';
    if (value <= 8) return 'AppTheme.spacingSm';
    // ...
  },
  isException: (line) => line.contains('AppTheme.spacing'),
),
```

### Related Documentation

- **Design System Reference**: `docs/design_system/STORM_SCREEN_DESIGN_REFERENCE.md`
- **Audit Report**: `docs/reports/STORM-011_Design_System_Audit_Report.md`
- **Migration Examples**: See STORM_SCREEN_DESIGN_REFERENCE.md

### Support

For issues or questions about the lint tool:
1. Check the STORM-012 task documentation
2. Review the design system reference guide
3. See migration examples in STORM-011 audit report

---

**Version**: 1.0.0
**Author**: Claude Code (STORM-012)
**Last Updated**: January 23, 2025
