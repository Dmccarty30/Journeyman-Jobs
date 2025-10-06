import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contractor_model.dart';

/// A service for interacting with the `contractors` collection in Firestore.
///
/// Provides methods to fetch, search, and stream contractor data.
class ContractorService {
  static const String _collection = 'contractors';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all contractors from Firestore, ordered by company name.
  ///
  /// Returns a `Future<List<Contractor>>`. If an error occurs, it returns an empty list.
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

  /// Searches for contractors by company name using a prefix search.
  ///
  /// - [query]: The search string to match against the beginning of company names.
  ///
  /// If the [query] is empty, it returns all contractors.
  /// Returns a `Future<List<Contractor>>` with matching results, or an empty list on error.
  Future<List<Contractor>> searchContractors(String query) async {
    if (query.isEmpty) {
      return getAllContractors();
    }
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('company', isGreaterThanOrEqualTo: query)
          .where('company', isLessThanOrEqualTo: query + '\uf8ff')
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

  /// Retrieves a specific contractor by their document ID.
  ///
  /// - [id]: The unique ID of the contractor document in Firestore.
  ///
  /// Returns a `Future<Contractor?>` which is the contractor object if found, otherwise `null`.
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
  ///
  /// This is useful for UIs that need to update automatically when contractor data changes.
  ///
  /// Returns a `Stream<List<Contractor>>`.
  Stream<List<Contractor>> contractorsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('company')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return Contractor.fromJson(data);
            })
            .toList());
  }
}