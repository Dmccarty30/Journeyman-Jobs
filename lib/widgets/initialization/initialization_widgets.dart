/// Barrel export for all initialization-related widgets
///
/// This file provides a single import point for all initialization UI components,
/// making it easier to use them throughout the application.

// Main screens
export '../initialization/initialization_progress_screen.dart';

// Progress indicators
export 'stage_progress_indicator.dart';
export 'background_progress_indicator.dart';

// Feature displays
export 'feature_availability_card.dart';

// Error handling
export 'error_recovery_widget.dart';

// Utility classes and extensions
export 'stage_progress_indicator.dart' show StageStatus, StageProgressStyle, StageProgress;
export 'feature_availability_card.dart' show FeatureStatus, FeatureCardLayout, FeatureCardStyle, FeatureInfo;
export 'background_progress_indicator.dart' show BackgroundProgressPosition;
export 'error_recovery_widget.dart' show ErrorSeverity, ErrorRecoveryOptions;