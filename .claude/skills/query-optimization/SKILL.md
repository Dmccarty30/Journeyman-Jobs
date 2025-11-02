# Query Optimization

## Overview

Query Optimization is the practice of structuring Firestore queries for maximum performance, minimal cost, and optimal user experience. This involves understanding Firestore's pricing model, index requirements, query limitations, and best practices for data retrieval.

**Key Objectives**:
- Minimize billable document reads
- Reduce query latency and improve response times
- Optimize index usage and reduce storage costs
- Implement efficient pagination and data loading strategies
- Balance real-time updates with cost efficiency

**Firestore Cost Model**:
- Document reads: $0.06 per 100,000 reads
- Document writes: $0.18 per 100,000 writes
- Document deletes: $0.02 per 100,000 deletes
- Index storage: $0.18 per GB/month
- Network egress: Varies by region

## Firebase Integration

### Core Query Concepts

```typescript
import {
  collection,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  endBefore,
  getDocs,
  getDoc,
  onSnapshot,
  QueryConstraint,
  DocumentSnapshot,
  Query,
  CollectionReference
} from 'firebase/firestore';

// Basic Query Structure
const buildQuery = (
  collectionRef: CollectionReference,
  constraints: QueryConstraint[]
): Query => {
  return query(collectionRef, ...constraints);
};

// Example: Optimized Job Search
const optimizedJobQuery = query(
  collection(db, 'jobs'),
  where('status', '==', 'active'),
  where('location', '==', 'New York'),
  orderBy('createdAt', 'desc'),
  limit(20)
);
```

### Index Management

**Composite Indexes**:
```typescript
// Required for queries with multiple where clauses or orderBy
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "jobs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "location", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "workers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "availability", "order": "ASCENDING" },
        { "fieldPath": "skills", "arrayConfig": "CONTAINS" },
        { "fieldPath": "rating", "order": "DESCENDING" }
      ]
    }
  ]
}
```

## Implementation Patterns

### 1. Query Builder Pattern

**Purpose**: Type-safe, composable query construction with optimization hints

