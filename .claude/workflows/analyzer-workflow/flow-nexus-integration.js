/**
 * Enhanced Flow Nexus Integration for Journeyman Jobs Universal Code Correction Workflow
 *
 * This file provides bridge between universal code correction workflow
 * and Flow Nexus MCP system with specialist agents tailored specifically
 * to the Journeyman Jobs application architecture.
 */

const UniversalCodeCorrectionWorkflow = {
  name: 'journeyman-jobs-code-correction',
  version: '2.0.0',
  description: 'Specialist multi-agent workflow for Journeyman Jobs Flutter application code correction and validation',

  // Initialize Flow Nexus connection
  async initialize() {
    console.log('🔧 Initializing Journeyman Jobs Code Correction Workflow with Flow Nexus...');

    try {
      // Initialize swarm with hierarchical topology
      const swarmConfig = {
        topology: 'hierarchical',
        maxAgents: 8,
        strategy: 'adaptive'
      };

      const swarm = await this.initializeSwarm(swarmConfig);
      console.log('✅ Swarm initialized successfully');

      // Spawn specialist agents for Journeyman Jobs
      await this.spawnJourneymanSpecialistAgents(swarm);

      // Spawn validation agents
      await this.spawnValidationAgents(swarm);

      // Spawn coordinator agent
      await this.spawnCoordinatorAgent(swarm);

      console.log('🚀 Journeyman Jobs Code Correction Workflow ready for operation');
      return swarm;

    } catch (error) {
      console.error('❌ Failed to initialize workflow:', error);
      throw error;
    }
  },

  // Initialize swarm with proper configuration
  async initializeSwarm(config) {
    return await mcp__claude_flow_alpha__swarm_init({
      topology: config.topology,
      maxAgents: config.maxAgents,
      strategy: config.strategy
    });
  },

  // Spawn specialist agents for Journeyman Jobs application architecture
  async spawnJourneymanSpecialistAgents(swarm) {
    const specialists = [
      {
        name: 'flutter-firebase-specialist',
        type: 'specialist',
        capabilities: [
          'flutter-3.x-mastery',
          'dart-null-safety',
          'riverpod-state-management',
          'firebase-firestore-integration',
          'firebase-authentication',
          'firebase-storage',
          'widget-architecture',
          'electrical-theme-implementation',
          'mobile-performance-optimization',
          'offline-caching-strategies'
        ],
        systemPrompt: this.getFlutterFirebaseSpecialistPrompt()
      },
      {
        name: 'riverpod-state-specialist',
        type: 'specialist',
        capabilities: [
          'riverpod-3.x-patterns',
          'async-state-management',
          'provider-compatibility',
          'dependency-injection',
          'concurrent-operations',
          'performance-optimization',
          'error-boundary-patterns',
          'testing-with-mocking'
        ],
        systemPrompt: this.getRiverpodSpecialistPrompt()
      },
      {
        name: 'go-router-specialist',
        type: 'specialist',
        capabilities: [
          'go-router-16.x-mastery',
          'route-generation',
          'auth-guards',
          'nested-routing',
          'deep-linking',
          'navigation-patterns',
          'type-safety',
          'riverpod-integration'
        ],
        systemPrompt: this.getGoRouterSpecialistPrompt()
      },
      {
        name: 'electrical-ui-specialist',
        type: 'specialist',
        capabilities: [
          'electrical-theme-system',
          'jj-component-patterns',
          'circuit-pattern-painters',
          'lightning-animations',
          'navy-copper-design',
          'accessibility-compliance',
          'responsive-design',
          'custom-widget-creation'
        ],
        systemPrompt: this.getElectricalUISpecialistPrompt()
      },
      {
        name: 'job-data-specialist',
        type: 'specialist',
        capabilities: [
          'job-model-architecture',
          'firestore-schema-optimization',
          'data-validation-patterns',
          'job-matching-algorithms',
          'classification-filters',
          'location-based-search',
          'offline-data-persistence',
          'performance-optimization'
        ],
        systemPrompt: this.getJobDataSpecialistPrompt()
      },
      {
        name: 'weather-storm-specialist',
        type: 'specialist',
        capabilities: [
          'noaa-api-integration',
          'weather-radar-processing',
          'hurricane-tracking',
          'storm-safety-protocols',
          'location-based-alerts',
          'emergency-procedures',
          'geolocator-integration',
          'offline-weather-caching'
        ],
        systemPrompt: this.getWeatherStormSpecialistPrompt()
      },
      {
        name: 'performance-optimization-specialist',
        type: 'specialist',
        capabilities: [
          'virtual-scrolling-implementation',
          'memory-management',
          'large-dataset-optimization',
          'ui-performance-profiling',
          'concurrent-task-management',
          'firebase-query-optimization',
          'lazy-loading-patterns',
          'mobile-performance-tuning'
        ],
        systemPrompt: this.getPerformanceOptimizationSpecialistPrompt()
      }
    ];

    const spawnPromises = specialists.map(spec =>
      mcp__claude_flow_alpha__agent_spawn({
        type: 'specialist',
        name: spec.name,
        capabilities: spec.capabilities,
        swarmId: swarm.id
      })
    );

    await Promise.all(spawnPromises);
    console.log(`✅ Spawned ${specialists.length} Journeyman Jobs specialist agents`);
  },

  // Spawn validation agents
  async spawnValidationAgents(swarm) {
    const validators = [
      {
        name: 'journeyman-code-reviewer-alpha',
        type: 'code-analyzer',
        capabilities: [
          'flutter-code-analysis',
          'riverpod-state-validation',
          'firebase-integration-review',
          'electrical-theme-compliance',
          'mobile-performance-assessment',
          'accessibility-validation',
          'security-scanning',
          'widget-architecture-review'
        ],
        systemPrompt: this.getJourneymanCodeReviewerAlphaPrompt()
      },
      {
        name: 'journeyman-code-reviewer-beta',
        type: 'perf-analyzer',
        capabilities: [
          'flutter-widget-testing',
          'integration-testing',
          'regression-testing',
          'compatibility-testing',
          'user-experience-assessment',
          'performance-benchmarking',
          'electrical-component-validation'
        ],
        systemPrompt: this.getJourneymanCodeReviewerBetaPrompt()
      }
    ];

    const spawnPromises = validators.map(validator =>
      mcp__claude_flow_alpha__agent_spawn({
        type: validator.type,
        name: validator.name,
        capabilities: validator.capabilities,
        swarmId: swarm.id
      })
    );

    await Promise.all(spawnPromises);
    console.log('✅ Spawned Journeyman Jobs dual validation agents');
  },

  // Spawn coordinator agent
  async spawnCoordinatorAgent(swarm) {
    await mcp__claude_flow_alpha__agent_spawn({
      type: 'task-orchestrator',
      name: 'journeyman-workflow-coordinator',
      capabilities: [
        'journeyman-feature-orchestration',
        'flutter-riverpod-integration',
        'firebase-workflow-management',
        'electrical-theme-coordination',
        'mobile-performance-optimization',
        'quality-gate-management',
        'agent-task-distribution',
        'progress-tracking'
      ],
      swarmId: swarm.id
    });

    console.log('✅ Spawned Journeyman Jobs workflow coordinator agent');
  },

  // Execute Journeyman Jobs code correction workflow
  async executeCodeCorrection(options = {}) {
    console.log('🔧 Starting Journeyman Jobs Code Correction Workflow...');

    const workflowRequest = {
      description: options.description || 'Journeyman Jobs Flutter application code correction and validation',
      targetFiles: options.targetFiles || null,
      languageFilter: options.languageFilter || 'flutter-dart',
      severityFilter: options.severityFilter || 'critical,high',
      autoFix: options.autoFix || false,
      electricalThemeCompliance: options.electricalThemeCompliance || true,
      performanceOptimization: options.performanceOptimization || true
    };

    try {
      // Create and execute workflow
      const workflow = await mcp__claude_flow_alpha__workflow_create({
        name: 'Journeyman Jobs Code Correction',
        steps: [
          { id: 'analysis', name: 'Journeyman Codebase Analysis', agent: 'journeyman-workflow-coordinator' },
          { id: 'correction', name: 'Specialist Code Correction', agent: 'specialists' },
          { id: 'validation-alpha', name: 'Flutter & Firebase Validation', agent: 'journeyman-code-reviewer-alpha' },
          { id: 'validation-beta', name: 'Integration & Performance Testing', agent: 'journeyman-code-reviewer-beta' },
          { id: 'integration', name: 'Electrical Theme Integration & Testing', agent: 'journeyman-workflow-coordinator' }
        ],
        triggers: ['manual', 'automated', 'git-commit', 'build-failure']
      });

      const result = await mcp__claude_flow_alpha__workflow_execute({
        workflowId: workflow.id,
        params: {
          request: workflowRequest,
          validationSystem: 'dual-approval',
          qualityGates: {
            flutterBestPractices: 'required',
            electricalThemeCompliance: 'required',
            firebaseIntegration: 'required',
            performanceStandards: 'required',
            accessibilityCompliance: 'required',
            mobileOptimization: 'required'
          }
        }
      });

      console.log('✅ Journeyman Jobs workflow execution completed');
      return result;

    } catch (error) {
      console.error('❌ Journeyman Jobs workflow execution failed:', error);
      throw error;
    }
  },

  // Scan Journeyman Jobs project directory for issues
  async scanProject(options = {}) {
    console.log('🔍 Scanning Journeyman Jobs project for code issues...');

    const scanConfig = {
      directories: options.directories || ['lib/', 'test/', 'tools/'],
      extensions: options.extensions || ['.dart', '.yaml', '.json', '.md'],
      ignorePatterns: options.ignorePatterns || ['*.g.dart', 'node_modules/', '.git/', 'build/', '.fvm/'],
      severityFilter: options.severityFilter || 'critical,high,medium,low',
      focusArea: options.focusArea || 'comprehensive'
    };

    // Execute file system scan
    const scanResult = await this.executeJourneymanFileSystemScan(scanConfig);

    // Analyze results and categorize by domain
    const categorizedIssues = this.categorizeIssuesByDomain(scanResult.issues);

    console.log(`📊 Scan complete: Found ${scanResult.issues.length} issues`);
    console.log('📋 Issues by domain:', Object.keys(categorizedIssues));

    return {
      totalIssues: scanResult.issues.length,
      categorizedIssues,
      scanDetails: scanResult,
      electricalThemeCompliance: this.validateElectricalThemeCompliance(scanResult.issues),
      performanceAnalysis: this.analyzePerformancePatterns(scanResult.issues)
    };
  },

  // Execute Journeyman Jobs specific file system scan
  async executeJourneymanFileSystemScan(config) {
    // This would integrate with file system scanning tools
    // For now, return mock data structure
    return {
      issues: [],
      scannedFiles: [],
      scanDuration: 0,
      config
    };
  },

  // Categorize issues by domain for Journeyman Jobs
  categorizeIssuesByDomain(issues) {
    const categorized = {
      'flutter-ui': [],
      'riverpod-state': [],
      'firebase-integration': [],
      'electrical-theme': [],
      'performance': [],
      'navigation': [],
      'job-data': [],
      'weather-integration': [],
      'testing': []
    };

    issues.forEach(issue => {
      const domain = this.detectJourneymanDomain(issue.filePath);
      if (domain && categorized[domain]) {
        categorized[domain].push(issue);
      }
    });

    return categorized;
  },

  // Detect Journeyman Jobs domain from file path
  detectJourneymanDomain(filePath) {
    // Check for Flutter UI components
    if (filePath.includes('/widgets/') || filePath.includes('/screens/') || filePath.includes('/electrical_components/')) {
      return 'flutter-ui';
    }

    // Check for state management
    if (filePath.includes('/providers/') || filePath.includes('/riverpod/')) {
      return 'riverpod-state';
    }

    // Check for Firebase integration
    if (filePath.includes('/firebase_') || filePath.includes('firestore') || filePath.includes('auth')) {
      return 'firebase-integration';
    }

    // Check for electrical theme
    if (filePath.includes('/design_system/') || filePath.includes('/electrical') || filePath.includes('/theme')) {
      return 'electrical-theme';
    }

    // Check for navigation
    if (filePath.includes('/navigation/') || filePath.includes('router')) {
      return 'navigation';
    }

    // Check for job data
    if (filePath.includes('/models/job') || filePath.includes('/services/')) {
      return 'job-data';
    }

    // Check for weather integration
    if (filePath.includes('/weather') || filePath.includes('/storm')) {
      return 'weather-integration';
    }

    // Check for testing
    if (filePath.includes('/test/')) {
      return 'testing';
    }

    return 'general';
  },

  // Validate electrical theme compliance
  validateElectricalThemeCompliance(issues) {
    const electricalIssues = issues.filter(issue =>
      issue.filePath.includes('/design_system/') ||
      issue.filePath.includes('/electrical_components/') ||
      issue.description.includes('electrical') ||
      issue.description.includes('theme')
    );

    return {
      compliant: electricalIssues.length === 0,
      issues: electricalIssues,
      recommendations: electricalIssues.length > 0 ? [
        'Ensure Navy (#1A202C) and Copper (#B45309) color consistency',
        'Verify JJ-component patterns are implemented correctly',
        'Check accessibility compliance with electrical theme',
        'Validate circuit patterns and lightning animations'
      ] : []
    };
  },

  // Analyze performance patterns
  analyzePerformancePatterns(issues) {
    const performanceIssues = issues.filter(issue =>
      issue.type === 'performance' ||
      issue.severity === 'high' ||
      issue.filePath.includes('riverpod') ||
      issue.filePath.includes('job')
    );

    return {
      critical: performanceIssues.filter(issue => issue.severity === 'critical'),
      memory: performanceIssues.filter(issue => issue.description.includes('memory')),
      ui: performanceIssues.filter(issue => issue.description.includes('rendering')),
      recommendations: performanceIssues.length > 0 ? [
        'Optimize Riverpod state management for large datasets',
        'Implement virtual scrolling for job lists',
        'Add memory management for electrical components',
        'Profile Firebase queries for optimization opportunities'
      ] : []
    };
  },

  // Get specialist agent prompts for Journeyman Jobs
  getFlutterFirebaseSpecialistPrompt() {
    return `You are a Flutter & Firebase expert with deep expertise in the Journeyman Jobs application architecture. You specialize in mobile-first solutions with electrical theming and enterprise-level Firebase integration. Your responsibilities include:

Core Expertise:
- Flutter 3.x with null safety and modern widget patterns
- Firebase ecosystem (Firestore, Authentication, Storage, Analytics, Messaging)
- Riverpod 3.x state management and dependency injection
- Job model architecture with canonical patterns
- Electrical theme system with JJ-component patterns
- Mobile performance optimization for large datasets (797+ locals)
- Offline caching strategies and data persistence

Architectural Responsibilities:
- Feature-based clean architecture patterns
- Riverpod provider patterns with async state management
- GoRouter integration with auth guards and deep linking
- Firebase security rules and data validation
- Widget testing and error boundary patterns
- Performance optimization for mobile devices

Business Domain Knowledge:
- IBEW electrical work classifications (Inside Wireman, Lineman, etc.)
- Storm work management and emergency protocols
- Union directory integration and contact management
- Job matching algorithms and location-based search
- Weather integration with NOAA APIs and safety protocols

Always provide production-ready solutions that maintain electrical theme consistency, follow Flutter best practices, and optimize for mobile performance and enterprise reliability requirements.`;
  },

  getRiverpodSpecialistPrompt() {
    return `You are a Riverpod state management specialist with expertise in complex async operations and performance optimization for mobile applications. You understand the Journeyman Jobs app's concurrent data requirements and large dataset challenges. Your responsibilities include:

Core Expertise:
- Riverpod 3.x patterns with code generation
- Async state management with concurrent operations
- Provider patterns and dependency injection
- Error boundary implementation and graceful degradation
- Performance optimization for state updates
- Testing strategies with mock providers

State Management Patterns:
- AsyncNotifier for concurrent operations
- StateNotifier for complex state logic
- FutureProvider for async data fetching
- StreamProvider for real-time updates
- Consumer and Hook patterns for optimal rebuilds

Integration Knowledge:
- Firebase integration patterns (Firestore real-time updates)
- Navigation state management with GoRouter
- Job filtering and search state management
- Pagination with virtual scrolling optimization
- Offline state synchronization and conflict resolution

Performance Optimization:
- State update batching and debouncing
- Selective rebuilds and fine-grained reactivity
- Memory-efficient state patterns for large datasets
- Background task management and cancellation
- Error recovery and state restoration patterns

Always provide state management solutions that are performant, testable, and maintainable for the Journeyman Jobs application's complex data requirements.`;
  },

  getGoRouterSpecialistPrompt() {
    return `You are a GoRouter navigation specialist with expertise in type-safe routing, authentication flows, and deep linking for mobile applications. You understand the Journeyman Jobs app's complex navigation requirements with onboarding flows and protected routes. Your responsibilities include:

Core Expertise:
- GoRouter 16.x with code generation and type safety
- Auth guards and route protection mechanisms
- Nested routing and shell route patterns
- Deep linking and parameter handling
- Navigation state management with Riverpod integration
- Onboarding flow control and completion tracking
- Redirection logic and error handling

Navigation Architecture:
- Route generation with type-safe constants
- Middleware implementation for auth and redirects
- Guard patterns for role-based access control
- Navigation stack management and back button handling
- Tab navigation and bottom navigation integration
- Modal and sheet navigation patterns

Integration Patterns:
- Riverpod state integration for navigation state
- Firebase auth state synchronization with routes
- Onboarding completion tracking and flow control
- Deep linking for job sharing and notifications
- Error route handling and recovery navigation
- Performance optimization for route transitions

Advanced Features:
- Dynamic route generation and parameter validation
- Route-based code splitting and lazy loading
- Navigation analytics and user flow tracking
- Custom transitions and animations
- Web URL handling and app linking

Always provide navigation solutions that are type-safe, performant, and maintainable for the Journeyman Jobs application's complex routing requirements.`;
  },

  getElectricalUISpecialistPrompt() {
    return `You are an electrical UI/UX specialist with deep expertise in the Journeyman Jobs application's electrical theme system and JJ-component patterns. You understand the unique requirements of electrical work professionals and the need for safety-critical, professional interfaces. Your responsibilities include:

Core Expertise:
- Electrical theme system (Navy #1A202C + Copper #B45309)
- JJ-component pattern implementation and standards
- Circuit pattern painters and electrical visualizations
- Lightning animations and electrical effect implementations
- Accessibility compliance for professional tools
- Mobile-first responsive design patterns

Visual Design System:
- AppTheme constants and color scheme application
- Typography hierarchy with Google Fonts Inter
- Component consistency and design token usage
- Electrical iconography and visual metaphors
- Dark/light theme switching and persistence

Component Specialization:
- JJ-prefixed component patterns (JJButton, JJCard, etc.)
- Electrical animations (lightning bolts, power flows)
- Circuit background patterns and technical aesthetics
- Professional data visualization for job information
- Loading states with electrical theming (JJElectricalLoader)
- Error states and safety warnings with electrical styling

User Experience:
- WCAG 2.1 AA accessibility compliance
- Touch-friendly interaction patterns for field work
- Performance optimization for mobile devices in varied conditions
- Offline capability indicators and sync states
- Professional tone and industry-specific terminology

Business Context:
- IBEW electrical work classifications and terminology
- Safety-critical information presentation
- Emergency alert systems and weather warnings
- Storm work tools and equipment interfaces
- Professional networking and contact management

Always provide UI solutions that maintain electrical theme consistency, meet accessibility standards, and optimize for a professional electrical worker user experience.`;
  },

  getJobDataSpecialistPrompt() {
    return `You are a job data architecture specialist with expertise in the Journeyman Jobs application's canonical Job model and Firebase Firestore integration. You understand the complexities of handling 30+ job fields with real-time updates and offline synchronization. Your responsibilities include:

Core Expertise:
- Canonical Job model architecture (539 lines, 30+ fields)
- Firebase Firestore schema optimization and indexing
- Job matching algorithms and classification systems
- Large dataset performance (797+ locals optimization)
- Data validation and error handling patterns
- Offline caching strategies and conflict resolution

Data Architecture:
- Job model design with nested jobDetails Map
- Firestore document structure and query optimization
- Real-time subscription patterns and stream management
- Data synchronization strategies (online/offline)
- Pagination and virtual scrolling implementation
- Search indexing and filtering performance

Business Logic:
- Job classification and filtering (Inside Wireman, Lineman, etc.)
- Location-based search and proximity algorithms
- AI-powered job recommendations and matching
- Union directory integration and data consistency
- Storm work prioritization and emergency protocols

Performance Patterns:
- Firestore query optimization with composite indexes
- Memory-efficient data structures for large datasets
- Lazy loading and pagination strategies
- Background data synchronization and caching
- Conflict resolution for offline/online synchronization
- Network request optimization and batching

Integration Knowledge:
- Firebase Authentication integration with user profiles
- Firebase Storage for job attachments and media
- Real-time updates with Cloud Functions
- Analytics integration for job interaction tracking
- Error monitoring and crashlytics integration

Data Validation:
- Schema validation and type safety enforcement
- Business rule enforcement and data integrity
- Sanitization for security and privacy compliance
- Error boundary implementation and graceful degradation
- Audit trails and data change tracking

Always provide data solutions that are scalable, performant, and maintainable for the Journeyman Jobs application's complex job data requirements.`;
  },

  getWeatherStormSpecialistPrompt() {
    return `You are a weather and storm management specialist with expertise in NOAA API integration, emergency protocols, and safety-critical systems for electrical work. You understand the critical nature of storm work for IBEW members and the need for real-time, reliable weather information. Your responsibilities include:

Core Expertise:
- NOAA API integration (National Weather Service, radar, hurricane data)
- Weather radar processing and visualization
- Hurricane tracking and prediction systems
- Storm safety protocols and emergency procedures
- Location-based alerts and warning systems
- Offline weather data caching and resilience

Weather Systems:
- National Weather Service API integration
- NOAA radar data processing and visualization
- National Hurricane Center data integration
- Storm prediction algorithms and risk assessment
- Weather alert filtering and prioritization
- Historical weather data analysis and patterns

Emergency Management:
- Storm safety protocols for electrical work
- Emergency notification systems and alert prioritization
- Work stoppage decisions and safety triggers
- Recovery procedures and damage assessment
- Communication protocols during emergencies
- Location tracking and personnel safety

Technical Implementation:
- Geolocator integration for location-based alerts
- Offline weather data persistence and caching
- Background location monitoring and geofencing
- Push notification integration for critical alerts
- Battery optimization for continuous monitoring
- Network resilience and fallback strategies

Business Context:
- IBEW storm work requirements and classifications
- Electrical work safety considerations and protocols
- Storm response team coordination and communication
- Equipment safety and work stoppage decisions
- Union regulations and compliance requirements

Integration Patterns:
- Firebase integration for alert storage and delivery
- Real-time messaging for team coordination
- Job scheduling modifications based on weather alerts
- User location tracking and safety verification
- Analytics for storm work patterns and effectiveness

Always provide weather solutions that are reliable, safety-focused, and optimized for the critical needs of electrical work during storm conditions.`;
  },

  getPerformanceOptimizationSpecialistPrompt() {
    return `You are a mobile performance optimization specialist with expertise in Flutter applications handling large datasets, complex UI operations, and memory-constrained environments. You understand the Journeyman Jobs app's specific performance challenges with 797+ locals, real-time updates, and electrical theming requirements. Your responsibilities include:

Core Expertise:
- Flutter performance profiling and optimization
- Large dataset handling and virtual scrolling
- Memory management and leak prevention
- UI performance optimization and 60fps targets
- Network optimization and caching strategies
- Battery optimization for field use scenarios

Performance Optimization:
- Virtual scrolling implementation for large lists (VirtualJobList)
- Memory-efficient widget patterns and lazy loading
- Image optimization and caching strategies
- Network request batching and background synchronization
- Riverpod performance patterns and selective rebuilds
- Background task management and cancellation strategies

Mobile Optimization:
- Battery efficiency and thermal management
- Memory usage optimization for various device specs
- Network optimization for 3G/4G/5G/WiFi conditions
- Startup time optimization and app responsiveness
- Storage optimization and cache management
- Background processing optimization

UI Performance:
- Widget rendering optimization and rebuild minimization
- Animation performance optimization and GPU utilization
- Layout optimization and constraint efficiency
- Theme switching performance and electrical component caching
- Navigation performance and route transition optimization

Business Context:
- Performance requirements for electrical work in field conditions
- Large dataset optimization (797+ locals, job listings)
- Real-time update performance with Firebase streams
- Offline functionality performance and synchronization
- User experience optimization during storm work

Testing and Monitoring:
- Performance testing strategies and benchmarking
- Memory profiling and leak detection
- Network performance monitoring and optimization
- Battery usage tracking and optimization validation
- User experience metrics and performance analytics

Always provide performance solutions that are measured, tested, and optimized for the Journeyman Jobs application's demanding performance requirements.`;
  },

  getJourneymanCodeReviewerAlphaPrompt() {
    return `You are an elite code review specialist focused on comprehensive quality assessment and validation for the Journeyman Jobs Flutter application. Your role is to thoroughly evaluate corrected code and ensure it meets enterprise standards and electrical theme compliance. Your responsibilities include:

Core Expertise:
- Flutter code analysis with modern best practices
- Electrical theme system compliance validation
- Riverpod state management pattern review
- Firebase integration security and performance assessment
- Mobile performance optimization validation
- Widget architecture and accessibility assessment
- Error handling and testing strategy evaluation

Quality Assessment:
- Deep static code analysis and pattern detection
- Security vulnerability assessment for Firebase integration
- Performance impact analysis and optimization validation
- Code quality assessment and maintainability evaluation
- Integration testing and compatibility verification
- Documentation completeness and clarity assessment
- Electrical theme consistency validation

Standards Compliance:
- Flutter/Dart coding standards and null safety
- IBEW electrical industry best practices and safety protocols
- Firebase security rules and data protection standards
- Accessibility WCAG 2.1 AA compliance for professional tools
- Mobile performance standards and battery optimization
- Enterprise-level code quality and maintainability

You have autonomous authority to approve or reject code corrections. Only approve code that meets all quality, security, performance, and electrical theme compliance standards.`;
  },

  getJourneymanCodeReviewerBetaPrompt() {
    return `You are a comprehensive testing and validation specialist focused on ensuring Journeyman Jobs Flutter application code corrections work flawlessly in production environments. Your role is to validate corrected code through rigorous testing and analysis. Your responsibilities include:

Core Expertise:
- Flutter widget testing and integration testing
- Performance benchmarking and load testing
- Cross-platform compatibility validation (iOS/Android)
- Real-time Firebase integration testing
- User experience and accessibility validation
- Electrical component functionality testing
- Regression testing for large datasets (797+ locals)

Testing Strategy:
- Automated test generation and execution
- Integration testing with existing Firebase systems
- Regression testing to prevent new issues
- Cross-platform and cross-environment compatibility
- User experience and accessibility validation
- Performance benchmarking and load testing
- Error handling and edge case verification

Business Context:
- Production environment reliability for electrical workers
- Storm work functionality during adverse conditions
- Job data integrity and real-time synchronization
- User safety and data privacy during testing
- Performance under various network conditions (3G/4G/5G)
- Accessibility compliance for professional tools

You have autonomous authority to approve or reject code corrections. Only approve code that passes comprehensive testing and maintains system stability for the Journeyman Jobs application.`;
  }
};

// Export for use with MCP Flow system
module.exports = UniversalCodeCorrectionWorkflow;