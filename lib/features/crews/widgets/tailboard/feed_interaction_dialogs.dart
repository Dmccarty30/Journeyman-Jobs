// Flutter & Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Journeyman Jobs - Absolute imports
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/providers/feed_provider.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';

// Tailboard widget imports
import 'electrical_dialog_background.dart';
import 'electrical_text_field.dart';
import 'dialog_actions.dart';

/// Dialog for sharing jobs with crew members
class ShareJobDialog extends ConsumerStatefulWidget {
  const ShareJobDialog({super.key});

  @override
  ConsumerState<ShareJobDialog> createState() => _ShareJobDialogState();
}

class _ShareJobDialogState extends ConsumerState<ShareJobDialog> {
  final TextEditingController _messageController = TextEditingController();
  Job? _selectedJob;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.read(selectedCrewProvider);
    final jobsAsync = ref.watch(recentJobsProvider);

    return ElectricalDialogBackground(
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Job with Crew',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Job selection dropdown
            _buildJobSelectionList(jobsAsync),

            const SizedBox(height: 16),

            // Custom message field
            ElectricalTextField(
              controller: _messageController,
              maxLines: 3,
              labelText: 'Add a custom message (optional)',
              hintText: 'Share your thoughts about this job...',
            ),

            const SizedBox(height: 16),

            // Actions
            DialogActions(
              onConfirm: () => _handleShareJob(),
              confirmText: 'Share Job',
            ),
          ],
        ),
      ),
    );
  }

  /// Build job selection dropdown list
  Widget _buildJobSelectionList(AsyncValue<List<Job>> jobsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Job to Share',
          style: TextStyle(
            color: AppTheme.textOnDark,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.borderCopper.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: jobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No jobs available to share.',
                    style: TextStyle(color: AppTheme.mediumGray),
                  ),
                );
              }
              return DropdownButtonFormField<Job>(
                value: _selectedJob,
                decoration: InputDecoration(
                  labelText: 'Select Job',
                  labelStyle: TextStyle(color: AppTheme.mediumGray),
                  filled: true,
                  fillColor: AppTheme.secondaryNavy,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                dropdownColor: AppTheme.secondaryNavy,
                style: TextStyle(color: AppTheme.textOnDark),
                items: jobs.map<DropdownMenuItem<Job>>((Job job) {
                  return DropdownMenuItem<Job>(
                    value: job,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          job.jobTitle ?? 'Untitled Job',
                          style: TextStyle(
                            color: AppTheme.textOnDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ...[
                        const SizedBox(height: 2),
                        Text(
                          job.company!,
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Job? job) {
                  setState(() {
                    _selectedJob = job;
                  });
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                ),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading jobs: $error',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Handle sharing job
  void _handleShareJob() async {
    final selectedCrew = ref.read(selectedCrewProvider);
    final currentUser = ref.read(auth_providers.currentUserProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'No crew selected. Please select a crew to share the job.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    if (_selectedJob == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Please select a job to share.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    if (currentUser == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'User not authenticated. Please log in.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    try {
      // Create post with job details
      await ref.read(postCreationProvider).createPost(
        crewId: selectedCrew.id,
        content: 'Job Shared: ${_selectedJob!.jobTitle ?? 'Untitled Job'}',
      );

      if (!mounted) return;

      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Job shared successfully!',
        type: ElectricalNotificationType.success,
      );

      // Force refresh of global feed
      ref.invalidate(globalFeedProvider);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Failed to share job: ${e.toString()}',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }
}

/// Dialog for creating new posts in the crew feed
class CreatePostDialog extends ConsumerStatefulWidget {
  const CreatePostDialog({super.key});

  @override
  ConsumerState<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends ConsumerState<CreatePostDialog> {
  final TextEditingController _postContentController = TextEditingController();
  final int _maxCharacters = 1000;
  late int _charactersRemaining;

  @override
  void initState() {
    super.initState();
    _charactersRemaining = _maxCharacters;
    _postContentController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _postContentController.removeListener(_updateCharacterCount);
    _postContentController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _charactersRemaining = _maxCharacters - _postContentController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return ElectricalDialogBackground(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Post',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Post content field
              ElectricalTextField(
                controller: _postContentController,
                maxLines: 5,
                labelText: 'What\'s on your mind?',
                hintText: 'Share your thoughts with the crew...',
                onChanged: (value) {
                  setModalState(() {
                    _charactersRemaining = _maxCharacters - value.length;
                  });
                },
              ),

              // Character count
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_charactersRemaining characters remaining',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _charactersRemaining < 100
                        ? AppTheme.errorRed
                        : AppTheme.mediumGray,
                    fontWeight: _charactersRemaining < 100
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Post attachments section
              _buildPostAttachmentSection(),

              const SizedBox(height: 16),

              // Actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Attachment button
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: AppTheme.accentCopper,
                    ),
                    onPressed: () {
                      JJElectricalNotifications.showElectricalToast(
                        context: context,
                        message: 'Media upload coming soon!',
                        type: ElectricalNotificationType.info,
                      );
                    },
                  ),

                  // Post actions
                  DialogActions(
                    onConfirm: () async => _handleCreatePost(),
                    confirmText: 'Post',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build post attachment section
  Widget _buildPostAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderCopper.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image_outlined,
            color: AppTheme.mediumGray,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Add photos or files',
            style: TextStyle(
              color: AppTheme.mediumGray,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.add_circle_outline,
            color: AppTheme.accentCopper,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Handle creating post
  Future<void> _handleCreatePost() async {
    final content = _postContentController.text.trim();
    if (content.isEmpty) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Post content cannot be empty.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    final selectedCrew = ref.read(selectedCrewProvider);
    final currentUser = ref.read(auth_providers.currentUserProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'No crew selected. Please select a crew to post.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    if (currentUser == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'User not authenticated. Please log in.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    try {
      // Create post with immediate real-time updates
      await ref.read(postCreationProvider).createPost(
        crewId: selectedCrew.id,
        content: content,
      );

      if (!mounted) return;

      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Post published to crew feed!',
        type: ElectricalNotificationType.success,
      );

      // Force immediate refresh of the global feed
      ref.invalidate(globalFeedProvider);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Failed to create post: ${e.toString()}',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }
}

/// Widget for previewing post content before publishing
class PostPreviewCard extends StatelessWidget {
  final String content;
  final String? authorName;
  final DateTime timestamp;

  const PostPreviewCard({
    super.key,
    required this.content,
    this.authorName,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderCopper.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          if (authorName != null) ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      authorName!.isNotEmpty ? authorName![0].toUpperCase() : 'A',
                      style: TextStyle(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName!,
                        style: TextStyle(
                          color: AppTheme.textOnDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Post content
          Text(
            content,
            style: TextStyle(
              color: AppTheme.textOnDark,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}