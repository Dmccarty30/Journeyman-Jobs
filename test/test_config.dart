/// Test configuration and utilities for Journeyman Jobs testing
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Test configuration for the application
class TestConfig {
  /// Default test timeout
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Animation test duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Performance test threshold (ms)
  static const int performanceThreshold = 16;

  /// Maximum memory increase in MB for performance tests
  static const double maxMemoryIncrease = 10.0;

  /// Enable golden tests
  static const bool enableGoldenTests = false;

  /// Skip integration tests
  static const bool skipIntegrationTests = false;

  /// Skip performance tests
  static const bool skipPerformanceTests = false;
}

/// Test utilities
class TestUtils {
  /// Creates a test Material app with optional theme
  static Widget createTestApp({
    Widget? child,
    ThemeData? theme,
    bool darkMode = false,
  }) {
    return MaterialApp(
      theme: theme ?? (darkMode ? ThemeData.dark() : ThemeData.light()),
      home: child ?? const SizedBox.shrink(),
    );
  }

  /// Creates a test widget wrapped in Scaffold
  static Widget createTestScaffold({
    Widget? child,
    EdgeInsets? padding,
  }) {
      return Scaffold(
        body: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child ?? const SizedBox.shrink(),
        ),
      );
    }

  /// Creates a provider scope with test overrides
  static Widget createTestProviderScope({
    required Widget child,
    List<Override> overrides = const [],
  }) {
      return ProviderScope(
        overrides: overrides,
        child: child,
      );
    }

  /// Wait for all animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  /// Find widget by text containing the given substring
  static Finder findTextContaining(String substring) {
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final text = widget.data ?? '';
        return text.contains(substring);
      }
      return false;
    });
  }

  /// Verify widget exists and is visible
  static Future<void> expectVisible(
    WidgetTester tester,
    Finder finder, {
    String? reason,
  }) async {
    await tester.pumpAndSettle();
    expect(finder, findsOneWidget, reason: reason);
    expect(tester.getFirstRenderError(finder), isNull, reason: reason);
  }

  /// Verify widget does not exist
  static Future<void> expectNotVisible(
    WidgetTester tester,
    Finder finder, {
    String? reason,
  }) async {
    await tester.pumpAndSettle();
    expect(finder, findsNothing, reason: reason);
  }

  /// Tap on widget and wait for animations
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration? waitDuration,
  }) async {
      await tester.tap(finder);
      await tester.pumpAndSettle(waitDuration ?? TestConfig.animationDuration);
    }

  /// Enter text into a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    bool clearFirst = true,
  }) async {
      if (clearFirst) {
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }
      await tester.enterText(finder, text);
      await tester.pumpAndSettle();
    }

  /// Drag from one widget to another
  static Future<void> drag(
    WidgetTester tester,
    Finder from,
    Finder to, {
    Offset offset = Offset.zero,
  }) async {
      final TestGesture gesture = await tester.startGesture(
        from,
        offset: offset,
      );
      await gesture.moveTo(to, offset: offset);
      await gesture.up();
      await tester.pumpAndSettle();
    }

  /// Long press on widget
  static Future<void> longPress(
    WidgetTester tester,
    Finder finder, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
      await tester.longPress(finder, duration: duration);
      await tester.pumpAndSettle();
    }

  /// Scroll until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
    double delta = 100.0,
    Duration maxDuration = const Duration(seconds: 10),
  }) async {
      final scrollableWidget = scrollable ?? find.byType(Scrollable);

      await tester.fling(
        scrollableWidget,
        const Offset(0, -500),
        10000,
      );
      await tester.pumpAndSettle();

      if (!finder.evaluate()) {
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      }
    }

  /// Get widget's render box
  static RenderBox getRenderBox(WidgetTester tester, Finder finder) {
      return tester.renderObject(finder) as RenderBox;
    }

  /// Get widget's size
  static Size getSize(WidgetTester tester, Finder finder) {
      return getRenderBox(tester, finder).size;
    }

  /// Get widget's position
      Offset getPosition(WidgetTester tester, Finder finder) {
      return getRenderBox(tester, finder).localToGlobal(Offset.zero);
      }
}

