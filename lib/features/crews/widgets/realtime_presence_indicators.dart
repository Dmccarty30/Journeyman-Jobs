import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';

/// Widget displaying real-time presence indicators for crew members.
/// 
/// Shows online/offline status, typing indicators, and activity states
/// for crew members in real-time.
class RealtimePresenceIndicators extends ConsumerWidget {
  final String userId;
  final String? crewId;
  final double size;

  const RealtimePresenceIndicators({
    Key? key,
    required this.userId,
    this.crewId,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceAsync = ref.watch(userPresenceStreamProvider(userId));
    
    return presenceAsync.when(
      data: (presence) => _buildPresenceIndicator(presence),
      loading: () => _buildLoadingIndicator(),
      error: (error, stack) => _buildOfflineIndicator(),
    );
  }

  Widget _buildPresenceIndicator(UserPresence presence) {
    return Stack(
      children: [
        // Base presence indicator
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getPresenceColor(presence.status),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        // Typing indicator animation
        if (presence.isTyping)
          Positioned(
            right: -2,
            top: -2,
            child: _buildTypingIndicator(),
          ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      width: size * 0.6,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: AppTheme.accentCopper,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: const Center(
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 8,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  Color _getPresenceColor(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return Colors.green;
      case PresenceStatus.away:
        return Colors.orange;
      case PresenceStatus.busy:
        return Colors.red;
      case PresenceStatus.offline:
      default:
        return Colors.grey;
    }
  }
}

/// Typing indicator widget for chat interfaces.
class TypingIndicator extends ConsumerWidget {
  final List<String> typingUserIds;
  final Map<String, String> userNames;

  const TypingIndicator({
    Key? key,
    required this.typingUserIds,
    required this.userNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (typingUserIds.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypingDots(),
          const SizedBox(width: 8),
          _buildTypingText(),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildTypingText() {
    final String typingText;
    
    if (typingUserIds.length == 1) {
      final userName = userNames[typingUserIds.first] ?? 'Someone';
      typingText = '$userName is typing';
    } else if (typingUserIds.length == 2) {
      final user1 = userNames[typingUserIds.first] ?? 'Someone';
      final user2 = userNames[typingUserIds[1]] ?? 'Someone';
      typingText = '$user1 and $user2 are typing';
    } else {
      typingText = '${typingUserIds.length} people are typing';
    }

    return Text(
      typingText,
      style: AppTheme.caption.copyWith(
        color: AppTheme.accentCopper,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// User activity status widget for crew member lists.
class UserActivityStatus extends ConsumerWidget {
  final String userId;
  final bool showLastSeen;

  const UserActivityStatus({
    Key? key,
    required this.userId,
    this.showLastSeen = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceAsync = ref.watch(userPresenceStreamProvider(userId));
    
    return presenceAsync.when(
      data: (presence) => _buildActivityStatus(presence),
      loading: () => _buildLoadingStatus(),
      error: (error, stack) => _buildOfflineStatus(),
    );
  }

  Widget _buildActivityStatus(UserPresence presence) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getPresenceIcon(presence.status),
          color: _getPresenceColor(presence.status),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          _getPresenceText(presence),
          style: AppTheme.caption.copyWith(
            color: _getPresenceColor(presence.status),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showLastSeen && presence.status == PresenceStatus.offline && 
            presence.lastSeen != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${_formatLastSeen(presence.lastSeen!)})',
            style: AppTheme.caption.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Loading...',
          style: AppTheme.caption.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.offline_bolt,
          color: Colors.grey,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          'Offline',
          style: AppTheme.caption.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getPresenceIcon(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return Icons.circle;
      case PresenceStatus.away:
        return Icons.bedtime;
      case PresenceStatus.busy:
        return Icons.work;
      case PresenceStatus.offline:
      default:
        return Icons.offline_bolt;
    }
  }

  Color _getPresenceColor(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return Colors.green;
      case PresenceStatus.away:
        return Colors.orange;
      case PresenceStatus.busy:
        return Colors.red;
      case PresenceStatus.offline:
      default:
        return Colors.grey;
    }
  }

  String _getPresenceText(UserPresence presence) {
    switch (presence.status) {
      case PresenceStatus.online:
        return 'Online';
      case PresenceStatus.away:
        return 'Away';
      case PresenceStatus.busy:
        return 'Busy';
      case PresenceStatus.offline:
      default:
        return 'Offline';
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    } else {
      return '${lastSeen.month}/${lastSeen.day}';
    }
  }
}

/// Models and providers for presence system

class UserPresence {
  final String userId;
  final PresenceStatus status;
  final bool isTyping;
  final DateTime? lastSeen;
  final String? currentActivity;

  const UserPresence({
    required this.userId,
    required this.status,
    this.isTyping = false,
    this.lastSeen,
    this.currentActivity,
  });

  UserPresence copyWith({
    String? userId,
    PresenceStatus? status,
    bool? isTyping,
    DateTime? lastSeen,
    String? currentActivity,
  }) {
    return UserPresence(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      isTyping: isTyping ?? this.isTyping,
      lastSeen: lastSeen ?? this.lastSeen,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}

enum PresenceStatus {
  online,
  away,
  busy,
  offline,
}

extension PresenceStatusExtension on PresenceStatus {
  String get displayName {
    switch (this) {
      case PresenceStatus.online:
        return 'Online';
      case PresenceStatus.away:
        return 'Away';
      case PresenceStatus.busy:
        return 'Busy';
      case PresenceStatus.offline:
        return 'Offline';
    }
  }
}

// Mock providers - these would connect to Firebase presence system
final userPresenceStreamProvider = StreamProvider.family<UserPresence, String>((ref, userId) {
  // This would connect to Firebase Realtime Database or Firestore
  // for real-time presence tracking
  return Stream.value(UserPresence(
    userId: userId,
    status: PresenceStatus.online,
    isTyping: false,
    lastSeen: DateTime.now(),
  ));
});
