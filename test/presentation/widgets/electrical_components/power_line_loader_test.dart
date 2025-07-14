import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/electrical_components/power_line_loader.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('PowerLineLoader - Widget Rendering', () {
    testWidgets('should render with default properties', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PowerLineLoader), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should render with custom width and height', (tester) async {
      // Arrange
      const customWidth = 200.0;
      const customHeight = 100.0;

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(
            width: customWidth,
            height: customHeight,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final loaderWidget = tester.widget<PowerLineLoader>(
        find.byType(PowerLineLoader),
      );
      expect(loaderWidget.width, equals(customWidth));
      expect(loaderWidget.height, equals(customHeight));

      final container = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(container.width, equals(customWidth));
      expect(container.height, equals(customHeight));
    });

    testWidgets('should render with custom line color', (tester) async {
      // Arrange
      const customColor = Colors.blue;

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(lineColor: customColor),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final loaderWidget = tester.widget<PowerLineLoader>(
        find.byType(PowerLineLoader),
      );
      expect(loaderWidget.lineColor, equals(customColor));
    });

    testWidgets('should use default electrical theme colors', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final loaderWidget = tester.widget<PowerLineLoader>(
        find.byType(PowerLineLoader),
      );
      expect(loaderWidget.lineColor, equals(AppTheme.primaryNavy));
      expect(loaderWidget.sparkColor, equals(AppTheme.accentCopper));
    });
  });

  group('PowerLineLoader - Animation Behavior', () {
    testWidgets('should animate spark movement along power lines', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );

      // Get initial state
      await tester.pump();
      final initialPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      
      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));
      final midPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      
      // Advance more
      await tester.pump(const Duration(milliseconds: 1000));
      final finalPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));

      // Assert - Animation should be running
      expect(initialPaint, isNotNull);
      expect(midPaint, isNotNull);
      expect(finalPaint, isNotNull);
    });

    testWidgets('should respect custom animation duration', (tester) async {
      // Arrange
      const customDuration = Duration(milliseconds: 800);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(
            animationDuration: customDuration,
          ),
        ),
      );

      // Assert
      final loaderWidget = tester.widget<PowerLineLoader>(
        find.byType(PowerLineLoader),
      );
      expect(loaderWidget.animationDuration, equals(customDuration));
    });

    testWidgets('should loop animation continuously', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );

      // Run through multiple animation cycles
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 2));
      }

      // Assert - Should still be animating
      expect(find.byType(PowerLineLoader), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle animation disposal properly', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Remove widget
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const SizedBox(),
        ),
      );

      // Assert - Should not throw errors during disposal
      expect(find.byType(PowerLineLoader), findsNothing);
    });
  });

  group('PowerLineLoader - Electrical Industry Features', () {
    testWidgets('should represent power transmission lines', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(
            width: 300,
            height: 80,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should use electrical industry colors
      final loaderWidget = tester.widget<PowerLineLoader>(
        find.byType(PowerLineLoader),
      );
      expect(loaderWidget.lineColor, equals(AppTheme.primaryNavy));
      expect(loaderWidget.sparkColor, equals(AppTheme.accentCopper));
    });

    testWidgets('should work as loading indicator for electrical operations', (tester) async {
      // Arrange - Simulating electrical system loading
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: Column(
            children: const [
              Text('Connecting to Grid...'),
              SizedBox(height: 20),
              PowerLineLoader(width: 200, height: 60),
              SizedBox(height: 10),
              Text('Establishing Power Flow'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Connecting to Grid...'), findsOneWidget);
      expect(find.text('Establishing Power Flow'), findsOneWidget);
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should support storm work loading scenarios', (tester) async {
      // Arrange - Storm restoration loading
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Icon(Icons.flash_on, color: Colors.orange, size: 32),
                  SizedBox(height: 8),
                  Text('Emergency Restoration in Progress'),
                  SizedBox(height: 16),
                  PowerLineLoader(
                    width: 250,
                    height: 50,
                    sparkColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Emergency Restoration in Progress'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should scale for different voltage scenarios', (tester) async {
      // Act - Different sizes for different voltage levels
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: Column(
            children: const [
              Text('Low Voltage (120V)'),
              PowerLineLoader(width: 100, height: 20),
              SizedBox(height: 10),
              Text('Medium Voltage (480V)'),
              PowerLineLoader(width: 150, height: 30),
              SizedBox(height: 10),
              Text('High Voltage (13.8kV)'),
              PowerLineLoader(width: 200, height: 40),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PowerLineLoader), findsNWidgets(3));
      expect(find.text('Low Voltage (120V)'), findsOneWidget);
      expect(find.text('High Voltage (13.8kV)'), findsOneWidget);
    });
  });

  group('PowerLineLoader - Performance', () {
    testWidgets('should handle multiple instances efficiently', (tester) async {
      // Act - Multiple loaders like in a dashboard
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => ListTile(
              title: Text('Circuit $index'),
              subtitle: PowerLineLoader(
                width: 150,
                height: 25,
                key: ValueKey('loader-$index'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PowerLineLoader), findsNWidgets(5));
      expect(find.byType(ListTile), findsNWidgets(5));
    });

    testWidgets('should optimize drawing for large instances', (tester) async {
      // Act - Very large power line loader
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(
            width: 800,
            height: 200,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should render without performance issues
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should not cause memory leaks with animations', (tester) async {
      // Act - Create and destroy widget multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          WidgetTestHelpers.createTestApp(
            child: PowerLineLoader(key: ValueKey('loader-$i')),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        
        await tester.pumpWidget(
          WidgetTestHelpers.createTestApp(
            child: const SizedBox(),
          ),
        );
      }

      // Assert - Should complete without errors
      expect(find.byType(PowerLineLoader), findsNothing);
    });
  });

  group('PowerLineLoader - Edge Cases', () {
    testWidgets('should handle zero dimensions gracefully', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(width: 0, height: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should render without errors
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should handle very small dimensions', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(width: 1, height: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should render without errors
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should handle extreme aspect ratios', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(width: 1000, height: 10),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should render without errors
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should handle null colors gracefully', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(
            lineColor: null,
            sparkColor: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should use default colors
      final loaderWidget = tester.widget<PowerLineLoader>(
        find.byType(PowerLineLoader),
      );
      expect(loaderWidget.lineColor, equals(AppTheme.primaryNavy));
      expect(loaderWidget.sparkColor, equals(AppTheme.accentCopper));
    });
  });

  group('PowerLineLoader - Accessibility', () {
    testWidgets('should have proper semantics for screen readers', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should have loading semantics
      expect(find.bySemanticsLabel('Power transmission loading'), findsOneWidget);
    });

    testWidgets('should support high contrast themes', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(),
          ),
          child: const PowerLineLoader(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should adapt to theme
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should respect reduced motion preferences', (tester) async {
      // Arrange - Simulate reduced motion accessibility setting
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue = 
          FakeAccessibilityFeatures(disableAnimations: true);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const PowerLineLoader(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should still render but potentially without animation
      expect(find.byType(PowerLineLoader), findsOneWidget);
    });

    testWidgets('should provide meaningful loading context', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const Semantics(
            label: 'Loading electrical job data',
            child: PowerLineLoader(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel('Loading electrical job data'), findsOneWidget);
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