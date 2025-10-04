import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../features/crews/providers/feed_provider.dart';

class CommentInput extends StatefulWidget {
  final String postId;
  final VoidCallback onCommentAdded;
  final String? currentUserId;
  final String? currentUserName;

  const CommentInput({
    super.key,
    required this.postId,
    required this.onCommentAdded,
    this.currentUserId,
    this.currentUserName,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isExpanded = false;
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _commentFocusNode.requestFocus();
      }
    });
  }

  Future<void> _submitComment() async {
    if (_isSending) return;

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Notify parent that a comment was added
      widget.onCommentAdded();

      // Clear the input
      _commentController.clear();
      setState(() {
        _isExpanded = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isExpanded)
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: AppTheme.borderWidthThin,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add a comment...',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isExpanded)
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
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLines: 4,
                  minLines: 1,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    hintText: 'Write your comment...',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${2000 - _commentController.text.length} characters left',
                      style: AppTheme.bodySmall.copyWith(
                        color: _commentController.text.length > 1800
                            ? AppTheme.error
                            : AppTheme.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Text(
                            'Cancel',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSending ? null : _submitComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCopper,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Post',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}