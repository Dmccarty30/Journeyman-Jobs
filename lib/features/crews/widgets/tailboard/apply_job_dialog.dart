import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tailboard_theme.dart';
import '../../../../models/job_model.dart';

class ApplyJobDialog extends ConsumerStatefulWidget {
  const ApplyJobDialog({
    required this.job,
    super.key,
  });

  final Job job;

  @override
  ConsumerState<ApplyJobDialog> createState() => _ApplyJobDialogState();
}

class _ApplyJobDialogState extends ConsumerState<ApplyJobDialog> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop(true); // Return true to indicate success
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Application submitted successfully!'),
          backgroundColor: TailboardTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TailboardTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
        side: const BorderSide(
          color: TailboardTheme.copper,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(TailboardTheme.spacingL),
              decoration: const BoxDecoration(
                color: TailboardTheme.backgroundDark,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(TailboardTheme.radiusL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply for Job',
                          style: TailboardTheme.headingMedium,
                        ),
                        const SizedBox(height: TailboardTheme.spacingXS),
                        Text(
                          widget.job.jobTitle ?? 'Unknown Position',
                          style: TailboardTheme.bodyMedium.copyWith(
                            color: TailboardTheme.copper,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(TailboardTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send a message with your application (optional):',
                    style: TailboardTheme.bodyMedium,
                  ),
                  const SizedBox(height: TailboardTheme.spacingS),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: TailboardTheme.bodyMedium,
                    decoration: TailboardTheme.inputDecoration(
                      hintText: 'I am interested in this position because...',
                    ),
                  ),
                  const SizedBox(height: TailboardTheme.spacingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: TailboardTheme.textButton,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: TailboardTheme.spacingM),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        style: TailboardTheme.primaryButton,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(TailboardTheme.textPrimary),
                                ),
                              )
                            : const Text('Submit Application'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
