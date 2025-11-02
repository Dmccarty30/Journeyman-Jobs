---
name: jj-hierarchical-data-management
description: Design hierarchical data structures for electrical trades platform. Covers IBEW organizational hierarchy (Nation→Region→Local→Jobs), job models with per diem, crew hierarchies, job aggregation pipelines, offline-first sync, territory-based queries, and multi-level caching. Use when designing data models, implementing offline sync, or structuring territorial data.
---

# JJ Hierarchical Data Management

## Purpose

Design and implement hierarchical data structures optimized for IBEW electrical trades platform, including organizational hierarchies, job aggregation pipelines, crew relationships, and offline-first synchronization strategies.

## When To Use

- Designing data models for electrical trades
- Implementing offline synchronization
- Structuring territorial/geographic data
- Building job aggregation pipelines
- Managing crew relationships and hierarchies
- Querying data across organizational levels
- Implementing multi-level caching strategies

## IBEW Organizational Hierarchy

### Structure Overview

```rust
IBEW Nation (International Brotherhood of Electrical Workers)
    ↓
Regions (e.g., First District, Second District)
    ↓
Locals (e.g., Local 134 Chicago, Local 3 New York)
    ↓
├─→ Members (Journeymen, Apprentices, Foremen)
├─→ Jobs (Job postings, Book calls)
├─→ Contractors (Signatory contractors)
└─→ Territories (Geographic jurisdiction)
```

### Data Models

#### Nation/Region Level

```dart
@freezed
class IBEWRegion with _$IBEWRegion {
  const factory IBEWRegion({
    required String id,
    required String name,
    required int districtNumber,
    required List<String> localNumbers,
    required Map<String, dynamic> metadata,
  }) = _IBEWRegion;
  
  factory IBEWRegion.fromJson(Map<String, dynamic> json) =>
      _$IBEWRegionFromJson(json);
}
```

#### Local Level (Primary Organization Unit)

```dart
@freezed
class Local with _$Local {
  const factory Local({
    required int localNumber,
    required String name,
    required String city,
    required String state,
    required Territory territory,
    required ContactInfo contact,
    required int memberCount,
    required List<TradeClassification> trades,
    required PayScale payScale,
    required String? website,
    required String? phoneNumber,
    required String? email,
  }) = _Local;
  
  factory Local.fromJson(Map<String, dynamic> json) =>
      _$LocalFromJson(json);
}

@freezed
class Territory with _$Territory {
  const factory Territory({
    required LatLng center,
    required double radiusMiles,
    required List<LatLng>? polygonBounds,
    required List<String> coveredCities,
    required List<String> coveredCounties,
  }) = _Territory;
  
  factory Territory.fromJson(Map<String, dynamic> json) =>
      _$TerritoryFromJson(json);
}

@freezed
class PayScale with _$PayScale {
  const factory PayScale({
    required double journeymanRate,
    required double foremanRate,
    required double generalForemanRate,
    required Map<int, double> apprenticeRates,  // Year → Rate
    required double healthWelfareRate,
    required double pensionRate,
    required DateTime effectiveDate,
  }) = _PayScale;
  
  factory PayScale.fromJson(Map<String, dynamic> json) =>
      _$PayScaleFromJson(json);
}
```

#### Member Level

```dart
@freezed
class Member with _$Member {
  const factory Member({
    required String id,
    required String userId,
    required int localNumber,
    required TradeClassification trade,
    required MemberStatus status,
    required DateTime bookNumber,
    required List<Certification> certifications,
    required WorkPreferences preferences,
    required int? crewId,
  }) = _Member;
  
  factory Member.fromJson(Map<String, dynamic> json) =>
      _$MemberFromJson(json);
}

enum TradeClassification {
  journeymanWireman,
  journeymanLineman,
  apprenticeWireman,
  apprenticeLineman,
  foreman,
  generalForeman,
  treeTrimer,
}

enum MemberStatus {
  onBook,      // Available for dispatch
  working,     // Currently employed
  traveling,   // Working outside home local
  onLeave,     // Temporary leave
}
```

