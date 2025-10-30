import 'package:cloud_firestore/cloud_firestore.dart';

/// Strategy interface for data sharding in Firestore
///
/// Implementations provide different sharding approaches:
/// - Geographic/regional sharding
/// - Time-based sharding
/// - Hash-based sharding
/// - No sharding (default)
abstract class ShardingStrategy {
  /// Get the appropriate collection reference for the given parameters
  ///
  /// [firestore] - Firestore instance
  /// [baseCollection] - Base collection name (e.g., 'jobs', 'locals')
  /// [shardKey] - Optional shard key (e.g., region, date, hash)
  ///
  /// Returns the collection reference to use
  CollectionReference getCollection(
    FirebaseFirestore firestore,
    String baseCollection, {
    String? shardKey,
  });

  /// Get all collection references for cross-shard queries
  ///
  /// [firestore] - Firestore instance
  /// [baseCollection] - Base collection name
  ///
  /// Returns list of all shard collections
  List<CollectionReference> getAllCollections(
    FirebaseFirestore firestore,
    String baseCollection,
  );

  /// Determine the shard key for given data
  ///
  /// [data] - Document data to analyze
  ///
  /// Returns the shard key to use for this document
  String? determineShardKey(Map<String, dynamic> data);

  /// Get sharding statistics and coverage information
  Map<String, dynamic> getStatistics();
}

/// Geographic region for sharding
class GeographicRegion {
  final String name;
  final List<String> states;
  final String code;

  const GeographicRegion({
    required this.name,
    required this.states,
    required this.code,
  });

  /// Check if a state belongs to this region
  bool containsState(String state) {
    return states.contains(state.toUpperCase());
  }

  /// Get region coverage percentage (out of 51 total: 50 states + DC)
  double get coveragePercentage => (states.length / 51) * 100;
}

/// Predefined US geographic regions for electrical industry
class USRegions {
  static const northeast = GeographicRegion(
    name: 'Northeast',
    code: 'northeast',
    states: ['NY', 'NJ', 'CT', 'MA', 'PA', 'VT', 'NH', 'ME', 'RI', 'DE', 'MD'],
  );

  static const southeast = GeographicRegion(
    name: 'Southeast',
    code: 'southeast',
    states: ['FL', 'GA', 'SC', 'NC', 'VA', 'WV', 'TN', 'KY', 'AL', 'MS', 'AR', 'LA'],
  );

  static const midwest = GeographicRegion(
    name: 'Midwest',
    code: 'midwest',
    states: ['OH', 'IN', 'MI', 'IL', 'WI', 'MN', 'IA', 'MO', 'ND', 'SD', 'NE', 'KS'],
  );

  static const southwest = GeographicRegion(
    name: 'Southwest',
    code: 'southwest',
    states: ['TX', 'OK', 'NM', 'AZ', 'NV', 'UT', 'CO'],
  );

  static const west = GeographicRegion(
    name: 'West',
    code: 'west',
    states: ['CA', 'OR', 'WA', 'ID', 'MT', 'WY', 'AK', 'HI'],
  );

  static const allRegions = [
    northeast,
    southeast,
    midwest,
    southwest,
    west,
  ];

  /// Get region from state code
  static GeographicRegion? getRegionForState(String state) {
    final upperState = state.toUpperCase();
    for (final region in allRegions) {
      if (region.containsState(upperState)) {
        return region;
      }
    }
    return null;
  }

  /// Get region by code
  static GeographicRegion? getRegionByCode(String code) {
    final lowerCode = code.toLowerCase();
    for (final region in allRegions) {
      if (region.code == lowerCode) {
        return region;
      }
    }
    return null;
  }

  /// Get nearby regions for cross-regional queries
  static List<GeographicRegion> getNearbyRegions(GeographicRegion primaryRegion) {
    // Define geographic adjacency
    const adjacency = {
      'northeast': ['southeast', 'midwest'],
      'southeast': ['northeast', 'midwest', 'southwest'],
      'midwest': ['northeast', 'southeast', 'southwest', 'west'],
      'southwest': ['southeast', 'midwest', 'west'],
      'west': ['midwest', 'southwest'],
    };

    final nearbyRegionCodes = adjacency[primaryRegion.code] ?? [];
    return allRegions
        .where((region) => nearbyRegionCodes.contains(region.code))
        .toList();
  }
}
