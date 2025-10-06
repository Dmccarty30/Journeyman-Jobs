import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A service for monitoring network connectivity and providing offline indicators.
///
/// This service uses the `connectivity_plus` package to provide real-time
/// connectivity monitoring. It notifies listeners when the connection state
/// changes, enabling an offline-first user experience.
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = true;
  bool _wasOffline = false;
  DateTime? _lastOfflineTime;
  DateTime? _lastOnlineTime;
  
  // Connection quality indicators
  String _connectionType = 'unknown';
  bool _isConnectedToWifi = false;
  bool _isMobileData = false;
  
  // Getters
  /// Returns `true` if the device has an active network connection.
  bool get isOnline => _isOnline;
  /// Returns `true` if the device has no active network connection.
  bool get isOffline => !_isOnline;
  /// Returns `true` if the device has been offline at least once during the session.
  bool get wasOffline => _wasOffline;
  /// Returns `true` if the device is connected to a WiFi network.
  bool get isConnectedToWifi => _isConnectedToWifi;
  /// Returns `true` if the device is connected to a mobile data network.
  bool get isMobileData => _isMobileData;
  /// Returns a string representation of the current connection type (e.g., 'WiFi', 'Mobile Data').
  String get connectionType => _connectionType;
  /// The timestamp of the last time the device went offline.
  DateTime? get lastOfflineTime => _lastOfflineTime;
  /// The timestamp of the last time the device came back online.
  DateTime? get lastOnlineTime => _lastOnlineTime;
  
  /// Returns a human-readable description of the connection quality.
  String get connectionQuality {
    if (!_isOnline) return 'Offline';
    if (_isConnectedToWifi) return 'WiFi';
    if (_isMobileData) return 'Mobile Data';
    return 'Unknown';
  }
  
  /// The duration in minutes the device was last offline.
  ///
  /// Returns `null` if the device has never been offline.
  int? get offlineDurationMinutes {
    if (_lastOfflineTime == null) return null;
    if (_isOnline && _lastOnlineTime != null) {
      return _lastOnlineTime!.difference(_lastOfflineTime!).inMinutes;
    } else if (!_isOnline) {
      return DateTime.now().difference(_lastOfflineTime!).inMinutes;
    }
    return null;
  }
  
  ConnectivityService() {
    _initializeConnectivityMonitoring();
  }
  
  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivityMonitoring() async {
    // Get initial connectivity state
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateConnectionState(result);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking initial connectivity: $e');
      }
      _isOnline = false;
    }
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionState,
      onError: (error) {
        if (kDebugMode) {
          print('Connectivity monitoring error: $error');
        }
        _handleConnectionError();
      },
    );
    
    if (kDebugMode) {
      print('ConnectivityService initialized - Initial state: ${_isOnline ? 'Online' : 'Offline'}');
    }
  }
  
  /// Update connection state based on connectivity result
  void _updateConnectionState(List<ConnectivityResult> results) {
    final bool wasOnline = _isOnline;
    final ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    // Update connection status
    _isOnline = result != ConnectivityResult.none;
    _isConnectedToWifi = result == ConnectivityResult.wifi;
    _isMobileData = result == ConnectivityResult.mobile;
    
    // Update connection type
    switch (result) {
      case ConnectivityResult.wifi:
        _connectionType = 'WiFi';
        break;
      case ConnectivityResult.mobile:
        _connectionType = 'Mobile Data';
        break;
      case ConnectivityResult.ethernet:
        _connectionType = 'Ethernet';
        break;
      case ConnectivityResult.vpn:
        _connectionType = 'VPN';
        break;
      case ConnectivityResult.bluetooth:
        _connectionType = 'Bluetooth';
        break;
      case ConnectivityResult.other:
        _connectionType = 'Other';
        break;
      case ConnectivityResult.none:
        _connectionType = 'Offline';
        break;
    }
    
    // Track state transitions
    if (wasOnline && !_isOnline) {
      // Went offline
      _lastOfflineTime = DateTime.now();
      _wasOffline = true;
      if (kDebugMode) {
        print('ConnectivityService: Connection lost');
      }
    } else if (!wasOnline && _isOnline) {
      // Came back online
      _lastOnlineTime = DateTime.now();
      if (kDebugMode) {
        print('ConnectivityService: Connection restored ($_connectionType)');
      }
    }
    
    // Notify listeners if state changed
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }
  
  /// Handle connectivity monitoring errors
  void _handleConnectionError() {
    final bool wasOnline = _isOnline;
    _isOnline = false;
    _connectionType = 'Error';
    
    if (wasOnline) {
      _lastOfflineTime = DateTime.now();
      _wasOffline = true;
      notifyListeners();
    }
  }
  
  /// Test internet connectivity by attempting a network request
  /// Performs a check to determine if the device has a functional internet connection.
  ///
  /// This can be more reliable than just checking the connection type, as it
  /// attempts a real network operation.
  ///
  /// Returns `true` if internet is accessible, `false` otherwise.
  Future<bool> testInternetConnection() async {
    try {
      // Use a reliable endpoint to test actual internet connectivity
      final result = await _connectivity.checkConnectivity();
      return result.first != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Internet connectivity test failed: $e');
      }
      return false;
    }
  }
  
  /// Manually triggers a refresh of the connectivity state.
  ///
  /// This is useful for re-checking the connection after a failed network request.
  Future<void> refreshConnectivityState() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateConnectionState(result);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing connectivity state: $e');
      }
      _handleConnectionError();
    }
  }
  
  /// Determines if the app should perform a data sync based on the current connection.
  ///
  /// Returns `true` if connected to WiFi or mobile data.
  bool shouldSyncData() {
    // Only sync on WiFi or if mobile data is explicitly allowed
    return _isOnline && (_isConnectedToWifi || _isMobileData);
  }
  
  /// Determines if the app should download large content.
  ///
  /// To conserve user data, this typically returns `true` only when connected to WiFi.
  bool shouldDownloadLargeContent() {
    // Only download large content on WiFi to save mobile data
    return _isOnline && _isConnectedToWifi;
  }
  
  /// Returns a summary of the current connection status.
  ///
  /// The returned map includes details like online status, connection type,
  /// and timestamps of state changes.
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isOnline': _isOnline,
      'connectionType': _connectionType,
      'isWifi': _isConnectedToWifi,
      'isMobileData': _isMobileData,
      'wasOffline': _wasOffline,
      'lastOfflineTime': _lastOfflineTime?.toIso8601String(),
      'lastOnlineTime': _lastOnlineTime?.toIso8601String(),
      'offlineDurationMinutes': offlineDurationMinutes,
      'shouldSyncData': shouldSyncData(),
      'shouldDownloadLargeContent': shouldDownloadLargeContent(),
    };
  }
  
  /// Resets the [wasOffline] flag to `false`.
  ///
  /// This is useful for dismissing persistent offline indicators after the user
  /// has acknowledged the status.
  void resetOfflineFlag() {
    _wasOffline = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
    
    if (kDebugMode) {
      print('ConnectivityService disposed');
    }
  }
}

/// Provides convenient extension methods on [ConnectivityService].
extension ConnectivityServiceExtensions on ConnectivityService {
  /// Determines if a UI indicator for being offline should be shown.
  bool get shouldShowOfflineIndicator => !isOnline || wasOffline;
  
  /// Determines if the app should cache data more aggressively.
  ///
  /// This is typically `true` when on mobile data or offline to reduce data usage
  /// and improve user experience.
  bool get shouldCacheAggressively => isMobileData || !isOnline;
  
  /// Determines if the app should reduce the frequency of background sync operations.
  ///
  /// This is `true` when on mobile data to conserve the user's data plan.
  bool get shouldReduceBackgroundSync => isMobileData;
}