## Job Data Models

### Core Job Model

```dart
@freezed
class Job with _$Job {
  const factory Job({
    // Identity
    required String id,
    required String externalId,  // From source system
    required String source,       // Local number or contractor
    
    // Location
    required String city,
    required String state,
    required int? localNumber,
    required LatLng? coordinates,
    required String? address,
    
    // Compensation
    required double hourlyRate,
    required double? perDiem,
    required double? perMileRate,
    required String? benefitsPackage,
    
    // Work Details
    required String title,
    required String? description,
    required TradeClassification trade,
    required List<String> requiredCertifications,
    required int estimatedDuration,  // Days
    required DateTime startDate,
    required bool isStormWork,
    required bool isOpenShop,      // Non-union shop
    
    // Requirements
    required int minimumYearsExperience,
    required List<String> requiredTools,
    required String? specialRequirements,
    
    // Metadata
    required DateTime postedDate,
    required DateTime? expirationDate,
    required JobStatus status,
    required int viewCount,
    required int applicationCount,
    
    // Aggregation Metadata
    required DateTime scrapedAt,
    required String scrapedFrom,  // URL
    required bool verified,
  }) = _Job;
  
  factory Job.fromJson(Map<String, dynamic> json) =>
      _$JobFromJson(json);
      
  // Computed properties
  const Job._();
  
  double get totalCompensation {
    final dailyBase = hourlyRate * 8;  // 8-hour day
    final dailyPerDiem = perDiem ?? 0;
    return dailyBase + dailyPerDiem;
  }
  
  bool get isPremiumJob {
    return isStormWork || 
           (perDiem ?? 0) > 50 || 
           hourlyRate > 45;
  }
}

enum JobStatus {
  active,
  filled,
  expired,
  cancelled,
}
```

### Job Aggregation Pipeline

```dart
@freezed
class JobAggregationSource with _$JobAggregationSource {
  const factory JobAggregationSource({
    required String id,
    required String name,
    required String baseUrl,
    required int localNumber,
    required SourceType type,
    required Map<String, String> selectors,  // CSS/XPath selectors
    required Duration checkInterval,
    required DateTime lastChecked,
    required bool enabled,
  }) = _JobAggregationSource;
  
  factory JobAggregationSource.fromJson(Map<String, dynamic> json) =>
      _$JobAggregationSourceFromJson(json);
}

enum SourceType {
  localWebsite,      // Local union job board
  contractorSite,    // Contractor direct posting
  thirdPartyBoard,   // Indeed, ZipRecruiter
  emailDigest,       // Email-based job lists
}

// Aggregated job with source tracking
@freezed
class AggregatedJob with _$AggregatedJob {
  const factory AggregatedJob({
    required Job job,
    required String sourceId,
    required DateTime aggregatedAt,
    required int deduplicationScore,  // Similarity to other jobs
    required List<String> duplicateIds,
  }) = _AggregatedJob;
  
  factory AggregatedJob.fromJson(Map<String, dynamic> json) =>
      _$AggregatedJobFromJson(json);
}
```

## Crew Hierarchies

### Crew Model

