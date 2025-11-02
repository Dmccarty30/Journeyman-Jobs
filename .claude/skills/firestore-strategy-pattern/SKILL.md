# Firestore Strategy Pattern

## Overview

The Firestore Strategy Pattern is a behavioral design pattern that encapsulates Firestore database operations into interchangeable strategy classes. This pattern enables flexible, maintainable, and testable database access layers by separating business logic from data persistence concerns.

**Key Benefits**:
- Swappable database implementations without changing business logic
- Consistent API across different Firestore operation types
- Enhanced testability through strategy injection
- Reduced code duplication and improved maintainability
- Type-safe operations with TypeScript generics

## Firebase Integration

### Core Firebase Services
```typescript
import {
  getFirestore,
  collection,
  doc,
  query,
  where,
  orderBy,
  limit,
  getDocs,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  writeBatch,
  Timestamp,
  DocumentReference,
  CollectionReference,
  Query
} from 'firebase/firestore';

// Initialize Firestore
const db = getFirestore();
```

### Strategy Pattern Architecture
```typescript
// Base Strategy Interface
interface FirestoreStrategy<T> {
  execute(params: any): Promise<T>;
  validate?(params: any): boolean;
  onError?(error: Error): void;
}

// Concrete Strategy Implementation
class QueryStrategy<T> implements FirestoreStrategy<T[]> {
  constructor(
    private collectionName: string,
    private queryBuilder: (ref: CollectionReference) => Query
  ) {}

  async execute(): Promise<T[]> {
    const ref = collection(db, this.collectionName);
    const q = this.queryBuilder(ref);
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as T));
  }
}
```

## Implementation Patterns

### 1. UnifiedFirestoreService Pattern

**Purpose**: Single service class managing all Firestore operations through strategy injection

**Structure**:
```typescript
export class UnifiedFirestoreService {
  private strategies: Map<string, FirestoreStrategy<any>> = new Map();

  // Strategy Registration
  registerStrategy<T>(name: string, strategy: FirestoreStrategy<T>): void {
    this.strategies.set(name, strategy);
  }

  // Strategy Execution
  async execute<T>(strategyName: string, params?: any): Promise<T> {
    const strategy = this.strategies.get(strategyName);
    if (!strategy) {
      throw new Error(`Strategy '${strategyName}' not found`);
    }

    if (strategy.validate && !strategy.validate(params)) {
      throw new Error('Strategy validation failed');
    }

    try {
      return await strategy.execute(params);
    } catch (error) {
      if (strategy.onError) {
        strategy.onError(error as Error);
      }
      throw error;
    }
  }

  // Convenience Methods
  async get<T>(collection: string, id: string): Promise<T | null> {
    return this.execute('get', { collection, id });
  }

  async query<T>(collection: string, constraints: any[]): Promise<T[]> {
    return this.execute('query', { collection, constraints });
  }

  async create<T>(collection: string, data: T): Promise<string> {
    return this.execute('create', { collection, data });
  }

  async update<T>(collection: string, id: string, data: Partial<T>): Promise<void> {
    return this.execute('update', { collection, id, data });
  }

  async delete(collection: string, id: string): Promise<void> {
    return this.execute('delete', { collection, id });
  }
}
```

### 2. Resilience Strategy Pattern

**Purpose**: Automatic retry, fallback, and error recovery for Firestore operations

