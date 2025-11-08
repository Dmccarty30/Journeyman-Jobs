import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/consolidated_session_service.dart';

part 'session_manager_provider.g.dart';

/// Provides the singleton ConsolidatedSessionService instance.
///
/// This provider creates and manages the ConsolidatedSessionService lifecycle.
/// The service is initialized when first accessed and properly disposed
/// when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionManagerProvider);
/// sessionService.recordActivity(); // Record user activity
///
/// // Check if in grace period
/// if (sessionService.isInGracePeriod) {
///   final remaining = sessionService.remainingGracePeriod;
///   // Show warning with countdown
/// }
/// ```
@riverpod
ConsolidatedSessionService sessionManager(Ref ref) {
  final service = ConsolidatedSessionService();

  // Initialize the service
  service.initialize();

  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
