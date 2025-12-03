import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'cache_service.dart';

/// Power outage data service using PowerOutage.us public API
/// 
/// Provides real-time power outage information by state for storm work planning
/// Data is updated every 10 minutes from utility providers
class PowerOutageService {
  static final PowerOutageService _instance = PowerOutageService._internal();
  factory PowerOutageService() => _instance;
  PowerOutageService._internal();

  final Dio _dio = Dio(BaseOptions(
    headers: {
      'User-Agent': 'JourneymanJobs/1.0 (IBEW storm work app)',
      'Accept': 'application/json',
    },
  ));
  final CacheService _cacheService = CacheService();
  
  // PowerOutage.us API endpoint (public key from their website)
  static const String _apiUrl = 'https://poweroutage.us/api/web/states';
  static const String _apiKey = '9818916638';
  static const String _countryId = 'us';
  
  // Cache configuration
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const int _minimumOutageThreshold = 20000; // Only show states with 20k+ outages
  
  // Current data
  final List<PowerOutageState> _currentOutages = [];
  Timer? _refreshTimer;
  DateTime? _lastUpdate;
  
  /// Initialize the service and start periodic updates
  Future<void> initialize() async {
    await fetchPowerOutages();
    
    // Set up periodic refresh every 5 minutes
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => fetchPowerOutages(),
    );
  }
  
  /// Dispose of resources
  void dispose() {
    _refreshTimer?.cancel();
  }
  
  /// Get current power outage data
  Future<List<PowerOutageState>> getPowerOutages({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _currentOutages.isEmpty || _isDataStale()) {
      await fetchPowerOutages();
    }
    
    // Return filtered and sorted data
    return _currentOutages
        .where((state) => state.outageCount >= _minimumOutageThreshold)
        .toList()
      ..sort((a, b) => b.outageCount.compareTo(a.outageCount));
  }
  
  /// Fetch latest power outage data from API
  Future<void> fetchPowerOutages() async {
    try {
      final cacheKey = 'power_outages_latest';
      
      // Try cache first
      final cached = await _cacheService.get<String>(cacheKey);
      if (cached != null && !_isDataStale()) {
        final data = jsonDecode(cached);
        _parseOutageData(data);
        return;
      }
      
      // Fetch fresh data
      final response = await _dio.get(
        _apiUrl,
        queryParameters: {
          'key': _apiKey,
          'countryid': _countryId,
        },
      );
      
      if (response.statusCode == 200) {
        _parseOutageData(response.data);
        _lastUpdate = DateTime.now();
        
        // Cache the data
        await _cacheService.set(
          cacheKey,
          jsonEncode(response.data),
          ttl: _cacheDuration,
        );
        
        if (kDebugMode) {
          final significantOutages = _currentOutages
              .where((s) => s.outageCount >= _minimumOutageThreshold)
              .length;
          print('Power outage data updated: $significantOutages states with 20k+ outages');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching power outage data: $e');
      }
      // Keep using cached data if available
    }
  }
  
  /// Parse outage data from API response
  void _parseOutageData(Map<String, dynamic> data) {
    _currentOutages.clear();
    
    final records = data['WebStateRecord'] as List<dynamic>?;
    if (records != null) {
      for (final record in records) {
        _currentOutages.add(PowerOutageState.fromJson(record));
      }
    }
  }
  
  /// Check if current data is stale
  bool _isDataStale() {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > _cacheDuration;
  }
  
  /// Get total outages across all states
  int getTotalOutages() {
    return _currentOutages.fold(0, (sum, state) => sum + state.outageCount);
  }
  
  /// Get total affected customers across significant outages (20k+)
  int getSignificantOutagesTotal() {
    return _currentOutages
        .where((state) => state.outageCount >= _minimumOutageThreshold)
        .fold(0, (sum, state) => sum + state.outageCount);
  }
  
  /// Get states with most severe outages
  List<PowerOutageState> getMostAffectedStates({int limit = 5}) {
    final sorted = List<PowerOutageState>.from(_currentOutages)
      ..sort((a, b) => b.outageCount.compareTo(a.outageCount));
    
    return sorted.take(limit).toList();
  }
  
  /// Calculate outage percentage for a state
  double getOutagePercentage(PowerOutageState state) {
    if (state.customerCount == 0) return 0;
    return (state.outageCount / state.customerCount) * 100;
  }
  
  /// Get outage severity level
  OutageSeverity getOutageSeverity(PowerOutageState state) {
    final percentage = getOutagePercentage(state);
    
    if (state.outageCount >= 100000 || percentage >= 20) {
      return OutageSeverity.critical;
    } else if (state.outageCount >= 50000 || percentage >= 10) {
      return OutageSeverity.severe;
    } else if (state.outageCount >= 20000 || percentage >= 5) {
      return OutageSeverity.moderate;
    } else if (state.outageCount >= 10000 || percentage >= 2) {
      return OutageSeverity.minor;
    } else {
      return OutageSeverity.minimal;
    }
  }
  
  /// Get formatted outage count
  String formatOutageCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return count.toString();
  }
  
  /// Get last update time
  DateTime? get lastUpdate => _lastUpdate;
  
  /// Check if data is loading
  bool get isLoading => _currentOutages.isEmpty && _lastUpdate == null;
}

