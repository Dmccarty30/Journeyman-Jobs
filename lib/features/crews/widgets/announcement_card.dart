import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tailboard.dart';
import '../../../design_system/app_theme.dart';

class AnnouncementCard extends ConsumerWidget {
  final TailboardPost post;
  final String currentUserId;

  const AnnouncementCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPinned = post.isPinned;
    final hasReacted = post.reactions.containsKey(currentUserId);
    final currentReaction = post.reactions[currentUserId];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isPinned ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPinned ? AppTheme.accentCopper.withValues(alpha: 0.5) : AppTheme.borderLight,
          width: isPinned ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with pin indicator
          if (isPinned)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: AppTheme.accentCopper,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned Announcement',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentCopper,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info (placeholder - would need to fetch user data)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.accentCopper,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crew Leader', // Would be actual user name
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(post.postedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Attachments (if any)
                if (post.attachmentUrls.isNotEmpty)
                  _buildAttachments(context),
                // Reactions and actions
                Row(
                  children: [
                    // Reactions
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _handleReaction(context, ReactionType.like),
                          icon: Icon(
                            hasReacted && currentReaction == ReactionType.like
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 20,
                            color: hasReacted && currentReaction == ReactionType.like
                                ? AppTheme.accentCopper
                                : AppTheme.textLight,
                          ),
                        ),
                        if (post.reactions.isNotEmpty)
                          Text(
                            post.reactions.length.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Actions
                    IconButton(
                      onPressed: () => _showMoreOptions(context),
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    if (post.attachmentUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Attachments:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: post.attachmentUrls.map((url) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon(url),
                    size: 16,
                    color: AppTheme.accentCopper,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getFileName(url),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  IconData _getFileIcon(String url) {
    if (url.contains('.pdf')) return Icons.picture_as_pdf;
    if (url.contains('.jpg') || url.contains('.png') || url.contains('.jpeg')) {
      return Icons.image;
    }
    return Icons.attach_file;
  }

  String _getFileName(String url) {
    return url.split('/').last.split('?').first;
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleReaction(BuildContext context, ReactionType reaction) {
    // This would typically call a provider method to add/remove reaction
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(post.reactions.containsKey(currentUserId) ? 'Reaction removed' : 'Reaction added'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: Text(post.isPinned ? 'Unpin announcement' : 'Pin announcement'),
              onTap: () {
                Navigator.pop(context);
                // Toggle pin status
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit announcement'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete announcement'),
              onTap: () {
                Navigator.pop(context);
                // Show delete confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}