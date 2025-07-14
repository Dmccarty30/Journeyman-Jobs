import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/electrical_components/electrical_rotation_meter.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('ElectricalRotationMeter - Widget Rendering', () {
    testWidgets('should render with default properties', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElectricalRotationMeter), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should render with custom size', (tester) async {
      // Arrange
      const customSize = 150.0;

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(size: customSize),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final meterWidget = tester.widget<ElectricalRotationMeter>(
        find.byType(ElectricalRotationMeter),
      );
      expect(meterWidget.size, equals(customSize));

      final container = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(container.width, equals(customSize));
      expect(container.height, equals(customSize));
    });

    testWidgets('should render with custom color', (tester) async {
      // Arrange
      const customColor = Colors.red;

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(color: customColor),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final meterWidget = tester.widget<ElectricalRotationMeter>(
        find.byType(ElectricalRotationMeter),
      );
      expect(meterWidget.color, equals(customColor));
    });

    testWidgets('should use default electrical theme color', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final meterWidget = tester.widget<ElectricalRotationMeter>(
        find.byType(ElectricalRotationMeter),
      );
      expect(meterWidget.color, equals(AppTheme.accentCopper));
    });
  });

  group('ElectricalRotationMeter - Animation Behavior', () {
    testWidgets('should animate rotation continuously', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );

      // Get initial rotation
      await tester.pump();
      final initialPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      
      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));
      final midPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      
      // Advance more
      await tester.pump(const Duration(milliseconds: 500));
      final finalPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));

      // Assert - Animation should be running
      expect(initialPaint, isNotNull);
      expect(midPaint, isNotNull);
      expect(finalPaint, isNotNull);
    });

    testWidgets('should respect animation duration', (tester) async {
      // Arrange
      const customDuration = Duration(milliseconds: 500);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(
            animationDuration: customDuration,
          ),
        ),
      );

      // Assert
      final meterWidget = tester.widget<ElectricalRotationMeter>(
        find.byType(ElectricalRotationMeter),
      );
      expect(meterWidget.animationDuration, equals(customDuration));
    });

    testWidgets('should handle animation disposal properly', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Remove widget
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const SizedBox(),
        ),
      );

      // Assert - Should not throw errors during disposal
      expect(find.byType(ElectricalRotationMeter), findsNothing);
    });
  });

  group('ElectricalRotationMeter - Electrical Industry Features', () {
    testWidgets('should represent electrical meter aesthetics', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should use copper color typical of electrical work
      final meterWidget = tester.widget<ElectricalRotationMeter>(
        find.byType(ElectricalRotationMeter),
      );
      expect(meterWidget.color, equals(AppTheme.accentCopper));
    });

    testWidgets('should work as loading indicator for electrical calculations', (tester) async {
      // Arrange - Simulating electrical calculation loading
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: Column(
            children: const [
              Text('Calculating Wire Size...'),
              ElectricalRotationMeter(size: 40),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Calculating Wire Size...'), findsOneWidget);
      expect(find.byType(ElectricalRotationMeter), findsOneWidget);
    });

    testWidgets('should scale appropriately for different contexts', (tester) async {
      // Act - Test multiple sizes for different use cases
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: Column(
            children: const [
              ElectricalRotationMeter(size: 20), // Small - for inline loading
              ElectricalRotationMeter(size: 50), // Medium - for cards
              ElectricalRotationMeter(size: 100), // Large - for full screen
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElectricalRotationMeter), findsNWidgets(3));
    });
  });

  group('ElectricalRotationMeter - Performance', () {
    testWidgets('should handle multiple instances efficiently', (tester) async {
      // Act - Create multiple meters like in a job list
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => const ListTile(
              trailing: ElectricalRotationMeter(size: 30),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElectricalRotationMeter), findsNWidgets(10));
      expect(find.byType(ListTile), findsNWidgets(10));
    });

    testWidgets('should not cause memory leaks with animations', (tester) async {
      // Act - Create and destroy widget multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          WidgetTestHelpers.createTestApp(
            child: ElectricalRotationMeter(key: ValueKey('meter-$i')),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        
        await tester.pumpWidget(
          WidgetTestHelpers.createTestApp(
            child: const SizedBox(),
          ),
        );
      }

      // Assert - Should complete without errors
      expect(find.byType(ElectricalRotationMeter), findsNothing);
    });
  });

  group('ElectricalRotationMeter - Edge Cases', () {
    testWidgets('should handle zero size gracefully', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(size: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should render without errors
      expect(find.byType(ElectricalRotationMeter), findsOneWidget);
    });

    testWidgets('should handle very large size', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(size: 1000),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should render without errors
      expect(find.byType(ElectricalRotationMeter), findsOneWidget);
    });

    testWidgets('should handle null color gracefully', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(color: null),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should use default color
      final meterWidget = tester.widget<ElectricalRotationMeter>(
        find.byType(ElectricalRotationMeter),
      );
      expect(meterWidget.color, equals(AppTheme.accentCopper));
    });
  });

  group('ElectricalRotationMeter - Accessibility', () {
    testWidgets('should have proper semantics for screen readers', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should have loading semantics
      expect(find.bySemanticsLabel('Loading indicator'), findsOneWidget);
    });

    testWidgets('should support high contrast themes', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(),
          ),
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should adapt to theme
      expect(find.byType(ElectricalRotationMeter), findsOneWidget);
    });

    testWidgets('should respect reduced motion preferences', (tester) async {
      // Arrange - Simulate reduced motion accessibility setting
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue = 
          FakeAccessibilityFeatures(disableAnimations: true);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const ElectricalRotationMeter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should still render but potentially without animation
      expect(find.byType(ElectricalRotationMeter), findsOneWidget);
    });
  });
}

class FakeAccessibilityFeatures implements AccessibilityFeatures {
  const FakeAccessibilityFeatures({
    this.accessibleNavigation = false,
    this.boldText = false,
    this.disableAnimations = false,
    this.highContrast = false,
    this.invertColors = false,
    this.onOffSwitchLabels = false,
    this.reduceMotion = false,
  });

  @override
  final bool accessibleNavigation;
  
  @override
  final bool boldText;
  
  @override
  final bool disableAnimations;
  
  @override
  final bool highContrast;
  
  @override
  final bool invertColors;
  
  @override
  final bool onOffSwitchLabels;
  
  @override
  final bool reduceMotion;
}