/// Power outage state model
class PowerOutageState {
  final String stateName;
  final int outageCount;
  final int customerCount;
  
  PowerOutageState({
    required this.stateName,
    required this.outageCount,
    required this.customerCount,
  });
  
  factory PowerOutageState.fromJson(Map<String, dynamic> json) {
    return PowerOutageState(
      stateName: json['StateName'] ?? '',
      outageCount: json['OutageCount'] ?? 0,
      customerCount: json['CustomerCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'StateName': stateName,
    'OutageCount': outageCount,
    'CustomerCount': customerCount,
  };
  
  /// Get state abbreviation
  String get stateAbbreviation {
    // Map of state names to abbreviations
    const stateAbbreviations = {
      'Alabama': 'AL', 'Alaska': 'AK', 'Arizona': 'AZ', 'Arkansas': 'AR',
      'California': 'CA', 'Colorado': 'CO', 'Connecticut': 'CT', 'Delaware': 'DE',
      'District of Columbia': 'DC', 'Florida': 'FL', 'Georgia': 'GA', 'Hawaii': 'HI',
      'Idaho': 'ID', 'Illinois': 'IL', 'Indiana': 'IN', 'Iowa': 'IA',
      'Kansas': 'KS', 'Kentucky': 'KY', 'Louisiana': 'LA', 'Maine': 'ME',
      'Maryland': 'MD', 'Massachusetts': 'MA', 'Michigan': 'MI', 'Minnesota': 'MN',
      'Mississippi': 'MS', 'Missouri': 'MO', 'Montana': 'MT', 'Nebraska': 'NE',
      'Nevada': 'NV', 'New Hampshire': 'NH', 'New Jersey': 'NJ', 'New Mexico': 'NM',
      'New York': 'NY', 'North Carolina': 'NC', 'North Dakota': 'ND', 'Ohio': 'OH',
      'Oklahoma': 'OK', 'Oregon': 'OR', 'Pennsylvania': 'PA', 'Rhode Island': 'RI',
      'South Carolina': 'SC', 'South Dakota': 'SD', 'Tennessee': 'TN', 'Texas': 'TX',
      'Utah': 'UT', 'Vermont': 'VT', 'Virginia': 'VA', 'Washington': 'WA',
      'West Virginia': 'WV', 'Wisconsin': 'WI', 'Wyoming': 'WY',
    };
    
    return stateAbbreviations[stateName] ?? stateName;
  }
}

/// Outage severity levels
enum OutageSeverity {
  minimal,   // < 10k outages
  minor,     // 10k-20k outages
  moderate,  // 20k-50k outages
  severe,    // 50k-100k outages
  critical,  // 100k+ outages
}