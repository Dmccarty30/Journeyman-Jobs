import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp in JobSuggestion
import '../../models/job_suggestion_model.dart';
import 'local_ai_model_provider.dart'; // Import the provider for LocalModelService
import '../../services/subscription_service.dart'; // New import

part 'job_recommendation_provider.g.dart';

@riverpod
SubscriptionService subscriptionService(SubscriptionServiceRef ref) => SubscriptionService();

@riverpod
Future<List<JobSuggestion>> jobRecommendations(JobRecommendationsRef ref) async {
  final SubscriptionService subService = ref.watch(subscriptionServiceProvider);

  // Check if the user is a pro subscriber
  final bool isPro = await subService.isProSubscriber();
  if (!isPro) {
    print("User is not a pro subscriber. Returning empty job suggestions.");
    return []; // Return empty list if not a pro subscriber
  }

  final localModelService = ref.watch(localModelServicePod);

  // Placeholder for user preferences. In a real app, this would come from a user preferences provider.
  final Map<String, dynamic> userPreferences = {
    'per_diem_min': 100,
    'location_preference': 'Florida',
    'job_type': 'Journeyman Lineman',
  };

  return localModelService.getJobRecommendations(userPreferences);
}

