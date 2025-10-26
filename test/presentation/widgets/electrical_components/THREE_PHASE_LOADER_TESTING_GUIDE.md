# Three-Phase Sine Wave Loader Testing Guide

## Overview

This comprehensive testing suite ensures the reliability, performance, and accessibility of the three-phase sine wave loader widget. The loader represents electrical three-phase power systems with accurate 120° phase separation and industry-standard color coding.

## Test Coverage Areas

### 1. Widget Rendering Tests
- **Default Properties**: Validates proper initialization with default values
- **Custom Dimensions**: Tests responsive sizing and constraint handling
- **Color Customization**: Verifies phase color configuration
- **Theme Integration**: Ensures proper electrical theme color usage
- **Container Constraints**: Tests behavior within different parent widgets

### 2. Animation Behavior Tests
- **Animation Lifecycle**: Validates start, progression, and disposal
- **Continuous Animation**: Ensures smooth, uninterrupted animation
- **Duration Configuration**: Tests custom animation timing
- **Interruption Handling**: Validates behavior during rapid changes
- **Property Updates**: Tests dynamic configuration changes

### 3. Three-Phase Physics Tests
- **Electrical Accuracy**: Validates 120° phase separation
- **Color Standards**: Ensures industry-standard phase colors
- **Wave Patterns**: Tests realistic AC sine wave rendering
- **Meter Aesthetics**: Validates electrical control panel appearance

### 4. Performance Tests
- **Multi-Instance**: Tests efficiency with multiple loaders
- **Memory Management**: Validates no memory leaks
- **Frame Rate**: Ensures 60fps target performance
- **System Load**: Tests behavior under resource pressure

### 5. Accessibility Tests
- **High Contrast**: Validates theme adaptation
- **Reduced Motion**: Tests accessibility preference handling
- **Screen Readers**: Ensures proper semantic labeling
- **Large Text**: Tests text scaling support

### 6. Integration Tests
- **Firebase Loading**: Simulates real-world loading scenarios
- **Navigation**: Tests behavior within screen transitions
- **Component Interaction**: Validates compatibility with other components

### 7. Edge Case Tests
- **Minimum/Maximum Size**: Tests boundary conditions
- **Null Values**: Validates graceful error handling
- **Zero/Long Duration**: Tests extreme timing values
- **Rapid Changes**: Tests stability under rapid modifications

### 8. Visual Regression Tests
- **Consistency**: Ensures visual appearance stability
- **Animation Phases**: Validates animation cycle consistency

## Running Tests

### Individual Test Suite
```bash
flutter test test/presentation/widgets/electrical_components/three_phase_sine_wave_loader_test.dart
```

### Specific Test Groups
```bash
# Widget rendering tests only
flutter test --name="Widget Rendering"

# Animation tests only
flutter test --name="Animation Behavior"

# Performance tests only
flutter test --name="Performance"
```

### With Coverage Report
```bash
flutter test --coverage test/presentation/widgets/electrical_components/three_phase_sine_wave_loader_test.dart
genhtml coverage/lcov.info -o coverage/html
```

## Performance Benchmarking

### Running Benchmarks
```dart
import 'package:flutter_test/flutter_test.dart';
import 'three_phase_loader_benchmark.dart';

void main() {
  test('Run all benchmarks', () async {
    final results = await ThreePhaseLoaderBenchmarkSuite.runAllBenchmarks();

    // Results will be printed to console
    expect(results, isNotEmpty);
  });
}
```

### Individual Benchmarks
```dart
// Memory benchmark
final memoryResult = await ThreePhaseLoaderBenchmark.runMemoryBenchmark();
print(memoryResult);

// Animation benchmark
final animationResult = await ThreePhaseLoaderBenchmark.runAnimationBenchmark();
print(animationResult);

// System load benchmark
final loadResult = await ThreePhaseLoaderBenchmark.runSystemLoadBenchmark();
print(loadResult);
```

## Performance Targets

### Animation Performance
- **Target Frame Rate**: 60fps (16.67ms per frame)
- **Acceptable Minimum**: 48fps (20.83ms per frame)
- **Frame Time Variance**: < 5ms

### Memory Usage
- **Peak Memory**: < 200MB for single instance
- **Memory Growth**: < 50MB over 10-second test
- **Memory Leaks**: Zero memory leaks detected

### CPU Utilization
- **Average Usage**: < 20% CPU
- **Peak Usage**: < 50% CPU
- **CPU Variance**: < 10%

### System Load
- **Sustainable Instances**: 50+ concurrent loaders
- **Performance Degradation**: < 50% at maximum load
- **Recovery Time**: < 100ms after load reduction

## Electrical Industry Requirements

### Three-Phase Color Standards
The loader must use industry-standard three-phase colors:
- **Phase 1 (L1)**: Copper/Orange/Brown (`#B45309`)
- **Phase 2 (L2)**: Blue/Black/Gray (`#3182CE`)
- **Phase 3 (L3)**: Green/Red (`#38A169`)

### Physics Accuracy
- **Phase Separation**: Exactly 120° (2π/3 radians)
- **Wave Frequency**: 2 complete cycles across width
- **Amplitude**: 30% of widget height
- **Animation**: Continuous smooth rotation

