# strategy-pattern-implementation

**Skill Type**: Design Pattern | **Domain**: Backend Development | **Complexity**: Intermediate

## Purpose

Master pluggable strategy pattern for extensible behavior implementation without modifying core service code, enabling flexible runtime configuration and testable business logic.

## Core Capabilities

### 1. Strategy Pattern Fundamentals
- **Interface Definition**: Common contract for all strategy implementations
- **Concrete Strategies**: Specific behavior implementations
- **Context Class**: Core service that delegates to strategies
- **Runtime Selection**: Dynamic strategy switching based on configuration
- **Composition**: Multiple strategies working together in pipeline

### 2. Strategy Pattern Architecture
```typescript
// Strategy pattern layers
Strategy Interface:
  - Define common operations contract
  - Lifecycle hooks (before/after operations)
  - Configuration options
  - Error handling interface

Concrete Strategies:
  - Resilience: Offline persistence, retry logic
  - Search: Full-text search integration
  - Sharding: Data partitioning logic
  - Caching: Result memoization
  - Validation: Business rule enforcement

Context Service:
  - Strategy registration and management
  - Strategy invocation pipeline
  - Result aggregation
  - Error propagation
```

### 3. Lifecycle Hook System
- **beforeRead**: Pre-process queries, add filters, modify constraints
- **afterRead**: Transform results, apply sorting, filter sensitive data
- **beforeWrite**: Validate data, enrich fields, apply business rules
- **afterWrite**: Trigger side effects, update caches, send notifications
- **onError**: Handle failures, log errors, trigger fallbacks

### 4. Strategy Composition Patterns
- **Pipeline**: Sequential strategy execution with data flow
- **Decorator**: Wrap strategies to add additional behavior
- **Chain of Responsibility**: First successful strategy wins
- **Composite**: Combine multiple strategies as single unit

## Implementation Patterns

### Strategy Interface Pattern
```typescript
// Core strategy interface
interface FirestoreStrategy<T = any> {
  // Lifecycle hooks
  beforeRead?(query: Query): Query | Promise<Query>;
  afterRead?(data: T[]): T[] | Promise<T[]>;
  beforeWrite?(data: Partial<T>): Partial<T> | Promise<Partial<T>>;
  afterWrite?(result: T): void | Promise<void>;
  onError?(error: Error, operation: string): void | Promise<void>;

  // Configuration
  configure?(options: StrategyOptions): void;
  getName(): string;
  getPriority(): number;
}

interface StrategyOptions {
  enabled: boolean;
  config: Record<string, any>;
}
```

### Context Service Pattern
```typescript
// Service with strategy management
class StrategyAwareService<T> {
  private strategies: FirestoreStrategy<T>[] = [];
  private strategyMap: Map<string, FirestoreStrategy<T>> = new Map();

  // Strategy registration
  registerStrategy(strategy: FirestoreStrategy<T>): void {
    this.strategies.push(strategy);
    this.strategyMap.set(strategy.getName(), strategy);

    // Sort by priority
    this.strategies.sort((a, b) => b.getPriority() - a.getPriority());

    console.log(`Registered strategy: ${strategy.getName()}`);
  }

  unregisterStrategy(name: string): void {
    const index = this.strategies.findIndex(s => s.getName() === name);
    if (index !== -1) {
      this.strategies.splice(index, 1);
      this.strategyMap.delete(name);
    }
  }

  getStrategy(name: string): FirestoreStrategy<T> | undefined {
    return this.strategyMap.get(name);
  }

  // Strategy execution pipeline
  protected async executeBeforeRead(query: Query): Promise<Query> {
    let modifiedQuery = query;

    for (const strategy of this.strategies) {
      if (strategy.beforeRead) {
        try {
          modifiedQuery = await strategy.beforeRead(modifiedQuery);
        } catch (error) {
          await this.handleStrategyError(strategy, error, 'beforeRead');
        }
      }
    }

    return modifiedQuery;
  }

  protected async executeAfterRead(data: T[]): Promise<T[]> {
    let modifiedData = data;

    for (const strategy of this.strategies) {
      if (strategy.afterRead) {
        try {
          modifiedData = await strategy.afterRead(modifiedData);
        } catch (error) {
          await this.handleStrategyError(strategy, error, 'afterRead');
        }
      }
    }

    return modifiedData;
  }

  protected async executeBeforeWrite(data: Partial<T>): Promise<Partial<T>> {
    let modifiedData = data;

    for (const strategy of this.strategies) {
      if (strategy.beforeWrite) {
        try {
          modifiedData = await strategy.beforeWrite(modifiedData);
        } catch (error) {
          await this.handleStrategyError(strategy, error, 'beforeWrite');
          throw error; // Don't continue if write validation fails
        }
      }
    }

    return modifiedData;
  }

  protected async executeAfterWrite(result: T): Promise<void> {
    for (const strategy of this.strategies) {
      if (strategy.afterWrite) {
        try {
          await strategy.afterWrite(result);
        } catch (error) {
          await this.handleStrategyError(strategy, error, 'afterWrite');
          // Continue even if after-write fails
        }
      }
    }
  }

  private async handleStrategyError(
    strategy: FirestoreStrategy<T>,
    error: Error,
    operation: string
  ): Promise<void> {
    console.error(
      `Strategy ${strategy.getName()} failed during ${operation}:`,
      error
    );

    if (strategy.onError) {
      await strategy.onError(error, operation);
    }
  }
}
```