```typescript
interface QueryOptions {
  limit?: number;
  orderBy?: { field: string; direction: 'asc' | 'desc' };
  where?: Array<{
    field: string;
    operator: FirestoreWhereOperator;
    value: any;
  }>;
  startAfter?: DocumentSnapshot;
}

class OptimizedQueryBuilder<T> {
  private constraints: QueryConstraint[] = [];
  private estimatedCost = 0;

  constructor(private collectionRef: CollectionReference) {}

  // Add where clause with cost estimation
  addWhere(
    field: string,
    operator: FirestoreWhereOperator,
    value: any
  ): this {
    this.constraints.push(where(field, operator, value));

    // Estimate selectivity (lower = more selective = better)
    if (operator === '==') {
      this.estimatedCost += 1; // Most selective
    } else if (operator === 'in' || operator === 'array-contains-any') {
      this.estimatedCost += 5; // Less selective
    } else {
      this.estimatedCost += 3; // Medium selectivity
    }

    return this;
  }

  // Add ordering with index check
  addOrderBy(field: string, direction: 'asc' | 'desc' = 'asc'): this {
    this.constraints.push(orderBy(field, direction));
    this.estimatedCost += 2; // Sorting has cost
    return this;
  }

  // Add limit to reduce reads
  addLimit(count: number): this {
    this.constraints.push(limit(count));
    return this;
  }

  // Add pagination cursor
  addPagination(cursor: DocumentSnapshot): this {
    this.constraints.push(startAfter(cursor));
    return this;
  }

  // Build optimized query
  build(): Query {
    // Optimize constraint order (equality first, then inequality, then sorting)
    const optimized = this.optimizeConstraintOrder();
    return query(this.collectionRef, ...optimized);
  }

  // Get estimated cost
  getEstimatedCost(): number {
    return this.estimatedCost;
  }

  // Optimize constraint order for better performance
  private optimizeConstraintOrder(): QueryConstraint[] {
    const equality: QueryConstraint[] = [];
    const inequality: QueryConstraint[] = [];
    const sorting: QueryConstraint[] = [];
    const other: QueryConstraint[] = [];

    this.constraints.forEach(constraint => {
      const type = (constraint as any).type;

      if (type === 'where') {
        const operator = (constraint as any).op;
        if (operator === '==') {
          equality.push(constraint);
        } else {
          inequality.push(constraint);
        }
      } else if (type === 'orderBy') {
        sorting.push(constraint);
      } else {
        other.push(constraint);
      }
    });

    return [...equality, ...inequality, ...sorting, ...other];
  }

  // Validate query (check for common mistakes)
  validate(): { valid: boolean; warnings: string[] } {
    const warnings: string[] = [];

    // Check for missing limit
    const hasLimit = this.constraints.some(c => (c as any).type === 'limit');
    if (!hasLimit) {
      warnings.push('Consider adding a limit to reduce document reads');
    }

    // Check for expensive operators
    const hasArrayContainsAny = this.constraints.some(c =>
      (c as any).op === 'array-contains-any'
    );
    if (hasArrayContainsAny) {
      warnings.push('array-contains-any can be expensive for large arrays');
    }

    // Check for multiple inequality operators
    const inequalityFields = this.constraints
      .filter(c => (c as any).type === 'where')
      .filter(c => {
        const op = (c as any).op;
        return ['<', '<=', '>', '>=', '!='].includes(op);
      })
      .map(c => (c as any).fieldPath);

    const uniqueInequalityFields = new Set(inequalityFields);
    if (uniqueInequalityFields.size > 1) {
      warnings.push('Multiple inequality filters require composite index');
    }

    return {
      valid: warnings.length === 0,
      warnings
    };
  }
}

// Usage Example
const queryBuilder = new OptimizedQueryBuilder(collection(db, 'jobs'));

const jobQuery = queryBuilder
  .addWhere('status', '==', 'active')
  .addWhere('location', '==', 'New York')
  .addOrderBy('createdAt', 'desc')
  .addLimit(20)
  .build();

const validation = queryBuilder.validate();
console.log('Estimated cost:', queryBuilder.getEstimatedCost());
console.log('Warnings:', validation.warnings);
```

### 2. Pagination Strategy

**Purpose**: Efficient data loading with cursor-based pagination

```typescript
interface PaginationResult<T> {
  data: T[];
  nextCursor?: DocumentSnapshot;
  previousCursor?: DocumentSnapshot;
  hasMore: boolean;
  totalEstimate?: number;
}

class PaginationManager<T> {
  private pageSize: number;
  private currentCursor?: DocumentSnapshot;

  constructor(
    private collectionRef: CollectionReference,
    private baseConstraints: QueryConstraint[],
    pageSize = 20
  ) {
    this.pageSize = pageSize;
  }

  // Fetch next page
  async next(): Promise<PaginationResult<T>> {
    const constraints = [...this.baseConstraints];

    if (this.currentCursor) {
      constraints.push(startAfter(this.currentCursor));
    }

    constraints.push(limit(this.pageSize + 1)); // +1 to check hasMore

    const q = query(this.collectionRef, ...constraints);
    const snapshot = await getDocs(q);

    const docs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as T));

    const hasMore = docs.length > this.pageSize;
    const data = hasMore ? docs.slice(0, this.pageSize) : docs;

    if (hasMore) {
      this.currentCursor = snapshot.docs[this.pageSize - 1];
    }

    return {
      data,
      nextCursor: hasMore ? this.currentCursor : undefined,
      hasMore
    };
  }

  // Fetch previous page (requires storing cursor history)
  async previous(previousCursor: DocumentSnapshot): Promise<PaginationResult<T>> {
    const constraints = [
      ...this.baseConstraints,
      endBefore(previousCursor),
      limit(this.pageSize)
    ];

    const q = query(this.collectionRef, ...constraints);
    const snapshot = await getDocs(q);

    const docs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as T));

    return {
      data: docs,
      previousCursor: snapshot.docs[0],
      hasMore: true // Assume more exists before
    };
  }

  // Reset pagination
  reset(): void {
    this.currentCursor = undefined;
  }
}

// Usage
const jobPagination = new PaginationManager(
  collection(db, 'jobs'),
  [
    where('status', '==', 'active'),
    orderBy('createdAt', 'desc')
  ],
  20
);

const firstPage = await jobPagination.next();
console.log('Jobs:', firstPage.data);
console.log('Has more:', firstPage.hasMore);

if (firstPage.hasMore) {
  const secondPage = await jobPagination.next();
}
```

