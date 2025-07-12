// This is a basic test file for the Journeyman Jobs app
// It includes example tests for the electrical components

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/electrical_components/jj_circuit_breaker_switch.dart';
import 'package:journeyman_jobs/electrical_components/three_phase_sine_wave_loader.dart';
import 'package:journeyman_jobs/electrical_components/power_line_loader.dart';

void main() {
  group('Electrical Components Tests', () {
    testWidgets('JJCircuitBreakerSwitch renders correctly', (WidgetTester tester) async {
      bool switchValue = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJCircuitBreakerSwitch(
              value: switchValue,
              onChanged: (value) {
                switchValue = value;
              },
            ),
          ),
        ),
      );

      // Verify that the switch renders
      expect(find.byType(JJCircuitBreakerSwitch), findsOneWidget);
      
      // Verify initial state
      final switchWidget = tester.widget<JJCircuitBreakerSwitch>(
        find.byType(JJCircuitBreakerSwitch),
      );
      expect(switchWidget.value, false);
    });

    testWidgets('JJCircuitBreakerSwitch can be toggled', (WidgetTester tester) async {
      bool switchValue = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
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
        ),
      );

      // Tap the switch
      await tester.tap(find.byType(JJCircuitBreakerSwitch));
      await tester.pumpAndSettle();

      // Verify the switch state changed
      final switchWidget = tester.widget<JJCircuitBreakerSwitch>(
        find.byType(JJCircuitBreakerSwitch),
      );
      expect(switchWidget.value, true);
    });

    testWidgets('ThreePhaseSineWaveLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreePhaseSineWaveLoader(
              width: 200,
              height: 60,
            ),
          ),
        ),
      );

      // Verify that the loader renders
      expect(find.byType(ThreePhaseSineWaveLoader), findsOneWidget);
      
      // Verify the animation controller is created
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('PowerLineLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PowerLineLoader(
              width: 300,
              height: 80,
            ),
          ),
        ),
      );

      // Verify that the loader renders
      expect(find.byType(PowerLineLoader), findsOneWidget);
      
      // Verify the custom paint widget is present
      expect(find.byType(CustomPaint), findsOneWidget);
      
      // Let the animation run for a bit
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('JJCircuitBreakerSwitch different sizes work', (WidgetTester tester) async {
      for (final size in JJCircuitBreakerSize.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJCircuitBreakerSwitch(
                value: false,
                size: size,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        // Verify that the switch renders with the specified size
        final switchWidget = tester.widget<JJCircuitBreakerSwitch>(
          find.byType(JJCircuitBreakerSwitch),
        );
        expect(switchWidget.size, size);
        
        // Clear the widget tree for the next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('Electrical components handle null callbacks gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                JJCircuitBreakerSwitch(
                  value: false,
                  onChanged: null, // Disabled switch
                ),
                ThreePhaseSineWaveLoader(),
                PowerLineLoader(),
              ],
            ),
          ),
        ),
      );

      // Verify all components render without errors
      expect(find.byType(JJCircuitBreakerSwitch), findsOneWidget);
      expect(find.byType(ThreePhaseSineWaveLoader), findsOneWidget);
      expect(find.byType(PowerLineLoader), findsOneWidget);

      // Try tapping the disabled switch - should not cause errors
      await tester.tap(find.byType(JJCircuitBreakerSwitch));
      await tester.pumpAndSettle();

      // Verify no exceptions were thrown
      expect(tester.takeException(), isNull);
    });
  });

  group('User Model Tests', () {
    test('UserModel toJson and fromJson work correctly', () {
      final user = UserModel(
        uid: 'test_uid',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '555-1234',
        email: 'john.doe@example.com',
        address1: '123 Main St',
        city: 'City',
        state: 'State',
        zipcode: '12345',
        homeLocal: '123',
        ticketNumber: '456789',
        classification: 'Journeyman Lineman',
        isWorking: true,
        constructionTypes: ['Distribution', 'Transmission'],
        networkWithOthers: true,
        careerAdvancements: false,
        betterBenefits: true,
        higherPayRate: false,
        learnNewSkill: true,
        travelToNewLocation: false,
        findLongTermWork: true,
        onboardingStatus: 'completed',
        createdTime: DateTime(2023, 1, 1),
      );

      // Test serialization
      final json = user.toJson();
      expect(json['uid'], 'test_uid');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['constructionTypes'], ['Distribution', 'Transmission']);

      // Test deserialization
      final reconstructedUser = UserModel.fromJson(json);
      expect(reconstructedUser.uid, user.uid);
      expect(reconstructedUser.firstName, user.firstName);
      expect(reconstructedUser.lastName, user.lastName);
      expect(reconstructedUser.constructionTypes, user.constructionTypes);
      expect(reconstructedUser.onboardingStatus, user.onboardingStatus);
    });

    test('UserModel fullName getter works correctly', () {
      final user = UserModel(
        uid: 'test',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '',
        email: '',
        address1: '',
        city: '',
        state: '',
        zipcode: '',
        homeLocal: '',
        ticketNumber: '',
        classification: '',
        isWorking: false,
        constructionTypes: [],
        networkWithOthers: false,
        careerAdvancements: false,
        betterBenefits: false,
        higherPayRate: false,
        learnNewSkill: false,
        travelToNewLocation: false,
        findLongTermWork: false,
        onboardingStatus: 'pending',
        createdTime: DateTime.now(),
      );

      expect(user.fullName, 'John Doe');
    });

    test('UserModel copyWith works correctly', () {
      final originalUser = UserModel(
        uid: 'test',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '555-1234',
        email: 'john@example.com',
        address1: '123 Main St',
        city: 'City',
        state: 'State',
        zipcode: '12345',
        homeLocal: '123',
        ticketNumber: '456',
        classification: 'Journeyman Lineman',
        isWorking: false,
        constructionTypes: ['Distribution'],
        networkWithOthers: false,
        careerAdvancements: false,
        betterBenefits: false,
        higherPayRate: false,
        learnNewSkill: false,
        travelToNewLocation: false,
        findLongTermWork: false,
        onboardingStatus: 'pending',
        createdTime: DateTime.now(),
      );

      final updatedUser = originalUser.copyWith(
        firstName: 'Jane',
        isWorking: true,
        constructionTypes: ['Transmission', 'SubStation'],
      );

      expect(updatedUser.firstName, 'Jane');
      expect(updatedUser.lastName, 'Doe'); // Should remain unchanged
      expect(updatedUser.isWorking, true);
      expect(updatedUser.constructionTypes, ['Transmission', 'SubStation']);
      expect(updatedUser.phoneNumber, '555-1234'); // Should remain unchanged
    });
  });
}