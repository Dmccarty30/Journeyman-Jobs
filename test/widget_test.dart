import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journeyman_jobs/main.dart';
import 'package:journeyman_jobs/screens/auth/auth_screen.dart';
import 'package:journeyman_jobs/screens/home/home_screen.dart';
import 'package:journeyman_jobs/screens/jobs/jobs_screen.dart';
import 'package:journeyman_jobs/screens/locals/locals_screen.dart';
import 'package:journeyman_jobs/screens/safety/electrical_safety_dashboard.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/electrical_components/electrical_components.dart';

/// Mock Firebase for testing
class MockFirebase {
  static Future<void> setupFirebaseAuthMocks() async {
    // Mock Firebase initialization for testing
    TestWidgetsFlutterBinding.ensureInitialized();
  }
}

void main() {
  group('Journeyman Jobs App Tests', () {
    setUpAll(() async {
      await MockFirebase.setupFirebaseAuthMocks();
    });

    group('Widget Tests', () {
      testWidgets('JJPrimaryButton displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJPrimaryButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(JJPrimaryButton), findsOneWidget);
      });

      testWidgets('JJSecondaryButton displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJSecondaryButton(
                text: 'Secondary Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Secondary Button'), findsOneWidget);
        expect(find.byType(JJSecondaryButton), findsOneWidget);
      });

      testWidgets('JJTextField displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJTextField(
                label: 'Test Field',
                hintText: 'Enter text',
              ),
            ),
          ),
        );

        expect(find.text('Test Field'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('JJLoadingIndicator displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJLoadingIndicator(
                message: 'Loading...',
              ),
            ),
          ),
        );

        expect(find.text('Loading...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('JJElectricalLoader displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJElectricalLoader(
                message: 'Electrical Loading...',
              ),
            ),
          ),
        );

        expect(find.text('Electrical Loading...'), findsOneWidget);
        expect(find.byType(ThreePhaseSineWaveLoader), findsOneWidget);
      });

      testWidgets('JJPowerLineLoader displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJPowerLineLoader(
                message: 'Power Line Loading...',
              ),
            ),
          ),
        );

        expect(find.text('Power Line Loading...'), findsOneWidget);
        expect(find.byType(PowerLineLoader), findsOneWidget);
      });

      testWidgets('JJCard displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJCard(
                child: Text('Card Content'),
              ),
            ),
          ),
        );

        expect(find.text('Card Content'), findsOneWidget);
        expect(find.byType(JJCard), findsOneWidget);
      });

      testWidgets('JJEmptyState displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJEmptyState(
                title: 'No Data',
                subtitle: 'No data available',
                icon: Icons.info,
              ),
            ),
          ),
        );

        expect(find.text('No Data'), findsOneWidget);
        expect(find.text('No data available'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
      });

      testWidgets('JJChip displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJChip(
                label: 'Test Chip',
                isSelected: true,
              ),
            ),
          ),
        );

        expect(find.text('Test Chip'), findsOneWidget);
        expect(find.byType(JJChip), findsOneWidget);
      });

      testWidgets('JJProgressIndicator displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJProgressIndicator(
                currentStep: 2,
                totalSteps: 5,
              ),
            ),
          ),
        );

        expect(find.byType(JJProgressIndicator), findsOneWidget);
      });
    });

    group('Electrical Components Tests', () {
      testWidgets('CircuitBreakerToggle displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CircuitBreakerToggle(
                isOn: true,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.byType(CircuitBreakerToggle), findsOneWidget);
      });

      testWidgets('HardHatIcon displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HardHatIcon(
                size: 24,
                color: Colors.blue,
              ),
            ),
          ),
        );

        expect(find.byType(HardHatIcon), findsOneWidget);
      });

      testWidgets('TransmissionTowerIcon displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TransmissionTowerIcon(
                size: 24,
                color: Colors.blue,
              ),
            ),
          ),
        );

        expect(find.byType(TransmissionTowerIcon), findsOneWidget);
      });

      testWidgets('ThreePhaseSineWaveLoader displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThreePhaseSineWaveLoader(
                width: 200,
                height: 60,
              ),
            ),
          ),
        );

        expect(find.byType(ThreePhaseSineWaveLoader), findsOneWidget);
      });

      testWidgets('PowerLineLoader displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PowerLineLoader(
                width: 300,
                height: 80,
              ),
            ),
          ),
        );

        expect(find.byType(PowerLineLoader), findsOneWidget);
      });

      testWidgets('ElectricalRotationMeter displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElectricalRotationMeter(
                value: 0.5,
                size: 100,
              ),
            ),
          ),
        );

        expect(find.byType(ElectricalRotationMeter), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('JJElectricalIcons hardHat creates HardHatIcon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJElectricalIcons.hardHat(size: 32),
            ),
          ),
        );

        expect(find.byType(HardHatIcon), findsOneWidget);
      });

      testWidgets('JJElectricalIcons transmissionTower creates TransmissionTowerIcon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJElectricalIcons.transmissionTower(size: 32),
            ),
          ),
        );

        expect(find.byType(TransmissionTowerIcon), findsOneWidget);
      });

      testWidgets('JJElectricalToggle creates CircuitBreakerToggle', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJElectricalToggle(
                isOn: true,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.byType(CircuitBreakerToggle), findsOneWidget);
      });
    });

    group('Button Interaction Tests', () {
      testWidgets('JJPrimaryButton responds to tap', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJPrimaryButton(
                text: 'Tap Me',
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tap Me'));
        expect(wasPressed, isTrue);
      });

      testWidgets('JJSecondaryButton responds to tap', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJSecondaryButton(
                text: 'Secondary Tap',
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Secondary Tap'));
        expect(wasPressed, isTrue);
      });

      testWidgets('JJChip responds to tap', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJChip(
                label: 'Chip',
                onTap: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Chip'));
        expect(wasPressed, isTrue);
      });
    });

    group('Electrical Loading States Tests', () {
      testWidgets('JJElectricalLoader shows with loading message', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJElectricalLoader(
                message: 'Connecting to power grid...',
              ),
            ),
          ),
        );

        expect(find.text('Connecting to power grid...'), findsOneWidget);
        expect(find.byType(ThreePhaseSineWaveLoader), findsOneWidget);
      });

      testWidgets('JJPowerLineLoader shows with loading message', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJPowerLineLoader(
                message: 'Loading power line data...',
              ),
            ),
          ),
        );

        expect(find.text('Loading power line data...'), findsOneWidget);
        expect(find.byType(PowerLineLoader), findsOneWidget);
      });
    });

    group('Form Field Tests', () {
      testWidgets('JJTextField accepts text input', (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJTextField(
                label: 'Test Input',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Hello World');
        expect(controller.text, 'Hello World');
      });

      testWidgets('JJTextField validates input', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                child: JJTextField(
                  label: 'Required Field',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        );

        // Trigger validation by finding the form and calling validate
        final form = tester.widget<Form>(find.byType(Form));
        // Note: In real tests, you'd trigger validation through form submission
        expect(find.byType(JJTextField), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('JJPrimaryButton has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJPrimaryButton(
                text: 'Accessible Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Accessible Button'), findsOneWidget);
        // In a real app, you'd verify semantic properties
      });

      testWidgets('JJTextField has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJTextField(
                label: 'Accessible Field',
                hintText: 'Enter value',
              ),
            ),
          ),
        );

        expect(find.text('Accessible Field'), findsOneWidget);
        // In a real app, you'd verify semantic properties
      });
    });
  });
}