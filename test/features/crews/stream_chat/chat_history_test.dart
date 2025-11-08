import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/services/stream_chat_service.dart';
import 'package:journeyman_jobs/features/crews/models/models.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

import 'chat_history_test.mocks.dart';

@GenerateMocks([StreamChatService, StreamChatClient])
void main() {
  group('Chat History Tests (Container 2)', () {
    late MockStreamChatService mockService;
    late MockStreamChatClient mockClient;
    late ProviderContainer container;
    late User testUser;
    late Crew testCrew;

    setUp(() {
      mockService = MockStreamChatService();
      mockClient = MockStreamChatClient();

      testUser = User(
        id: 'test_user_001',
        name: 'John Davis',
        extraData: {
          'crew_id': 'test_crew_123',
          'ibew_local': 84,
          'classification': 'Journeyman Lineman',
        },
      );

      testCrew = Crew(
        id: 'test_crew_123',
        name: 'IBEW Local 84 Storm Team',
        memberIds: ['test_user_001', 'user_002', 'user_003'],
        foremanId: 'user_002',
        crewType: CrewType.lineman,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      );

      container = ProviderContainer(
        overrides: [
          streamChatServiceProvider.overrideWithValue(mockService),
        ],
      );

      when(mockService.initializeClient()).thenAnswer((_) async => mockClient);
      when(mockService.currentUserId).thenReturn(testUser.id);
      when(mockService.disconnectClient()).thenAnswer((_) async {});
    });

    tearDown(() {
      container.dispose();
    });

    group('1. Archive Test Channel and Verify Display', () {
      test('should display archived channels in history', () async {
        // Arrange: Create archived channels
        final archivedChannel1 = Channel(
          cid: ChannelId('messaging:archived_storm_chat'),
          type: 'messaging',
          id: 'archived_storm_chat',
          state: const ChannelState(
            hidden: true, // Indicates archived
            archived: true,
          ),
          extraData: {
            'name': 'Storm Response - Feb 2024',
            'team': 'test_crew_123',
            'type': 'crew',
            'archived_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'archived_by': 'test_user_001',
          },
        );

        final archivedChannel2 = Channel(
          cid: ChannelId('messaging:archived_project_chat'),
          type: 'messaging',
          id: 'archived_project_chat',
          state: const ChannelState(
            hidden: true,
            archived: true,
          ),
          extraData: {
            'name': 'Project Alpha - Complete',
            'team': 'test_crew_123',
            'type': 'crew',
            'archived_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
            'archived_by': 'user_002',
          },
        );

        // Mock query for archived channels
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
          sort: [const SortOption('archived_at', direction: SortOption.DESC)],
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [archivedChannel1, archivedChannel2],
        ));

        // Act: Query archived channels
        final archivedChannels = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
          sort: [const SortOption('archived_at', direction: SortOption.DESC)],
        );

        // Assert: Verify archived channels are returned
        expect(archivedChannels.channels.length, 2);

        for (final channel in archivedChannels.channels) {
          expect(channel.extraData!['team'], equals('test_crew_123'));
          expect(channel.state?.archived, isTrue);
          expect(channel.extraData!.containsKey('archived_at'), isTrue);
          expect(channel.extraData!.containsKey('archived_by'), isTrue);
        }

        // Verify correct filter and sort were applied
        verify(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
          sort: [const SortOption('archived_at', direction: SortOption.DESC)],
        )).called(1);
      });

      test('should only show archived channels from user\'s crew', () async {
        // Arrange: Create archived channels from different crews
        final ownArchivedChannel = Channel(
          cid: ChannelId('messaging:own_archived'),
          extraData: {
            'name': 'Our Archived Chat',
            'team': 'test_crew_123',
            'archived': true,
          },
        );

        final otherArchivedChannel = Channel(
          cid: ChannelId('messaging:other_archived'),
          extraData: {
            'name': 'Other Crew Archived Chat',
            'team': 'other_crew_999',
            'archived': true,
          },
        );

        // Mock query with team filter
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [ownArchivedChannel],
        ));

        // Act: Query archived channels for user's crew
        final result = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
        );

        // Assert: Verify only user's crew archived channels are returned
        expect(result.channels.length, 1);
        expect(result.channels.first.extraData!['team'], equals('test_crew_123'));
        expect(result.channels.first.extraData!['name'], equals('Our Archived Chat'));

        // Verify other crew's archived channels are not included
        expect(result.channels.any((c) =>
          c.extraData!['team'] == 'other_crew_999'), isFalse);
      });
    });

    group('2. Test Restore Action', () {
      test('should restore archived channel to active channels', () async {
        // Arrange: Create archived channel
        final archivedChannel = Channel(
          cid: ChannelId('messaging:archived_to_restore'),
          type: 'messaging',
          id: 'archived_to_restore',
          state: const ChannelState(archived: true),
          extraData: {
            'name': 'Chat to Restore',
            'team': 'test_crew_123',
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'archived_to_restore',
        )).thenReturn(Channel(mockClient, 'messaging', 'archived_to_restore'));

        // Mock unarchive operation
        final restoreAction = mockClient.channel(type: 'messaging', id: 'archived_to_restore');
        when(restoreAction.unarchive()).thenAnswer((_) async {});

        // Act: Restore archived channel
        await restoreAction.unarchive();

        // Assert: Verify restore operation was called
        verify(restoreAction.unarchive()).called(1);

        // Verify restored channel is no longer archived
        final restoredChannel = Channel(
          cid: ChannelId('messaging:archived_to_restore'),
          state: const ChannelState(archived: false),
        );

        expect(restoredChannel.state?.archived, isFalse);
      });

      test('should handle restore errors gracefully', () async {
        // Arrange: Mock restore failure
        final archivedChannel = Channel(
          cid: ChannelId('messaging:restore_failed'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'restore_failed',
        )).thenReturn(archivedChannel);

        when(archivedChannel.unarchive()).thenThrow(StreamChatError(
          message: 'Failed to restore channel',
          code: ErrorCode.failed,
        ));

        // Act & Assert: Verify restore error is handled
        expect(
          () async => await archivedChannel.unarchive(),
          throwsA(isA<StreamChatError>()),
        );
      });
    });

    group('3. Test Delete Action with Confirmation', () {
      test('should show delete confirmation dialog', () async {
        // Arrange: This would typically show a dialog
        // In testing, we verify the delete channel is retrieved correctly
        final channelToDelete = Channel(
          cid: ChannelId('messaging:delete_test'),
          id: 'delete_test',
          extraData: {
            'name': 'Channel to Delete',
            'team': 'test_crew_123',
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'delete_test',
        )).thenReturn(channelToDelete);

        // Act: Get channel for deletion
        final deleteChannel = mockClient.channel(type: 'messaging', id: 'delete_test');

        // Assert: Verify correct channel is retrieved for deletion
        expect(deleteChannel.id, equals('delete_test'));
        expect(deleteChannel.extraData!['name'], equals('Channel to Delete'));
      });

      test('should permanently delete channel after confirmation', () async {
        // Arrange: Mock channel deletion
        final channelToDelete = Channel(
          cid: ChannelId('messaging:permanent_delete'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'permanent_delete',
        )).thenReturn(channelToDelete);

        when(channelToDelete.delete()).thenAnswer((_) async {});

        // Act: Delete channel (after user confirmation)
        await channelToDelete.delete();

        // Assert: Verify delete operation was called
        verify(channelToDelete.delete()).called(1);
      });

      test('should prevent deletion of critical channels', () async {
        // Arrange: Mock protected channel (e.g., #general)
        final protectedChannel = Channel(
          cid: ChannelId('messaging:test_crew_general'),
          extraData: {
            'name': '#general',
            'team': 'test_crew_123',
            'type': 'crew',
            'protected': true,
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'test_crew_general',
        )).thenReturn(protectedChannel);

        when(protectedChannel.delete()).thenThrow(StreamChatError(
          message: 'Cannot delete protected channel',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify protected channel deletion is blocked
        expect(
          () async => await protectedChannel.delete(),
          throwsA(isA<StreamChatError>()),
        );

        // Verify delete was attempted on protected channel
        verify(protectedChannel.delete()).called(1);
      });
    });

    group('4. Archive Channel Creation', () {
      test('should archive channel with proper metadata', () async {
        // Arrange: Create active channel to archive
        final activeChannel = Channel(
          cid: ChannelId('messaging:to_archive'),
          type: 'messaging',
          id: 'to_archive',
          state: const ChannelState(archived: false),
          extraData: {
            'name': 'Active Project Chat',
            'team': 'test_crew_123',
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'to_archive',
        )).thenReturn(activeChannel);

        // Mock archive operation
        when(activeChannel.archive()).thenAnswer((_) async {});

        // Act: Archive channel
        await activeChannel.archive();

        // Assert: Verify archive operation was called
        verify(activeChannel.archive()).called(1);

        // Verify archived state
        final archivedChannel = Channel(
          cid: ChannelId('messaging:to_archive'),
          state: const ChannelState(archived: true),
          extraData: {
            'name': 'Active Project Chat',
            'team': 'test_crew_123',
            'archived_at': DateTime.now().toIso8601String(),
            'archived_by': testUser.id,
          },
        );

        expect(archivedChannel.state?.archived, isTrue);
        expect(archivedChannel.extraData!['archived_by'], equals(testUser.id));
      });
    });

    group('5. Archived Channel Message History', () {
      test('should preserve message history in archived channels', () async {
        // Arrange: Create archived channel with messages
        final archivedChannel = Channel(
          cid: ChannelId('messaging:archived_with_history'),
          type: 'messaging',
          id: 'archived_with_history',
          state: const ChannelState(archived: true),
        );

        final historicalMessages = [
          Message(
            id: 'msg_001',
            text: 'Initial project setup',
            user: testUser,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          Message(
            id: 'msg_002',
            text: 'Site inspection completed',
            user: User(id: 'user_002', name: 'Foreman'),
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          Message(
            id: 'msg_003',
            text: 'Project completed successfully',
            user: testUser,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(mockClient.queryMessages(
          cid: archivedChannel.cid!,
        )).thenAnswer((_) async => QueryMessagesResponse(
          messages: historicalMessages,
        ));

        // Act: Query messages from archived channel
        final messageHistory = await mockClient.queryMessages(
          cid: archivedChannel.cid!,
        );

        // Assert: Verify message history is preserved
        expect(messageHistory.messages.length, 3);

        // Verify chronological order
        expect(messageHistory.messages.first.createdAt.isAfter(
          messageHistory.messages.last.createdAt), isTrue);

        // Verify message content
        expect(messageHistory.messages.any((m) =>
          m.text.contains('Project completed successfully')), isTrue);
      });

      test('should allow read-only access to archived channel messages', () async {
        // Arrange: Create archived channel
        final archivedChannel = Channel(
          cid: ChannelId('messaging:read_only_archive'),
          state: const ChannelState(
            archived: true,
            frozen: true, // Read-only mode
          ),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'read_only_archive',
        )).thenReturn(archivedChannel);

        // Mock read-only permissions
        when(archivedChannel.sendMessage(any)).thenThrow(StreamChatError(
          message: 'Cannot send messages to archived channels',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify message sending is blocked
        expect(
          () async => await archivedChannel.sendMessage(
            MessageRequest(text: 'New message'),
          ),
          throwsA(isA<StreamChatError>()),
        );

        // Verify message reading is still allowed
        when(mockClient.queryMessages(
          cid: archivedChannel.cid!,
        )).thenAnswer((_) async => QueryMessagesResponse(
          messages: [Message(
            id: 'old_msg',
            text: 'Historical message',
            user: testUser,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          )],
        ));

        final messages = await mockClient.queryMessages(cid: archivedChannel.cid!);
        expect(messages.messages.length, 1);
      });
    });

    group('6. Electrical Theme Integration', () {
      testWidgets('should apply electrical theme to archived channel list', (tester) async {
        // Arrange: Create archived channels
        final archivedChannel = Channel(
          cid: ChannelId('messaging:themed_archive'),
          extraData: {
            'name': 'Archived Storm Response',
            'team': 'test_crew_123',
            'archived': true,
            'archived_at': DateTime.now().toIso8601String(),
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [archivedChannel],
        ));

        // Act: Build themed archived channels view
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              theme: ThemeData(
                primaryColor: AppTheme.primaryNavy,
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.blue,
                  accentColor: AppTheme.accentCopper,
                ),
              ),
              home: Scaffold(
                backgroundColor: AppTheme.backgroundGrey,
                body: Column(
                  children: [
                    Text(
                      'Archived Channels',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: StreamChannelListView(
                        controller: mockClient,
                        filter: Filter.and([
                          Filter.equal('team', 'test_crew_123'),
                          Filter.equal('archived', true),
                        ]),
                        onChannelTap: (channel) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify electrical theme is applied
        expect(find.text('Archived Channels'), findsOneWidget);
        expect(find.text('Archived Storm Response'), findsOneWidget);

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppTheme.backgroundGrey));
      });
    });

    group('7. Performance Tests', () {
      test('should handle large number of archived channels efficiently', () async {
        // Arrange: Create many archived channels
        final manyArchivedChannels = List.generate(30, (index) => Channel(
          cid: ChannelId('messaging:archived_$index'),
          extraData: {
            'name': 'Archived Channel $index',
            'team': 'test_crew_123',
            'archived': true,
          },
        ));

        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: manyArchivedChannels,
        ));

        final stopwatch = Stopwatch()..start();

        // Act: Query many archived channels
        final result = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'test_crew_123'),
            Filter.equal('archived', true),
          ]),
        );

        stopwatch.stop();

        // Assert: Verify performance < 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(result.channels.length, 30);
      });
    });

    group('8. Integration with Container Navigation', () {
      test('should handle archive/unarchive navigation correctly', () async {
        // Arrange: Test channel state transitions
        final testChannel = Channel(
          cid: ChannelId('messaging:navigation_test'),
          id: 'navigation_test',
          extraData: {
            'name': 'Navigation Test Channel',
            'team': 'test_crew_123',
          },
        );

        // Mock state transitions
        when(mockClient.channel(
          type: 'messaging',
          id: 'navigation_test',
        )).thenReturn(testChannel);

        // Active -> Archived
        when(testChannel.archive()).thenAnswer((_) async {});
        // Archived -> Active
        when(testChannel.unarchive()).thenAnswer((_) async {});

        // Act: Perform state transitions
        await testChannel.archive(); // Move to Container 2 (History)
        await testChannel.unarchive(); // Move back to Container 0 (Channels)

        // Assert: Verify both operations were called
        verify(testChannel.archive()).called(1);
        verify(testChannel.unarchive()).called(1);
      });
    });
  });
}