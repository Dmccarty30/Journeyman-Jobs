# Complete Testing Suite

## Unit, Integration & E2E Tests for Job Sharing Feature

---

## 📋 Test Overview

This comprehensive testing suite covers all aspects of the job sharing feature with unit tests, integration tests, and end-to-end tests.

---

## 🧪 Test Setup

### Dependencies

**File: `pubspec.yaml` (test dependencies)**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
  fake_cloud_firestore: ^2.4.0
  firebase_auth_mocks: ^0.13.0
  network_image_mock: ^2.1.0
  golden_toolkit: ^0.15.0
  integration_test:
    sdk: flutter
```

### Test Configuration

**File: `test/test_helpers/test_config.dart`**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
])
void main() {}

class TestConfig {
  static Future<void> setupFirebaseTests() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
  
  static Map<String, dynamic> createMockJob() {
    return {
      'id': 'job123',
      'title': 'Journeyman Lineman',
      'classification': 'Journeyman Lineman',
      'company': 'Duke Energy',
      'city': 'Charlotte',
      'state': 'NC',
      'hourlyRate': 48.50,
      'perDiem': 150,
      'duration': '3-6 months',
      'description': 'Storm restoration work',
      'createdAt': DateTime.now(),
    };
  }
  
  static Map<String, dynamic> createMockUser() {
    return {
      'uid': 'user123',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'first_name': 'Test',
      'last_name': 'User',
      'phone_number': '555-1234',
    };
  }
  
  static Map<String, dynamic> createMockShare() {
    return {
      'id': 'share123',
      'jobId': 'job123',
      'sharerId': 'user123',
      'sharerName': 'Test User',
      'recipients': [
        {
          'identifier': 'friend@example.com',
          'type': 'email',
          'status': 'sent',
        }
      ],
      'message': 'Check this out!',
      'createdAt': DateTime.now(),
      'jobSnapshot': createMockJob(),
    };
  }
}
```

---

## 🔬 Unit Tests

### Share Model Tests

**File: `test/unit/models/share_model_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/features/job_sharing/models/share_model.dart';

void main() {
  group('ShareModel', () {
    late FakeFirebaseFirestore firestore;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
    });
    
    test('creates ShareModel from Firestore document', () async {
      // Arrange
      final shareData = {
        'jobId': 'job123',
        'sharerId': 'user123',
        'sharerName': 'John Doe',
        'recipients': [
          {
            'identifier': 'test@example.com',
            'type': 'email',
            'status': 'sent',
            'userId': null,
            'name': null,
          }
        ],
        'message': 'Check this job!',
        'createdAt': Timestamp.now(),
        'jobSnapshot': {
          'title': 'Journeyman Lineman',
          'company': 'Duke Energy',
        },
      };
      
      await firestore.collection('shares').doc('share123').set(shareData);
      final doc = await firestore.collection('shares').doc('share123').get();
      
      // Act
      final share = ShareModel.fromFirestore(doc);
      
      // Assert
      expect(share.id, equals('share123'));
      expect(share.jobId, equals('job123'));
      expect(share.sharerId, equals('user123'));
      expect(share.sharerName, equals('John Doe'));
      expect(share.recipients.length, equals(1));
      expect(share.recipients.first.identifier, equals('test@example.com'));
      expect(share.message, equals('Check this job!'));
    });
    
    test('converts ShareModel to Firestore map', () {
      // Arrange
      final share = ShareModel(
        id: 'share123',
        jobId: 'job123',
        sharerId: 'user123',
        sharerName: 'John Doe',
        recipients: [
          ShareRecipient(
            identifier: 'test@example.com',
            type: RecipientType.email,
          ),
        ],
        message: 'Check this job!',
        createdAt: DateTime.now(),
        jobSnapshot: {'title': 'Test Job'},
      );
      
      // Act
      final map = share.toFirestore();
      
      // Assert
      expect(map['jobId'], equals('job123'));
      expect(map['sharerId'], equals('user123'));
      expect(map['sharerName'], equals('John Doe'));
      expect(map['recipients'], isA<List>());
      expect(map['message'], equals('Check this job!'));
      expect(map['jobSnapshot'], isA<Map>());
    });
    
    test('ShareRecipient status updates correctly', () {
      // Arrange
      final recipient = ShareRecipient(
        identifier: 'test@example.com',
        type: RecipientType.email,
        status: ShareStatus.sent,
      );
      
      // Act
      recipient.status = ShareStatus.viewed;
      recipient.viewedAt = DateTime.now();
      
      // Assert
      expect(recipient.status, equals(ShareStatus.viewed));
      expect(recipient.viewedAt, isNotNull);
    });
  });
}
```

