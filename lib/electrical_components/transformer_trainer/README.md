# Transformer Trainer API Documentation

## Overview

The Transformer Trainer module provides an interactive educational interface for learning electrical transformer bank connections. This module is designed specifically for electrical workers, including journeymen, linemen, and operators who need to understand transformer configurations used in power distribution systems.

## Key Features

- **Interactive Learning**: Touch-based connection interface optimized for mobile devices
- **Multiple Bank Types**: Support for all common transformer configurations
- **Progressive Difficulty**: Beginner to advanced skill levels
- **Real-time Validation**: Immediate feedback on connection attempts
- **Electrical Safety**: Industry-standard safety considerations and warnings
- **Accessibility**: WCAG-compliant design with haptic feedback

## Module Structure

``` tree
transformer_trainer/
├── jj_transformer_trainer.dart     # Main widget entry point
├── models/
│   └── transformer_models.dart     # Data models and enums
├── state/
│   └── transformer_state.dart      # State management
├── widgets/
│   ├── connection_point.dart       # Interactive connection points
│   ├── trainer_widget.dart         # Core training interface
│   └── transformer_diagram.dart    # Visual transformer diagrams
├── modes/
│   ├── guided_mode.dart            # Step-by-step learning
│   └── quiz_mode.dart              # Assessment mode
├── painters/
│   ├── base_transformer_painter.dart    # Base drawing class
│   ├── wye_wye_painter.dart            # Wye-Wye configuration
│   ├── wye_delta_painter.dart          # Wye-Delta configuration
│   ├── delta_wye_painter.dart          # Delta-Wye configuration
│   ├── delta_delta_painter.dart        # Delta-Delta configuration
│   └── open_delta_painter.dart         # Open Delta configuration
├── animations/
│   ├── flash_animation.dart        # Connection feedback
│   └── success_animation.dart      # Completion celebration
└── utils/
    ├── performance_manager.dart    # Optimization utilities
    ├── accessibility_manager.dart  # A11y support
    └── mobile_optimizations.dart   # Mobile-specific features
```

## Core Classes

### JJTransformerTrainer

The main entry point widget for the transformer training interface.

```dart
class JJTransformerTrainer extends StatelessWidget {
  const JJTransformerTrainer({
    Key? key,
    this.initialBankType = TransformerBankType.wyeToWye,
    this.initialMode = TrainingMode.guided,
    this.initialDifficulty = DifficultyLevel.beginner,
    this.onStepComplete,
    this.onBankComplete,
    this.onError,
  });
}
```

**Parameters:**

- `initialBankType`: Starting transformer configuration
- `initialMode`: Training approach (guided vs quiz)
- `initialDifficulty`: Content complexity level
- `onStepComplete`: Callback for tracking learning progress
- `onBankComplete`: Callback for completion events
- `onError`: Error handling callback

### TransformerBankType

Enumeration of supported transformer bank configurations:

```dart
enum TransformerBankType {
  wyeToWye,      // Most common distribution configuration
  wyeToDelta,    // Step-up applications
  deltaToWye,    // Step-down with neutral
  deltaToDelta,  // Industrial applications
  openDelta,     // Emergency/temporary service
}
```

### ConnectionPoint

Represents an electrical connection terminal on a transformer:

```dart
class ConnectionPoint {
  const ConnectionPoint({
    required this.id,
    required this.label,
    required this.type,
    required this.position,
    required this.isInput,
  });

  final String id;              // Unique identifier (e.g., 'H1', 'X1')
  final String label;           // Display name
  final ConnectionType type;    // Primary, secondary, neutral, or ground
  final Offset position;        // Screen coordinates
  final bool isInput;          // Input vs output terminal
}
```

### ConnectionType

Classification of electrical connection terminals:

```dart
enum ConnectionType {
  primary,    // High voltage side (H1, H2, H3)
  secondary,  // Low voltage side (X1, X2, X3)
  neutral,    // Neutral connection point
  ground,     // Equipment grounding
}
```

### TrainingState

Immutable state object representing the current training session:

```dart
class TrainingState {
  const TrainingState({
    this.bankType = TransformerBankType.wyeToWye,
    this.mode = TrainingMode.guided,
    this.difficulty = DifficultyLevel.beginner,
    this.currentStep = 0,
    this.connections = const [],
    this.isComplete = false,
    this.errors = const [],
  });

  TrainingState copyWith({...}) => ...;
}
```

### WireConnection

Represents a connection between two transformer terminals:

```dart
class WireConnection {
  const WireConnection({
    required this.from,
    required this.to,
    this.isCorrect,
    this.phaseShift,
  });

  final ConnectionPoint from;    // Source terminal
  final ConnectionPoint to;      // Destination terminal
  final bool? isCorrect;        // Validation result
  final int? phaseShift;        // Phase relationship (degrees)
}
```

## Training Modes

### Guided Mode

Step-by-step learning with detailed instructions:

- Progressive disclosure of connection steps
- Contextual hints and safety warnings
- Common mistake prevention
- Real-world application examples

### Quiz Mode

Self-assessment without guidance:

- Timed challenges
- Scoring system
- Performance analytics
- Certification preparation

## Difficulty Levels

### Beginner

- Basic Wye-Wye connections
- Detailed step-by-step guidance
- Safety focus
- Standard distribution scenarios

### Intermediate

- Multiple bank types
- Moderate guidance
- Phase relationship concepts
- Industrial applications

### Advanced

- Complex configurations
- Minimal guidance
- Troubleshooting scenarios
- Emergency procedures

## Usage Examples

### Basic Implementation

