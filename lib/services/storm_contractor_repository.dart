import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/storm_contractor.dart';

class StormContractorRepository {
  final FirebaseFirestore _firestore;

  StormContractorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('storm contractors');

  Future<List<StormContractor>> fetchAll() async {
    final snap = await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => StormContractor.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  Stream<List<StormContractor>> streamAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StormContractor.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> create(StormContractor contractor) async {
    final data = contractor.toMap();
    await _collection.add(data);
  }

  Future<void> update(StormContractor contractor) async {
    await _collection.doc(contractor.id).set(contractor.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}