### User Detection Service Tests

**File: `test/unit/services/user_detection_service_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/features/job_sharing/services/user_detection_service.dart';

void main() {
  group('UserDetectionService', () {
    late UserDetectionService service;
    late FakeFirebaseFirestore firestore;
    
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      service = UserDetectionService();
      
      // Add test users
      await firestore.collection('users').doc('user1').set({
        'email': 'existing@example.com',
        'first_name': 'Existing',
        'last_name': 'User',
        'phone_number': '5551234567',
      });
    });
    
    test('detects existing user by email', () async {
      // Act
      final result = await service.detectUser('existing@example.com');
      
      // Assert
      expect(result, isNotNull);
      expect(result!['isUser'], isTrue);
      expect(result['type'], equals(RecipientType.user));
      expect(result['userId'], equals('user1'));
      expect(result['name'], equals('Existing User'));
    });
    
    test('detects non-user email', () async {
      // Act
      final result = await service.detectUser('new@example.com');
      
      // Assert
      expect(result, isNotNull);
      expect(result!['isUser'], isFalse);
      expect(result['type'], equals(RecipientType.email));
      expect(result['identifier'], equals('new@example.com'));
    });
    
    test('detects existing user by phone', () async {
      // Act
      final result = await service.detectUser('555-123-4567');
      
      // Assert
      expect(result, isNotNull);
      expect(result!['isUser'], isTrue);
      expect(result['type'], equals(RecipientType.user));
      expect(result['userId'], equals('user1'));
    });
    
    test('validates email format', () {
      // Act & Assert
      expect(service.isEmail('valid@example.com'), isTrue);
      expect(service.isEmail('invalid.email'), isFalse);
      expect(service.isEmail('555-1234'), isFalse);
    });
    
    test('validates phone format', () {
      // Act & Assert
      expect(service.isPhone('5551234567'), isTrue);
      expect(service.isPhone('555-123-4567'), isTrue);
      expect(service.isPhone('(555) 123-4567'), isTrue);
      expect(service.isPhone('123'), isFalse);
      expect(service.isPhone('email@example.com'), isFalse);
    });
    
    test('batch detects multiple users', () async {
      // Arrange
      final identifiers = [
        'existing@example.com',
        'new@example.com',
        '555-123-4567',
      ];
      
      // Act
      final results = await service.detectMultipleUsers(identifiers);
      
      // Assert
      expect(results.length, equals(3));
      expect(results[0]['isUser'], isTrue);
      expect(results[1]['isUser'], isFalse);
      expect(results[2]['isUser'], isTrue);
    });
  });
}
```

### Share Service Tests

