/// Mock services for testing Firebase operations
/// 
/// Provides mocked versions of Firebase services to enable
/// isolated unit testing without Firebase dependencies.

import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/onboarding_service.dart';

/// Mock Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Mock Firebase User
class MockUser extends Mock implements User {}

/// Mock UserCredential
class MockUserCredential extends Mock implements UserCredential {}

/// Mock Firebase Auth Exception
class MockFirebaseAuthException extends Mock implements FirebaseAuthException {}

/// Mock Cloud Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Mock Collection Reference
class MockCollectionReference extends Mock implements CollectionReference {}

/// Mock Document Reference
class MockDocumentReference extends Mock implements DocumentReference {}

/// Mock Document Snapshot
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

/// Mock Query Snapshot
class MockQuerySnapshot extends Mock implements QuerySnapshot {}

/// Mock Query Document Snapshot
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

/// Mock Google Sign In
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

/// Mock Google Sign In Account
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

/// Mock Google Sign In Authentication
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

/// Mock Auth Service
class MockAuthService extends Mock implements AuthService {}

/// Mock Firestore Service
class MockFirestoreService extends Mock implements FirestoreService {}

/// Mock Onboarding Service
class MockOnboardingService extends Mock implements OnboardingService {}

/// Factory class for creating configured mocks
class MockFactory {
  /// Create a mock AuthService with default behavior
  static MockAuthService createMockAuthService({
    User? currentUser,
    Stream<User?>? authStateChanges,
  }) {
    final mockAuthService = MockAuthService();
    
    when(() => mockAuthService.currentUser).thenReturn(currentUser);
    when(() => mockAuthService.authStateChanges).thenAnswer(
      (_) => authStateChanges ?? Stream.value(currentUser),
    );
    
    return mockAuthService;
  }

  /// Create a mock FirestoreService with default behavior
  static MockFirestoreService createMockFirestoreService() {
    final mockFirestoreService = MockFirestoreService();
    
    // Default successful operations
    when(() => mockFirestoreService.createUser(
      uid: any(named: 'uid'),
      userData: any(named: 'userData'),
    )).thenAnswer((_) async => {});
    
    when(() => mockFirestoreService.updateUser(
      uid: any(named: 'uid'),
      data: any(named: 'data'),
    )).thenAnswer((_) async => {});
    
    return mockFirestoreService;
  }

  /// Create a mock User with test data
  static MockUser createMockUser({
    String uid = 'test_uid',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
  }) {
    final mockUser = MockUser();
    
    when(() => mockUser.uid).thenReturn(uid);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockUser.displayName).thenReturn(displayName);
    
    return mockUser;
  }

  /// Create a mock DocumentSnapshot with test data
  static MockDocumentSnapshot createMockDocumentSnapshot({
    String id = 'test_doc',
    Map<String, dynamic>? data,
    bool exists = true,
  }) {
    final mockDoc = MockDocumentSnapshot();
    
    when(() => mockDoc.id).thenReturn(id);
    when(() => mockDoc.data()).thenReturn(data);
    when(() => mockDoc.exists).thenReturn(exists);
    
    return mockDoc;
  }

  /// Create a mock QuerySnapshot with test documents
  static MockQuerySnapshot createMockQuerySnapshot({
    List<QueryDocumentSnapshot>? docs,
  }) {
    final mockQuery = MockQuerySnapshot();
    
    when(() => mockQuery.docs).thenReturn(docs ?? []);
    when(() => mockQuery.size).thenReturn(docs?.length ?? 0);
    
    return mockQuery;
  }

  /// Create a mock QueryDocumentSnapshot
  static MockQueryDocumentSnapshot createMockQueryDocumentSnapshot({
    String id = 'test_doc',
    Map<String, dynamic>? data,
  }) {
    final mockDoc = MockQueryDocumentSnapshot();
    
    when(() => mockDoc.id).thenReturn(id);
    when(() => mockDoc.data()).thenReturn(data ?? {});
    
    return mockDoc;
  }
}

/// Mock setup helpers for common test scenarios
class MockSetupHelpers {
  /// Setup successful authentication flow
  static void setupSuccessfulAuth(MockAuthService mockAuthService) {
    final mockUser = MockFactory.createMockUser();
    final mockCredential = MockUserCredential();
    
    when(() => mockCredential.user).thenReturn(mockUser);
    
    when(() => mockAuthService.signInWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => mockCredential);
    
    when(() => mockAuthService.signUpWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => mockCredential);
    
    when(() => mockAuthService.signInWithGoogle())
        .thenAnswer((_) async => mockCredential);
  }

  /// Setup authentication failure
  static void setupAuthFailure(MockAuthService mockAuthService) {
    when(() => mockAuthService.signInWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenThrow(Exception('Authentication failed'));
  }

  /// Setup successful Firestore operations
  static void setupSuccessfulFirestore(MockFirestoreService mockFirestoreService) {
    // User operations
    when(() => mockFirestoreService.createUser(
      uid: any(named: 'uid'),
      userData: any(named: 'userData'),
    )).thenAnswer((_) async => {});
    
    when(() => mockFirestoreService.getUser(any()))
        .thenAnswer((_) async => MockFactory.createMockDocumentSnapshot(
          data: {'uid': 'test_uid', 'firstName': 'Test', 'lastName': 'User'},
        ));
    
    // Jobs operations
    when(() => mockFirestoreService.getJobs()).thenAnswer(
      (_) => Stream.value(MockFactory.createMockQuerySnapshot()),
    );
    
    // Locals operations
    when(() => mockFirestoreService.getLocals()).thenAnswer(
      (_) => Stream.value(MockFactory.createMockQuerySnapshot()),
    );
  }

  /// Setup Firestore failures
  static void setupFirestoreFailure(MockFirestoreService mockFirestoreService) {
    when(() => mockFirestoreService.createUser(
      uid: any(named: 'uid'),
      userData: any(named: 'userData'),
    )).thenThrow(Exception('Firestore error'));
  }

  /// Setup onboarding service
  static void setupOnboardingService(MockOnboardingService mockOnboardingService) {
    when(() => mockOnboardingService.isOnboardingComplete())
        .thenAnswer((_) async => false);
    
    when(() => mockOnboardingService.markOnboardingComplete())
        .thenAnswer((_) async => {});
  }
}