import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../models/tailboard.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final bool canEdit;
  final bool canDelete;
  final bool canLike;
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;

  const CommentItem({
    super.key,
    required this.comment,
    this.canEdit = false,
    this.canDelete = false,
    this.canLike = true,
    this.isLiked = false,
    this.likeCount = 0,
    this.onLike,
    this.onUnlike,
    this.onEdit,
    this.onDelete,
    this.onReply,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showActionMenu = false;

  @override
  Widget build(BuildContext context) {
    final isEdited = widget.comment.editedAt != null;
    final formattedDate = DateFormat('MMM d, yyyy h:mm a').format(widget.comment.postedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentCopper.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.person,
              size: 20,
              color: AppTheme.accentCopper,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment header with user info and timestamp
                Row(
                  children: [
                    Text(
                      'User ${widget.comment.authorId.substring(0, 6)}...', // Show first 6 chars of ID
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (isEdited) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                    const Spacer(),
                    // Like button
                    if (widget.canLike)
                      GestureDetector(
                        onTap: widget.isLiked ? widget.onUnlike : widget.onLike,
                        child: Row(
                          children: [
                            Icon(
                              widget.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: widget.isLiked ? AppTheme.accentCopper : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.likeCount}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Action menu button
                    if (widget.canEdit || widget.canDelete)
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        color: AppTheme.textSecondary,
                        onPressed: () {
                          setState(() {
                            _showActionMenu = !_showActionMenu;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment content
                Text(
                  widget.comment.content,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                // Action menu popup
                if (_showActionMenu && (widget.canEdit || widget.canDelete))
                  Positioned(
                    right: 0,
                    top: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (widget.canEdit)
                            ListTile(
                              title: const Text('Edit'),
                              onTap: () {
                                setState(() {
                                  _showActionMenu = false;
                                });
                                widget.onEdit?.call();
                              },
                            ),
                          if (widget.canDelete)
                            ListTile(
                              title: const Text('Delete'),
                              onTap: () {
                                setState(() {
                                  _showActionMenu = false;
                                });
                                widget.onDelete?.call();
                              },
                            ),
                          ListTile(
                            title: const Text('Report'),
                            onTap: () {
                              setState(() {
                                _showActionMenu = false;
                              });
                              // TODO: Implement report functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                // Reply button
                if (widget.onReply != null)
                  TextButton(
                    onPressed: widget.onReply,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Reply',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}