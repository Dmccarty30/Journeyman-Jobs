import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';
import '../models/chat_message.dart';
import '../widgets/enhanced_chat_input.dart';
import '../widgets/realtime_presence_indicators.dart';
import '../widgets/message_bubble.dart';
import '../providers/crew_messages_provider.dart';

/// Enhanced crew chat screen with real-time messaging, presence indicators,
/// and improved user experience.
class EnhancedCrewChatScreen extends ConsumerStatefulWidget {
  final String crewId;
  final String crewName;

  const EnhancedCrewChatScreen({
    Key? key,
    required this.crewId,
    required this.crewName,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedCrewChatScreen> createState() => _EnhancedCrewChatScreenState();
}

class _EnhancedCrewChatScreenState extends ConsumerState<EnhancedCrewChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _markMessagesAsRead();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _markMessagesAsRead() {
    // Mark messages as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crewMessagesProvider(widget.crewId).notifier)
          .markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    try {
      await ref.read(crewMessagesProvider(widget.crewId).notifier)
          .sendMessage(text);
      _scrollToBottom();
    } catch (e) {
      // Handle error
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(crewMessagesProvider(widget.crewId));
    final currentUser = ref.watch(authRiverpodProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ElectricalCircuitBackground(
          child: Column(
            children: [
              // Online members indicator
              _buildOnlineMembersIndicator(),
              
              // Messages list
              Expanded(
                child: messagesAsync.when(
                  data: (messages) => _buildMessagesList(messages, currentUser?.uid),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),
              
              // Chat input
              EnhancedChatInput(
                crewId: widget.crewId,
                onMessageSent: _sendMessage,
                enabled: currentUser != null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryNavy,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.crewName,
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final onlineCount = ref.watch(onlineMembersCountProvider(widget.crewId));
              return Text(
                '$onlineCount members online',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.accentCopper,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showCrewInfo,
          icon: const Icon(
            Icons.info_outline,
            color: AppTheme.accentCopper,
          ),
        ),
        IconButton(
          onPressed: _showCrewMembers,
          icon: const Icon(
            Icons.people,
            color: AppTheme.accentCopper,
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineMembersIndicator() {
    return Consumer(
      builder: (context, ref, child) {
        final onlineMembers = ref.watch(onlineMembersProvider(widget.crewId));
        
        if (onlineMembers.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.accentCopper.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Online Now',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: onlineMembers.length,
                  itemBuilder: (context, index) {
                    final member = onlineMembers[index];
                    return _buildOnlineMemberAvatar(member);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnlineMemberAvatar(OnlineMember member) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
                backgroundImage: member.avatarUrl != null 
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(
                        member.displayName.isNotEmpty
                            ? member.displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppTheme.accentCopper,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: RealtimePresenceIndicators(
                  userId: member.userId,
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            member.displayName.length > 8
                ? '${member.displayName.substring(0, 8)}...'
                : member.displayName,
            style: AppTheme.caption.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages, String? currentUserId) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        
        return MessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: !isMe && (index == 0 || 
              messages[index - 1].senderId != message.senderId),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to connect with your crew',
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.7),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading messages',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCrewInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCrewInfoSheet(),
    );
  }

  void _showCrewMembers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCrewMembersSheet(),
    );
  }

  Widget _buildCrewInfoSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.crewName,
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final memberCount = ref.watch(totalMembersProvider(widget.crewId));
                final onlineCount = ref.watch(onlineMembersCountProvider(widget.crewId));
                
                return Text(
                  '$memberCount members • $onlineCount online',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.accentCopper,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Crew chat for real-time communication and coordination.',
              style: TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewMembersSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Crew Members',
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                final membersAsync = ref.watch(crewMembersStreamProvider(widget.crewId));
                
                return membersAsync.when(
                  data: (members) => _buildMembersList(members),
                  loading: () => const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                  ),
                  error: (error, stack) => Text(
                    'Error loading members',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<CrewMember> members) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Consumer(
          builder: (context, ref, child) {
            final userAsync = ref.watch(userStreamProvider(member.userId));
            
            return userAsync.when(
              data: (user) => ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
                      backgroundImage: user.photoUrl != null 
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: AppTheme.accentCopper,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: RealtimePresenceIndicators(
                        userId: member.userId,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                title: Text(
                  user.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  member.role.displayName,
                  style: TextStyle(
                    color: AppTheme.accentCopper,
                  ),
                ),
                trailing: UserActivityStatus(
                  userId: member.userId,
                  showLastSeen: true,
                ),
              ),
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading...', style: TextStyle(color: Colors.white)),
              ),
              error: (error, stack) => ListTile(
                leading: Icon(Icons.error, color: Colors.red),
                title: Text('Error', style: TextStyle(color: Colors.white)),
              ),
            );
          },
        );
      },
    );
  }
}

// Mock models and providers for real-time features
class OnlineMember {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  OnlineMember({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });
}

// Mock providers - these would connect to Firebase
final onlineMembersProvider = StreamProvider.family<List<OnlineMember>, String>((ref, crewId) {
  return Stream.value([
    OnlineMember(userId: '1', displayName: 'John Doe'),
    OnlineMember(userId: '2', displayName: 'Jane Smith'),
  ]);
});

final onlineMembersCountProvider = Provider.family<int, String>((ref, crewId) {
  final onlineMembers = ref.watch(onlineMembersProvider(crewId));
  return onlineMembers.maybeWhen(
    data: (members) => members.length,
    orElse: () => 0,
  );
});

final totalMembersProvider = Provider.family<int, String>((ref, crewId) {
  return 5; // Mock value
});
