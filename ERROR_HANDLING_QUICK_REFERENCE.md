# ⚡ ERROR HANDLING QUICK REFERENCE
**One-Page Cheat Sheet for Journeyman Jobs Developers**

---

## 🎯 CORE PATTERN

```dart
// ✅ ALWAYS use this pattern for operations that can fail
Future<Result<T>> yourMethod() async {
  try {
    // 1. Check connectivity (if network operation)
    if (!_connectivity.isOnline) {
      return Result.failure(AppError.offline('...'));
    }

    // 2. Perform operation with timeout
    final result = await operation()
      .timeout(Duration(seconds: 10));

    // 3. Success
    return Result.success(result);

  } on SpecificException catch (e, stack) {
    // 4. Handle specific errors
    ErrorLogger.logError('context', e, stackTrace: stack);
    return Result.failure(AppError.specific(...));

  } catch (e, stack) {
    // 5. Handle unknown errors
    ErrorLogger.logError('context', e, stackTrace: stack);
    return Result.failure(AppError.unknown('...'));
  }
}
```

---

## 📦 COMMON ERROR TYPES

| Error Type | When to Use | Example |
|------------|-------------|---------|
| `AppError.network()` | Network connectivity issues | `AppError.network('Check your internet')` |
| `AppError.offline()` | No internet connection | `AppError.offline('No connection', recoveryAction: RecoveryAction.queueForLater)` |
| `AppError.timeout()` | Operation takes too long | `AppError.timeout('Request timed out')` |
| `AppError.firebase()` | Firebase-specific errors | `AppError.firebase(e.code, e.message)` |
| `AppError.unauthenticated()` | User not signed in | `AppError.unauthenticated()` |
| `AppError.authExpired()` | Token expired | `AppError.authExpired('Session expired')` |
| `AppError.validation()` | Invalid user input | `AppError.validation('Fix errors', fieldErrors)` |
| `AppError.unknown()` | Unexpected errors | `AppError.unknown('Unexpected error')` |

---

## 🔧 SERVICE LAYER TEMPLATE

```dart
class YourService {
  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivity;

  // Constructor injection
  YourService({
    required FirebaseFirestore firestore,
    required ConnectivityService connectivity,
  }) : _firestore = firestore,
       _connectivity = connectivity;

  Future<Result<YourModel>> fetchData() async {
    const context = 'YourService.fetchData';

    // Connectivity check
    if (!_connectivity.isOnline) {
      return Result.failure(
        AppError.offline('No internet connection')
      );
    }

    try {
      // Firebase operation with timeout
      final doc = await _firestore
        .collection('your_collection')
        .doc(id)
        .get()
        .timeout(Duration(seconds: 10));

      if (!doc.exists) {
        return Result.failure(
          AppError.firebase('not-found', 'Data not found')
        );
      }

      // Parse data
      final data = YourModel.fromMap(doc.data()!);
      return Result.success(data);

    } on FirebaseException catch (e, stack) {
      ErrorLogger.logError(context, e, stackTrace: stack);
      return Result.failure(AppError.firebase(e.code, e.message));

    } on TimeoutException catch (e, stack) {
      ErrorLogger.logError(context, e, stackTrace: stack);
      return Result.failure(AppError.timeout('Request timed out'));

    } catch (e, stack) {
      ErrorLogger.logError(context, e, stackTrace: stack);
      return Result.failure(AppError.unknown('Failed to fetch data'));
    }
  }
}
```

---

## 🎨 PROVIDER TEMPLATE

```dart
// FutureProvider with error handling
final yourDataProvider = FutureProvider.autoDispose<YourModel>((ref) async {
  final service = ref.watch(yourServiceProvider);

  final result = await service.fetchData();

  return result.when(
    success: (data) => data,
    failure: (error) {
      ErrorLogger.logError('yourDataProvider', error);
      throw error; // Triggers AsyncError state
    },
  );
});

// StateNotifier for mutations
class YourNotifier extends StateNotifier<AsyncValue<void>> {
  final YourService _service;

  YourNotifier(this._service) : super(AsyncData(null));

  Future<void> performAction(YourData data) async {
    state = AsyncLoading();

    final result = await _service.doSomething(data);

    state = result.when(
      success: (_) => AsyncData(null),
      failure: (error) => AsyncError(error, StackTrace.current),
    );
  }
}
```

---

## 🎨 UI TEMPLATE

```dart
class YourScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yourDataProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Your Screen')),
      body: dataAsync.when(
        // ✅ Success
        data: (data) => YourDataView(data: data),

        // ⏳ Loading
        loading: () => Center(child: CircularProgressIndicator()),

        // ❌ Error
        error: (error, stack) {
          final appError = error is AppError
            ? error
            : AppError.unknown('An error occurred');

          return ErrorRecoveryWidget(
            error: appError,
            onRetry: () => ref.refresh(yourDataProvider),
          );
        },
      ),
    );
  }
}
```

---

## 🔍 ERROR LOGGING

```dart
// Always log errors with context
ErrorLogger.logError(
  'MethodName.operation',     // Context (where error occurred)
  error,                       // The error object
  stackTrace: stack,           // Stack trace (if available)
  severity: ErrorSeverity.error, // Severity level
  additionalInfo: {            // Extra debugging info
    'userId': userId,
    'operation': 'fetch_jobs',
  },
);
```

