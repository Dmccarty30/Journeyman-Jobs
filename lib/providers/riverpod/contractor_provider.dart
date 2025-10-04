import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/contractor_service.dart';
import '../../models/contractor_model.dart';

/// Provides an instance of ContractorService.
final contractorServiceProvider = Provider<ContractorService>((ref) {
  return ContractorService();
});

/// Provides a list of all contractors, fetched asynchronously.
final allContractorsProvider = FutureProvider<List<Contractor>>((ref) async {
  final contractorService = ref.watch(contractorServiceProvider);
  return contractorService.getAllContractors();
});

/// Provides a real-time stream of all contractors.
final contractorsStreamProvider = StreamProvider<List<Contractor>>((ref) {
  final contractorService = ref.watch(contractorServiceProvider);
  return contractorService.contractorsStream();
});

/// Provides a filtered list of contractors based on a search query.
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