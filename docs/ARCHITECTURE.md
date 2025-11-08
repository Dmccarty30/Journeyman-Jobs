# Journeyman Jobs Architecture Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [Project Structure](#project-structure)
4. [State Management](#state-management)
5. [Service Layer](#service-layer)
6. [Data Layer](#data-layer)
7. [Security Layer](#security-layer)
8. [Error Handling](#error-handling)
9. [Testing Architecture](#testing-architecture)
10. [Deployment](#deployment)

## Overview

Journeyman Jobs is a Flutter mobile application built for IBEW electrical workers. The app serves as a comprehensive job matching platform with features for job searching, filtering, applying, and crew management.

### Core Features
- **Job Discovery**: Search and filter job listings
- **Authentication**: Firebase-based user authentication
- **Job Management**: Apply to jobs, bookmark favorites
- **Crew Management**: Create and manage work crews
- **Real-time Chat**: Stream Chat integration for crew communication
- **Offline Support**: Local caching for critical data

## Architecture Principles

### 1. Clean Architecture
- Separation of concerns with clear layer boundaries
- Dependency inversion with interfaces
- Business logic isolation from UI

### 2. Flutter Best Practices
- Widget composition over inheritance
- Reactive programming with streams
- Performance-first approach

### 3. Testing-First Development
- Comprehensive test coverage
- Unit, widget, and integration tests
- Mock-driven development

### 4. Security-First Design
- End-to-end encryption
- Secure data storage
- Authentication best practices

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root app widget
├── navigation/                  # Navigation configuration
│   ├── app_router.dart
│   └── app_router.g.dart
├── screens/                     # Screen widgets
│   ├── onboarding/
│   ├── home/
│   ├── jobs/
│   ├── profile/
│   └── crews/
├── widgets/                     # Reusable UI components
│   ├── common/                  # Generic widgets
│   ├── jj_job_card.dart        # Unified job card
│   └── error_dialog.dart       # Error dialog component
├── providers/                   # State management
│   └── riverpod/               # Riverpod providers
│       ├── auth_riverpod_provider.dart
│       ├── jobs_riverpod_provider.dart
│       ├── job_filter_riverpod_provider.dart
│       └── ...
├── services/                    # Business logic
│   ├── firebase_services/       # Firebase integrations
│   ├── unified_services/        # Consolidated services
│   └── security/               # Security services
├── models/                      # Data models
│   ├── job_model.dart           # Canonical Job model
│   ├── user_model.dart
│   ├── filter_criteria.dart
│   └── filter_preset.dart
├── utils/                       # Utilities
│   ├── error_handler.dart       # Unified error handling
│   ├── structured_logging.dart  # Logging system
│   └── ...
├── design_system/               # Theme and styling
│   ├── app_theme.dart
│   ├── colors.dart
│   └── text_styles.dart
└── electrical_components/       # Custom electrical-themed widgets
```

## State Management

### Riverpod Architecture

Journeyman Jobs uses Riverpod for reactive state management. The architecture follows these patterns:

#### Provider Types

1. **Notifiers** - Stateful providers with mutable state
2. **Future Providers** - Async data providers
3. **Stream Providers** - Real-time data providers
4. **Computed Providers** - Derived state providers

#### Provider Structure

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() => const MyState();

  Future<void> updateState() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await service.getData();
      state = state.copyWith(
        data: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
```

#### Error Handling in Providers

All providers use the standardized `ErrorHandler` utility:

```dart
final result = await ErrorHandler.handleAsyncOperation(
  operation: () => service.getData(),
  operationName: 'loadData',
  errorMessage: 'Failed to load data',
  showToast: true,
);
```

## Service Layer

### Service Architecture

The service layer follows the unified service pattern to reduce code duplication:

1. **Firebase Services** - Direct Firebase operations
2. **Unified Services** - Consolidated business logic
3. **Security Services** - Encryption and authentication

### Service Locator Pattern

Services are registered with the service locator:

```dart
// Register service
ServiceLocator.register<FirebaseService>(() => FirebaseService());

// Get service
final service = ServiceLocator.get<FirebaseService>();
```

### Key Services

#### 1. FirebaseService
```dart
class FirebaseService {
  Future<List<Job>> getJobs({FilterCriteria? filter}) async {
    // Firebase implementation
  }

  Future<void> saveJob(Job job) async {
    // Save job to Firestore
  }
}
```

#### 2. UnifiedCacheService
```dart
class UnifiedCacheService {
  Future<T?> get<T>(String key) async {
    // Unified caching logic
  }

  Future<void> set<T>(String key, T value) async {
    // Unified cache storage
  }
}
```

#### 3. ConsolidatedSessionService
```dart
class ConsolidatedSessionService {
  Future<void> initializeSession() async {
    // Session initialization
  }

  Future<bool> isSessionValid() async {
    // Session validation
  }
}
```

## Data Layer

### Models

#### Canonical Job Model
The app uses a single canonical Job model to avoid duplication:

```dart
class Job {
  final String id;
  final String company;
  final String location;
  final int? local;
  final String? classification;
  final double? wage;
  final Map<String, dynamic> jobDetails;

  // ... 30+ fields total

  const Job({
    required this.id,
    required this.company,
    // ... other fields
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Deserialization logic
  }

  Map<String, dynamic> toJson() {
    // Serialization logic
  }
}
```

### Data Serialization

- JSON serialization for all models
- Firestore document mapping
- Type safety with fromJson/toJson methods

## Security Layer

### Encryption Services

#### Secure Encryption Service
```dart
class SecureEncryptionService {
  static Future<String> encrypt(String data) async {
    // AES-256 encryption
  }

  static Future<String> decrypt(String encryptedData) async {
    // AES-256 decryption
  }
}
```

### Authentication Security

1. **Token Management**
   - JWT token storage in secure storage
   - Automatic token refresh
   - Session timeout handling

2. **Data Protection**
   - Sensitive data encryption
   - Secure local storage
   - Network security with certificate pinning

## Error Handling

### Unified Error Handler

The `ErrorHandler` utility provides consistent error handling:

```dart
class ErrorHandler {
  static Future<T?> handleAsyncOperation<T>({
    required Future<T> Function() operation,
    String? operationName,
    String? errorMessage,
    bool showToast = true,
    Map<String, dynamic>? context,
  }) async {
    // Error handling implementation
  }
}
```

### Error Categories

1. **Network Errors** - Connection issues, timeouts
2. **Authentication Errors** - Permission denied, invalid tokens
3. **Validation Errors** - Input validation failures
4. **System Errors** - Unexpected application errors

### Error Display

Standardized error dialogs with user-friendly messages:

```dart
ErrorDialog.show(
  context: context,
  error: error,
  operationName: 'Loading Jobs',
  onRetry: () => retryOperation(),
);
```

## Testing Architecture

### Test Structure

```
test/
├── fixtures/           # Mock data generators
├── integration/        # End-to-end tests
├── providers/          # Provider unit tests
├── widgets/            # Widget tests
├── utils/              # Utility tests
├── test_config.dart     # Test configuration
└── test_runner.dart     # Custom test runner
```

### Testing Patterns

1. **Mock-Driven Development**
   - Firebase mocks for testing
   - Service mocking for isolation
   - Data fixtures for consistency

2. **Widget Testing**
   - Rendering tests
   - Interaction tests
   - Accessibility tests

3. **Integration Testing**
   - Workflow testing
   - API integration testing
   - State flow testing

## Deployment

### Build Configuration

#### Release Build
```bash
flutter build apk --release
flutter build ios --release
```

#### Environment Variables
```dart
// Environment-specific configuration
const String kFirebaseProjectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: 'journeyman-jobs-dev',
);
```

### Security in Production

1. **Code Obfuscation**
   - Release builds with R8/ProGuard
   - String resource obfuscation

2. **Certificate Pinning**
   - SSL certificate validation
   - Network security enforcement

3. **Debug Mode Prevention**
   - Runtime debug checks
   - Production safety measures

## Performance Optimizations

### Memory Management

1. **Widget Disposal**
   - Proper resource cleanup
   - Stream controller management

2. **Image Caching**
   - Local image storage
   - Network image optimization

3. **Database Optimization**
   - Query optimization
   - Pagination implementation

### Rendering Performance

1. **Lazy Loading**
   - On-demand data loading
   - Progressive image loading

2. **Widget Rebuilding**
   - Const constructors
   - Selective rebuilding

## Future Enhancements

### Planned Improvements

1. **Microservices Architecture**
   - Service decomposition
   - Independent scaling

2. **Real-time Synchronization**
   - Offline-first architecture
   - Conflict resolution

3. **AI-Powered Features**
   - Job recommendation engine
   - Automated matching

### Technology Roadmap

1. **Short Term (3 months)**
   - Enhanced offline support
   - Performance optimization
   - Additional integrations

2. **Medium Term (6 months)**
   - Web platform support
   - Advanced analytics
   - API versioning

3. **Long Term (12+ months)**
   - Microservices migration
   - Multi-tenant architecture
   - International expansion

## Contributing Guidelines

### Code Standards

1. **Dart Style Guide**
   - Effective Dart guidelines
   - Custom linting rules
   - Code formatting

2. **Documentation**
   - Public API documentation
   - Inline code comments
   - Architecture decisions

3. **Testing Requirements**
   - Minimum 80% coverage
   - All public APIs tested
   - Integration tests for features

### Pull Request Process

1. Create feature branch
2. Implement with tests
3. Update documentation
4. Submit PR for review
5. Ensure CI/CD passes

---

## Conclusion

The Journeyman Jobs architecture is designed for scalability, maintainability, and performance. The clean architecture principles, combined with Flutter's reactive programming model, create a robust foundation for the IBEW electrical worker community.

The modular design allows for easy feature additions and modifications while maintaining code quality and testability. The unified service pattern reduces duplication, and the standardized error handling ensures consistent user experience across the application.