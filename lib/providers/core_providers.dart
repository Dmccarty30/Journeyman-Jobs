import 'package:riverpod/riverpod.dart';

class ConnectivityService {
  // Shim: mock connectivity checks for now
  Future<bool> get isConnected async => true;
  Stream<bool> get connectivityStream => Stream.value(true);
}

class FirestoreService {
  // Shim: mock Firestore operations
  Future<void> addJob(dynamic job) async {}
  Future<void> updateJob(dynamic job) async {}
}

class AuthService {
  // Shim for auth
  String? get currentUserId => 'mock_user';
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
