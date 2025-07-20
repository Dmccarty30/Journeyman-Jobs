import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'cache_service.dart';

/// Weather radar data service using RainViewer API
/// 
/// Provides real-time weather radar data including:
/// - Precipitation radar tiles
/// - Satellite cloud coverage
/// - Weather warnings overlay
/// - Animated radar frames for storm tracking
class WeatherRadarService {
  static final WeatherRadarService _instance = WeatherRadarService._internal();
  factory WeatherRadarService() => _instance;
  WeatherRadarService._internal();

  final Dio _dio = Dio();
  final CacheService _cacheService = CacheService();
  
  // RainViewer API endpoints
  static const String _baseUrl = 'https://api.rainviewer.com/public/weather-maps.json';
  static const String _tileUrl = 'https://tilecache.rainviewer.com';
  
  // NOAA radar endpoints (backup/additional data)
  static const String _noaaRadarBase = 'https://radar.weather.gov/ridge/standard';
  
  // Cache configuration
  static const Duration _radarCacheDuration = Duration(minutes: 5);
  static const Duration _satelliteCacheDuration = Duration(minutes: 15);
  
  // Current radar data
  RadarData? _currentRadarData;
  Timer? _refreshTimer;
  
  /// Initialize the service and start periodic updates
  Future<void> initialize() async {
    await _fetchRadarData();
    
    // Set up periodic refresh every 5 minutes
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchRadarData(),
    );
  }
  
  /// Dispose of resources
  void dispose() {
    _refreshTimer?.cancel();
  }
  
  /// Get current radar data
  Future<RadarData?> getRadarData() async {
    if (_currentRadarData == null || _isDataStale()) {
      await _fetchRadarData();
    }
    return _currentRadarData;
  }
  
  /// Fetch latest radar data from RainViewer API
  Future<void> _fetchRadarData() async {
    try {
      final cacheKey = 'radar_data_latest';
      
      // Try cache first
      final cached = await _cacheService.get<String>(cacheKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        _currentRadarData = RadarData.fromJson(data);
        
        // Check if cache is still fresh
        if (!_isDataStale()) {
          return;
        }
      }
      
      // Fetch fresh data
      final response = await _dio.get(_baseUrl);
      
      if (response.statusCode == 200) {
        _currentRadarData = RadarData.fromJson(response.data);
        
        // Cache the data
        await _cacheService.set(
          cacheKey,
          jsonEncode(response.data),
          ttl: _radarCacheDuration,
        );
        
        if (kDebugMode) {
          print('Radar data updated: ${_currentRadarData!.radar.past.length} past frames, '
                '${_currentRadarData!.radar.nowcast.length} forecast frames');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching radar data: $e');
      }
    }
  }
  
  /// Check if current data is stale
  bool _isDataStale() {
    if (_currentRadarData == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final latestTime = _currentRadarData!.generated;
    
    // Data is stale if more than 10 minutes old
    return (now - latestTime) > 600;
  }
  
  /// Get radar tile URL for a specific timestamp
  String getRadarTileUrl({
    required int timestamp,
    required int zoom,
    required int x,
    required int y,
    int size = 256,
    RadarColorScheme colorScheme = RadarColorScheme.universal,
    bool smooth = true,
    bool snow = false,
  }) {
    final colorCode = _getColorSchemeCode(colorScheme);
    final options = smooth ? 1 : 0;
    final snowOption = snow ? 1 : 0;
    
    return '$_tileUrl/v2/radar/$timestamp/$size/$zoom/$x/$y/$colorCode/$options'
           '_$snowOption.png';
  }
  
  /// Get satellite (infrared) tile URL
  String getSatelliteTileUrl({
    required int zoom,
    required int x,
    required int y,
    int size = 256,
  }) {
    if (_currentRadarData?.satellite.infrared.isEmpty ?? true) {
      return '';
    }
    
    final timestamp = _currentRadarData!.satellite.infrared.last.time;
    return '$_tileUrl/v2/satellite/$timestamp/$size/$zoom/$x/$y/0/0_0.png';
  }
  
  /// Get current weather warnings/alerts
  Future<List<WeatherAlert>> getWeatherAlerts({
    double? latitude,
    double? longitude,
  }) async {
    // TODO: Integrate with NWS API for US weather alerts
    // For now, return empty list
    return [];
  }
  
  /// Get animated radar frames for the last hour
  List<RadarFrame> getAnimationFrames() {
    if (_currentRadarData == null) return [];
    
    final frames = <RadarFrame>[];
    
    // Add past frames (last hour)
    frames.addAll(_currentRadarData!.radar.past.map((frame) => 
      RadarFrame(
        timestamp: frame.time,
        path: frame.path,
        type: RadarFrameType.past,
      ),
    ));
    
    // Add current frame
    if (_currentRadarData!.radar.past.isNotEmpty) {
      final latest = _currentRadarData!.radar.past.last;
      frames.add(RadarFrame(
        timestamp: latest.time,
        path: latest.path,
        type: RadarFrameType.current,
      ));
    }
    
    // Add forecast frames (next 30 minutes)
    frames.addAll(_currentRadarData!.radar.nowcast.take(6).map((frame) => 
      RadarFrame(
        timestamp: frame.time,
        path: frame.path,
        type: RadarFrameType.forecast,
      ),
    ));
    
    return frames;
  }
  
  /// Get NOAA radar station data for a specific location
  Future<String?> getNearestRadarStation({
    required double latitude,
    required double longitude,
  }) async {
    // US radar stations with approximate coverage
    final stations = _getRadarStations();
    
    String? nearestStation;
    double minDistance = double.infinity;
    
    for (final station in stations.entries) {
      final distance = _calculateDistance(
        latitude, longitude,
        station.value['lat']!, station.value['lon']!,
      );
      
      if (distance < minDistance && distance < 200) { // 200 mile radius
        minDistance = distance;
        nearestStation = station.key;
      }
    }
    
    return nearestStation;
  }
  
  /// Get NOAA radar image URL for a specific station
  String getNoaaRadarUrl({
    required String station,
    String product = 'N0R', // Base reflectivity
  }) {
    return '$_noaaRadarBase/$station/${station}_$product.gif';
  }
  
  /// Convert color scheme to API code
  int _getColorSchemeCode(RadarColorScheme scheme) {
    switch (scheme) {
      case RadarColorScheme.blackAndWhite:
        return 0;
      case RadarColorScheme.original:
        return 1;
      case RadarColorScheme.universal:
        return 2;
      case RadarColorScheme.titan:
        return 3;
      case RadarColorScheme.theWeatherChannel:
        return 4;
      case RadarColorScheme.meteored:
        return 5;
      case RadarColorScheme.nexradLevel3:
        return 6;
      case RadarColorScheme.rainbowSelex:
        return 7;
      case RadarColorScheme.darkSky:
        return 8;
    }
  }
  
  /// Calculate distance between two coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 3959; // miles
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) => degrees * pi / 180;
  
  /// Get major US radar station locations
  Map<String, Map<String, double>> _getRadarStations() {
    return {
      'KJAX': {'lat': 30.4847, 'lon': -81.7019}, // Jacksonville, FL
      'KBGM': {'lat': 42.1997, 'lon': -75.9847}, // Binghamton, NY
      'KBOX': {'lat': 41.9558, 'lon': -71.1369}, // Boston, MA
      'KBRO': {'lat': 25.9161, 'lon': -97.4189}, // Brownsville, TX
      'KBUF': {'lat': 42.9489, 'lon': -78.7367}, // Buffalo, NY
      'KCLE': {'lat': 41.4131, 'lon': -81.8597}, // Cleveland, OH
      'KCRP': {'lat': 27.7842, 'lon': -97.5111}, // Corpus Christi, TX
      'KDDC': {'lat': 37.7608, 'lon': -99.9689}, // Dodge City, KS
      'KDLH': {'lat': 46.8369, 'lon': -92.2097}, // Duluth, MN
      'KDMX': {'lat': 41.7311, 'lon': -93.7228}, // Des Moines, IA
      'KDTX': {'lat': 42.6997, 'lon': -83.4719}, // Detroit, MI
      'KEAX': {'lat': 38.8103, 'lon': -94.2644}, // Kansas City, MO
      'KEWX': {'lat': 29.7039, 'lon': -98.0286}, // San Antonio, TX
      'KFWS': {'lat': 32.5731, 'lon': -97.3031}, // Fort Worth, TX
      'KGRB': {'lat': 44.4986, 'lon': -88.1111}, // Green Bay, WI
      'KHGX': {'lat': 29.4719, 'lon': -95.0792}, // Houston, TX
      'KIND': {'lat': 39.7075, 'lon': -86.2803}, // Indianapolis, IN
      'KLVX': {'lat': 37.9753, 'lon': -85.9439}, // Louisville, KY
      'KMKX': {'lat': 42.9678, 'lon': -88.5506}, // Milwaukee, WI
      'KMPX': {'lat': 44.8489, 'lon': -93.5656}, // Minneapolis, MN
      'KOHX': {'lat': 36.2472, 'lon': -86.5625}, // Nashville, TN
      'KOKX': {'lat': 40.8653, 'lon': -72.8639}, // New York City, NY
      'KPBZ': {'lat': 40.5317, 'lon': -80.2183}, // Pittsburgh, PA
      'KPHX': {'lat': 33.4353, 'lon': -112.1553}, // Phoenix, AZ
      'KSGF': {'lat': 37.2353, 'lon': -93.4006}, // Springfield, MO
      'KTLX': {'lat': 35.3333, 'lon': -97.2778}, // Oklahoma City, OK
      // Add more stations as needed
    };
  }
}

