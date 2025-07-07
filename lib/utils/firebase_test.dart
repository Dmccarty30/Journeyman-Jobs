import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTest {
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance
          .collection('test')
          .doc('test')
          .get();
      
      debugPrint('Firestore connection: SUCCESS');

      // Test Auth service
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('Firebase Auth initialized: SUCCESS');
      debugPrint('Current user: ${currentUser?.email ?? 'No user signed in'}');
      
      return true;
    } catch (e) {
      debugPrint('Firebase connection error: $e');
      return false;
    }
  }
}
