// lib/services/local_notification_service.dart
// Minimal local notification adapter used by providers to avoid missing-import errors.
// Expand this implementation later to integrate with flutter_local_notifications or
// other notification libraries as needed.

class LocalNotificationService {
  /// Minimal initializer used by app_state_riverpod_provider.
  static Future<void> initialize() async {
    // No-op initializer to satisfy callers during analysis and early runtime.
    // Replace with actual plugin initialization when wiring real notifications.
    return;
  }

  /// Optional: add other small helper stubs if callers reference them.
}