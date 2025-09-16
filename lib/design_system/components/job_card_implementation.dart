import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../app_theme.dart';
import '../../electrical_components/circuit_pattern_painter.dart';

/// Job Card Implementation following the IBEW electrical theme
/// with proper touch targets for workers wearing gloves
class JobCardImplementation extends StatelessWidget {
  final Job job;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBidNow;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const JobCardImplementation({
    super.key,
    required this.job,
    this.onViewDetails,
    this.onBidNow,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        padding: padding ?? const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.primaryNavy, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle electrical circuit pattern in background
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: CircuitPatternPainter(
                    color: AppTheme.primaryNavy,
                    strokeWidth: 1.0,
                  ),
                ),
              ),
            ),
            
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Local and Classification
                _buildHeader(),
                const SizedBox(height: 20.0),
                
                // Grid Layout
                _buildGridContent(),
                
                const SizedBox(height: 24.0),
                
                // Action Buttons (minimum 48px touch targets)
                _buildActionButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Local info with electrical icon
        Row(
          children: [
            Icon(
              Icons.electrical_services,
              color: AppTheme.accentCopper,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            RichText(
              text: TextSpan(
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.black,
                ),
                children: [
                  TextSpan(
                    text: 'Local: ',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  TextSpan(
                    text: '${job.localNumber ?? job.local ?? 'N/A'}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Classification badge with electrical styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentCopper.withValues(alpha: 0.1),
                AppTheme.accentCopper.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(color: AppTheme.accentCopper, width: 1.0),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            job.classification ?? 'N/A',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Contractor | Wages
        _buildGridRow(
          leftLabel: 'Contractor:',
          leftValue: job.company,
          rightLabel: 'Wages:',
          rightValue: _formatWages(),
        ),
        const SizedBox(height: 20.0),
        
        // Row 2: Location | Hours
        _buildGridRow(
          leftLabel: 'Location:',
          leftValue: job.location,
          rightLabel: 'Hours:',
          rightValue: job.hours?.toString() ?? 'TBD',
        ),
        const SizedBox(height: 20.0),
        
        // Row 3: Start Date | Per Diem
        _buildGridRow(
          leftLabel: 'Start Date:',
          leftValue: job.startDate ?? job.datePosted ?? 'TBD',
          rightLabel: 'Per Diem:',
          rightValue: job.perDiem ?? 'N/A',
        ),
        const SizedBox(height: 20.0),
        
        // Row 4: Type of Work (Full Width)
        _buildFullWidthRow(
          label: 'Type of Work:',
          value: job.typeOfWork ?? 'N/A',
        ),
        const SizedBox(height: 20.0),
        
        // Row 5: Notes/Requirements (Right side only)
        _buildNotesRow(
          label: 'Notes/Requirements:',
          value: job.qualifications ?? job.jobDescription ?? job.jobTitle ?? '',
        ),
      ],
    );
  }

  Widget _buildGridRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Row(
      children: [
        // Left column
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.bodyMedium.copyWith(
                height: 1.5,
                color: AppTheme.black,
              ),
              children: [
                TextSpan(
                  text: '$leftLabel ',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                TextSpan(
                  text: leftValue,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20.0),
        // Right column
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.bodyMedium.copyWith(
                height: 1.5,
                color: AppTheme.black,
              ),
              children: [
                TextSpan(
                  text: '$rightLabel ',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                TextSpan(
                  text: rightValue,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullWidthRow({
    required String label,
    required String value,
  }) {
    return RichText(
      text: TextSpan(
        style: AppTheme.bodyMedium.copyWith(
          height: 1.5,
          color: AppTheme.black,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          TextSpan(
            text: value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.normal,
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        // Empty left column
        const Expanded(child: SizedBox()),
        const SizedBox(width: 20.0),
        // Right column with Notes/Requirements
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.bodyMedium.copyWith(
                height: 1.6,
                color: AppTheme.black,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.0, // Minimum touch target for gloved hands
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                side: BorderSide(color: AppTheme.primaryNavy, width: 2.0),
              ),
              child: Text(
                'Details',
                style: AppTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: SizedBox(
            height: 48.0, // Minimum touch target for gloved hands
            child: ElevatedButton(
              onPressed: onBidNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                side: BorderSide(color: AppTheme.secondaryCopper, width: 2.0),
                elevation: 2.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt,
                    size: 16.0,
                    color: AppTheme.white,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Bid',
                    style: AppTheme.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatWages() {
    if (job.wage != null) {
      return '\$${job.wage!.toStringAsFixed(2)}/hr';
    }
    return 'Contact Local';
  }
}
