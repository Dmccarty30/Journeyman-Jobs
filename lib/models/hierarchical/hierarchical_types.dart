/// Export all hierarchical types for easy importing
/// This barrel file ensures all hierarchical types are accessible
/// from a single import, which helps with code generation.

// Core data models
export 'hierarchical_data_model.dart';
export 'union_model.dart';

// Initialization system
export 'initialization_stage.dart';
export 'initialization_dependency_graph.dart';
export 'initialization_metadata.dart';

// Base models
export '../job_model.dart';
export '../locals_record.dart';

// Service types (re-exported for code generation)
export '../../services/hierarchical/hierarchical_service.dart'
    show HierarchicalSearchResult;
export '../../services/hierarchical/hierarchical_initialization_service.dart'
    show
        HierarchicalInitializationState,
        HierarchicalInitializationPhase,
        HierarchicalInitializationStrategy,
        HierarchicalHealthCheckResult;

// Enhanced initialization system types
export '../../services/hierarchical/hierarchical_initializer.dart'
    show
        HierarchicalInitializer,
        InitializationResult,
        InitializationConditions,
        InitializationStats,
        InitializationEvent,
        InitializationStartedEvent,
        InitializationCompletedEvent,
        InitializationFailedEvent,
        StageStartedEvent,
        StageCompletedEvent,
        StageFailedEvent,
        InitializationStrategy;

// Progress tracking and error management
export 'initialization_progress_tracker.dart'
    show
        InitializationProgressTracker,
        InitializationProgress,
        StageProgress;

export 'error_manager.dart'
    show
        ErrorManager,
        ErrorStats,
        RecoveryAction;

export 'performance_monitor.dart'
    show
        PerformanceMonitor,
        PerformanceStats,
        PerformanceRecommendation;
