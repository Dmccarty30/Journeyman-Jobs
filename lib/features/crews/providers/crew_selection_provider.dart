import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// FutureProvider that fetches the list of crews for the current user
final userCrewsProvider = FutureProvider<List<Crew>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  final crewService = ref.watch(crewServiceProvider as ProviderListenable);
  return await crewService.getUserCrews(currentUser.uid);
});