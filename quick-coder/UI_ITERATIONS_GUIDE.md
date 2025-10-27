# UI Iterations Workflow - Quick Reference Guide

## Overview

The **UI Iterations** workflow is a comprehensive, reusable template designed for iterative UI development on the Storm Screen (and adaptable to other screens) with full electrical theme compliance.

## Features

✅ **6 Automated Stages**

- Design Review & Planning
- Component Implementation
- Theme & Design System Validation
- Testing & Performance Benchmarking
- Documentation & Screenshots
- User Approval & Deployment

✅ **Electrical Theme Enforcement**

- Validates AppTheme color usage (Navy #1A202C, Copper #B45309)
- Checks JJ-prefixed component compliance
- Verifies circuit patterns and lightning animations
- Ensures electrical motifs throughout

✅ **Automated Testing**

- Widget tests with 80% minimum coverage
- Performance benchmarks (60fps target)
- Accessibility compliance (WCAG AA)
- Memory usage monitoring

✅ **Iterative Refinement**

- Supports up to 10 iteration cycles
- Checkpoint-based progression
- User approval gates
- Continuous improvement loop

## Quick Start

### Execute the Workflow

```bash
# Interactive mode (recommended for first run)
npx claude-flow workflow execute ui-iterations --interactive

# Standard execution
npx claude-flow workflow execute ui-iterations

# With specific iteration count
npx claude-flow workflow execute ui-iterations --max-iterations 5
```

### Workflow Stages Breakdown

#### Stage 1: Design Review (5-10 min)

**What it does:**

- Analyzes [guide/screens.md](guide/screens.md) for Storm Screen requirements
- Validates current electrical theme compliance
- Creates prioritized iteration roadmap

**Outputs:**

- Requirements summary
- Component checklist
- Design gaps report
- Iteration plan

#### Stage 2: Component Updates (20-40 min)

**What it does:**

- Updates Storm Screen layout with responsive design
- Implements navigation with electrical animations
- Adds flutter_animate transitions
- Creates JJElectricalLoader variants

**Files Modified:**

- `lib/screens/storm/storm_screen.dart`
- `lib/widgets/storm/*.dart`
- `lib/navigation/app_router.dart`
- `lib/electrical_components/*.dart`

#### Stage 3: Design System Validation (5-10 min)

**What it does:**

- Validates all colors use AppTheme constants
- Checks component naming (JJ prefix)
- Verifies typography consistency
- Reviews animation performance

**Checks:**

- ✅ No hardcoded colors
- ✅ WCAG AA contrast ratios
- ✅ 60fps animation performance
- ✅ Accessibility support

#### Stage 4: Testing & Performance (10-20 min)

**What it does:**

- Runs widget tests for Storm Screen
- Benchmarks rendering performance
- Tests accessibility compliance
- Measures memory usage

**Commands Executed:**

```bash
flutter test test/screens/storm/storm_screen_test.dart
flutter test test/widgets/storm/
flutter run --profile --trace-startup
```

**Success Criteria:**

- Widget test coverage: ≥80%
- Frame rate: ≥60fps
- Memory usage: ≤150MB
- Startup time: ≤2000ms

#### Stage 5: Documentation (5-15 min)

**What it does:**

- Captures screenshots (main, loading, animations)
- Updates code documentation
- Updates guide/screens.md
- Updates TASK.md with progress

**Outputs:**

- `screenshots/storm_screen_main.png`
- `screenshots/storm_screen_loading.png`
- `screenshots/storm_screen_animations.gif`
- Updated documentation files

#### Stage 6: Review & Deploy (5-10 min)

**What it does:**

- Presents changes summary for approval
- Shows test results and metrics
- Displays screenshots
- Commits and pushes approved changes

**Requires:** Your approval to proceed

## Customization

### Adapt for Different Screens

To use this workflow for screens other than Storm Screen, modify the `scope` section:

```yaml
scope:
  primary_screen: jobs_screen  # Change this
  components:
    - job_cards
    - filter_bar
    - search_functionality
  theme_compliance: electrical
```

### Adjust Iteration Settings

```yaml
iteration:
  max_cycles: 5  # Reduce for faster iterations
  checkpoint_stages:
    - design_review
    - testing_validation  # Skip review_deploy for faster cycles
```

### Customize Performance Targets

```yaml
metrics:
  target_fps: 60
  max_memory_mb: 100  # Stricter limit
  startup_time_ms: 1500  # Faster target
```

## Electrical Theme Checklist

Every iteration automatically validates:

- [ ] Colors use `AppTheme.primaryNavy` and `AppTheme.accentCopper`
- [ ] Custom components have `JJ` prefix
- [ ] `CircuitPatternBackground` integrated where appropriate
- [ ] Animations use electrical motifs (lightning, sparks, circuits)
- [ ] Loading states use `JJElectricalLoader`
- [ ] Typography uses `AppTheme` text styles
- [ ] Spacing follows 8px grid system
- [ ] Icons are electrical-themed (bolt, plug, circuit)

## Troubleshooting

### Tests Failing

The workflow will **pause** if widget tests fail. To continue:

1. Review test failures in console output
2. Fix failing tests manually
3. Re-run workflow from checkpoint

### Performance Issues

If performance benchmarks show <60fps:

1. Workflow will **flag** the issue but allow continuation
2. Review animation complexity
3. Check for unnecessary rebuilds
4. Optimize widget tree depth

### Theme Violations

The workflow will **pause** if theme violations are detected:

1. Review flagged components
2. Replace hardcoded colors with `AppTheme` constants
3. Ensure component naming follows `JJ` prefix convention
4. Re-run validation stage

## Integration with Project Workflow

### Pre-Workflow

1. Review current Storm Screen implementation
2. Gather any design feedback or requirements
3. Ensure Flutter environment is set up

### Post-Workflow

1. Test manually on physical device
2. Verify all animations feel smooth
3. Check electrical theme consistency
4. Update TASK.md with completion notes

## Example Iteration Cycle

```dart
┌─────────────────────────────────────────┐
│ Iteration 1: Initial Layout             │
├─────────────────────────────────────────┤
│ - Design Review: Identify gaps          │
│ - Implementation: Basic layout          │
│ - Validation: Theme compliance          │
│ - Testing: Widget tests                 │
│ - Documentation: Screenshots            │
│ - Approval: User reviews                │
└─────────────────────────────────────────┘
              ↓ User requests changes
┌─────────────────────────────────────────┐
│ Iteration 2: Navigation & Animations    │
├─────────────────────────────────────────┤
│ - Design Review: Check navigation        │
│ - Implementation: Add animations         │
│ - Validation: Performance check          │
│ - Testing: Benchmark 60fps               │
│ - Documentation: Update guide            │
│ - Approval: Final review                 │
└─────────────────────────────────────────┘
              ↓ Approved
┌─────────────────────────────────────────┐
│ Deployment: Commit & Push                │
└─────────────────────────────────────────┘
```

## Tips for Success

1. **Start Small**: Focus on one component per iteration
2. **Test Early**: Don't skip the testing stage
3. **Theme First**: Always validate electrical theme compliance
4. **Performance Matters**: Monitor 60fps target throughout
5. **Document Everything**: Update docs as you go
6. **Iterate Quickly**: Use checkpoints for fast cycles

## Files Generated

After running this workflow, you'll have:

```dart
d:\Journeyman-Jobs/
├── lib/
│   ├── screens/storm/
│   │   └── storm_screen.dart (updated)
│   ├── widgets/storm/
│   │   └── *.dart (new/updated)
│   └── electrical_components/
│       └── *.dart (new/updated)
├── test/
│   └── screens/storm/
│       └── storm_screen_test.dart (new/updated)
├── screenshots/
│   ├── storm_screen_main.png
│   ├── storm_screen_loading.png
│   └── storm_screen_animations.gif
└── guide/
    └── screens.md (updated)
```

## Version History

- **v1.0.0** (2025-02-01): Initial workflow creation
  - 6-stage comprehensive UI iteration process
  - Electrical theme validation
  - Widget testing and performance benchmarks
  - Storm Screen focus with adaptability

---

## Support

For questions or issues with this workflow:

1. Check [CLAUDE.md](../CLAUDE.md) for project guidelines
2. Review [guide/screens.md](../../guide/screens.md) for Storm Screen specs
3. Consult [TASK.md](../../TASK.md) for current project status

**Pro Tip**: Use `--interactive` mode for your first few runs to understand each stage. Once comfortable, switch to standard execution for faster iterations.
