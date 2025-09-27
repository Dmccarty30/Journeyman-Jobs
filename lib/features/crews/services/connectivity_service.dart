import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  other,
  none,
}

class ConnectivityService extends ChangeNotifier {
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult _currentResult = ConnectivityResult.none;
  DateTime? _lastOfflineTime;
  DateTime? _lastOnlineTime;
  bool _wasOffline = false;
  final Connectivity _connectivity = Connectivity();

  ConnectivityService() {
    _initialize();
  }

  void _initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateState(result as ConnectivityResult);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState as void Function(List<ConnectivityResult> event)?) as StreamSubscription<ConnectivityResult>?;
  }

  void _updateState(ConnectivityResult result) {
    final wasOffline = !isOnline;
    _currentResult = result;
    if (!isOnline) {
      _lastOfflineTime = DateTime.now();
    } else {
      _lastOnlineTime = DateTime.now();
    }
    if (wasOffline && isOnline) {
      _wasOffline = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool get isOnline => _currentResult != ConnectivityResult.none;
  bool get isOffline => _currentResult == ConnectivityResult.none;
  bool get wasOffline => _wasOffline;
  DateTime? get lastOfflineTime => _lastOfflineTime;
  DateTime? get lastOnlineTime => _lastOnlineTime;
  String get connectionType {
    switch (_currentResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'None';
      case ConnectivityResult.bluetooth:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
  bool get isConnectedToWifi => _currentResult == ConnectivityResult.wifi;
  bool get isMobileData => _currentResult == ConnectivityResult.mobile;
  int get offlineDurationMinutes {
    if (_lastOfflineTime == null || isOnline) return 0;
    return DateTime.now().difference(_lastOfflineTime!).inMinutes;
  }
  ConnectivityResult get currentConnectivity => _currentResult;
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<List<ConnectivityResult>> getConnection() async {
    return await _connectivity.checkConnectivity();
  }

  bool isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void refreshConnectivityState() async {
    final result = await _connectivity.checkConnectivity();
    _updateState(result as ConnectivityResult);
  }
}
