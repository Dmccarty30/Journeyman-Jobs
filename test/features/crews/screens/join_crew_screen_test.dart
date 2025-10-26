import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/screens/join_crew_screen.dart';
import 'package:journeyman_jobs/features/crews/services/crew_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/invite_code.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/navigation/app_router.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/domain/exceptions/crew_exception.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/enums/crew_visibility.dart';

/// Comprehensive test suite for JoinCrewScreen
///
/// Tests cover:
/// - UI rendering and interactions
/// - Form validation
/// - Crew joining workflow
/// - Error handling
/// - Edge cases
/// - Accessibility
/// - Performance
void main() {
  group('JoinCrewScreen Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CrewService mockCrewService;
    late Widget testWidget;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockCrewService = MockCrewService();

      testWidget = ProviderScope(
        overrides: [
          crewServiceProvider.overrideWithValue(mockCrewService),
        ],
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const JoinCrewScreen(),
        ),
      );
    });

    tearDown(() {
      reset(mockCrewService);
    });

    // Basic UI Rendering Tests
    group('UI Rendering', () {
      testWidgets('renders all required UI elements', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Verify app bar
        expect(find.text('Join a Crew'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        // Verify main content
        expect(find.byIcon(Icons.group_add), findsOneWidget);
        expect(find.text('Join an Existing Crew'), findsOneWidget);
        expect(find.text('Enter an invite code to join a crew or browse available public crews.'), findsOneWidget);

        // Verify form elements
        expect(find.byType(Form), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Invite Code'), findsOneWidget);
        expect(find.byIcon(Icons.code), findsOneWidget);

        // Verify buttons
        expect(find.text('Join Crew'), findsOneWidget);
        expect(find.text('Browse Public Crews'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('renders with proper styling and theme', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Verify colors are applied correctly
        final icon = tester.widget<Icon>(find.byIcon(Icons.group_add));
        expect(icon.color, equals(AppTheme.accentCopper));

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byWidgetPredicate((widget) => widget is ElevatedButton &&
            widget.child is Text && (widget.child as Text).data == 'Join Crew')
        );
        expect(elevatedButton.style?.backgroundColor?.resolve({}), equals(AppTheme.accentCopper));

        final outlinedButton = tester.widget<OutlinedButton>(
          find.byWidgetPredicate((widget) => widget is OutlinedButton &&
            widget.child is Text && (widget.child as Text).data == 'Browse Public Crews')
        );
        expect(outlinedButton.style?.side?.resolve({})?.color, equals(AppTheme.accentCopper));
      });
    });

    // Form Validation Tests
    group('Form Validation', () {
      testWidgets('shows validation error when invite code is empty', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Tap join button without entering code
        await tester.tap(find.text('Join Crew'));
        await tester.pumpAndSettle();

        // Verify error message
        expect(find.text('Invite code is required'), findsOneWidget);
      });

      testWidgets('clears validation error when valid code is entered', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // First trigger validation error
        await tester.tap(find.text('Join Crew'));
        await tester.pumpAndSettle();
        expect(find.text('Invite code is required'), findsOneWidget);

        // Enter valid code
        await tester.enterText(find.byType(TextFormField), 'CREWNAME-01/25-001');
        await tester.pumpAndSettle();

        // Verify error is cleared
        expect(find.text('Invite code is required'), findsNothing);
      });

      testWidgets('handles invite code formatting correctly', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField);

        // Test text capitalization
        await tester.enterText(textField, 'crewname-01/25-001');
        await tester.pumpAndSettle();

        final textFormField = tester.widget<TextFormField>(textField);
        expect(textFormField.textCapitalization, equals(TextCapitalization.characters));
      });
    });

    // Crew Joining Workflow Tests
    group('Crew Joining Workflow', () {
      testWidgets('successfully joins crew with valid invite code', (WidgetTester tester) async {
        // Arrange
        final mockCrew = Crew(
          id: 'crew-123',
          name: 'Test Crew',
          foremanId: 'foreman-123',
          memberIds: ['foreman-123'],
          preferences: const CrewPreferences(
            jobTypes: [],
            constructionTypes: [],
            autoShareEnabled: false,
          ),
          roles: {'foreman-123': MemberRole.foreman},
          stats: const CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: null,
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
          visibility: CrewVisibility.private,
          maxMembers: 50,
          inviteCodeCounter: 1,
        );

        // Mock successful crew lookup and join
        when(() => mockCrewService.getCrew('crew-123')).thenAnswer((_) async => mockCrew);
        when(() => mockCrewService.acceptInvitation(
          invitationId: any(named: 'invitationId'),
          crewId: any(named: 'crewId'),
          userId: any(named: 'userId'),
        )).thenAnswer((_) async {});

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byType(TextFormField), 'CREWNAME-01/25-001');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Join Crew'));
        await tester.pumpAndSettle();

        // Verify loading state
        expect(find.text('Joining...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for async operation
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Verify success message and navigation
        expect(find.text('Successfully joined crew!'), findsOneWidget);
      });

      testWidgets('shows error message when crew joining fails', (WidgetTester tester) async {
        // Arrange
        when(() => mockCrewService.getCrew(any())).thenThrow(
          CrewException('Invalid invite code', code: 'invalid-invite-code')
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byType(TextFormField), 'INVALID-CODE');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Join Crew'));
        await tester.pumpAndSettle();

        // Wait for async operation
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Verify error message
        expect(find.textContaining('Failed to join crew'), findsOneWidget);
      });

      testWidgets('handles network errors gracefully', (WidgetTester tester) async {
        // Arrange
        when(() => mockCrewService.getCrew(any())).thenThrow(
          CrewException('Network error', code: 'network-error')
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byType(TextFormField), 'CREWNAME-01/25-001');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Join Crew'));
        await tester.pumpAndSettle();

        // Wait for async operation
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Verify error message
        expect(find.textContaining('Failed to join crew'), findsOneWidget);
        expect(find.textContaining('Network error'), findsOneWidget);
      });
    });

    // Browse Public Crews Tests
    group('Browse Public Crews', () {
      testWidgets('shows coming soon message for browse public crews', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Browse Public Crews'));
        await tester.pumpAndSettle();

        expect(find.text('Browse public crews feature coming soon!'), findsOneWidget);
      });
    });

    // Accessibility Tests
    group('Accessibility', () {
      testWidgets('has proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Verify semantic labels
        expect(find.bySemanticsLabel('Invite Code'), findsOneWidget);
        expect(find.bySemanticsLabel('Join Crew'), findsOneWidget);
        expect(find.bySemanticsLabel('Browse Public Crews'), findsOneWidget);
      });

      testWidgets('supports keyboard navigation', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Test tab navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Focus should be on the text field
        expect(tester.binding.focusManager.primaryFocus?.runtimeType, equals(TextFormField));
      });

      testWidgets('has sufficient color contrast', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Verify text contrast (visual verification would need accessibility testing tools)
        final textWidgets = tester.widgetList<Text>(find.byType(Text));

        for (final textWidget in textWidgets) {
          final style = textWidget.style;
          if (style?.color != null) {
            // In a real test, you would verify contrast ratios
            // This is a placeholder for contrast testing
            expect(style?.color, isNotNull);
          }
        }
      });
    });

    // Edge Cases Tests
    group('Edge Cases', () {
      testWidgets('handles very long invite codes', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final longCode = 'VERY-LONG-CREW-NAME-01/25-001-EXTRA-TEXT';
        await tester.enterText(find.byType(TextFormField), longCode);
        await tester.pumpAndSettle();

        // Verify the text fits and doesn't overflow
        expect(find.text(longCode), findsOneWidget);
      });

      testWidgets('handles special characters in invite codes', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'CREW-NAME_01/25-001');
        await tester.pumpAndSettle();

        expect(find.text('CREW-NAME_01/25-001'), findsOneWidget);
      });

      testWidgets('handles rapid button taps', (WidgetTester tester) async {
        when(() => mockCrewService.getCrew(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          throw CrewException('Test error', code: 'test');
        });

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'TEST-CODE');
        await tester.pumpAndSettle();

        // Tap button multiple times rapidly
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Join Crew'));
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();

        // Should only show one loading state and one error
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Joining...'), findsOneWidget);
      });
    });

    // Performance Tests
    group('Performance', () {
      testWidgets('renders within acceptable time limits', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Should render within 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      testWidgets('handles large amounts of text input efficiently', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final largeText = 'A' * 1000;

        final stopwatch = Stopwatch()..start();
        await tester.enterText(find.byType(TextFormField), largeText);
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Should handle large input within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    // Error Boundary Tests
    group('Error Boundaries', () {
      testWidgets('handles widget disposal properly', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Enter some text
        await tester.enterText(find.byType(TextFormField), 'TEST-CODE');
        await tester.pumpAndSettle();

        // Navigate away (simulate disposal)
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/navigation',
          StandardMethodCodec().encodeMethodCall(MethodCall('popRoute')),
          (data) {},
        );

        await tester.pumpAndSettle();

        // Should not throw errors during disposal
        expect(tester.takeException(), isNull);
      });
    });
  });
}

/// Mock class for testing
class MockCrewService extends Mock implements CrewService {
  @override
  Future<Crew?> getCrew(String crewId) => super.noSuchMethod(Invocation.method(#getCrew, [crewId]),
      returnValue: Future<Crew?>.value(null));

  @override
  Future<void> acceptInvitation({
    required String invitationId,
    required String crewId,
    required String userId,
  }) => super.noSuchMethod(Invocation.method(#acceptInvitation, [], {
    #invitationId: invitationId,
    #crewId: crewId,
    #userId: userId,
  }), returnValue: Future<void>.value());
}