### Concrete Strategy Implementation Pattern
```typescript
// Example: Offline Resilience Strategy
class OfflineResilienceStrategy implements FirestoreStrategy {
  private offlineQueue: Map<string, QueuedOperation> = new Map();
  private isOnline: boolean = navigator.onLine;
  private syncInProgress: boolean = false;

  constructor() {
    this.setupNetworkListeners();
    this.loadQueueFromStorage();
  }

  getName(): string {
    return 'offline-resilience';
  }

  getPriority(): number {
    return 100; // High priority
  }

  async beforeWrite(data: any): Promise<any> {
    if (!this.isOnline) {
      // Queue operation for later
      const operationId = this.generateOperationId();
      this.offlineQueue.set(operationId, {
        id: operationId,
        type: 'write',
        data,
        timestamp: Date.now(),
        attempts: 0
      });

      this.persistQueue();

      throw new OfflineError('Operation queued for sync when online', {
        operationId,
        queueSize: this.offlineQueue.size
      });
    }

    return data;
  }

  async afterWrite(result: any): Promise<void> {
    // Trigger queue sync if we just came online
    if (this.isOnline && this.offlineQueue.size > 0 && !this.syncInProgress) {
      this.syncQueue();
    }
  }

  async onError(error: Error, operation: string): Promise<void> {
    console.error(`Resilience strategy handling error in ${operation}:`, error);

    // Analytics tracking
    if (error instanceof OfflineError) {
      // Track offline operation queued
    }
  }

  private setupNetworkListeners(): void {
    window.addEventListener('online', () => {
      console.log('Network back online, syncing queue');
      this.isOnline = true;
      this.syncQueue();
    });

    window.addEventListener('offline', () => {
      console.log('Network offline, queueing operations');
      this.isOnline = false;
    });
  }

  private async syncQueue(): Promise<void> {
    if (this.syncInProgress || this.offlineQueue.size === 0) return;

    this.syncInProgress = true;

    try {
      for (const [id, operation] of this.offlineQueue) {
        try {
          await this.retryOperation(operation);
          this.offlineQueue.delete(id);
        } catch (error) {
          console.error(`Failed to sync operation ${id}:`, error);
          operation.attempts++;

          // Give up after 5 attempts
          if (operation.attempts >= 5) {
            console.error(`Dropping operation ${id} after 5 failed attempts`);
            this.offlineQueue.delete(id);
          }
        }
      }

      this.persistQueue();
    } finally {
      this.syncInProgress = false;
    }
  }

  private async retryOperation(operation: QueuedOperation): Promise<void> {
    // Implementation would perform actual Firestore operation
    // This would be injected or use a callback
    console.log(`Retrying operation: ${operation.id}`);
  }

  private loadQueueFromStorage(): void {
    const stored = localStorage.getItem('offline_queue');
    if (stored) {
      try {
        const data = JSON.parse(stored);
        this.offlineQueue = new Map(Object.entries(data));
      } catch (error) {
        console.error('Failed to load offline queue:', error);
      }
    }
  }

  private persistQueue(): void {
    const data = Object.fromEntries(this.offlineQueue);
    localStorage.setItem('offline_queue', JSON.stringify(data));
  }

  private generateOperationId(): string {
    return `op_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

class OfflineError extends Error {
  constructor(message: string, public metadata: any) {
    super(message);
    this.name = 'OfflineError';
  }
}

interface QueuedOperation {
  id: string;
  type: 'write' | 'update' | 'delete';
  data: any;
  timestamp: number;
  attempts: number;
}
```

### Strategy Composition Pattern
```typescript
// Example: Composite strategy
class CompositeStrategy implements FirestoreStrategy {
  private strategies: FirestoreStrategy[] = [];

  constructor(strategies: FirestoreStrategy[]) {
    this.strategies = strategies;
  }

  getName(): string {
    return `composite-${this.strategies.map(s => s.getName()).join('-')}`;
  }

  getPriority(): number {
    return Math.max(...this.strategies.map(s => s.getPriority()));
  }

