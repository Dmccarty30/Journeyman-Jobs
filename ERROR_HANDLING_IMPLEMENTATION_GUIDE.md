# 🔧 ERROR HANDLING IMPLEMENTATION GUIDE
**Quick Reference for Journeyman Jobs Error Remediation**
**Target:** Flutter developers implementing forensic report recommendations

---

## 🎯 QUICK START: Critical Implementations (Day 1)

### Step 1: Create Error Infrastructure (30 min)

#### File: `lib/core/error/app_error.dart`
```dart
/// Represents all possible application errors with user-friendly messages
/// and recovery actions.
///
/// Usage:
/// ```dart
/// return Result.failure(
///   AppError.network('Check your internet connection',
///     recoveryAction: RecoveryAction.retry
///   )
/// );
/// ```
sealed class AppError implements Exception {
  final String userMessage;
  final String? technicalDetails;
  final ErrorSeverity severity;
  final RecoveryAction recoveryAction;
  final Map<String, dynamic>? metadata;

  const AppError({
    required this.userMessage,
    this.technicalDetails,
    required this.severity,
    required this.recoveryAction,
    this.metadata,
  });

  /// Network connectivity errors
  factory AppError.network(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.retry,
  }) = NetworkError;

  /// Operation timeout errors
  factory AppError.timeout(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.retry,
  }) = TimeoutError;

  /// Firebase-specific errors
  factory AppError.firebase(
    String code,
    String? message, {
    RecoveryAction? recoveryAction,
  }) = FirebaseError;

  /// Authentication errors
  factory AppError.unauthenticated({
    String message = 'Please sign in to continue',
  }) = UnauthenticatedError;

  /// Authorization/permission errors
  factory AppError.authExpired(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.reauthenticate,
  }) = AuthExpiredError;

  /// Data validation errors
  factory AppError.validation(
    String message,
    Map<String, String> fieldErrors,
  ) = ValidationError;

  /// No internet connection
  factory AppError.offline(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.queueForLater,
  }) = OfflineError;

  /// Unknown/unexpected errors
  factory AppError.unknown(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) = UnknownError;

  /// Convert any exception to AppError
  factory AppError.fromException(dynamic error) {
    if (error is FirebaseException) {
      return AppError.firebase(error.code, error.message);
    }
    if (error is TimeoutException) {
      return AppError.timeout('Operation timed out. Please try again.');
    }
    if (error is SocketException) {
      return AppError.network('No internet connection');
    }
    return AppError.unknown(
      'An unexpected error occurred',
      originalError: error,
    );
  }

  @override
  String toString() => userMessage;
}

// Concrete implementations
class NetworkError extends AppError {
  const NetworkError(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.retry,
  }) : super(
          userMessage: message,
          severity: ErrorSeverity.error,
          recoveryAction: recoveryAction,
        );
}

class TimeoutError extends AppError {
  const TimeoutError(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.retry,
  }) : super(
          userMessage: message,
          severity: ErrorSeverity.error,
          recoveryAction: recoveryAction,
        );
}

class FirebaseError extends AppError {
  final String code;

  FirebaseError(
    this.code,
    String? message, {
    RecoveryAction? recoveryAction,
  }) : super(
          userMessage: _getUserFriendlyMessage(code, message),
          technicalDetails: 'Firebase error: $code - ${message ?? "Unknown"}',
          severity: _getSeverity(code),
          recoveryAction: recoveryAction ?? _getRecoveryAction(code),
        );