**Implementation**:
```typescript
interface ResilienceConfig {
  maxRetries: number;
  retryDelay: number;
  exponentialBackoff: boolean;
  fallbackStrategy?: FirestoreStrategy<any>;
  circuitBreakerThreshold?: number;
}

export class ResilienceStrategy<T> implements FirestoreStrategy<T> {
  private failureCount = 0;
  private circuitOpen = false;

  constructor(
    private baseStrategy: FirestoreStrategy<T>,
    private config: ResilienceConfig
  ) {}

  async execute(params: any): Promise<T> {
    // Circuit Breaker Check
    if (this.circuitOpen) {
      if (this.config.fallbackStrategy) {
        return this.config.fallbackStrategy.execute(params);
      }
      throw new Error('Circuit breaker is open');
    }

    // Retry Logic
    for (let attempt = 0; attempt <= this.config.maxRetries; attempt++) {
      try {
        const result = await this.baseStrategy.execute(params);
        this.failureCount = 0; // Reset on success
        return result;
      } catch (error) {
        this.failureCount++;

        // Open circuit if threshold exceeded
        if (this.config.circuitBreakerThreshold &&
            this.failureCount >= this.config.circuitBreakerThreshold) {
          this.circuitOpen = true;
          setTimeout(() => {
            this.circuitOpen = false;
            this.failureCount = 0;
          }, 60000); // Reset after 1 minute
        }

        // Last attempt - throw error
        if (attempt === this.config.maxRetries) {
          throw error;
        }

        // Calculate delay
        const delay = this.config.exponentialBackoff
          ? this.config.retryDelay * Math.pow(2, attempt)
          : this.config.retryDelay;

        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    throw new Error('Max retries exceeded');
  }
}
```

### 3. Search Strategy Pattern

**Purpose**: Flexible search implementations (client-side filter, composite index, Algolia)

**Implementation**:
```typescript
// Base Search Strategy
interface SearchStrategy {
  search(query: string, filters?: any): Promise<any[]>;
}

// Client-Side Filter Strategy
export class ClientSideSearchStrategy implements SearchStrategy {
  constructor(
    private firestoreService: UnifiedFirestoreService,
    private collection: string
  ) {}

  async search(query: string, filters?: any): Promise<any[]> {
    // Fetch all documents (with pagination for large sets)
    const allDocs = await this.firestoreService.query(this.collection, []);

    // Client-side filtering
    return allDocs.filter(doc => {
      const searchableFields = this.getSearchableFields(doc);
      const matchesQuery = searchableFields.some(field =>
        field.toLowerCase().includes(query.toLowerCase())
      );

      if (filters) {
        return matchesQuery && this.applyFilters(doc, filters);
      }

      return matchesQuery;
    });
  }

  private getSearchableFields(doc: any): string[] {
    return [
      doc.title || '',
      doc.description || '',
      doc.tags?.join(' ') || '',
      doc.location || ''
    ];
  }

  private applyFilters(doc: any, filters: any): boolean {
    return Object.entries(filters).every(([key, value]) => {
      if (Array.isArray(value)) {
        return value.includes(doc[key]);
      }
      return doc[key] === value;
    });
  }
}

// Composite Index Strategy
export class CompositeIndexSearchStrategy implements SearchStrategy {
  constructor(
    private firestoreService: UnifiedFirestoreService,
    private collection: string
  ) {}

  async search(query: string, filters?: any): Promise<any[]> {
    const constraints = [];

    // Add search constraint (requires composite index)
    if (query) {
      constraints.push(where('searchTokens', 'array-contains', query.toLowerCase()));
    }

    // Add filter constraints
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (Array.isArray(value)) {
          constraints.push(where(key, 'in', value));
        } else {
          constraints.push(where(key, '==', value));
        }
      });
    }

    return this.firestoreService.query(this.collection, constraints);
  }
}

// Algolia Strategy (External Search)
export class AlgoliaSearchStrategy implements SearchStrategy {
  constructor(
    private algoliaClient: any,
    private indexName: string
  ) {}

  async search(query: string, filters?: any): Promise<any[]> {
    const index = this.algoliaClient.initIndex(this.indexName);

    const searchParams: any = {
      query,
      hitsPerPage: 100
    };

    if (filters) {
      searchParams.filters = this.buildAlgoliaFilters(filters);
    }

    const { hits } = await index.search('', searchParams);
    return hits;
  }

  private buildAlgoliaFilters(filters: any): string {
    return Object.entries(filters)
      .map(([key, value]) => {
        if (Array.isArray(value)) {
          return value.map(v => `${key}:${v}`).join(' OR ');
        }
        return `${key}:${value}`;
      })
      .join(' AND ');
  }
}
```

