# performance-monitoring-firebase

**Skill Type**: Technical Pattern | **Domain**: Backend Development | **Complexity**: Intermediate

## Purpose

Master Firebase Performance Monitoring integration for tracking app performance, identifying bottlenecks, and optimizing user experience with real-time metrics and traces.

## Core Capabilities

### 1. Performance Monitoring Setup
- **Automatic Tracking**: Page loads, network requests, custom traces
- **Custom Metrics**: Business-specific performance indicators
- **Real User Monitoring (RUM)**: Actual user experience data
- **Trace Management**: Custom traces for critical operations
- **Alert Configuration**: Performance degradation notifications

### 2. Metrics Collection
```typescript
Performance Metrics:
  - Page load times (FCP, LCP, TTI)
  - Network request latency
  - Firestore query performance
  - Storage operation duration
  - Custom business metrics

Core Web Vitals:
  - Largest Contentful Paint (LCP): <2.5s
  - First Input Delay (FID): <100ms
  - Cumulative Layout Shift (CLS): <0.1
  - First Contentful Paint (FCP): <1.8s
  - Time to Interactive (TTI): <3.8s

Custom Traces:
  - Authentication flow timing
  - Data fetch operations
  - Complex calculations
  - Third-party API calls
```

### 3. Implementation Patterns

```typescript
// Performance monitoring setup
class FirebasePerformanceMonitor {
  private performance: FirebasePerformance;
  private traces: Map<string, Trace> = new Map();

  constructor(app: FirebaseApp) {
    this.performance = getPerformance(app);
    this.setupAutomaticTracing();
  }

  private setupAutomaticTracing(): void {
    // Performance monitoring is automatic for page loads
    // and network requests once initialized
    console.log('Performance monitoring active');
  }

  // Custom trace for operations
  startTrace(traceName: string): Trace {
    const trace = trace(this.performance, traceName);
    trace.start();
    this.traces.set(traceName, trace);
    return trace;
  }

  stopTrace(traceName: string): void {
    const existingTrace = this.traces.get(traceName);
    if (existingTrace) {
      existingTrace.stop();
      this.traces.delete(traceName);
    }
  }

  // Measure async operation
  async measureOperation<T>(
    operationName: string,
    operation: () => Promise<T>
  ): Promise<T> {
    const trace = this.startTrace(operationName);

    try {
      const result = await operation();
      trace.putAttribute('status', 'success');
      return result;
    } catch (error) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error', error.message);
      throw error;
    } finally {
      trace.stop();
    }
  }

  // Add custom metric to trace
  recordMetric(traceName: string, metricName: string, value: number): void {
    const trace = this.traces.get(traceName);
    if (trace) {
      trace.putMetric(metricName, value);
    }
  }

  // Record custom attributes
  recordAttribute(traceName: string, attribute: string, value: string): void {
    const trace = this.traces.get(traceName);
    if (trace) {
      trace.putAttribute(attribute, value);
    }
  }
}

// Example usage
const perfMonitor = new FirebasePerformanceMonitor(firebaseApp);

// Measure Firestore query
async function fetchJobs(): Promise<Job[]> {
  return perfMonitor.measureOperation('fetch_jobs', async () => {
    const jobsRef = collection(firestore, 'jobs');
    const snapshot = await getDocs(jobsRef);
    return snapshot.docs.map(doc => doc.data() as Job);
  });
}

// Manual trace with custom metrics
async function processJobApplication(jobId: string): Promise<void> {
  const trace = perfMonitor.startTrace('process_job_application');
  trace.putAttribute('jobId', jobId);

  const startTime = performance.now();

  try {
    // Processing logic
    await performProcessing(jobId);

    const duration = performance.now() - startTime;
    trace.putMetric('processing_duration_ms', duration);
    trace.putAttribute('status', 'success');
  } catch (error) {
    trace.putAttribute('status', 'error');
    throw error;
  } finally {
    perfMonitor.stopTrace('process_job_application');
  }
}
```

### 4. Firestore Query Monitoring

```typescript
// Monitored Firestore service
class MonitoredFirestoreService<T> {
  constructor(
    private collection: string,
    private firestore: Firestore,
    private perfMonitor: FirebasePerformanceMonitor
  ) {}

  async getAll(): Promise<T[]> {
    return this.perfMonitor.measureOperation(
      `firestore_getAll_${this.collection}`,
      async () => {
        const snapshot = await getDocs(
          collection(this.firestore, this.collection)
        );
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as T));
      }
    );
  }

  async getById(id: string): Promise<T | null> {
    return this.perfMonitor.measureOperation(
      `firestore_getById_${this.collection}`,
      async () => {
        const docRef = doc(this.firestore, this.collection, id);
        const docSnap = await getDoc(docRef);
        return docSnap.exists() ? ({ id: docSnap.id, ...docSnap.data() } as T) : null;
      }
    );
  }

  async create(data: Omit<T, 'id'>): Promise<string> {
    return this.perfMonitor.measureOperation(
      `firestore_create_${this.collection}`,
      async () => {
        const docRef = await addDoc(
          collection(this.firestore, this.collection),
          data
        );
        return docRef.id;
      }
    );
  }
}
```

### 5. Network Request Monitoring

```typescript
// Monitored HTTP client
class MonitoredHttpClient {
  constructor(private perfMonitor: FirebasePerformanceMonitor) {}

  async get<T>(url: string): Promise<T> {
    return this.perfMonitor.measureOperation(
      `http_get_${this.sanitizeUrl(url)}`,
      async () => {
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
      }
    );
  }

  async post<T>(url: string, data: any): Promise<T> {
    return this.perfMonitor.measureOperation(
      `http_post_${this.sanitizeUrl(url)}`,
      async () => {
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
      }
    );
  }

  private sanitizeUrl(url: string): string {
    // Remove query params and IDs for cleaner trace names
    return url.split('?')[0].replace(/\/[a-f0-9-]+/g, '/:id');
  }
}
```

## Best Practices

### Trace Management
- **Meaningful Names**: Use descriptive trace names (e.g., `fetch_nearby_jobs`)
- **Attribute Context**: Add relevant attributes (userId, environment, version)
- **Metric Precision**: Record precise metrics (ms, bytes, count)
- **Error Tracking**: Capture error states and types
- **Limit Traces**: Avoid creating too many unique trace names (max 500)

### Performance Optimization
- **Lazy Initialization**: Start performance monitoring after critical path
- **Sampling**: Use sampling for high-frequency operations
- **Batch Traces**: Group related operations when possible
- **Memory Management**: Clean up completed traces
- **Network Efficiency**: Minimize performance data payload

## Quality Standards

- **Trace Duration**: Complete traces within operation lifetime
- **Attribute Limits**: Max 5 custom attributes per trace
- **Metric Limits**: Max 32 custom metrics per trace
- **Name Length**: Trace names <100 characters
- **Data Retention**: Performance data retained for 90 days

## Integration Points

### Analytics Integration
```typescript
// Combined performance and analytics tracking
function trackUserAction(action: string, metadata: Record<string, any>): void {
  // Performance trace
  const trace = perfMonitor.startTrace(`user_action_${action}`);
  Object.entries(metadata).forEach(([key, value]) => {
    trace.putAttribute(key, String(value));
  });

  // Analytics event
  logEvent(analytics, action, metadata);

  // Stop trace after action completes
  setTimeout(() => trace.stop(), 0);
}
```

## Related Skills
- `firebase-integration-architecture` - Multi-service coordination
- `query-optimization` - Database performance optimization
- `serverless-architecture` - Cloud Functions performance
