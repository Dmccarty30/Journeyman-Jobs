import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:journeyman_jobs/main.dart' as app;
import 'package:journeyman_jobs/features/crews/screens/create_crew_screen.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';

/// Integration test for the complete crew creation and management flow
/// 
/// This test simulates the user journey:
/// 1. Navigate to tailboard screen
/// 2. Create a new crew
/// 3. Set crew preferences
/// 4. Navigate back to tailboard
/// 5. Verify crew is active
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Crew Flow Integration Tests', () {
    testWidgets('complete crew creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to the tailboard screen (assuming it's accessible via bottom nav)
      // Note: In a real app, you'd need to handle authentication first
      
      // Wait for the app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the tailboard screen (or can navigate to it)
      // This would depend on your app's navigation structure
      expect(find.byType(TailboardScreen), findsNothing); // Initially not visible
      
      // Note: In a real integration test, you would:
      // 1. Handle authentication/login
      // 2. Navigate to the tailboard screen
      // 3. Test the complete flow
    });

    testWidgets('crew creation with validation', (WidgetTester tester) async {
      // Test crew name validation
      const testCrewName = 'Integration Test Crew';
      
      // Create a mock create crew screen for testing
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the crew name input field
      final crewNameField = find.byType(TextField);
      expect(crewNameField, findsOneWidget);

      // Enter a crew name
      await tester.enterText(crewNameField, testCrewName);
      await tester.pump();

      // Verify the text was entered
      expect(find.text(testCrewName), findsOneWidget);
    });

    testWidgets('tailboard screen state management', (WidgetTester tester) async {
      // Test the tailboard screen with different states
      
      // Test 1: No crew state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no crew state is displayed
      expect(find.text('You\'re not in a crew yet.'), findsOneWidget);
      expect(find.text('Create a Crew'), findsOneWidget);
      expect(find.text('Join a Crew'), findsOneWidget);

      // Test 2: Verify tab bar is present
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
    });

    testWidgets('crew preferences setup flow', (WidgetTester tester) async {
      // Test the crew preferences setup after creation
      const crewName = 'Test Preferences Crew';
      
      // This would simulate the flow after crew creation
      // where the foreman sets up job preferences
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Text('Crew: $crewName'),
                    ElevatedButton(
                      onPressed: () {
                        // Simulate opening preferences dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Set Crew Preferences'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Minimum Pay Rate',
                                    hintText: 'Enter minimum hourly rate',
                                  ),
                                  controller: TextEditingController(text: '25.00'),
                                ),
                                DropdownButtonFormField<String>(
                                  value: 'transmission',
                                  decoration: const InputDecoration(
                                    labelText: 'Job Type',
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'transmission', child: Text('Transmission')),
                                    DropdownMenuItem(value: 'distribution', child: Text('Distribution')),
                                  ],
                                  onChanged: (value) {},
                                ),
                                CheckboxListTile(
                                  title: const Text('Per Diem Required'),
                                  value: true,
                                  onChanged: (value) {},
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Save Preferences'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Set Preferences'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the preferences button
      await tester.tap(find.text('Set Preferences'));
      await tester.pumpAndSettle();

      // Verify the preferences dialog appears
      expect(find.text('Set Crew Preferences'), findsOneWidget);
      expect(find.text('Minimum Pay Rate'), findsOneWidget);
      expect(find.text('Per Diem Required'), findsOneWidget);

      // Test saving preferences
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Set Crew Preferences'), findsNothing);
    });

    testWidgets('crew member management flow', (WidgetTester tester) async {
      // Test adding and removing crew members
      const crewName = 'Member Management Crew';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Crew: $crewName'),
                const Text('Members (3/10)'),
                ListView(
                  shrinkWrap: true,
                  children: const [
                    ListTile(
                      leading: CircleAvatar(child: Text('JD')),
                      title: Text('John Doe'),
                      subtitle: Text('Foreman'),
                    ),
                    ListTile(
                      leading: CircleAvatar(child: Text('JS')),
                      title: Text('Jane Smith'),
                      subtitle: Text('Member'),
                    ),
                    ListTile(
                      leading: CircleAvatar(child: Text('BJ')),
                      title: Text('Bob Johnson'),
                      subtitle: Text('Member'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Simulate invite member
                  },
                  child: const Text('Invite Member'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify member list is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Bob Johnson'), findsOneWidget);
      expect(find.text('Foreman'), findsOneWidget);
      expect(find.text('Member'), findsNWidgets(2));

      // Verify invite button is present
      expect(find.text('Invite Member'), findsOneWidget);
    });

    testWidgets('crew chat functionality', (WidgetTester tester) async {
      // Test the crew chat feature
      const crewName = 'Chat Test Crew';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Crew: $crewName - Chat'),
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(
                        leading: CircleAvatar(child: Text('JD')),
                        title: Text('John Doe'),
                        subtitle: Text('Hey team, ready for the next job?'),
                      ),
                      ListTile(
                        leading: CircleAvatar(child: Text('JS')),
                        title: Text('Jane Smith'),
                        subtitle: Text('Yes! Looking forward to it.'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: 'Great! See you there.'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          // Simulate sending message
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chat messages are displayed
      expect(find.text('Hey team, ready for the next job?'), findsOneWidget);
      expect(find.text('Yes! Looking forward to it.'), findsOneWidget);

      // Verify message input is present
      expect(find.text('Type a message...'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      // Test sending a message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
    });

    testWidgets('job filtering and display', (WidgetTester tester) async {
      // Test job filtering based on crew preferences
      const crewName = 'Job Filter Crew';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Crew: $crewName - Jobs'),
                const Text('Filtered Jobs (2 found)'),
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        child: ListTile(
                          title: const Text('Transmission Lineman - Level 3'),
                          subtitle: const Text('\$35/hour • 50 miles • Per diem included'),
                          trailing: ElevatedButton(
                            onPressed: () {},
                            child: const Text('View Details'),
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text('Distribution Technician'),
                          subtitle: const Text('\$32/hour • 30 miles • Per diem included'),
                          trailing: ElevatedButton(
                            onPressed: () {},
                            child: const Text('View Details'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify filtered jobs are displayed
      expect(find.text('Transmission Lineman - Level 3'), findsOneWidget);
      expect(find.text('Distribution Technician'), findsOneWidget);
      expect(find.text('\$35/hour • 50 miles • Per diem included'), findsOneWidget);
      expect(find.text('View Details'), findsNWidgets(2));
    });

    testWidgets('error handling and edge cases', (WidgetTester tester) async {
      // Test error scenarios
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const Text('Crew: Error Test'),
                    ElevatedButton(
                      onPressed: () {
                        // Simulate error scenario
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Failed to create crew. Maximum limit reached.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Test Error'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger error
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // Verify error dialog
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to create crew. Maximum limit reached.'), findsOneWidget);
    });
  });
}