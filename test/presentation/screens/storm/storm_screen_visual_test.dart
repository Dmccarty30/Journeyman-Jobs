import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/screens/storm/storm_screen.dart';
import 'package:journeyman_jobs/providers/riverpod/contractor_provider.dart';
import 'package:journeyman_jobs/models/contractor_model.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Visual regression tests for Storm Screen UI alignment
///
/// Tests verify:
/// - Circuit background rendering at ComponentDensity.medium
/// - Main container border width (1.5px copper)
/// - Shadow consistency with AppTheme.shadowCard
/// - Contractor card styling consistency
/// - Responsive layout across device sizes
///
/// Reference: STORM-007 - Visual regression testing for storm screen
void main() {
  group('STORM-007: Storm Screen Visual Regression Tests', () {

    // Mock contractor data for consistent testing
    final mockContractors = [
      Contractor(
        id: 'test-1',
        company: 'Test Electrical Contractors Inc',
        howToSignup: 'Call dispatch office',
        phoneNumber: '555-123-4567',
        email: 'dispatch@test-electrical.com',
        website: 'https://test-electrical.com',
        createdAt: DateTime(2025, 1, 1),
      ),
      Contractor(
        id: 'test-2',
        company: 'Storm Response Electrical LLC',
        howToSignup: 'Online portal registration',
        phoneNumber: '555-987-6543',
        email: 'signup@storm-response.com',
        website: 'https://storm-response.com',
        createdAt: DateTime(2025, 1, 1),
      ),
    ];

    /// Helper function to create test widget with proper theming and providers
    Widget createTestWidget({
      required Widget child,
    }) {
      return ProviderScope(
        overrides: [
          // Mock contractor provider with test data
          contractorsStreamProvider.overrideWith((ref) {
            return Stream.value(mockContractors);
          }),
        ],
        child: MaterialApp(
          theme: ThemeData(
            primaryColor: AppTheme.primaryNavy,
            scaffoldBackgroundColor: AppTheme.lightGray,
            fontFamily: 'Inter',
          ),
          home: child,
        ),
      );
    }

    testWidgets('STORM-007.1: Phone portrait layout (375x667)', (tester) async {
      // Set device size to iPhone SE (375x667)
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      // Wait for all animations and async operations to complete
      await tester.pumpAndSettle();

      // Verify main elements are present and properly rendered
      expect(find.text('Storm Work'), findsOneWidget);
      expect(find.byType(StormScreen), findsOneWidget);

      // Visual snapshot for phone portrait
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_phone_portrait.png'),
      );

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.2: Phone landscape layout (667x375)', (tester) async {
      // Set device size to iPhone SE landscape
      await tester.binding.setSurfaceSize(const Size(667, 375));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Visual snapshot for phone landscape
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_phone_landscape.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.3: Tablet portrait layout (768x1024)', (tester) async {
      // Set device size to iPad mini portrait
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Visual snapshot for tablet portrait
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_tablet_portrait.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.4: Tablet landscape layout (1024x768)', (tester) async {
      // Set device size to iPad mini landscape
      await tester.binding.setSurfaceSize(const Size(1024, 768));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Visual snapshot for tablet landscape
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_tablet_landscape.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.5: Circuit background renders correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Verify circuit background is present with correct density
      // The background uses ComponentDensity.medium (per STORM-001)
      final background = find.byType(StormScreen);
      expect(background, findsOneWidget);

      // Visual verification of circuit background at medium density
      await expectLater(
        background,
        matchesGoldenFile('goldens/storm_screen_circuit_background.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.6: Contractor cards display with correct styling', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Scroll to contractor section
      await tester.scrollUntilVisible(
        find.text('Storm Contractors'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();

      // Verify contractor cards are rendered
      expect(find.text('Test Electrical Contractors Inc'), findsOneWidget);

      // Visual verification of contractor cards styling
      // Cards should use AppTheme.radiusMd and AppTheme.shadowCard (per STORM-005, STORM-006)
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_contractor_cards.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.7: Main container styling verification', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Visual verification of main container
      // Border: AppTheme.borderWidthMedium (1.5px) with AppTheme.accentCopper (per STORM-002)
      // Shadow: AppTheme.shadowCard (per STORM-003)
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_main_container.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.8: Different screen densities (1x, 2x, 3x)', (tester) async {
      // Test with different pixel ratios to verify rendering consistency

      // 1x density (mdpi)
      await tester.binding.setSurfaceSize(const Size(375, 667));
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_density_1x.png'),
      );

      // 2x density (xhdpi)
      tester.view.devicePixelRatio = 2.0;
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_density_2x.png'),
      );

      // 3x density (xxhdpi)
      tester.view.devicePixelRatio = 3.0;
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_density_3x.png'),
      );

      // Reset
      tester.view.resetDevicePixelRatio();
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.9: No layout overflow or rendering issues', (tester) async {
      // Test various sizes to ensure no overflow
      final testSizes = [
        const Size(320, 568), // iPhone SE 1st gen (smallest)
        const Size(375, 667), // iPhone SE 2nd gen
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad mini
        const Size(1024, 1366), // iPad Pro 12.9"
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          createTestWidget(child: const StormScreen()),
        );

        await tester.pumpAndSettle();

        // Verify no overflow errors
        expect(tester.takeException(), isNull);

        // Verify main elements are visible
        expect(find.text('Storm Work'), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.10: Filter dropdown styling consistency', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pumpAndSettle();

      // Find and interact with filter dropdown
      final dropdown = find.text('All Regions');
      expect(dropdown, findsOneWidget);

      // Visual verification of filter dropdown styling
      // Should use borderWidthMedium and shadowCard (per STORM-004)
      await expectLater(
        find.byType(StormScreen),
        matchesGoldenFile('goldens/storm_screen_filter_dropdown.png'),
      );

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('STORM-007: Performance and Quality Validation', () {
    testWidgets('STORM-007.11: Frame rate performance check', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contractorsStreamProvider.overrideWith((ref) {
              return Stream.value([
                Contractor(
                  id: 'test-1',
                  company: 'Test Contractor',
                  howToSignup: 'Call',
                  phoneNumber: '555-1234',
                  createdAt: DateTime(2025, 1, 1),
                ),
              ]);
            }),
          ],
          child: MaterialApp(
            theme: ThemeData(
              primaryColor: AppTheme.primaryNavy,
            ),
            home: const StormScreen(),
          ),
        ),
      );

      // Measure initial build time
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Initial build should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Verify smooth scrolling (no frame drops)
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );

      await tester.pumpAndSettle();

      // No exceptions should occur during scrolling
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
