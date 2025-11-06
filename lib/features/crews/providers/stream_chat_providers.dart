import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/services/stream_chat_service.dart';

/// Stream Chat Riverpod Providers
///
/// Provides state management for Stream Chat integration in crew messaging.
///
/// Provider Hierarchy:
/// 1. streamChatClientProvider - Base client initialization
/// 2. crewChannelsProvider - Crew-specific channels (depends on client)
/// 3. dmConversationsProvider - Direct messages (depends on client)
/// 4. activeChannelProvider - Currently active channel (state only)
///
/// Team Isolation:
/// All channel queries use Filter.equal('team', crewId) to ensure
/// users only see content from their current crew.

/// Service provider for Stream Chat operations
final streamChatServiceProvider = Provider<StreamChatService>((ref) {
  return StreamChatService();
});

/// FutureProvider that initializes Stream Chat client.
///
/// This provider:
/// - Calls StreamChatService.initializeClient()
/// - Returns connected StreamChatClient
/// - Auto-disposes on provider disposal
///
/// Usage:
/// ```dart
/// final clientAsync = ref.watch(streamChatClientProvider);
/// clientAsync.when(
///   data: (client) => StreamChat(client: client, child: ...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final streamChatClientProvider = FutureProvider<StreamChatClient>((ref) async {
  final service = ref.watch(streamChatServiceProvider);

  // Initialize and return client
  final client = await service.initializeClient();

  // Cleanup on disposal
  ref.onDispose(() {
    service.disconnectClient();
  });

  return client;
});

/// FutureProvider.family that queries crew channels with team filter.
///
/// Parameters:
/// - [crewId]: Crew ID for team isolation filter
///
/// This provider:
/// - Queries channels where team == crewId
/// - Sorts by last_message_at (most recent first)
/// - Returns list of channels for crew
///
/// Usage:
/// ```dart
/// final channelsAsync = ref.watch(crewChannelsProvider(crewId));
/// channelsAsync.when(
///   data: (channels) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final crewChannelsProvider = FutureProvider.family<List<Channel>, String>((ref, crewId) async {
  final client = await ref.watch(streamChatClientProvider.future);

  // Query channels with team filter for crew isolation
  final channels = await client.queryChannels(
    filter: Filter.equal('team', crewId),
    sort: [const SortOption('last_message_at', direction: SortOption.ASC)],
  ).first;

  return channels;
});

/// FutureProvider.family that queries direct message conversations with team filter.
///
/// Parameters:
/// - [crewId]: Crew ID for team isolation filter
///
/// This provider:
/// - Queries 1:1 DM channels where team == crewId
/// - Filters for channels with exactly 2 members (distinct DMs)
/// - Sorts by last_message_at (most recent first)
/// - Returns list of DM conversations
///
/// Usage:
/// ```dart
/// final dmsAsync = ref.watch(dmConversationsProvider(crewId));
/// dmsAsync.when(
///   data: (channels) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final dmConversationsProvider = FutureProvider.family<List<Channel>, String>((ref, crewId) async {
  final client = await ref.watch(streamChatClientProvider.future);

  // Query DM channels with team filter for crew isolation
  // member_count == 2 ensures 1:1 conversations only
  final channels = await client.queryChannels(
    filter: Filter.and([
      Filter.equal('team', crewId),
      Filter.equal('member_count', 2),
    ]),
    sort: [const SortOption('last_message_at', direction: SortOption.ASC)],
  ).first;

  return channels;
});

/// StateProvider for tracking the currently active/open channel.
///
/// This provider:
/// - Holds reference to currently open channel
/// - Updates when user navigates to different channel
/// - Used to highlight active channel in lists
/// - Clears when user exits channel view
///
/// Usage:
/// ```dart
/// // Get current channel
/// final activeChannel = ref.watch(activeChannelProvider);
///
/// // Set active channel when navigating
/// ref.read(activeChannelProvider.notifier).state = channel;
///
/// // Clear active channel when exiting
/// ref.read(activeChannelProvider.notifier).state = null;
/// ```
final activeChannelProvider = StateProvider<Channel?>((ref) => null);
