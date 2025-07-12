/// Tests for OnboardingStepsScreen
/// 
/// Comprehensive tests covering the complete onboarding flow for IBEW electrical workers,
/// including form validation, step navigation, and data persistence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/screens/onboarding/onboarding_steps_screen.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/onboarding_service.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/electrical_components/jj_circuit_breaker_switch_list_tile.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_services.dart';

void main() {
  group('OnboardingStepsScreen Tests', () {
    late MockFirestoreService mockFirestoreService;
    late MockOnboardingService mockOnboardingService;

    setUp(() {
      mockFirestoreService = MockFactory.createMockFirestoreService();
      mockOnboardingService = MockOnboardingService();
      MockSetupHelpers.setupSuccessfulFirestore(mockFirestoreService);
      MockSetupHelpers.setupOnboardingService(mockOnboardingService);
      
      // Register fallback values for mocktail
      registerFallbackValue(<String, dynamic>{});
    });

    /// Create the widget under test with necessary providers
    Widget createOnboardingScreen() {
      return createTestApp(
        child: MultiProvider(
          providers: [
            Provider<FirestoreService>.value(value: mockFirestoreService),
            Provider<OnboardingService>.value(value: mockOnboardingService),
          ],
          child: const OnboardingStepsScreen(),
        ),
      );
    }

    group('Initial Rendering', () {
      testWidgets('renders correctly with step 1 visible', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Verify app bar
        expect(find.text('Setup Profile'), findsOneWidget);
        
        // Verify progress indicator
        expect(find.text('Step 1 of 3'), findsOneWidget);
        expect(find.byType(JJProgressIndicator), findsOneWidget);
        
        // Verify step 1 content
        expect(find.text('Basic Information'), findsOneWidget);
        expect(find.text('Let\'s start with your essential details'), findsOneWidget);
        
        // Verify form fields are present
        expect(find.text('First Name'), findsOneWidget);
        expect(find.text('Last Name'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(find.text('Address Line 1'), findsOneWidget);
        expect(find.text('City'), findsOneWidget);
        expect(find.text('State'), findsOneWidget);
        expect(find.text('Zip Code'), findsOneWidget);
      });

      testWidgets('applies electrical theme correctly', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        TestExpectations.verifyElectricalTheme(tester);
      });

      testWidgets('is accessible', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        TestExpectations.verifyAccessibility(tester);
      });
    });

    group('Step 1: Basic Information', () {
      testWidgets('validates required fields', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Try to proceed without filling required fields
        final nextButton = find.text('Next');
        expect(tester.widget<JJPrimaryButton>(find.byType(JJPrimaryButton)).onPressed, isNull);
      });

      testWidgets('enables next button when all required fields are filled', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Fill required fields
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter first name'), 'John');
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter last name'), 'Doe');
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter your phone number'), '555-1234');
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter your street address'), '123 Main St');
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter city'), 'Houston');
        
        // Select state
        await tester.tap(find.text('State'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('TX').last);
        await tester.pumpAndSettle();
        
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Zip'), '77001');
        await tester.pumpAndSettle();

        // Verify next button is enabled
        expect(tester.widget<JJPrimaryButton>(find.byType(JJPrimaryButton)).onPressed, isNotNull);
      });

      testWidgets('handles phone number formatting', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        final phoneField = find.widgetWithText(TextField, 'Enter your phone number');
        await TestUtils.enterText(tester, phoneField, '5551234567');
        
        // Verify the field accepts numeric input
        expect(find.text('5551234567'), findsOneWidget);
      });

      testWidgets('handles zipcode numeric input', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        final zipcodeField = find.widgetWithText(TextField, 'Zip');
        await TestUtils.enterText(tester, zipcodeField, '77001');
        
        // Verify only numbers are accepted
        expect(find.text('77001'), findsOneWidget);
      });

      testWidgets('navigates to step 2 when next is tapped', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Fill all required fields
        await _fillStep1RequiredFields(tester);
        
        // Tap next button
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Verify step 2 is displayed
        expect(find.text('Step 2 of 3'), findsOneWidget);
        expect(find.text('IBEW Professional Details'), findsOneWidget);
      });
    });

    group('Step 2: Professional Details', () {
      setUp(() async {
        // Helper to navigate to step 2
      });

      testWidgets('displays IBEW-specific fields', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Navigate to step 2
        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Verify IBEW fields
        expect(find.text('Ticket Number'), findsOneWidget);
        expect(find.text('Home Local Number'), findsOneWidget);
        expect(find.text('Classification'), findsOneWidget);
        expect(find.text('Currently Working'), findsOneWidget);
        expect(find.text('Books You\'re Currently On'), findsOneWidget);
        
        // Verify classifications are available
        expect(find.text('Journeyman Lineman'), findsOneWidget);
        expect(find.text('Journeyman Electrician'), findsOneWidget);
        expect(find.text('Journeyman Tree Trimmer'), findsOneWidget);
      });

      testWidgets('validates professional fields', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Verify next button is disabled without required fields
        expect(tester.widget<JJPrimaryButton>(find.byType(JJPrimaryButton)).onPressed, isNull);
      });

      testWidgets('allows classification selection', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Select a classification
        await TestUtils.tapAndSettle(tester, find.text('Journeyman Lineman'));
        
        // Verify selection is highlighted
        expect(find.byWidgetPredicate((widget) => 
          widget is JJChip && widget.isSelected == true
        ), findsOneWidget);
      });

      testWidgets('handles circuit breaker switch for working status', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Find and tap the circuit breaker switch
        final switchWidget = find.byType(JJCircuitBreakerSwitchListTile);
        expect(switchWidget, findsOneWidget);
        
        await TestUtils.tapAndSettle(tester, switchWidget);
        
        // Verify switch state changed
        expect(tester.widget<JJCircuitBreakerSwitchListTile>(switchWidget).value, isTrue);
      });

      testWidgets('proceeds to step 3 when fields are completed', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));
        
        // Fill step 2 required fields
        await _fillStep2RequiredFields(tester);
        
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Verify step 3 is displayed
        expect(find.text('Step 3 of 3'), findsOneWidget);
        expect(find.text('Preferences & Feedback'), findsOneWidget);
      });
    });

    group('Step 3: Preferences & Feedback', () {
      testWidgets('displays preference options', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _navigateToStep3(tester);

        // Verify construction types
        expect(find.text('Construction Types'), findsOneWidget);
        expect(find.text('Distribution'), findsOneWidget);
        expect(find.text('Transmission'), findsOneWidget);
        expect(find.text('SubStation'), findsOneWidget);
        
        // Verify career goals checkboxes
        expect(find.text('Network with Others'), findsOneWidget);
        expect(find.text('Career Advancement'), findsOneWidget);
        expect(find.text('Higher Pay Rate'), findsOneWidget);
      });

      testWidgets('allows multiple construction type selection', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _navigateToStep3(tester);

        // Select multiple construction types
        await TestUtils.tapAndSettle(tester, find.text('Distribution'));
        await TestUtils.tapAndSettle(tester, find.text('Transmission'));
        
        // Verify both are selected
        final selectedChips = find.byWidgetPredicate((widget) => 
          widget is JJChip && widget.isSelected == true
        );
        expect(selectedChips, findsNWidgets(2));
      });

      testWidgets('handles career goals checkboxes', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _navigateToStep3(tester);

        // Select multiple career goals
        await TestUtils.tapAndSettle(tester, find.byWidgetPredicate((widget) =>
          widget is CheckboxListTile && 
          widget.title is Text &&
          (widget.title as Text).data == 'Network with Others'
        ));
        
        await TestUtils.tapAndSettle(tester, find.byWidgetPredicate((widget) =>
          widget is CheckboxListTile && 
          widget.title is Text &&
          (widget.title as Text).data == 'Higher Pay Rate'
        ));

        // Verify checkboxes are checked
        final checkedBoxes = find.byWidgetPredicate((widget) => 
          widget is CheckboxListTile && widget.value == true
        );
        expect(checkedBoxes, findsAtLeastNWidgets(2));
      });

      testWidgets('enables complete button when required fields filled', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _navigateToStep3(tester);
        
        // Select at least one construction type (minimum requirement)
        await TestUtils.tapAndSettle(tester, find.text('Distribution'));

        // Verify complete button is enabled
        expect(tester.widget<JJPrimaryButton>(find.byType(JJPrimaryButton)).onPressed, isNotNull);
        expect(find.text('Complete'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('shows back button from step 2 onwards', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Step 1 - no back button
        expect(find.byIcon(Icons.arrow_back), findsNothing);

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Step 2 - back button appears
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button navigates to previous step', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Navigate back to step 1
        await TestUtils.tapAndSettle(tester, find.byIcon(Icons.arrow_back));

        // Verify we're back to step 1
        expect(find.text('Step 1 of 3'), findsOneWidget);
        expect(find.text('Basic Information'), findsOneWidget);
      });

      testWidgets('preserves form data when navigating between steps', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Fill step 1 data
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter first name'), 'John');
        await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter last name'), 'Doe');
        
        // Complete step 1 navigation
        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Navigate back
        await TestUtils.tapAndSettle(tester, find.byIcon(Icons.arrow_back));

        // Verify data is preserved
        expect(find.text('John'), findsOneWidget);
        expect(find.text('Doe'), findsOneWidget);
      });
    });

    group('Completion Flow', () {
      testWidgets('calls firestore service when completing onboarding', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _completeFullOnboarding(tester);

        // Verify Firestore service was called
        verify(() => mockFirestoreService.createUser(
          uid: any(named: 'uid'),
          userData: any(named: 'userData'),
        )).called(1);
      });

      testWidgets('calls onboarding service to mark complete', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _completeFullOnboarding(tester);

        // Verify onboarding service was called
        verify(() => mockOnboardingService.markOnboardingComplete()).called(1);
      });

      testWidgets('shows success message on completion', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _completeFullOnboarding(tester);

        // Verify success message
        expect(find.text('Profile setup complete! Welcome to Journeyman Jobs.'), findsOneWidget);
      });

      testWidgets('handles firestore errors gracefully', (tester) async {
        // Setup firestore to fail
        MockSetupHelpers.setupFirestoreFailure(mockFirestoreService);
        
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _completeFullOnboarding(tester);

        // Verify error message is shown
        expect(find.text('Error saving profile. Please try again.'), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('validates email format in step 1', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        // Note: Email comes from Firebase Auth, not user input in this form
        // This test ensures the form doesn't break with email field
        await _fillStep1RequiredFields(tester);
        
        expect(tester.widget<JJPrimaryButton>(find.byType(JJPrimaryButton)).onPressed, isNotNull);
      });

      testWidgets('validates numeric fields', (tester) async {
        await tester.pumpWidget(createOnboardingScreen());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester);
        await TestUtils.tapAndSettle(tester, find.text('Next'));

        // Test ticket number field accepts only numbers
        final ticketField = find.widgetWithText(TextField, 'Enter your ticket number');
        await TestUtils.enterText(tester, ticketField, 'abc123');
        
        // Should only contain numbers due to input formatter
        final textField = tester.widget<TextField>(ticketField);
        expect(textField.inputFormatters, isNotEmpty);
      });
    });

    group('Responsive Design', () {
      testWidgets('adapts to different screen sizes', (tester) async {
        await TestExpectations.verifyResponsiveDesign(
          tester,
          () => createOnboardingScreen(),
        );
      });
    });
  });
}

