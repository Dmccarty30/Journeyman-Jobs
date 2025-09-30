import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:journeyman_jobs/services/offline_data_service.dart';
import 'package:journeyman_jobs/features/crews/providers/connectivity_service_provider.dart';

part 'offline_data_service_provider.g.dart';

@Riverpod(keepAlive: true)
OfflineDataService offlineDataService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceForOfflineProvider);
  return OfflineDataService(connectivityService as ConnectivityService);
}