  static String _getUserFriendlyMessage(String code, String? message) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'unauthenticated':
        return 'Please sign in to continue';
      case 'not-found':
        return 'The requested data was not found';
      case 'already-exists':
        return 'This data already exists';
      case 'deadline-exceeded':
        return 'Request took too long. Please try again.';
      default:
        return message ?? 'An error occurred. Please try again.';
    }
  }

  static ErrorSeverity _getSeverity(String code) {
    switch (code) {
      case 'permission-denied':
      case 'unauthenticated':
        return ErrorSeverity.critical;
      case 'unavailable':
      case 'deadline-exceeded':
        return ErrorSeverity.error;
      default:
        return ErrorSeverity.warning;
    }
  }

  static RecoveryAction _getRecoveryAction(String code) {
    switch (code) {
      case 'permission-denied':
      case 'unauthenticated':
        return RecoveryAction.reauthenticate;
      case 'unavailable':
      case 'deadline-exceeded':
        return RecoveryAction.retry;
      default:
        return RecoveryAction.none;
    }
  }
}

class UnauthenticatedError extends AppError {
  const UnauthenticatedError({
    String message = 'Please sign in to continue',
  }) : super(
          userMessage: message,
          severity: ErrorSeverity.critical,
          recoveryAction: RecoveryAction.reauthenticate,
        );
}

class AuthExpiredError extends AppError {
  const AuthExpiredError(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.reauthenticate,
  }) : super(
          userMessage: message,
          severity: ErrorSeverity.error,
          recoveryAction: recoveryAction,
        );
}

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;

  const ValidationError(
    String message,
    this.fieldErrors,
  ) : super(
          userMessage: message,
          severity: ErrorSeverity.warning,
          recoveryAction: RecoveryAction.none,
        );
}

class OfflineError extends AppError {
  const OfflineError(
    String message, {
    RecoveryAction recoveryAction = RecoveryAction.queueForLater,
  }) : super(
          userMessage: message,
          severity: ErrorSeverity.warning,
          recoveryAction: recoveryAction,
        );
}

class UnknownError extends AppError {
  final dynamic originalError;
  final StackTrace? stackTrace;

  const UnknownError(
    String message, {
    this.originalError,
    this.stackTrace,
  }) : super(
          userMessage: message,
          severity: ErrorSeverity.error,
          recoveryAction: RecoveryAction.contactSupport,
        );
}

// Enums
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

enum RecoveryAction {
  retry,
  reauthenticate,
  refresh,
  goOffline,
  contactSupport,
  autoRetry,
  queueForLater,
  none,
}
```

---

#### File: `lib/core/error/result.dart`
```dart
/// Type-safe result wrapper for operations that can fail.
///
/// Forces explicit error handling at compile time.
///
/// Usage:
/// ```dart
/// Future<Result<List<JobModel>>> fetchJobs() async {
///   try {
///     final jobs = await _firestore.collection('jobs').get();
///     return Result.success(jobs);
///   } catch (e) {
///     return Result.failure(AppError.fromException(e));
///   }
/// }
///
/// // Consuming code MUST handle both cases
/// final result = await jobService.fetchJobs();
/// result.when(
///   success: (jobs) => displayJobs(jobs),
///   failure: (error) => showError(error),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Create a successful result
  factory Result.success(T data) = Success<T>;

  /// Create a failed result
  factory Result.failure(AppError error) = Failure<T>;

  /// Pattern match on success/failure
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  });

  /// Map the success value to a new type
  Result<R> map<R>(R Function(T data) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Chain operations that return Result
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    return when(
      success: (data) => transform(data),
      failure: (error) => Future.value(Result.failure(error)),
    );
  }

  /// Get the value or throw the error
  T getOrThrow() {
    return when(
      success: (data) => data,
      failure: (error) => throw error,
    );
  }

  /// Get the value or null
  T? getOrNull() {
    return when(
      success: (data) => data,
      failure: (_) => null,
    );
  }

  /// Get the value or a default
  T getOrElse(T defaultValue) {
    return when(
      success: (data) => data,
      failure: (_) => defaultValue,
    );
  }

  /// Check if successful
  bool get isSuccess => this is Success<T>;

  /// Check if failed
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    return success(data);
  }

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && data == other.data;

  @override
  int get hashCode => data.hashCode;
}

class Failure<T> extends Result<T> {
  final AppError error;