/// Radar data model
class RadarData {
  final int version;
  final int generated;
  final String host;
  final RadarInfo radar;
  final SatelliteInfo satellite;
  
  RadarData({
    required this.version,
    required this.generated,
    required this.host,
    required this.radar,
    required this.satellite,
  });
  
  factory RadarData.fromJson(Map<String, dynamic> json) {
    return RadarData(
      version: json['version'] ?? 0,
      generated: json['generated'] ?? 0,
      host: json['host'] ?? '',
      radar: RadarInfo.fromJson(json['radar'] ?? {}),
      satellite: SatelliteInfo.fromJson(json['satellite'] ?? {}),
    );
  }
}

/// Radar information
class RadarInfo {
  final List<RadarTimeFrame> past;
  final List<RadarTimeFrame> nowcast;
  
  RadarInfo({
    required this.past,
    required this.nowcast,
  });
  
  factory RadarInfo.fromJson(Map<String, dynamic> json) {
    return RadarInfo(
      past: (json['past'] as List<dynamic>?)
          ?.map((e) => RadarTimeFrame.fromJson(e))
          .toList() ?? [],
      nowcast: (json['nowcast'] as List<dynamic>?)
          ?.map((e) => RadarTimeFrame.fromJson(e))
          .toList() ?? [],
    );
  }
}

