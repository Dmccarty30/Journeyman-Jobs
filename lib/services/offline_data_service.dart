import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';
import '../features/crews/models/crew.dart';
import '../features/crews/models/crew_member.dart';
import 'connectivity_service.dart';

/// Offline data availability duration
const Duration kOfflineDataRetention = Duration(hours: 24);

/// Sync strategy types
enum SyncStrategy {
  immediate,    // Sync as soon as connectivity is available
  scheduled,    // Sync at specific times (e.g., Wi-Fi only)
  manual,       // User-initiated sync only
  smart,        // Intelligent sync based on usage patterns
}

/// Sync priority levels
enum SyncPriority {
  high,         // Critical data (user preferences, bookmarks)
  medium,       // Important data (recent job searches, applications)
  low,          // Background data (full job listings, analytics)
}

/// Offline data entry with metadata
class OfflineDataEntry {
  final String key;
  final Map<String, dynamic> data;
  final DateTime cachedAt;
  final DateTime expiresAt;
  final SyncPriority priority;
  final bool isDirty;  // Has local changes that need syncing

  const OfflineDataEntry({
    required this.key,
    required this.data,
    required this.cachedAt,
    required this.expiresAt,
    required this.priority,
    this.isDirty = false,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'data': data,
    'cachedAt': cachedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'priority': priority.index,
    'isDirty': isDirty,
  };

  factory OfflineDataEntry.fromJson(Map<String, dynamic> json) =>
    OfflineDataEntry(
      key: json['key'],
      data: Map<String, dynamic>.from(json['data']),
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      priority: SyncPriority.values[json['priority']],
      isDirty: json['isDirty'] ?? false,
    );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  OfflineDataEntry copyWith({
    String? key,
    Map<String, dynamic>? data,
    DateTime? cachedAt,
    DateTime? expiresAt,
    SyncPriority? priority,
    bool? isDirty,
  }) => OfflineDataEntry(
    key: key ?? this.key,
    data: data ?? this.data,
    cachedAt: cachedAt ?? this.cachedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    priority: priority ?? this.priority,
    isDirty: isDirty ?? this.isDirty,
  );
}

/// Comprehensive offline data management service
class OfflineDataService {
  static const String _jobsKey = 'offline_jobs';
  static const String _localsKey = 'offline_locals';
  static const String _userDataKey = 'offline_user_data';
  static const String _searchHistoryKey = 'offline_search_history';
  static const String _bookmarksKey = 'offline_bookmarks';
  static const String _preferencesKey = 'offline_preferences';
  static const String _crewsKey = 'offline_crews';
  static const String _crewMembersKey = 'offline_crew_members';
  static const String _syncStrategyKey = 'sync_strategy';
  static const String _lastSyncKey = 'last_sync';
  static const String _pendingChangesKey = 'pending_changes';

  final ConnectivityService _connectivityService;
  
  SharedPreferences? _prefs;
  Timer? _syncTimer;
  Timer? _cleanupTimer;
  
  // Stream controllers for real-time updates
  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _dataUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<double> _syncProgressController = StreamController<double>.broadcast();

  // User preferences
  SyncStrategy _syncStrategy = SyncStrategy.smart;
  bool _wifiOnlySync = false;
  bool _backgroundSyncEnabled = true;
  int _maxOfflineDataSize = 50; // MB
  
  // Sync state
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingChangesCount = 0;

  OfflineDataService(this._connectivityService);

  /// Initialize the offline data service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserPreferences();
    await _loadSyncState();
    
    // Set up periodic cleanup
    _setupPeriodicCleanup();
    
    // Set up connectivity-based sync
    _setupConnectivitySync();
    
    // Load pending changes count
    await _updatePendingChangesCount();
  }

  /// Stream of sync status changes
  Stream<bool> get syncStatusStream => _syncStatusController.stream;
  
  /// Stream of data updates
  Stream<Map<String, dynamic>> get dataUpdateStream => _dataUpdateController.stream;
  