  const Failure(this.error);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    return failure(error);
  }

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && error == other.error;

  @override
  int get hashCode => error.hashCode;
}
```

---

#### File: `lib/core/error/error_logger.dart`
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized error logging service.
///
/// Logs errors to console (dev), Crashlytics (prod), and Analytics.
///
/// Usage:
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (e, stack) {
///   ErrorLogger.logError(
///     'riskyOperation failed',
///     e,
///     stackTrace: stack,
///     severity: ErrorSeverity.error,
///     additionalInfo: {'userId': currentUser.id},
///   );
/// }
/// ```
class ErrorLogger {
  static final FirebaseCrashlytics _crashlytics =
      FirebaseCrashlytics.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log an error with full context
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    // 1. Console logging for development
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────');
      debugPrint('│ [$severity] $context');
      debugPrint('│ Error: $error');
      if (stackTrace != null) {
        debugPrint('│ Stack trace:');
        debugPrint(stackTrace.toString());
      }
      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        debugPrint('│ Additional info: $additionalInfo');
      }
      debugPrint('└─────────────────────────────────');
    }

    // 2. Crashlytics logging for production
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: context,
      fatal: severity == ErrorSeverity.critical,
      information: additionalInfo?.entries
              .map((e) => '${e.key}: ${e.value}')
              .toList() ??
          [],
    );

    // 3. Set custom keys for better crash grouping
    if (additionalInfo != null) {
      for (final entry in additionalInfo.entries) {
        _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }

    // 4. Analytics event for error tracking
    _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': error.runtimeType.toString(),
        'context': context,
        'severity': severity.name,
        if (error is AppError) 'recovery_action': error.recoveryAction.name,
        ...?additionalInfo,
      },
    );
  }

  /// Log a user action for debugging context
  static void logUserAction(String action, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      debugPrint('👤 User action: $action ${params ?? ""}');
    }

    _analytics.logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        ...?params,
      },
    );
  }

  /// Set user properties for crash reports
  static void setUserContext({
    required String userId,
    String? role,
    String? localUnion,
  }) {
    _crashlytics.setUserIdentifier(userId);

    if (role != null) {
      _crashlytics.setCustomKey('user_role', role);
    }
    if (localUnion != null) {
      _crashlytics.setCustomKey('local_union', localUnion);
    }

    _analytics.setUserId(id: userId);
    if (role != null) {
      _analytics.setUserProperty(name: 'role', value: role);
    }
  }
}
```

---

### Step 2: Update Service Layer (2h)

#### Template: Service with Result Type

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/error/result.dart';
import '../core/error/app_error.dart';
import '../core/error/error_logger.dart';

/// Service for managing job data with comprehensive error handling.
///
/// All methods return Result<T> for type-safe error handling.
class JobService {
  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivity;

  JobService({
    required FirebaseFirestore firestore,
    required ConnectivityService connectivity,
  })  : _firestore = firestore,
        _connectivity = connectivity;

  /// Fetch all jobs with error handling and timeout.
  ///
  /// Returns [Result<List<JobModel>>] with success data or error.
  ///
  /// Errors:
  /// - [NetworkError]: No internet connection
  /// - [TimeoutError]: Request took > 10 seconds
  /// - [FirebaseError]: Firebase-specific errors
  /// - [UnknownError]: Unexpected errors
  Future<Result<List<JobModel>>> fetchJobs({
    int limit = 20,
    String? classification,
  }) async {
    const context = 'JobService.fetchJobs';

    try {
      // 1. Check connectivity first
      if (!_connectivity.isOnline) {
        ErrorLogger.logError(
          context,
          'No internet connection',
          severity: ErrorSeverity.warning,
        );

        return Result.failure(
          AppError.offline(
            'No internet connection. Jobs saved for offline viewing.',
            recoveryAction: RecoveryAction.goOffline,
          ),
        );
      }

      // 2. Build query with timeout
      Query query = _firestore.collection('jobs').limit(limit);

      if (classification != null) {
        query = query.where('classification', isEqualTo: classification);
      }

      // 3. Execute query with timeout
      final snapshot = await query.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Job fetch timed out');
        },
      );

      // 4. Parse results
      final jobs = snapshot.docs
          .map((doc) {
            try {
              return JobModel.fromMap(doc.data() as Map<String, dynamic>);
            } catch (e) {
              ErrorLogger.logError(
                'JobModel parsing failed',
                e,
                severity: ErrorSeverity.warning,
                additionalInfo: {'docId': doc.id},
              );
              return null;
            }
          })
          .whereType<JobModel>()
          .toList();

      // 5. Success
      return Result.success(jobs);

    } on FirebaseException catch (e, stack) {
      ErrorLogger.logError(
        context,
        e,
        stackTrace: stack,
        severity: ErrorSeverity.error,
        additionalInfo: {
          'limit': limit,
          'classification': classification,
        },
      );

      return Result.failure(AppError.firebase(e.code, e.message));

    } on TimeoutException catch (e, stack) {
      ErrorLogger.logError(
        context,
        e,
        stackTrace: stack,
        severity: ErrorSeverity.error,
      );

      return Result.failure(
        AppError.timeout(
          'Loading jobs is taking longer than expected. Please try again.',
        ),
      );

    } catch (e, stack) {
      ErrorLogger.logError(
        context,
        e,
        stackTrace: stack,
        severity: ErrorSeverity.error,
      );

      return Result.failure(
        AppError.unknown(
          'Failed to load jobs. Please try again.',
          originalError: e,
          stackTrace: stack,
        ),
      );
    }
  }

  /// Submit a job bid with idempotency and error handling.
  Future<Result<void>> submitBid(JobBid bid) async {
    const context = 'JobService.submitBid';

    try {
      // 1. Check connectivity
      if (!_connectivity.isOnline) {
        // Queue for later submission
        await _queueBidForLater(bid);

        return Result.failure(
          AppError.offline(
            'Bid saved. Will submit when online.',
            recoveryAction: RecoveryAction.queueForLater,
          ),
        );
      }

      // 2. Idempotent submission (prevents duplicates)
      await _firestore
          .collection('bids')
          .doc(bid.id) // Use bid ID for idempotency
          .set(
            bid.toMap(),
            SetOptions(merge: true),
          )
          .timeout(const Duration(seconds: 10));

      // 3. Log success
      ErrorLogger.logUserAction('submit_bid', params: {
        'jobId': bid.jobId,
        'bidAmount': bid.amount,
      });

      return Result.success(null);

    } on FirebaseException catch (e, stack) {
      ErrorLogger.logError(
        context,
        e,
        stackTrace: stack,
        severity: ErrorSeverity.error,
        additionalInfo: {'bidId': bid.id},
      );

      // Queue for retry if transient error
      if (_isTransientError(e.code)) {
        await _queueBidForLater(bid);
      }

      return Result.failure(AppError.firebase(e.code, e.message));

    } on TimeoutException catch (e, stack) {
      ErrorLogger.logError(context, e, stackTrace: stack);

      // Queue for retry
      await _queueBidForLater(bid);

      return Result.failure(
        AppError.timeout(
          'Submission timed out. Will retry automatically.',
        ),
      );

    } catch (e, stack) {
      ErrorLogger.logError(context, e, stackTrace: stack);

      return Result.failure(
        AppError.unknown('Failed to submit bid. Please try again.'),
      );
    }
  }

  bool _isTransientError(String code) {
    return ['unavailable', 'deadline-exceeded', 'resource-exhausted']
        .contains(code);
  }

  Future<void> _queueBidForLater(JobBid bid) async {
    // Implementation: Save to local database for background retry
  }
}
```

