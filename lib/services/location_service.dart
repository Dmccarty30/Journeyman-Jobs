import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import '../models/job_model.dart';
import '../models/locals_record.dart';
import 'geographic_firestore_service.dart';
import 'cache_service.dart';


/// A service providing advanced location-based functionalities.
///
/// This service handles location-based job and IBEW local searches, distance
/// calculations, GPS permission management, and geocoding. It integrates with
/// [GeographicFirestoreService] for optimized regional queries and uses
/// caching to improve performance.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  /// Provides a singleton instance of the [LocationService].
  factory LocationService() => _instance;
  LocationService._internal();

  final GeographicFirestoreService _geographicService = GeographicFirestoreService();
  final CacheService _cacheService = CacheService();
  
  // Location configuration
  /// The default search radius in miles for location-based queries.
  static const double defaultRadiusMiles = 50.0;
  /// The maximum allowable search radius in miles.
  static const double maxRadiusMiles = 200.0;
  /// The approximate radius of the Earth in miles, used for distance calculations.
  static const double earthRadiusMiles = 3959.0; // Earth's radius in miles
  /// The duration for which a fetched location is cached.
  static const Duration locationCacheTimeout = Duration(minutes: 30);
  
  // Cache keys
  static const String _lastLocationKey = 'last_known_location';
  static const String _locationPermissionKey = 'location_permission_status';
  
  // Current state
  Position? _lastKnownPosition;
  LocationPermission? _cachedPermissionStatus;
  Timer? _locationUpdateTimer;
  
  /// Retrieves jobs near a specified geographic location, filtered by radius and other criteria.
  ///
  /// The method performs a bounding box query and then filters the results by precise
  /// distance using the Haversine formula. It leverages regional sharding for performance.
  ///
  /// - [latitude]: The latitude of the search center.
  /// - [longitude]: The longitude of the search center.
  /// - [radiusMiles]: The search radius in miles.
  /// - [limit]: The maximum number of jobs to return.
  /// - [classification]: Optional job classification to filter by.
  /// - [typeOfWork]: Optional type of work to filter by.
  ///
  /// Returns a `Future<List<JobWithDistance>>` sorted by proximity.
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
  
  /// Retrieves the user's current geographic position.
  ///
  /// Handles location permission checks and requests. It uses a cached location
  /// to avoid unnecessary GPS calls unless [forceRefresh] is `true`.
  ///
  /// - [forceRefresh]: If `true`, it will bypass the cache and fetch a new location.
  ///
  /// Returns a `Future<Position?>`, which is the user's current position, a cached
  /// position, or `null` if permission is denied or an error occurs.
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
      
      // Get current position with high accuracy for weather tracking
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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
  
  /// Retrieves jobs near the user's current location.
  ///
  /// A convenience method that first calls [getCurrentLocation] and then
  /// passes the result to [getJobsNearLocation].
  ///
  /// - [radiusMiles]: The search radius in miles.
  /// - [limit]: The maximum number of jobs to return.
  /// - [classification]: Optional job classification to filter by.
  /// - [typeOfWork]: Optional type of work to filter by.
  ///
  /// Returns a `Future<List<JobWithDistance>>`.
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
  
  /// Retrieves IBEW locals near a specified geographic location.
  ///
  /// Similar to [getJobsNearLocation], it uses a bounding box query followed by
  /// precise distance filtering.
  ///
  /// - [latitude]: The latitude of the search center.
  /// - [longitude]: The longitude of the search center.
  /// - [radiusMiles]: The search radius in miles.
  /// - [limit]: The maximum number of locals to return.
  ///
  /// Returns a `Future<List<LocalWithDistance>>` sorted by proximity.
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
  
  /// Calculates the distance in miles between two geographic points using the Haversine formula.
  ///
  /// - [lat1], [lon1]: Latitude and longitude of the first point.
  /// - [lat2], [lon2]: Latitude and longitude of the second point.
  ///
  /// Returns the distance as a `double`.
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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _cachedPermissionStatus = LocationPermission.deniedForever;
      
      // Prompt user to enable location services
      if (kDebugMode) {
        print('Location services are disabled. Please enable them.');
      }
      
      // Optionally open location settings
      // await Geolocator.openLocationSettings();
      
      return LocationPermission.deniedForever;
    }
    
    // Check current permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    // Request permission if needed
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately
        if (kDebugMode) {
          print('Location permissions denied by user');
        }
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      if (kDebugMode) {
        print('Location permissions permanently denied. User must enable in settings.');
      }
      
      // Optionally open app settings
      // await permission.openAppSettings();
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
  
  /// Retrieves the current status of the location service.
  ///
  /// Returns a map with information about the last known location, permission
  /// status, and configuration settings.
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
  
  /// Clears all cached location data, including the last known position and permission status.
  Future<void> clearLocationData() async {
    _lastKnownPosition = null;
    _cachedPermissionStatus = null;
    _locationUpdateTimer?.cancel();
    
    await _cacheService.remove(_lastLocationKey);
    await _cacheService.remove(_locationPermissionKey);
  }
  
  /// Requests location permission specifically for the weather radar feature.
  ///
  /// Provides a detailed status map for the UI to give appropriate feedback
  /// to the user, whether permission is granted, denied, or permanently denied.
  ///
  /// Returns a `Future<Map<String, dynamic>>` with status details.
  Future<Map<String, dynamic>> requestLocationForRadar() async {
    try {
      // First check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'permitted': false,
          'status': 'disabled',
          'message': 'Location services are disabled. Please enable them in settings.',
          'canRetry': true,
        };
      }
      
      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Handle different permission states
      switch (permission) {
        case LocationPermission.denied:
          // Request permission
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return {
              'permitted': false,
              'status': 'denied',
              'message': 'Location permission denied. Radar will show default location.',
              'canRetry': true,
            };
          }
          break;
          
        case LocationPermission.deniedForever:
          return {
            'permitted': false,
            'status': 'deniedForever',
            'message': 'Location permission permanently denied. Enable in Settings > Privacy > Location Services.',
            'canRetry': false,
          };
          
        case LocationPermission.unableToDetermine:
          return {
            'permitted': false,
            'status': 'unable',
            'message': 'Unable to determine location permission status.',
            'canRetry': true,
          };
          
        default:
          // whileInUse or always - permission granted
          break;
      }
      
      // If we get here, permission is granted
      _cachedPermissionStatus = permission;
      
      // Try to get current location
      try {
        final position = await getCurrentLocation(forceRefresh: true);
        if (position != null) {
          return {
            'permitted': true,
            'status': 'granted',
            'message': 'Location permission granted',
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
          };
        } else {
          return {
            'permitted': true,
            'status': 'granted_no_location',
            'message': 'Permission granted but unable to get current location',
            'canRetry': true,
          };
        }
      } catch (e) {
        return {
          'permitted': true,
          'status': 'granted_error',
          'message': 'Permission granted but error getting location: $e',
          'canRetry': true,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location for radar: $e');
      }
      return {
        'permitted': false,
        'status': 'error',
        'message': 'Error checking location permissions: $e',
        'canRetry': true,
      };
    }
  }
  
  /// Opens the device's location settings screen.
  ///
  /// This allows the user to enable location services if they are disabled.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening location settings: $e');
      }
      return false;
    }
  }
  
  /// Opens the app's specific settings screen on the device.
  ///
  /// This is useful if the user has permanently denied location permissions
  /// and needs to re-enable them manually.
  Future<bool> openAppSettings() async {
    try {
      return await permission.openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
      return false;
    }
  }
}

