import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../services/power_outage_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget to display power outage information for a state
class PowerOutageCard extends StatelessWidget {
  final PowerOutageState outageData;
  final VoidCallback? onTap;
  
  const PowerOutageCard({
    super.key,
    required this.outageData,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final service = PowerOutageService();
    final severity = service.getOutageSeverity(outageData);
    final percentage = service.getOutagePercentage(outageData);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border.all(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthMedium,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // State icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(severity).withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.bolt,
                              color: _getSeverityColor(severity),
                              size: 24,
                            ),
                            Text(
                              outageData.stateAbbreviation,
                              style: AppTheme.labelSmall.copyWith(
                                color: _getSeverityColor(severity),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    
                    // State info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outageData.stateName,
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppTheme.primaryNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.usersSlash,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: AppTheme.spacingXs),
                              Text(
                                '${service.formatOutageCount(outageData.outageCount)} without power',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Severity indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(severity),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text(
                            _getSeverityLabel(severity),
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppTheme.headlineMedium.copyWith(
                            color: _getSeverityColor(severity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSeverityColor(severity),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingSm),
                
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total customers: ${service.formatOutageCount(outageData.customerCount)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.circleExclamation,
                          size: 12,
                          color: AppTheme.warningYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Storm restoration needed',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.warningYellow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getSeverityColor(OutageSeverity severity) {
    switch (severity) {
      case OutageSeverity.critical:
        return Color(0xFFD8006D); // Magenta
      case OutageSeverity.severe:
        return AppTheme.errorRed;
      case OutageSeverity.moderate:
        return AppTheme.warningYellow;
      case OutageSeverity.minor:
        return Colors.orange;
      case OutageSeverity.minimal:
        return AppTheme.textLight;
    }
  }
  
  String _getSeverityLabel(OutageSeverity severity) {
    switch (severity) {
      case OutageSeverity.critical:
        return 'CRITICAL';
      case OutageSeverity.severe:
        return 'SEVERE';
      case OutageSeverity.moderate:
        return 'MODERATE';
      case OutageSeverity.minor:
        return 'MINOR';
      case OutageSeverity.minimal:
        return 'MINIMAL';
    }
  }
}

/// Widget to display power outage summary
class PowerOutageSummary extends StatelessWidget {
  final List<PowerOutageState> outages;
  
  const PowerOutageSummary({
    super.key,
    required this.outages,
  });
  
  @override
  Widget build(BuildContext context) {
    final service = PowerOutageService();
    final totalAffected = service.getSignificantOutagesTotal();
    final stateCount = outages.length;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.errorRed.withAlpha((255 * 0.9).round()),
            AppTheme.warningYellow.withAlpha((255 * 0.9).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.plugCircleXmark,
                color: AppTheme.white,
                size: 28,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAJOR POWER OUTAGES',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Restoration crews needed nationwide',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white.withAlpha((255 * 0.9).round()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.usersSlash,
                  value: service.formatOutageCount(totalAffected),
                  label: 'Customers Affected',
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.mapLocationDot,
                  value: stateCount.toString(),
                  label: 'States Impacted',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white.withAlpha((255 * 0.2).round()),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.white,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.white.withAlpha((255 * 0.9).round()),
            ),
          ),
        ],
      ),
    );
  }
}