```dart
import 'package:journeyman_jobs/electrical_components/transformer_trainer/jj_transformer_trainer.dart';

class TransformerTrainingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transformer Bank Training'),
      ),
      body: JJTransformerTrainer(
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      ),
    );
  }
}
```

### Advanced Configuration

```dart
class AdvancedTrainingScreen extends StatefulWidget {
  @override
  _AdvancedTrainingScreenState createState() => _AdvancedTrainingScreenState();
}

class _AdvancedTrainingScreenState extends State<AdvancedTrainingScreen> {
  int completedSteps = 0;
  List<TransformerBankType> completedBanks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JJTransformerTrainer(
        initialBankType: TransformerBankType.deltaToWye,
        initialMode: TrainingMode.quiz,
        initialDifficulty: DifficultyLevel.advanced,
        onStepComplete: (step) {
          setState(() {
            completedSteps++;
          });
          _trackProgress(step);
        },
        onBankComplete: (bankType) {
          setState(() {
            completedBanks.add(bankType);
          });
          _awardCertificate(bankType);
        },
        onError: (error) {
          _logError(error);
          _showErrorDialog(error);
        },
      ),
    );
  }

  void _trackProgress(TrainingStep step) {
    // Analytics integration
    AnalyticsService.trackEvent('training_step_complete', {
      'step_id': step.id,
      'duration': step.duration?.inSeconds,
      'attempts': step.attemptCount,
    });
  }

  void _awardCertificate(TransformerBankType bankType) {
    // Certificate generation
    CertificateService.generateCertificate(
      userId: UserService.currentUserId,
      bankType: bankType,
      difficulty: DifficultyLevel.advanced,
    );
  }
}
```

### Custom Theme Integration

```dart
class ThemedTrainerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme.copyWith(
        // Custom electrical theme overrides
        primaryColor: AppTheme.primaryNavy,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppTheme.primaryNavy,
          secondary: AppTheme.accentCopper,
        ),
      ),
      child: JJTransformerTrainer(
        // Trainer inherits custom theme
      ),
    );
  }
}
```

## Error Handling

The transformer trainer implements comprehensive error handling:

### Error Types

1. **Initialization Errors**: State setup failures
2. **Validation Errors**: Incorrect connections
3. **Rendering Errors**: UI component failures
4. **Performance Errors**: Memory or animation issues

### Error Callbacks

```dart
JJTransformerTrainer(
  onError: (String error) {
    // Handle different error types
    if (error.contains('initialization')) {
      _handleInitError(error);
    } else if (error.contains('connection')) {
      _handleConnectionError(error);
    } else {
      _handleGenericError(error);
    }
  },
)
```

### Error Recovery

The trainer provides automatic error recovery:

- State validation and correction
- Graceful UI fallbacks
- User-friendly error messages
- Retry mechanisms

## Performance Considerations

### Optimization Features

- **Lazy Loading**: Components load on demand
- **Paint Caching**: Diagram elements cached for reuse
- **Animation Batching**: Smooth 60fps performance
- **Memory Management**: Automatic cleanup of resources

### Mobile Optimizations

- **Touch Targets**: 44pt minimum for accessibility
- **Haptic Feedback**: Tactile connection confirmation
- **Battery Efficiency**: Optimized animation cycles
- **Responsive Layout**: Adapts to screen sizes

## Accessibility

### WCAG Compliance

- **Color Contrast**: 4.5:1 ratio for all text
- **Focus Management**: Keyboard navigation support
- **Screen Readers**: Semantic markup and labels
- **Motor Accessibility**: Large touch targets

### Assistive Features

- **Voice Guidance**: Audio descriptions (optional)
- **High Contrast**: Alternative color schemes
- **Reduced Motion**: Respect motion preferences
- **Text Scaling**: Dynamic type support

## Testing

### Test Coverage

The module includes comprehensive test suites:

- **Unit Tests**: Model validation, state management
- **Widget Tests**: UI component behavior
- **Integration Tests**: End-to-end training flows
- **Performance Tests**: Animation and rendering

### Running Tests

```bash
# Run all transformer trainer tests
flutter test test/electrical_components/transformer_trainer/

# Run specific test suites
flutter test test/electrical_components/transformer_trainer/jj_transformer_trainer_test.dart
flutter test test/electrical_components/transformer_trainer/connection_point_test.dart
flutter test test/data/models/transformer_models_test.dart
```

## Safety Considerations

### Educational Disclaimer

This training tool is for educational purposes only. Always follow proper electrical safety procedures and local electrical codes when working with actual transformer installations.

### Safety Features

- **Lockout/Tagout Reminders**: Safety procedure prompts
- **PPE Notifications**: Personal protective equipment alerts
- **Hazard Warnings**: Electrical safety considerations
- **Code Compliance**: References to electrical standards

## Future Enhancements

### Planned Features

- **AR Visualization**: Augmented reality transformer models
- **Multi-language Support**: Internationalization
- **Advanced Analytics**: Learning pattern analysis
- **Collaborative Mode**: Team training exercises

### Extensibility

The module is designed for easy extension:

- **Custom Bank Types**: Add new transformer configurations
- **Plugin Architecture**: Third-party training modules
- **API Integration**: External learning management systems
- **Custom Themes**: Branding and visual customization

## Support

For technical support, feature requests, or bug reports:

- **Documentation**: Reference this API documentation
- **Examples**: Check the example implementations
- **Issues**: File GitHub issues for bugs
- **Community**: Join the Journeyman Jobs developer community

## License

This module is part of the Journeyman Jobs application and follows the project's licensing terms.