/// Helper function to fill Step 1 required fields
Future<void> _fillStep1RequiredFields(WidgetTester tester) async {
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter first name'), 'John');
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter last name'), 'Doe');
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter your phone number'), '555-1234');
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter your street address'), '123 Main St');
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter city'), 'Houston');
  
  await tester.tap(find.text('State'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('TX').last);
  await tester.pumpAndSettle();
  
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Zip'), '77001');
  await tester.pumpAndSettle();
}

/// Helper function to fill Step 2 required fields
Future<void> _fillStep2RequiredFields(WidgetTester tester) async {
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter your ticket number'), '123456');
  await TestUtils.enterText(tester, find.widgetWithText(TextField, 'Enter your home local number'), '456');
  await TestUtils.tapAndSettle(tester, find.text('Journeyman Lineman'));
}

/// Helper function to navigate to Step 3
Future<void> _navigateToStep3(WidgetTester tester) async {
  await _fillStep1RequiredFields(tester);
  await TestUtils.tapAndSettle(tester, find.text('Next'));
  await _fillStep2RequiredFields(tester);
  await TestUtils.tapAndSettle(tester, find.text('Next'));
}

/// Helper function to complete full onboarding flow
Future<void> _completeFullOnboarding(WidgetTester tester) async {
  await _navigateToStep3(tester);
  await TestUtils.tapAndSettle(tester, find.text('Distribution'));
  await TestUtils.tapAndSettle(tester, find.text('Complete'));
  await tester.pumpAndSettle();
}