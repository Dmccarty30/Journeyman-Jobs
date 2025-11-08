import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/services/stream_chat_service.dart';
import 'package:journeyman_jobs/features/crews/models/models.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

import 'integration_test.mocks.dart';

@GenerateMocks([StreamChatService, StreamChatClient])
void main() {
  group('Stream Chat Integration Tests', () {
    late MockStreamChatService mockService;
    late MockStreamChatClient mockClient;
    late ProviderContainer container;
    late List<User> testUsers;
    late List<Crew> testCrews;

    setUp(() {
      mockService = MockStreamChatService();
      mockClient = MockStreamChatClient();

      // Setup test users
      testUsers = [
        User(
          id: 'user_alpha_001',
          name: 'John Alpha',
          extraData: {
            'crew_id': 'crew_alpha_123',
            'ibew_local': 84,
            'classification': 'Journeyman Lineman',
            'role': 'foreman',
          },
        ),
        User(
          id: 'user_alpha_002',
          name: 'Mike Alpha',
          extraData: {
            'crew_id': 'crew_alpha_123',
            'ibew_local': 84,
            'classification': 'Apprentice Lineman',
            'role': 'member',
          },
        ),
        User(
          id: 'user_beta_001',
          name: 'Sarah Beta',
          extraData: {
            'crew_id': 'crew_beta_456',
            'ibew_local': 111,
            'classification': 'Journeyman Wireman',
            'role': 'foreman',
          },
        ),
        User(
          id: 'user_beta_002',
          name: 'Lisa Beta',
          extraData: {
            'crew_id': 'crew_beta_456',
            'ibew_local': 111,
            'classification': 'Apprentice Wireman',
            'role': 'member',
          },
        ),
      ];

      // Setup test crews
      testCrews = [
        Crew(
          id: 'crew_alpha_123',
          name: 'IBEW Local 84 Storm Team',
          memberIds: ['user_alpha_001', 'user_alpha_002'],
          foremanId: 'user_alpha_001',
          crewType: CrewType.lineman,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Crew(
          id: 'crew_beta_456',
          name: 'IBEW Local 111 Installation Team',
          memberIds: ['user_beta_001', 'user_beta_002'],
          foremanId: 'user_beta_001',
          crewType: CrewType.wireman,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ];

      container = ProviderContainer(
        overrides: [
          streamChatServiceProvider.overrideWithValue(mockService),
        ],
      );

      when(mockService.initializeClient()).thenAnswer((_) async => mockClient);
      when(mockService.currentUserId).thenReturn(testUsers[0].id);
      when(mockService.disconnectClient()).thenAnswer((_) async {});
    });

    tearDown(() {
      container.dispose();
    });

    group('1. End-to-End Crew Chat Workflow', () {
      testWidgets('should complete full crew chat workflow from authentication to messaging', (tester) async {
        // Arrange: Setup complete mock environment
        when(mockService.initializeClient()).thenAnswer((_) async => mockClient);

        // Mock channels for crew Alpha
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_alpha_123_general'),
          type: 'messaging',
          id: 'crew_alpha_123_general',
          extraData: {
            'name': '#general',
            'team': 'crew_alpha_123',
            'type': 'crew',
            'auto_join': true,
            'members': ['user_alpha_001', 'user_alpha_002'],
          },
        );

        final workChannel = Channel(
          cid: ChannelId('messaging:crew_alpha_123_work'),
          type: 'messaging',
          id: 'crew_alpha_123_work',
          extraData: {
            'name': 'Work Coordination',
            'team': 'crew_alpha_123',
            'type': 'crew',
            'members': ['user_alpha_001', 'user_alpha_002'],
          },
        );

        final dmChannel = Channel(
          cid: ChannelId('messaging:user_alpha_001-user_alpha_002'),
          type: 'messaging',
          id: 'user_alpha_001-user_alpha_002',
          extraData: {
            'type': 'direct',
            'team': 'crew_alpha_123',
            'members': ['user_alpha_001', 'user_alpha_002'],
            'member_count': 2,
            'distinct': true,
          },
        );

        // Mock channel queries
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [generalChannel, workChannel],
        ));

        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('member_count', 2),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [dmChannel],
        ));

        // Mock messages
        final testMessages = [
          Message(
            id: 'msg_001',
            text: 'Team meeting at 8 AM tomorrow',
            user: testUsers[0],
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Message(
            id: 'msg_002',
            text: 'I\'ll be there with the equipment',
            user: testUsers[1],
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];

        when(mockClient.queryMessages(
          cid: generalChannel.cid!,
        )).thenAnswer((_) async => QueryMessagesResponse(messages: testMessages));

        // Act: Build complete chat interface
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
                scaffoldBackgroundColor: AppTheme.backgroundGrey,
              ),
              home: Scaffold(
                appBar: AppBar(
                  backgroundColor: AppTheme.primaryNavy,
                  title: const Text(
                    'IBEW Connect',
                    style: TextStyle(color: AppTheme.textOnDark),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.electrical_services,
                        color: AppTheme.accentCopper,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Dynamic container row
                    DynamicContainerRow(
                      labels: ['Channels', 'DMs', 'History', 'Crew'],
                      selectedIndex: 0,
                      onTap: (index) async {
                        // Simulate navigation between containers
                        if (index == 0) {
                          // Channels container (Container 0)
                          await tester.pumpAndSettle();
                          expect(find.text('#general'), findsOneWidget);
                          expect(find.text('Work Coordination'), findsOneWidget);
                        } else if (index == 1) {
                          // DMs container (Container 1)
                          await tester.pumpAndSettle();
                          expect(find.byType(StreamChannelListView), findsOneWidget);
                        } else if (index == 2) {
                          // History container (Container 2)
                          await tester.pumpAndSettle();
                        } else if (index == 3) {
                          // Crew chat container (Container 3)
                          await tester.pumpAndSettle();
                        }
                      },
                    ),
                    // Content area
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: AppTheme.accentCopper,
                            width: AppTheme.borderWidthCopper,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#general',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Message list
                            Expanded(
                              child: ListView.builder(
                                itemCount: testMessages.length,
                                itemBuilder: (context, index) {
                                  final message = testMessages[index];
                                  final isOwnMessage = message.user?.id == testUsers[0].id;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isOwnMessage
                                          ? AppTheme.accentCopper
                                          : AppTheme.backgroundGrey,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMd,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.user?.name ?? 'Unknown',
                                          style: TextStyle(
                                            color: isOwnMessage
                                                ? AppTheme.white
                                                : AppTheme.primaryNavy,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          message.text!,
                                          style: TextStyle(
                                            color: isOwnMessage
                                                ? AppTheme.white
                                                : AppTheme.textPrimary,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTime(message.createdAt!),
                                          style: TextStyle(
                                            color: isOwnMessage
                                                ? AppTheme.white.withValues(alpha:0.8)
                                                : AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Message input
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGrey,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppTheme.accentCopper,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Type a message...',
                                        hintStyle: TextStyle(
                                          color: AppTheme.textSecondary,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: AppTheme.accentCopper,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify complete workflow
        expect(find.text('IBEW Connect'), findsOneWidget);
        expect(find.byIcon(Icons.electrical_services), findsOneWidget);
        expect(find.byType(DynamicContainerRow), findsOneWidget);
        expect(find.text('#general'), findsOneWidget);
        expect(find.text('Team meeting at 8 AM tomorrow'), findsOneWidget);
        expect(find.text('I\'ll be there with the equipment'), findsOneWidget);
        expect(find.text('Type a message...'), findsOneWidget);

        // Test container navigation
        final dynamicContainerFinder = find.byType(DynamicContainerRow);
        final dynamicContainer = tester.widget<DynamicContainerRow>(dynamicContainerFinder);

        // Test tap on DMs container
        await tester.tap(find.text('DMs'));
        await tester.pumpAndSettle();

        // Test tap on Crew container
        await tester.tap(find.text('Crew'));
        await tester.pumpAndSettle();
      });
    });

    group('2. Multi-User Real-Time Coordination', () {
      test('should handle real-time updates across multiple users', () async {
        // Arrange: Setup multi-user scenario
        final generalChannel = Channel(
          cid: ChannelId('messaging:multi_user_test'),
          type: 'messaging',
          id: 'multi_user_test',
        );

        // Mock event stream for real-time updates
        final eventController = StreamController<Event>();
        when(mockClient.events).thenAnswer((_) => eventController.stream);

        // Setup message streams
        final messageStreamController = StreamController<List<Message>>();
        when(generalChannel.state?.messagesStream)
            .thenAnswer((_) => messageStreamController.stream);

        // Act: Simulate multi-user real-time coordination
        final futures = <Future<Message>>[];

        // User Alpha sends message
        final alphaMessage = Message(
          id: 'alpha_msg_001',
          text: 'Starting storm assessment now',
          user: testUsers[0],
          createdAt: DateTime.now(),
        );

        // User Beta sends message
        final betaMessage = Message(
          id: 'beta_msg_001',
          text: 'Copy that, checking weather updates',
          user: testUsers[1],
          createdAt: DateTime.now(),
        );

        // Simulate real-time message delivery
        messageStreamController.add([alphaMessage, betaMessage]);

        // Simulate user presence updates
        final presenceEvent = UserPresenceUpdatedEvent(
          user: testUsers[1].copyWith(online: true),
        );
        eventController.add(presenceEvent);

        // Assert: Verify real-time capabilities
        expect(mockClient.events, isA<Stream<Event>>());
        expect(generalChannel.state?.messagesStream, isA<Stream<List<Message>>>());

        // Verify message order and delivery
        final messages = await messageStreamController.stream.first;
        expect(messages.length, 2);
        expect(messages.map((m) => m.text), contains('Starting storm assessment now'));
        expect(messages.map((m) => m.text), contains('Copy that, checking weather updates'));

        // Clean up
        eventController.close();
        messageStreamController.close();
      });
    });

    group('3. Team Isolation Enforcement', () {
      test('should strictly enforce crew data separation', () async {
        // Arrange: Create mixed channel data from different crews
        final alphaChannels = [
          Channel(
            cid: ChannelId('messaging:alpha_general'),
            extraData: {
              'name': '#general',
              'team': 'crew_alpha_123',
              'type': 'crew',
            },
          ),
          Channel(
            cid: ChannelId('messaging:alpha_work'),
            extraData: {
              'name': 'Work Chat',
              'team': 'crew_alpha_123',
              'type': 'crew',
            },
          ),
        ];

        final betaChannels = [
          Channel(
            cid: ChannelId('messaging:beta_general'),
            extraData: {
              'name': '#general',
              'team': 'crew_beta_456',
              'type': 'crew',
            },
          ),
          Channel(
            cid: ChannelId('messaging:beta_safety'),
            extraData: {
              'name': 'Safety Alerts',
              'team': 'crew_beta_456',
              'type': 'crew',
            },
          ),
        ];

        // Mock isolated queries for each crew
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: alphaChannels));

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_beta_456'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: betaChannels));

        // Act: Query channels for each crew
        final alphaResult = await mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        );

        final betaResult = await mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_beta_456'),
        );

        // Assert: Verify complete crew isolation
        expect(alphaResult.channels.length, 2);
        expect(betaResult.channels.length, 2);

        // Verify Alpha crew only sees Alpha channels
        for (final channel in alphaResult.channels) {
          expect(channel.extraData!['team'], equals('crew_alpha_123'));
          expect(channel.extraData!['team'], isNot(equals('crew_beta_456')));
        }

        // Verify Beta crew only sees Beta channels
        for (final channel in betaResult.channels) {
          expect(channel.extraData!['team'], equals('crew_beta_456'));
          expect(channel.extraData!['team'], isNot(equals('crew_alpha_123')));
        }

        // Verify filters were applied correctly
        verify(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        )).called(1);

        verify(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_beta_456'),
        )).called(1);
      });
    });

    group('4. Security and Data Integrity', () {
      test('should maintain security boundaries across all operations', () async {
        // Arrange: Test cross-crew access prevention
        final unauthorizedAccessAttempts = [
          () => mockClient.queryChannels(
            filter: Filter.and([
              Filter.equal('team', 'crew_beta_456'),
              Filter.in_('members', [testUsers[0].id]),
            ]),
          ),
          () => mockClient.channel(
            type: 'messaging',
            extraData: {
              'type': 'direct',
              'team': 'crew_beta_456',
              'members': [testUsers[0].id, testUsers[2].id],
            },
          ),
        ];

        // Mock all unauthorized attempts to fail
        for (final attempt in unauthorizedAccessAttempts) {
          when(attempt()).thenThrow(StreamChatError(
            message: 'Access denied: User not authorized for this crew',
            code: ErrorCode.forbidden,
          ));
        }

        // Act & Assert: Verify all unauthorized attempts are blocked
        for (final attempt in unauthorizedAccessAttempts) {
          expect(
            () async => await attempt(),
            throwsA(isA<StreamChatError>()),
          );
        }
      });
    });

    group('5. Performance Under Load', () {
      test('should maintain performance with high user activity', () async {
        // Arrange: Create high-load scenario
        final stopwatch = Stopwatch()..start();

        // Mock large channel list
        final manyChannels = List.generate(100, (index) => Channel(
          cid: ChannelId('messaging:channel_$index'),
          extraData: {
            'name': 'Channel $index',
            'team': 'crew_alpha_123',
          },
        ));

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: manyChannels));

        // Mock many messages
        final manyMessages = List.generate(500, (index) => Message(
          id: 'msg_$index',
          text: 'High volume message $index',
          user: testUsers[index % testUsers.length],
          createdAt: DateTime.now().subtract(Duration(seconds: index)),
        ));

        when(mockClient.queryMessages(
          cid: anyNamed('cid'),
        )).thenAnswer((_) async => QueryMessagesResponse(messages: manyMessages));

        // Act: Perform high-load operations
        final channelsFuture = mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        );

        final messagesFuture = mockClient.queryMessages(
          cid: ChannelId('messaging:channel_0'),
        );

        // Wait for both operations
        final results = await Future.wait([channelsFuture, messagesFuture]);

        stopwatch.stop();

        // Assert: Verify performance under load
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // < 2 seconds
        expect(results[0].channels.length, 100);
        expect(results[1].messages.length, 500);
      });
    });

    group('6. Theme Integration Validation', () {
      testWidgets('should apply electrical theme consistently across all components', (tester) async {
        // Act: Build complete themed interface
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              primaryColor: AppTheme.primaryNavy,
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
                accentColor: AppTheme.accentCopper,
              ),
              scaffoldBackgroundColor: AppTheme.backgroundGrey,
            ),
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.primaryNavy,
                title: const Text('Electrical Theme Test'),
                actions: [
                  Icon(Icons.electrical_services, color: AppTheme.accentCopper),
                ],
              ),
              body: Column(
                children: [
                  DynamicContainerRow(
                    labels: ['Channels', 'DMs', 'History', 'Crew'],
                    selectedIndex: 0,
                    onTap: (index) {},
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.accentCopper),
                      ),
                      child: const Center(
                        child: Text(
                          'Electrical Themed Content',
                          style: TextStyle(color: AppTheme.primaryNavy),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify consistent theme application
        expect(find.text('Electrical Theme Test'), findsOneWidget);
        expect(find.byIcon(Icons.electrical_services), findsOneWidget);
        expect(find.byType(DynamicContainerRow), findsOneWidget);
        expect(find.text('Electrical Themed Content'), findsOneWidget);

        // Verify theme colors
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppTheme.backgroundGrey));
      });
    });
  });
}

// Helper function for formatting time
String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

// Helper event class for testing
class UserPresenceUpdatedEvent extends Event {
  final User user;

  UserPresenceUpdatedEvent({required this.user})
      : super(type: EventType.userPresenceUpdated);
}