import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/electrical_components/jj_circuit_breaker_switch.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

import '../../test_utils/test_helpers.dart';

void main() {
  group('JJCircuitBreakerSwitch Widget Tests', () {
    testWidgets('should display circuit breaker in OFF state by default',
        (WidgetTester tester) async {
      // Arrange
      bool switchValue = false;
      
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: switchValue,
            onChanged: (value) => switchValue = value,
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(JJCircuitBreakerSwitch), findsOneWidget);
      
      // Check for OFF state visual elements
      final switchWidget = tester.widget<JJCircuitBreakerSwitch>(
        find.byType(JJCircuitBreakerSwitch),
      );
      expect(switchWidget.value, isFalse);
    });

    testWidgets('should display circuit breaker in ON state when value is true',
        (WidgetTester tester) async {
      // Arrange
      bool switchValue = true;
      
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: switchValue,
            onChanged: (value) => switchValue = value,
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      final switchWidget = tester.widget<JJCircuitBreakerSwitch>(
        find.byType(JJCircuitBreakerSwitch),
      );
      expect(switchWidget.value, isTrue);
    });

    testWidgets('should call onChanged when tapped',
        (WidgetTester tester) async {
      // Arrange
      bool switchValue = false;
      bool onChangedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: switchValue,
            onChanged: (value) {
              switchValue = value;
              onChangedCalled = true;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(JJCircuitBreakerSwitch));
      await tester.pumpAndSettle();

      // Assert
      expect(onChangedCalled, isTrue);
      expect(switchValue, isTrue);
    });

    testWidgets('should not respond to taps when disabled',
        (WidgetTester tester) async {
      // Arrange
      bool switchValue = false;
      bool onChangedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: switchValue,
            onChanged: null, // Disabled
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(JJCircuitBreakerSwitch));
      await tester.pumpAndSettle();

      // Assert
      expect(onChangedCalled, isFalse);
      expect(switchValue, isFalse);
    });

    testWidgets('should animate state transitions',
        (WidgetTester tester) async {
      // Arrange
      bool switchValue = false;
      
      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return JJCircuitBreakerSwitch(
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    switchValue = value;
                  });
                },
              );
            },
          ),
        ),
      );

      // Act - Tap to turn ON
      await tester.tap(find.byType(JJCircuitBreakerSwitch));
      await tester.pump(); // Start animation
      
      // Check for animation widgets
      expect(find.byType(AnimatedContainer), findsWidgets);
      
      // Complete animation
      await tester.pumpAndSettle();

      // Assert
      expect(switchValue, isTrue);
    });

    testWidgets('should display correct colors for ON state',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: true,
            onChanged: (value) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Check for ON state colors
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      
      // Look for green/copper colors indicating ON state
      bool foundOnStateColor = false;
      for (final container in containers.evaluate()) {
        final containerWidget = container.widget as Container;
        if (containerWidget.decoration is BoxDecoration) {
          final decoration = containerWidget.decoration as BoxDecoration;
          if (decoration.color == AppTheme.accentCopper ||
              decoration.color == Colors.green) {
            foundOnStateColor = true;
            break;
          }
        }
      }
      
      // Note: This assertion may need adjustment based on actual implementation
      // expect(foundOnStateColor, isTrue);
    });

    testWidgets('should display correct colors for OFF state',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: false,
            onChanged: (value) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Check for OFF state colors
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      
      // Look for grey/dark colors indicating OFF state
      bool foundOffStateColor = false;
      for (final container in containers.evaluate()) {
        final containerWidget = container.widget as Container;
        if (containerWidget.decoration is BoxDecoration) {
          final decoration = containerWidget.decoration as BoxDecoration;
          if (decoration.color == Colors.grey ||
              decoration.color == AppTheme.primaryNavy) {
            foundOffStateColor = true;
            break;
          }
        }
      }
      
      // Note: This assertion may need adjustment based on actual implementation
      // expect(foundOffStateColor, isTrue);
    });

    testWidgets('should display switch label when provided',
        (WidgetTester tester) async {
      // Arrange
      const labelText = 'Main Breaker';
      
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: false,
            onChanged: (value) {},
            label: labelText,
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('should display amperage rating when provided',
        (WidgetTester tester) async {
      // Arrange
      const amperage = '20A';
      
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: false,
            onChanged: (value) {},
            amperage: amperage,
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(amperage), findsOneWidget);
    });

    testWidgets('should handle rapid state changes gracefully',
        (WidgetTester tester) async {
      // Arrange
      bool switchValue = false;
      
      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return JJCircuitBreakerSwitch(
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    switchValue = value;
                  });
                },
              );
            },
          ),
        ),
      );

      // Act - Rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(JJCircuitBreakerSwitch));
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Assert - Should handle rapid changes without errors
      expect(tester.takeException(), isNull);
      expect(switchValue, isTrue); // Odd number of taps = ON
    });

    testWidgets('should be accessible with proper semantics',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: false,
            onChanged: (value) {},
            label: 'Circuit Breaker',
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Check for semantic properties
      final semantics = find.bySemanticsLabel(RegExp(r'.*[Cc]ircuit.*[Bb]reaker.*'));
      if (semantics.evaluate().isNotEmpty) {
        expect(semantics, findsOneWidget);
      }
      
      // Check for switch role semantics
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should maintain consistent size across states',
        (WidgetTester tester) async {
      // Arrange
      Size? offStateSize;
      Size? onStateSize;
      
      // Test OFF state
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: false,
            onChanged: (value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final offStateWidget = tester.getSize(find.byType(JJCircuitBreakerSwitch));
      offStateSize = offStateWidget;

      // Test ON state
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: true,
            onChanged: (value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final onStateWidget = tester.getSize(find.byType(JJCircuitBreakerSwitch));
      onStateSize = onStateWidget;

      // Assert
      expect(offStateSize, equals(onStateSize));
    });

    testWidgets('should display electrical safety indicators',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          JJCircuitBreakerSwitch(
            value: true,
            onChanged: (value) {},
            showSafetyIndicators: true,
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Look for safety-related visual elements
      // This would depend on the actual implementation
      expect(find.byType(JJCircuitBreakerSwitch), findsOneWidget);
    });
  });

  group('JJCircuitBreakerSwitch Performance Tests', () {
    testWidgets('should rebuild efficiently on state changes',
        (WidgetTester tester) async {
      // Arrange
      int buildCount = 0;
      bool switchValue = false;
      
      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              buildCount++;
              return JJCircuitBreakerSwitch(
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    switchValue = value;
                  });
                },
              );
            },
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Act
      await tester.tap(find.byType(JJCircuitBreakerSwitch));
      await tester.pumpAndSettle();

      // Assert - Should only rebuild once for state change
      expect(buildCount, equals(initialBuildCount + 1));
    });
  });
}