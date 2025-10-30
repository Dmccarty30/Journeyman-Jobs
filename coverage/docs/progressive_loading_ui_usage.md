# Progressive Loading UI Components

This document provides comprehensive usage examples and guidelines for the progressive loading UI components designed for the hierarchical initialization system.

## Overview

The progressive loading UI system provides a modern, professional loading experience that respects the IBEW electrical theme while giving users excellent feedback during app initialization. The system consists of 5 main components:

1. **InitializationProgressScreen** - Main progress display
2. **StageProgressIndicator** - Individual stage status
3. **FeatureAvailabilityCard** - Available vs loading features
4. **ErrorRecoveryWidget** - Error handling and retry UI
5. **BackgroundProgressIndicator** - Subtle background loading

## Quick Start

### Basic Usage with HierarchicalInitializer

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/widgets/hierarchical/hierarchical_initializer.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: HierarchicalInitializer(
        useProgressiveLoading: true,
        showInitializationScreen: true,
        strategy: HierarchicalInitializationStrategy.adaptive,
        onInitializationComplete: () {
          // Navigation to main app
          Navigator.of(context).pushReplacementNamed('/home');
        },
        child: HomeScreen(),
      ),
    );
  }
}
```

### Advanced Configuration

```dart
HierarchicalInitializer(
  useProgressiveLoading: true,
  showInitializationScreen: true,
  strategy: HierarchicalInitializationStrategy.preferredLocalsFirst,
  timeout: const Duration(seconds: 45),
  autoRetry: true,
  maxRetryAttempts: 3,
  onInitializationComplete: () {
    // Handle completion
  },
  onInitializationError: (error, stackTrace) {
    // Handle errors
    log('Initialization failed: $error');
  },
  child: MainApp(),
)
```

## Individual Components

### InitializationProgressScreen

The main progress screen that shows the complete initialization flow.

```dart
InitializationProgressScreen(
  initializationService: myInitializationService,
  onInitializationComplete: () => Navigator.pushNamed(context, '/home'),
  onSkipToAvailable: () => Navigator.pushNamed(context, '/limited-features'),
  showSkipButton: true,
  customMessage: 'Preparing your electrical career toolkit...',
)
```

**Features:**

- Real-time progress tracking with 13 stages across 5 levels
- Estimated time remaining
- Feature availability cards
- Error recovery integration
- Electrical-themed animations

### StageProgressIndicator

Individual stage progress indicator with level badges and electrical effects.

```dart
StageProgressIndicator(
  stage: InitializationStage.firebaseCore,
  progress: StageProgress(
    stage: InitializationStage.firebaseCore,
    status: StageStatus.inProgress,
    progress: 0.75,
    startTime: DateTime.now(),
  ),
  showLevelBadge: true,
  showEstimatedTime: true,
  compact: false,
  onTap: () => showStageDetails(stage),
)
```

**Styling Options:**

```dart
StageProgressIndicator(
  stage: stage,
  progress: progress,
  style: StageProgressStyle.minimal,
  compact: true,
)
```

### FeatureAvailabilityCard

Shows which features are available vs loading.

```dart
FeatureAvailabilityCard(
  features: ['Profile', 'Job Search', 'Local Directory'],
  status: FeatureStatus.available,
  title: 'Ready to Use',
  description: 'These features are now available',
  showDescriptions: true,
  layout: FeatureCardLayout.grid,
  onFeatureTap: (feature) => navigateToFeature(feature),
)
```

**Layout Options:**

- `FeatureCardLayout.grid` - Grid layout for multiple features
- `FeatureCardLayout.list` - List layout for detailed information

**Status Options:**

- `FeatureStatus.available` - Feature is ready to use
- `FeatureStatus.loading` - Feature is currently loading
- `FeatureStatus.comingSoon` - Feature will be available later

### ErrorRecoveryWidget

Comprehensive error handling and recovery UI.

```dart
ErrorRecoveryWidget(
  error: 'Network connection failed',
  stackTrace: stackTrace,
  title: 'Connection Error',
  description: 'Unable to connect to IBEW network',
  suggestedActions: [
    'Check your internet connection',
    'Try switching to cellular data',
    'Contact support if the problem persists',
  ],
  canRetry: true,
  canDismiss: false,
  showTechnicalDetails: true,
  onRetry: () => retryInitialization(),
  onContactSupport: () => openSupportChat(),
  onViewDiagnostics: () => showDiagnosticsDialog(),
)
```

### BackgroundProgressIndicator

Subtle background progress indicator for ongoing operations.

```dart
BackgroundProgressIndicator(
  progress: 0.65,
  position: BackgroundProgressPosition.top,
  height: 4.0,
  showElectricalEffects: true,
  showPercentage: false,
  message: 'Syncing data...',
  showPulse: true,
  onTap: () => showProgressDetails(),
)
```

**Position Options:**

- `BackgroundProgressPosition.top` - Top of screen
- `BackgroundProgressPosition.bottom` - Bottom of screen
- `BackgroundProgressPosition.overlay` - Overlay on content

## Integration with Existing Systems

### Connecting to HierarchicalInitializationService

```dart
class MyInitializationScreen extends StatefulWidget {
  @override
  _MyInitializationScreenState createState() => _MyInitializationScreenState();
}