## JJ-Specific Examples

### Job Listing Management
```typescript
// Job CRUD Strategies
class CreateJobStrategy implements FirestoreStrategy<string> {
  async execute(params: { data: Job }): Promise<string> {
    const { data } = params;
    const jobRef = doc(collection(db, 'jobs'));

    const jobData = {
      ...data,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      status: 'active',
      searchTokens: this.generateSearchTokens(data)
    };

    await setDoc(jobRef, jobData);
    return jobRef.id;
  }

  private generateSearchTokens(job: Job): string[] {
    const tokens = new Set<string>();

    // Title tokens
    job.title.toLowerCase().split(/\s+/).forEach(token => tokens.add(token));

    // Location tokens
    if (job.location) {
      job.location.toLowerCase().split(/\s+/).forEach(token => tokens.add(token));
    }

    // Skill tokens
    job.requiredSkills?.forEach(skill => {
      tokens.add(skill.toLowerCase());
    });

    return Array.from(tokens);
  }
}

// Job Query Strategy with Filters
class QueryJobsStrategy implements FirestoreStrategy<Job[]> {
  async execute(params: {
    status?: string;
    location?: string;
    tradeType?: string;
    limit?: number;
  }): Promise<Job[]> {
    const constraints: any[] = [];

    if (params.status) {
      constraints.push(where('status', '==', params.status));
    }

    if (params.location) {
      constraints.push(where('location', '==', params.location));
    }

    if (params.tradeType) {
      constraints.push(where('tradeType', '==', params.tradeType));
    }

    constraints.push(orderBy('createdAt', 'desc'));

    if (params.limit) {
      constraints.push(limit(params.limit));
    }

    const q = query(collection(db, 'jobs'), ...constraints);
    const snapshot = await getDocs(q);

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Job));
  }
}

// Usage
const firestoreService = new UnifiedFirestoreService();

// Register strategies
firestoreService.registerStrategy('createJob', new CreateJobStrategy());
firestoreService.registerStrategy('queryJobs', new QueryJobsStrategy());

// Wrap with resilience
const resilientCreateJob = new ResilienceStrategy(
  new CreateJobStrategy(),
  {
    maxRetries: 3,
    retryDelay: 1000,
    exponentialBackoff: true
  }
);

firestoreService.registerStrategy('createJobResilient', resilientCreateJob);

// Execute
const jobId = await firestoreService.execute('createJobResilient', {
  data: newJob
});

const jobs = await firestoreService.execute('queryJobs', {
  status: 'active',
  tradeType: 'electrician',
  limit: 10
});
```

### Worker Profile Management
```typescript
// Worker Profile Update Strategy
class UpdateWorkerProfileStrategy implements FirestoreStrategy<void> {
  async execute(params: {
    workerId: string;
    updates: Partial<WorkerProfile>;
  }): Promise<void> {
    const { workerId, updates } = params;
    const workerRef = doc(db, 'workers', workerId);

    // Validate worker exists
    const workerSnap = await getDoc(workerRef);
    if (!workerSnap.exists()) {
      throw new Error('Worker not found');
    }

    await updateDoc(workerRef, {
      ...updates,
      updatedAt: Timestamp.now()
    });
  }

  validate(params: any): boolean {
    return !!params.workerId && !!params.updates;
  }

  onError(error: Error): void {
    console.error('Failed to update worker profile:', error);
    // Send to error monitoring service
  }
}

// Batch Update Strategy for Skills
class BatchUpdateSkillsStrategy implements FirestoreStrategy<void> {
  async execute(params: {
    workerId: string;
    skills: Skill[];
  }): Promise<void> {
    const { workerId, skills } = params;
    const batch = writeBatch(db);

    const workerRef = doc(db, 'workers', workerId);
    batch.update(workerRef, {
      skills,
      skillsUpdatedAt: Timestamp.now()
    });

    // Update skill index for search
    skills.forEach(skill => {
      const skillIndexRef = doc(db, 'skillIndex', `${workerId}_${skill.name}`);
      batch.set(skillIndexRef, {
        workerId,
        skillName: skill.name,
        proficiencyLevel: skill.proficiencyLevel,
        verified: skill.verified || false
      });
    });

    await batch.commit();
  }
}
```

