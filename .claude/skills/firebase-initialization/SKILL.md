# firebase-initialization

**Skill Type**: Technical Pattern | **Domain**: Backend Development | **Complexity**: Intermediate

## Purpose

Master Firebase app startup sequence and configuration management for reliable multi-environment initialization with proper error handling and service coordination.

## Core Capabilities

### 1. Initialization Sequence Management
- **Bootstrap Order**: Environment detection → Config loading → App initialization → Service setup
- **Dependency Resolution**: Ensure services initialize in correct dependency order
- **Error Recovery**: Graceful handling of initialization failures
- **Health Validation**: Verify successful initialization before app start
- **Performance Tracking**: Monitor initialization time and bottlenecks

### 2. Configuration Management
```typescript
// Configuration layers
Environment Detection:
  - Hostname-based detection (localhost, staging, production)
  - Environment variable overrides
  - Build-time configuration injection
  - Runtime configuration switching

Config Loading:
  - Environment-specific .env files
  - Config validation and schema checking
  - Secret management (API keys, tokens)
  - Feature flag integration
  - Default fallback values

Config Structure:
  - Core: apiKey, authDomain, projectId, storageBucket
  - Optional: messagingSenderId, appId, measurementId
  - Service-specific: Firestore settings, Storage settings
  - Custom: App-specific configuration
```

### 3. Multi-Environment Support
- **Development**: Local Firebase emulators, debug logging, relaxed security
- **Staging**: Production-like environment, integration testing, limited data
- **Production**: Full security, performance monitoring, real user data
- **Environment Switching**: Seamless transition between environments

### 4. Service Initialization Patterns
- **Lazy Initialization**: Initialize services on first access for faster startup
- **Eager Initialization**: Pre-initialize critical services during bootstrap
- **Conditional Initialization**: Initialize services based on feature flags
- **Parallel Initialization**: Initialize independent services concurrently
- **Retry Logic**: Retry failed initializations with exponential backoff

## Implementation Patterns