class _MyInitializationScreenState extends State<MyInitializationScreen> {
  late HierarchicalInitializationService _initService;
  StreamSubscription<HierarchicalInitializationState>? _subscription;

  @override
  void initState() {
    super.initState();
    _initService = HierarchicalInitializationService();
    _subscription = _initService.initializationStateStream.listen(
      _onStateChanged,
    );
    _initService.initializeForCurrentUser();
  }

  void _onStateChanged(HierarchicalInitializationState state) {
    setState(() {
      // Update UI based on state
    });
  }

  @override
  Widget build(BuildContext context) {
    return InitializationProgressScreen(
      initializationService: _initService,
      onInitializationComplete: () {
        Navigator.of(context).pushReplacementNamed('/home');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _initService.dispose();
    super.dispose();
  }
}
```

### Custom Feature Information

Define custom features for the FeatureAvailabilityCard:

```dart
const Map<String, FeatureInfo> customFeatures = {
  'Time Tracking': FeatureInfo(
    name: 'Time Tracking',
    icon: Icons.schedule,
    description: 'Track your work hours and generate reports',
  ),
  'Safety Training': FeatureInfo(
    name: 'Safety Training',
    icon: Icons.security,
    description: 'Access safety protocols and training materials',
  ),
};

FeatureAvailabilityCard(
  features: ['Time Tracking', 'Safety Training'],
  status: FeatureStatus.comingSoon,
)
```

## Theme Customization

### Custom Colors and Styling

```dart
// Use existing AppTheme colors for consistency
Container(
  decoration: BoxDecoration(
    color: AppTheme.primaryNavy,
    gradient: AppTheme.electricalGradient,
    border: Border.all(color: AppTheme.accentCopper),
  ),
)

// Custom stage progress styling
StageProgressIndicator(
  stage: stage,
  progress: progress,
  style: StageProgressStyle(
    titleStyle: AppTheme.titleMedium.copyWith(
      color: AppTheme.accentCopper,
    ),
    borderRadius: 16.0,
    borderWidth: 2.0,
  ),
)
```

### Electrical Effects

Enable electrical-themed animations and effects:

```dart
BackgroundProgressIndicator(
  progress: 0.5,
  showElectricalEffects: true,
  showPulse: true,
  color: AppTheme.accentCopper,
)

StageProgressIndicator(
  stage: stage,
  progress: progress,
  // Electrical effects are automatic for in-progress stages
)
```

## Accessibility

### Screen Reader Support

All components include proper semantic labels:

```dart
// Automatic semantic labels
StageProgressIndicator(
  stage: stage,
  progress: progress,
  // Automatically generates: "Firebase Services stage: inProgress, 50% complete"
)

// Custom accessibility labels
BackgroundProgressIndicator(
  progress: 0.75,
  accessibilityLabel: 'Loading job database, 75% complete',
)
```

### Keyboard Navigation

All interactive elements support keyboard navigation:

```dart
FeatureAvailabilityCard(
  features: features,
  status: FeatureStatus.available,
  onFeatureTap: (feature) => _handleFeatureSelection(feature),
  // Features are automatically focusable and handle keyboard events
)
```

## Performance Considerations

### Efficient Animations

```dart
// Use efficient animation controllers
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Lazy Loading

```dart
// Only load components when needed
Widget _buildProgressContent() {
  if (!_showProgress) return SizedBox.shrink();

  return InitializationProgressScreen(
    initializationService: _service,
  );
}
```

## Error Handling

### Comprehensive Error Recovery

```dart
class RobustInitializer extends StatefulWidget {
  @override
  _RobustInitializerState createState() => _RobustInitializerState();
}

class _RobustInitializerState extends State<RobustInitializer> {
  Object? _lastError;
  int _retryCount = 0;
  static const int maxRetries = 3;

  void _handleError(Object error, StackTrace? stackTrace) {
    setState(() {
      _lastError = error;
    });

    if (_retryCount < maxRetries) {
      Future.delayed(const Duration(seconds: 2), () {
        _retryInitialization();
      });
    }
  }

  void _retryInitialization() {
    setState(() {
      _retryCount++;
      _lastError = null;
    });
    // Retry logic here
  }

  @override
  Widget build(BuildContext context) {
    if (_lastError != null) {
      return ErrorRecoveryWidget(
        error: _lastError.toString(),
        onRetry: _retryCount < maxRetries ? _retryInitialization : null,
        suggestedActions: _getSuggestedActions(),
      );
    }

    return InitializationProgressScreen(
      initializationService: _service,
    );
  }
}
```

## Testing

### Widget Testing Examples

```dart
testWidgets('progress screen shows completion state', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: InitializationProgressScreen(
        initializationService: mockService,
      ),
    ),
  );

  // Verify initial state
  expect(find.text('Powering up your electrical career tools...'), findsOneWidget);

  // Simulate completion
  mockService.complete();
  await tester.pumpAndSettle();

  // Verify completion state
  expect(find.text('All systems ready - Welcome aboard!'), findsOneWidget);
  expect(find.text('Get Started'), findsOneWidget);
});
```

### Integration Testing

```dart
testWidgets('full initialization flow', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: HierarchicalInitializer(
          useProgressiveLoading: true,
          child: HomeScreen(),
        ),
      ),
    ),
  );

  // Should show initialization screen
  expect(find.byType(InitializationProgressScreen), findsOneWidget);

  // Wait for initialization to complete
  await tester.pumpAndSettle(const Duration(seconds: 10));

  // Should show home screen
  expect(find.byType(HomeScreen), findsOneWidget);
  expect(find.byType(InitializationProgressScreen), findsNothing);
});
```

## Best Practices

### DO

- ✅ Use the electrical theme consistently (navy #1A202C, copper #B45309)
- ✅ Provide clear feedback for all initialization stages
- ✅ Allow users to proceed with available features when possible
- ✅ Handle errors gracefully with clear recovery options
- ✅ Include proper accessibility labels and semantic markup
- ✅ Test on various screen sizes and devices
- ✅ Use efficient animations that don't impact performance

### DON'T

- ❌ Don't block users from accessing available features
- ❌ Don't show technical jargon to end users
- ❌ Don't ignore error states or retry mechanisms
- ❌ Don't use inconsistent colors or styling
- ❌ Don't forget to dispose animation controllers
- ❌ Don't skip accessibility testing
- ❌ Don't assume network connectivity

## Troubleshooting

### Common Issues

**Problem:** Progress indicators not updating
**Solution:** Ensure you're listening to the initialization state stream and calling setState().

**Problem:** Electrical animations not showing
**Solution:** Check that TickerProviderStateMixin is properly implemented and controllers are initialized.

**Problem:** Features showing as unavailable when they should be ready
**Solution:** Verify the feature availability logic matches the initialization phase completion.

**Problem:** Error recovery not working
**Solution:** Ensure error states are properly propagated and retry logic is implemented.

### Debug Tips

```dart
// Enable debug logging
HierarchicalInitializationService(
  debugMode: true,
);

// Check initialization state
print('Current phase: ${service.currentState.phase}');
print('Is completed: ${service.currentState.isCompleted}');
print('Has error: ${service.currentState.hasError}');

// Monitor progress stream
service.initializationStateStream.listen((state) {
  print('State changed: $state');
});
```

## Migration Guide

### From Simple Loading to Progressive Loading

**Before:**

```dart
if (isLoading) {
  return CircularProgressIndicator();
} else {
  return child;
}
```

**After:**

```dart
HierarchicalInitializer(
  useProgressiveLoading: true,
  showInitializationScreen: true,
  child: child,
)
```

### From Basic Error Handling to ErrorRecoveryWidget

**Before:**

```dart
if (error != null) {
  return Text('Error: $error');
}
```

**After:**

```dart
ErrorRecoveryWidget(
  error: error.toString(),
  onRetry: retryFunction,
  suggestedActions: ['Check connection', 'Try again'],
)
```

This comprehensive progressive loading UI system provides a modern, professional experience that enhances user engagement during app initialization while maintaining the electrical industry aesthetic of the Journeyman Jobs application.
