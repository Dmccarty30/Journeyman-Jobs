import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post_model.dart';
import '../../../design_system/app_theme.dart';
import 'crew_member_avatar.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;
  final Function(String, PostModel)? onLike;
  final Function(String, PostModel)? onComment;
  final Function(String, PostModel)? onShare;
  final Function(String, PostModel)? onDelete;
  final Function(String, PostModel)? onEdit;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likes.contains(widget.currentUserId);
    _likeCount = widget.post.likes.length;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    
    if (widget.onLike != null) {
      widget.onLike!(widget.currentUserId, widget.post);
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _sharePost() {
    if (widget.onShare != null) {
      widget.onShare!(widget.currentUserId, widget.post);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post shared!'),
        backgroundColor: AppTheme.electricalSuccess,
      ),
    );
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (widget.onDelete != null) {
                widget.onDelete!(widget.currentUserId, widget.post);
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editPost() {
    if (widget.onEdit != null) {
      widget.onEdit!(widget.currentUserId, widget.post);
    }
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CrewMemberAvatar(
            memberName: 'Author Name', // TODO: Replace with actual user name
            size: 40,
            showStatus: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Author Name', // TODO: Replace with actual user name from user service
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(widget.post.timestamp),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  _editPost();
                  break;
                case 'delete':
                  _deletePost();
                  break;
                case 'report':
                  // TODO: Implement report functionality
                  break;
              }
            },
            itemBuilder: (context) => [
              if (widget.post.authorId == widget.currentUserId)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: AppTheme.accentCopper),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              if (widget.post.authorId == widget.currentUserId)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppTheme.errorRed),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, size: 16, color: AppTheme.warningYellow),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.content.isNotEmpty)
            Text(
              widget.post.content,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          if (widget.post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildMediaGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    if (widget.post.mediaUrls.length == 1) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          color: AppTheme.electricalSurface,
          border: Border.all(
            color: AppTheme.borderCopperLight,
            width: AppTheme.borderWidthThin,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Image.network(
            widget.post.mediaUrls.first,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.lightGray,
                child: Icon(
                  Icons.broken_image,
                  size: 48,
                  color: AppTheme.mediumGray,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: widget.post.mediaUrls.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.electricalSurface,
              border: Border.all(
                color: AppTheme.borderCopperLight,
                width: AppTheme.borderWidthThin,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Image.network(
                widget.post.mediaUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.lightGray,
                    child: Icon(
                      Icons.broken_image,
                      size: 32,
                      color: AppTheme.mediumGray,
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleLike,
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? AppTheme.errorRed : AppTheme.textSecondary,
              size: 24,
            ),
          ),
          Text(
            '$_likeCount',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: _toggleComments,
            icon: Icon(
              Icons.comment,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
          Text(
            '0', // TODO: Replace with actual comment count
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: _sharePost,
            icon: Icon(
              Icons.share,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppTheme.accentCopper : AppTheme.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    if (!_showComments) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: Replace with actual comments from comments service
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.borderLight,
                width: AppTheme.borderWidthThin,
              ),
            ),
            child: Text(
              'No comments yet. Be the first to comment!',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: AppTheme.shadowCard.first.blurRadius * 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(
          color: AppTheme.borderCopperLight.withValues(alpha: 0.3),
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildPostContent(),
          _buildPostActions(),
          _buildCommentsSection(),
        ],
      ),
    );
  }
}