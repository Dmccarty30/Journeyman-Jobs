import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/concurrent_operations.dart';

/// Provider responsible for authentication state management
/// 
/// Features:
/// - User authentication state tracking
/// - Sign in/out operations with loading states
/// - Error handling and recovery
/// - Concurrent operation management
/// - Performance monitoring
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ConcurrentOperationManager _operationManager = ConcurrentOperationManager();

  // Authentication state
  User? _user;
  bool _isLoadingAuth = false;
  String? _authError;
  
  // Subscription management
  StreamSubscription<User?>? _authSubscription;
  
  // Performance metrics
  DateTime? _lastSignInTime;
  Duration? _lastSignInDuration;
  int _signInAttempts = 0;
  int _successfulSignIns = 0;

  // Getters
  User? get user => _user;
  bool get isLoadingAuth => _isLoadingAuth;
  String? get authError => _authError;
  bool get isAuthenticated => _user != null;
  
  // Performance getters
  Duration? get lastSignInDuration => _lastSignInDuration;
  double get signInSuccessRate => _signInAttempts > 0 ? _successfulSignIns / _signInAttempts : 0.0;

  AuthProvider(this._authService) {
    _initializeAuthListener();
  }

  /// Initialize authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChange,
      onError: _handleAuthError,
    );
    
    if (kDebugMode) {
      print('AuthProvider: Initialized authentication listener');
    }
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(User? user) {
    final wasAuthenticated = _user != null;
    _user = user;
    _authError = null;
    
    if (kDebugMode) {
      print('AuthProvider: Auth state changed - User: ${user?.uid}');
    }
    
    // Track performance metrics
    if (user != null && !wasAuthenticated) {
      _successfulSignIns++;
      _lastSignInTime = DateTime.now();
    }
    
    notifyListeners();
  }

  /// Handle authentication errors
  void _handleAuthError(dynamic error) {
    _authError = error.toString();
    _isLoadingAuth = false;
    
    if (kDebugMode) {
      print('AuthProvider: Auth error - $error');
    }
    
    notifyListeners();
  }

  /// Sign in with email and password
  ///
  /// Authenticates a user using their email and password credentials.
  /// Uses transaction-based state management to ensure atomic updates.
  ///
  /// **Parameters:**
  /// - [email]: User's email address (must be valid email format)
  /// - [password]: User's password (minimum length enforced by Firebase)
  ///
  /// **Returns:**
  /// - `true` if sign-in was successful
  /// - `false` if sign-in failed
  ///
  /// **Performance Tracking:**
  /// - Records sign-in attempts and success rate
  /// - Measures sign-in duration for performance monitoring
  /// - Updates performance metrics accessible via [signInSuccessRate]
  ///
  /// **State Updates:**
  /// - Sets [isLoadingAuth] to `true` during operation
  /// - Clears [authError] on successful authentication
  /// - Updates [user] with authenticated user data
  ///
  /// **Example:**
  /// ```dart
  /// final success = await authProvider.signInWithEmailAndPassword(
  ///   'user@example.com',
  ///   'securePassword123'
  /// );
  /// if (success) {
  ///   print('User signed in: ${authProvider.user?.email}');
  /// } else {
  ///   print('Sign-in failed: ${authProvider.authError}');
  /// }
  /// ```
  ///
  /// **Throws:**
  /// - May throw authentication exceptions that are handled internally
  ///   and exposed via [authError]
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    return _operationManager.queueOperation<bool>(
      type: OperationType.signIn,
      parameters: {'email': email, 'password': password},
      operation: () async {
        final startTime = DateTime.now();
        _signInAttempts++;
        
        final transactionId = await _operationManager.startTransaction({
          'isLoadingAuth': _isLoadingAuth,
          'authError': _authError,
        });

        try {
          _operationManager.addTransactionChange(transactionId, 'isLoadingAuth', true);
          _operationManager.addTransactionChange(transactionId, 'authError', null);
          
          final finalState = await _operationManager.commitTransaction(transactionId);
          _isLoadingAuth = finalState['isLoadingAuth'];
          _authError = finalState['authError'];
          notifyListeners();

          await _authService.signInWithEmailAndPassword(email: email, password: password);
          
          // Calculate sign-in duration
          _lastSignInDuration = DateTime.now().difference(startTime);
          
          if (kDebugMode) {
            print('AuthProvider: Sign-in successful in ${_lastSignInDuration?.inMilliseconds}ms');
          }
          
          return true;
        } catch (e) {
          await _operationManager.rollbackTransaction(transactionId);
          _authError = e.toString();
          _isLoadingAuth = false;
          
          if (kDebugMode) {
            print('AuthProvider: Sign-in failed - $e');
          }
          
          notifyListeners();
          return false;
        }
      },
    );
  }

  /// Sign up with email and password
  ///
  /// Creates a new user account using email and password credentials.
  /// Uses the same transaction-based state management as sign-in for consistency.
  ///
  /// **Parameters:**
  /// - [email]: User's email address (must be unique and valid format)
  /// - [password]: User's password (must meet Firebase security requirements)
  ///
  /// **Returns:**
  /// - `true` if account creation was successful
  /// - `false` if sign-up failed
  ///
  /// **Performance Tracking:**
  /// - Records sign-up attempts under sign-in metrics for unified tracking
  /// - Measures account creation duration
  /// - Updates success rate statistics
  ///
  /// **State Updates:**
  /// - Sets [isLoadingAuth] to `true` during operation
  /// - Clears [authError] on successful account creation
  /// - Automatically signs in the user upon successful registration
  ///
  /// **Example:**
  /// ```dart
  /// final success = await authProvider.signUpWithEmailAndPassword(
  ///   'newuser@example.com',
  ///   'strongPassword123!'
  /// );
  /// if (success) {
  ///   print('Account created and user signed in');
  /// } else {
  ///   print('Sign-up failed: ${authProvider.authError}');
  /// }
  /// ```
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    return _operationManager.queueOperation<bool>(
      type: OperationType.signIn, // Use signIn type as it's similar operation
      parameters: {'email': email, 'password': password, 'isSignUp': true},
      operation: () async {
        final startTime = DateTime.now();
        _signInAttempts++;
        
        final transactionId = await _operationManager.startTransaction({
          'isLoadingAuth': _isLoadingAuth,
          'authError': _authError,
        });

        try {
          _operationManager.addTransactionChange(transactionId, 'isLoadingAuth', true);
          _operationManager.addTransactionChange(transactionId, 'authError', null);
          
          final finalState = await _operationManager.commitTransaction(transactionId);
          _isLoadingAuth = finalState['isLoadingAuth'];
          _authError = finalState['authError'];
          notifyListeners();

          await _authService.signUpWithEmailAndPassword(email: email, password: password);
          
          // Calculate sign-up duration
          _lastSignInDuration = DateTime.now().difference(startTime);
          
          if (kDebugMode) {
            print('AuthProvider: Sign-up successful in ${_lastSignInDuration?.inMilliseconds}ms');
          }
          
          return true;
        } catch (e) {
          await _operationManager.rollbackTransaction(transactionId);
          _authError = e.toString();
          _isLoadingAuth = false;
          
          if (kDebugMode) {
            print('AuthProvider: Sign-up failed - $e');
          }
          
          notifyListeners();
          return false;
        }
      },
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      
      if (kDebugMode) {
        print('AuthProvider: User signed out successfully');
      }
    } catch (e) {
      _authError = e.toString();
      
      if (kDebugMode) {
        print('AuthProvider: Error signing out - $e');
      }
      
      notifyListeners();
    }
  }

  /// Reset authentication error
  void clearAuthError() {
    if (_authError != null) {
      _authError = null;
      notifyListeners();
    }
  }

  /// Get authentication performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'signInAttempts': _signInAttempts,
      'successfulSignIns': _successfulSignIns,
      'signInSuccessRate': signInSuccessRate,
      'lastSignInDuration': _lastSignInDuration?.inMilliseconds,
      'lastSignInTime': _lastSignInTime?.toIso8601String(),
      'isCurrentlyLoading': _isLoadingAuth,
      'hasActiveError': _authError != null,
      'operationStats': _operationManager.getOperationStats(),
    };
  }

  /// Get current authentication state summary
  Map<String, dynamic> getStateSnapshot() {
    return {
      'isAuthenticated': isAuthenticated,
      'userId': _user?.uid,
      'userEmail': _user?.email,
      'isLoading': _isLoadingAuth,
      'hasError': _authError != null,
      'errorMessage': _authError,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (_user != null) {
      try {
        await _user!.reload();
        // The auth state listener will handle the update
        
        if (kDebugMode) {
          print('AuthProvider: User data refreshed');
        }
      } catch (e) {
        if (kDebugMode) {
          print('AuthProvider: Error refreshing user data - $e');
        }
      }
    }
  }

  @override
  void dispose() {
    // Cancel authentication subscription
    _authSubscription?.cancel();
    
    // Dispose operation manager
    _operationManager.dispose();
    
    if (kDebugMode) {
      print('AuthProvider: Disposed with ${getPerformanceMetrics()}');
    }
    
    super.dispose();
  }
}
