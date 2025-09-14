import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../models/storm_contractor.dart';

/// A card widget displaying contractor details using RichText with icons
/// Shows contractor information in a two-span format: bold labels and bracketed values
class ContractorCard extends StatelessWidget {
  const ContractorCard({
    required this.contractor,
    super.key,
    this.onDetails,
    this.onBid,
  });
  
  final StormContractor contractor;
  final VoidCallback? onDetails;
  final VoidCallback? onBid;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Contractor | Starting Local
            _buildTwoColumnRow(
              leftLabel: 'Contractor',
              leftValue: contractor.contractorName.isNotEmpty ? contractor.contractorName : 'N/A',
              rightLabel: 'Starting Local',
              rightValue: contractor.workingLocal ?? 'N/A',
            ),
            const SizedBox(height: 8),

            // Row 2: Show-up location | Start Time
            _buildTwoColumnRow(
              leftLabel: 'Show-up location',
              leftValue: contractor.showUpLocation.isNotEmpty ? contractor.showUpLocation : 'N/A',
              rightLabel: 'Start Time',
              rightValue: _formatShowUpTime(contractor.showUpTime),
            ),
            const SizedBox(height: 8),

            // Row 3: Pay Scale | Working Conditions
            _buildTwoColumnRow(
              leftLabel: 'Pay Scale',
              leftValue: contractor.payScale ?? (contractor.localWages.isNotEmpty ? contractor.localWages : 'N/A'),
              rightLabel: 'Working Conditions',
              rightValue: contractor.workingConditions ?? 'N/A',
            ),
            const SizedBox(height: 8),

            // Row 4: Position Requested | Positions Available
            _buildTwoColumnRow(
              leftLabel: 'Position Requested',
              leftValue: contractor.positionRequested ?? 'N/A',
              rightLabel: 'Positions Available',
              rightValue: '${contractor.requestedPositions - contractor.positionsFilled}',
              rightValueColor: (contractor.requestedPositions - contractor.positionsFilled) > 0 ? AppTheme.successGreen : null,
            ),
            const SizedBox(height: 8),

            // Row 5: Utility | Working Local
            _buildTwoColumnRow(
              leftLabel: 'Utility',
              leftValue: contractor.utility ?? 'N/A',
              rightLabel: 'Working Local',
              rightValue: contractor.workingLocal ?? 'N/A',
            ),
            const SizedBox(height: 8),

            // Row 6: Notes/Requirements (full width)
            if (contractor.notesRequirements != null && contractor.notesRequirements!.isNotEmpty)
              _buildInfoRow(
                label: 'Notes/Requirements',
                value: contractor.notesRequirements!,
              ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Details button (outlined with AppTheme)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showContractorDetailsDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: AppTheme.primaryNavy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bid Now button (copper gradient with flash icon)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentCopper,
                          AppTheme.accentCopper.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: onBid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppTheme.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flash_on,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Bid Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  /// Helper method to build two-column info rows
  Widget _buildTwoColumnRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    Color? leftValueColor,
    Color? rightValueColor,
  }) => Row(
      children: [
        // Left column
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForLabel(leftLabel),
                size: AppTheme.iconXs,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$leftLabel: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: leftValue,
                        style: TextStyle(
                          color: leftValueColor ?? AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right column
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForLabel(rightLabel),
                size: AppTheme.iconXs,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$rightLabel: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: rightValue,
                        style: TextStyle(
                          color: rightValueColor ?? AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

  /// Helper method to build single info rows (full width)
  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getIconForLabel(label),
          size: AppTheme.iconXs,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  /// Maps labels to appropriate electrical-themed icons
  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'contractor':
        return Icons.business;
      case 'starting local':
      case 'working local':
        return Icons.location_on;
      case 'show-up location':
        return Icons.place;
      case 'start time':
        return Icons.access_time;
      case 'pay scale':
      case 'local wages':
        return Icons.attach_money;
      case 'working conditions':
        return Icons.work;
      case 'position requested':
        return Icons.assignment_ind;
      case 'positions available':
        return Icons.people;
      case 'utility':
        return Icons.electrical_services;
      case 'notes/requirements':
        return Icons.info;
      default:
        return Icons.info_outline;
    }
  }

  /// Format show up time
  String _formatShowUpTime(DateTime? dt) {
    if (dt == null) return 'TBD';
    try {
      final time = TimeOfDay.fromDateTime(dt);
      final date = '${dt.month}/${dt.day}';
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$date • $hour:${time.minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return dt.toString();
    }
  }

  /// Show the contractor details dialog
  void _showContractorDetailsDialog(BuildContext context) {
    // Call the custom onDetails callback if provided, otherwise show dialog directly
    if (onDetails != null) {
      onDetails!();
    } else {
      // Fallback: show dialog directly if no callback provided
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(contractor.contractorName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Contractor', contractor.contractorName),
                _buildDetailRow('Local Wages', contractor.localWages),
                _buildDetailRow('Show-up Location', contractor.showUpLocation),
                _buildDetailRow('Start Time', _formatShowUpTime(contractor.showUpTime)),
                if (contractor.utility != null) _buildDetailRow('Utility', contractor.utility!),
                if (contractor.workingLocal != null) _buildDetailRow('Working Local', contractor.workingLocal!),
                if (contractor.payScale != null) _buildDetailRow('Pay Scale', contractor.payScale!),
                if (contractor.workingConditions != null) _buildDetailRow('Working Conditions', contractor.workingConditions!),
                if (contractor.positionRequested != null) _buildDetailRow('Position Requested', contractor.positionRequested!),
                _buildDetailRow('Positions Available', '${contractor.requestedPositions - contractor.positionsFilled}'),
                if (contractor.notesRequirements != null) _buildDetailRow('Notes/Requirements', contractor.notesRequirements!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  /// Helper method to build detail rows for the dialog
  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getIconForLabel(label),
          size: AppTheme.iconXs,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