---

### Step 3: Update Riverpod Providers (1h)

#### Template: Provider with Error Handling

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/job_service.dart';
import '../models/job_model.dart';
import '../core/error/result.dart';

/// Provider for job data with comprehensive error handling.
///
/// States:
/// - AsyncData: Successful data fetch
/// - AsyncLoading: Data is being fetched
/// - AsyncError: Error occurred (with AppError details)
final jobsProvider = FutureProvider.autoDispose
    .family<List<JobModel>, JobFilters?>((ref, filters) async {
  final service = ref.watch(jobServiceProvider);

  // Fetch jobs with Result type
  final result = await service.fetchJobs(
    limit: filters?.limit ?? 20,
    classification: filters?.classification,
  );

  // Convert Result to AsyncValue
  return result.when(
    success: (jobs) => jobs,
    failure: (error) {
      // Log error for monitoring
      ErrorLogger.logError(
        'jobsProvider failed',
        error,
        severity: error.severity,
        additionalInfo: {
          'filters': filters?.toString(),
        },
      );

      // Throw to trigger AsyncError state
      throw error;
    },
  );
});

/// Provider for submitting bids with error state management.
final submitBidProvider =
    StateNotifierProvider<SubmitBidNotifier, AsyncValue<void>>((ref) {
  return SubmitBidNotifier(
    jobService: ref.watch(jobServiceProvider),
  );
});

