import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../design_system/app_theme.dart';
import '../storm_theme.dart';

class StormContractorCard extends StatelessWidget {
  final Map<String, dynamic> contractor;

  const StormContractorCard({
    super.key,
    required this.contractor,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $phoneNumber');
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final uri = Uri.parse('mailto:$emailAddress');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $emailAddress');
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = contractor['COMPANY']?.toString() ?? 'N/A';
    final howToSignup = contractor['HOW TO SIGNUP']?.toString() ?? 'N/A';
    final website = contractor['WEBSITE']?.toString();
    final phoneNumber = contractor['PHONE NUMBER']?.toString();
    final email = contractor['EMAIL']?.toString();
    final address = contractor['ADDRESS']?.toString();
    final city = contractor['CITY']?.toString();
    final state = contractor['STATE']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border.all(
          color: StormTheme.electricBlue.withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.white,
            StormTheme.electricBlue.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            companyName,
            style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Sign Up: $howToSignup',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Address: $address${city != null ? ', $city' : ''}${state != null ? ', $state' : ''}',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
            ),
          ],
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (website != null && website.isNotEmpty)
                _buildActionButton(
                  icon: Icons.public,
                  label: 'Website',
                  onPressed: () => _launchUrl(website),
                  color: StormTheme.electricBlue,
                ),
              if (phoneNumber != null && phoneNumber.isNotEmpty)
                _buildActionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  onPressed: () => _makePhoneCall(phoneNumber),
                  color: StormTheme.deepStorm,
                ),
              if (email != null && email.isNotEmpty)
                _buildActionButton(
                  icon: Icons.email,
                  label: 'Email',
                  onPressed: () => _sendEmail(email),
                  color: AppTheme.accentCopper,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}