  async beforeRead(query: Query): Promise<Query> {
    let modifiedQuery = query;

    for (const strategy of this.strategies) {
      if (strategy.beforeRead) {
        modifiedQuery = await strategy.beforeRead(modifiedQuery);
      }
    }

    return modifiedQuery;
  }

  async afterRead(data: any[]): Promise<any[]> {
    let modifiedData = data;

    for (const strategy of this.strategies) {
      if (strategy.afterRead) {
        modifiedData = await strategy.afterRead(modifiedData);
      }
    }

    return modifiedData;
  }
}
```

### Strategy Factory Pattern
```typescript
// Factory for strategy creation
class StrategyFactory {
  private static registry: Map<string, () => FirestoreStrategy> = new Map();

  static register(name: string, factory: () => FirestoreStrategy): void {
    this.registry.set(name, factory);
  }

  static create(name: string, options?: StrategyOptions): FirestoreStrategy {
    const factory = this.registry.get(name);

    if (!factory) {
      throw new Error(`Strategy '${name}' not registered`);
    }

    const strategy = factory();

    if (options && strategy.configure) {
      strategy.configure(options);
    }

    return strategy;
  }

  static createMultiple(
    configs: Array<{ name: string; options?: StrategyOptions }>
  ): FirestoreStrategy[] {
    return configs.map(config => this.create(config.name, config.options));
  }
}

// Register strategies
StrategyFactory.register('offline-resilience', () => new OfflineResilienceStrategy());
StrategyFactory.register('cache', () => new CacheStrategy());
StrategyFactory.register('validation', () => new ValidationStrategy());

// Use factory
const strategies = StrategyFactory.createMultiple([
  { name: 'offline-resilience' },
  { name: 'cache', options: { enabled: true, config: { ttl: 300 } } },
  { name: 'validation' }
]);
```

## Best Practices

### Strategy Design
- **Single Responsibility**: Each strategy handles one concern
- **Interface Compliance**: All strategies implement common interface
- **Priority System**: Use priorities to control execution order
- **Error Isolation**: Strategy failures shouldn't crash the system
- **Configuration**: Support runtime configuration for flexibility

### Performance Optimization
- **Lazy Loading**: Load strategies only when needed
- **Parallel Execution**: Run independent strategies concurrently when possible
- **Caching**: Cache strategy results when appropriate
- **Early Exit**: Skip disabled or irrelevant strategies

### Testing Strategy
- **Unit Tests**: Test each strategy in isolation
- **Integration Tests**: Test strategy combinations
- **Mock Strategies**: Use test doubles for dependencies
- **Performance Tests**: Measure strategy overhead

## Integration Points

### Service Integration
```typescript
// Example: UnifiedFirestoreService with strategies
class UnifiedFirestoreService<T> extends StrategyAwareService<T> {
  async getAll(constraints?: QueryConstraint[]): Promise<T[]> {
    let query = collection(this.db, this.collectionPath);

    if (constraints) {
      query = query(this.db, this.collectionPath, ...constraints);
    }

    // Apply beforeRead strategies
    query = await this.executeBeforeRead(query);

    const snapshot = await getDocs(query);
    let data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as T));

    // Apply afterRead strategies
    data = await this.executeAfterRead(data);

    return data;
  }
}
```

## Quality Standards

- **Type Safety**: Full TypeScript types for strategies and interfaces
- **Documentation**: Document strategy purpose, configuration, and side effects
- **Error Handling**: Graceful degradation when strategies fail
- **Logging**: Log strategy execution for debugging
- **Metrics**: Track strategy performance and errors

## Common Patterns

### Conditional Strategy Execution
```typescript
class ConditionalStrategy implements FirestoreStrategy {
  constructor(
    private condition: () => boolean,
    private strategy: FirestoreStrategy
  ) {}

  async beforeRead(query: Query): Promise<Query> {
    if (this.condition() && this.strategy.beforeRead) {
      return this.strategy.beforeRead(query);
    }
    return query;
  }

  getName(): string {
    return `conditional-${this.strategy.getName()}`;
  }

  getPriority(): number {
    return this.strategy.getPriority();
  }
}
```

### Strategy Chaining
```typescript
class StrategyChain {
  private strategies: FirestoreStrategy[] = [];

  add(strategy: FirestoreStrategy): this {
    this.strategies.push(strategy);
    return this;
  }

  async execute<T>(operation: string, input: T): Promise<T> {
    let result = input;

    for (const strategy of this.strategies) {
      const handler = strategy[operation];
      if (handler) {
        result = await handler.call(strategy, result);
      }
    }

    return result;
  }
}
```

## Related Skills
- `firestore-strategy-pattern` - Specific Firestore strategy implementations
- `query-optimization` - Performance-focused strategies
- `serverless-architecture` - Cloud Functions strategy patterns
