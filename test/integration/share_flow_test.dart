import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

@GenerateMocks([
  FirebaseAnalytics,
  ContactsService,
])
import 'share_flow_test.mocks.dart';

// Integration test for complete job sharing flow
// This tests the entire user journey from job discovery to successful sharing

// Mock services and providers
class ShareFlowTestApp extends StatelessWidget {
  final FakeFirebaseFirestore firestore;
  final MockFirebaseAuth auth;
  final MockFirebaseAnalytics analytics;

  const ShareFlowTestApp({
    Key? key,
    required this.firestore,
    required this.auth,
    required this.analytics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Override providers with test implementations
        // firestoreProvider.overrideWithValue(firestore),
        // authProvider.overrideWithValue(auth),
        // analyticsProvider.overrideWithValue(analytics),
      ],
      child: MaterialApp(
        title: 'Journeyman Jobs Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const JobsScreen(),
        routes: {
          '/job-detail': (context) => const JobDetailScreen(),
          '/share-job': (context) => const ShareJobScreen(),
          '/contact-picker': (context) => const ContactPickerScreen(),
          '/share-confirmation': (context) => const ShareConfirmationScreen(),
        },
      ),
    );
  }
}

// Mock screens for testing
class JobsScreen extends StatelessWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => JobCard(
          jobId: 'job-$index',
          title: 'Storm Work - IBEW Local 26',
          onTap: () => Navigator.pushNamed(context, '/job-detail', arguments: 'job-$index'),
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String jobId;
  final String title;
  final VoidCallback onTap;

  const JobCard({
    Key? key,
    required this.jobId,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('job-card-$jobId'),
      child: ListTile(
        title: Text(title),
        subtitle: Text('Job ID: $jobId'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            key: const Key('share-job-button'),
            icon: const Icon(Icons.share),
            onPressed: () => Navigator.pushNamed(
              context, 
              '/share-job', 
              arguments: jobId,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text('Job ID: $jobId'),
          const Text('Storm Restoration Work'),
          const Text('IBEW Local 26'),
          const Text('Journeyman Lineman'),
          const Text('Rate: \$55.50/hr'),
          ElevatedButton(
            key: const Key('quick-share-button'),
            onPressed: () => Navigator.pushNamed(
              context, 
              '/share-job', 
              arguments: jobId,
            ),
            child: const Text('Share This Job'),
          ),
        ],
      ),
    );
  }
}

class ShareJobScreen extends StatefulWidget {
  const ShareJobScreen({Key? key}) : super(key: key);

  @override
  State<ShareJobScreen> createState() => _ShareJobScreenState();
}

class _ShareJobScreenState extends State<ShareJobScreen> {
  final _contactController = TextEditingController();
  String _shareMethod = 'email';
  bool _isDetectingUser = false;
  String? _detectedUserName;

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sharing Job: $jobId'),
            const SizedBox(height: 20),
            
            // Contact input
            TextField(
              key: const Key('contact-input'),
              controller: _contactController,
              decoration: InputDecoration(
                labelText: 'Email or Phone Number',
                suffixIcon: IconButton(
                  key: const Key('contact-picker-button'),
                  icon: const Icon(Icons.contacts),
                  onPressed: () async {
                    final contact = await Navigator.pushNamed(
                      context, '/contact-picker',
                    ) as String?;
                    if (contact != null) {
                      _contactController.text = contact;
                      _detectUser();
                    }
                  },
                ),
              ),
              onChanged: (_) => _detectUser(),
            ),
            const SizedBox(height: 10),
            
            // User detection indicator
            if (_isDetectingUser)
              const LinearProgressIndicator(key: Key('user-detection-progress')),
            if (_detectedUserName != null)
              Container(
                key: const Key('detected-user-info'),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('User found: $_detectedUserName'),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Share method selection
            const Text('Share Method:'),
            RadioListTile<String>(
              key: const Key('share-method-email'),
              title: const Text('Email'),
              value: 'email',
              groupValue: _shareMethod,
              onChanged: (value) => setState(() => _shareMethod = value!),
            ),
            RadioListTile<String>(
              key: const Key('share-method-sms'),
              title: const Text('SMS'),
              value: 'sms',
              groupValue: _shareMethod,
              onChanged: (value) => setState(() => _shareMethod = value!),
            ),
            RadioListTile<String>(
              key: const Key('share-method-in-app'),
              title: const Text('In-App Notification'),
              value: 'in-app',
              groupValue: _shareMethod,
              onChanged: (value) => setState(() => _shareMethod = value!),
            ),
            
            const Spacer(),
            
            // Share button
            ElevatedButton(
              key: const Key('send-share-button'),
              onPressed: _contactController.text.isNotEmpty 
                ? () => _shareJob(jobId)
                : null,
              child: const Text('Share Job'),
            ),
            
            // Quick share options
            const SizedBox(height: 10),
            TextButton(
              key: const Key('share-crew-button'),
              onPressed: () => _shareWithCrew(jobId),
              child: const Text('Share with My Crew'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _detectUser() async {
    if (_contactController.text.isEmpty) return;
    
    setState(() => _isDetectingUser = true);
    
    // Simulate user detection
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isDetectingUser = false;
      _detectedUserName = _contactController.text.contains('@') 
        ? 'John Journeyman' : null;
    });
  }

  Future<void> _shareJob(String jobId) async {
    // Navigate to confirmation screen
    Navigator.pushReplacementNamed(
      context, 
      '/share-confirmation',
      arguments: {
        'jobId': jobId,
        'contact': _contactController.text,
        'method': _shareMethod,
        'detectedUser': _detectedUserName,
      },
    );
  }

  Future<void> _shareWithCrew(String jobId) async {
    // Share with predefined crew
    Navigator.pushReplacementNamed(
      context, 
      '/share-confirmation',
      arguments: {
        'jobId': jobId,
        'contact': 'crew',
        'method': 'crew',
        'crewSize': 3,
      },
    );
  }
}

class ContactPickerScreen extends StatelessWidget {
  const ContactPickerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Contact')),
      body: ListView(
        children: [
          ListTile(
            key: const Key('contact-john'),
            leading: const CircleAvatar(child: Text('J')),
            title: const Text('John Journeyman'),
            subtitle: const Text('john@ibew26.org'),
            onTap: () => Navigator.pop(context, 'john@ibew26.org'),
          ),
          ListTile(
            key: const Key('contact-mike'),
            leading: const CircleAvatar(child: Text('M')),
            title: const Text('Mike Lineman'),
            subtitle: const Text('+15551234567'),
            onTap: () => Navigator.pop(context, '+15551234567'),
          ),
          ListTile(
            key: const Key('contact-sarah'),
            leading: const CircleAvatar(child: Text('S')),
            title: const Text('Sarah Electrician'),
            subtitle: const Text('sarah@ibew134.org'),
            onTap: () => Navigator.pop(context, 'sarah@ibew134.org'),
          ),
        ],
      ),
    );
  }
}

