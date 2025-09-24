import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crew_preferences.dart';

class CrewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCrew({
    required String id,
    required String name,
    required String foremanId,
    required CrewPreferences preferences,
  }) async {
    await _firestore.collection('crews').doc(id).set({
      'id': id,
      'name': name,
      'foremanId': foremanId,
      'preferences': preferences.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}