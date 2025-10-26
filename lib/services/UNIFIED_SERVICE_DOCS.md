# UnifiedFirestoreService Documentation

## Overview

`UnifiedFirestoreService` is a comprehensive Firestore integration service that consolidates 4 previous services into a unified architecture using the Strategy Pattern. It provides pluggable strategies for resilience, search optimization, and geographic sharding.

### Architecture

```
UnifiedFirestoreService
├── Core Operations (CRUD, collections, batch operations)
├── ResilienceStrategy (optional)
│   ├── Automatic retry with exponential backoff
│   ├── Circuit breaker pattern
│   └── Error classification and handling
├── SearchStrategy (optional)
│   ├── Multi-term search with relevance ranking
│   ├── Intelligent caching (<300ms target)
│   └── Search analytics
└── ShardingStrategy (optional)
    ├── Geographic data organization (5 US regions)
    ├── Regional subcollections (70% query reduction)
    └── Cross-regional search support
```

### Key Features

- **Single Point of Integration**: One service for all Firestore operations
- **Pluggable Strategies**: Enable/disable features as needed
- **Backward Compatible**: All existing method signatures preserved
- **Comprehensive Monitoring**: Built-in statistics and observability
- **Production Ready**: Tested, documented, and optimized

---

## Installation & Setup

### Basic Setup

```dart
import 'package:journeyman_jobs/services/unified_firestore_service.dart';

// Create service with default configuration
final service = UnifiedFirestoreService();

// Create service with all strategies enabled
final service = UnifiedFirestoreService(
  enableResilience: true,
  enableSearch: true,
  enableSharding: true,
);

// Create service with custom configuration
final service = UnifiedFirestoreService(
  enableResilience: true,
  enableSearch: true,
  enableSharding: false,
  resilienceConfig: ResilienceConfig(
    maxRetries: 5,
    circuitBreakerThreshold: 10,
  ),
  searchConfig: SearchConfig(
    maxSearchResults: 100,
    searchCacheTimeout: Duration(minutes: 15),
  ),
);
```

### Provider Integration

```dart
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/services/unified_firestore_service.dart';

MultiProvider(
  providers: [
    Provider<UnifiedFirestoreService>(
      create: (_) => UnifiedFirestoreService(
        enableResilience: true,
        enableSearch: true,
        enableSharding: false,
      ),
    ),
  ],
  child: MyApp(),
)
```

---

## Core Operations

### User Operations

#### Create User

```dart
await service.createUser(
  uid: 'user-123',
  userData: {
    'displayName': 'John Doe',
    'email': 'john@example.com',
    'classification': 'Inside Wireman',
  },
);
```

Automatically sets:
- `createdTime`: Server timestamp
- `onboardingStatus`: 'incomplete'

#### Get User

```dart
// Get user document
final userDoc = await service.getUser('user-123');

if (userDoc.exists) {
  final userData = userDoc.data() as Map<String, dynamic>;
  print('User: ${userData['displayName']}');
}

// Get user with caching
final cachedData = await service.getCachedUserData('user-123');
```

#### Update User

```dart
// Update specific fields
await service.updateUser(
  uid: 'user-123',
  data: {
    'displayName': 'Jane Doe',
    'onboardingStatus': 'complete',
  },
);

// Set with merge (creates if not exists)
await service.setUserWithMerge(
  uid: 'user-123',
  data: {
    'preferences': {
      'notifications': true,
      'darkMode': false,
    },
  },
);

// Update with UserModel
await service.updateUserProfile('user-123', userModel);
```

#### Stream User Updates

```dart
service.getUserStream('user-123').listen((snapshot) {
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;
    print('User updated: $data');
  }
});
```

#### Delete User

```dart
await service.deleteUserData('user-123');
```

### Job Operations

#### Get Jobs Stream

```dart
// Basic usage
service.getJobs(limit: 20).listen((snapshot) {
  for (var doc in snapshot.docs) {
    final job = doc.data() as Map<String, dynamic>;
    print('Job: ${job['company']}');
  }
});

// With filters
service.getJobs(
  limit: 50,
  filters: {
    'state': 'NY',
    'classification': 'Inside Wireman',
    'typeOfWork': 'Commercial',
  },
).listen((snapshot) {
  // Handle jobs
});

// With pagination
DocumentSnapshot? lastDoc;

service.getJobs(
  limit: 20,
  startAfter: lastDoc,
).listen((snapshot) {
  if (snapshot.docs.isNotEmpty) {
    lastDoc = snapshot.docs.last;
  }
});
```

#### Get Single Job

