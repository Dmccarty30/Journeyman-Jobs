import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:journeyman_jobs/services/offline_data_service.dart';
import 'package:journeyman_jobs/features/crews/providers/connectivity_service_provider.dart';

part 'offline_data_service_provider.g.dart';

/// A Riverpod provider that creates and exposes a singleton instance of [OfflineDataService].
///
/// This provider is marked with `keepAlive: true` to ensure that the offline
/// data service persists throughout the app's lifecycle, managing cached data
/// and synchronization tasks. It depends on a connectivity service to
/// intelligently handle online/offline state transitions.
@Riverpod(keepAlive: true)
OfflineDataService offlineDataService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceForOfflineProvider);
  // connectivityService is already the correct type from the provider
  return OfflineDataService(connectivityService);
}
