import 'package:flutter/material.dart';
import '../design_system/components/standardized_card.dart';
import '../design_system/app_theme.dart';
import '../models/locals_record.dart';

/// LocalsCard component that displays IBEW local union information
/// Uses the StandardizedCard component to follow the app-wide card format requirements
class LocalsCard extends StatelessWidget {
  /// The locals record containing all local union data
  final LocalsRecord local;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  /// Optional callback for contact actions
  final VoidCallback? onContact;

  /// Optional callback for website navigation
  final VoidCallback? onVisitWebsite;

  const LocalsCard({
    super.key,
    required this.local,
    this.onTap,
    this.onContact,
    this.onVisitWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return StandardizedCard(
      header: 'IBEW Local ${local.localNumber}',
      columns: [
        // Column 1: Basic Information
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.business,
              label: 'Name',
              value: local.localName,
            ),
            CardRowData(
              icon: Icons.location_on,
              label: 'Location',
              value: local.location,
            ),
            CardRowData(
              icon: Icons.people,
              label: 'Members',
              value: local.memberCount.toString(),
            ),
          ],
        ),

        // Column 2: Contact Information
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.phone,
              label: 'Phone',
              value: local.contactPhone,
            ),
            CardRowData(
              icon: Icons.email,
              label: 'Email',
              value: local.contactEmail,
            ),
            if (local.website != null && local.website!.isNotEmpty)
              CardRowData(
                icon: Icons.language,
                label: 'Website',
                value: 'Visit Website',
                valueColor: AppTheme.accentCopper,
              ),
          ],
        ),

        // Column 3: Additional Information (if available)
        if (local.specialties.isNotEmpty || local.classification != null)
          CardColumnData(
            rows: [
              if (local.classification != null)
                CardRowData(
                  icon: Icons.work,
                  label: 'Classification',
                  value: local.classification!,
                ),
              if (local.specialties.isNotEmpty)
                CardRowData(
                  icon: Icons.build,
                  label: 'Specialties',
                  value: local.specialties.take(2).join(', '),
                ),
              CardRowData(
                icon: local.isActive ? Icons.check_circle : Icons.cancel,
                label: 'Status',
                value: local.isActive ? 'Active' : 'Inactive',
                valueColor: local.isActive ? AppTheme.successGreen : AppTheme.errorRed,
                iconColor: local.isActive ? AppTheme.successGreen : AppTheme.errorRed,
              ),
            ],
          ),
      ],
      onTap: onTap,
    );
  }
}

/// Alternative compact version of LocalsCard for smaller displays
class CompactLocalsCard extends StatelessWidget {
  /// The locals record containing all local union data
  final LocalsRecord local;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  const CompactLocalsCard({
    super.key,
    required this.local,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StandardizedCard(
      header: 'Local ${local.localNumber}',
      columns: [
        // Single column with essential information
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.business,
              label: 'Name',
              value: local.localName,
            ),
            CardRowData(
              icon: Icons.location_on,
              label: 'Location',
              value: local.location,
            ),
            CardRowData(
              icon: Icons.phone,
              label: 'Contact',
              value: local.contactPhone,
            ),
          ],
        ),
      ],
      onTap: onTap,
    );
  }
}

/// Factory class for creating different types of locals cards
class LocalsCardFactory {
  /// Creates a standard locals card
  static Widget standard(LocalsRecord local, {VoidCallback? onTap}) {
    return LocalsCard(local: local, onTap: onTap);
  }

  /// Creates a compact locals card for smaller displays
  static Widget compact(LocalsRecord local, {VoidCallback? onTap}) {
    return CompactLocalsCard(local: local, onTap: onTap);
  }

  /// Creates a locals card based on available data and display context
  static Widget adaptive(LocalsRecord local, {
    VoidCallback? onTap,
    bool compact = false,
  }) {
    if (compact) {
      return CompactLocalsCard(local: local, onTap: onTap);
    }

    // Use standard card if local has rich data
    if (local.specialties.isNotEmpty || local.classification != null) {
      return LocalsCard(local: local, onTap: onTap);
    }

    // Use compact card for basic information only
    return CompactLocalsCard(local: local, onTap: onTap);
  }
}