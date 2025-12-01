import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contractor_model.dart';

class ContractorService {
  static const String _collection = 'contractors';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all contractors from Firestore, ordered by company name.
  Future<List<Contractor>> getAllContractors() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('company')
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Contractor.fromJson(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error fetching contractors: $e');
      return [];
    }
  }

  /// Searches contractors by company name (prefix search).
  Future<List<Contractor>> searchContractors(String query) async {
    if (query.isEmpty) {
      return getAllContractors();
    }
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('company', isGreaterThanOrEqualTo: query)
          .where('company', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('company')
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Contractor.fromJson(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error searching contractors: $e');
      return [];
    }
  }

  /// Gets a specific contractor by ID.
  Future<Contractor?> getContractorById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Contractor.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching contractor by ID: $e');
      return null;
    }
  }

  /// Provides a real-time stream of all contractors, ordered by company name.
  Stream<List<Contractor>> contractorsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('company')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Contractor.fromJson(data);
            })
            .toList());
  }
}