### 3. Caching Strategy

**Purpose**: Reduce redundant reads and improve performance

```typescript
interface CacheEntry<T> {
  data: T;
  timestamp: number;
  expiresAt: number;
}

class QueryCache<T> {
  private cache = new Map<string, CacheEntry<T>>();
  private defaultTTL = 5 * 60 * 1000; // 5 minutes

  // Generate cache key from query
  private getCacheKey(query: Query): string {
    // Hash query constraints
    return JSON.stringify({
      path: (query as any)._query.path.segments,
      constraints: (query as any)._query.filters,
      order: (query as any)._query.explicitOrderBy
    });
  }

  // Get cached result
  get(query: Query): T | null {
    const key = this.getCacheKey(query);
    const entry = this.cache.get(key);

    if (!entry) return null;

    if (Date.now() > entry.expiresAt) {
      this.cache.delete(key);
      return null;
    }

    return entry.data;
  }

  // Set cache entry
  set(query: Query, data: T, ttl?: number): void {
    const key = this.getCacheKey(query);
    const now = Date.now();

    this.cache.set(key, {
      data,
      timestamp: now,
      expiresAt: now + (ttl || this.defaultTTL)
    });
  }

  // Invalidate cache entries
  invalidate(pattern?: string): void {
    if (!pattern) {
      this.cache.clear();
      return;
    }

    const keysToDelete: string[] = [];

    this.cache.forEach((_, key) => {
      if (key.includes(pattern)) {
        keysToDelete.push(key);
      }
    });

    keysToDelete.forEach(key => this.cache.delete(key));
  }

  // Get cache statistics
  getStats(): {
    size: number;
    oldestEntry: number;
    newestEntry: number;
  } {
    let oldest = Date.now();
    let newest = 0;

    this.cache.forEach(entry => {
      if (entry.timestamp < oldest) oldest = entry.timestamp;
      if (entry.timestamp > newest) newest = entry.timestamp;
    });

    return {
      size: this.cache.size,
      oldestEntry: oldest,
      newestEntry: newest
    };
  }
}

// Cached Query Executor
class CachedQueryExecutor<T> {
  private cache = new QueryCache<T[]>();

  async execute(query: Query): Promise<T[]> {
    // Check cache first
    const cached = this.cache.get(query);
    if (cached) {
      console.log('Cache hit');
      return cached;
    }

    console.log('Cache miss - fetching from Firestore');

    // Fetch from Firestore
    const snapshot = await getDocs(query);
    const data = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as T));

    // Cache result
    this.cache.set(query, data);

    return data;
  }

  invalidateCache(pattern?: string): void {
    this.cache.invalidate(pattern);
  }
}
```

### 4. Batch Fetching Strategy

**Purpose**: Reduce multiple single-document reads