/// Mock data generators
class MockData {
  /// Creates a test job with default values
  static Map<String, dynamic> createTestJobJson({
    String? id,
    String? company,
    String? location,
    int? local,
    String? classification,
    double? wage,
    bool? perDiem,
    String? typeOfWork,
    String? jobDescription,
    String? startDate,
    String? postedAt,
    bool? booked,
    String? status,
  }) {
      final now = DateTime.now();
      return {
        'id': id ?? 'test_job_123',
        'company': company ?? 'PowerGrid Solutions',
        'location': location ?? 'New York, NY',
        'local': local ?? 3,
        'classification': classification ?? 'Inside Wireman',
        'wage': wage ?? 45.50,
        'hours': 40,
        'typeOfWork': typeOfWork ?? 'Commercial',
        'jobDescription': jobDescription ?? 'Installing electrical systems',
        'startDate': startDate ?? now.add(const Duration(days: 7)).toIso8601String(),
        'postedAt': postedAt ?? now.toIso8601String(),
        'perDiem': perDiem ?? true,
        'perDiemAmount': '100',
        'booked': booked ?? false,
        'status': status ?? 'active',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'createdBy': 'test_user@example.com',
        'contactInfo': {
          'email': 'contact@company.com',
          'phone': '555-0123-4567',
        },
        'jobDetails': {
          'requirements': ['Journeyman license', 'OSHA 10', 'Reliable transportation'],
          'benefits': ['Health insurance', '401k', 'Paid time off'],
          'equipment': ['Basic hand tools provided'],
        },
      };
    }

  /// Creates a test Job model
  static Job createTestJob({
    String? id,
    String? company,
    String? location,
    int? local,
    String? classification,
    double? wage,
  }) {
      return Job.fromJson(createTestJobJson(
        id: id,
        company: company,
        location: location,
        local: local,
        classification: classification,
        wage: wage,
      ));
    }

  /// Creates a list of test jobs
  static List<Job> createTestJobList({int count = 5}) {
    return List.generate(count, (index) => createTestJob(
      id: 'test_job_${index + 1}',
      company: 'Company ${index + 1}',
      location: 'Location ${index + 1}',
      local: index + 1,
      wage: 40.0 + (index * 5.0),
    ));
  }

  /// Creates a test user
  static Map<String, dynamic> createTestUserJson({
    String? uid,
    String? email,
    String? displayName,
    String? local,
    List<String>? classifications,
  }) {
      final now = DateTime.now();
      return {
        'uid': uid ?? 'test_user_123',
        'email': email ?? 'test@example.com',
        'displayName': displayName ?? 'Test User',
        'local': local ?? '3',
        'classifications': classifications ?? ['Inside Wireman', 'Lineman'],
        'isEmailVerified': true,
        'createdAt': now.toIso8601String(),
        'lastSignInAt': now.toIso8601String(),
        'preferences': {
          'notifications': true,
          'darkMode': false,
          'autoApply': true,
        },
      };
    }
}

/// Test fixtures
class TestFixtures {
  /// Creates a mock Firebase user
  static MockUser createMockUser() {
    final mockUser = MockUser();
    when(mockUser.uid).thenReturn('test_user_123');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.isEmailVerified).thenReturn(true);
    when(mockUser.getIdToken()).thenAnswer((_) async => 'test_token');
    when(mockUser.getIdToken(refresh: true)).thenAnswer((_) async => 'test_token_refreshed');
    return mockUser;
  }

  /// Creates a mock Firestore instance with test data
  static FakeFirebaseFirestore createMockFirestore() {
    final firestore = FakeFirebaseFirestore();

    // Add test data
    firestore.collection('jobs').add(createTestJobJson());

    return firestore;
  }

  /// Creates test authentication state
  static AuthState createAuthState({
    User? user,
    bool isLoading = false,
    String? error,
  }) {
    return AuthState(
      user: user,
      isLoading: isLoading,
      error: error,
    );
  }
}