```dart
final jobDoc = await service.getJob('job-456');

if (jobDoc.exists) {
  final job = jobDoc.data() as Map<String, dynamic>;
  print('Company: ${job['company']}');
  print('Wage: \$${job['wage']}/hr');
}
```

#### Get Jobs with Advanced Filters

```dart
final filter = JobFilterCriteria(
  classifications: ['Inside Wireman', 'Lineman'],
  localNumbers: [123, 456],
  constructionTypes: ['Commercial', 'Industrial'],
  companies: ['ABC Electric', 'XYZ Contractors'],
  hasPerDiem: true,
  state: 'NY',
  city: 'New York',
  postedAfter: DateTime.now().subtract(Duration(days: 7)),
  sortBy: JobSortOption.wage,
  sortDescending: true,
);

final results = await service.getJobsWithFilter(
  filter: filter,
  limit: 50,
);

for (var doc in results.docs) {
  final job = doc.data() as Map<String, dynamic>;
  print('${job['company']} - \$${job['wage']}/hr');
}
```

#### Get Popular Jobs (Cached)

```dart
final popularJobs = await service.getCachedPopularJobs();

for (var job in popularJobs) {
  print('${job['company']} - ${job['location']}');
}
```

### Local Union Operations

#### Get Locals Stream

```dart
// All locals
service.getLocals(limit: 100).listen((snapshot) {
  for (var doc in snapshot.docs) {
    final local = doc.data() as Map<String, dynamic>;
    print('Local ${local['localUnion']}');
  }
});

// Filter by state
service.getLocals(
  limit: 50,
  state: 'CA',
).listen((snapshot) {
  // Handle California locals
});

// With pagination
DocumentSnapshot? lastLocal;

service.getLocals(
  limit: 20,
  startAfter: lastLocal,
).listen((snapshot) {
  if (snapshot.docs.isNotEmpty) {
    lastLocal = snapshot.docs.last;
  }
});
```

#### Search Locals (Basic)

```dart
// Prefix search
final results = await service.searchLocals(
  'local 123',
  state: 'TX',
  limit: 20,
);

for (var doc in results.docs) {
  final local = doc.data() as Map<String, dynamic>;
  print('Found: ${local['localUnion']}');
}
```

#### Search Locals (Enhanced)

Requires `enableSearch: true`

```dart
// Multi-term search with relevance ranking
final results = await service.searchLocalsEnhanced(
  'electrician new york',
  state: 'NY',
  limit: 50,
);

for (var local in results) {
  print('${local.localUnion} - ${local.city}, ${local.state}');
  print('Relevance: High');
}
```

#### Get Single Local

```dart
final localDoc = await service.getLocal('local-789');

if (localDoc.exists) {
  final local = localDoc.data() as Map<String, dynamic>;
  print('Local: ${local['localUnion']}');
  print('Address: ${local['address']}');
}
```

#### Get Locals (Cached)

```dart
final cachedLocals = await service.getCachedLocals();

for (var local in cachedLocals) {
  print('${local['localUnion']} - ${local['city']}');
}
```

### Batch Operations

```dart
final operations = [
  BatchOperation(
    reference: service.usersCollection.doc('user-1'),
    type: OperationType.create,
    data: {'name': 'John'},
  ),
  BatchOperation(
    reference: service.usersCollection.doc('user-2'),
    type: OperationType.update,
    data: {'status': 'active'},
  ),
  BatchOperation(
    reference: service.usersCollection.doc('user-3'),
    type: OperationType.delete,
  ),
];

await service.batchWrite(operations);
```

### Transactions

```dart
final result = await service.runTransaction<int>((transaction) async {
  final userDoc = await transaction.get(
    service.usersCollection.doc('user-123'),
  );

  final currentCount = userDoc.data()?['count'] ?? 0;
  final newCount = currentCount + 1;

  transaction.update(
    service.usersCollection.doc('user-123'),
    {'count': newCount},
  );

  return newCount;
});

print('New count: $result');
```

---

## Strategy Configuration

### Resilience Strategy

Provides automatic retry logic and circuit breaker pattern.

#### Configuration Options

```dart
final service = UnifiedFirestoreService(
  enableResilience: true,
  resilienceConfig: ResilienceConfig(
    maxRetries: 3,                                    // Max retry attempts
    initialRetryDelay: Duration(seconds: 1),          // Base delay
    maxRetryDelay: Duration(seconds: 10),             // Delay cap
    circuitBreakerThreshold: 5,                       // Failures before opening
    circuitBreakerTimeout: Duration(minutes: 5),      // Time before reset
  ),
);
```