```dart
@freezed
class Crew with _$Crew {
  const factory Crew({
    required String id,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    required List<CrewMember> members,
    required CrewPreferences preferences,
    required CrewStatus status,
    required List<String> sharedJobIds,
    required List<CrewMessage> messages,
  }) = _Crew;
  
  factory Crew.fromJson(Map<String, dynamic> json) =>
      _$CrewFromJson(json);
}

@freezed
class CrewMember with _$CrewMember {
  const factory CrewMember({
    required String userId,
    required String displayName,
    required CrewRole role,
    required DateTime joinedAt,
    required bool isActive,
  }) = _CrewMember;
  
  factory CrewMember.fromJson(Map<String, dynamic> json) =>
      _$CrewMemberFromJson(json);
}

enum CrewRole {
  leader,      // Can manage crew, invite members
  member,      // Can share jobs, participate
  viewer,      // Read-only access
}

enum CrewStatus {
  active,
  inactive,
  disbanded,
}

@freezed
class CrewPreferences with _$CrewPreferences {
  const factory CrewPreferences({
    // Location preferences
    required List<String> preferredCities,
    required int maxTravelDistance,
    
    // Job preferences
    required List<TradeClassification> preferredTrades,
    required bool stormWorkOnly,
    required double minPerDiem,
    required double minHourlyRate,
    
    // Notification preferences
    required bool notifyOnNewJobs,
    required bool notifyOnStormWork,
    required List<String> notificationKeywords,
  }) = _CrewPreferences;
  
  factory CrewPreferences.fromJson(Map<String, dynamic> json) =>
      _$CrewPreferencesFromJson(json);
}
```

### Crew Job Matching

```dart
class CrewJobMatcher {
  static Future<List<Job>> findMatchingJobs(
    Crew crew,
    List<Job> availableJobs,
  ) async {
    final prefs = crew.preferences;
    
    return availableJobs.where((job) {
      // Location match
      if (prefs.preferredCities.isNotEmpty &&
          !prefs.preferredCities.contains(job.city)) {
        return false;
      }
      
      // Trade match
      if (!prefs.preferredTrades.contains(job.trade)) {
        return false;
      }
      
      // Storm work filter
      if (prefs.stormWorkOnly && !job.isStormWork) {
        return false;
      }
      
      // Compensation thresholds
      if (job.hourlyRate < prefs.minHourlyRate) {
        return false;
      }
      
      if ((job.perDiem ?? 0) < prefs.minPerDiem) {
        return false;
      }
      
      // Keyword matching
      if (prefs.notificationKeywords.isNotEmpty) {
        final jobText = '${job.title} ${job.description}'.toLowerCase();
        final hasKeyword = prefs.notificationKeywords.any(
          (keyword) => jobText.contains(keyword.toLowerCase()),
        );
        if (!hasKeyword) return false;
      }
      
      return true;
    }).toList();
  }
  
  static int calculateMatchScore(Crew crew, Job job) {
    int score = 0;
    final prefs = crew.preferences;
    
    // Perfect location match: +20
    if (prefs.preferredCities.contains(job.city)) {
      score += 20;
    }
    
    // Storm work (if preferred): +15
    if (prefs.stormWorkOnly && job.isStormWork) {
      score += 15;
    }
    
    // Above minimum compensation: +10
    if (job.hourlyRate > prefs.minHourlyRate + 5) {
      score += 10;
    }
    
    // High per diem: +10
    if ((job.perDiem ?? 0) > prefs.minPerDiem + 20) {
      score += 10;
    }
    
    // Keyword match: +5 per keyword
    final jobText = '${job.title} ${job.description}'.toLowerCase();
    score += prefs.notificationKeywords.where(
      (keyword) => jobText.contains(keyword.toLowerCase()),
    ).length * 5;
    
    return score;
  }
}
```

## Offline-First Synchronization

### Sync Strategy

```dart
@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    required DateTime lastFullSync,
    required DateTime lastIncrementalSync,
    required Map<String, DateTime> lastSyncByCollection,
    required List<PendingSync> pendingOperations,
    required SyncStatus status,
  }) = _SyncState;
  
  factory SyncState.fromJson(Map<String, dynamic> json) =>
      _$SyncStateFromJson(json);
}

enum SyncStatus {
  idle,
  syncing,
  error,
}

@freezed
class PendingSync with _$PendingSync {
  const factory PendingSync({
    required String id,
    required String collection,
    required SyncOperation operation,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required int retryCount,
  }) = _PendingSync;
  
  factory PendingSync.fromJson(Map<String, dynamic> json) =>
      _$PendingSyncFromJson(json);
}

enum SyncOperation {
  create,
  update,
  delete,
}
```

### Three-Tier Sync Architecture

