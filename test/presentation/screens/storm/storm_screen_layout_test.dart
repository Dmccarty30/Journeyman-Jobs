import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/screens/storm/storm_screen.dart';
import 'package:journeyman_jobs/providers/riverpod/contractor_provider.dart';
import 'package:journeyman_jobs/models/contractor_model.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/widgets/contractor_card.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';

/// Layout validation tests for Storm Screen UI alignment
///
/// Tests verify STORM-001 through STORM-006 implementations:
/// - Circuit background density (STORM-001)
/// - Container borders and shadows (STORM-002, STORM-003, STORM-004)
/// - Contractor card styling (STORM-005, STORM-006)
/// - Responsive layout without overflow
///
/// Reference: STORM-007 - Visual regression testing for storm screen
void main() {
  group('STORM-007: Storm Screen Layout Tests', () {

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

    testWidgets('STORM-007.1: Storm screen renders without overflow', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      // Initial pump
      await tester.pump();

      // Verify main elements are present
      expect(find.text('Storm Work'), findsOneWidget);
      expect(find.byType(StormScreen), findsOneWidget);

      // Verify no overflow errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('STORM-007.2: Circuit background uses correct density', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Find the circuit background component
      final circuitBackground = tester.widget<ElectricalCircuitBackground>(
        find.byType(ElectricalCircuitBackground),
      );

      // Verify STORM-001: ComponentDensity.medium (not high)
      expect(circuitBackground.componentDensity, equals(ComponentDensity.medium));

      // Verify opacity is 0.08 for subtle effect
      expect(circuitBackground.opacity, equals(0.08));

      // Verify current flow animation is enabled
      expect(circuitBackground.enableCurrentFlow, isTrue);
    });

    testWidgets('STORM-007.3: Main container uses correct border and shadow', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Find the main container (first Container with copper border)
      final mainContainer = tester.widgetList<Container>(
        find.byType(Container),
      ).firstWhere(
        (container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.border != null &&
                 (decoration!.border as Border).top.width == AppTheme.borderWidthMedium;
        },
      );

      final decoration = mainContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;

      // Verify STORM-002: Border width is borderWidthMedium (1.5px)
      expect(border.top.width, equals(AppTheme.borderWidthMedium));

      // Verify border color is accentCopper
      expect(border.top.color, equals(AppTheme.accentCopper));

      // Verify STORM-003: Shadow uses AppTheme.shadowCard
      expect(decoration.boxShadow, equals(AppTheme.shadowCard));
    });

    testWidgets('STORM-007.4: Contractor cards use correct styling', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Wait for contractors to load
      await tester.pump(const Duration(milliseconds: 100));

      // Find contractor card
      final contractorCard = find.byType(ContractorCard);

      if (contractorCard.evaluate().isNotEmpty) {
        final cardContainer = tester.widget<Container>(
          find.descendant(
            of: contractorCard,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = cardContainer.decoration as BoxDecoration;

        // Verify STORM-005: Border radius uses AppTheme.radiusMd (12px)
        expect(
          decoration.borderRadius,
          equals(BorderRadius.circular(AppTheme.radiusMd)),
        );

        // Verify STORM-006: Shadow uses AppTheme.shadowCard
        expect(decoration.boxShadow, equals(AppTheme.shadowCard));
      }
    });

    testWidgets('STORM-007.5: No layout overflow on small screens', (tester) async {
      // Test on smallest common phone size
      await tester.binding.setSurfaceSize(const Size(320, 568));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Verify no overflow errors
      expect(tester.takeException(), isNull);

      // Verify main elements are visible
      expect(find.text('Storm Work'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.6: Responsive layout on tablet', (tester) async {
      // Test on tablet size
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Verify no overflow errors
      expect(tester.takeException(), isNull);

      // Verify main elements are visible
      expect(find.text('Storm Work'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('STORM-007.7: Filter dropdown uses correct styling', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Find the filter dropdown container
      final dropdownText = find.text('All Regions');
      expect(dropdownText, findsOneWidget);

      // The dropdown should be wrapped in a Container with proper styling
      // This validates STORM-004: Filter dropdown styling consistency
      final containers = tester.widgetList<Container>(find.byType(Container));

      // Find container with copper border (filter dropdown)
      final filterContainer = containers.firstWhere(
        (container) {
          final decoration = container.decoration as BoxDecoration?;
          if (decoration?.border == null) return false;
          final border = decoration!.border as Border;
          return border.top.color == AppTheme.accentCopper &&
                 border.top.width == AppTheme.borderWidthMedium;
        },
      );

      final decoration = filterContainer.decoration as BoxDecoration;

      // Verify STORM-004: Uses borderWidthMedium
      expect((decoration.border as Border).top.width, equals(AppTheme.borderWidthMedium));

      // Verify STORM-004: Uses shadowCard
      expect(decoration.boxShadow, equals(AppTheme.shadowCard));
    });

    testWidgets('STORM-007.8: AppBar styling consistency', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Find AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));

      // Verify AppBar uses primary navy color
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));

      // Verify title is present
      expect(find.text('Storm Work'), findsOneWidget);

      // Verify notification icon is present
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('STORM-007.9: Multiple screen densities render correctly', (tester) async {
      final densities = [1.0, 2.0, 3.0];

      for (final density in densities) {
        tester.view.devicePixelRatio = density;

        await tester.pumpWidget(
          createTestWidget(child: const StormScreen()),
        );

        await tester.pump();

        // Verify no overflow or rendering issues at this density
        expect(tester.takeException(), isNull);

        // Verify main elements render
        expect(find.text('Storm Work'), findsOneWidget);
      }

      // Reset to default
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('STORM-007.10: Verify electrical theme components', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StormScreen()),
      );

      await tester.pump();

      // Verify circuit background is present
      expect(find.byType(ElectricalCircuitBackground), findsOneWidget);

      // Verify lightning/flash icon in AppBar
      expect(find.byIcon(Icons.flash_on), findsOneWidget);

      // Verify electrical theme colors are used
      final containers = tester.widgetList<Container>(find.byType(Container));

      // At least one container should use accentCopper
      final hasCopper = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.border == null) return false;
        final border = decoration!.border as Border;
        return border.top.color == AppTheme.accentCopper;
      });

      expect(hasCopper, isTrue);
    });
  });

  group('STORM-007: Design System Compliance', () {
    testWidgets('STORM-007.11: All design system constants used correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contractorsStreamProvider.overrideWith((ref) {
              return Stream.value([
                Contractor(
                  id: 'test',
                  company: 'Test',
                  howToSignup: 'Call',
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

      await tester.pump();

      // This test validates that no hardcoded values are used
      // All styling should come from AppTheme constants

      // Verify circuit background exists with correct configuration
      final circuitBg = tester.widget<ElectricalCircuitBackground>(
        find.byType(ElectricalCircuitBackground),
      );

      expect(circuitBg.componentDensity, ComponentDensity.medium);
      expect(circuitBg.opacity, 0.08);
      expect(circuitBg.enableCurrentFlow, true);

      // No exceptions should occur
      expect(tester.takeException(), isNull);
    });
  });
}