#### Monitoring

```dart
// Get circuit breaker status
final status = service.getCircuitBreakerStatus();
print('Circuit Open: ${status?['isOpen']}');
print('Failure Count: ${status?['failureCount']}');
print('Time Until Reset: ${status?['timeUntilReset']}');

// Get retry statistics
final stats = service.getServiceStatistics();
print('Total Retries: ${stats['resilience']['retries']['total']}');
print('Success Rate: ${stats['resilience']['retries']['successRate']}%');
```

#### Manual Circuit Breaker Control

```dart
// Reset circuit breaker
service.resetCircuitBreaker();
```

### Search Strategy

Provides multi-term search with relevance ranking.

#### Configuration Options

```dart
final service = UnifiedFirestoreService(
  enableSearch: true,
  searchConfig: SearchConfig(
    maxSearchResults: 50,                             // Max results per query
    minSearchLength: 2,                               // Min query length
    searchCacheTimeout: Duration(minutes: 10),        // Cache TTL
    fieldWeights: {
      'localUnion': 1.0,                              // Exact union name
      'city': 0.8,                                    // City matches
      'state': 0.6,                                   // State matches
      'searchTerms': 0.4,                             // General terms
    },
  ),
);
```

#### Advanced Search

```dart
// Single term (basic search)
final results1 = await service.searchLocalsEnhanced('123');

// Multi-term (advanced search with ranking)
final results2 = await service.searchLocalsEnhanced('new york electrician');

// With state filter
final results3 = await service.searchLocalsEnhanced(
  'commercial contractor',
  state: 'CA',
);
```

#### Monitoring

```dart
final stats = service.getSearchStatistics();
print('Total Searches: ${stats?['totalSearches']}');
print('Cache Hit Rate: ${stats?['cacheHitRate']}%');
print('Avg Response Time: ${stats?['avgResponseTimeMs']}ms');
print('Performance Target: ${stats?['performanceTarget']}%');
print('Popular Terms: ${stats?['popularTerms']}');
```

### Sharding Strategy

Provides geographic data optimization through regional subcollections.

⚠️ **Note:** Requires data migration before enabling. See Migration Guide.

#### Configuration Options

```dart
final service = UnifiedFirestoreService(
  enableSharding: true,
  shardingConfig: ShardingConfig(
    regions: {
      'northeast': ['NY', 'NJ', 'CT', 'MA', 'PA', ...],
      'southeast': ['FL', 'GA', 'SC', 'NC', 'VA', ...],
      'midwest': ['OH', 'IN', 'MI', 'IL', 'WI', ...],
      'southwest': ['TX', 'OK', 'NM', 'AZ', 'NV', ...],
      'west': ['CA', 'OR', 'WA', 'ID', 'MT', ...],
    },
    enableCrossRegionalSearch: true,                  // Fallback to nearby regions
  ),
);
```

#### Automatic Region Detection

Sharding strategy automatically detects region from state filter:

```dart
// Automatically uses Northeast regional collection
final nyJobs = service.getJobs(filters: {'state': 'NY'});

// Automatically uses West regional collection
final caLocals = service.getLocals(state: 'CA');
```

#### Monitoring

```dart
final stats = service.getShardingStatistics();
print('Regional Queries: ${stats?['queries']['regional']}');
print('Cross-Regional Queries: ${stats?['queries']['crossRegional']}');
print('Regional Percentage: ${stats?['queries']['regionalPercentage']}%');
print('Optimization: ${stats?['optimization']}');
```

---

## Monitoring & Observability

### Service Statistics

Get comprehensive statistics from all enabled strategies:

```dart
final stats = service.getServiceStatistics();

// Service info
print('Service: ${stats['service']}');
print('Timestamp: ${stats['timestamp']}');

// Enabled strategies
print('Resilience: ${stats['strategies']['resilience']}');
print('Search: ${stats['strategies']['search']}');
print('Sharding: ${stats['strategies']['sharding']}');

// Strategy-specific stats
if (stats.containsKey('resilience')) {
  print('Circuit Breaker: ${stats['resilience']['circuitBreaker']}');
  print('Retries: ${stats['resilience']['retries']}');
}

if (stats.containsKey('search')) {
  print('Search Performance: ${stats['search']}');
}

if (stats.containsKey('sharding')) {
  print('Sharding Metrics: ${stats['sharding']}');
}

// Cache stats
print('Cache: ${stats['cache']}');
```

### Cache Management

```dart
// Get cache statistics
final cacheStats = service.getCacheStats();
print('Cache Stats: $cacheStats');

// Clear all caches
await service.clearCache();
```