```dart
class HierarchicalSyncService {
  // Tier 1: Memory Cache (Instant)
  final _memoryCache = <String, dynamic>{};
  static const _memoryCacheDuration = Duration(minutes: 5);
  
  // Tier 2: Local Storage (Fast)
  final LocalStorageService _localStorage;
  
  // Tier 3: Firestore (Authoritative)
  final FirestoreService _firestore;
  
  Future<T?> get<T>({
    required String collection,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final cacheKey = '$collection:$id';
    
    // Tier 1: Check memory
    if (_memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey];
      if (_isCacheValid(cached['timestamp'])) {
        return cached['data'] as T;
      }
    }
    
    // Tier 2: Check local storage
    final local = await _localStorage.get(collection, id);
    if (local != null) {
      final data = fromJson(local);
      _cacheInMemory(cacheKey, data);
      
      // Background sync from Firestore
      _backgroundSync(collection, id, fromJson);
      
      return data;
    }
    
    // Tier 3: Fetch from Firestore
    final remote = await _firestore.get(collection, id);
    if (remote != null) {
      final data = fromJson(remote);
      
      // Cache in both tiers
      await _localStorage.set(collection, id, remote);
      _cacheInMemory(cacheKey, data);
      
      return data;
    }
    
    return null;
  }
  
  Future<void> set<T>({
    required String collection,
    required String id,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final json = toJson(data);
    final cacheKey = '$collection:$id';
    
    // Tier 1: Update memory immediately
    _cacheInMemory(cacheKey, data);
    
    // Tier 2: Update local storage
    await _localStorage.set(collection, id, json);
    
    // Tier 3: Sync to Firestore (background)
    try {
      await _firestore.set(collection, id, json);
    } catch (e) {
      // Queue for retry if offline
      await _queueForSync(
        collection: collection,
        id: id,
        operation: SyncOperation.update,
        data: json,
      );
    }
  }
  
  void _cacheInMemory(String key, dynamic data) {
    _memoryCache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }
  
  bool _isCacheValid(DateTime timestamp) {
    return DateTime.now().difference(timestamp) < _memoryCacheDuration;
  }
  
  Future<void> _backgroundSync<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Fetch latest from Firestore in background
    final remote = await _firestore.get(collection, id);
    if (remote != null) {
      await _localStorage.set(collection, id, remote);
      _cacheInMemory('$collection:$id', fromJson(remote));
    }
  }
  
  Future<void> _queueForSync({
    required String collection,
    required String id,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    final pending = PendingSync(
      id: '${collection}_${id}_${DateTime.now().millisecondsSinceEpoch}',
      collection: collection,
      operation: operation,
      data: data,
      timestamp: DateTime.now(),
      retryCount: 0,
    );
    
    await _localStorage.addPendingSync(pending);
  }
}
```

## Territory-Based Queries

### Geographic Queries

```dart
class TerritoryQueryService {
  final FirestoreService _firestore;
  
  // Find jobs within local territory
  Future<List<Job>> getJobsInTerritory(Territory territory) async {
    if (territory.polygonBounds != null) {
      // Polygon-based query
      return await _firestore.getJobsInPolygon(territory.polygonBounds!);
    } else {
      // Radius-based query
      return await _firestore.getJobsNearPoint(
        territory.center,
        territory.radiusMiles,
      );
    }
  }
  
  // Find closest local to a location
  Future<Local?> findNearestLocal(LatLng location) async {
    final allLocals = await _firestore.getAllLocals();
    
    Local? nearest;
    double minDistance = double.infinity;
    
    for (final local in allLocals) {
      final distance = _calculateDistance(location, local.territory.center);
      
      if (distance < minDistance) {
        minDistance = distance;
        nearest = local;
      }
    }
    
    return nearest;
  }
  
  // Check if job is within multiple territories
  Future<List<Local>> getJurisdictionalLocals(Job job) async {
    if (job.coordinates == null) return [];
    
    final allLocals = await _firestore.getAllLocals();
    
    return allLocals.where((local) {
      return _isPointInTerritory(job.coordinates!, local.territory);
    }).toList();
  }
  
  bool _isPointInTerritory(LatLng point, Territory territory) {
    if (territory.polygonBounds != null) {
      return _isPointInPolygon(point, territory.polygonBounds!);
    } else {
      final distance = _calculateDistance(point, territory.center);
      return distance <= territory.radiusMiles;
    }
  }
  
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    // Ray casting algorithm
    bool inside = false;
    int j = polygon.length - 1;
    
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
          (polygon[j].latitude > point.latitude) &&
          point.longitude < (polygon[j].longitude - polygon[i].longitude) *
              (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude) {
        inside = !inside;
      }
      j = i;
    }
    
    return inside;
  }
  
  double _calculateDistance(LatLng from, LatLng to) {
    // Haversine formula
    const R = 3959;  // Earth radius in miles
    
    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(from.latitude)) * cos(_toRadians(to.latitude)) *
        sin(dLon / 2) * sin(dLon / 2);
        
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }
  
  double _toRadians(double degrees) => degrees * pi / 180;
}
```

