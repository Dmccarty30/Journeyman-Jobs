import 'dart:async';
import 'package:flutter/material.dart' as material; // Alias material
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' as ft; // Alias flutter_test
import 'package:provider/provider.dart' as legacy_provider; // Alias provider (still needed for some legacy components)
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod; // Alias flutter_riverpod
import 'package:mockito/mockito.dart' as m; // Alias mockito
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Alias cloud_firestore

// Project-specific imports for Riverpod providers and models
import 'package:journeyman_jobs/providers/riverpod/app_state_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/job_filter_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/connectivity_riverpod_provider.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:journeyman_jobs/models/filter_criteria.dart';
import 'package:journeyman_jobs/models/job_model.dart'; // Corrected import for Job

// Generated Riverpod provider imports (for overriding) - Removed .g.dart imports
// These are not imported directly, but are part of their respective .dart files.
// import 'package:journeman_jobs/providers/riverpod/app_state_riverpod_provider.g.dart';
// import 'package:journeyman_jobs/providers/riverpod/job_filter_riverpod_provider.g.dart';
// import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.g.dart';
// import 'package:journeyman_jobs/providers/riverpod/connectivity_riverpod_provider.g.dart';


// A simple mock for UserCredential to resolve the error
class MockUserCredential implements UserCredential {
  @override
  final User? user;

  MockUserCredential({this.user});

  @override
  AuthCredential? get credential => null;
  @override
  String? get verificationId => null;
  @override
  String? get verificationCode => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  
  @override
  String get operationType => ''; // Fixed: return empty string for non-nullable
  
  @override
  String? get providerId => null;
  
  @override
  String? get signInMethod => null;
}

// Manual mock implementations for complex services
class TestAuthService extends m.Mock implements AuthService {
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final mockUser = MockUser(uid: 'test-uid', email: email);
    _currentUser = mockUser;
    _authStateController.add(mockUser);
    return MockUserCredential(user: mockUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  void setSignedInUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  void dispose() {
    _authStateController.close();
  }
}

// Mock Riverpod Notifiers (interfaces for mocking)
// These are the actual Notifier classes that the generated providers expose.
// We mock their interfaces to provide controlled behavior in tests.
class MockJobFilterNotifier extends m.Mock implements JobFilterNotifier {}
class MockAppStateNotifier extends m.Mock implements AppStateNotifier {}
class MockAuthNotifier extends m.Mock implements AuthNotifier {}
class MockConnectivityNotifier extends m.Mock implements ConnectivityNotifier {}

class ConnectivityNotifier {
}


class TestResilientFirestoreService extends m.Mock implements ResilientFirestoreService {
  final FakeFirebaseFirestore _firestore = FakeFirebaseFirestore();

  @override
  Stream<firestore.QuerySnapshot> getJobs({
    Map<String, dynamic>? filters,
    firestore.DocumentSnapshot? startAfter,
    int limit = 10,
  }) {
    firestore.Query query = _firestore.collection('jobs');
    
    if (filters != null) {
      filters.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          query = query.where(key, whereIn: value);
        } else if (value != null) {
          query = query.where(key, isEqualTo: value);
        }
      });
    }
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    return query.limit(limit).snapshots();
  }

  @override
  Stream<firestore.QuerySnapshot> getLocals({
    String? state,
    firestore.DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    firestore.Query query = _firestore.collection('locals');
    
    if (state != null) {
      query = query.where('state', isEqualTo: state);
    }
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    return query.limit(limit).snapshots();
  }

  @override
  Future<firestore.QuerySnapshot> searchLocals(String searchQuery, {int limit = 20, String? state}) async {
    firestore.Query query = _firestore.collection('locals');
    
    if (state != null) {
      query = query.where('state', isEqualTo: state);
    }

    query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                 .where('name', isLessThan: searchQuery + '\uf8ff');
    
    return query.limit(limit).get();
  }

  // Helper method to seed test data
  Future<void> seedTestData() async {
    // Add test jobs
    await _firestore.collection('jobs').add(TestFixtures.createJobData());
    await _firestore.collection('jobs').add(TestFixtures.createJobData(
      id: 'job-2',
      company: 'Another Electric Co',
      local: 456,
    ));

    // Add test locals
    await _firestore.collection('locals').add(TestFixtures.createLocalData());
    await _firestore.collection('locals').add(TestFixtures.createLocalData(
      localNumber: 456,
      name: 'IBEW Local 456',
    ));
  }
}