  /// Stream of sync progress (0.0 to 1.0)
  Stream<double> get syncProgressStream => _syncProgressController.stream;

  // Getters for current state
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChangesCount => _pendingChangesCount;
  SyncStrategy get syncStrategy => _syncStrategy;
  bool get isOfflineDataAvailable => _hasValidOfflineData();

  /// Store jobs for offline access
  Future<void> storeJobsOffline(List<Job> jobs, {SyncPriority priority = SyncPriority.medium}) async {
    final entries = jobs.map((job) => OfflineDataEntry(
      key: 'job_${job.id}',
      data: job.toJson(),
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(kOfflineDataRetention),
      priority: priority,
    )).toList();

    await _storeDataEntries(_jobsKey, entries);
    _dataUpdateController.add({'type': 'jobs', 'count': jobs.length});
  }

  /// Get jobs from offline storage
  Future<List<Job>> getOfflineJobs({bool includeExpired = false}) async {
    final entries = await _getDataEntries(_jobsKey);
    final validEntries = includeExpired 
        ? entries 
        : entries.where((entry) => !entry.isExpired).toList();
    
    return validEntries
        .map((entry) => Job.fromJson(entry.data))
        .toList();
  }

  /// Store locals for offline access
  Future<void> storeLocalsOffline(List<LocalsRecord> locals, {SyncPriority priority = SyncPriority.low}) async {
    final entries = locals.map((local) => OfflineDataEntry(
      key: 'local_${local.id}',
      data: local.toJson(),
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(kOfflineDataRetention),
      priority: priority,
    )).toList();

    await _storeDataEntries(_localsKey, entries);
    _dataUpdateController.add({'type': 'locals', 'count': locals.length});
  }

  /// Get locals from offline storage
  Future<List<LocalsRecord>> getOfflineLocals({bool includeExpired = false}) async {
    final entries = await _getDataEntries(_localsKey);
    final validEntries = includeExpired 
        ? entries 
        : entries.where((entry) => !entry.isExpired).toList();
    
    return validEntries
        .map((entry) => LocalsRecord.fromJson(entry.data))
        .toList();
  }