### Sharded Territory Queries

```dart
class ShardedTerritoryService {
  // Shard jobs by geographic region for better query performance
  Future<List<Job>> getJobsInRegion(String regionId) async {
    // Query specific shard
    final shard = 'jobs_region_$regionId';
    return await _firestore.collection(shard).get();
  }
  
  String getShardForLocation(LatLng location) {
    // US regions (simplified)
    if (_isInNortheast(location)) return 'northeast';
    if (_isInSoutheast(location)) return 'southeast';
    if (_isInMidwest(location)) return 'midwest';
    if (_isInSouthwest(location)) return 'southwest';
    if (_isInWest(location)) return 'west';
    
    return 'other';
  }
  
  bool _isInNortheast(LatLng location) {
    // Northeast: lat > 38, lon > -80
    return location.latitude > 38 && location.longitude > -80;
  }
  
  // ... other region checks
}
```

## Multi-Level Caching

### Cache Hierarchy

```dart
class MultiLevelCache<T> {
  // L1: In-memory (instant, volatile)
  final Map<String, CacheEntry<T>> _l1Cache = {};
  final Duration _l1Duration = const Duration(minutes: 5);
  
  // L2: Local storage (fast, persistent)
  final LocalStorageService _l2Storage;
  final Duration _l2Duration = const Duration(hours: 24);
  
  // L3: Firestore (authoritative, slow)
  final FirestoreService _l3Remote;
  
  Future<T?> get(String key) async {
    // L1: Memory
    if (_l1Cache.containsKey(key)) {
      final entry = _l1Cache[key]!;
      if (!entry.isExpired) {
        return entry.value;
      }
      _l1Cache.remove(key);
    }
    
    // L2: Local storage
    final l2Data = await _l2Storage.get(key);
    if (l2Data != null) {
      final entry = CacheEntry.fromJson(l2Data);
      if (!entry.isExpired) {
        _l1Cache[key] = entry;  // Promote to L1
        return entry.value;
      }
    }
    
    // L3: Remote (Firestore)
    final l3Data = await _l3Remote.get(key);
    if (l3Data != null) {
      final entry = CacheEntry(
        value: l3Data,
        timestamp: DateTime.now(),
        ttl: _l2Duration,
      );
      
      // Populate all cache levels
      _l1Cache[key] = entry;
      await _l2Storage.set(key, entry.toJson());
      
      return l3Data;
    }
    
    return null;
  }
  
  Future<void> set(String key, T value) async {
    final entry = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      ttl: _l2Duration,
    );
    
    // Write to all levels
    _l1Cache[key] = entry;
    await _l2Storage.set(key, entry.toJson());
    await _l3Remote.set(key, value);
  }
  
  Future<void> invalidate(String key) async {
    _l1Cache.remove(key);
    await _l2Storage.remove(key);
    // L3 (Firestore) remains authoritative
  }
  
  Future<void> clear() async {
    _l1Cache.clear();
    await _l2Storage.clear();
  }
}

@freezed
class CacheEntry<T> with _$CacheEntry<T> {
  const factory CacheEntry({
    required T value,
    required DateTime timestamp,
    required Duration ttl,
  }) = _CacheEntry;
  
  factory CacheEntry.fromJson(Map<String, dynamic> json) =>
      _$CacheEntryFromJson(json);
      
  const CacheEntry._();
  
  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
}
```

