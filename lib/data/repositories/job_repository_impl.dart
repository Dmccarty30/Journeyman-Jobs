import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_repository.dart';
import '../../models/job_model.dart';

class JobRepositoryImpl implements JobRepository {
  final FirebaseFirestore firestore;

  JobRepositoryImpl({required this.firestore});

  @override
  Future<List<Job>> fetchJobs() async {
    try {
      final snapshot = await firestore
          .collection('jobs')
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  @override
  Future<Job?> getJobById(String id) async {
    try {
      final doc = await firestore.collection('jobs').doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return Job.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get job by ID: $e');
    }
  }

  @override
  Future<void> addJob(Job job) async {
    try {
      await firestore.collection('jobs').add(job.toFirestore());
    } catch (e) {
      throw Exception('Failed to add job: $e');
    }
  }

  @override
  Future<void> updateJob(Job job) async {
    try {
      await firestore.collection('jobs').doc(job.id).update(job.toFirestore());
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }

  @override
  Future<void> deleteJob(String id) async {
    try {
      await firestore.collection('jobs').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }
}