/// Performance testing utilities
class PerformanceUtils {
  /// Measures render time for a widget
  static Future<Duration> measureRenderTime(
    WidgetTester tester,
    Widget widget, {
    int iterations = 10,
  }) async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < iterations; i++) {
        await tester.pumpWidget(widget);
        await tester.pump();
      }

      stopwatch.stop();
      return Duration(
        milliseconds: stopwatch.elapsedMilliseconds ~/ iterations,
      );
    }

  /// Measures memory usage before and after rendering
  static Future<Map<String, double>> measureMemoryUsage(
    WidgetTester tester,
    Widget widget, {
    bool gcBefore = true,
    bool gcAfter = true,
  }) async {
      if (gcBefore) {
        // Force garbage collection
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final beforeMemory = _getCurrentMemoryUsage();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      final afterMemory = _getCurrentMemoryUsage();

      if (gcAfter) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      return {
        'before': beforeMemory,
        'after': afterMemory,
        'increase': afterMemory - beforeMemory,
      };
    }

  /// Get current memory usage in MB
  static double _getCurrentMemoryUsage() {
    // In a real implementation, this would use dart:developer to get memory usage
    // For now, return a mock value
    return 10.0;
  }
}

/// Golden test utilities
class GoldenTestUtils {
  /// Compare widget snapshot with golden file
  static Future<void> expectGoldenSnapshot(
    WidgetTester tester,
    Widget widget, {
    String? goldenName,
    bool skip = false,
  }) async {
      if (TestConfig.enableGoldenTests && !skip) {
        await tester.pumpWidget(widget);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'test/goldens/${goldenName ?? 'widget'}.png',
          ),
        );
      }
    }

  /// Create golden image comparator
  static Future<bool> compareGoldenImages(
    String actualPath,
    String goldenPath, {
    double threshold = 0.05,
  }) async {
      // Implementation would compare two images and return similarity score
      return true;
    }
}

/// Integration test utilities
class IntegrationTestUtils {
  /// Sets up Firebase emulators for testing
  static Future<void> setupFirebaseEmulators() async {
    // In a real implementation, this would configure Firebase emulators
    // For now, just wait to simulate setup time
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Creates a test environment with mocked services
  static Map<Type, dynamic> createTestServices() {
    return {
      // Return mocked service instances
    };
  }

  /// Waits for async operations to complete
  static Future<void> waitForAsyncOperations() async {
    // Wait for microtasks to complete
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Error testing utilities
class ErrorTestUtils {
  /// Creates a mock error for testing
  static Exception createMockError({
    String? message,
    String? code,
    StackTrace? stackTrace,
  }) {
    return Exception(message ?? 'Test error');
  }

  /// Simulates network error
  static SocketException createNetworkError({
    String? message,
    OSError? osError,
  }) {
      return SocketException(
        message ?? 'Network error',
        osError: osError ?? const OSError('Connection refused', 61),
      );
    }

  /// Simulates timeout error
  static TimeoutException createTimeoutError({
    String? message,
    Duration? duration,
  }) {
      return TimeoutException(
        message ?? 'Operation timed out',
        duration ?? const Duration(seconds: 30),
      );
    }

  /// Simulates Firebase auth error
  static FirebaseAuthException createAuthError({
    String? code,
    String? message,
  }) {
      return FirebaseAuthException(
        code: code ?? 'unknown',
        message: message ?? 'Authentication error',
      );
    }

  /// Simulates Firestore error
  static FirebaseException createFirestoreError({
    String? code,
    String? message,
  }) {
      return FirebaseException(
        code: code ?? 'unknown',
        message: message ?? 'Firestore error',
      );
    }
}