## Best Practices

### DO

✓ Use hierarchical organization (Nation → Region → Local → Jobs)
✓ Implement three-tier caching (memory → storage → remote)
✓ Design for offline-first with sync queues
✓ Shard by geography for better query performance
✓ Calculate per diem based on distance
✓ Validate territorial boundaries for job postings
✓ Track aggregation metadata for deduplication
✓ Index on commonly queried fields (city, trade, local)

### DON'T

✗ Flatten hierarchies unnecessarily
✗ Skip caching frequently accessed data
✗ Ignore geographic boundaries
✗ Store sensitive member data without encryption
✗ Over-normalize crew relationships
✗ Fetch entire collections when filtering is possible
✗ Forget to handle sync conflicts

## Testing Hierarchical Data

```dart
void main() {
  group('Territory Queries', () {
    test('Point in circle territory', () {
      final territory = Territory(
        center: LatLng(41.8781, -87.6298),  // Chicago
        radiusMiles: 50,
      );
      
      final nearbyPoint = LatLng(41.9, -87.6);  // ~2 miles away
      final farPoint = LatLng(42.5, -88.0);     // ~60 miles away
      
      expect(_isPointInTerritory(nearbyPoint, territory), true);
      expect(_isPointInTerritory(farPoint, territory), false);
    });
    
    test('Per diem calculation', () {
      final calculator = PerDiemCalculator();
      final userLocation = LatLng(41.8781, -87.6298);  // Chicago
      
      final nearbyJob = Job(
        coordinates: LatLng(41.9, -87.6),  // 20 miles
      );
      
      final farJob = Job(
        coordinates: LatLng(42.5, -88.0),  // 60 miles
      );
      
      expect(calculator.calculate(nearbyJob, userLocation), 0.0);
      expect(calculator.calculate(farJob, userLocation), 50.0);
    });
  });
  
  group('Crew Matching', () {
    test('Matches jobs by preferences', () async {
      final crew = Crew(
        preferences: CrewPreferences(
          preferredCities: ['Chicago'],
          preferredTrades: [TradeClassification.journeymanWireman],
          minHourlyRate: 40.0,
          minPerDiem: 50.0,
        ),
      );
      
      final jobs = [
        Job(city: 'Chicago', trade: TradeClassification.journeymanWireman,
            hourlyRate: 45, perDiem: 60),  // Match
        Job(city: 'New York', trade: TradeClassification.journeymanWireman,
            hourlyRate: 45, perDiem: 60),  // No match (city)
        Job(city: 'Chicago', trade: TradeClassification.journeymanLineman,
            hourlyRate: 45, perDiem: 60),  // No match (trade)
      ];
      
      final matches = await CrewJobMatcher.findMatchingJobs(crew, jobs);
      
      expect(matches.length, 1);
      expect(matches.first.city, 'Chicago');
    });
  });
}
```

## Checklist

- [ ] Hierarchical models defined (Nation → Local → Jobs)
- [ ] Territory boundaries configured per local
- [ ] Per diem calculation based on distance
- [ ] Three-tier caching implemented
- [ ] Offline sync queue operational
- [ ] Geographic queries optimized with sharding
- [ ] Crew matching algorithm tested
- [ ] Job aggregation pipeline defined
- [ ] Deduplication logic for aggregated jobs
- [ ] Sync conflict resolution strategy
- [ ] Tests for territorial queries
- [ ] Tests for crew job matching

---

**Skill Version**: 1.0.0  
**Last Updated**: 2025-10-31  
**Status**: ✅ Production Ready
