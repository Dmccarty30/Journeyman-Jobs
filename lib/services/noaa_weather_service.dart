import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'cache_service.dart';

/// NOAA Weather Service for authoritative US weather data
/// 
/// Integrates with multiple NOAA services:
/// - National Weather Service API for alerts and forecasts
/// - NOAA Radar imagery for real-time precipitation
/// - National Hurricane Center for tropical systems
/// - Storm Prediction Center for severe weather outlooks
class NoaaWeatherService {
  static final NoaaWeatherService _instance = NoaaWeatherService._internal();
  factory NoaaWeatherService() => _instance;
  NoaaWeatherService._internal();

  final Dio _dio = Dio(BaseOptions(
    headers: {
      'User-Agent': 'JourneymanJobs/1.0 (IBEW storm work app)',
      'Accept': 'application/json',
    },
  ));
  final CacheService _cacheService = CacheService();
  
  // NOAA API endpoints (all free, no API key required)
  static const String _nwsApiBase = 'https://api.weather.gov';
  static const String _radarBase = 'https://radar.weather.gov/ridge';
  static const String _nhcBase = 'https://www.nhc.noaa.gov';
  static const String _spcBase = 'https://www.spc.noaa.gov';
  
  // Radar products
  static const Map<String, String> radarProducts = {
    'N0R': 'Base Reflectivity', // Default precipitation view
    'N0V': 'Base Velocity', // Storm rotation detection
    'NTP': 'Storm Total Precipitation',
    'N0S': 'Storm Relative Velocity',
    'NCR': 'Composite Reflectivity', // Full volume scan
  };
  
  // Cache durations
  static const Duration _alertsCacheDuration = Duration(minutes: 5);
  static const Duration _radarCacheDuration = Duration(minutes: 2);
  static const Duration _hurricaneCacheDuration = Duration(minutes: 15);
  
  /// Get all active weather alerts for a location
  Future<List<NoaaAlert>> getActiveAlerts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final cacheKey = 'noaa_alerts_${latitude}_${longitude}';
      
      // Check cache first
      final cached = await _cacheService.get<String>(cacheKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        return (data['features'] as List)
            .map((f) => NoaaAlert.fromGeoJson(f))
            .toList();
      }
      
      // Get point data first to find the correct office
      final pointResponse = await _dio.get(
        '$_nwsApiBase/points/$latitude,$longitude',
      );
      
      if (pointResponse.statusCode != 200) {
        throw Exception('Failed to get point data');
      }
      
      final gridId = pointResponse.data['properties']['gridId'];
      final gridX = pointResponse.data['properties']['gridX'];
      final gridY = pointResponse.data['properties']['gridY'];
      
      // Get active alerts
      final alertsResponse = await _dio.get(
        '$_nwsApiBase/alerts/active',
        queryParameters: {
          'point': '$latitude,$longitude',
          'status': 'actual',
          'message_type': 'alert,update',
        },
      );
      
