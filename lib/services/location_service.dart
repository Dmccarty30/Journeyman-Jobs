import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';
import 'geographic_firestore_service.dart';
import 'cache_service.dart';

/// Mock location permission enum (fallback for geolocator)
enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
  disabled,
}

/// Mock location accuracy enum (fallback for geolocator)
enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation,
  reduced,
  balanced,
}

/// Mock position class (fallback for geolocator)
class Position {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedAccuracy;
  final double altitudeAccuracy;
  final double headingAccuracy;

  Position({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
    required this.altitudeAccuracy,
    required this.headingAccuracy,
  });
}

/// Mock geolocator service (fallback)
class _MockGeolocator {
  static Future<bool> isLocationServiceEnabled() async {
    // Mock implementation - in real app would check actual location services
    return true;
  }
  
  static Future<LocationPermission> checkPermission() async {
    // Mock implementation - in real app would check actual permissions
    return LocationPermission.whileInUse;
  }
  
  static Future<LocationPermission> requestPermission() async {
    // Mock implementation - in real app would request actual permissions
    return LocationPermission.whileInUse;
  }
  
  static Future<Position> getCurrentPosition({
    Duration? timeLimit,
  }) async {
    // Mock implementation - return approximate US center coordinates
    return Position(
      latitude: 39.8283,
      longitude: -98.5795,
      timestamp: DateTime.now(),
      accuracy: 100.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}

/// Location-based service for job matching and geographic queries
/// 
/// Provides advanced location capabilities including:
/// - Location-based job search within configurable radius
/// - Distance calculation and sorting by proximity  
/// - GPS permission handling with fallback strategies
/// - Geocoding for address-to-coordinates conversion
/// - State-based fallback when location unavailable
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final GeographicFirestoreService _geographicService = GeographicFirestoreService();
  final CacheService _cacheService = CacheService();
  
  // Location configuration
  static const double defaultRadiusMiles = 50.0;
  static const double maxRadiusMiles = 200.0;
  static const double earthRadiusMiles = 3959.0; // Earth's radius in miles
  static const Duration locationCacheTimeout = Duration(minutes: 30);
  
  // Cache keys
  static const String _lastLocationKey = 'last_known_location';
  static const String _locationPermissionKey = 'location_permission_status';
  
  // Current state
  Position? _lastKnownPosition;
  LocationPermission? _cachedPermissionStatus;
  Timer? _locationUpdateTimer;
  
  /// Get jobs near a specific location with distance filtering and sorting
  Future<List<JobWithDistance>> getJobsNearLocation({
    required double latitude,
    required double longitude,
    double radiusMiles = defaultRadiusMiles,
    int limit = 20,
    String? classification,
    String? typeOfWork,
  }) async {
    try {
      // Validate inputs
      radiusMiles = radiusMiles.clamp(1.0, maxRadiusMiles);
      
      // Convert radius to approximate degrees for bounding box
      final radiusDegrees = radiusMiles / 69.0; // Rough approximation: 1 degree ≈ 69 miles
      
      // Get state for regional optimization
      final state = await _getStateFromCoordinates(latitude, longitude);
      final targetRegion = _geographicService.getRegionFromState(state);
      
      if (kDebugMode) {
        print('Searching for jobs near ($latitude, $longitude) within $radiusMiles miles');
      }
      
      // Get jobs in expanded bounding box to ensure we don't miss edge cases
      final expandedLimit = limit * 3; // Get extra to filter by exact distance
      List<Job> candidateJobs;
      
      if (targetRegion != 'all') {
        // Use regional optimization when possible
        candidateJobs = await _getRegionalJobsInBoundingBox(
          region: targetRegion,
          centerLat: latitude,
          centerLng: longitude,
          radiusDegrees: radiusDegrees,
          limit: expandedLimit,
          classification: classification,
          typeOfWork: typeOfWork,
        );
      } else {
        // Fallback to global search
        candidateJobs = await _getJobsInBoundingBox(
          centerLat: latitude,
          centerLng: longitude,
          radiusDegrees: radiusDegrees,
          limit: expandedLimit,
          classification: classification,
          typeOfWork: typeOfWork,
        );
      }
      
      // Calculate exact distances and filter by radius
      final jobsWithDistance = <JobWithDistance>[];
      
      for (final job in candidateJobs) {
        final jobCoords = await _getJobCoordinates(job);
        if (jobCoords != null) {
          final distance = calculateDistance(
            latitude, longitude,
            jobCoords.latitude, jobCoords.longitude,
          );
          
          if (distance <= radiusMiles) {
            jobsWithDistance.add(JobWithDistance(
              job: job,
              distance: distance,
              coordinates: jobCoords,
            ));
          }
        }
      }
      
      // Sort by distance and return limited results
      jobsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      
      if (kDebugMode) {
        print('Found ${jobsWithDistance.length} jobs within $radiusMiles miles');
      }
      
      return jobsWithDistance.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in location-based job search: $e');
      }
      // Fallback to state-based search
      return await _fallbackToStateBased(
        state: await _getStateFromCoordinates(latitude, longitude),
        limit: limit,
        classification: classification,
        typeOfWork: typeOfWork,
      );
    }
  }
  