class TestConnectivityService extends m.Mock implements ConnectivityService {
  bool _isConnected = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  void setConnected(bool connected) {
    _isConnected = connected;
    _connectivityController.add(connected);
  }

  @override
  void dispose() {
    _connectivityController.close();
  }

  @override
  bool get hasListeners => _connectivityController.hasListener;
}


/// Create a widget test environment with mocked dependencies using Riverpod's ProviderScope
material.Widget createRiverpodTestWidget(
  material.Widget widget, {
  List<riverpod.Override> overrides = const [],
}) {
  return riverpod.ProviderScope(
    overrides: overrides,
    child: material.MaterialApp( // Corrected alias
      home: widget,
    ),
  );
}

/// Create a test Firebase Auth instance
MockFirebaseAuth createMockFirebaseAuth({
  bool isSignedIn = false,
  String? uid,
  String? email,
}) {
  final auth = MockFirebaseAuth(
    signedIn: isSignedIn,
    mockUser: isSignedIn
        ? MockUser(
            uid: uid ?? 'test-user-id',
            email: email ?? 'test@example.com',
            displayName: 'Test User',
          )
        : null,
  );
  return auth;
}

/// Create a test Firestore instance
FakeFirebaseFirestore createFakeFirestore() {
  return FakeFirebaseFirestore();
}

