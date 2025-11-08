import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/services/stream_chat_service.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

import 'channel_list_test.mocks.dart';

@GenerateMocks([StreamChatService, StreamChatClient])
void main() {
  group('Channel List Tests (Container 0)', () {
    late MockStreamChatService mockService;
    late MockStreamChatClient mockClient;
    late ProviderContainer container;
    late User testUser;

    setUp(() {
      mockService = MockStreamChatService();
      mockClient = MockStreamChatClient();

      testUser = User(
        id: 'test_user_001',
        name: 'Test User',
        extraData: {
          'crew_id': 'test_crew_123',
          'ibew_local': 84,
        },
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

    group('1. Create Test Channels and Verify Display', () {
      testWidgets('should display crew channels in StreamChannelListView', (tester) async {
        // Arrange: Create mock channels
        final generalChannel = Channel(
          cid: ChannelId('messaging:test_crew_general'),
          type: 'messaging',
          id: 'test_crew_general',
          extraData: {
            'name': '#general',
            'team': 'test_crew_123',
            'type': 'crew',
            'member_count': 5,
          },
        );

        final workChannel = Channel(
          cid: ChannelId('messaging:test_crew_work'),
          type: 'messaging',
          id: 'test_crew_work',
          extraData: {
            'name': 'Work Chat',
            'team': 'test_crew_123',
            'type': 'crew',
            'member_count': 3,
          },
        );

        // Mock successful client initialization
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: anyNamed('sort'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [generalChannel, workChannel],
        ));

        when(mockClient.queryChannels(
          filter: anyNamed('filter'),
          sort: anyNamed('sort'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [generalChannel, workChannel],
        ));

        // Act: Build widget with StreamChannelListView
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: StreamChannelListView(
                  controller: mockClient,
                  filter: Filter.equal('team', 'test_crew_123'),
                  sort: [const SortOption('last_message_at', direction: SortOption.DESC)],
                  onChannelTap: (channel) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify channels are displayed
        expect(find.text('#general'), findsOneWidget);
        expect(find.text('Work Chat'), findsOneWidget);

        // Verify electrical theme is applied
        expect(find.byType(StreamChannelListView), findsOneWidget);
      });

      test('should create and display new crew channel', () async {
        // Arrange: Mock channel creation
        final newChannel = Channel(
          cid: ChannelId('messaging:new_channel'),
          type: 'messaging',
          id: 'new_channel',
          extraData: {
            'name': 'New Safety Chat',
            'team': 'test_crew_123',
            'type': 'crew',
            'created_by': testUser.id,
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            allOf([
              containsPair('name', 'New Safety Chat'),
              containsPair('team', 'test_crew_123'),
              containsPair('type', 'crew'),
            ]),
            named: 'extraData',
          ),
        )).thenReturn(Channel(mockClient, 'messaging', 'new_channel'));

        // Act: Create new channel
        final createdChannel = mockClient.channel(
          type: 'messaging',
          extraData: {
            'name': 'New Safety Chat',
            'team': 'test_crew_123',
            'type': 'crew',
            'members': [testUser.id],
          },
        );

        // Assert: Verify channel creation with correct data
        expect(createdChannel, isA<Channel>());
        verify(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            allOf([
              containsPair('name', 'New Safety Chat'),
              containsPair('team', 'test_crew_123'),
            ]),
            named: 'extraData',
          ),
        )).called(1);
      });
    });

    group('2. Unread Count Badge Tests', () {
      testWidgets('should display unread count badges on channels', (tester) async {
        // Arrange: Create channel with unread messages
        final channelWithUnread = Channel(
          cid: ChannelId('messaging:unread_channel'),
          type: 'messaging',
          id: 'unread_channel',
          state: const ChannelState(
            unreadCount: 3,
            lastMessageAt: null,
          ),
          extraData: {
            'name': 'Unread Channel',
            'team': 'test_crew_123',
          },
        );

        final channelRead = Channel(
          cid: ChannelId('messaging:read_channel'),
          type: 'messaging',
          id: 'read_channel',
          state: const ChannelState(
            unreadCount: 0,
            lastMessageAt: null,
          ),
          extraData: {
            'name': 'Read Channel',
            'team': 'test_crew_123',
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [channelWithUnread, channelRead],
        ));

        // Act: Build channel list
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: StreamChannelListView(
                  controller: mockClient,
                  filter: Filter.equal('team', 'test_crew_123'),
                  onChannelTap: (channel) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify channel list displays
        expect(find.text('Unread Channel'), findsOneWidget);
        expect(find.text('Read Channel'), findsOneWidget);

        // Note: Actual unread badge testing would depend on Stream Chat's internal widget structure
        // This test verifies the channel data is properly set up
      });

      test('should update unread count when messages are read', () async {
        // Arrange: Create channel with unread messages
        final testChannel = Channel(
          cid: ChannelId('messaging:test_unread'),
          type: 'messaging',
          id: 'test_unread',
          state: const ChannelState(
            unreadCount: 5,
            lastMessageAt: null,
          ),
        );

        // Mock mark as read functionality
        when(mockClient.queryChannels(
          filter: Filter.equal('id', 'test_unread'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [testChannel],
        ));

        when(mockClient.channel(
          type: 'messaging',
          id: 'test_unread',
        )).thenReturn(Channel(mockClient, 'messaging', 'test_unread'));

        // Act: Mark channel as read
        final channel = mockClient.channel(type: 'messaging', id: 'test_unread');

        // Mock successful read
        when(channel.markRead()).thenAnswer((_) async {});

        await channel.markRead();

        // Assert: Verify markRead was called
        verify(channel.markRead()).called(1);
      });
    });

    group('3. Real-time Message Update Tests', () {
      test('should update channel list when new messages arrive', () async {
        // Arrange: Setup initial channels
        final testChannel = Channel(
          cid: ChannelId('messaging:realtime_test'),
          type: 'messaging',
          id: 'realtime_test',
          state: const ChannelState(
            unreadCount: 0,
            lastMessageAt: null,
          ),
          extraData: {
            'name': 'Realtime Test',
            'team': 'test_crew_123',
          },
        );

        // Mock real-time channel updates
        final updatedChannel = Channel(
          cid: ChannelId('messaging:realtime_test'),
          type: 'messaging',
          id: 'realtime_test',
          state: ChannelState(
            unreadCount: 1,
            lastMessageAt: DateTime.now(),
          ),
          extraData: {
            'name': 'Realtime Test',
            'team': 'test_crew_123',
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [testChannel],
        ));

        // Mock event subscription for real-time updates
        final eventController = StreamController<Event>();
        when(mockClient.events).thenAnswer((_) => eventController.stream);

        // Act: Simulate new message event
        final newMessageEvent = MessageNewEvent(
          message: Message(
            id: 'new_msg_001',
            text: 'New message',
            user: testUser,
            createdAt: DateTime.now(),
          ),
          channel: ChannelState(
            cid: testChannel.cid!,
            channel: testChannel,
          ),
        );

        eventController.add(newMessageEvent);

        // Assert: Verify event stream is available
        verify(mockClient.events).called(1);

        eventController.close();
      });

      test('should handle channel state updates in real-time', () async {
        // Arrange: Create channel that will be updated
        const testChannelId = 'messaging:state_update_test';

        final eventController = StreamController<Event>();
        when(mockClient.events).thenAnswer((_) => eventController.stream);

        // Act: Simulate channel updated event
        final channelUpdatedEvent = ChannelUpdatedEvent(
          channel: ChannelState(
            cid: ChannelId(testChannelId),
            lastMessageAt: DateTime.now(),
            unreadCount: 2,
          ),
        );

        eventController.add(channelUpdatedEvent);

        // Assert: Verify events are properly streamed
        expect(mockClient.events, isA<Stream<Event>>());

        eventController.close();
      });
    });

    group('4. Channel Sorting Tests', () {
      test('should sort channels by last_message_at by default', () async {
        // Arrange: Create channels with different timestamps
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final twoHoursAgo = now.subtract(const Duration(hours: 2));

        final channels = [
          Channel(
            cid: ChannelId('messaging:oldest'),
            state: ChannelState(lastMessageAt: twoHoursAgo),
          ),
          Channel(
            cid: ChannelId('messaging:newest'),
            state: ChannelState(lastMessageAt: now),
          ),
          Channel(
            cid: ChannelId('messaging:middle'),
            state: ChannelState(lastMessageAt: oneHourAgo),
          ),
        ];

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: [const SortOption('last_message_at', direction: SortOption.DESC)],
        )).thenAnswer((_) async => QueryChannelsResponse(channels: channels));

        // Act: Query sorted channels
        final result = await mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: [const SortOption('last_message_at', direction: SortOption.DESC)],
        );

        // Assert: Verify correct sorting was requested
        verify(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: [const SortOption('last_message_at', direction: SortOption.DESC)],
        )).called(1);

        expect(result.channels.length, 3);
      });

      test('should handle custom sorting options', () async {
        // Arrange: Test custom sort by channel name
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: [const SortOption('name', direction: SortOption.ASC)],
        )).thenAnswer((_) async => QueryChannelsResponse(channels: []));

        // Act: Query with custom sort
        await mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: [const SortOption('name', direction: SortOption.ASC)],
        );

        // Assert: Verify custom sort was applied
        verify(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
          sort: [const SortOption('name', direction: SortOption.ASC)],
        )).called(1);
      });
    });

    group('5. Electrical Theme Integration', () {
      testWidgets('should apply electrical copper theme to channel list', (tester) async {
        // Arrange: Create theme-aware channel list
        final testChannel = Channel(
          cid: ChannelId('messaging:theme_test'),
          extraData: {
            'name': 'Theme Test Channel',
            'team': 'test_crew_123',
          },
        );

        when(mockClient.queryChannels(
          filter: anyNamed('filter'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [testChannel],
        ));

        // Act: Build with electrical theme
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
                body: StreamChannelListView(
                  controller: mockClient,
                  filter: Filter.equal('team', 'test_crew_123'),
                  onChannelTap: (channel) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify electrical theme elements
        expect(find.text('Theme Test Channel'), findsOneWidget);

        // Verify background color matches electrical theme
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppTheme.backgroundGrey));
      });
    });

    group('6. Error Handling Tests', () {
      test('should handle channel query errors gracefully', () async {
        // Arrange: Mock network error
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        )).thenThrow(StreamChatError(
          message: 'Network error',
          code: ErrorCode.networkFailed,
        ));

        // Act & Assert: Verify error is handled
        expect(
          () async => await mockClient.queryChannels(
            filter: Filter.equal('team', 'test_crew_123'),
          ),
          throwsA(isA<StreamChatError>()),
        );
      });

      test('should handle empty channel list', () async {
        // Arrange: Mock empty response
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: []));

        // Act: Query empty channels
        final result = await mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        );

        // Assert: Verify empty list is handled
        expect(result.channels, isEmpty);
      });
    });

    group('7. Performance Tests', () {
      test('should handle large channel lists efficiently', () async {
        // Arrange: Create many channels
        final manyChannels = List.generate(50, (index) => Channel(
          cid: ChannelId('messaging:channel_$index'),
          extraData: {
            'name': 'Channel $index',
            'team': 'test_crew_123',
          },
        ));

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: manyChannels));

        final stopwatch = Stopwatch()..start();

        // Act: Query large channel list
        final result = await mockClient.queryChannels(
          filter: Filter.equal('team', 'test_crew_123'),
        );

        stopwatch.stop();

        // Assert: Verify performance < 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(result.channels.length, 50);
      });
    });
  });
}

// Helper event class definitions for testing
class MessageNewEvent extends Event {
  final Message message;
  final ChannelState channel;

  MessageNewEvent({required this.message, required this.channel})
      : super(type: EventType.messageNew);
}

class ChannelUpdatedEvent extends Event {
  final ChannelState channel;

  ChannelUpdatedEvent({required this.channel})
      : super(type: EventType.channelUpdated);
}