/// A wrapper class that pairs a [Job] with its calculated distance from a search point.
class JobWithDistance {
  /// The job object.
  final Job job;
  /// The calculated distance in miles. A value of -1 indicates distance was not calculated.
  final double distance;
  /// The geographic coordinates of the job.
  final Coordinates? coordinates;
  
  /// Creates an instance of [JobWithDistance].
  JobWithDistance({
    required this.job,
    required this.distance,
    this.coordinates,
  });
  
  /// Returns a user-friendly string for the distance.
  String get formattedDistance {
    if (distance < 0) return 'Distance unknown';
    if (distance < 1) return '${(distance * 5280).round()} ft';
    return '${distance.toStringAsFixed(1)} mi';
  }
  
  /// A boolean indicating whether the distance was successfully calculated.
  bool get hasDistance => distance >= 0;
}

/// A wrapper class that pairs a [LocalsRecord] with its calculated distance.
class LocalWithDistance {
  /// The IBEW local record.
  final LocalsRecord local;
  /// The calculated distance in miles.
  final double distance;
  /// The geographic coordinates of the local.
  final Coordinates coordinates;
  
  /// Creates an instance of [LocalWithDistance].
  LocalWithDistance({
    required this.local,
    required this.distance,
    required this.coordinates,
  });
  
  /// Returns a user-friendly string for the distance.
  String get formattedDistance {
    if (distance < 1) return '${(distance * 5280).round()} ft';
    return '${distance.toStringAsFixed(1)} mi';
  }
}

/// A simple class to represent geographic coordinates.
class Coordinates {
  /// The latitude value.
  final double latitude;
  /// The longitude value.
  final double longitude;
  
  /// Creates an instance of [Coordinates].
  Coordinates(this.latitude, this.longitude);
  
  @override
  String toString() => '($latitude, $longitude)';
}