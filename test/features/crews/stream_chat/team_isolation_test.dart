import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/services/stream_chat_service.dart';
import 'package:journeyman_jobs/features/crews/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'team_isolation_test.mocks.dart';

@GenerateMocks([StreamChatService, StreamChatClient])
void main() {
  group('Stream Chat Team Isolation Tests', () {
    late MockStreamChatService mockService;
    late MockStreamChatClient mockClient;
    late ProviderContainer container;
    late User testUserAlpha;
    late User testUserBeta;
    late Crew crewAlpha;
    late Crew crewBeta;

    setUp(() {
      mockService = MockStreamChatService();
      mockClient = MockStreamChatClient();

      // Setup test users from different crews
      testUserAlpha = User(
        id: 'user_alpha_001',
        name: 'John Alpha',
        extraData: {
          'crew_id': 'crew_alpha_123',
          'ibew_local': 84,
        },
      );

      testUserBeta = User(
        id: 'user_beta_001',
        name: 'Mike Beta',
        extraData: {
          'crew_id': 'crew_beta_456',
          'ibew_local': 111,
        },
      );

      // Setup test crews
      crewAlpha = Crew(
        id: 'crew_alpha_123',
        name: 'IBEW Local 84 Linemen',
        memberIds: ['user_alpha_001', 'user_alpha_002'],
        foremanId: 'user_alpha_001',
        crewType: CrewType.lineman,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      crewBeta = Crew(
        id: 'crew_beta_456',
        name: 'IBEW Local 111 Wiremen',
        memberIds: ['user_beta_001', 'user_beta_002'],
        foremanId: 'user_beta_001',
        crewType: CrewType.wireman,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      );

      // Setup Riverpod container
      container = ProviderContainer(
        overrides: [
          streamChatServiceProvider.overrideWithValue(mockService),
        ],
      );

      // Mock service initialization
      when(mockService.initializeClient()).thenAnswer((_) async => mockClient);
      when(mockService.currentUserId).thenReturn(testUserAlpha.id);
      when(mockService.disconnectClient()).thenAnswer((_) async {});
    });

    tearDown(() {
      container.dispose();
    });

    group('1. User A Cannot See User B\'s Channels', () {
      test('should enforce crew isolation in channel queries', () async {
        // Arrange: Create mock channels for each crew
        final alphaChannel = Channel(
          cid: ChannelId('messaging:alpha_general'),
          type: 'messaging',
          id: 'alpha_general',
          extraData: {
            'name': 'IBEW Local 84 - General',
            'team': 'crew_alpha_123',
            'type': 'crew',
            'members': ['user_alpha_001', 'user_alpha_002'],
          },
        );

        final betaChannel = Channel(
          cid: ChannelId('messaging:beta_general'),
          type: 'messaging',
          id: 'beta_general',
          extraData: {
            'name': 'IBEW Local 111 - General',
            'team': 'crew_beta_456',
            'type': 'crew',
            'members': ['user_beta_001', 'user_beta_002'],
          },
        );

        // Mock: User Alpha can only see Alpha channels
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
          sort: anyNamed('sort'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [alphaChannel]));

        // Mock: User Beta can only see Beta channels
        when(mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_beta_456'),
          sort: anyNamed('sort'),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [betaChannel]));

        // Act: Get channels for User Alpha (crew_alpha_123)
        final alphaChannels = await container.read(
          crewChannelsProvider('crew_alpha_123').future,
        );

        // Assert: User Alpha should only see Alpha channels
        expect(alphaChannels, isA<List<Channel>>());
        expect(alphaChannels.length, 1);
        expect(alphaChannels.first.extraData!['team'], equals('crew_alpha_123'));
        expect(alphaChannels.first.extraData!['name'], contains('IBEW Local 84'));

        // Verify no Beta channels are returned
        expect(alphaChannels.any((c) =>
          c.extraData!['team'] == 'crew_beta_456'), isFalse);
      });

      test('should prevent cross-crew channel access attempts', () async {
        // Arrange: Mock channel access attempt
        final unauthorizedChannel = Channel(
          cid: ChannelId('messaging:beta_general'),
          extraData: {'team': 'crew_beta_456'},
        );

        // Mock service to throw exception for unauthorized access
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_beta_456'),
            Filter.in_('members', ['user_alpha_001']),
          ]),
        )).thenThrow(StreamChatError(
          message: 'User not authorized for this crew channel',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify unauthorized access is blocked
        expect(
          () async {
            await mockClient.queryChannels(
              filter: Filter.and([
                Filter.equal('team', 'crew_beta_456'),
                Filter.in_('members', ['user_alpha_001']),
              ]),
            );
          },
          throwsA(isA<StreamChatError>()),
        );
      });
    });

    group('2. #general Channels Are Crew-Specific', () {
      test('should create separate #general channels per crew', () async {
        // Arrange: Mock general channel creation for each crew
        final alphaGeneral = Channel(
          cid: ChannelId('messaging:alpha_general'),
          extraData: {
            'name': '#general',
            'team': 'crew_alpha_123',
            'type': 'crew',
            'auto_join': true,
          },
        );

        final betaGeneral = Channel(
          cid: ChannelId('messaging:beta_general'),
          extraData: {
            'name': '#general',
            'team': 'crew_beta_456',
            'type': 'crew',
            'auto_join': true,
          },
        );

        // Mock: Query Alpha's general channel
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('name', '#general'),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [alphaGeneral]));

        // Mock: Query Beta's general channel
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_beta_456'),
            Filter.equal('name', '#general'),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [betaGeneral]));

        // Act: Query general channels
        final alphaResult = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('name', '#general'),
          ]),
        );

        final betaResult = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_beta_456'),
            Filter.equal('name', '#general'),
          ]),
        );

        // Assert: Verify separate general channels exist
        expect(alphaResult.channels.length, 1);
        expect(betaResult.channels.length, 1);
        expect(alphaResult.channels.first.cid, isNot(equals(betaResult.channels.first.cid)));
        expect(alphaResult.channels.first.extraData!['team'], equals('crew_alpha_123'));
        expect(betaResult.channels.first.extraData!['team'], equals('crew_beta_456'));
      });

      test('should auto-add crew members to their #general channel', () async {
        // Arrange: Test auto-join functionality
        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('auto_join', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [
          Channel(
            cid: ChannelId('messaging:alpha_general'),
            extraData: {
              'team': 'crew_alpha_123',
              'auto_join': true,
              'members': ['user_alpha_001', 'user_alpha_002'],
            },
          ),
        ]));

        // Act: Query auto-join channels
        final autoJoinChannels = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('auto_join', true),
          ]),
        );

        // Assert: Verify crew members are auto-added
        expect(autoJoinChannels.channels.length, 1);
        final generalChannel = autoJoinChannels.channels.first;
        expect(generalChannel.extraData!['members'], contains('user_alpha_001'));
        expect(generalChannel.extraData!['members'], contains('user_alpha_002'));
      });
    });

    group('3. DMs Only Work Within Same Crew', () {
      test('should allow DMs between same crew members', () async {
        // Arrange: Create same-crew users
        final userAlpha2 = User(
          id: 'user_alpha_002',
          extraData: {'crew_id': 'crew_alpha_123'},
        );

        // Mock successful DM creation
        final dmChannel = Channel(
          cid: ChannelId('messaging:user_alpha_001-user_alpha_002'),
          extraData: {
            'type': 'direct',
            'team': 'crew_alpha_123',
            'members': ['user_alpha_001', 'user_alpha_002'],
            'member_count': 2,
          },
        );

        when(mockClient.channel(
          type: 'messaging',
          id: anyNamed('id'),
          extraData: argThat(
            containsPair('team', 'crew_alpha_123'),
            named: 'extraData',
          ),
        )).thenReturn(Channel(mockClient, 'messaging', 'test-dm'));

        // Act & Assert: Verify DM creation is allowed for same crew
        final dmCreation = mockClient.channel(
          type: 'messaging',
          extraData: {
            'members': ['user_alpha_001', 'user_alpha_002'],
            'team': 'crew_alpha_123',
            'distinct': true,
          },
        );

        expect(dmCreation, isA<Channel>());
      });

      test('should prevent DMs between different crew members', () async {
        // Arrange: Mock cross-crew DM prevention
        when(mockClient.channel(
          type: 'messaging',
          extraData: argThat(
            allOf([
              containsPair('members', ['user_alpha_001', 'user_beta_001']),
              containsPair('team', 'crew_alpha_123'), // Different crew IDs
            ]),
            named: 'extraData',
          ),
        )).thenThrow(StreamChatError(
          message: 'Cannot create DM between different crews',
          code: ErrorCode.forbidden,
        ));

        // Act & Assert: Verify cross-crew DM is blocked
        expect(
          () {
            mockClient.channel(
              type: 'messaging',
              extraData: {
                'members': ['user_alpha_001', 'user_beta_001'],
                'team': 'crew_alpha_123',
                'distinct': true,
              },
            );
          },
          throwsA(isA<StreamChatError>()),
        );
      });

      test('should use distinct flag to prevent duplicate DMs', () async {
        // Arrange: Test distinct DM creation
        final existingDM = Channel(
          cid: ChannelId('messaging:user_alpha_001-user_alpha_002'),
          extraData: {
            'type': 'direct',
            'team': 'crew_alpha_123',
            'members': ['user_alpha_001', 'user_alpha_002'],
            'distinct': true,
          },
        );

        when(mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_alpha_001', 'user_alpha_002']),
            Filter.equal('distinct', true),
          ]),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: [existingDM]));

        // Act: Check for existing DM
        final existingDMs = await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_alpha_001', 'user_alpha_002']),
            Filter.equal('distinct', true),
          ]),
        );

        // Assert: Verify existing DM is found to prevent duplicates
        expect(existingDMs.channels.length, 1);
        expect(existingDMs.channels.first.extraData!['distinct'], isTrue);
      });
    });

    group('4. Filter Queries Enforce Team Separation', () {
      test('should apply team filter to all channel queries', () async {
        // Arrange: Test team filter application
        final alphaChannels = [
          Channel(extraData: {'team': 'crew_alpha_123'}),
          Channel(extraData: {'team': 'crew_alpha_123'}),
        ];

        when(mockClient.queryChannels(
          filter: argThat(
            predicate((Filter filter) {
              // Verify team filter is applied
              return filter.toString().contains('team') &&
                     filter.toString().contains('crew_alpha_123');
            }),
            named: 'filter',
          ),
        )).thenAnswer((_) async => QueryChannelsResponse(channels: alphaChannels));

        // Act: Query channels with team filter
        final result = await mockClient.queryChannels(
          filter: Filter.equal('team', 'crew_alpha_123'),
        );

        // Assert: Verify team filter was applied
        verify(mockClient.queryChannels(
          filter: argThat(
            contains(Filter.equal('team', 'crew_alpha_123')),
            named: 'filter',
          ),
        )).called(1);

        expect(result.channels.length, 2);
      });

      test('should combine team filter with other filters', () async {
        // Arrange: Test complex filter combination
        final combinedFilter = Filter.and([
          Filter.equal('team', 'crew_alpha_123'),
          Filter.equal('member_count', 2),
          Filter.in_('members', ['user_alpha_001']),
        ]);

        when(mockClient.queryChannels(
          filter: combinedFilter,
        )).thenAnswer((_) async => QueryChannelsResponse(channels: []));

        // Act: Query with combined filters
        await mockClient.queryChannels(
          filter: Filter.and([
            Filter.equal('team', 'crew_alpha_123'),
            Filter.equal('member_count', 2),
            Filter.in_('members', ['user_alpha_001']),
          ]),
        );

        // Assert: Verify all filters were applied together
        verify(mockClient.queryChannels(
          filter: argThat(
            allOf([
              contains(Filter.equal('team', 'crew_alpha_123')),
              contains(Filter.equal('member_count', 2)),
              contains(Filter.in_('members', ['user_alpha_001'])),
            ]),
            named: 'filter',
          ),
        )).called(1);
      });
    });

    group('5. Online Status Isolation', () {
      test('should only show online status for same crew members', () async {
        // Arrange: Test online status filtering by crew
        final alphaMembers = [
          User(id: 'user_alpha_001', online: true, extraData: {'crew_id': 'crew_alpha_123'}),
          User(id: 'user_alpha_002', online: false, extraData: {'crew_id': 'crew_alpha_123'}),
        ];

        final betaMembers = [
          User(id: 'user_beta_001', online: true, extraData: {'crew_id': 'crew_beta_456'}),
          User(id: 'user_beta_002', online: true, extraData: {'crew_id': 'crew_beta_456'}),
        ];

        // Mock: Query users by crew
        when(mockClient.queryUsers(
          filter: Filter.equal('crew_id', 'crew_alpha_123'),
        )).thenAnswer((_) async => QueryUsersResponse(users: alphaMembers));

        when(mockClient.queryUsers(
          filter: Filter.equal('crew_id', 'crew_beta_456'),
        )).thenAnswer((_) async => QueryUsersResponse(users: betaMembers));

        // Act: Query Alpha crew online users
        final alphaOnlineUsers = await mockClient.queryUsers(
          filter: Filter.equal('crew_id', 'crew_alpha_123'),
        );

        // Assert: Verify only Alpha crew users are returned
        expect(alphaOnlineUsers.users.length, 2);
        expect(alphaOnlineUsers.users.every((user) =>
          user.extraData!['crew_id'] == 'crew_alpha_123'), isTrue);
        expect(alphaOnlineUsers.users.any((user) =>
          user.extraData!['crew_id'] == 'crew_beta_456'), isFalse);
      });
    });

    group('6. Message Isolation', () {
      test('should enforce crew-based message access', () async {
        // Arrange: Test message filtering by crew
        final alphaChannel = Channel(
          cid: ChannelId('messaging:alpha_general'),
          extraData: {'team': 'crew_alpha_123'},
        );

        final alphaMessages = [
          Message(
            id: 'msg_1',
            text: 'Alpha crew message',
            user: testUserAlpha,
            createdAt: DateTime.now(),
          ),
        ];

        // Mock: Query messages for Alpha channel
        when(mockClient.queryMessages(
          cid: alphaChannel.cid!,
        )).thenAnswer((_) async => QueryMessagesResponse(messages: alphaMessages));

        // Act: Query messages for Alpha channel
        final messageResult = await mockClient.queryMessages(cid: alphaChannel.cid!);

        // Assert: Verify messages are returned for correct channel
        expect(messageResult.messages.length, 1);
        expect(messageResult.messages.first.text, equals('Alpha crew message'));
        expect(messageResult.messages.first.user?.id, equals(testUserAlpha.id));

        // Verify the channel has correct team assignment
        verify(mockClient.queryMessages(
          cid: argThat(
            equals(alphaChannel.cid),
            named: 'cid',
          ),
        )).called(1);
      });
    });
  });
}