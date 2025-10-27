import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../models/locals_record.dart';
import '../utils/text_formatting_wrapper.dart';


/// A card widget displaying local union information using RichText with icons
/// Shows local information in a two-span format: bold labels and bracketed values
class RichTextLocalCard extends StatelessWidget {
  const RichTextLocalCard({
    required this.local,
    super.key,
    this.onDetails,
  });

  final LocalsRecord local;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 8),
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
            // Row 1: Local Union | Classification
            _buildTwoColumnRow(
              leftLabel: 'Local Union',
              leftValue: local.localUnion.toString(),
              rightLabel: 'Classification',
              rightValue: toTitleCase(local.classification ?? 'Unknown'),
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.accentCopper, height: 1, thickness: 1.5),
            const SizedBox(height: 12),

            // Row 2: City | State
            _buildTwoColumnRow(
              leftLabel: 'City',
              leftValue: toTitleCase(local.city),
              rightLabel: 'State',
              rightValue: local.state.toUpperCase(),
            ),
            const SizedBox(height: 12),

            // Row 3: Address (full width if available)
            if (local.address?.isNotEmpty == true) ...[
              _buildInfoRow(
                label: 'Address',
                value: local.address!,
              ),
              const SizedBox(height: 12),
            ],

            // Row 4: Phone | Email
            if (local.phone.isNotEmpty || local.email.isNotEmpty) ...[
              _buildTwoColumnRow(
                leftLabel: 'Phone',
                leftValue: local.phone.isNotEmpty ? local.phone : 'N/A',
                rightLabel: 'Email',
                rightValue: local.email.isNotEmpty ? 'Available' : 'N/A',
                leftValueColor: local.phone.isNotEmpty ? AppTheme.accentCopper : null,
                rightValueColor: local.email.isNotEmpty ? AppTheme.accentCopper : null,
              ),
              const SizedBox(height: 12),
            ],

            // Row 5: Website (full width if available)
            if (local.website?.isNotEmpty == true) ...[
              _buildInfoRow(
                label: 'Website',
                value: 'Available',
                valueColor: AppTheme.accentCopper,
              ),
              const SizedBox(height: 20),
            ] else const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showLocalDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build two-column info rows
  Widget _buildTwoColumnRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    Color? leftValueColor,
    Color? rightValueColor,
  }) {
    return Row(
      children: [
        // Left column
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$leftLabel: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: leftValue,
                  style: TextStyle(
                    color: leftValueColor ?? AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Right column
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$rightLabel: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: rightValue,
                  style: TextStyle(
                    color: rightValueColor ?? AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to build single info rows (full width)
  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textLight,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Show the local details dialog
  void _showLocalDetails(BuildContext context) {
    if (onDetails != null) {
      onDetails!();
    } else {
      // If no callback provided, we could show a simple dialog or navigate
      // For now, just call the existing dialog functionality
      showDialog(
        context: context,
        builder: (context) => LocalDetailsDialog(local: local),
      );
    }
  }
}

/// Simple details dialog for local information
class LocalDetailsDialog extends StatelessWidget {
  const LocalDetailsDialog({super.key, required this.local});

  final LocalsRecord local;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
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
                          'IBEW Local ${local.localUnion}',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          '${toTitleCase(local.city)}, ${local.state.toUpperCase()}',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.white.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.white,
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (local.address?.isNotEmpty == true) ...[
                      _buildDetailRow('Address', local.address!),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],
                    if (local.phone.isNotEmpty) ...[
                      _buildDetailRow('Phone', local.phone),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],
                    if (local.email.isNotEmpty) ...[
                      _buildDetailRow('Email', local.email),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],
                    if (local.website?.isNotEmpty == true) ...[
                      _buildDetailRow('Website', local.website!),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],
                    if (local.classification != null) ...[
                      _buildDetailRow('Classification', toTitleCase(local.classification!)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}