```typescript
class BatchFetchManager {
  private batchSize = 10; // Firestore 'in' operator limit
  private fetchQueue = new Map<string, Promise<any>>();

  // Batch fetch documents by IDs
  async fetchByIds<T>(
    collectionPath: string,
    ids: string[]
  ): Promise<Map<string, T>> {
    const results = new Map<string, T>();

    // Split into batches of 10 (Firestore 'in' limit)
    for (let i = 0; i < ids.length; i += this.batchSize) {
      const batchIds = ids.slice(i, i + this.batchSize);

      const q = query(
        collection(db, collectionPath),
        where('__name__', 'in', batchIds)
      );

      const snapshot = await getDocs(q);

      snapshot.docs.forEach(doc => {
        results.set(doc.id, {
          id: doc.id,
          ...doc.data()
        } as T);
      });
    }

    return results;
  }

  // Deduplication: Prevent multiple fetches for same document
  async fetchWithDeduplication<T>(
    collectionPath: string,
    id: string
  ): Promise<T | null> {
    const cacheKey = `${collectionPath}/${id}`;

    // Check if already fetching
    if (this.fetchQueue.has(cacheKey)) {
      return this.fetchQueue.get(cacheKey);
    }

    // Create fetch promise
    const fetchPromise = (async () => {
      const docRef = doc(db, collectionPath, id);
      const docSnap = await getDoc(docRef);

      if (!docSnap.exists()) return null;

      return {
        id: docSnap.id,
        ...docSnap.data()
      } as T;
    })();

    // Store in queue
    this.fetchQueue.set(cacheKey, fetchPromise);

    try {
      const result = await fetchPromise;
      return result;
    } finally {
      // Remove from queue after completion
      this.fetchQueue.delete(cacheKey);
    }
  }
}

// Usage
const batchManager = new BatchFetchManager();

// Fetch multiple jobs at once
const jobIds = ['job1', 'job2', 'job3', 'job4'];
const jobs = await batchManager.fetchByIds<Job>('jobs', jobIds);

// Deduplication prevents redundant fetches
const job1Promise = batchManager.fetchWithDeduplication<Job>('jobs', 'job1');
const job1DuplicatePromise = batchManager.fetchWithDeduplication<Job>('jobs', 'job1');

// Both resolve to same promise - only one Firestore read
const [job1a, job1b] = await Promise.all([job1Promise, job1DuplicatePromise]);
```

## JJ-Specific Examples

### Job Search Optimization

```typescript
// Optimized job search with multiple filters
class OptimizedJobSearch {
  private cache = new QueryCache<Job[]>();
  private batchFetcher = new BatchFetchManager();

  // Search jobs with intelligent query building
  async searchJobs(params: {
    status?: string;
    location?: string;
    tradeType?: string;
    minPay?: number;
    skills?: string[];
    limit?: number;
    cursor?: DocumentSnapshot;
  }): Promise<PaginationResult<Job>> {
    const queryBuilder = new OptimizedQueryBuilder<Job>(
      collection(db, 'jobs')
    );

    // Add filters in order of selectivity (most selective first)
    if (params.status) {
      queryBuilder.addWhere('status', '==', params.status);
    }

    if (params.tradeType) {
      queryBuilder.addWhere('tradeType', '==', params.tradeType);
    }

    if (params.location) {
      queryBuilder.addWhere('location', '==', params.location);
    }

    if (params.skills && params.skills.length > 0) {
      // Use array-contains-any (max 10 values)
      const skillsToQuery = params.skills.slice(0, 10);
      queryBuilder.addWhere('requiredSkills', 'array-contains-any', skillsToQuery);
    }

    if (params.minPay) {
      queryBuilder.addWhere('payRate', '>=', params.minPay);
    }

    // Add ordering and pagination
    queryBuilder.addOrderBy('createdAt', 'desc');
    queryBuilder.addLimit(params.limit || 20);

    if (params.cursor) {
      queryBuilder.addPagination(params.cursor);
    }

    // Validate query
    const validation = queryBuilder.validate();
    if (validation.warnings.length > 0) {
      console.warn('Query warnings:', validation.warnings);
    }

    const query = queryBuilder.build();

    // Check cache first
    const cached = this.cache.get(query);
    if (cached) {
      return {
        data: cached,
        hasMore: cached.length === (params.limit || 20)
      };
    }

    // Execute query
    const snapshot = await getDocs(query);
    const jobs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Job));

    // Cache results
    this.cache.set(query, jobs);

    return {
      data: jobs,
      nextCursor: snapshot.docs[snapshot.docs.length - 1],
      hasMore: jobs.length === (params.limit || 20)
    };
  }

  // Fetch job details with employer info (optimized)
  async getJobWithEmployer(jobId: string): Promise<{
    job: Job;
    employer: Employer;
  } | null> {
    // Fetch job
    const job = await this.batchFetcher.fetchWithDeduplication<Job>(
      'jobs',
      jobId
    );

    if (!job) return null;

    // Fetch employer (deduplicated)
    const employer = await this.batchFetcher.fetchWithDeduplication<Employer>(
      'employers',
      job.employerId
    );

    if (!employer) return null;

    return { job, employer };
  }

  // Invalidate cache when jobs change
  onJobUpdate(jobId: string): void {
    this.cache.invalidate('jobs');
  }
}
```