/// Pump widget and settle with timeout protection
Future<void> pumpAndSettleWithTimeout(
  ft.WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    ft.EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

/// Find widgets by key string
ft.Finder findByKeyString(String key) {
  return ft.find.byKey(material.Key(key));
}

/// Common test data fixtures
class TestFixtures {
  static Map<String, dynamic> createJobData({
    String? id,
    String? company,
    String? location,
    String? classification,
    int? local,
    double? wage,
  }) {
    return {
      'id': id ?? 'test-job-id',
      'company': company ?? 'Test Electrical Company',
      'location': location ?? 'Test City, TS',
      'classification': classification ?? 'Inside Wireman',
      'local': local ?? 123,
      'wage': wage ?? 42.50,
      'job_title': 'Journeyman Electrician',
      'timestamp': DateTime.now(),
      'startDate': '2025-01-15',
      'typeOfWork': 'Commercial',
    };
  }

  static Map<String, dynamic> createLocalData({
    int? localNumber,
    String? name,
    String? address,
    String? phone,
    List<String>? classifications,
  }) {
    return {
      'localNumber': localNumber ?? 123,
      'name': name ?? 'IBEW Local 123',
      'address': address ?? '123 Union St, Test City, TS 12345',
      'phone': phone ?? '(555) 123-4567',
      'classifications': classifications ??
          ['Inside Wireman', 'Journeyman Lineman', 'Low Voltage Technician'],
      'state': 'TS',
      'website': 'https://local123.ibew.org',
    };
  }

  static Map<String, dynamic> createUserData({
    String? uid,
    String? email,
    String? displayName,
    int? localNumber,
    String? classification,
  }) {
    return {
      'uid': uid ?? 'test-user-id',
      'email': email ?? 'test@example.com',
      'display_name': displayName ?? 'Test User',
      'local_number': localNumber ?? 123,
      'classification': classification ?? 'Inside Wireman',
      'created_time': DateTime.now(),
      'certifications': ['OSHA 30', 'First Aid/CPR'],
      'years_experience': 5,
      'preferred_distance': 50,
    };
  }

  /// Create electrical industry test data for IBEW locals
  static List<Map<String, dynamic>> createIBEWLocalsData() {
    return [
      createLocalData(localNumber: 1, name: 'IBEW Local 1 - St. Louis'),
      createLocalData(localNumber: 3, name: 'IBEW Local 3 - New York'),
      createLocalData(localNumber: 11, name: 'IBEW Local 11 - Los Angeles'),
      createLocalData(localNumber: 26, name: 'IBEW Local 26 - Washington DC'),
      createLocalData(localNumber: 46, name: 'IBEW Local 46 - Seattle'),
      createLocalData(localNumber: 58, name: 'IBEW Local 58 - Detroit'),
      createLocalData(localNumber: 98, name: 'IBEW Local 98 - Philadelphia'),
      createLocalData(localNumber: 134, name: 'IBEW Local 134 - Chicago'),
    ];
  }

  /// Create job test data with electrical classifications
  static List<Map<String, dynamic>> createElectricalJobsData() {
    return [
      createJobData(
        classification: 'Inside Wireman',
        company: 'Elite Electric',
        wage: 45.50,
        local: 3,
      ),
      createJobData(
        classification: 'Journeyman Lineman',
        company: 'Power Grid Solutions',
        wage: 52.75,
        local: 11,
      ),
      createJobData(
        classification: 'Low Voltage Technician',
        company: 'Security Systems Inc',
        wage: 38.25,
        local: 26,
      ),
      createJobData(
        classification: 'Sound Technician',
        company: 'AV Solutions',
        wage: 41.00,
        local: 46,
      ),
    ];
  }
}

/// Custom matchers for electrical industry widgets
class ElectricalMatchers {
  /// Matcher for finding loading indicators
  static ft.Finder get loadingIndicator => ft.find.byType(material.CircularProgressIndicator);

  /// Matcher for finding error messages
  static ft.Finder errorMessage(String message) {
    return ft.find.textContaining(message);
  }

  /// Matcher for job cards
  static ft.Finder get jobCard => ft.find.byKey(const material.Key('job-card'));

  /// Matcher for local cards
  static ft.Finder get localCard => ft.find.byKey(const material.Key('local-card'));

  /// Matcher for circuit breaker switch
  static ft.Finder get circuitBreakerSwitch => ft.find.byKey(const material.Key('circuit-breaker-switch'));
}

/// Extension for common widget test actions
extension WidgetTesterExtensions on ft.WidgetTester {
  /// Enter text and pump
  Future<void> enterTextAndPump(ft.Finder finder, String text) async {
    await enterText(finder, text);
    await pump();
  }

  /// Tap and pump with settle
  Future<void> tapAndSettle(ft.Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Scroll until visible and tap
  Future<void> scrollUntilVisibleAndTap(
    ft.Finder finder, {
    double delta = 300,
    int maxScrolls = 10,
    ft.Finder? scrollable,
  }) async {
    await ft.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
      maxScrolls: maxScrolls,
    );
    await tap(finder);
    await pumpAndSettle();
  }

  /// Send keyboard key event
  Future<void> sendKeyEvent(ft.LogicalKeyboardKey key) async {
    await sendKeyDownEvent(key);
    await sendKeyUpEvent(key);
    await pump();
  }
}

/// Test setup helpers for electrical industry scenarios
class ElectricalTestSetup {
  /// Setup test environment with electrical industry data
  static Future<TestResilientFirestoreService> setupElectricalTestData() async {
    final firestoreService = TestResilientFirestoreService();
    await firestoreService.seedTestData();
    
    // Add additional electrical industry specific data
    for (final jobData in TestFixtures.createElectricalJobsData()) {
      await firestoreService._firestore.collection('jobs').add(jobData);
    }
    
    for (final localData in TestFixtures.createIBEWLocalsData()) {
      await firestoreService._firestore.collection('locals').add(localData);
    }
    
    return firestoreService;
  }
}