### Bootstrap Sequence Pattern
```typescript
// Main initialization orchestrator
class FirebaseBootstrap {
  private static initializationPromise: Promise<FirebaseApp> | null = null;
  private static isInitialized: boolean = false;

  static async initialize(): Promise<FirebaseApp> {
    // Prevent duplicate initialization
    if (this.isInitialized) {
      return getApp();
    }

    // Prevent concurrent initialization
    if (this.initializationPromise) {
      return this.initializationPromise;
    }

    this.initializationPromise = this.performInitialization();

    try {
      const app = await this.initializationPromise;
      this.isInitialized = true;
      return app;
    } catch (error) {
      this.initializationPromise = null;
      throw error;
    }
  }

  private static async performInitialization(): Promise<FirebaseApp> {
    console.log('🔥 Starting Firebase initialization...');
    const startTime = performance.now();

    try {
      // Step 1: Detect environment
      const environment = this.detectEnvironment();
      console.log(`📍 Environment: ${environment}`);

      // Step 2: Load configuration
      const config = await this.loadConfiguration(environment);
      console.log('⚙️  Configuration loaded');

      // Step 3: Validate configuration
      this.validateConfiguration(config);
      console.log('✅ Configuration validated');

      // Step 4: Initialize Firebase App
      const app = initializeApp(config, environment);
      console.log('🎯 Firebase app initialized');

      // Step 5: Setup core services
      await this.setupCoreServices(app);
      console.log('🔧 Core services ready');

      // Step 6: Health check
      await this.performHealthCheck(app);
      console.log('💚 Health check passed');

      const duration = Math.round(performance.now() - startTime);
      console.log(`🚀 Firebase initialized successfully in ${duration}ms`);

      return app;
    } catch (error) {
      console.error('❌ Firebase initialization failed:', error);
      throw new InitializationError('Firebase initialization failed', error);
    }
  }

  private static detectEnvironment(): Environment {
    // Check explicit environment variable
    const envVar = import.meta.env.VITE_ENVIRONMENT;
    if (envVar) return envVar as Environment;

    // Hostname-based detection
    const hostname = window.location.hostname;

    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'development';
    } else if (hostname.includes('staging') || hostname.includes('preview')) {
      return 'staging';
    } else {
      return 'production';
    }
  }

  private static async loadConfiguration(env: Environment): Promise<FirebaseConfig> {
    const configLoaders = {
      development: () => this.loadDevConfig(),
      staging: () => this.loadStagingConfig(),
      production: () => this.loadProdConfig()
    };

    const config = await configLoaders[env]();

    // Apply environment-specific overrides
    return {
      ...config,
      ...this.getEnvironmentOverrides(env)
    };
  }

  private static loadDevConfig(): FirebaseConfig {
    return {
      apiKey: import.meta.env.VITE_FIREBASE_API_KEY_DEV,
      authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN_DEV,
      projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID_DEV,
      storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET_DEV,
      messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID_DEV,
      appId: import.meta.env.VITE_FIREBASE_APP_ID_DEV,
      measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID_DEV
    };
  }

  private static getEnvironmentOverrides(env: Environment): Partial<FirebaseConfig> {
    const overrides: Record<Environment, Partial<FirebaseConfig>> = {
      development: {
        // Use emulators if available
        // This would be applied to individual services
      },
      staging: {
        // Staging-specific overrides
      },
      production: {
        // Production optimizations
      }
    };

    return overrides[env] || {};
  }

  private static validateConfiguration(config: FirebaseConfig): void {
    const requiredFields = [
      'apiKey',
      'authDomain',
      'projectId',
      'storageBucket'
    ];

    const missingFields = requiredFields.filter(field => !config[field]);

    if (missingFields.length > 0) {
      throw new ConfigurationError(
        `Missing required Firebase configuration: ${missingFields.join(', ')}`
      );
    }

    // Validate format
    if (config.apiKey && !this.isValidApiKey(config.apiKey)) {
      throw new ConfigurationError('Invalid Firebase API key format');
    }

    if (config.projectId && !this.isValidProjectId(config.projectId)) {
      throw new ConfigurationError('Invalid Firebase project ID format');
    }
  }

  private static isValidApiKey(apiKey: string): boolean {
    // Basic validation - should be alphanumeric with hyphens
    return /^[A-Za-z0-9-_]+$/.test(apiKey);
  }

  private static isValidProjectId(projectId: string): boolean {
    // Project ID should be lowercase with hyphens
    return /^[a-z0-9-]+$/.test(projectId);
  }

  private static async setupCoreServices(app: FirebaseApp): Promise<void> {
    // Initialize core services in dependency order
    const services = [];

    // Auth (no dependencies)
    services.push(
      this.initializeAuth(app).catch(err => {
        console.warn('Auth initialization failed:', err);
      })
    );

    // Firestore (no dependencies)
    services.push(
      this.initializeFirestore(app).catch(err => {
        console.warn('Firestore initialization failed:', err);
      })
    );

    // Storage (no dependencies)
    services.push(
      this.initializeStorage(app).catch(err => {
        console.warn('Storage initialization failed:', err);
      })
    );

    // Analytics (browser only)
    if (typeof window !== 'undefined') {
      services.push(
        this.initializeAnalytics(app).catch(err => {
          console.warn('Analytics initialization failed:', err);
        })
      );
    }

    // Wait for all services (failures are caught individually)
    await Promise.all(services);
  }

  private static async initializeAuth(app: FirebaseApp): Promise<void> {
    const auth = getAuth(app);

    // Configure auth settings
    auth.languageCode = 'en';

    // Setup persistence
    await setPersistence(auth, browserLocalPersistence);

    console.log('  ✓ Auth configured');
  }

  private static async initializeFirestore(app: FirebaseApp): Promise<void> {
    const firestore = getFirestore(app);

    // Enable offline persistence
    try {
      await enableIndexedDbPersistence(firestore);
      console.log('  ✓ Firestore persistence enabled');
    } catch (err: any) {
      if (err.code === 'failed-precondition') {
        console.warn('  ⚠ Firestore persistence: multiple tabs open');
      } else if (err.code === 'unimplemented') {
        console.warn('  ⚠ Firestore persistence: not supported');
      }
    }

    console.log('  ✓ Firestore configured');
  }

  private static async initializeStorage(app: FirebaseApp): Promise<void> {
    const storage = getStorage(app);
    console.log('  ✓ Storage configured');
  }

  private static async initializeAnalytics(app: FirebaseApp): Promise<void> {
    const analytics = getAnalytics(app);
    setAnalyticsCollectionEnabled(analytics, true);
    console.log('  ✓ Analytics configured');
  }

  private static async performHealthCheck(app: FirebaseApp): Promise<void> {
    const checks = [];

    // Check if app is accessible
    try {
      const appCheck = getApp(app.name);
      checks.push(!!appCheck);
    } catch {
      checks.push(false);
    }

    // Verify auth is accessible
    try {
      const auth = getAuth(app);
      checks.push(!!auth);
    } catch {
      checks.push(false);
    }

    // Verify Firestore is accessible
    try {
      const firestore = getFirestore(app);
      checks.push(!!firestore);
    } catch {
      checks.push(false);
    }

    const healthScore = checks.filter(Boolean).length / checks.length;

    if (healthScore < 0.5) {
      throw new HealthCheckError(
        `Health check failed: ${Math.round(healthScore * 100)}% services healthy`
      );
    }

    if (healthScore < 1.0) {
      console.warn(
        `⚠️  Some services unavailable: ${Math.round(healthScore * 100)}% healthy`
      );
    }
  }

  static async reset(): Promise<void> {
    try {
      const app = getApp();
      await deleteApp(app);
      this.isInitialized = false;
      this.initializationPromise = null;
      console.log('Firebase reset successfully');
    } catch (error) {
      console.error('Failed to reset Firebase:', error);
    }
  }
}

class InitializationError extends Error {
  constructor(message: string, public cause?: any) {
    super(message);
    this.name = 'InitializationError';
  }
}

class ConfigurationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ConfigurationError';
  }
}

class HealthCheckError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'HealthCheckError';
  }
}

type Environment = 'development' | 'staging' | 'production';
```