### Worker Discovery Optimization

```typescript
// Optimized worker discovery with skill matching
class OptimizedWorkerDiscovery {
  // Find workers matching job requirements
  async findMatchingWorkers(job: Job): Promise<Worker[]> {
    const queryBuilder = new OptimizedQueryBuilder<Worker>(
      collection(db, 'workers')
    );

    // Most selective filters first
    queryBuilder
      .addWhere('availability', '==', 'available')
      .addWhere('location', '==', job.location);

    // Skill matching (max 10 skills due to array-contains-any limit)
    if (job.requiredSkills.length > 0) {
      const topSkills = job.requiredSkills.slice(0, 10);
      queryBuilder.addWhere('skills', 'array-contains-any', topSkills);
    }

    // Order by rating
    queryBuilder
      .addOrderBy('rating', 'desc')
      .addLimit(50);

    const query = queryBuilder.build();
    const snapshot = await getDocs(query);

    const workers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Worker));

    // Client-side filtering for exact skill match
    return this.rankWorkersBySkillMatch(workers, job.requiredSkills);
  }

  // Rank workers by skill match percentage
  private rankWorkersBySkillMatch(
    workers: Worker[],
    requiredSkills: string[]
  ): Worker[] {
    return workers
      .map(worker => {
        const matchedSkills = worker.skills.filter(skill =>
          requiredSkills.includes(skill.name)
        );

        const matchPercentage = matchedSkills.length / requiredSkills.length;

        return {
          ...worker,
          skillMatchPercentage: matchPercentage
        };
      })
      .sort((a, b) => b.skillMatchPercentage - a.skillMatchPercentage);
  }
}
```

## Security Considerations

### Query Security Rules

**Firestore Security Rules** must align with optimized queries:

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Jobs collection
    match /jobs/{jobId} {
      // Allow read if status is active (aligns with optimized queries)
      allow read: if resource.data.status == 'active';

      // Allow create for authenticated employers
      allow create: if request.auth != null &&
                       request.auth.uid == request.resource.data.employerId;

      // Allow update/delete for job owner
      allow update, delete: if request.auth != null &&
                               request.auth.uid == resource.data.employerId;
    }

    // Workers collection
    match /workers/{workerId} {
      // Allow read for authenticated users
      allow read: if request.auth != null;

      // Allow write for owner only
      allow write: if request.auth != null &&
                      request.auth.uid == workerId;
    }
  }
}
```

### Input Validation

```typescript
class QueryValidator {
  // Validate and sanitize query parameters
  static validateJobSearch(params: any): {
    valid: boolean;
    sanitized?: any;
    errors?: string[];
  } {
    const errors: string[] = [];

    // Validate status
    if (params.status && !['active', 'filled', 'expired'].includes(params.status)) {
      errors.push('Invalid status value');
    }

    // Validate limit
    if (params.limit && (params.limit < 1 || params.limit > 100)) {
      errors.push('Limit must be between 1 and 100');
    }

    // Validate skills array
    if (params.skills && params.skills.length > 10) {
      errors.push('Maximum 10 skills allowed');
    }

    if (errors.length > 0) {
      return { valid: false, errors };
    }

    // Sanitize parameters
    const sanitized = {
      status: params.status || 'active',
      location: params.location?.trim(),
      tradeType: params.tradeType?.trim(),
      minPay: params.minPay ? Math.max(0, params.minPay) : undefined,
      skills: params.skills?.map((s: string) => s.trim().toLowerCase()),
      limit: Math.min(params.limit || 20, 100)
    };

    return { valid: true, sanitized };
  }
}
```

## Performance Optimization

### 1. Index Strategy

```typescript
// Automatically generate index configuration
class IndexGenerator {
  private indexes: any[] = [];

