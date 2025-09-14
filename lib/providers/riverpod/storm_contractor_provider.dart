import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/storm_contractor.dart';
import '../../services/storm_contractor_repository.dart';

final stormContractorRepositoryProvider = Provider<StormContractorRepository>((ref) {
  return StormContractorRepository();
});

final stormContractorsStreamProvider = StreamProvider.autoDispose<List<StormContractor>>((ref) {
  final repo = ref.watch(stormContractorRepositoryProvider);
  return repo.streamAll();
});