**File: `test/unit/services/share_service_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/features/job_sharing/services/share_service.dart';
import 'package:journeyman_jobs/features/jobs/models/job_model.dart';

class MockEmailService extends Mock {
  Future<bool> sendJobShareEmail({
    required String toEmail,
    required String sharerName,
    required JobModel job,
    String? personalMessage,
    required String shareId,
  }) async {
    return true;
  }
}

void main() {
  group('ShareService', () {
    late ShareService service;
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;
    late MockEmailService emailService;
    
    setUp(() async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'user123',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );
      
      firestore = FakeFirebaseFirestore();
      emailService = MockEmailService();
      
      service = ShareService();
      
      // Add test user profile
      await firestore.collection('users').doc('user123').set({
        'first_name': 'Test',
        'last_name': 'User',
        'email': 'test@example.com',
      });
    });
    
    test('creates share successfully', () async {
      // Arrange
      final job = JobModel(
        id: 'job123',
        classification: 'Journeyman Lineman',
        company: 'Duke Energy',
        city: 'Charlotte',
        state: 'NC',
        hourlyRate: 48.50,
        perDiem: 150,
        duration: '3-6 months',
      );
      
      final recipients = ['friend@example.com', 'buddy@example.com'];
      
      // Act
      final share = await service.shareJob(
        job: job,
        recipientIdentifiers: recipients,
        personalMessage: 'Check this out!',
      );
      
      // Assert
      expect(share.jobId, equals('job123'));
      expect(share.sharerId, equals('user123'));
      expect(share.recipients.length, equals(2));
      expect(share.message, equals('Check this out!'));
    });
    
    test('sends notifications to users and emails', () async {
      // Arrange
      final job = JobModel(
        id: 'job123',
        classification: 'Journeyman Lineman',
        company: 'Duke Energy',
        city: 'Charlotte',
        state: 'NC',
        hourlyRate: 48.50,
      );
      
      // Add existing user
      await firestore.collection('users').doc('user456').set({
        'email': 'existing@example.com',
        'first_name': 'Existing',
        'last_name': 'User',
      });
      
      final recipients = [
        'existing@example.com',  // Existing user
        'new@example.com',       // Non-user
      ];
      
      // Act
      final share = await service.shareJob(
        job: job,
        recipientIdentifiers: recipients,
        personalMessage: 'Great opportunity!',
      );
      
      // Assert
      expect(share.recipients.length, equals(2));
      
      // Check notification created for existing user
      final notifications = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: 'user456')
          .get();
      expect(notifications.docs.length, greaterThan(0));
      
      // Verify email service was called for non-user
      verify(emailService.sendJobShareEmail(
        toEmail: 'new@example.com',
        sharerName: 'Test User',
        job: job,
        personalMessage: 'Great opportunity!',
        shareId: anyNamed('shareId'),
      )).called(1);
    });
    
    test('tracks share analytics', () async {
      // Arrange
      final job = JobModel(
        id: 'job123',
        classification: 'Journeyman Lineman',
        company: 'Duke Energy',
        city: 'Charlotte',
        state: 'NC',
        hourlyRate: 48.50,
      );
      
      // Act
      await service.shareJob(
        job: job,
        recipientIdentifiers: ['test@example.com'],
      );
      
      // Assert
      final analytics = await firestore
          .collection('analytics')
          .where('event', isEqualTo: 'job_shared')
          .get();
      
      expect(analytics.docs.length, equals(1));
      expect(analytics.docs.first.data()['jobId'], equals('job123'));
      expect(analytics.docs.first.data()['recipientCount'], equals(1));
    });
    
    test('marks share as viewed', () async {
      // Arrange
      await firestore.collection('shares').doc('share123').set({
        'jobId': 'job123',
        'sharerId': 'user123',
        'recipients': [
          {
            'identifier': 'test@example.com',
            'type': 'email',
            'status': 'sent',
          }
        ],
      });
      
      // Act
      await service.markShareAsViewed('share123', 'test@example.com');
      
      // Assert
      final share = await firestore
          .collection('shares')
          .doc('share123')
          .get();
      
      final recipients = share.data()!['recipients'] as List;
      expect(recipients[0]['status'], equals('viewed'));
      expect(recipients[0]['viewedAt'], isNotNull);
    });
  });
}
```

---

## 🔗 Integration Tests

### Share Flow Integration Test

