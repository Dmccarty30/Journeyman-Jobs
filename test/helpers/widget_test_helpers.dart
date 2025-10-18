import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/providers/app_state_provider.dart';
import 'package:journeyman_jobs/providers/job_filter_provider.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'test_helpers.dart';

/// Widget test helpers specifically for UI/widget testing
class WidgetTestHelpers {
  /// Create a MaterialApp wrapper with theme for widget testing
  static Widget createMaterialApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  /// Create a test app wrapper with full provider setup
  /// This is an alias for createThemedTestWidget for backward compatibility
  static Widget createTestApp({
    required Widget child,
    AuthService? authService,
    ResilientFirestoreService? firestoreService,
    ConnectivityService? connectivityService,
    AppStateProvider? appStateProvider,
    JobFilterProvider? jobFilterProvider,
  }) {
    return createThemedTestWidget(
      child,
      authService: authService,
      firestoreService: firestoreService,
      connectivityService: connectivityService,
      appStateProvider: appStateProvider,
      jobFilterProvider: jobFilterProvider,
    );
  }

  /// Create a themed wrapper with all necessary providers for widget testing
  static Widget createThemedTestWidget(
    Widget child, {
    AuthService? authService,
    ResilientFirestoreService? firestoreService,
    ConnectivityService? connectivityService,
    AppStateProvider? appStateProvider,
    JobFilterProvider? jobFilterProvider,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => authService ?? TestAuthService(),
          ),
          Provider<ResilientFirestoreService>(
            create: (_) => firestoreService ?? TestResilientFirestoreService(),
          ),
          ChangeNotifierProvider<ConnectivityService>(
            create: (_) => connectivityService ?? TestConnectivityService(),
          ),
          ChangeNotifierProvider<JobFilterProvider>(
            create: (_) => jobFilterProvider ?? JobFilterProvider(),
          ),
          ChangeNotifierProxyProvider3<AuthService, ResilientFirestoreService,
              ConnectivityService, AppStateProvider>(
            create: (context) =>
                appStateProvider ??
                AppStateProvider(
                  context.read<AuthService>(),
                  context.read<ResilientFirestoreService>(),
                  context.read<ConnectivityService>(),
                ),
            update: (context, authService, firestoreService, connectivityService,
                    previous) =>
                previous ??
                AppStateProvider(
                  authService,
                  firestoreService,
                  connectivityService,
                ),
          ),
        ],
        child: child,
      ),
    );
  }

  /// Common electrical theme assertions
  static void expectElectricalTheme(WidgetTester tester) {
    // Check for primary navy color usage
    expect(
      tester.widget<Container>(find.byType(Container).first).decoration,
      isA<BoxDecoration>(),
    );
  }

  /// Find widgets by electrical component keys
  static Finder findElectricalComponent(String componentKey) {
    return find.byKey(Key('electrical-$componentKey'));
  }

  /// Common assertions for job-related widgets
  static void expectJobCardElements(WidgetTester tester) {
    expect(find.text('IBEW Local'), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.location_on), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.work), findsAtLeastNWidgets(1));
  }

  /// Common assertions for union/local widgets
  static void expectUnionCardElements(WidgetTester tester) {
    expect(find.textContaining('Local'), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.phone), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.location_on), findsAtLeastNWidgets(1));
  }

  /// Electrical loading animation test helper
  static Future<void> expectElectricalLoadingAnimation(
    WidgetTester tester,
  ) async {
    // Look for electrical themed loading indicators
    expect(
      find.byKey(const Key('electrical-loader')),
      findsOneWidget,
    );
    
    // Pump a few frames to ensure animation is running
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Circuit breaker component test helper
  static Future<void> testCircuitBreakerSwitch(
    WidgetTester tester,
    Widget circuitBreakerWidget,
  ) async {
    await tester.pumpWidget(createMaterialApp(circuitBreakerWidget));
    
    // Check initial state
    expect(find.byKey(const Key('circuit-breaker-switch')), findsOneWidget);
    
    // Test toggle functionality
    await tester.tap(find.byKey(const Key('circuit-breaker-switch')));
    await tester.pump();
    
    // Verify state change (implementation specific)
  }
}

/// Extensions for electrical industry specific widget testing
extension ElectricalWidgetTesterExtensions on WidgetTester {
  /// Find IBEW local number displays
  Finder findLocalNumber(int localNumber) {
    return find.textContaining('Local $localNumber');
  }

  /// Find classification badges
  Finder findClassificationBadge(String classification) {
    return find.textContaining(classification);
  }

  /// Find wage displays
  Finder findWageDisplay(double wage) {
    return find.textContaining('\$${wage.toStringAsFixed(2)}');
  }

  /// Test electrical component animations
  Future<void> testElectricalAnimation(Finder animationFinder) async {
    expect(animationFinder, findsOneWidget);
    
    // Pump multiple frames to test animation
    for (int i = 0; i < 5; i++) {
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Verify electrical color scheme
  void verifyElectricalColors() {
    // Check for presence of navy and copper colors in the widget tree
    final containers = widgetList<Container>(find.byType(Container));
    
    bool hasNavyColor = containers.any((container) {
      final decoration = container.decoration;
      if (decoration is BoxDecoration) {
        return decoration.color == AppTheme.primaryNavy ||
               (decoration.gradient as LinearGradient?)?.colors.contains(AppTheme.primaryNavy) == true;
      }
      return false;
    });
    
    expect(hasNavyColor, isTrue, reason: 'Should contain electrical navy color');
  }
}

/// Mock data builders for widget tests
class WidgetTestDataBuilders {
  /// Build test job data for widget tests
  static Map<String, dynamic> buildJobData({
    String? company,
    String? location,
    String? classification,
    int? localNumber,
    double? wage,
  }) {
    return {
      'company': company ?? 'Test Electric Co',
      'location': location ?? 'Test City, TS',
      'classification': classification ?? 'Inside Wireman',
      'local': localNumber ?? 123,
      'wage': wage ?? 45.50,
      'job_title': 'Journeyman Electrician',
      'startDate': '2025-01-15',
      'typeOfWork': 'Commercial',
    };
  }

  /// Build test union local data for widget tests
  static Map<String, dynamic> buildLocalData({
    int? localNumber,
    String? name,
    String? state,
    List<String>? classifications,
  }) {
    return {
      'localNumber': localNumber ?? 123,
      'name': name ?? 'IBEW Local ${localNumber ?? 123}',
      'state': state ?? 'TS',
      'phone': '(555) 123-4567',
      'classifications': classifications ?? ['Inside Wireman', 'Journeyman Lineman'],
      'website': 'https://local${localNumber ?? 123}.ibew.org',
    };
  }
}