  // Analyze query and suggest index
  analyzeQuery(query: Query): void {
    const filters = (query as any)._query.filters;
    const orderBy = (query as any)._query.explicitOrderBy;

    const fields: any[] = [];

    // Add filter fields
    filters.forEach((filter: any) => {
      fields.push({
        fieldPath: filter.field.canonicalString(),
        order: 'ASCENDING'
      });
    });

    // Add orderBy fields
    orderBy.forEach((order: any) => {
      fields.push({
        fieldPath: order.field.canonicalString(),
        order: order.dir === 'desc' ? 'DESCENDING' : 'ASCENDING'
      });
    });

    if (fields.length > 1) {
      this.indexes.push({
        collectionGroup: (query as any)._query.path.segments[0],
        queryScope: 'COLLECTION',
        fields
      });
    }
  }

  // Generate firestore.indexes.json
  generateConfig(): string {
    return JSON.stringify({ indexes: this.indexes }, null, 2);
  }
}
```

### 2. Query Performance Monitoring

```typescript
class QueryPerformanceMonitor {
  private metrics = new Map<string, {
    count: number;
    totalDuration: number;
    avgDuration: number;
    documentReads: number;
  }>();

  // Track query performance
  async monitorQuery<T>(
    query: Query,
    executor: () => Promise<T>
  ): Promise<T> {
    const queryKey = this.getQueryKey(query);
    const startTime = Date.now();

    try {
      const result = await executor();
      const duration = Date.now() - startTime;

      // Get document count
      const snapshot = await getDocs(query);
      const documentReads = snapshot.size;

      // Update metrics
      this.updateMetrics(queryKey, duration, documentReads);

      return result;
    } catch (error) {
      console.error('Query execution failed:', error);
      throw error;
    }
  }

  private updateMetrics(
    queryKey: string,
    duration: number,
    documentReads: number
  ): void {
    const existing = this.metrics.get(queryKey);

    if (existing) {
      existing.count++;
      existing.totalDuration += duration;
      existing.avgDuration = existing.totalDuration / existing.count;
      existing.documentReads += documentReads;
    } else {
      this.metrics.set(queryKey, {
        count: 1,
        totalDuration: duration,
        avgDuration: duration,
        documentReads
      });
    }
  }

  // Get performance report
  getReport(): Array<{
    query: string;
    executions: number;
    avgDuration: number;
    totalReads: number;
    estimatedCost: number;
  }> {
    const report: any[] = [];

    this.metrics.forEach((metrics, query) => {
      report.push({
        query,
        executions: metrics.count,
        avgDuration: Math.round(metrics.avgDuration),
        totalReads: metrics.documentReads,
        estimatedCost: (metrics.documentReads / 100000) * 0.06 // $0.06 per 100k reads
      });
    });

    return report.sort((a, b) => b.estimatedCost - a.estimatedCost);
  }

  private getQueryKey(query: Query): string {
    return JSON.stringify({
      path: (query as any)._query.path.segments,
      filters: (query as any)._query.filters,
      orderBy: (query as any)._query.explicitOrderBy
    });
  }
}
```

### 3. Real-Time Listener Optimization

```typescript
class OptimizedRealtimeListener {
  private unsubscribers = new Map<string, () => void>();

