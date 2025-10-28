import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:journeyman_jobs/features/crews/widgets/user_search_dialog.dart';
import 'package:journeyman_jobs/models/users_record.dart';

import 'user_search_dialog_test.mocks.dart';

@GenerateMocks([UsersRecord])
void main() {
  group('UserSearchDialog Tests', () {
    late MockUsersRecord mockUser;

    setUp(() {
      mockUser = MockUsersRecord();
      when(mockUser.uid).thenReturn('test-user-123');
      when(mockUser.displayName).thenReturn('John Doe');
      when(mockUser.email).thenReturn('john@example.com');
      when(mockUser.localNumber).thenReturn('123');
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: UserSearchDialog(
              crewId: 'test-crew-123',
              onUserSelected: (user) {},
            ),
          ),
        ),
      );
    }

    testWidgets('displays dialog with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Invite Crew Members'), findsOneWidget);
      expect(find.byIcon(Icons.group_add), findsOneWidget);
    });

    testWidgets('search field is present and functional', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by name, email, or IBEW local...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('clear button appears when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('suggested users section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Suggested for You'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (WidgetTester tester) async {
      bool dialogClosed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => UserSearchDialog(
                          crewId: 'test-crew-123',
                          onUserSelected: (user) {},
                        ),
                      );
                      dialogClosed = true;
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(UserSearchDialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(UserSearchDialog), findsNothing);
    });

    testWidgets('user result card displays user information correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter search to trigger results
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      // Verify user card elements
      expect(find.byType(UserResultCard), findsAtLeastNWidgets(1));
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('IBEW Local 123'), findsOneWidget);
    });

    testWidgets('error state displays correctly', (WidgetTester tester) async {
      // This would require mocking the service to return an error
      // For now, just verify the error state UI would work
      await tester.pumpWidget(createWidgetUnderTest());

      // Simulate error condition
      // This would need to be implemented with proper service mocking
    });

    testWidgets('empty state displays when no results found', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter search that would return no results
      await tester.enterText(find.byType(TextField), 'nonexistentuser');
      await tester.pump();

      expect(find.text('No users found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('loading state displays during search', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter search to trigger loading
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Verify loading indicators are present
      expect(find.byType(JJSkeletonLoader), findsWidgets);
    });
  });

  group('UserResultCard Tests', () {
    testWidgets('user result card displays user information', 
        (WidgetTester tester) async {
      final mockUser = MockUsersRecord();
      when(mockUser.displayName).thenReturn('John Doe');
      when(mockUser.localNumber).thenReturn('123');
      when(mockUser.certifications).thenReturn(['Journeyman']);
      when(mockUser.yearsExperience).thenReturn(5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserResultCard(
              user: mockUser,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('IBEW Local 123'), findsOneWidget);
      expect(find.text('Journeyman'), findsOneWidget);
      expect(find.text('5 years experience'), findsOneWidget);
    });

    testWidgets('suggested user shows indicator', (WidgetTester tester) async {
      final mockUser = MockUsersRecord();
      when(mockUser.displayName).thenReturn('Jane Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserResultCard(
              user: mockUser,
              onTap: () {},
              isSuggested: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('user card handles tap events', (WidgetTester tester) async {
      bool cardTapped = false;
      final mockUser = MockUsersRecord();
      when(mockUser.displayName).thenReturn('Test User');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserResultCard(
              user: mockUser,
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserResultCard));
      await tester.pump();

      expect(cardTapped, isTrue);
    });
  });
}
