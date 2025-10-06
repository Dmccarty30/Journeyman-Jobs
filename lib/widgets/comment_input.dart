import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../features/crews/providers/feed_provider.dart';

/// A user input widget for adding comments to a post.
///
/// This widget starts in a collapsed state, showing a simple "Add a comment..."
/// prompt. When tapped, it expands into a multi-line text field with controls
/// for posting or canceling the comment.
class CommentInput extends StatefulWidget {
  /// The unique identifier of the post to which the comment will be added.
  final String postId;
  /// A callback function that is invoked when a comment is successfully added.
  final VoidCallback onCommentAdded;
  /// The ID of the user who is posting the comment.
  final String? currentUserId;
  /// The name of the user who is posting the comment.
  final String? currentUserName;

  /// Creates an instance of [CommentInput].
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

/// The state for the [CommentInput] widget.
class _CommentInputState extends State<CommentInput> {
  /// The controller for the text input field.
  final TextEditingController _commentController = TextEditingController();
  /// The focus node to manage the focus state of the input field.
  final FocusNode _commentFocusNode = FocusNode();
  /// A flag to control the collapsed/expanded state of the widget.
  bool _isExpanded = false;
  /// A flag to prevent duplicate submissions by disabling the send button during a request.
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  /// Toggles the UI between its collapsed and expanded input states.
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _commentFocusNode.requestFocus();
      }
    });
  }

  /// Validates and submits the user's comment.
  ///
  /// Handles UI updates for the loading state and shows SnackBars for feedback.
  /// Invokes the [onCommentAdded] callback on success.
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