  // Subscribe with automatic cleanup
  subscribe<T>(
    query: Query,
    callback: (data: T[]) => void,
    options?: {
      includeMetadataChanges?: boolean;
      onError?: (error: Error) => void;
    }
  ): string {
    const listenerId = Math.random().toString(36);

    const unsubscribe = onSnapshot(
      query,
      {
        includeMetadataChanges: options?.includeMetadataChanges || false
      },
      (snapshot) => {
        // Only process if data actually changed
        if (!snapshot.metadata.hasPendingWrites) {
          const data = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          } as T));

          callback(data);
        }
      },
      (error) => {
        console.error('Snapshot listener error:', error);
        options?.onError?.(error);
      }
    );

    this.unsubscribers.set(listenerId, unsubscribe);
    return listenerId;
  }

  // Unsubscribe from listener
  unsubscribe(listenerId: string): void {
    const unsubscribe = this.unsubscribers.get(listenerId);
    if (unsubscribe) {
      unsubscribe();
      this.unsubscribers.delete(listenerId);
    }
  }

  // Unsubscribe all listeners
  unsubscribeAll(): void {
    this.unsubscribers.forEach(unsubscribe => unsubscribe());
    this.unsubscribers.clear();
  }
}

// Usage
const realtimeListener = new OptimizedRealtimeListener();

// Subscribe to active jobs
const listenerId = realtimeListener.subscribe<Job>(
  query(
    collection(db, 'jobs'),
    where('status', '==', 'active'),
    orderBy('createdAt', 'desc'),
    limit(20)
  ),
  (jobs) => {
    console.log('Jobs updated:', jobs.length);
    updateUI(jobs);
  },
  {
    onError: (error) => {
      console.error('Failed to listen to jobs:', error);
    }
  }
);

// Clean up when component unmounts
onUnmount(() => {
  realtimeListener.unsubscribe(listenerId);
});
```

## Error Handling

```typescript
class QueryErrorHandler {
  // Handle common Firestore errors
  static async executeWithRetry<T>(
    executor: () => Promise<T>,
    maxRetries = 3
  ): Promise<T> {
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await executor();
      } catch (error: any) {
        // Permission denied - don't retry
        if (error.code === 'permission-denied') {
          throw new Error('Insufficient permissions to access data');
        }

        // Quota exceeded - don't retry
        if (error.code === 'resource-exhausted') {
          throw new Error('Query quota exceeded. Please try again later.');
        }

        // Network error - retry with backoff
        if (error.code === 'unavailable' || error.code === 'deadline-exceeded') {
          if (attempt < maxRetries - 1) {
            const delay = Math.pow(2, attempt) * 1000;
            await new Promise(resolve => setTimeout(resolve, delay));
            continue;
          }
        }

        throw error;
      }
    }

    throw new Error('Max retries exceeded');
  }
}
```

## Cloud Functions Examples

```typescript
// Scheduled function to optimize indexes
export const optimizeIndexes = functions.pubsub
  .schedule('0 2 * * 0') // Weekly at 2 AM
  .onRun(async (context) => {
    const indexGenerator = new IndexGenerator();
    const performanceMonitor = new QueryPerformanceMonitor();

    // Analyze most common queries
    const report = performanceMonitor.getReport();

    // Generate index recommendations
    report.slice(0, 10).forEach(metric => {
      // Log expensive queries
      console.log('Expensive query:', metric);
    });

    // Generate index configuration
    const indexConfig = indexGenerator.generateConfig();
    console.log('Recommended indexes:', indexConfig);
  });
```

## Best Practices

1. **Always use limits**: Never fetch unlimited documents
2. **Index wisely**: Create composite indexes for complex queries
3. **Cache aggressively**: Reduce redundant reads with intelligent caching
4. **Batch operations**: Use 'in' queries and batch fetches when possible
5. **Monitor costs**: Track document reads and optimize expensive queries
6. **Paginate properly**: Use cursor-based pagination for large datasets
7. **Validate inputs**: Sanitize and validate all query parameters
8. **Optimize listener usage**: Minimize real-time listeners and clean up properly
9. **Use query builders**: Enforce best practices with type-safe builders
10. **Performance testing**: Regularly analyze query performance and costs