### Severity Levels
- `info`: Informational, not an error
- `warning`: Non-critical issue
- `error`: Standard error (default)
- `critical`: Critical system error

---

## 🌐 CONNECTIVITY CHECKS

```dart
class YourService {
  final ConnectivityService _connectivity;

  Future<Result<T>> networkOperation() async {
    // ✅ ALWAYS check before network operations
    if (!_connectivity.isOnline) {
      return Result.failure(
        AppError.offline(
          'No internet connection',
          recoveryAction: RecoveryAction.queueForLater,
        ),
      );
    }

    // Proceed with operation...
  }

  // Or listen to connectivity changes
  void listenToConnectivity() {
    _connectivity.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        // Sync queued operations
      }
    });
  }
}
```

---

## ⏱️ TIMEOUT HANDLING

```dart
// ✅ ALWAYS add timeouts to Firebase operations
final result = await _firestore
  .collection('jobs')
  .get()
  .timeout(
    Duration(seconds: 10),
    onTimeout: () {
      throw TimeoutException('Job fetch timed out');
    },
  );
```

**Recommended Timeouts:**
- Simple queries: 10 seconds
- Complex queries: 15 seconds
- Uploads/downloads: 30 seconds
- Large data transfers: 60 seconds

---

## 🎯 RECOVERY ACTIONS

| Recovery Action | When to Use | User Experience |
|-----------------|-------------|-----------------|
| `retry` | Transient errors | Shows "Try Again" button |
| `reauthenticate` | Auth expired | Navigates to login |
| `refresh` | Stale data | Shows "Refresh" option |
| `goOffline` | No connectivity | Shows offline mode |
| `contactSupport` | Critical errors | Shows support contact |
| `autoRetry` | Background sync | System retries automatically |
| `queueForLater` | Offline operations | Queues for background processing |
| `none` | No recovery available | Shows error only |

---

## 🧪 TESTING PATTERNS

### Unit Test
```dart
test('handles network timeout', () async {
  when(mockFirestore.collection('jobs').get())
    .thenThrow(TimeoutException('Timeout'));

  final result = await service.fetchJobs();

  expect(result, isA<Failure>());
  result.when(
    success: (_) => fail('Should have failed'),
    failure: (error) {
      expect(error, isA<TimeoutError>());
      expect(error.recoveryAction, RecoveryAction.retry);
    },
  );
});
```

### Widget Test
```dart
testWidgets('shows error recovery UI', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        yourDataProvider.overrideWith((ref) {
          throw AppError.network('No connection');
        }),
      ],
      child: MaterialApp(home: YourScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('No connection'), findsOneWidget);
  expect(find.text('Try Again'), findsOneWidget);
});
```

---

## 🚨 ANTI-PATTERNS TO AVOID

### ❌ DON'T: Ignore errors
```dart
try {
  await firestore.get();
} catch (e) {
  // Silent failure - BAD!
}
```

### ✅ DO: Handle and log errors
```dart
try {
  await firestore.get();
} catch (e, stack) {
  ErrorLogger.logError('context', e, stackTrace: stack);
  return Result.failure(AppError.fromException(e));
}
```

---

### ❌ DON'T: Expose technical details
```dart
return AppError.unknown('FirebaseException: permission-denied');
```

### ✅ DO: Use user-friendly messages
```dart
return AppError.firebase(
  'permission-denied',
  'You don\'t have access to this data',
);
```

---

### ❌ DON'T: Skip connectivity checks
```dart
await firestore.get(); // Might fail if offline
```

### ✅ DO: Check connectivity first
```dart
if (!_connectivity.isOnline) {
  return Result.failure(AppError.offline('...'));
}
await firestore.get();
```

---

### ❌ DON'T: No timeout
```dart
await firestore.get(); // Hangs indefinitely
```

### ✅ DO: Always timeout
```dart
await firestore.get().timeout(Duration(seconds: 10));
```

---

## 📋 PRE-COMMIT CHECKLIST

Before committing code:

- [ ] All Firebase operations have `.timeout()`
- [ ] All network operations check `_connectivity.isOnline`
- [ ] All methods return `Result<T>` for error-prone operations
- [ ] All errors are logged with `ErrorLogger.logError()`
- [ ] All error messages are user-friendly
- [ ] Error states have appropriate `RecoveryAction`
- [ ] UI handles `AsyncError` with `ErrorRecoveryWidget`
- [ ] Tests cover error scenarios

---

## 🔗 RELATED DOCS

- **Full Analysis:** `ERROR_FORENSICS_REPORT.md`
- **Implementation Guide:** `ERROR_HANDLING_IMPLEMENTATION_GUIDE.md`
- **Connectivity Service:** `CONNECTIVITY_SERVICE_IMPLEMENTATION.md`

---

## 💡 QUICK TIPS

1. **Always use Result<T>** for operations that can fail
2. **Check connectivity** before network operations
3. **Add timeouts** to all async operations
4. **Log all errors** with context and severity
5. **User-friendly messages** - no technical jargon
6. **Recovery actions** - give users a way forward
7. **Test error states** - don't just test happy paths

---

**Last Updated:** 2025-10-18
**Version:** 1.0
**Maintained by:** Error Detective Agent
