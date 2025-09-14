import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/app_theme.dart';
import '../electrical_components/enhanced_backgrounds.dart' show VoltageLevel, EnhancedBackgrounds;
import '../models/job_model.dart';
import '../features/job_sharing/widgets/share_button.dart';
import '../features/job_sharing/widgets/share_modal.dart';
import '../features/job_sharing/providers/contact_provider.dart';
import '../services/job_sharing_service.dart';

/// Enhanced JobCard component with electrical theme
class EnhancedJobCard extends ConsumerStatefulWidget {
  /// Creates an EnhancedJobCard.
  ///
  /// The [job] and [variant] parameters are required.
  const EnhancedJobCard({
    required this.job, required this.variant, super.key,
    this.onTap,
    this.onViewDetails,
    this.onBidNow,
    this.onFavorite,
    this.onShare,
    this.isFavorited = false,
    this.margin,
    this.padding,
  });

  /// The job data to display
  final Job job;
  
  /// The variant of the job card to display
  final JobCardVariant variant;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Callback when the view details button is pressed
  final VoidCallback? onViewDetails;
  
  /// Callback when the bid now button is pressed
  final VoidCallback? onBidNow;
  
  /// Callback when the favorite button is pressed
  final VoidCallback? onFavorite;
  
  /// Callback when share is completed
  final Function(List<String> recipientIds, String? message)? onShare;
  
  /// Whether the job is favorited
  final bool isFavorited;
  
  /// Margin around the card
  final EdgeInsets? margin;
  
  /// Padding inside the card
  final EdgeInsets? padding;

  @override
  ConsumerState<EnhancedJobCard> createState() => _EnhancedJobCardState();
}