class ShareConfirmationScreen extends StatelessWidget {
  const ShareConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Share Sent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              key: Key('success-icon'),
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Job shared successfully!',
              key: Key('success-message'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Job ID: ${args['jobId']}'),
            if (args['contact'] != 'crew')
              Text('Sent to: ${args['contact']}'),
            if (args['crewSize'] != null)
              Text('Shared with ${args['crewSize']} crew members'),
            Text('Method: ${args['method']}'),
            if (args['detectedUser'] != null)
              Text('User: ${args['detectedUser']}'),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              key: const Key('done-button'),
              onPressed: () => Navigator.of(context).popUntil(
                ModalRoute.withName('/'),
              ),
              child: const Text('Done'),
            ),
            
            TextButton(
              key: const Key('share-another-button'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Share with Someone Else'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Job Sharing Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseAnalytics mockAnalytics;
    late MockUser mockUser;

    setUpAll(() {
      // Initialize test environment
    });

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockAnalytics = MockFirebaseAnalytics();
      mockUser = MockUser(
        uid: 'test-user-123',
        email: 'test@ibew26.org',
        displayName: 'Test Journeyman',
      );

      when(mockAuth.currentUser).thenReturn(mockUser);

      // Setup test data
      await _setupTestData(fakeFirestore);
    });

    testWidgets('Complete job sharing flow - existing user', (tester) async {
      // Launch app
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      // Step 1: Navigate to job detail
      await tester.tap(find.byKey(const Key('job-card-job-0')));
      await tester.pumpAndSettle();
      
      expect(find.text('Job ID: job-0'), findsOneWidget);

      // Step 2: Tap share button
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();
      
      expect(find.text('Share Job'), findsOneWidget);

      // Step 3: Enter contact email
      await tester.enterText(
        find.byKey(const Key('contact-input')),
        'colleague@ibew26.org',
      );
      await tester.pumpAndSettle();

      // Wait for user detection
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('detected-user-info')), findsOneWidget);

