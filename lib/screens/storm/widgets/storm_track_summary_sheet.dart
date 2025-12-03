import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/storm_track.dart';

class StormTrackSummarySheet extends StatelessWidget {
  final StormTrack track;

  const StormTrackSummarySheet({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Pay Summary: ${track.stormType}',
                  style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _buildSummaryCard(
            child: Column(
              children: [
                _buildTitleRow('Total Estimated Pay', currencyFormat.format(track.totalPay), isTotal: true),
                const Divider(height: AppTheme.spacingLg),

                // Hourly Pay Breakdown
                _buildSubHeader('Hourly Pay Breakdown'),
                _buildDetailRow(
                  'Mobilization',
                  '${track.mobilizationHours} hrs @ ${currencyFormat.format(track.payRate)} (2x)',
                  currencyFormat.format(track.mobilizationPay),
                ),
                _buildDetailRow(
                  'Working',
                  '${track.workingHours} hrs @ ${currencyFormat.format(track.payRate)} (2x)',
                  currencyFormat.format(track.workingPay),
                ),
                _buildDetailRow(
                  'De-mobilization',
                  '${track.demobilizationHours} hrs @ ${currencyFormat.format(track.payRate)} (1.5x)',
                  currencyFormat.format(track.demobilizationPay),
                ),
                _buildTitleRow('Total Hourly', currencyFormat.format(track.totalHourlyPay)),
                const SizedBox(height: AppTheme.spacingMd),

                // Per Diem Breakdown
                _buildSubHeader('Per Diem'),
                 _buildDetailRow(
                  'Days Worked',
                  '${track.totalDays} days @ ${currencyFormat.format(track.perDiem)} / day',
                  currencyFormat.format(track.perDiemPay),
                ),
                const SizedBox(height: AppTheme.spacingMd),


                // Other Income
                _buildSubHeader('Bonuses & Reimbursements'),
                 _buildDetailRow(
                  'Travel Reimbursement',
                  '',
                  currencyFormat.format(track.travelReimbursement),
                ),
                 _buildDetailRow(
                  'Completion Bonus',
                  '',
                  currencyFormat.format(track.completionBonus),
                ),
              ],
            ),
          ),
           const SizedBox(height: AppTheme.spacingLg),
           Text(
            '*This is an estimate. Actual pay may vary based on contractor agreements and final hours.',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textLight),
            textAlign: TextAlign.center,
           ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: child,
    );
  }

  Widget _buildTitleRow(String title, String amount, {bool isTotal = false}) {
    final style = isTotal 
        ? AppTheme.headlineMedium.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.bold)
        : AppTheme.titleLarge.copyWith(color: AppTheme.primaryNavy);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style.copyWith(fontWeight: FontWeight.bold)),
          Text(amount, style: style),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingSm, bottom: AppTheme.spacingXs),
      child: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildDetailRow(String label, String calculation, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodyMedium),
                if (calculation.isNotEmpty)
                  Text(
                    calculation,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                  ),
              ],
            ),
          ),
          Text(amount, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
