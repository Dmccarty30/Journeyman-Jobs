import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTest {
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      final testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc('test')
          .get();
      
      print('Firestore connection: SUCCESS');
      
      // Test Auth service
      final currentUser = FirebaseAuth.instance.currentUser;
      print('Firebase Auth initialized: SUCCESS');
      print('Current user: ${currentUser?.email ?? 'No user signed in'}');
      
      return true;
    } catch (e) {
      print('Firebase connection error: $e');
      return false;
    }
  }
}
