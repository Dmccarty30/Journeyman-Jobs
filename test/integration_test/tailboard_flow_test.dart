import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:journeyman_jobs/main.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tailboard Flow E2E Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUpAll(() {
      fakeFirestore = FakeFirebaseFirestore();
      FirebaseFirestore.instance = fakeFirestore;
    });

    testWidgets('Non-member to member flow via create crew', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate authenticated user with no crew (mock auth provider if needed)
      // Assume app starts at home or tailboard; tap to navigate to tailboard if needed
      // For simplicity, assume direct pump to Tailboard with no crew state

      // Expect no crew header with create/join buttons
      expect(find.textContaining('Welcome to the Tailboard'), findsOneWidget);
      expect(find.text('Create a Crew'), findsOneWidget);
      expect(find.text('Join a Crew'), findsOneWidget);

      // Tap create crew button
      await tester.tap(find.text('Create a Crew'));
      await tester.pumpAndSettle();

      // Now in create crew screen (assume navigation)
      // Fill form: name, description, classification, rate
      await tester.enterText(find.byType(TextField).first, 'Test Crew');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), 'Test Description');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), 'Lineman');
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, '30.0');
      await tester.pump();

      // Submit
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Back to tailboard, expect member state header
      expect(find.text('Test Crew'), findsOneWidget);
      expect(find.text('1 members'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget); // Tabs visible
    });

    testWidgets('Join crew flow from non-member state', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Expect no crew state
      expect(find.textContaining('Join a Crew'), findsOneWidget);

      // Tap join crew
      await tester.tap(find.text('Join a Crew'));
      await tester.pumpAndSettle();

      // In join screen, assume list of crews, select one
      // Mock a crew in fakeFirestore for join
      await fakeFirestore.collection('crews').add({
        'name': 'Joinable Crew',
        'memberCount': 1,
        'isActive': true,
      });

      // Simulate selecting and joining
      await tester.tap(find.text('Joinable Crew'));
      await tester.pump();
      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();

      // Back to tailboard, verify member state
      expect(find.text('Joinable Crew'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget); // FAB visible for member
    });
  });
}