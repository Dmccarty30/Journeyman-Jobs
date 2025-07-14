# Test Directory Architecture

This document outlines the reorganized test directory structure for the Journeyman Jobs Flutter project, aligned with the new lib/ architecture.

## Directory Structure

``` tree
test/
├── core/
│   └── extensions/
│       └── color_extensions_test.dart
├── data/
│   ├── models/
│   │   ├── job_model_test.dart
│   │   └── user_model_test.dart
│   ├── repositories/
│   │   └── job_repository_test.dart
│   └── services/
│       └── auth_service_test.dart
├── domain/
│   └── use_cases/
│       └── get_jobs_use_case_test.dart
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   └── auth_screen_test.dart
│   │   └── splash/
│   │       └── splash_screen_test.dart
│   ├── widgets/
│   │   └── electrical_components/
│   │       └── jj_circuit_breaker_switch_test.dart
│   └── providers/
│       ├── app_state_provider_test.dart
│       └── job_filter_provider_test.dart
├── performance/
│   ├── firestore_load_test.dart
│   └── backend_performance_test.dart
├── fixtures/
│   ├── mock_data.dart
│   └── test_constants.dart
├── helpers/
│   ├── test_helpers.dart
│   └── widget_test_helpers.dart
└── integration_test/
    ├── performance/
    └── user_flows/
```

## Key Changes Made

### 1. **Architecture Alignment**

- Test structure now mirrors the new lib/ directory organization
- Clear separation between data, domain, and presentation layers
- Dedicated directories for core utilities and extensions

### 2. **Consolidated Test Utilities**

- **`helpers/test_helpers.dart`**: Core test utilities with mocks for services
- **`helpers/widget_test_helpers.dart`**: Widget-specific test helpers and builders
- **`fixtures/mock_data.dart`**: Centralized mock data generation for all tests
- **`fixtures/test_constants.dart`**: Test configuration and constants

### 3. **Electrical Industry Focus**

- Mock data includes real IBEW local numbers and classifications
- Test constants for electrical industry standards
- Electrical component test helpers
- OWASP security testing patterns for electrical industry data

### 4. **Performance Testing**

- Dedicated performance directory for load and benchmark tests
- Memory management and rendering performance tests
- Large dataset handling tests for IBEW locals (797+ locals)

## Test Categories

### **Unit Tests**

- **Data Layer**: Models, repositories, services
- **Domain Layer**: Use cases and business logic
- **Core Extensions**: Utility functions and extensions

### **Widget Tests**

- **Presentation Layer**: Screens, widgets, providers
- **Electrical Components**: Custom electrical-themed components
- **Theme Validation**: Electrical industry color schemes

### **Integration Tests**

- **User Flows**: Complete user journeys
- **Performance**: Load testing and benchmarks

## Mock Data Patterns

### **IBEW-Specific Data**

```dart
// Real IBEW local numbers for testing
static const List<int> realIBEWLocals = [1, 3, 11, 26, 46, 58, 98, 134, ...];

// Electrical classifications
static const List<String> electricalClassifications = [
  'Inside Wireman',
  'Journeyman Lineman', 
  'Tree Trimmer',
  'Equipment Operator',
  ...
];
```

### **Industry-Standard Test Data**

- Storm work and emergency restoration scenarios
- High voltage and low voltage classification testing
- Construction type filtering (Commercial, Industrial, Utility)
- Wage range testing with realistic electrical industry wages

## Testing Best Practices

### **File Naming**

- Test files end with `_test.dart`
- Mirror the structure of the file being tested
- Group related tests in the same directory

### **Test Organization**

```dart
void main() {
  group('ComponentName Tests', () {
    test('should do something specific', () {
      // Arrange
      // Act  
      // Assert
    });
  });
  
  group('ComponentName Edge Cases', () {
    // Edge case tests
  });
}
```

### **Electrical Industry Testing**

- Validate against real IBEW standards
- Test electrical safety color schemes
- Verify accessibility for construction site use
- Performance testing for large local directories

## Migration Notes

### **Moved Files**

- `test/unit_test/providers/*` → `test/presentation/providers/`
- `test/unit_test/services/*` → `test/data/services/`
- `test/widget_test/screens/*` → `test/presentation/screens/`
- `test/widget_test/electrical_components/*` → `test/presentation/widgets/electrical_components/`
- `test/test_utils/test_helpers.dart` → `test/helpers/test_helpers.dart`

### **Updated Imports**

- All test files now use relative imports to new helper locations
- Mock data consolidated into `fixtures/mock_data.dart`
- Test constants moved to `fixtures/test_constants.dart`

### **Removed Directories**

- `test/unit_test/` (contents moved to appropriate layer directories)
- `test/widget_test/` (contents moved to presentation layer)
- `test/test_utils/` (contents moved to helpers and fixtures)
- `test/load/` (moved to performance directory)

## Missing Test Coverage Areas

### **High Priority**

- Home screen tests
- Jobs screen tests
- Locals screen tests
- Navigation tests
- Filter functionality tests

### **Medium Priority**

- Settings screen tests
- Notification tests
- Offline functionality tests
- Search functionality tests

### **Low Priority**

- Animation tests
- Theme switching tests
- Accessibility tests
- Internationalization tests

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/data/
flutter test test/presentation/
flutter test test/performance/

# Run specific test file
flutter test test/data/models/job_model_test.dart

# Run with coverage
flutter test --coverage
```

## Test Configuration

### **Environment Variables**

- `TEST_ENVIRONMENT=test`
- `MOCK_FIREBASE=true`
- `ENABLE_DEBUG_LOGS=false`

### **Test Timeouts**

- Unit tests: 5 seconds
- Widget tests: 15 seconds  
- Integration tests: 30 seconds
- Performance tests: 60 seconds

---

*This architecture supports the electrical industry focus of Journeyman Jobs while maintaining clean separation of concerns and comprehensive test coverage.*
