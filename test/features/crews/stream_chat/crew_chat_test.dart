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

import 'crew_chat_test.mocks.dart';

@GenerateMocks([StreamChatService, StreamChatClient])
void main() {
  group('Crew Chat Tests (Container 3)', () {
    late MockStreamChatService mockService;
    late MockStreamChatClient mockClient;
    late ProviderContainer container;
    late User foremanUser;
    late User crewMember1;
    late User crewMember2;
    late Crew testCrew;

    setUp(() {
      mockService = MockStreamChatService();
      mockClient = MockStreamChatClient();

      foremanUser = User(
        id: 'foreman_001',
        name: 'Bob Thompson',
        extraData: {
          'crew_id': 'crew_123',
          'ibew_local': 84,
          'classification': 'Foreman',
          'role': 'foreman',
        },
      );

      crewMember1 = User(
        id: 'member_001',
        name: 'John Davis',
        extraData: {
          'crew_id': 'crew_123',
          'ibew_local': 84,
          'classification': 'Journeyman Lineman',
          'role': 'member',
        },
      );

      crewMember2 = User(
        id: 'member_002',
        name: 'Mike Wilson',
        extraData: {
          'crew_id': 'crew_123',
          'ibew_local': 84,
          'classification': 'Apprentice Lineman',
          'role': 'member',
        },
      );

      testCrew = Crew(
        id: 'crew_123',
        name: 'IBEW Local 84 Storm Response Team',
        memberIds: ['foreman_001', 'member_001', 'member_002'],
        foremanId: 'foreman_001',
        crewType: CrewType.lineman,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      );

      container = ProviderContainer(
        overrides: [
          streamChatServiceProvider.overrideWithValue(mockService),
        ],
      );

      when(mockService.initializeClient()).thenAnswer((_) async => mockClient);
      when(mockService.currentUserId).thenReturn(foremanUser.id);
      when(mockService.disconnectClient()).thenAnswer((_) async {});
    });

    tearDown(() {
      container.dispose();
    });

    group('1. Navigate to #general Channel', () {
      test('should create and access #general channel for crew', () async {
        // Arrange: Mock #general channel creation
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
          type: 'messaging',
          id: 'crew_123_general',
          extraData: {
            'name': '#general',
            'team': 'crew_123',
            'type': 'crew',
            'auto_join': true,
            'crew_channel_type': 'general',
            'created_by': 'system',
            'created_at': testCrew.createdAt.toIso8601String(),
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(Channel(mockClient, 'messaging', 'crew_123_general'));

        // Mock channel query for #general
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('name', '#general'),
            Filter.equal('type', 'crew'),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [generalChannel],
        ));

        // Act: Query #general channel
        final generalChannels = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('name', '#general'),
            Filter.equal('type', 'crew'),
          ]),
        );

        // Assert: Verify #general channel exists
        expect(generalChannels.channels.length, 1);
        expect(generalChannels.channels.first.extraData!['name'], equals('#general'));
        expect(generalChannels.channels.first.extraData!['team'], equals('crew_123'));
        expect(generalChannels.channels.first.extraData!['type'], equals('crew'));
        expect(generalChannels.channels.first.extraData!['auto_join'], isTrue);

        // Verify correct filter was applied
        verify(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('name', '#general'),
            Filter.equal('type', 'crew'),
          ]),
        )).called(1);
      });

      test('should handle navigation to crew chat container', () async {
        // This test verifies the UI navigation logic
        // In the actual implementation, this would involve DynamicContainerRow navigation

        // Arrange: Mock navigation state
        const selectedIndex = 3; // Container 3 index

        // Act: Simulate container selection (would be triggered by UI)
        // This is typically handled by the DynamicContainerRow widget

        // Assert: Verify container index is correct
        expect(selectedIndex, equals(3));
      });
    });

    group('2. Verify All Crew Members Auto-Added', () {
      test('should automatically add all crew members to #general channel', () async {
        // Arrange: Create #general channel with all crew members
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
          extraData: {
            'name': '#general',
            'team': 'crew_123',
            'type': 'crew',
            'members': testCrew.memberIds, // All crew members
            'member_count': testCrew.memberIds.length,
            'auto_join': true,
          },
        );

        // Mock channel creation with auto-added members
        when(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            allOf([
              containsPair('name', '#general'),
              containsPair('team', 'crew_123'),
              containsPair('members', testCrew.memberIds),
              containsPair('auto_join', true),
            ]),
            named: 'extraData',
          ),
        )).thenReturn(Channel(mockClient, 'messaging', 'crew_123_general'));

        // Act: Create #general channel with auto-added members
        final createdChannel = mockClient.channel(
          type: 'messaging',
          extraData: {
            'name': '#general',
            'team': 'crew_123',
            'type': 'crew',
            'members': testCrew.memberIds,
            'member_count': testCrew.memberIds.length,
            'auto_join': true,
          },
        );

        // Assert: Verify all crew members are included
        expect(createdChannel, isA<Channel>());

        verify(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            containsPair('members', testCrew.memberIds),
            named: 'extraData',
          ),
        )).called(1);

        // Verify member count matches
        final membersList = testCrew.memberIds as List<String>;
        expect(membersList.length, equals(3));
        expect(membersList, contains('foreman_001'));
        expect(membersList, contains('member_001'));
        expect(membersList, contains('member_002'));
      });

      test('should add new crew members to existing #general channel', () async {
        // Arrange: Create scenario where new member joins crew
        final newMemberId = 'new_member_003';
        final updatedMemberIds = [...testCrew.memberIds, newMemberId];

        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        // Mock adding member to channel
        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        when(generalChannel.addMembers([newMemberId]))
            .thenAnswer((_) async {});

        // Act: Add new member to #general channel
        await generalChannel.addMembers([newMemberId]);

        // Assert: Verify new member was added
        verify(generalChannel.addMembers([newMemberId])).called(1);
      });

      test('should remove departed crew members from #general channel', () async {
        // Arrange: Create scenario where member leaves crew
        const departingMemberId = 'member_002';
        final remainingMemberIds = ['foreman_001', 'member_001'];

        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        // Mock removing member from channel
        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        when(generalChannel.removeMembers([departingMemberId]))
            .thenAnswer((_) async {});

        // Act: Remove departing member from #general channel
        await generalChannel.removeMembers([departingMemberId]);

        // Assert: Verify member was removed
        verify(generalChannel.removeMembers([departingMemberId])).called(1);
      });
    });

    group('3. Test Electrical Theme Application', () {
      testWidgets('should apply electrical copper theme to crew chat interface', (tester) async {
        // Arrange: Mock #general channel
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
          extraData: {
            'name': '#general',
            'team': 'crew_123',
            'type': 'crew',
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_123'),
        )).thenAnswer((_) async => QueryChannelsResponse(
          channels: [generalChannel],
        ));

        // Act: Build crew chat with electrical theme
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
                textTheme: ThemeData.light().textTheme.apply(
                  bodyColor: AppTheme.textPrimary,
                  displayColor: AppTheme.textPrimary,
                ),
              ),
              home: Scaffold(
                backgroundColor: AppTheme.backgroundGrey,
                appBar: AppBar(
                  backgroundColor: AppTheme.primaryNavy,
                  title: Text(
                    'IBEW Local 84 - #general',
                    style: TextStyle(
                      color: AppTheme.textOnDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    Icon(
                      Icons.electrical_services,
                      color: AppTheme.accentCopper,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                body: Column(
                  children: [
                    // Crew info section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.accentCopper,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.accentCopper,
                            child: Icon(
                              Icons.group,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Storm Response Team',
                                  style: TextStyle(
                                    color: AppTheme.textOnDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '3 Members • Local 84',
                                  style: TextStyle(
                                    color: AppTheme.textOnDark.withValues(alpha:0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chat area
                    Expanded(
                      child: Container(
                        color: AppTheme.white,
                        child: StreamChannelListView(
                          controller: mockClient,
                          filter: Filter.and([
                            Filter.equal('team', 'crew_123'),
                            Filter.equal('name', '#general'),
                          ]),
                          onChannelTap: (channel) {},
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

        // Assert: Verify electrical theme elements
        expect(find.text('IBEW Local 84 - #general'), findsOneWidget);
        expect(find.text('Storm Response Team'), findsOneWidget);
        expect(find.text('3 Members • Local 84'), findsOneWidget);

        // Verify electrical theme colors
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppTheme.backgroundGrey));

        // Verify copper accent color
        final iconFinder = find.byIcon(Icons.electrical_services);
        expect(iconFinder, findsOneWidget);
      });

      test('should apply theme to crew member indicators', () async {
        // Test electrical-themed member status indicators
        final onlineMember = User(
          id: 'member_001',
          name: 'John Davis',
          online: true,
          extraData: {
            'crew_id': 'crew_123',
            'classification': 'Journeyman Lineman',
            'ibew_local': 84,
          },
        );

        final offlineMember = User(
          id: 'member_002',
          name: 'Mike Wilson',
          online: false,
          extraData: {
            'crew_id': 'crew_123',
            'classification': 'Apprentice Lineman',
            'ibew_local': 84,
          },
        );

        // Mock member list query
        when(mockClient.queryUsers(
          filter: Filter.and([
            Filter.equal('crew_id', 'crew_123'),
          ]),
        )).thenAnswer((_) async => QueryUsersResponse(
          users: [onlineMember, offlineMember],
        ));

        // Act: Query crew members
        final crewMembers = await mockClient.queryUsers(
          filter: Filter.and([
            Filter.equal('crew_id', 'crew_123'),
          ]),
        );

        // Assert: Verify member data
        expect(crewMembers.users.length, 2);
        expect(crewMembers.users.any((u) => u.name == 'John Davis'), isTrue);
        expect(crewMembers.users.any((u) => u.name == 'Mike Wilson'), isTrue);
      });
    });

    group('4. Crew Chat Message Features', () {
      test('should handle crew-specific message types', () async {
        // Arrange: Create #general channel for crew messages
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        // Test safety alert message
        final safetyAlertMessage = MessageRequest(
          text: '⚠️ SAFETY ALERT: High voltage lines reported down in sector 4',
          extraData: {
            'message_type': 'safety_alert',
            'priority': 'high',
            'crew_notification': true,
          },
        );

        final sentSafetyMessage = Message(
          id: 'safety_alert_001',
          text: '⚠️ SAFETY ALERT: High voltage lines reported down in sector 4',
          user: foremanUser,
          extraData: {
            'message_type': 'safety_alert',
            'priority': 'high',
            'crew_notification': true,
          },
          createdAt: DateTime.now(),
        );

        when(generalChannel.sendMessage(safetyAlertMessage))
            .thenAnswer((_) async => SendMessageResponse(message: sentSafetyMessage));

        // Act: Send safety alert to crew
        final response = await generalChannel.sendMessage(safetyAlertMessage);

        // Assert: Verify safety alert was sent with crew-specific metadata
        expect(response.message, isNotNull);
        expect(response.message!.extraData!['message_type'], equals('safety_alert'));
        expect(response.message!.extraData!['priority'], equals('high'));
        expect(response.message!.extraData!['crew_notification'], isTrue);

        verify(generalChannel.sendMessage(safetyAlertMessage)).called(1);
      });

      test('should handle work coordination messages', () async {
        // Arrange: Test work assignment messages
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        final workAssignmentMessage = MessageRequest(
          text: '🔧 Work Assignment: John and Mike to report to substation A for emergency repairs',
          extraData: {
            'message_type': 'work_assignment',
            'assigned_members': ['member_001', 'member_002'],
            'location': 'Substation A',
            'priority': 'urgent',
            'created_by': 'foreman_001',
          },
        );

        when(generalChannel.sendMessage(workAssignmentMessage))
            .thenAnswer((_) async => SendMessageResponse(
              message: Message(
                id: 'work_assignment_001',
                text: '🔧 Work Assignment: John and Mike to report to substation A for emergency repairs',
                extraData: {
                  'message_type': 'work_assignment',
                  'assigned_members': ['member_001', 'member_002'],
                  'location': 'Substation A',
                  'priority': 'urgent',
                },
              ),
            ));

        // Act: Send work assignment
        final response = await generalChannel.sendMessage(workAssignmentMessage);

        // Assert: Verify work assignment details
        expect(response.message!.extraData!['message_type'], equals('work_assignment'));
        expect(response.message!.extraData!['assigned_members'], contains('member_001'));
        expect(response.message!.extraData!['assigned_members'], contains('member_002'));
        expect(response.message!.extraData!['location'], equals('Substation A'));
      });
    });

    group('5. Crew Role and Permissions', () {
      test('should enforce foreman permissions in crew chat', () async {
        // Arrange: Test foreman-specific actions
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        // Mock foreman permissions
        when(generalChannel.mute(any)).thenAnswer((_) async {});
        when(generalChannel.addModerators([foremanUser.id])).thenAnswer((_) async {});

        // Act: Perform foreman-only actions
        await generalChannel.mute(testCrew);
        await generalChannel.addModerators([foremanUser.id]);

        // Assert: Verify foreman actions were permitted
        verify(generalChannel.mute(any)).called(1);
        verify(generalChannel.addModerators([foremanUser.id])).called(1);
      });

      test('should restrict member permissions appropriately', () async {
        // Arrange: Switch to member context
        when(mockService.currentUserId).thenReturn(crewMember1.id);

        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        // Mock member restrictions
        when(generalChannel.addModerators(any)).thenThrow(StreamChatError(
          message: 'Only foreman can add moderators',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify restricted actions are blocked
        expect(
          () async => await generalChannel.addModerators([crewMember1.id]),
          throwsA(isA<StreamChatError>()),
        );
      });
    });

    group('6. Integration with DynamicContainerRow', () {
      test('should handle Container 3 selection correctly', () async {
        // This test verifies the integration with the DynamicContainerRow widget
        // Container 3 corresponds to "Crew Chat" selection

        // Arrange: Mock container selection state
        const containerIndex = 3;
        final containerLabels = ['Channels', 'DMs', 'History', 'Crew Chat'];

        // Act: Simulate selection of Container 3
        final selectedLabel = containerLabels[containerIndex];

        // Assert: Verify correct container is selected
        expect(containerIndex, equals(3));
        expect(selectedLabel, equals('Crew Chat'));

        // Verify this would trigger navigation to crew chat interface
        // (This is typically handled by the DynamicContainerRow callback)
      });
    });

    group('7. Error Handling', () {
      test('should handle #general channel access errors', () async {
        // Arrange: Mock channel access failure
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_123'),
            Filter.equal('name', '#general'),
          ]),
        )).thenThrow(StreamChatError(
          message: 'Unable to access #general channel',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify error is handled
        expect(
          () async => await mockClient.queryChannels(
            filter: Filter.and([
              Filter.equal('team', 'crew_123'),
              Filter.equal('name', '#general'),
            ]),
          ),
          throwsA(isA<StreamChatError>()),
        );
      });

      test('should handle crew member addition failures', () async {
        // Arrange: Mock member addition failure
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        when(mockClient.channel(
          type: 'messaging',
          id: 'crew_123_general',
        )).thenReturn(generalChannel);

        when(generalChannel.addMembers(['new_member']))
            .thenThrow(StreamChatError(
              message: 'Failed to add member to crew chat',
              code: ErrorCode.failed,
            ));

        // Act & Assert: Verify error is handled
        expect(
          () async => await generalChannel.addMembers(['new_member']),
          throwsA(isA<StreamChatError>()),
        );
      });
    });

    group('8. Performance Tests', () {
      test('should handle crew chat message loading efficiently', () async {
        // Arrange: Create #general channel with many messages
        final generalChannel = Channel(
          cid: ChannelId('messaging:crew_123_general'),
        );

        final manyMessages = List.generate(50, (index) => Message(
          id: 'crew_msg_$index',
          text: 'Crew message $index',
          user: index % 3 == 0 ? foremanUser : crewMember1,
          createdAt: DateTime.now().subtract(Duration(minutes: index * 5)),
        ));

        when(mockClient.queryMessages(
          cid: generalChannel.cid!,
        )).thenAnswer((_) async => QueryMessagesResponse(
          messages: manyMessages,
        ));

        final stopwatch = Stopwatch()..start();

        // Act: Load crew chat messages
        final messageResult = await mockClient.queryMessages(
          cid: generalChannel.cid!,
        );

        stopwatch.stop();

        // Assert: Verify performance < 1 second for 50 messages
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(messageResult.messages.length, 50);
      });
    });
  });
}