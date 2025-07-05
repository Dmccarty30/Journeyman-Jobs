import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  String? get userId => _user?.uid;
  
  // Constructor
  AuthProvider() {
    _init();
  }
  
  // Initialize auth state listener
  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }
  
  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential?.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(
          userId: credential!.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
        
        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        _user = credential.user;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential?.user != null) {
        _user = credential!.user;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.signInWithGoogle();
      
      if (credential?.user != null) {
        _user = credential!.user;
        
        // Check if user profile exists, if not create one
        await _ensureUserProfile(credential.user!);
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.signInWithApple();
      
      if (credential?.user != null) {
        _user = credential!.user;
        
        // Check if user profile exists, if not create one
        await _ensureUserProfile(credential.user!);
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Send password reset email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _user?.uid;
      
      if (userId != null) {
        // Delete user data from Firestore first
        await _firestoreService.deleteUserData(userId);
      }
      
      // Delete Firebase Auth account
      await _authService.deleteAccount();
      
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update email
  Future<bool> updateEmail({required String newEmail}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.updateEmail(newEmail: newEmail);
      
      // Update email in Firestore
      if (_user != null) {
        await _firestoreService.updateUserEmail(_user!.uid, newEmail);
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update password
  Future<bool> updatePassword({required String newPassword}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.updatePassword(newPassword: newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Clear error
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  // Create user profile in Firestore
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    await _firestoreService.createUserProfile(
      userId: userId,
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'createdTime': DateTime.now(),
        'onboardingStatus': 'not_started',
      },
    );
  }
  
  // Ensure user profile exists (for social login)
  Future<void> _ensureUserProfile(User user) async {
    final profileExists = await _firestoreService.userProfileExists(user.uid);
    
    if (!profileExists) {
      // Extract names from display name
      final names = user.displayName?.split(' ') ?? [];
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
      
      await _createUserProfile(
        userId: user.uid,
        email: user.email ?? '',
        firstName: firstName,
        lastName: lastName,
      );
    }
  }
}
