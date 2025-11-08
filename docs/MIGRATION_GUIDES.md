# Migration Guides

## Overview

This document provides migration guides for the major architectural changes made during the Journeyman Jobs refactoring process. These guides help developers understand how to update their code to work with the new architecture.

## Table of Contents

1. [Provider Architecture Migration](#provider-architecture-migration)
2. [Model Consolidation Migration](#model-consolidation-migration)
3. [Service Layer Migration](#service-layer-migration)
4. [Error Handling Migration](#error-handling-migration)
5. [Widget Architecture Migration](#widget-architecture-migration)

---

## Provider Architecture Migration

### Old Pattern (Legacy Provider)

```dart
// ❌ OLD - Legacy provider pattern
final authProvider = ChangeNotifierProvider((ref) => AuthProvider());

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    // Implementation
    notifyListeners();
  }
}
```

### New Pattern (Riverpod @riverpod)

```dart
// ✅ NEW - Riverpod @riverpod pattern
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final result = await ErrorHandler.handleAsyncOperation<UserModel>(
      operation: () async {
        // Implementation
      },
      operationName: 'signIn',
      errorMessage: 'Failed to sign in',
    );

    // Update state automatically handled by ErrorHandler
  }
}
```

### Migration Steps

1. **Convert Provider Classes**
   - Remove `ChangeNotifier` inheritance
   - Add `@riverpod` annotation
   - Change state management to use generated state class

2. **Update Provider Usage**
   ```dart
   // OLD
   final user = context.watch<AuthProvider>().user;

   // NEW
   final user = ref.watch(authProvider).user;
   ```

3. **Replace notifyListeners()**
   ```dart
   // OLD
   notifyListeners();

   // NEW - State is automatically updated
   state = state.copyWith(newValue);
   ```

4. **Handle Async Operations**
   ```dart
   // OLD
   try {
     await operation();
   } catch (e) {
     // Manual error handling
   }

   // NEW
   final result = await ErrorHandler.handleAsyncOperation(
     operation: () => operation(),
     operationName: 'operationName',
     errorMessage: 'Failed to perform operation',
   );
   ```

### Provider Reference Mapping

| Old Provider | New Provider | Location |
|--------------|------------|----------|
| `AuthProvider` | `authProvider` | `lib/providers/riverpod/auth_riverpod_provider.dart` |
| `JobsProvider` | `jobsProvider` | `lib/providers/riverpod/jobs_riverpod_provider.dart` |
| `JobFilterProvider` | `jobFilterProvider` | `lib/providers/riverpod/job_filter_riverpod_provider.dart` |
| `UserPreferencesProvider` | `userPreferencesProvider` | `lib/providers/riverpod/user_preferences_riverpod_provider.dart` |

---

## Model Consolidation Migration

### Old Models (Duplicated)

```dart
// ❌ OLD - Multiple Job models
class JobModel {
  final String company;
  final double? wage;
  // ... fields
}

class UnifiedJobModel {
  final String companyName;  // Different field name!
  final double hourlyRate;  // Different field name!
  // ... fields
}

class CrewJob {
  final String? companyName;
  final double hourlyRate;
  // ... fields
}
```

### New Model (Canonical)

```dart
// ✅ NEW - Single canonical Job model
class Job {
  final String company;
  final double? wage;
  final int? local;
  final String? classification;
  final String location;
  final Map<String, dynamic> jobDetails;

  // ... 30+ fields

  const Job({
    required this.id,
    required this.company,
    // ... all fields
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Unified parsing logic
  }
}
```

### Migration Steps

1. **Update Model Imports**
   ```dart
   // OLD
   import 'models/unified_job_model.dart';
   import 'models/crew_job.dart';

   // NEW
   import 'models/job_model.dart';
   ```

2. **Replace Model References**
   ```dart
   // OLD
   UnifiedJobModel job = UnifiedJobModel(...);

   // NEW
   Job job = Job.fromJson(...);
   ```

3. **Handle Field Name Changes**
   ```dart
   // OLD
   final company = job.companyName;
   final wage = job.hourlyRate;

   // NEW
   final company = job.company;
   final wage = job.wage;
   ```

4. **Update JSON Serialization**
   ```dart
   // All models now use consistent fromJson/toJson
   final job = Job.fromJson(jsonData);
   final json = job.toJson();
   ```

### Model Reference Mapping

| Old Model | New Model | Notes |
|-----------|----------|-------|
| `JobModel` | `Job` | Direct replacement |
| `UnifiedJobModel` | `Job` | Use canonical model |
| `CrewJob` | `Job` | Reserved for future use |

---

## Service Layer Migration

### Old Pattern (Multiple Services)

```dart
// ❌ OLD - Duplicate service implementations
class JobService {
  Future<List<Job>> getJobs() async { /* implementation */ }
}

class JobRepository {
  Future<List<Job>> getJobs() async { /* implementation */ }
}

class JobDataManager {
  Future<List<Job>> getJobs() async { /* implementation */ }
}
```

### New Pattern (Unified Service)

```dart
// ✅ NEW - Consolidated service
class UnifiedJobService {
  final FirebaseService _firebaseService;
  final CacheService _cacheService;

  UnifiedJobService(this._firebaseService, this._cacheService);

  Future<List<Job>> getJobs({FilterCriteria? filter}) async {
    // Unified implementation
    final cached = await _cacheService.get<List<Job>>('jobs_$filter');
    if (cached != null) return cached;

    final jobs = await _firebaseService.getJobs(filter: filter);
    await _cacheService.set('jobs_$filter', jobs);
    return jobs;
  }
}
```

### Migration Steps

1. **Consolidate Service Logic**
   - Identify duplicate functionality
   - Merge into unified services
   - Preserve unique features

2. **Update Service Dependencies**
   ```dart
   // OLD
   final jobService = JobService();
   final jobRepo = JobRepository();

   // NEW
   final unifiedJobService = UnifiedJobService(
     firebaseService,
     cacheService,
   );
   ```

3. **Handle Legacy Service Calls**
   ```dart
   // Create adapter pattern for backward compatibility
   class JobServiceAdapter {
     final UnifiedJobService _unified;

     Future<List<Job>> getJobs() => _unified.getJobs();
   }
   ```

### Service Reference Mapping

| Old Service | New Service | Location |
|-------------|------------|----------|
| `JobService` | `UnifiedJobService` | `lib/services/unified_services/job_service.dart` |
| `UserService` | `UnifiedUserService` | `lib/services/unified_services/user_service.dart` |
| `CacheService` | `UnifiedCacheService` | `lib/services/unified_services/cache_service.dart` |
| `SessionService` | `ConsolidatedSessionService` | `lib/services/unified_services/session_service.dart` |

---

## Error Handling Migration

### Old Pattern (Manual Error Handling)

```dart
// ❌ OLD - Manual error handling
Future<List<Job>> loadJobs() async {
  try {
    final jobs = await apiService.getJobs();
    return jobs;
  } on SocketException catch (e) {
    showToast('Network error: ${e.message}');
    return [];
  } on TimeoutException catch (e) {
    showToast('Request timeout');
    return [];
  } catch (e) {
    showToast('An error occurred');
    return [];
  }
}
```

### New Pattern (Unified Error Handler)

```dart
// ✅ NEW - Unified error handling
Future<List<Job>?> loadJobs() async {
  return ErrorHandler.handleAsyncOperation<List<Job>>(
    operation: () async => apiService.getJobs(),
    operationName: 'loadJobs',
    errorMessage: 'Failed to load jobs',
    defaultValue: [],
    showToast: true,
    context: {
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

### Migration Steps

1. **Add ErrorHandler Import**
   ```dart
   import 'utils/error_handler.dart';
   ```

2. **Replace Try-Catch Blocks**
   ```dart
   // Replace with ErrorHandler.handleAsyncOperation
   final result = await ErrorHandler.handleAsyncOperation<T>(...);
   ```

3. **Handle Error Categories**
   - Network errors: Automatic retry logic
   - Auth errors: Special handling for auth flows
   - Validation errors: Form field validation

4. **Custom Error Messages**
   ```dart
   final result = await ErrorHandler.handleAsyncOperation(
     operation: () => riskyOperation(),
     errorMessage: 'Custom error message',
   );
   ```

### Error Handling Best Practices

1. **Always Use ErrorHandler for Async Operations**
   ```dart
   // ✅ DO
   final result = await ErrorHandler.handleAsyncOperation(...);

   // ❌ DON'T
   try { await operation(); } catch (e) { /* manual handling */ }
   ```

2. **Provide Context for Debugging**
   ```dart
   context: {
     'userId': user.id,
     'attempt': retryCount,
     'filter': filter.toString(),
   }
   ```

3. **Use Appropriate Error Messages**
   - User-friendly messages
   - Technical details in debug mode

---

## Widget Architecture Migration

### Old Pattern (Duplicate Widgets)

```dart
// ❌ OLD - Multiple job card implementations
class JobCard extends StatelessWidget { /* implementation */ }
class JobCardWidget extends StatelessWidget { /* implementation */ }
class JobListItem extends StatelessWidget { /* implementation */ }
class EnhancedJobCard extends StatelessWidget { /* implementation */ }
class CompactJobCard extends StatelessWidget { /* implementation */ }
```

### New Pattern (Unified Widget)

```dart
// ✅ NEW - Unified job card widget
class JJJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool? isBookmarked;
  final Widget? action;
  final bool isLoading;
  final double? distance;

  const JJJobCard({
    Key? key,
    required this.job,
    this.onTap,
    this.isBookmarked,
    this.action,
    this.isLoading = false,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Unified implementation with all features
    return Card(
      child: /* ... */,
    );
  }
}
```

### Migration Steps

1. **Identify Duplicate Widgets**
   - Search for multiple implementations
   - List all job card variations
   - Analyze feature differences

2. **Create Unified Widget**
   - Consolidate all features
   - Add optional parameters for variations
   - Maintain backward compatibility

3. **Update Widget Usage**
   ```dart
   // OLD
   JobCard(job: job, onTap: onTap)
   JobCardWidget(job: job, onTap: onTap)

   // NEW
   JJJobCard(
     job: job,
     onTap: onTap,
     isBookmarked: isBookmarked,
     action: shareButton,
   )
   ```

4. **Remove Duplicate Widgets**
   - Delete old implementations
   - Update imports
   - Fix any remaining references

### Widget Reference Mapping

| Old Widget | New Widget | Features Consolidated |
|-------------|------------|---------------------|
| `JobCard` | `JJJobCard` | Basic job display |
| `JobCardWidget` | `JJJobCard` | Interactive features |
| `JobListItem` | `JJJobCard` | List display |
| `EnhancedJobCard` | `JJJobCard` | Advanced features |
| `CompactJobCard` | `JJJobCard` | Compact mode |

---

## Common Migration Patterns

### 1. Async State Updates

```dart
// OLD
setState(() {
  _isLoading = false;
  _error = null;
});

// NEW
state = state.copyWith(
  isLoading: false,
  error: null,
);
```

### 2. Provider Access

```dart
// OLD
final provider = Provider.of<MyProvider>(context);
final value = provider.value;

// NEW
final value = ref.watch(myProvider);
final notifier = ref.read(myProvider.notifier);
```

### 3. Navigation

```dart
// OLD
Navigator.pushNamed(context, '/jobs');

// NEW
context.goNamed(AppRoutes.jobs);
```

### 4. Error Display

```dart
// OLD
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $error')),
);

// NEW
ErrorDialog.show(
  context: context,
  error: error,
  onRetry: () => retryOperation(),
);
```

## Testing Migration

### Old Pattern (Basic Tests)

```dart
testWidgets('JobCard displays title', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: JobCard(job: testJob),
  ));

  expect(find.text(testJob.company), findsOneWidget);
});
```

### New Pattern (Comprehensive Tests)

```dart
testWidgets('JJJobCard displays job information correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: JJJobCard(
            job: testJob,
            onTap: () {},
          ),
        ),
      ),
    ),
  );

  // Multiple assertions
  expect(find.text(testJob.company), findsOneWidget);
  expect(find.text(testJob.location), findsOneWidget);
  expect(find.text('\$${testJob.wage}/hr'), findsOneWidget);
});
```

## Migration Checklist

### Provider Migration
- [ ] Convert all ChangeNotifier providers to @riverpod
- [ ] Update provider usage in widgets
- [ ] Replace notifyListeners() calls
- [ ] Implement error handling with ErrorHandler

### Model Migration
- [ ] Update imports to use canonical models
- [ ] Replace field references
- [ ] Update JSON serialization
- [ ] Remove duplicate model files

### Service Migration
- [ ] Identify and consolidate duplicate services
- [ ] Update service dependencies
- [ ] Implement caching in unified services
- [ ] Create adapters for backward compatibility if needed

### Widget Migration
- [ ] Identify duplicate widget implementations
- [ ] Create unified widgets with optional parameters
- [ ] Update widget usage throughout app
- [ ] Remove old widget files

### Error Handling Migration
- [ ] Import ErrorHandler utility
- [ ] Replace try-catch blocks with ErrorHandler
- [ ] Add appropriate error contexts
- [ ] Update error dialogs to use ErrorDialog

### Testing Migration
- [ ] Create mock data fixtures
- [ ] Update test files to use ProviderScope
- [ ] Add comprehensive test scenarios
- [ ] Update test runner configuration

## Troubleshooting

### Common Issues

1. **Provider Not Found Error**
   ```
   Error: Provider not found
   ```
   - Check if provider is exported
   - Verify provider registration
   - Ensure ProviderScope wraps widget

2. **Model Serialization Error**
   ```
   Error: Missing required field
   ```
   - Check fromJson implementation
   - Verify JSON structure
   - Update model fields

3. **Service Injection Error**
   ```
   Error: Service not registered
   ```
   - Verify service registration
   - Check dependency injection setup
   - Ensure proper service locator configuration

### Debug Tips

1. **Enable Debug Logging**
   ```dart
   StructuredLogger.debug('Migration: $message');
   ```

2. **Use DevTools**
   - Provider dependencies
   - Widget tree inspection
   - Performance profiling

3. **Check Build Runner Output**
   - Verify code generation
   - Check for compilation errors
   - Validate provider generation

---

## Conclusion

Following these migration guides will help you successfully update your code to work with the new Journeyman Jobs architecture. The key principles are:

1. **Consistency** - Use unified patterns throughout
2. **Simplicity** - Reduce code duplication
3. **Reliability** - Improve error handling
4. **Maintainability** - Clear separation of concerns

Take your time with each migration, test thoroughly, and don't hesitate to reach out for help with specific migration challenges.