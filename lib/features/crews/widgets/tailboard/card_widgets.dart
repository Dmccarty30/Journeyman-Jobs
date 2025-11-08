// Flutter & Dart imports
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// Journeyman Jobs - Absolute imports
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Channel preview card for chat tab
class ChannelPreviewCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onTap;

  const ChannelPreviewCard({
    super.key,
    required this.channel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = channel.state?.lastMessage;
    final unreadCount = channel.state?.unreadCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.1),
              child: Text(
                (channel.name?.isNotEmpty == true ? channel.name![0] : 'C').toUpperCase(),
                style: TextStyle(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          channel.name ?? 'Unnamed Channel',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        subtitle: lastMessage != null
            ? Text(
                lastMessage.text ?? 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              )
            : const Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastMessage != null)
              Text(
                _formatMessageTime(lastMessage.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: unreadCount > 0
                      ? AppTheme.accentCopper
                      : const Color(0xFF94A3B8),
                  fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  /// Format message timestamp
  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

/// Crew member card for members tab
class CrewMemberCard extends StatelessWidget {
  final dynamic member;

  const CrewMemberCard({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF3B82F6), // blue
      const Color(0xFF22C55E), // green
      const Color(0xFF9333EA), // purple
      const Color(0xFFEF4444), // red
      const Color(0xFFEAB308), // yellow
    ];

    final colorIndex = 0; // Using first color for simplicity
    final avatarColor = colors[colorIndex];
    final isOnline = true; // Default to online for demo

    final roleColors = {
      'Lead': const Color(0xFF22C55E),
      'Safety': const Color(0xFFF97316),
      'Apprentice': const Color(0xFF3B82F6),
      'Specialist': const Color(0xFF9333EA),
      'Technician': const Color(0xFF6B7280),
    };

    const role = 'Lead';
    final roleColor = roleColors[role] ?? const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'JS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Member details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'John Smith',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Foreman • 8 years experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: Color(0xFF94A3B8)),
                      SizedBox(width: 4),
                      Text(
                        '(555) 123-4567',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.mail, size: 12, color: Color(0xFF94A3B8)),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'john@company.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status and actions
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 16),
                  color: const Color(0xFF64748B),
                  onPressed: () {
                    // Handle more options
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Safety card for tailboard tab
class SafetyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const SafetyCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () {
          // Handle safety card tap
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}