### Reset Strategies

Useful for testing or troubleshooting:

```dart
// Reset all strategies
service.resetStrategies();

// Reset specific strategy
service.resetCircuitBreaker();
```

---

## Error Handling

### Custom Exception

All Firestore errors are wrapped in `FirestoreException`:

```dart
try {
  await service.getUser('user-123');
} on FirestoreException catch (e) {
  print('Error: ${e.message}');
  print('Code: ${e.code}');
  print('Original: ${e.originalError}');
}
```

### Error Codes

Common error codes:

- `circuit-breaker-open`: Circuit breaker is open, service temporarily unavailable
- `unavailable`: Firestore service unavailable (retryable)
- `deadline-exceeded`: Operation timeout (retryable)
- `permission-denied`: Insufficient permissions (not retryable)
- `not-found`: Document not found (not retryable)
- `unknown-error`: Unexpected error occurred

### Retry Behavior

When `enableResilience: true`, these errors automatically retry:

- `unavailable`
- `deadline-exceeded`
- `internal`
- `cancelled`
- `resource-exhausted`
- `aborted`
- Network errors
- Timeout exceptions

These errors do NOT retry:

- `permission-denied`
- `not-found`
- `already-exists`
- `failed-precondition`
- `unauthenticated`

---

## Performance Optimization

### Pagination

Always use pagination for large datasets:

```dart
// Good: Paginated query
service.getJobs(limit: 20).listen((snapshot) {
  // Handle 20 jobs
});

// Bad: Unbounded query
service.getJobs(limit: 1000).listen((snapshot) {
  // May cause performance issues
});
```

Default page size: 20
Maximum page size: 100

### Caching

Use cached methods for frequently accessed data:

```dart
// Cached user data
final userData = await service.getCachedUserData('user-123');

// Cached popular jobs
final popularJobs = await service.getCachedPopularJobs();

// Cached locals
final locals = await service.getCachedLocals();
```

### Geographic Filtering

Always provide state filter when possible for sharding optimization:

```dart
// Good: State filter enables sharding
service.getJobs(filters: {'state': 'NY'});
service.getLocals(state: 'CA');

// Less optimal: No state filter, queries full database
service.getJobs(limit: 20);
service.getLocals(limit: 100);
```

### Search Optimization

For best search performance:

1. Enable search strategy
2. Keep queries specific (2+ characters)
3. Use state filters to narrow scope
4. Leverage automatic caching

```dart
// Optimized search
final results = await service.searchLocalsEnhanced(
  'local 123',
  state: 'TX',
  limit: 20,
);
```

---

## Best Practices

### Service Lifecycle

Create service once and reuse throughout app lifecycle:

```dart
// Good: Single instance
class MyApp extends StatelessWidget {
  static final service = UnifiedFirestoreService(
    enableResilience: true,
    enableSearch: true,
  );

  @override
  Widget build(BuildContext context) {
    return Provider<UnifiedFirestoreService>.value(
      value: service,
      child: MaterialApp(...),
    );
  }
}

// Bad: Creating new instance per operation
Future<void> fetchData() async {
  final service = UnifiedFirestoreService();  // ❌ Creates new instance
  await service.getUser('user-123');
}
```

### Strategy Selection

Enable only the strategies you need:

```dart
// Basic app: Resilience only
final service = UnifiedFirestoreService(
  enableResilience: true,
  enableSearch: false,
  enableSharding: false,
);

// Search-heavy app: Resilience + Search
final service = UnifiedFirestoreService(
  enableResilience: true,
  enableSearch: true,
  enableSharding: false,
);

// Geographic app: All strategies
final service = UnifiedFirestoreService(
  enableResilience: true,
  enableSearch: true,
  enableSharding: true,  // After data migration
);
```

### Error Handling

Always handle errors gracefully:

```dart
// Good: Proper error handling
try {
  final user = await service.getUser('user-123');
  // Use user data
} on FirestoreException catch (e) {
  if (e.code == 'circuit-breaker-open') {
    // Show maintenance message
  } else if (e.code == 'permission-denied') {
    // Show permission error
  } else {
    // Show generic error
  }
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}

// Bad: No error handling
final user = await service.getUser('user-123');  // ❌ May throw
```

### Monitoring

Monitor service health in production:

```dart
// Periodic health check
Timer.periodic(Duration(minutes: 5), (_) {
  final stats = service.getServiceStatistics();

  // Check circuit breaker
  final circuitBreaker = service.getCircuitBreakerStatus();
  if (circuitBreaker?['isOpen'] == true) {
    // Alert: Circuit breaker open
  }

  // Check search performance
  final search = service.getSearchStatistics();
  final avgTime = search?['avgResponseTimeMs'] ?? 0;
  if (avgTime > 500) {
    // Alert: Slow search performance
  }

  // Log metrics to monitoring service
  logMetrics(stats);
});
```

