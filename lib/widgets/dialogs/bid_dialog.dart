import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../design_system/popup_theme.dart';
import '../../services/bidding_service.dart';
import '../../models/job_model.dart';

/// Dialog for submitting job bids with cover message and urgency options
class BidDialog extends StatefulWidget {
  final Job job;
  final bool isStormWork;

  const BidDialog({
    super.key,
    required this.job,
    this.isStormWork = false,
  });

  @override
  State<BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  final TextEditingController _messageController = TextEditingController();
  final BiddingService _biddingService = BiddingService();
  bool _isUrgent = false;
  bool _immediateAvailability = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          JJSnackBar.showError(
            context: context,
            message: 'Please sign in to submit bids',
          );
        }
        return;
      }

      BidResult result;

      if (widget.isStormWork) {
        result = await _biddingService.submitStormBid(
          stormId: widget.job.id,
          stormName: widget.job.jobTitle ?? 'Storm Job',
          contractor: widget.job.company,
          specialRequirements: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
          immediateAvailability: _immediateAvailability,
        );
      } else {
        result = await _biddingService.submitJobBid(
          jobId: widget.job.id,
          jobTitle: widget.job.jobTitle ?? 'Job Title',
          company: widget.job.company,
          coverMessage: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
          isUrgent: _isUrgent,
        );
      }

      if (mounted) {
        if (result.success) {
          Navigator.of(context).pop(true);
          JJSnackBar.showSuccess(
            context: context,
            message: result.message,
          );
        } else {
          JJSnackBar.showError(
            context: context,
            message: result.error ?? 'Failed to submit bid',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'An error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PopupThemeData.alertDialog();
    return Dialog(
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.borderRadius,
        side: BorderSide(
          color: theme.borderColor,
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: theme.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isStormWork ? Icons.flash_on : Icons.work,
                    color: AppTheme.white,
                    size: AppTheme.iconSm,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isStormWork ? 'Storm Work Application' : 'Submit Job Bid',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      Text(
                        widget.job.jobTitle ?? 'Job Title',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                  color: AppTheme.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Job details
            JJCard(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: AppTheme.iconSm,
                        color: AppTheme.accentCopper,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          widget.job.company,
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.job.location.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: AppTheme.iconSm,
                          color: AppTheme.accentCopper,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Text(
                            widget.job.location,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.job.classification!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        Icon(
                          Icons.engineering,
                          size: AppTheme.iconSm,
                          color: AppTheme.accentCopper,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Text(
                            widget.job.classification ?? 'Classification',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Cover message / Special requirements
            JJTextField(
              label: widget.isStormWork ? 'Special Requirements (Optional)' : 'Cover Message (Optional)',
              hintText: widget.isStormWork
                  ? 'Any special requirements or availability notes...'
                  : 'Tell the employer why you\'re the right fit...',
              controller: _messageController,
              maxLines: 3,
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Options
            if (widget.isStormWork)
              CheckboxListTile(
                value: _immediateAvailability,
                onChanged: (value) {
                  setState(() {
                    _immediateAvailability = value ?? false;
                  });
                },
                title: Text(
                  'Available for immediate deployment',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                activeColor: AppTheme.accentCopper,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              )
            else
              CheckboxListTile(
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value ?? false;
                  });
                },
                title: Text(
                  'Mark as urgent application',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                activeColor: AppTheme.accentCopper,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),

            const SizedBox(height: AppTheme.spacingLg),

            // Actions
            Row(
              children: [
                Expanded(
                  child: JJButton(
                    text: 'Cancel',
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    variant: JJButtonVariant.secondary,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: JJButton(
                    text: _isSubmitting ? 'Submitting...' : 'Submit Bid',
                    icon: _isSubmitting ? null : Icons.send,
                    onPressed: _isSubmitting ? null : _submitBid,
                    variant: JJButtonVariant.primary,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}