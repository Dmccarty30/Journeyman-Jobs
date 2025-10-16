import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../models/pay_scale_model.dart';

/// A card widget displaying pay scale details using RichText
/// Shows pay scale information in a two-span format: bold labels and values
/// Follows the same structure and styling as RichTextJobCard
class RichTextPayScaleCard extends StatelessWidget {

  const RichTextPayScaleCard({
    required this.payScale, super.key,
    this.onDetails,
    this.onViewWageSheet,
  });
  final PayScale payScale;
  final VoidCallback? onDetails;
  final VoidCallback? onViewWageSheet;

  @override
  Widget build(BuildContext context) => Container(
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
            // Row 1: Local | Location
            _buildTwoColumnRow(
              leftLabel: 'Local',
              leftValue: payScale.localIdentifier,
              rightLabel: 'Location',
              rightValue: payScale.location,
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.accentCopper, height: 1, thickness: 1.5),
            const SizedBox(height: 12),

            // Row 2: Hourly Rate | Total Package
            _buildTwoColumnRow(
              leftLabel: 'Hourly Rate',
              leftValue: payScale.formattedHourlyRate,
              rightLabel: 'Total Package',
              rightValue: payScale.formattedTotalPackage,
            ),
            const SizedBox(height: 12),

            // Row 3: Yearly Salary | Adjusted Wage
            _buildTwoColumnRow(
              leftLabel: 'Yearly Salary',
              leftValue: payScale.formattedYearlySalary,
              rightLabel: 'Adjusted Wage',
              rightValue: payScale.formattedAdjustedWage,
            ),
            const SizedBox(height: 12),

            // Row 4: Cost of Living | Per Diem
            _buildTwoColumnRow(
              leftLabel: 'Cost of Living',
              leftValue: payScale.formattedCostOfLiving,
              rightLabel: 'Per Diem',
              rightValue: payScale.perDiem != null ? '\$${payScale.perDiem!.toStringAsFixed(0)}' : 'N/A',
            ),
            const SizedBox(height: 12),

            // Row 5: Health & Welfare | Pension
            _buildTwoColumnRow(
              leftLabel: 'Health & Welfare',
              leftValue: payScale.healthAndWelfare != null ? '\$${payScale.healthAndWelfare!.toStringAsFixed(2)}' : 'N/A',
              rightLabel: 'Defined Pension',
              rightValue: payScale.definedPension != null ? '\$${payScale.definedPension!.toStringAsFixed(2)}' : 'N/A',
            ),
            const SizedBox(height: 12),

            // Row 6: 401K/Annuity | Contribution Pension
            _buildTwoColumnRow(
              leftLabel: '401K/Annuity',
              leftValue: payScale.pension401k != null ? '\$${payScale.pension401k!.toStringAsFixed(2)}' : 'N/A',
              rightLabel: 'Contribution Pension',
              rightValue: payScale.contributionPension != null ? '\$${payScale.contributionPension!.toStringAsFixed(2)}' : 'N/A',
            ),
            const SizedBox(height: 12),

            // Row 7: NEBF | Dues
            _buildTwoColumnRow(
              leftLabel: 'NEBF',
              leftValue: payScale.nebf != null ? '\$${payScale.nebf!.toStringAsFixed(2)}' : 'N/A',
              rightLabel: 'Dues',
              rightValue: payScale.dues ?? 'N/A',
            ),
            const SizedBox(height: 12),

            // Vacation Pay (full width if exists)
            if (payScale.vacationPay != null)
              _buildInfoRow(
                label: 'Vacation Pay',
                value: '\$${payScale.vacationPay!.toStringAsFixed(2)}',
              ),

            // Last Updated (full width)
            if (payScale.lastUpdated != null && payScale.lastUpdated!.isNotEmpty)
              _buildInfoRow(
                label: 'Last Updated',
                value: payScale.lastUpdated!,
              ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                // Details button (outlined with AppTheme)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetails,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // View Wage Sheet button (copper gradient)
                if (payScale.wageSheet != null && payScale.wageSheet!.isNotEmpty)
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
                        onPressed: onViewWageSheet,
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
                              Icons.open_in_new,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Wage Sheet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryNavy,
                            AppTheme.primaryNavy.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: onDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppTheme.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'View Pay Scale',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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

  /// Helper method to build two-column info rows (Local | Location)
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

  /// Helper method to build single info rows (full width)
  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) => RichText(
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
