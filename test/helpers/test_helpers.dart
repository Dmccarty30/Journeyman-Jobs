import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/providers/app_state_provider.dart';
import 'package:journeyman_jobs/providers/job_filter_provider.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Manual mock implementations for complex providers
class TestAuthService extends Mock implements AuthService {
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

class TestResilientFirestoreService extends Mock implements ResilientFirestoreService {
  @override
  Future<QuerySnapshot> searchLocals(String searchQuery, {int limit = 20, DocumentSnapshot? startAfter, String? state}) async {
    return await _firestore
        .collection('locals')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchQuery + '\uf8ff')
        .limit(limit)
        .get();
  }
}
  final FakeFirebaseFirestore _firestore = FakeFirebaseFirestore();

  @override
  Stream<QuerySnapshot> getJobs({
    Map<String, dynamic>? filters,
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) {
    Query query = _firestore.collection('jobs');
    
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
  Stream<QuerySnapshot> getLocals({
    String? state,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    Query query = _firestore.collection('locals');
    
    if (state != null) {
      query = query.where('state', isEqualTo: state);
    }
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    return query.limit(limit).snapshots();
  }

  @override
  Future<QuerySnapshot> searchLocals(String searchQuery, {int limit = 20, DocumentSnapshot? startAfter}) async {
    String searchQuery, {
    int limit = 20,
  }) async {
    return await _firestore
        .collection('locals')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchQuery + '\uf8ff')
        .limit(limit)
        .get();
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

class TestConnectivityService extends Mock implements ConnectivityService {
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

/// Base test widget wrapper with all necessary providers
class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final AuthService? authService;
  final ResilientFirestoreService? firestoreService;
  final ConnectivityService? connectivityService;
  final AppStateProvider? appStateProvider;
  final JobFilterProvider? jobFilterProvider;

  const TestAppWrapper({
    Key? key,
    required this.child,
    this.authService,
    this.firestoreService,
    this.connectivityService,
    this.appStateProvider,
    this.jobFilterProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService ?? TestAuthService(),
        ),
        Provider<ResilientFirestoreService>(
          create: (_) => firestoreService ?? TestResilientFirestoreService(),
        ),
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => connectivityService ?? TestConnectivityService(),
        ),
        ChangeNotifierProvider<JobFilterProvider>(
          create: (_) => jobFilterProvider ?? JobFilterProvider(),
        ),
        ChangeNotifierProxyProvider3<AuthService, ResilientFirestoreService,
            ConnectivityService, AppStateProvider>(
          create: (context) =>
              appStateProvider ??
              AppStateProvider(
                context.read<AuthService>(),
                context.read<ResilientFirestoreService>(),
                context.read<ConnectivityService>(),
              ),
          update: (context, authService, firestoreService, connectivityService,
                  previous) =>
              previous ??
              AppStateProvider(
                authService,
                firestoreService,
                connectivityService,
              ),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

/// Create a widget test environment with mocked dependencies
Widget createTestWidget(
  Widget widget, {
  AuthService? authService,
  ResilientFirestoreService? firestoreService,
  ConnectivityService? connectivityService,
  AppStateProvider? appStateProvider,
  JobFilterProvider? jobFilterProvider,
}) {
  return TestAppWrapper(
    child: widget,
    authService: authService,
    firestoreService: firestoreService,
    connectivityService: connectivityService,
    appStateProvider: appStateProvider,
    jobFilterProvider: jobFilterProvider,
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
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

/// Find widgets by key string
Finder findByKeyString(String key) {
  return find.byKey(Key(key));
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
  static Finder get loadingIndicator => find.byType(CircularProgressIndicator);

  /// Matcher for finding error messages
  static Finder errorMessage(String message) {
    return find.textContaining(message);
  }

  /// Matcher for job cards
  static Finder get jobCard => find.byKey(const Key('job-card'));

  /// Matcher for local cards
  static Finder get localCard => find.byKey(const Key('local-card'));

  /// Matcher for circuit breaker switch
  static Finder get circuitBreakerSwitch => find.byKey(const Key('circuit-breaker-switch'));
}

/// Extension for common widget test actions
extension WidgetTesterExtensions on WidgetTester {
  /// Enter text and pump
  Future<void> enterTextAndPump(Finder finder, String text) async {
    await enterText(finder, text);
    await pump();
  }

  /// Tap and pump with settle
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Scroll until visible and tap
  Future<void> scrollUntilVisibleAndTap(
    Finder finder, {
    double delta = 300,
    int maxScrolls = 10,
    Finder? scrollable,
  }) async {
    await scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
      maxScrolls: maxScrolls,
    );
    await tap(finder);
    await pumpAndSettle();
  }

  /// Send keyboard key event
  Future<void> sendKeyEvent(LogicalKeyboardKey key) async {
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