## Security Considerations

### 1. Security Rules Integration
```typescript
// Strategy with Security Context
interface SecurityContext {
  userId: string;
  role: 'worker' | 'employer' | 'admin';
  permissions: string[];
}

class SecureCreateJobStrategy implements FirestoreStrategy<string> {
  constructor(private securityContext: SecurityContext) {}

  async execute(params: { data: Job }): Promise<string> {
    // Verify user has permission to create jobs
    if (!this.securityContext.permissions.includes('create:jobs')) {
      throw new Error('Insufficient permissions');
    }

    // Ensure employer ID matches authenticated user
    if (params.data.employerId !== this.securityContext.userId) {
      throw new Error('Cannot create job for another employer');
    }

    const jobRef = doc(collection(db, 'jobs'));
    await setDoc(jobRef, {
      ...params.data,
      createdBy: this.securityContext.userId,
      createdAt: Timestamp.now()
    });

    return jobRef.id;
  }
}
```

### 2. Data Validation
```typescript
// Validation Strategy Decorator
class ValidationStrategy<T> implements FirestoreStrategy<T> {
  constructor(
    private baseStrategy: FirestoreStrategy<T>,
    private validator: (params: any) => boolean,
    private sanitizer?: (params: any) => any
  ) {}

  async execute(params: any): Promise<T> {
    // Sanitize input
    const sanitizedParams = this.sanitizer
      ? this.sanitizer(params)
      : params;

    // Validate
    if (!this.validator(sanitizedParams)) {
      throw new Error('Validation failed');
    }

    return this.baseStrategy.execute(sanitizedParams);
  }
}

// Usage
const validatedCreateJob = new ValidationStrategy(
  new CreateJobStrategy(),
  (params) => {
    const { data } = params;
    return !!(
      data.title &&
      data.description &&
      data.employerId &&
      data.location &&
      data.tradeType
    );
  },
  (params) => {
    // Sanitize HTML, trim strings, etc.
    return {
      data: {
        ...params.data,
        title: params.data.title.trim(),
        description: sanitizeHtml(params.data.description)
      }
    };
  }
);
```

## Performance Optimization

### 1. Caching Strategy
```typescript
class CachedQueryStrategy<T> implements FirestoreStrategy<T> {
  private cache = new Map<string, { data: T; timestamp: number }>();
  private cacheTTL = 5 * 60 * 1000; // 5 minutes

  constructor(private baseStrategy: FirestoreStrategy<T>) {}

  async execute(params: any): Promise<T> {
    const cacheKey = JSON.stringify(params);
    const cached = this.cache.get(cacheKey);

    if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
      return cached.data;
    }

    const data = await this.baseStrategy.execute(params);
    this.cache.set(cacheKey, { data, timestamp: Date.now() });

    return data;
  }

  clearCache(): void {
    this.cache.clear();
  }
}
```

### 2. Batch Operations
```typescript
class BatchWriteStrategy implements FirestoreStrategy<void> {
  async execute(params: {
    operations: Array<{
      type: 'create' | 'update' | 'delete';
      collection: string;
      id?: string;
      data?: any;
    }>;
  }): Promise<void> {
    const { operations } = params;
    const batch = writeBatch(db);

    operations.forEach(op => {
      const ref = op.id
        ? doc(db, op.collection, op.id)
        : doc(collection(db, op.collection));

      switch (op.type) {
        case 'create':
          batch.set(ref, op.data);
          break;
        case 'update':
          batch.update(ref, op.data);
          break;
        case 'delete':
          batch.delete(ref);
          break;
      }
    });

    await batch.commit();
  }
}
```