**File: `test/integration/share_flow_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Share Flow Integration', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });
    
    tearDown(() async {
      // Clean up test data
      await FirebaseAuth.instance.signOut();
    });
    
    testWidgets('Complete share flow from job details to email', 
        (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // Sign in test user
      await _signInTestUser(tester);
      
      // Navigate to jobs
      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();
      
      // Select first job
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // Tap share button
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      
      // Enter recipient email
      await tester.enterText(
        find.byType(TextField).first,
        'friend@example.com',
      );
      
      // Add personal message
      await tester.enterText(
        find.byType(TextField).last,
        'Great opportunity for you!',
      );
      
      // Send share
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      
      // Verify success
      expect(find.text('Job shared successfully!'), findsOneWidget);
      
      // Verify share in database
      final shares = await FirebaseFirestore.instance
          .collection('shares')
          .where('sharerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      
      expect(shares.docs.length, greaterThan(0));
      expect(shares.docs.first.data()['message'], 
          equals('Great opportunity for you!'));
    });
    
    testWidgets('Quick signup flow from share link', 
        (WidgetTester tester) async {
      // Create test share
      final shareId = await _createTestShare();
      
      // Start app with share link
      app.main(shareLink: '/share?id=$shareId&job=job123');
      await tester.pumpAndSettle();
      
      // Should show quick signup screen
      expect(find.text('Quick Signup'), findsOneWidget);
      
      // Fill signup form
      await tester.enterText(
        find.byKey(Key('name_field')),
        'New User',
      );
      
      await tester.enterText(
        find.byKey(Key('email_field')),
        'newuser@example.com',
      );
      
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      
      // Submit
      await tester.tap(find.text('Create Account & Apply'));
      await tester.pumpAndSettle();
      
      // Verify account created
      expect(FirebaseAuth.instance.currentUser, isNotNull);
      expect(FirebaseAuth.instance.currentUser!.email, 
          equals('newuser@example.com'));
      
      // Verify auto-applied
      final applications = await FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      
      expect(applications.docs.length, equals(1));
      expect(applications.docs.first.data()['jobId'], equals('job123'));
    });
    
    testWidgets('Contact picker integration', 
        (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // Sign in
      await _signInTestUser(tester);
      
      // Navigate to share
      await _navigateToShare(tester);
      
      // Tap contact picker
      await tester.tap(find.byIcon(Icons.contacts));
      await tester.pumpAndSettle();
      
      // Grant permission if needed
      if (find.text('Grant Permission').evaluate().isNotEmpty) {
        await tester.tap(find.text('Grant Permission'));
        await tester.pumpAndSettle();
      }
      
      // Select contacts
      await tester.tap(find.byType(Checkbox).first);
      await tester.tap(find.byType(Checkbox).at(1));
      
      // Add selected
      await tester.tap(find.text('Add Selected'));
      await tester.pumpAndSettle();
      
      // Verify contacts added
      expect(find.text('2 recipients selected'), findsOneWidget);
    });
  });
}

Future<void> _signInTestUser(WidgetTester tester) async {
  // Sign in with test account
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'test@example.com',
    password: 'testpassword',
  );
  await tester.pumpAndSettle();
}

Future<String> _createTestShare() async {
  final doc = await FirebaseFirestore.instance.collection('shares').add({
    'jobId': 'job123',
    'sharerId': 'user123',
    'sharerName': 'Test User',
    'recipients': [],
    'createdAt': FieldValue.serverTimestamp(),
    'jobSnapshot': {
      'title': 'Test Job',
      'company': 'Test Company',
      'hourlyRate': 50,
    },
  });
  return doc.id;
}

Future<void> _navigateToShare(WidgetTester tester) async {
  // Navigate to job details
  await tester.tap(find.text('Jobs'));
  await tester.pumpAndSettle();
  
  await tester.tap(find.byType(Card).first);
  await tester.pumpAndSettle();
  
  // Open share modal
  await tester.tap(find.byIcon(Icons.share));
  await tester.pumpAndSettle();
}
```

---

## 🎭 Widget Tests

### Share Button Widget Test

**File: `test/widgets/share_button_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/job_sharing/widgets/share_button.dart';
import 'package:journeyman_jobs/features/jobs/models/job_model.dart';

void main() {
  group('ShareButton Widget', () {
    late JobModel testJob;
    
    setUp(() {
      testJob = JobModel(
        id: 'job123',
        classification: 'Journeyman Lineman',
        company: 'Duke Energy',
        city: 'Charlotte',
        state: 'NC',
        hourlyRate: 48.50,
      );
    });
    
    testWidgets('displays icon only variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              job: testJob,
              isIconOnly: true,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.text('Share'), findsNothing);
    });
    
    testWidgets('displays text with icon variant', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              job: testJob,
              isIconOnly: false,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
    
    testWidgets('opens share screen on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(job: testJob),
          ),
          routes: {
            '/share': (context) => Text('Share Screen'),
          },
        ),
      );
      
      await tester.tap(find.byType(ShareButton));
      await tester.pumpAndSettle();
      
      // Should navigate to share screen
      expect(find.text('Share Screen'), findsOneWidget);
    });
    
    testWidgets('calls onShareComplete callback', 
        (WidgetTester tester) async {
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              job: testJob,
              onShareComplete: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Simulate share completion
      // (In real app, this would happen after share flow)
      
      expect(callbackCalled, isTrue);
    });
  });
}
```

### Share Modal Widget Test

