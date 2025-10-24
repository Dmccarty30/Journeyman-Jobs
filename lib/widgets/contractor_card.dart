import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contractor_model.dart';
import '../design_system/app_theme.dart';
import '../utils/text_formatting_wrapper.dart';

/// A card widget that displays contractor information with interactive links
/// for phone, email, and website contact methods.
class ContractorCard extends StatelessWidget {
  final Contractor contractor;

  const ContractorCard({required this.contractor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthMedium,
        ),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name (header)
            _buildInfoRow(
              label: 'Company',
              value: toTitleCase(contractor.company),
              valueStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),

            // How to Signup
            _buildInfoRow(
              label: 'How to Signup',
              value: contractor.howToSignup,
            ),
            const SizedBox(height: 8),

            // Phone Number (if available)
            if (contractor.phoneNumber != null &&
                contractor.phoneNumber!.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchPhone(contractor.phoneNumber!),
                child: _buildInfoRow(
                  label: 'Phone',
                  value: contractor.phoneNumber!,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Email (if available)
            if (contractor.email != null && contractor.email!.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchEmail(contractor.email!),
                child: _buildInfoRow(
                  label: 'Email',
                  value: contractor.email!,
                  isLink: true,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Website (if available)
            if (contractor.website != null &&
                contractor.website!.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchWebsite(contractor.website!),
                child: _buildInfoRow(
                  label: 'Website',
                  value: contractor.website!,
                  isLink: true,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons with WCAG 2.1 AA compliant touch targets (≥48px)
            Row(
              children: [
                if (contractor.website != null &&
                    contractor.website!.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchWebsite(contractor.website!),
                      icon: const Icon(Icons.language, size: 18),
                      label: const Text('Visit Website'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: AppTheme.white,
                        minimumSize: const Size(0, 48), // WCAG compliance
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                if (contractor.website != null && contractor.phoneNumber != null)
                  const SizedBox(width: 12),
                if (contractor.phoneNumber != null &&
                    contractor.phoneNumber!.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchPhone(contractor.phoneNumber!),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(
                          color: AppTheme.accentCopper,
                        ),
                        minimumSize: const Size(0, 48), // WCAG compliance
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
    bool isLink = false,
  }) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: valueStyle ??
                TextStyle(
                  fontWeight: FontWeight.normal,
                  color: isLink ? AppTheme.primaryNavy : AppTheme.textPrimary,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWebsite(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching website: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    try {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching phone: $e');
    }
  }

  Future<void> _launchEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }
}