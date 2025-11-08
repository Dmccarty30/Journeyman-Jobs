import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:flutter/foundation.dart';
import 'consolidated_session_service.dart';

/// Stream Chat service that handles chat client initialization and team management.
///
/// SECURITY IMPLEMENTATION:
/// ✅ Secure token generation via Firebase Cloud Functions
/// ✅ API secret never exposed to client
/// ✅ User authentication required for all operations
/// ✅ Automatic user profile sync with Stream Chat
///
/// Features:
/// - Secure client initialization with Firebase Auth integration
/// - Team-based isolation for crew messaging
/// - Automatic user profile synchronization
/// - Clean disconnect and resource cleanup
///
/// Client Lifecycle:
/// - Initialize client on user login
/// - Token generated server-side via Cloud Function
/// - User automatically added to Stream Chat system
/// - Disconnect on user logout for cleanup
///
/// Team Assignment:
/// - Users assigned to teams (mapped to crew IDs)
/// - Team filter enforces message isolation
/// - Automatic team update when user switches crews
class StreamChatService {
  // Stream Chat API key from environment
  static const String _apiKey = String.fromEnvironment(
    'STREAM_API_KEY',
    defaultValue: 'YOUR_STREAM_API_KEY', // Replace with actual key or use --dart-define
  );

  // Singleton instance
  static final StreamChatService _instance = StreamChatService._internal();
  factory StreamChatService() => _instance;
  StreamChatService._internal();

  // Stream Chat client instance
  stream.StreamChatClient? _client;
  stream.StreamChatClient? get client => _client;

  /// Initialize Stream Chat client with secure token from Firebase Cloud Function.
  ///
  /// This method:
  /// 1. Verifies Firebase user authentication
  /// 2. Calls getStreamUserToken Cloud Function
  /// 3. Receives secure token and user ID
  /// 4. Initializes Stream client with token
  /// 5. Connects user to Stream Chat
  ///
  /// Throws [Exception] if:
  /// - User not authenticated with Firebase
  /// - Cloud Function call fails
  /// - Client initialization fails
  ///
  /// Example usage:
  /// ```dart
  /// final streamService = StreamChatService();
  /// await streamService.initializeClient();
  /// ```
  Future<stream.StreamChatClient> initializeClient() async {
    try {
      // Use consolidated session service to prevent auth conflicts
      final sessionService = ConsolidatedSessionService();

      return await sessionService.initializeStreamChatSafely(() async {
        // Verify Firebase user authentication
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          throw Exception('User must be authenticated with Firebase');
        }

        debugPrint('[StreamChatService] Initializing client for user: ${firebaseUser.uid}');

        // Call Cloud Function to get secure token
        final functions = FirebaseFunctions.instance;
        final result = await functions.httpsCallable('getStreamUserToken').call();

        final token = result.data['token'] as String;
        final userId = result.data['userId'] as String;

        debugPrint('[StreamChatService] Received token for user: $userId');

        // Initialize Stream client if not already created
        _client ??= stream.StreamChatClient(_apiKey, logLevel: stream.Level.INFO);

        // Connect user to Stream Chat with token
        await _client!.connectUser(
          stream.User(id: userId),
          token,
        );

        debugPrint('[StreamChatService] Client connected successfully');

        return _client!;
      });
    } catch (e) {
      debugPrint('[StreamChatService] Failed to initialize client: $e');
      rethrow;
    }
  }

  /// Update user's team assignment for crew isolation.
  ///
  /// This method calls the updateUserTeam Cloud Function to assign
  /// the user to a specific crew team, enabling message isolation.
  ///
  /// Team assignment ensures:
  /// - User only sees channels from their crew
  /// - DMs only work within same crew
  /// - #general channel is crew-specific
  ///
  /// Parameters:
  /// - [teamId]: Crew ID to assign user to
  ///
  /// Throws [Exception] if:
  /// - User not authenticated
  /// - Cloud Function call fails
  /// - Team update fails
  ///
  /// Example usage:
  /// ```dart
  /// await streamService.updateUserTeam('crew-123');
  /// ```
  Future<void> updateUserTeam(String teamId) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User must be authenticated');
      }

      debugPrint('[StreamChatService] Updating user team to: $teamId');

      // Call Cloud Function to update team
      final functions = FirebaseFunctions.instance;
      await functions.httpsCallable('updateUserTeam').call({
        'teamId': teamId,
      });

      debugPrint('[StreamChatService] Team updated successfully');
    } catch (e) {
      debugPrint('[StreamChatService] Failed to update team: $e');
      rethrow;
    }
  }

  /// Disconnect Stream Chat client and cleanup resources.
  ///
  /// Call this method when:
  /// - User logs out
  /// - App is closing
  /// - Switching to different account
  ///
  /// This ensures:
  /// - Clean disconnection from Stream servers
  /// - Resources are properly released
  /// - No memory leaks
  ///
  /// Example usage:
  /// ```dart
  /// await streamService.disconnectClient();
  /// ```
  Future<void> disconnectClient() async {
    try {
      if (_client != null) {
        debugPrint('[StreamChatService] Disconnecting client');
        await _client!.disconnectUser();
        _client = null;
        debugPrint('[StreamChatService] Client disconnected successfully');
      }
    } catch (e) {
      debugPrint('[StreamChatService] Error disconnecting client: $e');
      // Don't rethrow - allow logout to proceed even if disconnect fails
    }
  }

  /// Check if client is currently connected
  bool get isConnected => _client?.wsConnectionStatus == stream.ConnectionStatus.connected;
}
