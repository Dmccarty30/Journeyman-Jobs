import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Data model for a single row in a card column
class CardRowData {
  /// The icon to display at the start of the row
  final IconData icon;

  /// The label text (will be displayed in bold, ending with ": ")
  final String label;

  /// The value text (will be displayed in regular font)
  final String value;

  /// Optional custom color for the icon
  final Color? iconColor;

  /// Optional custom color for the value text
  final Color? valueColor;

  const CardRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
  });
}

/// Data model for a single column in the card
class CardColumnData {
  /// List of rows in this column
  final List<CardRowData> rows;

  /// Optional custom flex value for this column
  final int? flex;

  const CardColumnData({
    required this.rows,
    this.flex,
  });
}

/// Standardized card component that follows the app-wide card format requirements
/// All cards (job cards, locals cards, etc.) MUST use this component or extend it
class StandardizedCard extends StatelessWidget {
  /// The columns to display in the card
  final List<CardColumnData> columns;

  /// Optional header/title for the card
  final String? header;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  /// Optional margin around the card
  final EdgeInsets? margin;

  /// Optional padding inside the card
  final EdgeInsets? padding;

  /// Whether to show copper border (default: true for electrical theme)
  final bool showCopperBorder;

  /// Custom background color (defaults to white)
  final Color? backgroundColor;

  /// Custom border radius
  final double? borderRadius;

  const StandardizedCard({
    super.key,
    required this.columns,
    this.header,
    this.onTap,
    this.margin,
    this.padding,
    this.showCopperBorder = true,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.white,
              borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
              border: showCopperBorder ? Border.all(
                color: AppTheme.accentCopper.withValues(alpha: 0.3),
                width: 1.5,
              ) : null,
              boxShadow: [AppTheme.shadowSm],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header if provided
                if (header != null) ...[
                  Text(
                    header!,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Main content with columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildColumns(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the column widgets with vertical dividers between them
  List<Widget> _buildColumns() {
    final List<Widget> columnWidgets = [];

    for (int i = 0; i < columns.length; i++) {
      // Add column
      columnWidgets.add(
        Expanded(
          flex: columns[i].flex ?? 1,
          child: _buildColumn(columns[i]),
        ),
      );

      // Add vertical divider between columns (except after the last column)
      if (i < columns.length - 1) {
        columnWidgets.add(
          const SizedBox(width: AppTheme.spacingMd),
        );
        columnWidgets.add(
          _buildVerticalDivider(),
        );
        columnWidgets.add(
          const SizedBox(width: AppTheme.spacingMd),
        );
      }
    }

    return columnWidgets;
  }

  /// Builds a single column with its rows
  Widget _buildColumn(CardColumnData columnData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnData.rows.map((row) => _buildRow(row)).toList(),
    );
  }

  /// Builds a single row with icon and rich text
  Widget _buildRow(CardRowData rowData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(
            rowData.icon,
            size: AppTheme.iconXs,
            color: rowData.iconColor ?? AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingXs),

          // Rich text content
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  // Bold label ending with ": "
                  TextSpan(
                    text: '${rowData.label}: ',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Regular value text
                  TextSpan(
                    text: rowData.value,
                    style: AppTheme.bodySmall.copyWith(
                      color: rowData.valueColor ?? AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
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

  /// Builds the vertical divider between columns
  Widget _buildVerticalDivider() {
    return Container(
      width: 2,
      height: 60, // Fixed height for consistency
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.accentCopper.withValues(alpha: 0.1),
            AppTheme.accentCopper.withValues(alpha: 0.4),
            AppTheme.accentCopper.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCopper.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }
}