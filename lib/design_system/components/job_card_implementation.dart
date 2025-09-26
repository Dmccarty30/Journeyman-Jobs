import 'package:flutter/material.dart';
import '../../models/job_model.dart';

/// Job Card Implementation following the exact wireframe specification
/// from job-card-implementation.md
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
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Local and Classification
            _buildHeader(),
            const SizedBox(height: 20.0),
            
            // Grid Layout
            _buildGridContent(),
            
            const SizedBox(height: 24.0),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Local info
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: '-apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, \'Helvetica Neue\', Arial, sans-serif',
              fontSize: 18.0,
              color: Colors.black,
            ),
            children: [
              const TextSpan(
                text: 'Local: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
              TextSpan(
                text: '${job.localNumber ?? job.local ?? 'N/A'}',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        
        // Classification badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            border: Border.all(color: const Color(0xFFD0D0D0), width: 1.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            job.classification ?? 'N/A',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
              fontFamily: '-apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, \'Helvetica Neue\', Arial, sans-serif',
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
              style: const TextStyle(
                fontFamily: '-apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, \'Helvetica Neue\', Arial, sans-serif',
                fontSize: 15.0,
                height: 1.5,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: '$leftLabel ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
                TextSpan(
                  text: leftValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
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
              style: const TextStyle(
                fontFamily: '-apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, \'Helvetica Neue\', Arial, sans-serif',
                fontSize: 15.0,
                height: 1.5,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: '$rightLabel ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
                TextSpan(
                  text: rightValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
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
        style: const TextStyle(
          fontFamily: '-apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, \'Helvetica Neue\', Arial, sans-serif',
          fontSize: 15.0,
          height: 1.5,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
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
              style: const TextStyle(
                fontFamily: '-apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, \'Helvetica Neue\', Arial, sans-serif',
                fontSize: 15.0,
                height: 1.6,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
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
          child: OutlinedButton(
            onPressed: onViewDetails,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              side: const BorderSide(color: Colors.black, width: 2.0),
            ),
            child: const Text(
              'Details',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: ElevatedButton(
            onPressed: onBidNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEB3B),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              side: const BorderSide(color: Color(0xFFF9A825), width: 2.0),
            ),
            child: const Text(
              'Bid',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
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
