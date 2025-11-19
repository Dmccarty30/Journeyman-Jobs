import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import '../features/crews/models/tailboard.dart';
import 'comment_item.dart';

class CommentThread extends StatefulWidget {
  final List<Comment> comments;
  final String postId;
  final String? currentUserId;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final Function(String, String)? onLikeComment;
  final Function(String, String)? onUnlikeComment;
  final Function(String, String)? onEditComment;
  final Function(String, String)? onDeleteComment;
  final Function(String)? onReplyToComment;

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

class _CommentThreadState extends State<CommentThread> {
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