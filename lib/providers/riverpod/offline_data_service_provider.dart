import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:journeyman_jobs/services/offline_data_service.dart';
import 'package:journeyman_jobs/features/crews/providers/connectivity_service_provider.dart';

part 'offline_data_service_provider.g.dart';

@riverpod
OfflineDataService offlineDataService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceForOfflineProvider);
  // connectivityService is already the correct type from the provider
  return OfflineDataService(connectivityService);
}