### 3. Pagination Strategy
```typescript
class PaginatedQueryStrategy<T> implements FirestoreStrategy<{
  data: T[];
  nextPageToken?: any;
  hasMore: boolean;
}> {
  async execute(params: {
    collection: string;
    constraints: any[];
    pageSize: number;
    pageToken?: any;
  }): Promise<{ data: T[]; nextPageToken?: any; hasMore: boolean }> {
    const { collection: collectionName, constraints, pageSize, pageToken } = params;

    let q = query(
      collection(db, collectionName),
      ...constraints,
      limit(pageSize + 1) // Fetch one extra to check if more exist
    );

    if (pageToken) {
      q = query(q, startAfter(pageToken));
    }

    const snapshot = await getDocs(q);
    const docs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as T));

    const hasMore = docs.length > pageSize;
    const data = hasMore ? docs.slice(0, pageSize) : docs;
    const nextPageToken = hasMore ? snapshot.docs[pageSize - 1] : undefined;

    return { data, nextPageToken, hasMore };
  }
}
```

## Error Handling

### 1. Error Classification
```typescript
class FirestoreError extends Error {
  constructor(
    message: string,
    public code: string,
    public retryable: boolean = false,
    public originalError?: Error
  ) {
    super(message);
    this.name = 'FirestoreError';
  }
}

class ErrorHandlingStrategy<T> implements FirestoreStrategy<T> {
  constructor(private baseStrategy: FirestoreStrategy<T>) {}

  async execute(params: any): Promise<T> {
    try {
      return await this.baseStrategy.execute(params);
    } catch (error: any) {
      // Classify error
      if (error.code === 'permission-denied') {
        throw new FirestoreError(
          'Insufficient permissions',
          'PERMISSION_DENIED',
          false,
          error
        );
      }

      if (error.code === 'unavailable') {
        throw new FirestoreError(
          'Firestore temporarily unavailable',
          'UNAVAILABLE',
          true,
          error
        );
      }

      if (error.code === 'deadline-exceeded') {
        throw new FirestoreError(
          'Operation timeout',
          'TIMEOUT',
          true,
          error
        );
      }

      // Unknown error
      throw new FirestoreError(
        'Unknown Firestore error',
        'UNKNOWN',
        false,
        error
      );
    }
  }
}
```

### 2. Logging Strategy
```typescript
class LoggingStrategy<T> implements FirestoreStrategy<T> {
  constructor(
    private baseStrategy: FirestoreStrategy<T>,
    private logger: any
  ) {}

  async execute(params: any): Promise<T> {
    const startTime = Date.now();
    const operationId = Math.random().toString(36);

    this.logger.info('Firestore operation started', {
      operationId,
      strategy: this.baseStrategy.constructor.name,
      params
    });

    try {
      const result = await this.baseStrategy.execute(params);
      const duration = Date.now() - startTime;

      this.logger.info('Firestore operation succeeded', {
        operationId,
        duration
      });

      return result;
    } catch (error) {
      const duration = Date.now() - startTime;

      this.logger.error('Firestore operation failed', {
        operationId,
        duration,
        error
      });

      throw error;
    }
  }
}
```

## Cloud Functions Examples

### 1. Trigger-Based Strategies
```typescript
// onCreate Trigger Strategy
export const onJobCreated = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snapshot, context) => {
    const job = snapshot.data() as Job;
    const jobId = context.params.jobId;

    // Execute notification strategy
    const notificationStrategy = new JobCreatedNotificationStrategy();
    await notificationStrategy.execute({ job, jobId });

    // Execute indexing strategy
    const indexStrategy = new AlgoliaIndexStrategy();
    await indexStrategy.execute({ job, jobId });
  });

// Notification Strategy
class JobCreatedNotificationStrategy implements FirestoreStrategy<void> {
  async execute(params: { job: Job; jobId: string }): Promise<void> {
    const { job, jobId } = params;

    // Find matching workers
    const matchingWorkers = await this.findMatchingWorkers(job);

    // Create notifications batch
    const batch = writeBatch(db);

    matchingWorkers.forEach(worker => {
      const notificationRef = doc(collection(db, 'notifications'));
      batch.set(notificationRef, {
        type: 'new_job_match',
        workerId: worker.id,
        jobId,
        jobTitle: job.title,
        createdAt: Timestamp.now(),
        read: false
      });
    });

    await batch.commit();
  }

  private async findMatchingWorkers(job: Job): Promise<Worker[]> {
    // Query workers with matching skills and location
    const constraints = [
      where('skills', 'array-contains-any', job.requiredSkills),
      where('location', '==', job.location),
      where('availability', '==', 'available')
    ];

    const q = query(collection(db, 'workers'), ...constraints);
    const snapshot = await getDocs(q);

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Worker));
  }
}
```