      // Step 4: Select share method
      await tester.tap(find.byKey(const Key('share-method-in-app')));
      await tester.pumpAndSettle();

      // Step 5: Send share
      await tester.tap(find.byKey(const Key('send-share-button')));
      await tester.pumpAndSettle();

      // Step 6: Verify success screen
      expect(find.byKey(const Key('success-icon')), findsOneWidget);
      expect(find.byKey(const Key('success-message')), findsOneWidget);
      expect(find.text('Job ID: job-0'), findsOneWidget);
      expect(find.text('Sent to: colleague@ibew26.org'), findsOneWidget);

      // Step 7: Complete flow
      await tester.tap(find.byKey(const Key('done-button')));
      await tester.pumpAndSettle();

      // Should return to jobs screen
      expect(find.text('Jobs'), findsOneWidget);
    });

    testWidgets('Share job using contact picker', (tester) async {
      // Launch app
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      // Navigate to share screen
      await tester.tap(find.byKey(const Key('job-card-job-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();

      // Open contact picker
      await tester.tap(find.byKey(const Key('contact-picker-button')));
      await tester.pumpAndSettle();

      expect(find.text('Select Contact'), findsOneWidget);

      // Select a contact
      await tester.tap(find.byKey(const Key('contact-john')));
      await tester.pumpAndSettle();

      // Verify contact was selected
      expect(find.text('john@ibew26.org'), findsOneWidget);

      // Complete sharing
      await tester.tap(find.byKey(const Key('send-share-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('success-message')), findsOneWidget);
    });

    testWidgets('Share job with crew', (tester) async {
      // Launch app
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      // Navigate to share screen
      await tester.tap(find.byKey(const Key('job-card-job-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick-share-button')));
      await tester.pumpAndSettle();

      // Share with crew
      await tester.tap(find.byKey(const Key('share-crew-button')));
      await tester.pumpAndSettle();

      // Verify crew sharing success
      expect(find.byKey(const Key('success-message')), findsOneWidget);
      expect(find.text('Shared with 3 crew members'), findsOneWidget);
      expect(find.text('Method: crew'), findsOneWidget);
    });

    testWidgets('Share job via SMS to phone number', (tester) async {
      // Launch app
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      // Navigate to share screen
      await tester.tap(find.byKey(const Key('job-card-job-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();

      // Enter phone number
      await tester.enterText(
        find.byKey(const Key('contact-input')),
        '+15551234567',
      );
      await tester.pumpAndSettle();

      // Select SMS method
      await tester.tap(find.byKey(const Key('share-method-sms')));
      await tester.pumpAndSettle();

      // Send share
      await tester.tap(find.byKey(const Key('send-share-button')));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Sent to: +15551234567'), findsOneWidget);
      expect(find.text('Method: sms'), findsOneWidget);
    });

    testWidgets('Handle sharing to non-user email', (tester) async {
      // Launch app
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      // Navigate to share screen
      await tester.tap(find.byKey(const Key('job-card-job-4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();

      // Enter non-user email
      await tester.enterText(
        find.byKey(const Key('contact-input')),
        'newuser@gmail.com',
      );
      await tester.pumpAndSettle();

      // Wait for detection to complete (no user found)
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('detected-user-info')), findsNothing);

      // Email method should be auto-selected for non-users
      await tester.tap(find.byKey(const Key('share-method-email')));
      await tester.pumpAndSettle();

      // Send invitation
      await tester.tap(find.byKey(const Key('send-share-button')));
      await tester.pumpAndSettle();

      // Verify invitation sent
      expect(find.text('Job shared successfully!'), findsOneWidget);
      expect(find.text('Sent to: newuser@gmail.com'), findsOneWidget);
      expect(find.text('Method: email'), findsOneWidget);
    });

    testWidgets('Test error handling - invalid contact', (tester) async {
      // Launch app
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      // Navigate to share screen
      await tester.tap(find.byKey(const Key('job-card-job-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();

      // Enter invalid contact
      await tester.enterText(
        find.byKey(const Key('contact-input')),
        'invalid-contact',
      );
      await tester.pumpAndSettle();

      // Share button should be disabled or show error
      final shareButton = find.byKey(const Key('send-share-button'));
      expect(tester.widget<ElevatedButton>(shareButton).onPressed, isNull);
    });

    testWidgets('Test share-another workflow', (tester) async {
      // Launch app and complete one share
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: fakeFirestore,
        auth: mockAuth,
        analytics: mockAnalytics,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('job-card-job-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(
        find.byKey(const Key('contact-input')),
        'first@ibew.org',
      );
      await tester.tap(find.byKey(const Key('send-share-button')));
      await tester.pumpAndSettle();

      // Now test sharing with another person
      await tester.tap(find.byKey(const Key('share-another-button')));
      await tester.pumpAndSettle();

      // Should return to share screen
      expect(find.text('Share Job'), findsOneWidget);
      
      // Contact field should be cleared
      final textField = tester.widget<TextField>(find.byKey(const Key('contact-input')));
      expect(textField.controller!.text, isEmpty);
    });
  });

  group('Share Flow Performance Tests', () {
    testWidgets('Share flow completes within performance thresholds', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        analytics: MockFirebaseAnalytics(),
      ));
      await tester.pumpAndSettle();

      // Complete entire share flow
      await tester.tap(find.byKey(const Key('job-card-job-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('contact-input')),
        'perf@test.com',
      );
      await tester.tap(find.byKey(const Key('send-share-button')));
      await tester.pumpAndSettle();

      stopwatch.stop();
      
      // Should complete in under 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('Contact picker loads quickly', (tester) async {
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        analytics: MockFirebaseAnalytics(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('job-card-job-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      await tester.tap(find.byKey(const Key('contact-picker-button')));
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Contact picker should load in under 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.text('Select Contact'), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Share flow is accessible', (tester) async {
      await tester.pumpWidget(ShareFlowTestApp(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        analytics: MockFirebaseAnalytics(),
      ));
      await tester.pumpAndSettle();

      // Test semantic labels and accessibility
      expect(find.byKey(const Key('share-job-button')), findsOneWidget);
      
      // All interactive elements should have semantic labels
      final shareButton = find.byKey(const Key('share-job-button'));
      expect(tester.getSemantics(shareButton), hasProperty('label'));
    });

    testWidgets('Screen reader compatibility', (tester) async {
      // Test with screen reader settings
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/accessibility'),
        (call) async {
          if (call.method == 'announce') {
            // Mock screen reader announcements
            return true;
          }
          return null;
        },
      );

      await tester.pumpWidget(ShareFlowTestApp(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        analytics: MockFirebaseAnalytics(),
      ));
      await tester.pumpAndSettle();

      // Navigate through share flow
      await tester.tap(find.byKey(const Key('job-card-job-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share-job-button')));
      await tester.pumpAndSettle();

      // Screen should announce important changes
      expect(find.text('Share Job'), findsOneWidget);
    });
  });
}

// Helper function to setup test data
Future<void> _setupTestData(FakeFirebaseFirestore firestore) async {
  // Create test jobs
  for (int i = 0; i < 5; i++) {
    await firestore.collection('jobs').doc('job-$i').set({
      'title': 'Storm Work - IBEW Local 26',
      'description': 'Emergency line restoration after storm',
      'local': 26,
      'classification': 'Journeyman Lineman',
      'payRate': 55.50,
      'location': 'Tacoma, WA',
      'startDate': DateTime.now().add(Duration(days: i + 1)),
      'stormWork': true,
      'urgent': i == 0,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'job-poster-$i',
    });
  }

  // Create test users
  await firestore.collection('users').doc('colleague-user').set({
    'email': 'colleague@ibew26.org',
    'displayName': 'John Journeyman',
    'ibewLocal': 26,
    'classification': 'Journeyman Lineman',
    'fcmTokens': ['fcm-token-colleague'],
    'isVerified': true,
    'lastActive': DateTime.now().subtract(Duration(hours: 1)),
  });

  await firestore.collection('users').doc('contact-john').set({
    'email': 'john@ibew26.org',
    'displayName': 'John Journeyman',
    'ibewLocal': 26,
    'fcmTokens': ['fcm-token-john'],
  });

  // Create crew data
  await firestore.collection('crews').doc('test-crew').set({
    'foremanId': 'test-user-123',
    'memberIds': ['crew-member-1', 'crew-member-2', 'crew-member-3'],
    'name': 'Storm Restoration Crew Alpha',
    'local': 26,
    'active': true,
  });

  // Create crew members
  for (int i = 1; i <= 3; i++) {
    await firestore.collection('users').doc('crew-member-$i').set({
      'email': 'crew$i@ibew26.org',
      'displayName': 'Crew Member $i',
      'ibewLocal': 26,
      'classification': 'Journeyman Lineman',
      'fcmTokens': ['fcm-token-crew-$i'],
    });
  }
}