### Emulator Support Pattern
```typescript
// Development emulator configuration
class FirebaseEmulatorSetup {
  static setupEmulators(app: FirebaseApp): void {
    if (import.meta.env.VITE_USE_EMULATORS !== 'true') {
      return;
    }

    console.log('🔧 Connecting to Firebase emulators...');

    try {
      // Auth emulator
      const auth = getAuth(app);
      connectAuthEmulator(auth, 'http://localhost:9099', {
        disableWarnings: true
      });
      console.log('  ✓ Auth emulator connected');

      // Firestore emulator
      const firestore = getFirestore(app);
      connectFirestoreEmulator(firestore, 'localhost', 8080);
      console.log('  ✓ Firestore emulator connected');

      // Storage emulator
      const storage = getStorage(app);
      connectStorageEmulator(storage, 'localhost', 9199);
      console.log('  ✓ Storage emulator connected');

      // Functions emulator
      const functions = getFunctions(app);
      connectFunctionsEmulator(functions, 'localhost', 5001);
      console.log('  ✓ Functions emulator connected');

    } catch (error) {
      console.error('Failed to connect to emulators:', error);
      throw error;
    }
  }
}
```

## Best Practices

### Initialization Strategy
- **Single Initialization**: Use singleton pattern to prevent duplicate initialization
- **Promise Caching**: Cache initialization promise to handle concurrent calls
- **Error Recovery**: Implement retry logic for transient failures
- **Performance Monitoring**: Track initialization time and optimize bottlenecks

### Configuration Management
- **Environment Variables**: Use .env files for configuration
- **Validation**: Validate configuration at startup
- **Type Safety**: Use TypeScript interfaces for config structure
- **Secrets**: Never commit secrets to version control

### Error Handling
- **Specific Errors**: Create custom error types for different failure modes
- **Graceful Degradation**: Allow partial initialization when possible
- **User Feedback**: Provide clear error messages for configuration issues
- **Logging**: Log initialization steps for debugging

## Integration Points

### App Bootstrap Integration
```typescript
// React example
function App() {
  const [firebaseReady, setFirebaseReady] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    FirebaseBootstrap.initialize()
      .then(() => setFirebaseReady(true))
      .catch(err => setError(err));
  }, []);

  if (error) {
    return <ErrorScreen error={error} />;
  }

  if (!firebaseReady) {
    return <LoadingScreen />;
  }

  return <MainApp />;
}
```

## Quality Standards

- **Initialization Time**: Complete initialization in <2s on fast network
- **Error Recovery**: Automatic retry for network failures
- **Health Validation**: Verify critical services before app start
- **Logging**: Comprehensive logging for debugging
- **Testing**: Unit tests for configuration validation, integration tests for initialization

## Related Skills
- `firebase-integration-architecture` - Multi-service setup patterns
- `performance-monitoring-firebase` - Performance tracking integration
- `serverless-architecture` - Cloud Functions initialization