      if (alertsResponse.statusCode == 200) {
        // Cache the response
        await _cacheService.set(
          cacheKey,
          jsonEncode(alertsResponse.data),
          ttl: _alertsCacheDuration,
        );
        
        final alerts = (alertsResponse.data['features'] as List)
            .map((f) => NoaaAlert.fromGeoJson(f))
            .where((alert) => alert.isRelevantForStormWork)
            .toList();
        
        // Sort by severity
        alerts.sort((a, b) => b.severityLevel.compareTo(a.severityLevel));
        
        return alerts;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching NOAA alerts: $e');
      }
      return [];
    }
  }
  
  /// Get nearest NOAA radar station
  Future<NoaaRadarStation?> getNearestRadarStation({
    required double latitude,
    required double longitude,
  }) async {
    final stations = getRadarStations();
    
    NoaaRadarStation? nearest;
    double minDistance = double.infinity;
    
    for (final station in stations) {
      final distance = _calculateDistance(
        latitude, longitude,
        station.latitude, station.longitude,
      );
      
      if (distance < minDistance && distance < station.range) {
        minDistance = distance;
        nearest = station;
      }
    }
    
    return nearest;
  }
  
  /// Get NOAA radar image URL
  String getRadarImageUrl({
    required String stationId,
    String product = 'N0R',
    bool loop = false,
  }) {
    if (loop) {
      // Animated loop of last 10 frames
      return '$_radarBase/standard/${stationId}_loop.gif';
    } else {
      // Latest single frame
      return '$_radarBase/standard/${stationId}/${stationId}_${product}_0.gif';
    }
  }
  
  /// Get enhanced radar with overlays
  String getEnhancedRadarUrl({
    required String stationId,
    String product = 'NCR',
    bool includeWarnings = true,
    bool includeCounties = false,
    bool includeHighways = true,
    bool includeCities = true,
  }) {
    final layers = <String>[];
    if (includeWarnings) layers.add('warnings');
    if (includeCounties) layers.add('counties');
    if (includeHighways) layers.add('highways');
    if (includeCities) layers.add('cities');
    
    final layerString = layers.isNotEmpty ? '_${layers.join('_')}' : '';
    
    return '$_radarBase/standard/${stationId}/${stationId}_${product}${layerString}_0.gif';
  }
  
  /// Get current tropical systems from National Hurricane Center
  Future<List<TropicalSystem>> getActiveTropicalSystems() async {
    try {
      final cacheKey = 'nhc_tropical_systems';
      
      // Check cache
      final cached = await _cacheService.get<String>(cacheKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        return (data as List)
            .map((s) => TropicalSystem.fromJson(s))
            .toList();
      }
      
      // NHC provides RSS/JSON feeds
      final response = await _dio.get(
        '$_nhcBase/CurrentStorms.json',
      );
      
      if (response.statusCode == 200) {
        final systems = <TropicalSystem>[];
        
        // Parse active storms
        final activeStorms = response.data['activeStorms'] ?? [];
        for (final storm in activeStorms) {
          systems.add(TropicalSystem(
            id: storm['id'],
            name: storm['name'],
            classification: storm['classification'],
            latitude: storm['latitude'],
            longitude: storm['longitude'],
            maxWindsMph: storm['maxWinds'],
            movementDirection: storm['movementDir'],
            movementSpeedMph: storm['movementSpeed'],
            pressure: storm['pressure'],
            lastUpdate: DateTime.parse(storm['lastUpdate']),
          ));
        }
        
        // Cache the data
        await _cacheService.set(
          cacheKey,
          jsonEncode(systems.map((s) => s.toJson()).toList()),
          ttl: _hurricaneCacheDuration,
        );
        
        return systems;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tropical systems: $e');
      }
      return [];
    }
  }
  
  /// Get Storm Prediction Center convective outlook
  Future<SpcOutlook?> getSevereWeatherOutlook({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // SPC provides categorical outlooks
      final response = await _dio.get(
        '$_spcBase/products/outlook/day1otlk.json',
      );
      
      if (response.statusCode == 200) {
        // Check if location is in any risk area
        final features = response.data['features'] as List;
        
        for (final feature in features) {
          final properties = feature['properties'];
          final riskLevel = properties['LABEL'];
          
          // Check if point is in polygon (simplified)
          // In production, use proper point-in-polygon algorithm
          
          return SpcOutlook(
            riskLevel: riskLevel,
            validTime: DateTime.parse(properties['VALID']),
            hazards: List<String>.from(properties['hazards'] ?? []),
          );
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching SPC outlook: $e');
      }
      return null;
    }
  }
  
  /// Get NOAA forecast discussion for context
  Future<String?> getForecastDiscussion({
    required String wfoId, // Weather Forecast Office ID
  }) async {
    try {
      final response = await _dio.get(
        '$_nwsApiBase/products',
        queryParameters: {
          'type': 'AFD',
          'office': wfoId,
          'limit': 1,
        },
      );
      
      if (response.statusCode == 200 && response.data['@graph'].isNotEmpty) {
        final productId = response.data['@graph'][0]['@id'];
        
        final textResponse = await _dio.get(productId);
        if (textResponse.statusCode == 200) {
          return textResponse.data['productText'];
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching forecast discussion: $e');
      }
      return null;
    }
  }
  
  /// Calculate distance between coordinates
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
  
  /// Get all US NOAA radar stations
  List<NoaaRadarStation> getRadarStations() {
    return [
      // Major stations covering storm-prone areas
      NoaaRadarStation('KJAX', 'Jacksonville, FL', 30.4847, -81.7019, 'Southeast'),
      NoaaRadarStation('KBRO', 'Brownsville, TX', 25.9161, -97.4189, 'Gulf Coast'),
      NoaaRadarStation('KCRP', 'Corpus Christi, TX', 27.7842, -97.5111, 'Gulf Coast'),
      NoaaRadarStation('KDGX', 'Jackson, MS', 32.2798, -89.9846, 'Southeast'),
      NoaaRadarStation('KEVX', 'Eglin AFB, FL', 30.5644, -85.9214, 'Gulf Coast'),
      NoaaRadarStation('KFWS', 'Fort Worth, TX', 32.5731, -97.3031, 'Texas'),
      NoaaRadarStation('KHGX', 'Houston, TX', 29.4719, -95.0792, 'Gulf Coast'),
      NoaaRadarStation('KLIX', 'New Orleans, LA', 30.3367, -89.8256, 'Gulf Coast'),
      NoaaRadarStation('KLWX', 'Sterling, VA', 38.9753, -77.4778, 'Northeast'),
      NoaaRadarStation('KMHX', 'Morehead City, NC', 34.7759, -76.8762, 'Southeast'),
      NoaaRadarStation('KMOB', 'Mobile, AL', 30.6795, -88.2397, 'Gulf Coast'),
      NoaaRadarStation('KOKX', 'New York City, NY', 40.8653, -72.8639, 'Northeast'),
      NoaaRadarStation('KPAH', 'Paducah, KY', 37.0683, -88.7720, 'Midwest'),
      NoaaRadarStation('KPBZ', 'Pittsburgh, PA', 40.5317, -80.2183, 'Northeast'),
      NoaaRadarStation('KTBW', 'Tampa Bay, FL', 27.7055, -82.4019, 'Florida'),
      NoaaRadarStation('KTLX', 'Oklahoma City, OK', 35.3333, -97.2778, 'Midwest'),
      // Add more stations as needed
    ];
  }
}

/// NOAA Weather Alert
class NoaaAlert {
  final String id;
  final String event;
  final String severity; // Extreme, Severe, Moderate, Minor
  final String urgency; // Immediate, Expected, Future
  final String certainty; // Observed, Likely, Possible
  final DateTime effective;
  final DateTime expires;
  final String headline;
  final String description;
  final String instruction;
  final List<String> affectedZones;
  
  NoaaAlert({
    required this.id,
    required this.event,
    required this.severity,
    required this.urgency,
    required this.certainty,
    required this.effective,
    required this.expires,
    required this.headline,
    required this.description,
    required this.instruction,
    required this.affectedZones,
  });
  
  factory NoaaAlert.fromGeoJson(Map<String, dynamic> feature) {
    final props = feature['properties'];
    return NoaaAlert(
      id: props['id'] ?? '',
      event: props['event'] ?? '',
      severity: props['severity'] ?? 'Unknown',
      urgency: props['urgency'] ?? 'Unknown',
      certainty: props['certainty'] ?? 'Unknown',
      effective: DateTime.parse(props['effective']),
      expires: DateTime.parse(props['expires']),
      headline: props['headline'] ?? '',
      description: props['description'] ?? '',
      instruction: props['instruction'] ?? '',
      affectedZones: List<String>.from(props['areaDesc']?.split('; ') ?? []),
    );
  }
  
  /// Check if this alert is relevant for storm restoration work
  bool get isRelevantForStormWork {
    final relevantEvents = [
      'Hurricane Warning',
      'Hurricane Watch',
      'Tropical Storm Warning',
      'Tropical Storm Watch',
      'Tornado Warning',
      'Tornado Watch',
      'Severe Thunderstorm Warning',
      'Severe Thunderstorm Watch',
      'High Wind Warning',
      'High Wind Watch',
      'Ice Storm Warning',
      'Winter Storm Warning',
      'Blizzard Warning',
      'Flood Warning',
      'Flash Flood Warning',
    ];
    
    return relevantEvents.any((e) => event.contains(e));
  }
  
  /// Get severity level for sorting (higher = more severe)
  int get severityLevel {
    if (severity == 'Extreme') return 4;
    if (severity == 'Severe') return 3;
    if (severity == 'Moderate') return 2;
    if (severity == 'Minor') return 1;
    return 0;
  }
}

/// NOAA Radar Station
class NoaaRadarStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String region;
  final double range; // Coverage radius in miles
  
  NoaaRadarStation(
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.region, {
    this.range = 200, // Default 200 mile range
  });
}

