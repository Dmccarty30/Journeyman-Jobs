import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

/// Test utilities for IBEW Journeyman Jobs app testing
class TestHelpers {
  
  /// Creates a mock Firebase user for testing
  static MockUser createMockUser({
    String uid = 'test-uid-123',
    String email = 'test@ibew26.org',
    String? displayName = 'Test Journeyman',
    bool isEmailVerified = true,
  }) {
    return MockUser(
      uid: uid,
      email: email,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
    );
  }

  /// Creates a mock user credential for testing
  static MockUserCredential createMockUserCredential({
    String uid = 'test-uid-123',
    String email = 'test@ibew26.org',
  }) {
    final user = createMockUser(uid: uid, email: email);
    return MockUserCredential(user: user);
  }

  /// Creates a configured MockFirebaseAuth instance
  static MockFirebaseAuth createMockFirebaseAuth({
    bool signedIn = false,
    MockUser? mockUser,
  }) {
    final user = mockUser ?? createMockUser();
    
    return MockFirebaseAuth(
      signedIn: signedIn,
      mockUser: user,
    );
  }

  /// Test wrapper widget with basic material app setup
  static Widget createTestWrapper({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

/// Auth exception configurations for testing
class AuthExceptionConfig {
  static const String invalidEmail = 'invalid-email';
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String weakPassword = 'weak-password';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String networkRequestFailed = 'network-request-failed';
}