**File: `test/widgets/share_modal_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/job_sharing/widgets/share_modal.dart';

void main() {
  group('ShareModal Widget', () {
    testWidgets('displays recipient list', (WidgetTester tester) async {
      final recipients = [
        {
          'identifier': 'user1@example.com',
          'isUser': true,
          'name': 'User One',
        },
        {
          'identifier': 'user2@example.com',
          'isUser': false,
        },
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareModal(
              detectedRecipients: recipients,
              onAddRecipient: (String recipient) {},
              onRemoveRecipient: (String recipient) {},
              onShare: () {},
            ),
          ),
        ),
      );
      
      expect(find.text('User One'), findsOneWidget);
      expect(find.text('user1@example.com'), findsOneWidget);
      expect(find.text('user2@example.com'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);  // User badge
      expect(find.text('Invite'), findsOneWidget); // Invite badge
    });
    
    testWidgets('adds new recipient', (WidgetTester tester) async {
      String? addedRecipient;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareModal(
              detectedRecipients: [],
              onAddRecipient: (recipient) {
                addedRecipient = recipient;
              },
              onRemoveRecipient: (String recipient) {},
              onShare: () {},
            ),
          ),
        ),
      );
      
      // Enter email
      await tester.enterText(
        find.byType(TextField).first,
        'new@example.com',
      );
      
      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      expect(addedRecipient, equals('new@example.com'));
    });
    
    testWidgets('validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareModal(
              detectedRecipients: [],
              onAddRecipient: (String recipient) {},
              onRemoveRecipient: (String recipient) {},
              onShare: () {},
            ),
          ),
        ),
      );
      
      // Enter invalid email
      await tester.enterText(
        find.byType(TextField).first,
        'invalid.email',
      );
      
      // Try to add
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Should show error
      expect(find.text('Invalid email format'), findsOneWidget);
    });
    
    testWidgets('disables share with no recipients', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareModal(
              detectedRecipients: [],
              onAddRecipient: (String recipient) {},
              onRemoveRecipient: (String recipient) {},
              onShare: () {},
            ),
          ),
        ),
      );
      
      final shareButton = find.widgetWithText(ElevatedButton, 'Share');
      final button = tester.widget<ElevatedButton>(shareButton);
      
      expect(button.onPressed, isNull);
    });
  });
}
```

---

## 🚀 End-to-End Tests

### Complete User Journey Test

**File: `test/e2e/share_journey_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:journeyman_jobs/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('E2E Share Journey', () {
    testWidgets('Complete share journey from sender to recipient', 
        (WidgetTester tester) async {
      // PART 1: SENDER JOURNEY
      print('Starting sender journey...');
      
      // Start app as sender
      app.main();
      await tester.pumpAndSettle();
      
      // Sign in as sender
      await _signIn(tester, 'sender@example.com', 'password123');
      
      // Browse to job
      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();
      
      // Find high-paying job
      final jobCard = find.text('\$48.50/hr').first;
      await tester.tap(jobCard);
      await tester.pumpAndSettle();
      
      // Share job
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      
      // Add recipients
      await tester.enterText(
        find.byType(TextField).first,
        'recipient@example.com',
      );
      await tester.tap(find.byIcon(Icons.add));
      
      // Add message
      await tester.enterText(
        find.byType(TextField).last,
        'Perfect job for your skills!',
      );
      
      // Send
      await tester.tap(find.text('Share Now'));
      await tester.pumpAndSettle();
      
      // Verify success
      expect(find.text('Job shared successfully!'), findsOneWidget);
      
      // Sign out sender
      await _signOut(tester);
      
      // PART 2: RECIPIENT JOURNEY (NON-USER)
      print('Starting recipient journey...');
      
      // Simulate clicking email link
      final shareId = await _getLatestShareId();
      app.main(shareLink: '/signup?share=$shareId&job=job123');
      await tester.pumpAndSettle();
      
      // Should see quick signup
      expect(find.text('Quick Signup'), findsOneWidget);
      expect(find.text('Perfect job for your skills!'), findsOneWidget);
      
      // Fill quick signup
      await tester.enterText(
        find.byKey(Key('name_field')),
        'New Recipient',
      );
      
      await tester.enterText(
        find.byKey(Key('email_field')),
        'recipient@example.com',
      );
      
      await tester.enterText(
        find.byKey(Key('password_field')),
        'newpassword123',
      );
      
      // Create account
      await tester.tap(find.text('Create Account & Apply'));
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Should be on job details with application submitted
      expect(find.text('Application submitted!'), findsOneWidget);
      expect(find.text('\$48.50/hr'), findsOneWidget);
      
      // PART 3: VERIFY METRICS
      print('Verifying metrics...');
      
      final metrics = await _getShareMetrics(shareId);
      expect(metrics['views'], equals(1));
      expect(metrics['signups'], equals(1));
      expect(metrics['applies'], equals(1));
      
      print('E2E test completed successfully!');
    });
  });
}

Future<void> _signIn(WidgetTester tester, String email, String password) async {
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
  
  await tester.enterText(
    find.byKey(Key('email_field')),
    email,
  );
  
  await tester.enterText(
    find.byKey(Key('password_field')),
    password,
  );
  
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
}

Future<void> _signOut(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  
  await tester.tap(find.text('Sign Out'));
  await tester.pumpAndSettle();
}

Future<String> _getLatestShareId() async {
  // Get most recent share from Firestore
  final shares = await FirebaseFirestore.instance
      .collection('shares')
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();
  
  return shares.docs.first.id;
}

Future<Map<String, dynamic>> _getShareMetrics(String shareId) async {
  final share = await FirebaseFirestore.instance
      .collection('shares')
      .doc(shareId)
      .get();
  
  return share.data()!['metrics'] ?? {};
}
```

