import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../features/crews/models/tailboard.dart';
import 'comment_item.dart';

/// A widget that displays a list of comments as a thread.
///
/// It handles displaying a list of [CommentItem] widgets, shows a loading
/// indicator, and provides a "load more" button for pagination.
class CommentThread extends StatefulWidget {
  /// The list of comments to display in the thread.
  final List<Comment> comments;
  /// The ID of the parent post to which these comments belong.
  final String postId;
  /// The ID of the currently logged-in user, used to determine permissions (edit/delete).
  final String? currentUserId;
  /// A flag indicating if more comments are currently being loaded.
  final bool isLoading;
  /// A callback function to be invoked when the user requests to load more comments.
  final VoidCallback? onLoadMore;
  /// A flag indicating if there are more comments available to be loaded from the server.
  final bool hasMore;
  /// A callback for when a user likes a comment. Passes post ID and comment ID.
  final Function(String, String)? onLikeComment;
  /// A callback for when a user unlikes a comment. Passes post ID and comment ID.
  final Function(String, String)? onUnlikeComment;
  /// A callback for when a user edits a comment. Passes post ID and comment ID.
  final Function(String, String)? onEditComment;
  /// A callback for when a user deletes a comment. Passes post ID and comment ID.
  final Function(String, String)? onDeleteComment;
  /// A callback for when a user replies to a comment. Passes the comment ID.
  final Function(String)? onReplyToComment;

  /// Creates a [CommentThread] widget.
  const CommentThread({
    super.key,
    required this.comments,
    required this.postId,
    this.currentUserId,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
    this.onLikeComment,
    this.onUnlikeComment,
    this.onEditComment,
    this.onDeleteComment,
    this.onReplyToComment,
  });

  @override
  State<CommentThread> createState() => _CommentThreadState();
}

/// The state for the [CommentThread] widget.
class _CommentThreadState extends State<CommentThread> {
  /// The scroll controller for the list of comments.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listens to the scroll position to trigger loading more comments when the
  /// user reaches the end of the list.
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (widget.hasMore && !widget.isLoading) {
        widget.onLoadMore?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isEmpty && !widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No comments yet. Be the first to comment!',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Comment count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${widget.comments.length} ${widget.comments.length == 1 ? 'comment' : 'comments'}',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
        // Comment list
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: widget.comments.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < widget.comments.length) {
                final comment = widget.comments[index];
                final canEdit = comment.authorId == widget.currentUserId;
                final canDelete = comment.authorId == widget.currentUserId;

                return CommentItem(
                  comment: comment,
                  canEdit: canEdit,
                  canDelete: canDelete,
                  canLike: true,
                  isLiked: false, // TODO: Implement like tracking
                  likeCount: 0, // TODO: Implement like count
                  onLike: canEdit ? null : () {
                    widget.onLikeComment?.call(widget.postId, comment.id);
                  },
                  onUnlike: canEdit ? null : () {
                    widget.onUnlikeComment?.call(widget.postId, comment.id);
                  },
                  onEdit: canEdit ? () {
                    widget.onEditComment?.call(widget.postId, comment.id);
                  } : null,
                  onDelete: canDelete ? () {
                    widget.onDeleteComment?.call(widget.postId, comment.id);
                  } : null,
                  onReply: () {
                    widget.onReplyToComment?.call(comment.id);
                  },
                );
              } else {
                // Load more indicator
                return widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton(
                            onPressed: widget.onLoadMore,
                            child: const Text('Load more comments'),
                          ),
                        ),
                      );
              }
            },
          ),
        ),
      ],
    );
  }
}