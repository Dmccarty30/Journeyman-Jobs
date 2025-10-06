import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/contractor_service.dart';
import '../../models/contractor_model.dart';

/// A Riverpod provider that creates and exposes a singleton instance of [ContractorService].
///
/// This service is responsible for all data operations related to contractors.
final contractorServiceProvider = Provider<ContractorService>((ref) {
  return ContractorService();
});

/// A Riverpod provider that fetches a list of all contractors one time.
///
/// This is useful for screens that need a static list of contractors without
/// listening for real-time updates. It asynchronously provides a `List<Contractor>`.
final allContractorsProvider = FutureProvider<List<Contractor>>((ref) async {
  final contractorService = ref.watch(contractorServiceProvider);
  return contractorService.getAllContractors();
});

/// A Riverpod provider that supplies a real-time stream of all contractors.
///
/// This is ideal for UIs that need to reflect changes to the contractor list
/// as they happen in the database.
final contractorsStreamProvider = StreamProvider<List<Contractor>>((ref) {
  final contractorService = ref.watch(contractorServiceProvider);
  return contractorService.contractorsStream();
});

/// A Riverpod provider family that filters the list of contractors based on a search query.
///
/// It takes a `String` query as a parameter and performs a case-insensitive, client-side
/// search on the list of contractors provided by [allContractorsProvider].
/// If the query is empty, it returns the full list.
final filteredContractorsProvider =
    Provider.family<List<Contractor>, String>((ref, query) {
  final allContractors = ref.watch(allContractorsProvider).value ?? [];
  if (query.isEmpty) {
    return allContractors;
  }
  return allContractors
      .where((contractor) =>
          contractor.company.toLowerCase().contains(query.toLowerCase()))
      .toList();
});