### 2. Scheduled Functions
```typescript
// Daily Job Expiration Check
export const checkExpiredJobs = functions.pubsub
  .schedule('0 0 * * *') // Daily at midnight
  .onRun(async (context) => {
    const expirationStrategy = new ExpireOldJobsStrategy();
    await expirationStrategy.execute({});
  });

class ExpireOldJobsStrategy implements FirestoreStrategy<void> {
  async execute(params: {}): Promise<void> {
    const thirtyDaysAgo = Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );

    const q = query(
      collection(db, 'jobs'),
      where('status', '==', 'active'),
      where('createdAt', '<', thirtyDaysAgo)
    );

    const snapshot = await getDocs(q);
    const batch = writeBatch(db);

    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: 'expired',
        expiredAt: Timestamp.now()
      });
    });

    await batch.commit();
  }
}
```

### 3. Callable Functions
```typescript
// Worker Search Function
export const searchWorkers = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated'
    );
  }

  const searchStrategy = new WorkerSearchStrategy();
  return searchStrategy.execute(data);
});

class WorkerSearchStrategy implements FirestoreStrategy<Worker[]> {
  async execute(params: {
    skills?: string[];
    location?: string;
    availability?: string;
  }): Promise<Worker[]> {
    const constraints: any[] = [];

    if (params.skills?.length) {
      constraints.push(where('skills', 'array-contains-any', params.skills));
    }

    if (params.location) {
      constraints.push(where('location', '==', params.location));
    }

    if (params.availability) {
      constraints.push(where('availability', '==', params.availability));
    }

    const q = query(collection(db, 'workers'), ...constraints);
    const snapshot = await getDocs(q);

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Worker));
  }
}
```

## Best Practices

1. **Strategy Composition**: Combine multiple strategies (resilience + caching + logging)
2. **Type Safety**: Use TypeScript generics for type-safe strategy execution
3. **Separation of Concerns**: Keep business logic separate from data access logic
4. **Testability**: Strategies are easily mockable for unit testing
5. **Reusability**: Share strategies across different parts of the application
6. **Performance**: Implement caching and batching for frequently accessed data
7. **Security**: Always validate and sanitize data in strategies
8. **Error Handling**: Classify errors and implement appropriate retry logic
9. **Monitoring**: Log all operations for debugging and performance analysis
10. **Documentation**: Document strategy purpose, parameters, and behavior

## Testing Strategies

```typescript
// Mock Firestore Strategy for Testing
class MockFirestoreStrategy<T> implements FirestoreStrategy<T> {
  constructor(private mockData: T) {}

  async execute(params: any): Promise<T> {
    return this.mockData;
  }
}

// Unit Test Example
describe('CreateJobStrategy', () => {
  it('should create job with search tokens', async () => {
    const strategy = new CreateJobStrategy();
    const jobData = {
      title: 'Senior Electrician Needed',
      description: 'Looking for experienced electrician',
      location: 'New York',
      requiredSkills: ['wiring', 'troubleshooting']
    };

    const jobId = await strategy.execute({ data: jobData });
    expect(jobId).toBeDefined();

    // Verify search tokens were generated
    const job = await getDoc(doc(db, 'jobs', jobId));
    expect(job.data()?.searchTokens).toContain('senior');
    expect(job.data()?.searchTokens).toContain('electrician');
    expect(job.data()?.searchTokens).toContain('wiring');
  });
});
```
