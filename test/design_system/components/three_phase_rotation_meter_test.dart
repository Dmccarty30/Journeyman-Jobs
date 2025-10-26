import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:journeyman_jobs/design_system/components/three_phase_rotation_meter.dart';

void main() {
  group('ThreePhaseRotationMeter Widget Tests', () {
    testWidgets('renders with default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      const customSize = 120.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(size: customSize),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('renders with clockwise rotation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(clockwise: true),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);

      // Let animation run a bit
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('renders with counter-clockwise rotation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(clockwise: false),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);

      // Let animation run a bit
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('renders with custom duration', (WidgetTester tester) async {
      const customDuration = Duration(seconds: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(duration: customDuration),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with autoStart disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(autoStart: false),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with custom colors', (WidgetTester tester) async {
      const customColors = RotationMeterColors(
        outerRingLight: Color(0xFF000000),
        outerRingDark: Color(0xFFFFFFFF),
        innerDialLight: Color(0xFF000000),
        innerDialDark: Color(0xFFFFFFFF),
        redDotLight: Color(0xFFFF0000),
        redDotDark: Color(0xFF800000),
        borderColor: Color(0xFF000000),
        markingColor: Color(0xFF000000),
        phaseIndicatorColor: Color(0xFF000000),
        textColor: Color(0xFF000000),
        mountingHoleColor: Color(0xFF000000),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(colors: customColors),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with IBEW theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(
              colors: RotationMeterColors.ibewTheme(),
            ),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with copper theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(
              colors: RotationMeterColors.copperTheme(),
            ),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with mounting holes visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(showMountingHoles: true),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with mounting holes hidden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(showMountingHoles: false),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with speed indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(showSpeedIndicator: true),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('renders with semantic label', (WidgetTester tester) async {
      const semanticLabel = 'Custom loading indicator';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(semanticLabel: semanticLabel),
          ),
        ),
      );

      expect(find.byType(Semantics), findsOneWidget);
      final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
      expect(semantics.label, equals(semanticLabel));
    });

    testWidgets('animation progresses correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(),
          ),
        ),
      );

      // Initial state
      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);

      // Let animation run
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be animating
      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('handles direction change correctly', (WidgetTester tester) async {
      bool clockwise = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ThreePhaseRotationMeter(key: UniqueKey(), clockwise: clockwise),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          clockwise = !clockwise;
                        });
                      },
                      child: Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);

      // Toggle direction
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
    });

    testWidgets('handles size change correctly', (WidgetTester tester) async {
      double size = 80.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ThreePhaseRotationMeter(key: UniqueKey(), size: size),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          size = size == 80.0 ? 120.0 : 80.0;
                        });
                      },
                      child: Text('Change Size'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      var initialSizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(initialSizedBox.width, equals(80.0));

      // Change size
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      var updatedSizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(updatedSizedBox.width, equals(120.0));
    });

    testWidgets('disposes properly when removed', (WidgetTester tester) async {
      bool showMeter = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    if (showMeter)
                      ThreePhaseRotationMeter(key: UniqueKey()),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showMeter = !showMeter;
                        });
                      },
                      child: Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);

      // Remove meter
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(ThreePhaseRotationMeter), findsNothing);
    });

    testWidgets('accessibility semantics are applied', (WidgetTester tester) async {
      const semanticLabel = 'Loading jobs';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreePhaseRotationMeter(semanticLabel: semanticLabel),
          ),
        ),
      );

      expect(find.bySemanticsLabel(semanticLabel), findsOneWidget);
    });

    group('RotationMeterColors Tests', () {
      test('IBEW theme creates correct colors', () {
        final colors = RotationMeterColors.ibewTheme();

        expect(colors.outerRingLight, equals(const Color(0xFFB0BEC5)));
        expect(colors.outerRingDark, equals(const Color(0xFF455A64)));
        expect(colors.innerDialLight, equals(const Color(0xFFF5F5F5)));
        expect(colors.innerDialDark, equals(const Color(0xFFE0E0E0)));
        expect(colors.redDotLight, equals(const Color(0xFFEF5350)));
        expect(colors.redDotDark, equals(const Color(0xFFC62828)));
        expect(colors.borderColor, equals(const Color(0xFF37474F)));
        expect(colors.markingColor, equals(const Color(0xFF263238)));
        expect(colors.phaseIndicatorColor, equals(const Color(0xFF1A202C)));
        expect(colors.textColor, equals(const Color(0xFF1A202C)));
        expect(colors.mountingHoleColor, equals(const Color(0xFF000000)));
      });

      test('Copper theme creates correct colors', () {
        final colors = RotationMeterColors.copperTheme();

        expect(colors.outerRingLight, equals(const Color(0xFFB87333)));
        expect(colors.outerRingDark, equals(const Color(0xFF8B5A2B)));
        expect(colors.innerDialLight, equals(const Color(0xFFF5F5F5)));
        expect(colors.innerDialDark, equals(const Color(0xFFE0E0E0)));
        expect(colors.redDotLight, equals(const Color(0xFFEF5350)));
        expect(colors.redDotDark, equals(const Color(0xFFC62828)));
        expect(colors.borderColor, equals(const Color(0xFF8B5A2B)));
        expect(colors.markingColor, equals(const Color(0xFF263238)));
        expect(colors.phaseIndicatorColor, equals(const Color(0xFFB45309)));
        expect(colors.textColor, equals(const Color(0xFFB45309)));
        expect(colors.mountingHoleColor, equals(const Color(0xFF000000)));
      });
    });

    group('Performance Tests', () {
      testWidgets('handles rapid state changes without errors', (WidgetTester tester) async {
        int counter = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return ThreePhaseRotationMeter(
                    key: ValueKey(counter),
                    size: 80.0 + (counter % 3) * 20.0,
                    clockwise: counter % 2 == 0,
                  );
                },
              ),
            ),
          ),
        );

        // Rapid state changes
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    counter++;
                    return ThreePhaseRotationMeter(
                      key: ValueKey(counter),
                      size: 80.0 + (counter % 3) * 20.0,
                      clockwise: counter % 2 == 0,
                    );
                  },
                ),
              ),
            ),
          );
        }

        expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
      });

      testWidgets('handles multiple instances efficiently', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(5, (index) =>
                  ThreePhaseRotationMeter(
                    key: ValueKey(index),
                    size: 40.0 + index * 10.0,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(ThreePhaseRotationMeter), findsNWidgets(5));

        // Let animations run
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ThreePhaseRotationMeter), findsNWidgets(5));
      });
    });

    group('Error Handling Tests', () {
      testWidgets('handles zero size gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThreePhaseRotationMeter(size: 0.0),
            ),
          ),
        );

        expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
      });

      testWidgets('handles very large size gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThreePhaseRotationMeter(size: 1000.0),
            ),
          ),
        );

        expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
      });

      testWidgets('handles very short duration gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThreePhaseRotationMeter(
                duration: const Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        expect(find.byType(ThreePhaseRotationMeter), findsOneWidget);
      });
    });
  });
}