### Electrical Aesthetics
- **Meter Design**: Resembles electrical gauge instruments
- **Professional Appearance**: Suitable for industrial control panels
- **Circuit Integration**: Fits with electrical component design system

## Accessibility Compliance

### WCAG 2.1 AA Standards
- **Contrast Ratio**: Minimum 4.5:1 for normal text
- **Animation Control**: Respect reduced motion preferences
- **Screen Reader**: Proper semantic labels
- **Keyboard Navigation**: Not applicable (animation only)

### Testing Accessibility
```dart
testWidgets('should support screen readers', (tester) async {
  await tester.pumpWidget(
    WidgetTestHelpers.createTestApp(
      child: Semantics(
        label: 'Three phase power loading indicator',
        child: const ThreePhaseSineWaveLoader(),
      ),
    ),
  );

  expect(find.bySemanticsLabel('Three phase power loading indicator'), findsOneWidget);
});
```

## Test Data and Mocks

### Electrical Theme Colors
```dart
const electricalColors = ElectricalColors(
  phase1: Color(0xFFB45309), // Copper
  phase2: Color(0xFF3182CE), // Blue
  phase3: Color(0xFF38A169), // Green
);
```

### Test Scenarios
- **Normal Loading**: Standard 2-second animation
- **Quick Loading**: 500ms animation for fast operations
- **Extended Loading**: 5+ second animation for long processes
- **Error State**: Loading with error indication
- **Success State**: Loading with completion indication

## Continuous Integration

### GitHub Actions Configuration
```yaml
name: Three-Phase Loader Tests

on:
  push:
    paths:
      - 'lib/electrical_components/three_phase_sine_wave_loader.dart'
      - 'test/presentation/widgets/electrical_components/three_phase_sine_wave_loader_test.dart'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Run widget tests
        run: flutter test test/presentation/widgets/electrical_components/three_phase_sine_wave_loader_test.dart --coverage

      - name: Run performance benchmarks
        run: flutter test test/presentation/widgets/electrical_components/three_phase_loader_benchmark.dart

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
```

### Test Quality Gates
- **Test Coverage**: > 90% line coverage
- **Performance**: All benchmarks must pass
- **Accessibility**: All accessibility tests must pass
- **Memory**: No memory leaks detected

## Debugging and Troubleshooting

### Common Issues

#### Animation Not Starting
```dart
// Ensure widget is properly mounted
await tester.pumpWidget(app);
await tester.pumpAndSettle(); // Important for initialization

// Check animation controller state
expect(find.byType(AnimatedBuilder), findsOneWidget);
```

#### Performance Issues
```dart
// Use Flutter DevTools for performance profiling
// Run: flutter run --profile
// Open: http://localhost:8080

// Check frame times with benchmarking
final result = await ThreePhaseLoaderBenchmark.runAnimationBenchmark();
print(result.metrics);
```

#### Memory Leaks
```dart
// Run memory benchmark
final result = await ThreePhaseLoaderBenchmark.runMemoryBenchmark();
if (!result.success) {
  print('Memory issues detected:');
  print(result.metrics);
}
```

### Performance Profiling
1. **Enable Flutter DevTools**
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

2. **Profile Widget Performance**
   ```bash
   flutter run --profile --trace-startup
   ```

3. **Analyze with Golden Tests**
   ```bash
   flutter test --update-goldens test/presentation/widgets/electrical_components/
   ```

## Maintenance and Updates

### Adding New Tests
1. Follow existing test patterns and naming conventions
2. Include electrical industry specific test cases
3. Add performance benchmarks for new features
4. Update documentation with new test scenarios

### Updating Performance Targets
1. Monitor real-world performance metrics
2. Adjust targets based on device capabilities
3. Update benchmark thresholds accordingly
4. Document changes in this guide

### Test Data Updates
1. Keep electrical color codes current with industry standards
2. Update test scenarios based on user feedback
3. Add new edge cases as they're discovered
4. Maintain mock data consistency

## References

### Electrical Standards
- [IEC 60446: Basic and safety principles for man-machine interface](https://webstore.iec.ch/preview/info_iec60446%7Bed1.0%7Den.pdf)
- [NFPA 70: National Electrical Code](https://www.nfpa.org/codes-and-standards/all-codes-and-standards/list-of-codes-and-standards/detail?code=70)
- [Three-Phase Power Systems](https://en.wikipedia.org/wiki/Three-phase_electric_power)

### Flutter Testing
- [Flutter Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/)
- [Performance Testing](https://docs.flutter.dev/cookbook/testing/performance/)
- [Accessibility Testing](https://docs.flutter.dev/cookbook/testing/accessibility/)

### Industry Best Practices
- [Material Design Loading Indicators](https://material.io/components/progress-activity)
- [iOS Human Interface Guidelines - Activity Indicators](https://developer.apple.com/design/human-interface-guidelines/ios/views/progress-indicators/)
- [Android Design Guidelines - Progress & Activity](https://material.io/design/components/progress-activity.html)

---

**Last Updated**: 2025-01-XX
**Maintained by**: Flutter Testing Team
**Version**: 1.0.0