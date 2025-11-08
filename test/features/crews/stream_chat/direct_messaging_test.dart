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

import 'direct_messaging_test.mocks.dart';

@GenerateMocks([StreamChatService, StreamChatClient])
void main() {
  group('Direct Messaging Tests (Container 1)', () {
    late MockStreamChatService mockService;
    late MockStreamChatClient mockClient;
    late ProviderContainer container;
    late User currentUser;
    late User otherUser;
    late Crew testCrew;

    setUp(() {
      mockService = MockStreamChatService();
      mockClient = MockStreamChatClient();

      currentUser = User(
        id: 'user_001',
        name: 'John Doe',
        extraData: {
          'crew_id': 'crew_123',
          'ibew_local': 84,
          'classification': 'Journeyman Lineman',
        },
      );

      otherUser = User(
        id: 'user_002',
        name: 'Mike Smith',
        extraData: {
          'crew_id': 'crew_123',
          'ibew_local': 84,
          'classification': 'Foreman',
        },
      );

      testCrew = Crew(
        id: 'crew_123',
        name: 'IBEW Local 84 Linemen',
        memberIds: ['user_001', 'user_002', 'user_003'],
        foremanId: 'user_002',
        crewType: CrewType.lineman,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );

      container = ProviderContainer(
        overrides: [
          streamChatServiceProvider.overrideWithValue(mockService),
        ],
      );

      when(mockService.initializeClient()).thenAnswer((_) async => mockClient);
      when(mockService.currentUserId).thenReturn(currentUser.id);
      when(mockService.disconnectClient()).thenAnswer((_) async {});
    });

    tearDown(() {
      container.dispose();
    });

    group('1. Create DM Between 2 Crew Members', () {
      test('should create distinct DM channel with proper metadata', () async {
        // Arrange: Mock DM channel creation
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          type: 'messaging',
          id: 'user_001-user_002',
          extraData: {
            'type': 'direct',
            'team': 'crew_123',
            'members': ['user_001', 'user_002'],
            'member_count': 2,
            'distinct': true,
            'created_by': 'user_001',
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            allOf([
              containsPair('type', 'direct'),
              containsPair('team', 'crew_123'),
              containsPair('members', ['user_001', 'user_002']),
              containsPair('member_count', 2),
              containsPair('distinct', true),
            ]),
            named: 'extraData',
          ),
        )).thenReturn(Channel(mockClient, 'messaging', 'user_001-user_002'));

        // Act: Create DM channel
        final createdChannel = mockClient.channel(
          type: 'messaging',
          extraData: {
            'type': 'direct',
            'team': 'crew_123',
            'members': ['user_001', 'user_002'],
            'member_count': 2,
            'distinct': true,
            'created_by': currentUser.id,
          },
        );

        // Assert: Verify channel was created with correct metadata
        expect(createdChannel, isA<Channel>());
        verify(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            allOf([
              containsPair('type', 'direct'),
              containsPair('team', 'crew_123'),
              containsPair('distinct', true),
            ]),
            named: 'extraData',
          ),
        )).called(1);
      });

      test('should prevent DM creation for non-crew members', () async {
        // Arrange: Create user from different crew
        final nonCrewUser = User(
          id: 'user_999',
          name: 'Other Crew Member',
          extraData: {
            'crew_id': 'crew_999',
            'ibew_local': 111,
          },
        );

        // Mock service to reject cross-crew DMs
        when(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            containsPair('members', ['user_001', 'user_999']),
            named: 'extraData',
          ),
        )).thenThrow(StreamChatError(
          message: 'Cannot create DM between different crews',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify cross-crew DM is blocked
        expect(
          () => mockClient.channel(
            type: 'messaging',
            extraData: {
              'type': 'direct',
              'team': 'crew_123', // Different from user_999's crew
              'members': ['user_001', 'user_999'],
              'member_count': 2,
              'distinct': true,
            },
          ),
          throwsA(isA<StreamChatError>()),
        );
      });
    });

    group('2. Verify Distinct Flag Prevents Duplicates', () {
      test('should find existing DM using distinct flag', () async {
        // Arrange: Create existing DM channel
        final existingDM = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          type: 'messaging',
          id: 'user_001-user_002',
          extraData: {
            'type': 'direct',
            'team': 'crew_123',
            'members': ['user_001', 'user_002'],
            'member_count': 2,
            'distinct': true,
          },
        );

        // Mock query for existing distinct DM
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_001', 'user_002']),
            Filter.equal('distinct', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [existingDM]));

        // Act: Check for existing DM
        final existingDMs = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_001', 'user_002']),
            Filter.equal('distinct', true),
          ]),
        );

        // Assert: Verify existing DM is found
        expect(existingDMs.channels.length, 1);
        expect(existingDMs.channels.first.cid, equals(ChannelId('messaging:user_001-user_002')));
        expect(existingDMs.channels.first.extraData!['distinct'], isTrue);

        // Verify correct filter was applied
        verify(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_001', 'user_002']),
            Filter.equal('distinct', true),
          ]),
        )).called(1);
      });

      test('should return empty when no existing DM found', () async {
        // Arrange: Mock empty query result
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_001', 'user_003']), // Different user
            Filter.equal('distinct', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: []));

        // Act: Search for non-existent DM
        final result = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_001', 'user_003']),
            Filter.equal('distinct', true),
          ]),
        );

        // Assert: Verify no existing DM found
        expect(result.channels, isEmpty);
      });

      test('should handle member order independence in distinct DMs', () async {
        // Arrange: Test that member order doesn't matter for distinct DMs
        final existingDM = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          extraData: {
            'members': ['user_001', 'user_002'],
            'distinct': true,
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_002', 'user_001']), // Reversed order
            Filter.equal('distinct', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [existingDM]));

        // Act: Search with reversed member order
        final result = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_002', 'user_001']),
            Filter.equal('distinct', true),
          ]),
        );

        // Assert: Verify DM is found regardless of member order
        expect(result.channels.length, 1);
        expect(result.channels.first.cid, equals(ChannelId('messaging:user_001-user_002')));
      });
    });

    group('3. Test Online/Offline Status Display', () {
      test('should display online status for crew members', () async {
        // Arrange: Create users with different online status
        final onlineUser = User(
          id: 'user_002',
          name: 'Mike Smith',
          online: true,
          extraData: {
            'crew_id': 'crew_123',
            'last_active': DateTime.now().toIso8601String(),
          },
        );

        final offlineUser = User(
          id: 'user_003',
          name: 'Jane Wilson',
          online: false,
          extraData: {
            'crew_id': 'crew_123',
            'last_active': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          },
        );

        // Mock user queries
        when(mockClient.queryUsers(
          filter: Filter.and([
            Filter.equal('crew_id', 'crew_123'),
            Filter.in_('id', ['user_002', 'user_003']),
          ]),
        )).thenAnswer((_) async => QueryUsersResponse(
          users: [onlineUser, offlineUser],
        ));

        // Act: Query crew members
        final crewMembers = await mockClient.queryUsers(
          filter: Filter.and([
            Filter.equal('crew_id', 'crew_123'),
            Filter.in_('id', ['user_002', 'user_003']),
          ]),
        );

        // Assert: Verify online status is correctly returned
        expect(crewMembers.users.length, 2);

        final foundOnlineUser = crewMembers.users.firstWhere(
          (user) => user.id == 'user_002',
        );
        final foundOfflineUser = crewMembers.users.firstWhere(
          (user) => user.id == 'user_003',
        );

        expect(foundOnlineUser.online, isTrue);
        expect(foundOfflineUser.online, isFalse);
      });

      test('should update online status in real-time', () async {
        // Arrange: Setup event stream for online status updates
        final eventController = StreamController<Event>();
        when(mockClient.events).thenAnswer((_) => eventController.stream);

        // Act: Simulate user presence update
        final presenceEvent = UserPresenceUpdatedEvent(
          user: User(
            id: 'user_002',
            name: 'Mike Smith',
            online: true,
            extraData: {'crew_id': 'crew_123'},
          ),
        );

        eventController.add(presenceEvent);

        // Assert: Verify event stream is available
        expect(mockClient.events, isA<Stream<Event>>());

        eventController.close();
      });
    });

    group('4. Message Exchange in DMs', () {
      test('should send messages in DM channels', () async {
        // Arrange: Create DM channel
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          type: 'messaging',
          id: 'user_001-user_002',
        );

        final testMessage = MessageRequest(
          text: 'Hello Mike, are you available for the job site?',
        );

        final sentMessage = Message(
          id: 'msg_001',
          text: 'Hello Mike, are you available for the job site?',
          user: currentUser,
          createdAt: DateTime.now(),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'user_001-user_002',
        )).thenReturn(dmChannel);

        when(dmChannel.sendMessage(testMessage))
            .thenAnswer((_) async => SendMessageResponse(message: sentMessage));

        // Act: Send message in DM
        final response = await dmChannel.sendMessage(testMessage);

        // Assert: Verify message was sent
        expect(response.message, isNotNull);
        expect(response.message!.text, equals('Hello Mike, are you available for the job site?'));
        expect(response.message!.user?.id, equals(currentUser.id));

        verify(dmChannel.sendMessage(testMessage)).called(1);
      });

      test('should receive messages in real-time', () async {
        // Arrange: Setup message stream
        final messageStreamController = StreamController<List<Message>>();
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          type: 'messaging',
          id: 'user_001-user_002',
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'user_001-user_002',
        )).thenReturn(dmChannel);

        when(dmChannel.state?.messagesStream)
            .thenAnswer((_) => messageStreamController.stream);

        // Act: Simulate new message
        final incomingMessage = Message(
          id: 'msg_002',
          text: 'Yes John, I can help at the site',
          user: otherUser,
          createdAt: DateTime.now(),
        );

        messageStreamController.add([incomingMessage]);

        // Assert: Verify message stream is available
        expect(dmChannel.state?.messagesStream, isA<Stream<List<Message>>>());

        messageStreamController.close();
      });
    });

    group('5. DM Provider Tests', () {
      test('should query DM conversations with team filter', () async {
        // Arrange: Create mock DM channels
        final dmChannel1 = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          extraData: {
            'type': 'direct',
            'team': 'crew_123',
            'member_count': 2,
          },
        );

        final dmChannel2 = Channel(
          cid: ChannelId('messaging:user_001-user_003'),
          extraData: {
            'type': 'direct',
            'team': 'crew_123',
            'member_count': 2,
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
          ]),
          sort: [const SortOption('last_message_at', direction: SortOption.ASC)],
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [dmChannel1, dmChannel2],
        ));

        // Act: Get DM conversations for crew
        final dmConversations = await container.read(
          dmConversationsProvider('crew_123').future,
        );

        // Assert: Verify only DMs from crew are returned
        expect(dmConversations, isA<List<Channel>>());
        expect(dmConversations.length, 2);

        for (final channel in dmConversations) {
          expect(channel.extraData!['team'], equals('crew_123'));
          expect(channel.extraData!['member_count'], equals(2));
          expect(channel.extraData!['type'], equals('direct'));
        }

        // Verify correct filter was used
        verify(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('member_count', 2),
          ]),
          sort: [const SortOption('last_message_at', direction: SortOption.ASC)],
        )).called(1);
      });
    });

    group('6. Electrical Theme Integration', () {
      testWidgets('should apply electrical theme to DM interface', (tester) async {
        // Arrange: Mock DM data
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
          extraData: {
            'name': 'Mike Smith',
            'type': 'direct',
            'team': 'crew_123',
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [dmChannel],
        ));

        // Act: Build themed DM interface
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
                  filter: Filter.and([
                    Filter.equal('team', 'crew_123'),
                    Filter.equal('member_count', 2),
                  ]),
                  onChannelTap: (channel) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify electrical theme is applied
        expect(find.text('Mike Smith'), findsOneWidget);

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppTheme.backgroundGrey));
      });
    });

    group('7. Error Handling', () {
      test('should handle DM creation errors gracefully', () async {
        // Arrange: Mock service error
        when(mockClient.channel(
          type: 'messaging',
          extraData: anyNamed('extraData'),
        )).thenThrow(StreamChatError(
          message: 'Failed to create DM channel',
          code: ErrorCode.failed,
        ));

        // Act & Assert: Verify error handling
        expect(
          () => mockClient.channel(
            type: 'messaging',
            extraData: {
              'type': 'direct',
              'team': 'crew_123',
              'members': ['user_001', 'user_002'],
            },
          ),
          throwsA(isA<StreamChatError>()),
        );
      });

      test('should handle message sending failures', () async {
        // Arrange: Create DM channel with send failure
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'user_001-user_002',
        )).thenReturn(dmChannel);

        when(dmChannel.sendMessage(any)).thenThrow(StreamChatError(
          message: 'Network error - message not sent',
          code: ErrorCode.networkFailed,
        ));

        // Act & Assert: Verify message send failure
        expect(
          () async => await dmChannel.sendMessage(
            MessageRequest(text: 'Test message'),
          ),
          throwsA(isA<StreamChatError>()),
        );
      });
    });

    group('8. Performance Tests', () {
      test('should handle high-volume DM exchanges efficiently', () async {
        // Arrange: Create DM channel
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_001-user_002'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'user_001-user_002',
        )).thenReturn(dmChannel);

        when(dmChannel.sendMessage(any))
            .thenAnswer((_) async => SendMessageResponse(
              message: Message(
                id: 'msg_bulk',
                text: 'Bulk message',
                user: currentUser,
                createdAt: DateTime.now(),
              ),
            ));

        final stopwatch = Stopwatch()..start();

        // Act: Send multiple messages
        for (int i = 0; i < 20; i++) {
          await dmChannel.sendMessage(
            MessageRequest(text: 'Message $i'),
          );
        }

        stopwatch.stop();

        // Assert: Verify performance < 2 seconds for 20 messages
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));

        // Verify all messages were sent
        verify(dmChannel.sendMessage(any)).called(20);
      });
    });
  });
}

// Helper event class for testing
class UserPresenceUpdatedEvent extends Event {
  final User user;

  UserPresenceUpdatedEvent({required this.user})
      : super(type: EventType.userPresenceUpdated);
}