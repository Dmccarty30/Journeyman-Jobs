# Journeyman Jobs - Code Style & Conventions

## Dart/Flutter Standards
- **Linting**: Uses `package:flutter_lints/flutter.yaml` with standard Flutter lints
- **Null Safety**: All code uses null safety (Dart 3.6.0+)
- **Formatting**: Standard Dart formatting with `dart format`
- **Analysis**: Configured in `analysis_options.yaml`

## Naming Conventions

### Files and Directories
- **Files**: snake_case (e.g., `job_model.dart`, `auth_service.dart`)
- **Directories**: snake_case (e.g., `electrical_components/`, `user_settings/`)
- **Test Files**: `{filename}_test.dart` (mirrors source structure)

### Classes and Components
- **Classes**: PascalCase (e.g., `JobModel`, `AuthService`)
- **Custom Components**: `JJ` prefix + PascalCase (e.g., `JJButton`, `JJElectricalLoader`)
- **Widgets**: PascalCase ending with descriptive type (e.g., `JobCardWidget`, `LocalsScreen`)

### Variables and Functions
- **Variables**: camelCase (e.g., `userName`, `jobListings`)
- **Functions**: camelCase (e.g., `fetchJobs()`, `validateUser()`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `API_BASE_URL`, `MAX_RETRY_ATTEMPTS`)
- **Private Members**: Leading underscore (e.g., `_privateMethod()`, `_internalState`)

### Electrical Industry Specific
- **IBEW Terms**: Maintain official terminology (e.g., `IBEWLocal`, `JourneymanLineman`)
- **Classifications**: Use official IBEW classifications
  - Inside Wireman
  - Journeyman Lineman
  - Tree Trimmer
  - Equipment Operator

## File Organization

### Import Order
1. Dart core libraries
2. Flutter framework libraries  
3. Third-party packages (pub.dev)
4. Local project imports (relative)

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/job_model.dart';
import '../services/auth_service.dart';
```

### Directory Structure
- **Feature-based**: Each major feature gets its own directory
- **Layer separation**: Clear separation between data, domain, presentation
- **Shared components**: Common widgets in `/widgets`, design system in `/design_system`

## Code Documentation

### Class Documentation
```dart
/// A card displaying IBEW union local information.
/// 
/// Shows local number, address, and classifications.
/// Tapping opens full details in [LocalDetailScreen].
class UnionCard extends StatelessWidget {
  /// The union local data to display
  final UnionModel union;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  const UnionCard({
    Key? key,
    required this.union,
    this.onTap,
  }) : super(key: key);
```

### Function Documentation
```dart
/// Fetches jobs based on user preferences.
/// 
/// Returns a list of [JobModel] sorted by relevance.
/// Throws [FirebaseException] if network fails.
Future<List<JobModel>> fetchPersonalizedJobs({
  required String userId,
  int limit = 20,
}) async {
  try {
    // Implementation
  } catch (e) {
    // Error handling
  }
}
```

## Design System Integration

### Theme Usage
```dart
// Always use AppTheme constants
Container(
  color: AppTheme.primaryNavy,
  child: Text(
    'IBEW Local 123',
    style: AppTheme.headingLarge.copyWith(
      color: AppTheme.accentCopper,
    ),
  ),
)

// Avoid hardcoded values
Container(
  color: Color(0xFF1A202C), // ❌ Don't do this
  child: Text('Content'),
)
```

### Component Prefixing
- **Custom Components**: Always use `JJ` prefix
- **Electrical Theme**: Incorporate electrical elements and animations
- **Consistency**: Follow established patterns for similar components

```dart
// ✅ Correct naming
class JJElectricalLoader extends StatefulWidget { ... }
class JJCircuitBreakerSwitch extends StatelessWidget { ... }

// ❌ Incorrect naming  
class ElectricalLoader extends StatefulWidget { ... }
class CircuitSwitch extends StatelessWidget { ... }
```

## State Management Patterns

### Provider Pattern (Legacy)
```dart
// Provider usage for backward compatibility
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
```

### Riverpod Pattern (Preferred)
```dart
// Modern Riverpod approach with code generation
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() => null;
  
  void updateUser(User user) {
    state = user;
  }
}
```

## Error Handling

### Exception Patterns
```dart
// Comprehensive error handling
try {
  final jobs = await _jobService.fetchJobs();
  return jobs;
} on FirebaseException catch (e) {
  _logger.error('Firebase error: ${e.code}', e);
  throw JobFetchException('Failed to load jobs: ${e.message}');
} catch (e) {
  _logger.error('Unexpected error fetching jobs', e);
  throw JobFetchException('An unexpected error occurred');
}
```

### Null Safety
```dart
// Proper null safety usage
String? getUserName() => _currentUser?.displayName;

// Null-aware operators
final name = user?.displayName ?? 'Unknown User';
final jobs = await jobService.fetchJobs() ?? <Job>[];
```

## Testing Conventions

### Test Structure
```dart
void main() {
  group('ComponentName Tests', () {
    test('should do something specific', () {
      // Arrange
      final input = createTestInput();
      
      // Act
      final result = performAction(input);
      
      // Assert
      expect(result, equals(expectedOutput));
    });
  });
  
  group('ComponentName Edge Cases', () {
    // Edge case tests
  });
}
```

### Mock Data Patterns
```dart
// IBEW-specific test data
static const List<int> realIBEWLocals = [1, 3, 11, 26, 46, 58, 98, 134];

static const List<String> electricalClassifications = [
  'Inside Wireman',
  'Journeyman Lineman', 
  'Tree Trimmer',
  'Equipment Operator',
];
```

## Performance Considerations

### Widget Building
```dart
// Prefer const constructors
const Text('Static text');

// Use const for static widgets
const SizedBox(height: 16);

// Avoid unnecessary rebuilds
class OptimizedWidget extends StatefulWidget {
  const OptimizedWidget({Key? key}) : super(key: key);
}
```

### Memory Management
- Dispose controllers and streams properly
- Use `const` constructors where possible
- Implement efficient list building with ListView.builder()
- Cache expensive computations

## Electrical Industry Standards

### Safety First
- Follow electrical safety color schemes
- Validate against OSHA standards where applicable
- Use appropriate electrical terminology
- Consider construction site accessibility

### IBEW Compliance
- Maintain official IBEW local numbers and classifications  
- Respect union terminology and standards
- Handle sensitive union data appropriately
- Follow electrical industry best practices