/// Satellite information
class SatelliteInfo {
  final List<RadarTimeFrame> infrared;
  
  SatelliteInfo({
    required this.infrared,
  });
  
  factory SatelliteInfo.fromJson(Map<String, dynamic> json) {
    return SatelliteInfo(
      infrared: (json['infrared'] as List<dynamic>?)
          ?.map((e) => RadarTimeFrame.fromJson(e))
          .toList() ?? [],
    );
  }
}

/// Radar time frame
class RadarTimeFrame {
  final int time;
  final String path;
  
  RadarTimeFrame({
    required this.time,
    required this.path,
  });
  
  factory RadarTimeFrame.fromJson(Map<String, dynamic> json) {
    return RadarTimeFrame(
      time: json['time'] ?? 0,
      path: json['path'] ?? '',
    );
  }
}

/// Radar frame for animation
class RadarFrame {
  final int timestamp;
  final String path;
  final RadarFrameType type;
  
  RadarFrame({
    required this.timestamp,
    required this.path,
    required this.type,
  });
  
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

/// Radar frame type
enum RadarFrameType {
  past,
  current,
  forecast,
}

/// Radar color schemes
enum RadarColorScheme {
  blackAndWhite,
  original,
  universal,
  titan,
  theWeatherChannel,
  meteored,
  nexradLevel3,
  rainbowSelex,
  darkSky,
}

/// Weather alert model
class WeatherAlert {
  final String id;
  final String title;
  final String description;
  final String severity;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> affectedAreas;
  
  WeatherAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.startTime,
    required this.endTime,
    required this.affectedAreas,
  });
}