class SubmitBidNotifier extends StateNotifier<AsyncValue<void>> {
  final JobService _jobService;

  SubmitBidNotifier({required JobService jobService})
      : _jobService = jobService,
        super(const AsyncData(null));

  Future<void> submitBid(JobBid bid) async {
    // Set loading state
    state = const AsyncLoading();

    try {
      // Submit bid
      final result = await _jobService.submitBid(bid);

      // Update state based on result
      state = result.when(
        success: (_) => const AsyncData(null),
        failure: (error) => AsyncError(error, StackTrace.current),
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
```

---

### Step 4: Update UI Layer (1h)

#### Template: Widget with Error Handling

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Jobs screen with comprehensive error handling and recovery UI.
class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch jobs provider
    final jobsAsync = ref.watch(jobsProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Available Jobs')),
      body: jobsAsync.when(
        // ✅ Success state: Display data
        data: (jobs) {
          if (jobs.isEmpty) {
            return const EmptyJobsView();
          }
          return JobsList(jobs: jobs);
        },

        // ⏳ Loading state: Show progress
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading jobs...'),
            ],
          ),
        ),

        // ❌ Error state: Rich error UI with recovery
        error: (error, stack) {
          // Extract AppError if available
          final appError = error is AppError
              ? error
              : AppError.unknown('An unexpected error occurred');

          return ErrorRecoveryWidget(
            error: appError,
            onRetry: () => ref.refresh(jobsProvider(null)),
          );
        },
      ),
    );
  }
}

/// Reusable error recovery widget.
///
/// Displays user-friendly error message with appropriate recovery actions.
class ErrorRecoveryWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback onRetry;

  const ErrorRecoveryWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              _getIconForError(error),
              size: 64,
              color: _getColorForSeverity(error.severity),
            ),

            const SizedBox(height: 24),

            // User-friendly message
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 32),

            // Recovery actions
            ..._buildRecoveryActions(context),
          ],
        ),
      ),
    );
  }

  IconData _getIconForError(AppError error) {
    return switch (error) {
      NetworkError() || OfflineError() => Icons.wifi_off,
      UnauthenticatedError() || AuthExpiredError() => Icons.lock,
      TimeoutError() => Icons.access_time,
      _ => Icons.error_outline,
    };
  }

  Color _getColorForSeverity(ErrorSeverity severity) {
    return switch (severity) {
      ErrorSeverity.critical => Colors.red,
      ErrorSeverity.error => Colors.orange,
      ErrorSeverity.warning => Colors.amber,
      ErrorSeverity.info => Colors.blue,
    };
  }

  List<Widget> _buildRecoveryActions(BuildContext context) {
    final actions = <Widget>[];

    // Primary action based on recovery type
    switch (error.recoveryAction) {
      case RecoveryAction.retry:
        actions.add(
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        );
        break;

      case RecoveryAction.reauthenticate:
        actions.add(
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to login
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
          ),
        );
        break;

      case RecoveryAction.goOffline:
        actions.add(
          ElevatedButton.icon(
            onPressed: () {
              // Switch to offline mode
              // Implementation depends on your offline strategy
            },
            icon: const Icon(Icons.offline_bolt),
            label: const Text('View Offline Data'),
          ),
        );
        break;

      case RecoveryAction.contactSupport:
        actions.add(
          ElevatedButton.icon(
            onPressed: () {
              // Open support contact
              // Implementation: Email, chat, etc.
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
          ),
        );
        break;

      default:
        // No primary action
        break;
    }

    // Always offer a way back
    actions.add(
      const SizedBox(height: 8),
    );
    actions.add(
      TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Go Back'),
      ),
    );

    return actions;
  }
}
```

---

## 📋 CHECKLIST: Implementation Progress

### Day 1: Core Infrastructure
- [ ] Create `lib/core/error/app_error.dart`
- [ ] Create `lib/core/error/result.dart`
- [ ] Create `lib/core/error/error_logger.dart`
- [ ] Add Firebase Crashlytics to `pubspec.yaml`
- [ ] Initialize Crashlytics in `main.dart`
- [ ] Create `ErrorRecoveryWidget`

### Day 2-3: Service Layer Migration
- [ ] Update `JobService` to return `Result<T>`
- [ ] Update `UnionService` to return `Result<T>`
- [ ] Update `AuthService` to return `Result<T>`
- [ ] Add timeout handling to all Firebase operations
- [ ] Add connectivity checks to network operations
- [ ] Implement comprehensive error logging

### Day 4: Provider Layer Updates
- [ ] Update `jobsProvider` for new Result types
- [ ] Update `unionsProvider` for new Result types
- [ ] Update auth providers for new Result types
- [ ] Test error state propagation
- [ ] Verify error recovery flows

### Day 5: UI Layer & Testing
- [ ] Update all screens to use `ErrorRecoveryWidget`
- [ ] Test network error scenarios
- [ ] Test authentication error scenarios
- [ ] Test timeout scenarios
- [ ] Verify user experience during errors
- [ ] Write widget tests for error states

---

## 🧪 TESTING GUIDE

### Manual Testing Scenarios

#### 1. Network Errors
```bash
# Enable airplane mode on device/emulator
# Attempt to load jobs
# Expected: Offline error with appropriate message
```

#### 2. Timeout Errors
```dart
// In service, temporarily reduce timeout
.timeout(const Duration(milliseconds: 1)); // Force timeout

// Expected: Timeout error with retry option
```

#### 3. Authentication Errors
```bash
# Sign in, then delete user from Firebase Console
# Attempt protected operation
# Expected: Re-authentication required
```

---

## 📊 MONITORING SETUP

### Firebase Console Configuration

1. **Enable Crashlytics**
   - Firebase Console → Crashlytics → Enable
   - Follow integration steps

2. **Configure Analytics Events**
   - Create custom event: `app_error`
   - Parameters: error_type, context, severity

3. **Set Up Alerts**
   - Crashlytics: Alert on crash rate > 1%
   - Analytics: Alert on error event spike

---

## 🚀 DEPLOYMENT CHECKLIST

Before releasing to production:

- [ ] All services return `Result<T>`
- [ ] All errors logged to Crashlytics
- [ ] Error recovery UI tested on real devices
- [ ] Network scenarios tested (3G, offline, etc.)
- [ ] Authentication flows tested
- [ ] Error messages are user-friendly
- [ ] No stack traces exposed to users
- [ ] Analytics events verified in Firebase Console
- [ ] Alert thresholds configured
- [ ] Team trained on new error handling patterns

---

**Questions? Issues?**
Refer to `ERROR_FORENSICS_REPORT.md` for detailed analysis and patterns.
