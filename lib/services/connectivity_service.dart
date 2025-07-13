import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity and providing offline indicators
/// 
/// This service provides real-time connectivity monitoring and notifies
/// listeners when the connection state changes, enabling offline-first UX.
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
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get wasOffline => _wasOffline;
  bool get isConnectedToWifi => _isConnectedToWifi;
  bool get isMobileData => _isMobileData;
  String get connectionType => _connectionType;
  DateTime? get lastOfflineTime => _lastOfflineTime;
  DateTime? get lastOnlineTime => _lastOnlineTime;
  
  /// Get connection quality description
  String get connectionQuality {
    if (!_isOnline) return 'Offline';
    if (_isConnectedToWifi) return 'WiFi';
    if (_isMobileData) return 'Mobile Data';
    return 'Unknown';
  }
  
  /// Get offline duration in minutes
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
  
  /// Force refresh connectivity state
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
  
  /// Check if we should sync data now
  bool shouldSyncData() {
    // Only sync on WiFi or if mobile data is explicitly allowed
    return _isOnline && (_isConnectedToWifi || _isMobileData);
  }
  
  /// Check if we should download large content
  bool shouldDownloadLargeContent() {
    // Only download large content on WiFi to save mobile data
    return _isOnline && _isConnectedToWifi;
  }
  
  /// Get connection status summary
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
  
  /// Reset the wasOffline flag (useful for dismissing offline indicators)
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

/// Extension methods for connectivity state
extension ConnectivityServiceExtensions on ConnectivityService {
  /// Check if app should show offline indicators
  bool get shouldShowOfflineIndicator => !isOnline || wasOffline;
  
  /// Check if app should cache aggressively
  bool get shouldCacheAggressively => isMobileData || !isOnline;
  
  /// Check if app should reduce background sync
  bool get shouldReduceBackgroundSync => isMobileData;
}
