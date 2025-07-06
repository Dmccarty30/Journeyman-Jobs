import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class PPESuppliersScreen extends StatelessWidget {
  const PPESuppliersScreen({super.key});

  final List<Map<String, dynamic>> _suppliers = const [
    {
      'name': '3M Safety',
      'description': 'Leading provider of personal protective equipment including hard hats, safety glasses, and respirators.',
      'phone': '1-800-364-3577',
      'website': 'https://www.3m.com/3M/en_US/safety-centers-us/',
      'specialties': ['Hard Hats', 'Safety Glasses', 'Respirators', 'Fall Protection'],
      'logo': Icons.security,
    },
    {
      'name': 'Honeywell Safety',
      'description': 'Comprehensive safety solutions for electrical workers including arc flash protection and gas detection.',
      'phone': '1-800-430-5490',
      'website': 'https://safety.honeywell.com/',
      'specialties': ['Arc Flash Protection', 'Gas Detection', 'Safety Footwear', 'Eye Protection'],
      'logo': Icons.shield,
    },
    {
      'name': 'MSA Safety',
      'description': 'Advanced safety equipment including gas detection, fall protection, and head protection.',
      'phone': '1-800-672-2222',
      'website': 'https://us.msasafety.com/',
      'specialties': ['Gas Detection', 'Fall Protection', 'Head Protection', 'Respiratory Protection'],
      'logo': Icons.health_and_safety,
    },
    {
      'name': 'Ergodyne',
      'description': 'Innovative safety gear designed to make work safer and more productive.',
      'phone': '1-800-225-8238',
      'website': 'https://www.ergodyne.com/',
      'specialties': ['Tool Belts', 'Knee Pads', 'Hi-Vis Clothing', 'Work Gloves'],
      'logo': Icons.construction,
    },
    {
      'name': 'Milwaukee Tool',
      'description': 'Safety equipment and tools specifically designed for electrical professionals.',
      'phone': '1-800-729-3878',
      'website': 'https://www.milwaukeetool.com/Products/Safety',
      'specialties': ['Safety Glasses', 'Hard Hats', 'High-Vis Clothing', 'Cut Resistant Gloves'],
      'logo': Icons.electrical_services,
    },
    {
      'name': 'Grainger Industrial Supply',
      'description': 'One-stop shop for all PPE needs with fast delivery and competitive pricing.',
      'phone': '1-800-472-4643',
      'website': 'https://www.grainger.com/category/safety',
      'specialties': ['Complete PPE Solutions', 'Bulk Orders', 'Next-Day Delivery', 'Safety Training'],
      'logo': Icons.store,
    },
  ];

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    final uri = Uri.parse(website);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'PPE Suppliers',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            JJCard(
              backgroundColor: AppTheme.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSm),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCopper.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: JJElectricalIcons.hardHat(
                          size: AppTheme.iconLg,
                          color: AppTheme.accentCopper,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PPE Suppliers',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingXs),
                            Text(
                              'Trusted suppliers for electrical worker safety equipment.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Safety reminder
            JJCard(
              backgroundColor: AppTheme.successGreen.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.successGreen,
                    size: AppTheme.iconMd,
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Text(
                      'Always ensure your PPE meets OSHA standards and is properly maintained. When in doubt, consult your safety supervisor.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Suppliers list
            Text(
              'Recommended Suppliers',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            ..._suppliers.map((supplier) => Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with logo and name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNavy.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(
                            supplier['logo'],
                            size: AppTheme.iconMd,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(
                            supplier['name'],
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // Description
                    Text(
                      supplier['description'],
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // Specialties
                    Text(
                      'Specialties:',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingSm,
                      children: (supplier['specialties'] as List<String>).map((specialty) {
                        return JJChip(
                          label: specialty,
                          isSelected: false,
                          selectedColor: AppTheme.accentCopper,
                          unselectedColor: AppTheme.lightGray,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: JJSecondaryButton(
                            text: 'Call',
                            icon: Icons.phone,
                            onPressed: () => _launchPhone(supplier['phone']),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: JJPrimaryButton(
                            text: 'Website',
                            icon: Icons.language,
                            onPressed: () => _launchWebsite(supplier['website']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),

            const SizedBox(height: AppTheme.spacingLg),

            // Contact info
            JJCard(
              backgroundColor: AppTheme.primaryNavy.withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support,
                        color: AppTheme.primaryNavy,
                        size: AppTheme.iconMd,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Text(
                        'Need Help Finding PPE?',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Contact your local IBEW safety representative for personalized recommendations based on your specific job requirements.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}