---

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/services/unified_firestore_service.dart';

void main() {
  late UnifiedFirestoreService service;

  setUp(() {
    service = UnifiedFirestoreService(
      enableResilience: true,
      enableSearch: true,
      enableSharding: false,
    );
  });

  tearDown(() {
    service.resetStrategies();
  });

  group('User Operations', () {
    test('should create user', () async {
      await service.createUser(
        uid: 'test-user',
        userData: {'name': 'Test'},
      );

      final user = await service.getUser('test-user');
      expect(user.exists, isTrue);
    });

    test('should update user', () async {
      await service.updateUser(
        uid: 'test-user',
        data: {'status': 'active'},
      );

      final user = await service.getUser('test-user');
      expect(user.data()?['status'], 'active');
    });
  });

  group('Search Operations', () {
    test('should perform enhanced search', () async {
      final results = await service.searchLocalsEnhanced('local 123');
      expect(results, isNotEmpty);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  testWidgets('Service integration test', (tester) async {
    final service = UnifiedFirestoreService(
      enableResilience: true,
      enableSearch: true,
    );

    // Test service in widget tree
    await tester.pumpWidget(
      Provider<UnifiedFirestoreService>.value(
        value: service,
        child: MyApp(),
      ),
    );

    // Verify service is accessible
    final foundService = Provider.of<UnifiedFirestoreService>(
      tester.element(find.byType(MyApp)),
      listen: false,
    );

    expect(foundService, isNotNull);
  });
}
```

---

## Troubleshooting

### Issue: Service not initialized

**Error:** `Null check operator used on a null value`

**Solution:** Ensure service is created before use:

```dart
// Create service at app startup
final service = UnifiedFirestoreService(
  enableResilience: true,
);

// Provide to widget tree
Provider<UnifiedFirestoreService>.value(
  value: service,
  child: MyApp(),
)
```

### Issue: Circuit breaker keeps opening

**Error:** `FirestoreException: circuit-breaker-open`

**Diagnosis:**
```dart
final status = service.getCircuitBreakerStatus();
print('Failure count: ${status?['failureCount']}');
print('Time until reset: ${status?['timeUntilReset']}s');
```

**Solutions:**
1. Check Firestore rules and permissions
2. Verify network connectivity
3. Increase circuit breaker threshold:
   ```dart
   resilienceConfig: ResilienceConfig(
     circuitBreakerThreshold: 10,  // More tolerant
   )
   ```

### Issue: Slow search performance

**Diagnosis:**
```dart
final stats = service.getSearchStatistics();
print('Avg time: ${stats?['avgResponseTimeMs']}ms');
print('Cache hit rate: ${stats?['cacheHitRate']}%');
```

**Solutions:**
1. Increase search cache timeout
2. Add state filters to narrow scope
3. Enable sharding strategy (after migration)
4. Verify Firestore indexes exist

### Issue: Sharding not working

**Error:** Regional queries not using subcollections

**Diagnosis:**
```dart
final stats = service.getShardingStatistics();
print('Regional queries: ${stats?['queries']['regional']}');
```

**Solutions:**
1. Verify data migration completed
2. Ensure state filter is provided
3. Check regional collection structure in Firestore

---

## API Reference

See inline documentation in `unified_firestore_service.dart` for complete API reference.

### Key Classes

- `UnifiedFirestoreService`: Main service class
- `ResilienceStrategy`: Retry and circuit breaker logic
- `SearchStrategy`: Search optimization
- `ShardingStrategy`: Geographic optimization
- `ResilienceConfig`: Resilience configuration
- `SearchConfig`: Search configuration
- `ShardingConfig`: Sharding configuration
- `FirestoreException`: Custom exception class
- `BatchOperation`: Batch operation descriptor
- `SearchMetrics`: Search analytics

---

## Version History

### v1.0.0 (2025-10-25)
- Initial release
- Consolidates 4 services into unified architecture
- Implements strategy pattern for pluggable features
- Adds comprehensive monitoring and observability
- Full backward compatibility with existing services

---

## Support

For issues or questions:

1. Review inline documentation
2. Check migration guide
3. Enable debug logging
4. Test with strategies disabled to isolate issues

---

**Last Updated:** 2025-10-25
**Version:** 1.0.0
**Author:** Backend System Architect