  /// Get current user location with permission handling
  Future<Position?> getCurrentLocation({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cached location first
      if (!forceRefresh && _lastKnownPosition != null) {
        final age = DateTime.now().difference(_lastKnownPosition!.timestamp);
        if (age < locationCacheTimeout) {
          return _lastKnownPosition;
        }
      }
      
      // Check location permissions
      final permission = await _checkLocationPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        if (kDebugMode) {
          print('Location permission denied: $permission');
        }
        return _lastKnownPosition; // Return cached if available
      }
      
      // Get current position
      final position = await _MockGeolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      
      // Cache the position
      _lastKnownPosition = position;
      await _cacheLocation(position);
      
      if (kDebugMode) {
        print('Location updated: ${position.latitude}, ${position.longitude}');
      }
      
      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      
      // Try to load cached location
      return await _loadCachedLocation() ?? _lastKnownPosition;
    }
  }
  
  /// Get jobs near current user location
  Future<List<JobWithDistance>> getJobsNearCurrentLocation({
    double radiusMiles = defaultRadiusMiles,
    int limit = 20,
    String? classification,
    String? typeOfWork,
  }) async {
    final position = await getCurrentLocation();
    
    if (position != null) {
      return await getJobsNearLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusMiles: radiusMiles,
        limit: limit,
        classification: classification,
        typeOfWork: typeOfWork,
      );
    } else {
      // Fallback to region-based search without location
      if (kDebugMode) {
        print('No location available, falling back to regional search');
      }
      return await _fallbackToStateBased(
        state: null,
        limit: limit,
        classification: classification,
        typeOfWork: typeOfWork,
      );
    }
  }
  
  /// Get locals near a specific location
  Future<List<LocalWithDistance>> getLocalsNearLocation({
    required double latitude,
    required double longitude,
    double radiusMiles = defaultRadiusMiles,
    int limit = 20,
  }) async {
    try {
      radiusMiles = radiusMiles.clamp(1.0, maxRadiusMiles);
      final radiusDegrees = radiusMiles / 69.0;
      
      // Get state for regional optimization
      final state = await _getStateFromCoordinates(latitude, longitude);
      final targetRegion = _geographicService.getRegionFromState(state);
      
      // Get locals in bounding box
      List<LocalsRecord> candidateLocals;
      if (targetRegion != 'all') {
        candidateLocals = await _getRegionalLocalsInBoundingBox(
          region: targetRegion,
          centerLat: latitude,
          centerLng: longitude,
          radiusDegrees: radiusDegrees,
          limit: limit * 2,
        );
      } else {
        candidateLocals = await _getLocalsInBoundingBox(
          centerLat: latitude,
          centerLng: longitude,
          radiusDegrees: radiusDegrees,
          limit: limit * 2,
        );
      }
      
      // Calculate distances and filter
      final localsWithDistance = <LocalWithDistance>[];
      
      for (final local in candidateLocals) {
        final localCoords = await _getLocalCoordinates(local);
        if (localCoords != null) {
          final distance = calculateDistance(
            latitude, longitude,
            localCoords.latitude, localCoords.longitude,
          );
          
          if (distance <= radiusMiles) {
            localsWithDistance.add(LocalWithDistance(
              local: local,
              distance: distance,
              coordinates: localCoords,
            ));
          }
        }
      }
      
      // Sort by distance
      localsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      
      return localsWithDistance.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in location-based locals search: $e');
      }
      return [];
    }
  }
  
  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusMiles * c;
  }
  
  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
  
  /// Check and request location permissions
  Future<LocationPermission> _checkLocationPermission() async {
    // Check cached permission first
    if (_cachedPermissionStatus != null) {
      return _cachedPermissionStatus!;
    }
    
    // Check if location services are enabled
    bool serviceEnabled = await _MockGeolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _cachedPermissionStatus = LocationPermission.disabled;
      return LocationPermission.disabled;
    }
    
    // Check current permission
    LocationPermission permission = await _MockGeolocator.checkPermission();
    
    // Request permission if needed
    if (permission == LocationPermission.denied) {
      permission = await _MockGeolocator.requestPermission();
    }
    
    // Cache the result
    _cachedPermissionStatus = permission;
    await _cachePermissionStatus(permission);
    
    return permission;
  }
  
  /// Get jobs in bounding box with filters
  Future<List<Job>> _getJobsInBoundingBox({
    required double centerLat,
    required double centerLng,
    required double radiusDegrees,
    required int limit,
    String? classification,
    String? typeOfWork,
  }) async {
    Query query = FirebaseFirestore.instance.collection('jobs');
    
    // Apply bounding box filter
    query = query
        .where('latitude', isGreaterThan: centerLat - radiusDegrees)
        .where('latitude', isLessThan: centerLat + radiusDegrees);
    
    // Apply additional filters
    if (classification != null) {
      query = query.where('classification', isEqualTo: classification);
    }
    if (typeOfWork != null) {
      query = query.where('typeOfWork', isEqualTo: typeOfWork);
    }
    
    query = query.limit(limit);
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }
  
  /// Get regional jobs in bounding box
  Future<List<Job>> _getRegionalJobsInBoundingBox({
    required String region,
    required double centerLat,
    required double centerLng,
    required double radiusDegrees,
    required int limit,
    String? classification,
    String? typeOfWork,
  }) async {
    final collection = FirebaseFirestore.instance
        .collection('jobs_regions')
        .doc(region)
        .collection('jobs');
    
    Query query = collection
        .where('latitude', isGreaterThan: centerLat - radiusDegrees)
        .where('latitude', isLessThan: centerLat + radiusDegrees);
    
    if (classification != null) {
      query = query.where('classification', isEqualTo: classification);
    }
    if (typeOfWork != null) {
      query = query.where('typeOfWork', isEqualTo: typeOfWork);
    }
    
    query = query.limit(limit);
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }
  
  /// Get locals in bounding box
  Future<List<LocalsRecord>> _getLocalsInBoundingBox({
    required double centerLat,
    required double centerLng,
    required double radiusDegrees,
    required int limit,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locals')
        .where('latitude', isGreaterThan: centerLat - radiusDegrees)
        .where('latitude', isLessThan: centerLat + radiusDegrees)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => LocalsRecord.fromFirestore(doc))
        .toList();
  }
  
  /// Get regional locals in bounding box
  Future<List<LocalsRecord>> _getRegionalLocalsInBoundingBox({
    required String region,
    required double centerLat,
    required double centerLng,
    required double radiusDegrees,
    required int limit,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locals_regions')
        .doc(region)
        .collection('locals')
        .where('latitude', isGreaterThan: centerLat - radiusDegrees)
        .where('latitude', isLessThan: centerLat + radiusDegrees)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => LocalsRecord.fromFirestore(doc))
        .toList();
  }
  
  /// Get coordinates for a job (with caching and geocoding fallback)
  Future<Coordinates?> _getJobCoordinates(Job job) async {
    // Job model doesn't have latitude/longitude fields, only location string
    // Try geocoding from address/location
    
    // Try geocoding from address/location
    if (job.location.isNotEmpty) {
      return await _geocodeAddress(job.location);
    }
    
    return null;
  }
  
  /// Get coordinates for a local union
  Future<Coordinates?> _getLocalCoordinates(LocalsRecord local) async {
    // Try geocoding from location field
    return await _geocodeAddress(local.location);
  }
  
  /// Geocode address to coordinates with caching
  Future<Coordinates?> _geocodeAddress(String address) async {
    try {
      final cacheKey = 'geocode_${address.hashCode}';
      
      // Try cache first
      final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return Coordinates(cached['latitude'], cached['longitude']);
      }
      
      // Geocode the address (placeholder - would need actual geocoding service)
      // For now, extract state and use approximate center coordinates
      final coordinates = await _approximateCoordinatesFromAddress(address);
      
      // Cache the result
      if (coordinates != null) {
        await _cacheService.set(
          cacheKey,
          {
            'latitude': coordinates.latitude,
            'longitude': coordinates.longitude,
          },
          ttl: const Duration(days: 30), // Addresses don't change often
        );
      }
      
      return coordinates;
    } catch (e) {
      if (kDebugMode) {
        print('Error geocoding address "$address": $e');
      }
      return null;
    }
  }
  
  /// Approximate coordinates from address (fallback method)
  Future<Coordinates?> _approximateCoordinatesFromAddress(String address) async {
    // Simple state-based coordinate approximation
    final stateCenters = {
      'CA': Coordinates(36.7783, -119.4179),
      'TX': Coordinates(31.9686, -99.9018),
      'FL': Coordinates(27.7663, -81.6868),
      'NY': Coordinates(40.7589, -73.9851),
      'PA': Coordinates(40.2732, -76.8751),
      'IL': Coordinates(40.3363, -89.0022),
      'OH': Coordinates(40.3888, -82.7649),
      // Add more as needed
    };
    
    for (final entry in stateCenters.entries) {
      if (address.toUpperCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  /// Get state from coordinates (reverse geocoding approximation)
  Future<String?> _getStateFromCoordinates(double latitude, double longitude) async {
    // Simple bounding box approach for major states
    if (latitude >= 32.5 && latitude <= 42.0 && longitude >= -124.5 && longitude <= -114.0) {
      return 'CA';
    }
    if (latitude >= 25.8 && latitude <= 36.5 && longitude >= -106.6 && longitude <= -93.5) {
      return 'TX';
    }
    // Add more state boundaries as needed
    
    return null;
  }
  
  /// Fallback to state-based search when location is unavailable
  Future<List<JobWithDistance>> _fallbackToStateBased({
    String? state,
    required int limit,
    String? classification,
    String? typeOfWork,
  }) async {
    try {
      // Use the geographic service for region-based search
      final filters = <String, dynamic>{};
      if (state != null) filters['state'] = state;
      if (classification != null) filters['classification'] = classification;
      if (typeOfWork != null) filters['typeOfWork'] = typeOfWork;
      
      final snapshot = await _geographicService.getJobs(
        limit: limit,
        filters: filters,
      ).first;
      
      // Convert to JobWithDistance without actual distance calculation
      return snapshot.docs
          .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .map((job) => JobWithDistance(
                job: job,
                distance: -1, // Indicates no distance calculated
                coordinates: null,
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in state-based fallback: $e');
      }
      return [];
    }
  }
  
  /// Cache location for offline use
  Future<void> _cacheLocation(Position position) async {
    try {
      await _cacheService.set(
        _lastLocationKey,
        {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': position.timestamp.toIso8601String(),
        },
        ttl: locationCacheTimeout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error caching location: $e');
      }
    }
  }
  
  /// Load cached location
  Future<Position?> _loadCachedLocation() async {
    try {
      final cached = await _cacheService.get<Map<String, dynamic>>(_lastLocationKey);
      if (cached != null) {
        return Position(
          latitude: cached['latitude'],
          longitude: cached['longitude'],
          timestamp: DateTime.parse(cached['timestamp']),
          accuracy: cached['accuracy'],
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached location: $e');
      }
    }
    return null;
  }
  
  /// Cache permission status
  Future<void> _cachePermissionStatus(LocationPermission permission) async {
    try {
      await _cacheService.set(
        _locationPermissionKey,
        permission.index,
        ttl: const Duration(hours: 1),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error caching permission status: $e');
      }
    }
  }
  
  /// Get location service status
  Map<String, dynamic> getLocationStatus() {
    return {
      'hasLastKnownLocation': _lastKnownPosition != null,
      'lastLocationAge': _lastKnownPosition != null
          ? DateTime.now().difference(_lastKnownPosition!.timestamp).inMinutes
          : null,
      'permissionStatus': _cachedPermissionStatus?.toString(),
      'defaultRadius': defaultRadiusMiles,
      'maxRadius': maxRadiusMiles,
      'cacheTimeout': locationCacheTimeout.inMinutes,
    };
  }
  
  /// Clear location cache and reset permissions
  Future<void> clearLocationData() async {
    _lastKnownPosition = null;
    _cachedPermissionStatus = null;
    _locationUpdateTimer?.cancel();
    
    await _cacheService.remove(_lastLocationKey);
    await _cacheService.remove(_locationPermissionKey);
  }
}

/// Job with calculated distance information
class JobWithDistance {
  final Job job;
  final double distance; // Distance in miles (-1 if not calculated)
  final Coordinates? coordinates;
  
  JobWithDistance({
    required this.job,
    required this.distance,
    this.coordinates,
  });
  
  /// Get formatted distance string
  String get formattedDistance {
    if (distance < 0) return 'Distance unknown';
    if (distance < 1) return '${(distance * 5280).round()} ft';
    return '${distance.toStringAsFixed(1)} mi';
  }
  
  /// Check if distance was calculated
  bool get hasDistance => distance >= 0;
}

/// Local union with calculated distance information
class LocalWithDistance {
  final LocalsRecord local;
  final double distance; // Distance in miles
  final Coordinates coordinates;
  
  LocalWithDistance({
    required this.local,
    required this.distance,
    required this.coordinates,
  });
  
  /// Get formatted distance string
  String get formattedDistance {
    if (distance < 1) return '${(distance * 5280).round()} ft';
    return '${distance.toStringAsFixed(1)} mi';
  }
}

/// Simple coordinates class
class Coordinates {
  final double latitude;
  final double longitude;
  
  Coordinates(this.latitude, this.longitude);
  
  @override
  String toString() => '($latitude, $longitude)';
}