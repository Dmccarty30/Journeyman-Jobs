// lib/features/crews/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../design_system/app_theme.dart';
import '../models/post_model.dart';

/// A card widget displaying a crew feed post with interaction capabilities
///
/// Provides a comprehensive post display with:
/// - Author information and timestamp
/// - Post content with optional image
/// - Like, comment, share, and reaction actions
/// - Comment display and interaction
/// - Edit and delete options for post owners
///
/// **Electrical Theme Integration:**
/// - Copper accent colors for interactive elements
/// - Navy backgrounds for elevated cards
/// - Lightning-inspired animation on interactions
class PostCard extends StatefulWidget {
  /// The post to display
  final Post post;

  /// Current user's ID for permission checks
  final String currentUserId;

  /// User ID for comment interactions
  final String commentUserId;

  /// Current user's display name
  final String currentUserName;

  /// List of comments on this post
  final List<PostComment> comments;

  /// Callback when user likes the post
  final Function(String userId, Post post) onLike;

  /// Callback when user comments on the post
  final Function(String userId, Post post) onComment;

  /// Callback when user shares the post
  final Function(String userId, Post post) onShare;

  /// Callback when user deletes the post (owner only)
  final Function(String userId, Post post) onDelete;

  /// Callback when user edits the post (owner only)
  final Function(String userId, Post post) onEdit;

  /// Callback when user adds a reaction
  final Function(String userId, String emoji, Post post) onReaction;

  /// Callback when user adds a comment
  final Function(String postId, String content) onAddComment;

  /// Callback when user likes a comment
  final Function(String commentId, String postId) onLikeComment;

  /// Callback when user unlikes a comment
  final Function(String commentId, String postId) onUnlikeComment;

  /// Callback when user edits a comment
  final Function(String commentId, String postId) onEditComment;

  /// Callback when user deletes a comment
  final Function(String commentId, String postId) onDeleteComment;

  /// Callback when user replies to a comment
  final Function(String postId, String commentId) onReplyToComment;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.commentUserId,
    required this.currentUserName,
    required this.comments,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onDelete,
    required this.onEdit,
    required this.onReaction,
    required this.onAddComment,
    required this.onLikeComment,
    required this.onUnlikeComment,
    required this.onEditComment,
    required this.onDeleteComment,
    required this.onReplyToComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Check if current user is the post owner
  bool get _isOwner => widget.post.userId == widget.currentUserId;

  /// Check if current user has liked this post
  bool get _isLiked => widget.post.likedBy.contains(widget.currentUserId);

  /// Get post type icon
  IconData get _postTypeIcon {
    switch (widget.post.type) {
      case PostType.announcement:
        return Icons.campaign;
      case PostType.discussion:
        return Icons.forum;
      case PostType.jobRelated:
        return Icons.work;
      case PostType.safety:
        return Icons.warning_amber;
      case PostType.social:
        return Icons.celebration;
      default:
        return Icons.article;
    }
  }

  /// Get post type color
  Color get _postTypeColor {
    switch (widget.post.type) {
      case PostType.announcement:
        return AppTheme.electricalWarning;
      case PostType.discussion:
        return AppTheme.accentCopper;
      case PostType.jobRelated:
        return Colors.green;
      case PostType.safety:
        return Colors.red;
      case PostType.social:
        return Colors.purple;
      default:
        return AppTheme.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(
          color: AppTheme.accentCopper.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          _buildPostHeader(),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            child: Text(
              widget.post.content,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ),

          // Post image if available
          if (widget.post.imageUrl != null) _buildPostImage(),

          // Post tags
          if (widget.post.tags.isNotEmpty) _buildPostTags(),

          // Post actions (like, comment, share)
          _buildPostActions(),

          // Comments section
          if (_showComments) _buildCommentsSection(),
        ],
      ),
    );
  }

  /// Build post header with author info and timestamp
  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          // Author avatar
          CircleAvatar(
            backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.2),
            child: Text(
              widget.post.authorName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),

          // Author name and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.authorName,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _postTypeIcon,
                      size: 16,
                      color: _postTypeColor,
                    ),
                  ],
                ),
                Text(
                  timeago.format(widget.post.createdAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),

          // More options menu (for post owner)
          if (_isOwner)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppTheme.mediumGray),
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onEdit(widget.currentUserId, widget.post);
                } else if (value == 'delete') {
                  widget.onDelete(widget.currentUserId, widget.post);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: AppTheme.accentCopper),
                      const SizedBox(width: 8),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Build post image display
  Widget _buildPostImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Image.network(
          widget.post.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: AppTheme.lightGray,
            child: Icon(Icons.broken_image, size: 48, color: AppTheme.mediumGray),
          ),
        ),
      ),
    );
  }

  /// Build post tags display
  Widget _buildPostTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.post.tags.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  /// Build post actions row (like, comment, share)
  Widget _buildPostActions() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.lightGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Like button
          _ActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: '${widget.post.likeCount}',
            color: _isLiked ? Colors.red : AppTheme.mediumGray,
            onTap: () => widget.onLike(widget.currentUserId, widget.post),
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // Comment button
          _ActionButton(
            icon: Icons.comment_outlined,
            label: '${widget.post.commentCount}',
            color: AppTheme.mediumGray,
            onTap: () {
              setState(() {
                _showComments = !_showComments;
              });
            },
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // Share button
          _ActionButton(
            icon: Icons.share_outlined,
            label: '${widget.post.shareCount}',
            color: AppTheme.mediumGray,
            onTap: () => widget.onShare(widget.currentUserId, widget.post),
          ),

          const Spacer(),

          // Reaction button
          IconButton(
            icon: Icon(Icons.add_reaction_outlined, color: AppTheme.accentCopper),
            onPressed: () {
              // TODO: Show emoji picker
              widget.onReaction(widget.currentUserId, '⚡', widget.post);
            },
          ),
        ],
      ),
    );
  }

  /// Build comments section
  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppTheme.lightGray,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments list
          ...widget.comments.map((comment) => _buildCommentItem(comment)),

          const SizedBox(height: AppTheme.spacingSm),

          // Add comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingSm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              IconButton(
                icon: Icon(Icons.send, color: AppTheme.accentCopper),
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    widget.onAddComment(widget.post.id, _commentController.text);
                    _commentController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual comment item
  Widget _buildCommentItem(PostComment comment) {
    final isLiked = comment.likedBy.contains(widget.currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment author avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.2),
            child: Text(
              comment.authorName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.accentCopper,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Text(
                  comment.content,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      timeago.format(comment.createdAt),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => isLiked
                          ? widget.onUnlikeComment(comment.id, widget.post.id)
                          : widget.onLikeComment(comment.id, widget.post.id),
                      child: Text(
                        isLiked ? 'Unlike' : 'Like',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.accentCopper,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${comment.likeCount} ${comment.likeCount == 1 ? 'like' : 'likes'}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal widget for action buttons
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