class _EnhancedJobCardState extends ConsumerState<EnhancedJobCard> {
  final JobSharingService _sharingService = JobSharingService();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case JobCardVariant.compact:
        return _buildCompactCard();
      case JobCardVariant.standard:
        return _buildStandardCard();
      case JobCardVariant.enhanced:
        return _buildFullCard();
    }
  }

  Widget _buildCompactCard() => Card(
        margin: widget.margin ?? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingSm),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'IBEW Local ${widget.job.local}',
                        style: AppTheme.captionBold.copyWith(
                          color: AppTheme.accentCopper,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        widget.job.title,
                        style: AppTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.job.location,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                _buildPayRate(),
                const SizedBox(width: AppTheme.spacingSm),
                _buildCompactActions(),
              ],
            ),
          ),
        ),
      );

  Widget _buildStandardCard() => Card(
        margin: widget.margin ?? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildHeader(),
                const SizedBox(height: AppTheme.spacingSm),
                _buildContent(),
                const SizedBox(height: AppTheme.spacingMd),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      );

  Widget _buildFullCard() => EnhancedBackgrounds.enhancedCardBackground(
        onTap: widget.onTap,
        margin: widget.margin ?? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        voltageLevel: _getVoltageLevel(),
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildEnhancedHeader(),
              const SizedBox(height: AppTheme.spacingSm),
              _buildStatusIndicator(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildEnhancedContent(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildElectricalDetails(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildEnhancedActionButtons(),
            ],
          ),
        ),
      );

  Widget _buildHeader() => Row(
        children: <Widget>[
          // Local indicator with electrical theme
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.electrical_services,
                  size: 12,
                  color: AppTheme.white,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  'LOCAL ${widget.job.local}',
                  style: AppTheme.captionBold.copyWith(
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Job type indicator
          if (_isStormWork())
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.warning,
                    size: 10,
                    color: AppTheme.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'STORM',
                    style: AppTheme.captionBold.copyWith(
                      color: AppTheme.white,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildFavoriteButton(),
          const SizedBox(width: AppTheme.spacingXs),
          _buildShareButton(),
        ],
      );

  Widget _buildEnhancedHeader() => Row(
        children: <Widget>[
          // Enhanced local indicator
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              boxShadow: const <BoxShadow>[AppTheme.shadowSm],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    size: 18,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'IBEW LOCAL',
                      style: AppTheme.captionBold.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      widget.job.local.toString(),
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Enhanced favorite and share buttons
          Row(
            children: [
              _buildFavoriteButton(),
              const SizedBox(width: AppTheme.spacingSm),
              _buildShareButton(),
            ],
          ),
        ],
      );

  Widget _buildStatusIndicator() {
    final bool isUrgent = _isStormWork();
    final bool isPriority = _isHighPriority();
    
    if (!isUrgent && !isPriority) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent 
            ? <Color>[AppTheme.errorRed, const Color(0xFFDC2626)]
            : <Color>[AppTheme.warningYellow, const Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: const <BoxShadow>[AppTheme.shadowXs],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isUrgent ? Icons.warning : Icons.priority_high,
            size: 16,
            color: AppTheme.white,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            isUrgent ? 'STORM RESTORATION' : 'HIGH PRIORITY',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.job.title,
            style: AppTheme.headingSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            children: <Widget>[
              const Icon(
                Icons.location_on,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: Text(
                  widget.job.location,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            children: <Widget>[
              Icon(
                _getClassificationIcon(widget.job.classification),
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                widget.job.classification,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              _buildPayRate(),
            ],
          ),
        ],
      );

  Widget _buildEnhancedContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.job.title,
            style: AppTheme.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildInfoChip(
                  Icons.location_on,
                  widget.job.location,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _buildInfoChip(
                  _getClassificationIcon(widget.job.classification),
                  widget.job.classification,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildElectricalDetails() => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: AppTheme.primaryNavy.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pay Rate',
                    style: AppTheme.captionBold.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.attach_money,
                        size: 18,
                        color: AppTheme.accentCopper,
                      ),
                      Text(
                        '${widget.job.payRate.toStringAsFixed(2)}/hr',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.accentCopper,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppTheme.primaryNavy.withValues(alpha: 0.2),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Start Date',
                    style: AppTheme.captionBold.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.primaryNavy,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        _formatDate(widget.job.startDate),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildInfoChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Expanded(
              child: Text(
                text,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildPayRate() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            '\$${widget.job.payRate.toStringAsFixed(2)}',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'per hour',
            style: AppTheme.captionRegular.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      );

  Widget _buildCompactActions() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShareButton(size: JJShareButtonSize.small),
          const SizedBox(width: AppTheme.spacingXs),
          IconButton(
            onPressed: widget.onFavorite,
            icon: Icon(
              widget.isFavorited ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorited ? AppTheme.errorRed : AppTheme.textSecondary,
              size: 18,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: const EdgeInsets.all(4),
          ),
        ],
      );

  Widget _buildActionButtons() => Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightGray,
                foregroundColor: AppTheme.primaryNavy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Details'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onBidNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Bid Now'),
            ),
          ),
        ],
      );

  Widget _buildEnhancedActionButtons() => Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.onBidNow,
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Quick Bid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                elevation: 2,
                shadowColor: AppTheme.accentCopper.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onViewDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryNavy,
                side: const BorderSide(
                  color: AppTheme.primaryNavy,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Details'),
            ),
          ),
        ],
      );

  Widget _buildFavoriteButton() => DecoratedBox(
        decoration: BoxDecoration(
          color: widget.isFavorited ? AppTheme.errorRed : AppTheme.lightGray,
          shape: BoxShape.circle,
          boxShadow: const <BoxShadow>[AppTheme.shadowSm],
        ),
        child: IconButton(
          onPressed: widget.onFavorite,
          icon: Icon(
            widget.isFavorited ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorited ? AppTheme.white : AppTheme.textSecondary,
            size: 20,
          ),
        ),
      );

  Widget _buildShareButton({JJShareButtonSize size = JJShareButtonSize.medium}) => 
      JJShareButton(
        size: size,
        onPressed: _isSharing ? null : _handleShare,
        isLoading: _isSharing,
        tooltip: 'Share job with colleagues',
      );

  void _handleShare() async {
    if (_isSharing) return;

    try {
      setState(() => _isSharing = true);

      // Get contacts
      final contactsState = ref.read(contactsProvider);
      final contacts = contactsState.maybeWhen(
        data: (contacts) => contacts,
        orElse: () => <UserModel>[],
      );

      if (!mounted) return;

      // Show share modal
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => JJShareModal(
            job: widget.job,
            contacts: contacts,
            onShare: (recipients, message) async {
              try {
                final shareId = await _sharingService.shareJob(
                  job: widget.job,
                  recipients: recipients,
                  message: message,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  
                  // Show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Job shared with ${recipients.length} ${recipients.length == 1 ? 'person' : 'people'}'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );

                  // Call callback if provided
                  widget.onShare?.call(
                    recipients.map((r) => r.id).toList(),
                    message,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text('Failed to share job'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            isSharing: _isSharing,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  IconData _getClassificationIcon(String classification) {
    switch (classification.toLowerCase()) {
      case 'journeyman lineman':
      case 'lineman':
        return Icons.electrical_services;
      case 'inside wireman':
      case 'wireman':
        return Icons.cable;
      case 'tree trimmer':
        return Icons.nature;
      case 'equipment operator':
        return Icons.construction;
      default:
        return Icons.work;
    }
  }

  bool _isStormWork() {
    return widget.job.title.toLowerCase().contains('storm') ||
        widget.job.description.toLowerCase().contains('emergency') ||
        (widget.job.additionalProperties?['stormWork'] as bool? ?? false);
  }

  bool _isHighPriority() {
    return widget.job.title.toLowerCase().contains('urgent') ||
        widget.job.description.toLowerCase().contains('priority') ||
        (widget.job.additionalProperties?['priority'] as bool? ?? false);
  }

  VoltageLevel _getVoltageLevel() {
    if (_isStormWork()) return VoltageLevel.high;
    if (_isHighPriority()) return VoltageLevel.medium;
    return VoltageLevel.low;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return '${difference}d';
    
    return '${date.month}/${date.day}';
  }
}

/// Variants for the job card display
enum JobCardVariant {
  compact,
  standard,
  enhanced,
}
