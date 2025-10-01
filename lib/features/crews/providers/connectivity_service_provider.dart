import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  Stream<List<ConnectivityResult>> get connectivityStream => _appService.onConnectivityChanged;

  @override
  bool get isOnline {
    // This is a synchronous getter, but AppConnectivityService.isOnline is async
    // For now, return false - in a real implementation you'd need to cache the state
    // or make the base class methods async as well
    return false;
  }

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
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults != ConnectivityResult.none;
  }

  Future<bool> get isOnline async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults != ConnectivityResult.none;
  }
}
