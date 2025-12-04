import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
import '../../services/user_preference_service.dart';
import '../../services/resilient_firestore_service.dart'; // Assuming this is where job fetching logic resides

part 'user_job_preference_query_provider.g.dart';

// Provides the UserPreferenceService
@Riverpod(keepAlive: true)
UserPreferenceService userPreferenceService(Ref ref) => UserPreferenceService();

// Provides the ResilientFirestoreService
@Riverpod(keepAlive: true)
ResilientFirestoreService firestoreService(Ref ref) =>
    ResilientFirestoreService();

@riverpod
Future<JobFilterCriteria> userJobFilterCriteria(Ref ref) async {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return const JobFilterCriteria(); // Default empty filter if no user
  }

  final userPreferenceService = ref.watch(userPreferenceServiceProvider);
  final preferences =
      await userPreferenceService.getUserPreferences(currentUser.uid);

  // Construct JobFilterCriteria from user preferences
  return JobFilterCriteria(
    classifications:
        List<String>.from(preferences?['preferredClassifications'] ?? []),
    state: preferences?['statePreference'] as String?,
    city: preferences?['cityPreference'] as String?,
    hasPerDiem: preferences?['wantsPerDiem'] as bool?,
    minWage: preferences?['minHourlyWage'] as double?,
    // Add more criteria based on your preferences structure
  );
}

@riverpod
Future<List<Job>> userPreferredJobs(Ref ref) async {
  final filterCriteria = await ref.watch(userJobFilterCriteriaProvider.future);
  final firestore = ref.watch(firestoreServiceProvider);

  try {
    // This uses the existing getJobsWithFilter method from ResilientFirestoreService
    final QuerySnapshot snapshot =
        await firestore.getJobsWithFilter(filter: filterCriteria);
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  } catch (e) {
    return [];
  }
}
