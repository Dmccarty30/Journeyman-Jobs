import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.electrical_services,
                size: 18,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Journeyman Jobs',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.white),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: [AppTheme.shadowMd],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Ready to find your next opportunity?',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  JJPrimaryButton(
                    text: 'Browse Jobs',
                    icon: Icons.search,
                    onPressed: () {
                      // TODO: Navigate to jobs screen
                    },
                    isFullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Quick stats section
            Text(
              'Quick Stats',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Jobs',
                    '1,247',
                    Icons.work_outline,
                    AppTheme.accentCopper,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildStatCard(
                    'Storm Jobs',
                    '23',
                    Icons.flash_on_outlined,
                    AppTheme.warningYellow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Recent job postings
            Text(
              'Recent Postings',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Placeholder job cards
            _buildJobCard(
              'Journeyman Electrician',
              'ABC Electric Co.',
              'Boston, MA',
              '\$42/hr',
              'Local 103',
            ),
            _buildJobCard(
              'Lineman - Storm Work',
              'Power Solutions LLC',
              'Houston, TX',
              '\$55/hr',
              'Local 66',
              isEmergency: true,
            ),
            _buildJobCard(
              'Journeyman Wireman',
              'Metro Construction',
              'Chicago, IL',
              '\$38/hr',
              'Local 134',
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Quick actions
            Text(
              'Quick Actions',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Find Locals',
                    Icons.people_outline,
                    () {
                      // TODO: Navigate to unions screen
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildActionCard(
                    'Storm Jobs',
                    Icons.flash_on_outlined,
                    () {
                      // TODO: Navigate to storm screen
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppTheme.iconMd),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(color: AppTheme.primaryNavy),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    String title,
    String company,
    String location,
    String wage,
    String local, {
    bool isEmergency = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: JJCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEmergency) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: AppTheme.white,
                      size: AppTheme.iconXs,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'STORM WORK',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              company,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: AppTheme.iconSm,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  location,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                ),
                const Spacer(),
                Text(
                  wage,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    local,
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                JJSecondaryButton(
                  text: 'View Details',
                  onPressed: () {
                    // TODO: Navigate to job details
                  },
                  width: 120,
                  height: 36,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return JJCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.white,
              size: AppTheme.iconMd,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            title,
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.primaryNavy,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}