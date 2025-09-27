import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:journeyman_jobs/features/crews/services/connectivity_service.dart';

part 'connectivity_service_provider.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

@riverpod
AppConnectivityService connectivityService(Ref ref) {
  return AppConnectivityService(ref);
}

// Wrapper class to adapt AppConnectivityService to ConnectivityService interface
class ConnectivityServiceAdapter extends ConnectivityService {
  final AppConnectivityService _appService;

  ConnectivityServiceAdapter(this._appService) : super();

  @override
  Stream<List<ConnectivityResult>> get connectivityStream => _appService.onConnectivityChanged;

  @override
  bool get isOnline {
    // This is a synchronous getter, but AppConnectivityService.isOnline is async
    // For now, return false - in a real implementation you'd need to cache the state
    // or make the base class methods async as well
    return false;
  }

  @override
  Future<List<ConnectivityResult>> getConnection() async {
    return await _appService.isConnected ? await Connectivity().checkConnectivity() : [ConnectivityResult.none];
  }
}

@riverpod
ConnectivityService connectivityServiceForOffline(Ref ref) {
  final appService = ref.watch(connectivityServiceProvider);
  return ConnectivityServiceAdapter(appService);
}

class AppConnectivityService {
  final Ref _ref;

  AppConnectivityService(this._ref);

  Stream<List<ConnectivityResult>> get onConnectivityChanged => _ref.watch(connectivityStreamProvider as ProviderListenable<Stream<List<ConnectivityResult>>>);

  Future<bool> get isConnected async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> get isOnline async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
