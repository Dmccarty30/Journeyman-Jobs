import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/storm_roster_signup.dart';

class RosterDataService {
  // Singleton pattern
  static final RosterDataService _instance = RosterDataService._internal();
  factory RosterDataService() => _instance;
  RosterDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RosterContractor>? _rosterData;

  /// Load roster contractor data from Firestore
  /// Expects data to be pre-formatted and stored in 'roster_contractors' collection
  Future<List<RosterContractor>> loadRosterData() async {
    if (_rosterData != null) {
      return _rosterData!;
    }

    try {
      // Load pre-formatted roster data from Firestore
      final QuerySnapshot snapshot = await _firestore
          .collection('roster_contractors')
          .orderBy('companyName')
          .get();

      _rosterData = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RosterContractor.fromMap(data);
      }).toList();

      return _rosterData!;
    } catch (e) {
      // Handle potential errors during Firestore loading
      print('Error loading roster data from Firestore: $e');
      _rosterData = [];
      return _rosterData!;
    }
  }

  /// Clear cached data to force refresh from Firestore
  void clearCache() {
    _rosterData = null;
  }

  /// Add or update a roster contractor
  Future<void> saveRosterContractor(RosterContractor contractor) async {
    try {
      await _firestore
          .collection('roster_contractors')
          .doc(contractor.companyName.replaceAll(' ', '_').toLowerCase())
          .set(contractor.toMap());

      // Clear cache to force refresh
      clearCache();
    } catch (e) {
      print('Error saving roster contractor: $e');
      rethrow;
    }
  }

  /// Delete a roster contractor
  Future<void> deleteRosterContractor(String companyName) async {
    try {
      await _firestore
          .collection('roster_contractors')
          .doc(companyName.replaceAll(' ', '_').toLowerCase())
          .delete();

      // Clear cache to force refresh
      clearCache();
    } catch (e) {
      print('Error deleting roster contractor: $e');
      rethrow;
    }
  }
}
