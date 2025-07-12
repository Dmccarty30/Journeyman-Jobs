/// Test helpers and utilities for Journeyman Jobs testing
/// 
/// Provides common test setup, mocks, and utilities used across
/// all test files in the project.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/providers/auth_provider.dart';
import 'package:journeyman_jobs/providers/job_filter_provider.dart';

/// Creates a MaterialApp with necessary providers for testing widgets
Widget createTestApp({
  required Widget child,
  GoRouter? router,
  List<Provider>? additionalProviders,
}) {
  final providers = <Provider>[
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
    ),
    ChangeNotifierProvider<JobFilterProvider>(
      create: (_) => JobFilterProvider(),
    ),
    ...?additionalProviders,
  ];

  if (router != null) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp.router(
        title: 'Journeyman Jobs Test',
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  return MultiProvider(
    providers: providers,
    child: MaterialApp(
      title: 'Journeyman Jobs Test',
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

/// Test data generators for consistent test fixtures
class TestDataGenerators {
  /// Generate mock UserModel data for testing
  static Map<String, dynamic> mockUserData({
    String uid = 'test_uid',
    String firstName = 'John',
    String lastName = 'Doe',
    String email = 'john.doe@test.com',
    String classification = 'Journeyman Lineman',
    String homeLocal = '123',
    bool isWorking = false,
  }) {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': '555-1234',
      'email': email,
      'address1': '123 Test St',
      'city': 'Test City',
      'state': 'TX',
      'zipcode': '12345',
      'homeLocal': homeLocal,
      'ticketNumber': '456789',
      'classification': classification,
      'isWorking': isWorking,
      'constructionTypes': ['Distribution', 'Transmission'],
      'networkWithOthers': true,
      'careerAdvancements': false,
      'betterBenefits': true,
      'higherPayRate': false,
      'learnNewSkill': true,
      'travelToNewLocation': false,
      'findLongTermWork': true,
      'onboardingStatus': 'completed',
      'createdTime': DateTime.now().toIso8601String(),
    };
  }

  /// Generate mock StormEvent data for testing
  static Map<String, dynamic> mockStormEventData({
    String id = 'storm_001',
    String name = 'Hurricane Test',
    String region = 'Gulf Coast',
    String severity = 'Critical',
    int openPositions = 50,
  }) {
    return {
      'id': id,
      'name': name,
      'region': region,
      'severity': severity,
      'affectedUtilities': ['Texas Power & Light', 'Gulf Coast Electric'],
      'estimatedDuration': '2-3 weeks',
      'openPositions': openPositions,
      'payRate': '\$45-55/hr',
      'perDiem': '\$150/day',
      'status': 'Active',
      'description': 'Emergency storm restoration work following hurricane damage.',
      'deploymentDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    };
  }

  /// Generate mock Job data for testing
  static Map<String, dynamic> mockJobData({
    String id = 'job_001',
    String local = '456',
    String classification = 'Journeyman Lineman',
    String location = 'Houston, TX',
  }) {
    return {
      'id': id,
      'local': local,
      'classification': classification,
      'location': location,
      'typeOfWork': 'Distribution',
      'payRate': '\$42/hr',
      'description': 'Distribution line maintenance and construction',
      'timestamp': DateTime.now().toIso8601String(),
      'isActive': true,
    };
  }

  /// Generate mock Local Union data for testing
  static Map<String, dynamic> mockLocalData({
    String localUnion = 'Local 123',
    String city = 'Houston',
    String state = 'TX',
  }) {
    return {
      'localUnion': localUnion,
      'city': city,
      'state': state,
      'phone': '(555) 123-4567',
      'address': '123 Union St',
      'zipcode': '77001',
      'classifications': ['Journeyman Lineman', 'Journeyman Electrician'],
    };
  }
}

/// Common test expectations
class TestExpectations {
  /// Verify electrical theme elements are present
  static void verifyElectricalTheme(WidgetTester tester) {
    // Check for electrical-themed colors
    expect(find.byWidgetPredicate((widget) =>
      widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).color == AppTheme.primaryNavy
    ), findsAtLeastNWidgets(1));
  }

  /// Verify accessibility features
  static void verifyAccessibility(WidgetTester tester) {
    // Check for semantic labels
    expect(find.byWidgetPredicate((widget) =>
      widget is Semantics && widget.properties.label != null
    ), findsAtLeastNWidgets(1));
  }

  /// Verify responsive design
  static Future<void> verifyResponsiveDesign(
    WidgetTester tester,
    Widget Function() widgetBuilder,
  ) async {
    // Test different screen sizes
    final sizes = [
      const Size(375, 812), // iPhone X
      const Size(414, 896), // iPhone 11 Pro Max
      const Size(768, 1024), // iPad
    ];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(widgetBuilder());
      await tester.pumpAndSettle();
      
      // Verify no overflow
      expect(tester.takeException(), isNull);
    }
  }
}

/// Test utilities for common operations
class TestUtils {
  /// Enter text into a field and trigger validation
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Tap a widget and wait for animations
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Scroll until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable,
  ) async {
    await tester.scrollUntilVisible(
      finder,
      500.0,
      scrollable: scrollable,
    );
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}