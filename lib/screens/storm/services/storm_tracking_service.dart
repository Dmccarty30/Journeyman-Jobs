import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/storm_track.dart';

class StormTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _getStormTracksCollection() {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('storm_tracks');
  }

  Future<void> addStormTrack(StormTrack track) async {
    final collection = _getStormTracksCollection();
    final docRef = collection.doc(); // Generate ID
    final newTrack = track.copyWith(id: docRef.id, userId: _userId);
    await docRef.set(newTrack.toMap());
  }

  Future<void> updateStormTrack(StormTrack track) async {
    final collection = _getStormTracksCollection();
    await collection.doc(track.id).update(track.toMap());
  }

  Future<void> deleteStormTrack(String id) async {
    final collection = _getStormTracksCollection();
    await collection.doc(id).delete();
  }

  Stream<List<StormTrack>> getStormTracks() {
    if (_userId == null) return Stream.value([]);

    return _getStormTracksCollection()
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StormTrack.fromMap(doc.data()))
          .toList();
    });
  }

  Future<Map<String, dynamic>> getStormStats() async {
    if (_userId == null) return {};

    final snapshot = await _getStormTracksCollection().get();
    final tracks =
        snapshot.docs.map((doc) => StormTrack.fromMap(doc.data())).toList();

    double totalEarnings = 0;
    double totalHours = 0;
    int totalDays = 0;

    for (var track in tracks) {
      // Calculate earnings (simplified: hours * rate + per diem * days)
      // Assuming per diem is paid daily for the duration
      final duration = track.endDate?.difference(track.startDate).inDays ?? 0;
      final days =
          duration > 0 ? duration : 1; // At least 1 day if active or same day

      totalHours += track.hoursWorked;
      totalEarnings +=
          (track.hoursWorked * track.payRate) + (days * track.perDiem);
      totalDays += days;
    }

    return {
      'totalEarnings': totalEarnings,
      'totalHours': totalHours,
      'totalDays': totalDays,
      'stormCount': tracks.length,
    };
  }
}
