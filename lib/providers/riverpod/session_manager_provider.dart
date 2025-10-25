import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/session_manager_service.dart';

part 'session_manager_provider.g.dart';

/// Provides the singleton SessionManagerService instance.
///
/// This provider creates and manages the SessionManagerService lifecycle.
/// The service is initialized when first accessed and properly disposed
/// when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionManager = ref.watch(sessionManagerProvider);
/// sessionManager.recordActivity(); // Record user activity
///
/// // Check if in grace period
/// if (sessionManager.isInGracePeriod) {
///   final remaining = sessionManager.remainingGracePeriod;
///   // Show warning with countdown
/// }
/// ```
@riverpod
SessionManagerService sessionManager(Ref ref) {
  final service = SessionManagerService();

  // Initialize the service
  service.initialize();

  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
