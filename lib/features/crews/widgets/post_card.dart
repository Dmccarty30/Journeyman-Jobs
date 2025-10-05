import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post_model.dart';
import '../../../design_system/app_theme.dart';
import '../../../widgets/reaction_animation.dart';
import '../../../widgets/like_animation.dart';
import '../../../widgets/comment_animation.dart';
import 'crew_member_avatar.dart';
import '../../../widgets/comment_input.dart';
import '../../../widgets/comment_thread.dart';
import '../models/tailboard.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;
  final Function(String, PostModel)? onLike;
  final Function(String, PostModel)? onComment;
  final Function(String, PostModel)? onShare;
  final Function(String, PostModel)? onDelete;
  final Function(String, PostModel)? onEdit;
  final Function(String, String, PostModel)? onReaction;
  final Function(String, String)? onAddComment;
  final Function(String, String)? onLikeComment;
  final Function(String, String)? onUnlikeComment;
  final Function(String, String)? onEditComment;
  final Function(String, String)? onDeleteComment;
  final Function(String, String)? onReplyToComment;
  final String commentUserId;
  final String? currentUserName;
  final List<Comment>? comments;
  final bool showCommentInput;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onDelete,
    this.onEdit,
    this.onReaction,
    this.onAddComment,
    this.onLikeComment,
    this.onUnlikeComment,
    this.onEditComment,
    this.onDeleteComment,
    this.onReplyToComment,
    required this.commentUserId,
    this.currentUserName,
    this.comments,
    this.showCommentInput = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  bool _showComments = false;
  bool _showReactionPicker = false;
  String? _userReaction;
  Map<String, int> _reactions = {};
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likes.contains(widget.currentUserId);
    _likeCount = widget.post.likes.length;
    _reactions = widget.post.reactions;
    _userReaction = widget.post.userReactions[widget.currentUserId];
  }

  void _showReactionAnimation(String emoji) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + renderBox.size.width / 2 - 18,
        top: position.dy + renderBox.size.height / 2 - 18,
        child: Material(
          color: Colors.transparent,
          child: EnhancedReactionAnimation(
            emoji: emoji,
            isSelected: true,
            onTap: () {},
            size: 36.0,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
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

  void _toggleReactionPicker() {
    setState(() {
      _showReactionPicker = !_showReactionPicker;
    });
  }

  void _handleReactionSelected(String emoji) {
    setState(() {
      _showReactionPicker = false;

      // Update local state
      if (_userReaction == emoji) {
        // Remove reaction if same emoji selected again
        _reactions[emoji] = (_reactions[emoji] ?? 1) - 1;
        if (_reactions[emoji]! <= 0) {
          _reactions.remove(emoji);
        }
        _userReaction = null;
      } else {
        // Remove previous reaction if exists
        if (_userReaction != null) {
          _reactions[_userReaction!] = (_reactions[_userReaction!] ?? 1) - 1;
          if (_reactions[_userReaction!]! <= 0) {
            _reactions.remove(_userReaction!);
          }
        }

        // Add new reaction
        _reactions[emoji] = (_reactions[emoji] ?? 0) + 1;
        _userReaction = emoji;
      }
    });

    // Trigger animation
    if (_userReaction == null || _userReaction != emoji) {
      _showReactionAnimation(emoji);
    }

    // Notify parent
    if (widget.onReaction != null) {
      widget.onReaction!(widget.currentUserId, emoji, widget.post);
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
      if (_showComments && widget.onComment != null) {
        widget.onComment!(widget.post.id, widget.post);
      }
    });
  }

  void _handleCommentAdded() {
    setState(() {
      _isAddingComment = true;
    });

    // In a real implementation, this would trigger a refresh of comments
    // For now, we'll just simulate the action
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
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
      return 'Just now';
    }
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CrewMemberAvatar(
            memberName: widget.post.authorName ?? 'Unknown User',
            size: 40,
            showStatus: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName ?? 'Unknown User',
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
          LikeAnimation(
            isLiked: _isLiked,
            onLike: _toggleLike,
            size: 24,
            likedColor: AppTheme.errorRed,
            unlikedColor: AppTheme.textSecondary,
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
            '${widget.post.commentCount ?? widget.post.comments.length}',
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

    return CommentAnimation(
      isVisible: _showComments,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment input field
            if (widget.showCommentInput)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommentInput(
                  postId: widget.post.id,
                  currentUserId: widget.commentUserId,
                  currentUserName: widget.currentUserName,
                  onCommentAdded: () {
                    setState(() {
                      _isAddingComment = true;
                    });
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Comment thread
            if (widget.comments != null && widget.comments!.isNotEmpty)
              CommentThread(
                comments: widget.comments!,
                postId: widget.post.id,
                currentUserId: widget.commentUserId,
                onLikeComment: (postId, commentId) {
                  widget.onLikeComment?.call(commentId, postId);
                },
                onUnlikeComment: (postId, commentId) {
                  widget.onUnlikeComment?.call(commentId, postId);
                },
                onEditComment: (postId, commentId) {
                  widget.onEditComment?.call(commentId, postId);
                },
                onDeleteComment: (postId, commentId) {
                  widget.onDeleteComment?.call(commentId, postId);
                },
                onReplyToComment: (commentId) {
                  widget.onReplyToComment?.call(widget.post.id, commentId);
                },
              )
            else if (_isAddingComment)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: AppTheme.electricalSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(
          color: AppTheme.borderCopperLight,
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