---

## 📊 Performance Tests

**File: `test/performance/share_performance_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Share Performance', () {
    testWidgets('Share action completes within 200ms', 
        (WidgetTester tester) async {
      // Measure share button tap to modal open
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      print('Share modal opened in ${stopwatch.elapsedMilliseconds}ms');
    });
    
    testWidgets('Batch share to 10 recipients', 
        (WidgetTester tester) async {
      // Add 10 recipients
      final recipients = List.generate(
        10, 
        (i) => 'user$i@example.com',
      );
      
      final stopwatch = Stopwatch()..start();
      
      // Process share
      await _shareToMultiple(tester, recipients);
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      print('Batch share completed in ${stopwatch.elapsedMilliseconds}ms');
    });
    
    testWidgets('Contact list loads within 1 second', 
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byIcon(Icons.contacts));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      print('Contacts loaded in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}

Future<void> _shareToMultiple(
  WidgetTester tester, 
  List<String> recipients,
) async {
  for (final recipient in recipients) {
    await tester.enterText(find.byType(TextField).first, recipient);
    await tester.tap(find.byIcon(Icons.add));
  }
  
  await tester.tap(find.text('Share'));
  await tester.pumpAndSettle();
}
```

---

## 🎯 Test Coverage Report

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

### Expected Coverage

```dart
lib/features/job_sharing/
├── models/             95%
├── services/           92%
├── widgets/            88%
├── screens/            85%
└── providers/          90%

Overall Coverage:       90%
```

---

## 🔧 Test Configuration

**File: `test/test_config.yaml`**

```yaml
# Test configuration
test:
  # Timeouts
  timeout: 5m
  
  # Retries
  retry: 2
  
  # Concurrency
  concurrency: 4
  
  # Tags
  tags:
    unit:
      timeout: 30s
    integration:
      timeout: 2m
    e2e:
      timeout: 5m
      
  # Exclude
  exclude:
    - test/manual/**
    - test/experimental/**
```

---

## 📝 Test Scripts

**File: `scripts/test.sh`**

```bash
#!/bin/bash

echo "🧪 Running Job Sharing Feature Tests"
echo "===================================="

# Unit tests
echo "\n📦 Running unit tests..."
flutter test test/unit/ --coverage

# Widget tests
echo "\n🎨 Running widget tests..."
flutter test test/widgets/

# Integration tests
echo "\n🔗 Running integration tests..."
flutter test test/integration/

# E2E tests (requires device/emulator)
echo "\n🚀 Running E2E tests..."
flutter drive --driver=test_driver/integration_test.dart \
  --target=test/e2e/share_journey_test.dart

# Performance tests
echo "\n⚡ Running performance tests..."
flutter test test/performance/

# Generate coverage report
echo "\n📊 Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "\n✅ All tests completed!"
echo "Coverage report: coverage/html/index.html"
```

---

## ✅ Testing Checklist

```dart
Unit Tests:
☐ Share model serialization
☐ User detection logic
☐ Email validation
☐ Phone validation
☐ Share service methods
☐ Analytics tracking
☐ Crew management

Widget Tests:
☐ Share button variants
☐ Share modal interactions
☐ Recipient selector
☐ Contact picker
☐ Notification cards
☐ Quick signup form

Integration Tests:
☐ Complete share flow
☐ Quick signup flow
☐ Notification delivery
☐ Contact integration
☐ Deep linking
☐ Crew sharing

E2E Tests:
☐ Sender journey
☐ Recipient journey
☐ Conversion tracking
☐ Multiple recipients
☐ Error recovery

Performance Tests:
☐ Share action < 200ms
☐ Batch operations
☐ Contact loading
☐ Memory usage
☐ Network efficiency

Manual Tests:
☐ iOS permissions
☐ Android permissions
☐ Email delivery
☐ Push notifications
☐ Different devices
```

---

*This comprehensive testing suite ensures the job sharing feature is robust, performant, and bug-free.*
