import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// A service that manages user authentication using Firebase Auth.
///
/// Provides methods for signing up, signing in, signing out, and managing
/// user accounts with various providers like email/password, Google, and Apple.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  // Initialize Google Sign-In
  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
  }

  // Ensure Google Sign-In is initialized
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  /// Returns the currently signed-in user, or `null` if none exists.
  User? get currentUser => _auth.currentUser;

  /// A stream that emits the currently signed-in user when the auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Creates a new user account with the given [email] and [password].
  ///
  /// Returns a `Future<UserCredential?>` containing the user's credential
  /// upon successful registration. Throws a `FirebaseAuthException` on failure.
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in a user with the given [email] and [password].
  ///
  /// Returns a `Future<UserCredential?>` containing the user's credential
  /// upon successful sign-in. Throws a `FirebaseAuthException` on failure.
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in a user using their Google account.
  ///
  /// Initiates the Google Sign-In flow and uses the resulting token to
  /// authenticate with Firebase. Returns a `Future<UserCredential?>` on success.
  /// Throws an exception if the process fails or is cancelled.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure Google Sign-In is initialized
      await _ensureGoogleSignInInitialized();

      // Check if authenticate is supported
      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError('Google Sign-In not supported on this platform');
      }

      // Trigger the authentication flow with v7 API
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // Get authorization client for accessing tokens
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In error: ${e.code.name} - ${e.description}');
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in a user using their Apple ID.
  ///
  /// This method is only available on Apple devices. It initiates the
  /// Sign in with Apple flow and uses the resulting credential to authenticate
  /// with Firebase. Returns a `Future<UserCredential?>` on success.
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential from the credential returned by Apple
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      return await _auth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sends a password reset email to the specified [email] address.
  ///
  /// Throws a `FirebaseAuthException` if the email is not valid or does not
  /// exist in the system.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs out the current user from Firebase and any third-party providers.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Deletes the current user's account permanently.
  ///
  /// This action is irreversible and requires the user to have recently signed in.
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Updates the current user's email address.
  ///
  /// Firebase will send a verification email to the [newEmail] address.
  /// The email change will only complete after the user verifies the new address.
  Future<void> updateEmail({required String newEmail}) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Updates the current user's password.
  ///
  /// The user must have signed in recently for this operation to succeed.
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Handles `FirebaseAuthException` and returns a user-friendly error message.
  ///
  /// - [e]: The `FirebaseAuthException` to handle.
  ///
  /// Returns a `String` containing the appropriate error message.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'The supplied credential is invalid.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
