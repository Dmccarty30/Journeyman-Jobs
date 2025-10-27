# Quick Coder Workflow Commands

## Quick Start Commands

### Execute Mobile Refactoring

```bash
# Basic mobile code refactoring
npx claude-flow workflow execute quick-coder-mobile-refactor --target "path/to/mobile/code"

# With performance focus
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/" \
  --focus performance \
  --optimization-level aggressive

# With specific mobile platform
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "screens/" \
  --platform flutter \
  --focus responsive_design
```

### Advanced Mobile Refactoring

```bash
# Comprehensive mobile refactoring with multiple focus areas
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/screens/,lib/widgets/" \
  --focus "performance,responsive_design,accessibility" \
  --quality-standards "mobile_first,accessibility_wcag" \
  --optimization-level maximum

# Target-specific refactoring
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/screens/home_screen.dart" \
  --focus "user_experience,performance" \
  --include-tests true
```

## Mobile-Specific Options

### Performance Focus

```bash
# Mobile performance optimization
--focus performance --optimization-target "load_time,memory_usage,battery_efficiency"

# User experience enhancement
--focus "user_experience,responsive_design" --include "accessibility,animations"

# Code quality improvement
--focus "code_quality,maintainability" --standards "flutter_best_practices,dart_style_guide"
```

### Platform-Specific Commands

```bash
# Flutter mobile development
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/" \
  --platform flutter \
  --framework "provider,riverpod,go_router"

# Cross-platform mobile
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "src/" \
  --platform "react_native" \
  --framework "react_navigation,redux"
```

## Output and Reporting

### Generate Mobile Refactoring Report

```bash
# Comprehensive mobile refactoring report
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/" \
  --generate-report true \
  --report-format "html" \
  --include-metrics true
```

## Quick Reference

| Command | Purpose | Example |
|----------|---------|---------|
| `--target` | Specify code paths | `--target "lib/screens/"` |
| `--focus` | Refactoring focus area | `--focus "performance,ux"` |
| `--platform` | Mobile platform | `--platform flutter` |
| `--optimization-level` | Optimization intensity | `--optimization-level aggressive` |
| `--include-tests` | Include test generation | `--include-tests true` |
| `--generate-report` | Create detailed report | `--generate-report true` |

## Common Mobile Refactoring Scenarios

### 1. Performance Optimization

```bash
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/screens/,lib/widgets/" \
  --focus performance \
  --optimization-level aggressive \
  --metrics "load_time,memory_usage,frame_rate"
```

### 2. Responsive Design Improvement

```bash
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/widgets/,lib/components/" \
  --focus "responsive_design,accessibility" \
  --standards "material_design,guidelines"
```

### 3. Code Quality Enhancement

```bash
npx claude-flow workflow execute quick-coder-mobile-refactor \
  --target "lib/" \
  --focus "code_quality,maintainability" \
  --include-tests true \
  --quality-gates "test_coverage,performance_score"
```