  /// Store user preferences offline
  Future<void> storeUserPreferencesOffline(Map<String, dynamic> preferences) async {
    final entry = OfflineDataEntry(
      key: 'user_preferences',
      data: preferences,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)), // Preferences last longer
      priority: SyncPriority.high,
      isDirty: true, // User preferences always need syncing
    );

    await _storeDataEntry(_preferencesKey, entry);
    await _updatePendingChangesCount();
    _dataUpdateController.add({'type': 'preferences', 'data': preferences});
  }

  /// Get user preferences from offline storage
  Future<Map<String, dynamic>?> getOfflineUserPreferences() async {
    final entry = await _getDataEntry(_preferencesKey);
    return entry?.data;
  }

  /// Store search history offline
  Future<void> storeSearchHistoryOffline(List<Map<String, dynamic>> searchHistory) async {
    final entries = searchHistory.asMap().entries.map((entry) => OfflineDataEntry(
      key: 'search_${entry.key}',
      data: entry.value,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)), // Search history expires in a week
      priority: SyncPriority.medium,
    )).toList();

    await _storeDataEntries(_searchHistoryKey, entries);
    _dataUpdateController.add({'type': 'search_history', 'count': searchHistory.length});
  }

  /// Get search history from offline storage
  Future<List<Map<String, dynamic>>> getOfflineSearchHistory() async {
    final entries = await _getDataEntries(_searchHistoryKey);
    return entries
        .where((entry) => !entry.isExpired)
        .map((entry) => entry.data)
        .toList();
  }

  /// Store job bookmarks offline
  Future<void> storeBookmarksOffline(List<String> jobIds) async {
    final bookmarkData = {
      'bookmarked_jobs': jobIds,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final entry = OfflineDataEntry(
      key: 'bookmarks',
      data: bookmarkData,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      priority: SyncPriority.high,
      isDirty: true, // Bookmarks always need syncing
    );

    await _storeDataEntry(_bookmarksKey, entry);
    await _updatePendingChangesCount();
    _dataUpdateController.add({'type': 'bookmarks', 'jobIds': jobIds});
  }

  /// Get job bookmarks from offline storage
  Future<List<String>> getOfflineBookmarks() async {
    final entry = await _getDataEntry(_bookmarksKey);
    if (entry?.data['bookmarked_jobs'] != null) {
      return List<String>.from(entry!.data['bookmarked_jobs']);
    }
    return [];
  }

  /// Store crews for offline access
  Future<void> storeCrewsOffline(List<Crew> crews, {SyncPriority priority = SyncPriority.medium}) async {
    final entries = crews.map((crew) => OfflineDataEntry(
      key: 'crew_${crew.id}',
      data: crew.toFirestore(), // Assuming toFirestore() returns Map<String, dynamic>
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(kOfflineDataRetention),
      priority: priority,
    )).toList();

    await _storeDataEntries(_crewsKey, entries);
    _dataUpdateController.add({'type': 'crews', 'count': crews.length});
  }

  /// Get crews from offline storage
  Future<List<Crew>> getOfflineCrews({bool includeExpired = false}) async {
    final entries = await _getDataEntries(_crewsKey);
    final validEntries = includeExpired 
        ? entries 
        : entries.where((entry) => !entry.isExpired).toList();
    
    return validEntries
        .map((entry) => Crew.fromMap(entry.data)) // Assuming fromFirestore takes Map<String, dynamic>
        .toList();
  }

  /// Store crew members for offline access
  Future<void> storeCrewMembersOffline(List<CrewMember> members, {SyncPriority priority = SyncPriority.medium}) async {
    final entries = members.map((member) => OfflineDataEntry(
      key: 'member_${member.userId}_${member.crewId}',
      data: member.toFirestore(), // Assuming toFirestore() returns Map<String, dynamic>
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(kOfflineDataRetention),
      priority: priority,
    )).toList();

    await _storeDataEntries(_crewMembersKey, entries);
    _dataUpdateController.add({'type': 'crew_members', 'count': members.length});
  }

  /// Get crew members from offline storage
  Future<List<CrewMember>> getOfflineCrewMembers({bool includeExpired = false}) async {
    final entries = await _getDataEntries(_crewMembersKey);
    final validEntries = includeExpired 
        ? entries 
        : entries.where((entry) => !entry.isExpired).toList();
    
    return validEntries
        .map((entry) => CrewMember.fromMap(entry.data)) // Assuming fromFirestore takes Map<String, dynamic>
        .toList();
  }

  /// Mark data as needing sync (when modified offline)
  Future<void> markDataDirty(String key, Map<String, dynamic> changes) async {
    // Store the pending change
    final pendingChanges = await _getPendingChanges();
    pendingChanges[key] = {
      'changes': changes,
      'timestamp': DateTime.now().toIso8601String(),
      'priority': SyncPriority.high.index,
    };

    await _prefs?.setString(_pendingChangesKey, jsonEncode(pendingChanges));
    await _updatePendingChangesCount();

    // Trigger sync if appropriate
    if (_syncStrategy == SyncStrategy.immediate && _connectivityService.isOnline) {
      _triggerSync();
    }
  }

  /// Perform data synchronization
  Future<bool> performSync({bool force = false}) async {
    if (_isSyncing && !force) return false;

    _isSyncing = true;
    _syncStatusController.add(true);
    _syncProgressController.add(0.0);

    try {
      // Check connectivity requirements
      if (!_connectivityService.isOnline) {
        debugPrint('Offline: Cannot sync without internet connection');
        return false;
      }

      if (_wifiOnlySync && _connectivityService.connectionType != 'WiFi') {
        debugPrint('Offline: Waiting for Wi-Fi connection for sync');
        return false;
      }

      // Sync pending changes first (highest priority)
      await _syncPendingChanges();
      _syncProgressController.add(0.3);

      // Sync high priority data
      await _syncHighPriorityData();
      _syncProgressController.add(0.6);

      // Sync medium/low priority data if bandwidth allows
      if (_shouldSyncLowPriorityData()) {
        await _syncLowPriorityData();
      }
      _syncProgressController.add(0.9);

      // Clean up expired data
      await _cleanupExpiredData();
      _syncProgressController.add(1.0);

      _lastSyncTime = DateTime.now();
      await _prefs?.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());

      debugPrint('Offline: Sync completed successfully');
      return true;

    } catch (e) {
      debugPrint('Offline: Sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  /// Configure sync strategy
  Future<void> configureSyncStrategy({
    SyncStrategy? strategy,
    bool? wifiOnly,
    bool? backgroundSync,
    int? maxDataSizeMB,
  }) async {
    if (strategy != null) {
      _syncStrategy = strategy;
      await _prefs?.setInt(_syncStrategyKey, strategy.index);
    }

    if (wifiOnly != null) {
      _wifiOnlySync = wifiOnly;
      await _prefs?.setBool('wifi_only_sync', wifiOnly);
    }

    if (backgroundSync != null) {
      _backgroundSyncEnabled = backgroundSync;
      await _prefs?.setBool('background_sync', backgroundSync);
      
      if (backgroundSync) {
        _setupPeriodicSync();
      } else {
        _syncTimer?.cancel();
      }
    }

    if (maxDataSizeMB != null) {
      _maxOfflineDataSize = maxDataSizeMB;
      await _prefs?.setInt('max_offline_data_size', maxDataSizeMB);
    }
  }

  /// Get sync and storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    final stats = <String, dynamic>{};
    
    // Data counts
    stats['jobs_count'] = (await _getDataEntries(_jobsKey)).length;
    stats['locals_count'] = (await _getDataEntries(_localsKey)).length;
    stats['search_history_count'] = (await _getDataEntries(_searchHistoryKey)).length;
    
    // Storage size estimation (rough)
    final allKeys = [_jobsKey, _localsKey, _userDataKey, _searchHistoryKey, _bookmarksKey, _preferencesKey];
    int totalSize = 0;
    
    for (final key in allKeys) {
      final data = _prefs?.getString(key);
      if (data != null) {
        totalSize += data.length;
      }
    }
    
    stats['storage_size_bytes'] = totalSize;
    stats['storage_size_mb'] = (totalSize / (1024 * 1024)).toStringAsFixed(2);
    stats['max_size_mb'] = _maxOfflineDataSize;
    stats['last_sync'] = _lastSyncTime?.toIso8601String();
    stats['pending_changes'] = _pendingChangesCount;
    stats['sync_strategy'] = _syncStrategy.toString();
    
    return stats;
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    final keys = [_jobsKey, _localsKey, _userDataKey, _searchHistoryKey, _bookmarksKey, _crewsKey, _crewMembersKey];
    
    for (final key in keys) {
      await _prefs?.remove(key);
    }
    
    await _prefs?.remove(_pendingChangesKey);
    await _updatePendingChangesCount();
    
    _dataUpdateController.add({'type': 'cleared'});
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _cleanupTimer?.cancel();
    _syncStatusController.close();
    _dataUpdateController.close();
    _syncProgressController.close();
  }

  // Private helper methods

  Future<void> _loadUserPreferences() async {
    _syncStrategy = SyncStrategy.values[_prefs?.getInt(_syncStrategyKey) ?? SyncStrategy.smart.index];
    _wifiOnlySync = _prefs?.getBool('wifi_only_sync') ?? false;
    _backgroundSyncEnabled = _prefs?.getBool('background_sync') ?? true;
    _maxOfflineDataSize = _prefs?.getInt('max_offline_data_size') ?? 50;
  }

  Future<void> _loadSyncState() async {
    final lastSyncString = _prefs?.getString(_lastSyncKey);
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.parse(lastSyncString);
    }
  }

  Future<void> _updatePendingChangesCount() async {
    final pendingChanges = await _getPendingChanges();
    _pendingChangesCount = pendingChanges.length;
  }

  Future<Map<String, dynamic>> _getPendingChanges() async {
    final changesString = _prefs?.getString(_pendingChangesKey);
    if (changesString != null) {
      return Map<String, dynamic>.from(jsonDecode(changesString));
    }
    return {};
  }

  Future<void> _storeDataEntries(String key, List<OfflineDataEntry> entries) async {
    final serialized = entries.map((entry) => entry.toJson()).toList();
    await _prefs?.setString(key, jsonEncode(serialized));
  }

  Future<void> _storeDataEntry(String key, OfflineDataEntry entry) async {
    await _prefs?.setString(key, jsonEncode(entry.toJson()));
  }

  Future<List<OfflineDataEntry>> _getDataEntries(String key) async {
    final dataString = _prefs?.getString(key);
    if (dataString != null) {
      final List<dynamic> serialized = jsonDecode(dataString);
      return serialized
          .map((item) => OfflineDataEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  Future<OfflineDataEntry?> _getDataEntry(String key) async {
    final dataString = _prefs?.getString(key);
    if (dataString != null) {
      return OfflineDataEntry.fromJson(Map<String, dynamic>.from(jsonDecode(dataString)));
    }
    return null;
  }

  bool _hasValidOfflineData() {
    // Check if we have any non-expired data
    return _lastSyncTime != null && 
           DateTime.now().difference(_lastSyncTime!).inHours < 24;
  }

  void _setupPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _cleanupExpiredData();
    });
  }

  void _setupConnectivitySync() {
    _connectivityService.addListener(() {
      if (_connectivityService.isOnline && _syncStrategy == SyncStrategy.immediate && _pendingChangesCount > 0) {
        _triggerSync();
      }
    });
  }

  void _setupPeriodicSync() {
    if (!_backgroundSyncEnabled) return;
    
    // Sync every 2 hours when connected
    _syncTimer = Timer.periodic(const Duration(hours: 2), (_) {
      if (_connectivityService.isOnline && !_isSyncing) {
        _triggerSync();
      }
    });
  }

  void _triggerSync() {
    // Delay sync to avoid overwhelming the system
    Timer(const Duration(seconds: 2), () {
      performSync();
    });
  }

  Future<void> _syncPendingChanges() async {
    final pendingChanges = await _getPendingChanges();
    
    for (final entry in pendingChanges.entries) {
      try {
        // In a real implementation, this would sync specific changes to Firestore
        // For now, we'll just mark them as synced
        debugPrint('Syncing pending change: ${entry.key}');
        
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 100));
        
      } catch (e) {
        debugPrint('Failed to sync change ${entry.key}: $e');
        throw e; // Re-throw to handle in main sync method
      }
    }

    // Clear pending changes after successful sync
    await _prefs?.remove(_pendingChangesKey);
    await _updatePendingChangesCount();
  }

  Future<void> _syncHighPriorityData() async {
    // Sync user preferences and bookmarks
    debugPrint('Syncing high priority data...');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate sync
  }

  Future<void> _syncLowPriorityData() async {
    // Sync search history and refresh job data
    debugPrint('Syncing low priority data...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate sync
  }

  bool _shouldSyncLowPriorityData() {
    // Only sync low priority data on Wi-Fi or if specifically configured
    return _connectivityService.connectionType == 'WiFi' ||
           !_wifiOnlySync;
  }

  Future<void> _cleanupExpiredData() async {
    final keys = [_jobsKey, _localsKey, _searchHistoryKey];
    
    for (final key in keys) {
      final entries = await _getDataEntries(key);
      final validEntries = entries.where((entry) => !entry.isExpired).toList();
      
      if (validEntries.length != entries.length) {
        await _storeDataEntries(key, validEntries);
        debugPrint('Cleaned up ${entries.length - validEntries.length} expired entries from $key');
      }
    }
  }
}