/// Tropical System from National Hurricane Center
class TropicalSystem {
  final String id;
  final String name;
  final String classification; // Hurricane, Tropical Storm, etc.
  final double latitude;
  final double longitude;
  final int maxWindsMph;
  final String movementDirection;
  final int movementSpeedMph;
  final int pressure;
  final DateTime lastUpdate;
  
  TropicalSystem({
    required this.id,
    required this.name,
    required this.classification,
    required this.latitude,
    required this.longitude,
    required this.maxWindsMph,
    required this.movementDirection,
    required this.movementSpeedMph,
    required this.pressure,
    required this.lastUpdate,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'classification': classification,
    'latitude': latitude,
    'longitude': longitude,
    'maxWindsMph': maxWindsMph,
    'movementDirection': movementDirection,
    'movementSpeedMph': movementSpeedMph,
    'pressure': pressure,
    'lastUpdate': lastUpdate.toIso8601String(),
  };
  
  factory TropicalSystem.fromJson(Map<String, dynamic> json) => TropicalSystem(
    id: json['id'],
    name: json['name'],
    classification: json['classification'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    maxWindsMph: json['maxWindsMph'],
    movementDirection: json['movementDirection'],
    movementSpeedMph: json['movementSpeedMph'],
    pressure: json['pressure'],
    lastUpdate: DateTime.parse(json['lastUpdate']),
  );
}

/// Storm Prediction Center Outlook
class SpcOutlook {
  final String riskLevel; // TSTM, MRGL, SLGT, ENH, MDT, HIGH
  final DateTime validTime;
  final List<String> hazards; // tornado, wind, hail
  
  SpcOutlook({
    required this.riskLevel,
    required this.validTime,
    required this.hazards,
  });
}