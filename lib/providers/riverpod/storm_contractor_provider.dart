import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/storm_contractor.dart';
import '../../services/storm_contractor_repository.dart';

part 'storm_contractor_provider.g.dart';

/// Storm contractor repository provider
@Riverpod()
StormContractorRepository stormContractorRepository(
        StormContractorRepositoryRef ref) =>
    StormContractorRepository();

/// Storm contractors stream provider
@Riverpod()
Stream<List<StormContractor>> stormContractorsStream(
    StormContractorsStreamRef ref) {
  final repo = ref.watch(stormContractorRepositoryProvider);
  return repo.streamAll();
}
