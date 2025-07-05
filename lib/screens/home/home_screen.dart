import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
// import '../../../electrical_components/electrical_components.dart'; // Temporarily disabled
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final math.Random _random = math.Random();
  final int _safetyDaysCount = 127; // This would come from a data source
  final List<String> _safetyTips = [
    'Always test circuits before working - never assume they are de-energized',
    'Wear proper PPE including safety glasses, hard hat, and arc-rated clothing',
    'Use proper lockout/tagout procedures before electrical work',
    'Keep a safe distance from overhead power lines - maintain 10-foot clearance',
    'Inspect tools and equipment before each use',
    'Never work alone on electrical systems - use the buddy system',
    'Know your electrical hazards: shock, arc flash, blast, and fire',
  ];

  String get _todaysSafetyTip => _safetyTips[_random.nextInt(_safetyTips.length)];

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
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.construction,
                  size: 20,
                  color: AppTheme.white,
                ),
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

            // Safety Dashboard Section
            Text(
              'Daily Safety Check',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildSafetyDashboard(),
            
            const SizedBox(height: AppTheme.spacingLg),

            // Electrical Industry Stats section
            Text(
              'Electrical Industry Stats',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // First row of electrical stats
            Row(
              children: [
                Expanded(
                  child: _buildElectricalStatCard(
                    'Power Outages',
                    '12',
                    const Icon(Icons.electrical_services, size: 20),
                    AppTheme.errorRed,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildElectricalStatCard(
                    'Storm Jobs',
                    '23',
                    const Icon(Icons.flash_on_outlined, size: 20),
                    AppTheme.warningYellow,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Second row of electrical stats
            Row(
              children: [
                Expanded(
                  child: _buildElectricalStatCard(
                    'High Voltage',
                    '89',
                    const Icon(Icons.flash_on, size: 20),
                    AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildElectricalStatCard(
                    'Code Updates',
                    '3',
                    const Icon(Icons.update_outlined, size: 20),
                    AppTheme.successGreen,
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

            // Electrical job categories
            _buildElectricalJobCard(
              'Residential Electrical',
              'Highpoint Electric',
              'Boston, MA',
              '\$42/hr',
              'Local 103',
              '120V/240V Service',
              Icons.home_outlined,
            ),
            _buildElectricalJobCard(
              'Storm Restoration',
              'Emergency Power Solutions',
              'Houston, TX',
              '\$65/hr',
              'Local 66',
              'Emergency Work',
              Icons.flash_on_outlined,
              isEmergency: true,
            ),
            _buildElectricalJobCard(
              'Commercial/Industrial',
              'Metro Industrial Electric',
              'Chicago, IL',
              '\$48/hr',
              'Local 134',
              '480V+ Systems',
              Icons.factory_outlined,
            ),
            _buildElectricalJobCard(
              'Transmission/Distribution',
              'Grid Solutions LLC',
              'Phoenix, AZ',
              '\$58/hr',
              'Local 387',
              'High Voltage',
              Icons.electrical_services_outlined,
              isHighVoltage: true,
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

            // First row of electrical quick actions
            Row(
              children: [
                Expanded(
                  child: _buildElectricalActionCard(
                    'Code Updates',
                    Icons.update_outlined,
                    () {
                      // TODO: Navigate to NEC updates
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildElectricalActionCard(
                    'Safety Check-in',
                    Icons.security_outlined,
                    () {
                      // TODO: Navigate to safety checklist
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Second row of electrical quick actions
            Row(
              children: [
                Expanded(
                  child: _buildElectricalActionCard(
                    'Report Hazard',
                    Icons.warning_outlined,
                    () {
                      // TODO: Navigate to hazard reporting
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildElectricalActionCard(
                    'PPE Suppliers',
                    Icons.shield_outlined,
                    () {
                      // TODO: Navigate to PPE suppliers
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Third row of electrical quick actions
            Row(
              children: [
                Expanded(
                  child: _buildElectricalActionCard(
                    'Electrical Calculators',
                    Icons.calculate_outlined,
                    () {
                      // TODO: Navigate to electrical calculators
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildTransmissionActionCard(
                    'Power Grid',
                    () {
                      // TODO: Navigate to transmission jobs
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

  Widget _buildSafetyDashboard() {
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
          Text(
            '$_safetyDaysCount days since the last incident',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Safety Tip: $_todaysSafetyTip',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricalStatCard(String title, String value, Widget icon, Color color) {
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
              icon,
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: AppTheme.headlineMedium.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricalJobCard(
      String title,
      String company,
      String location,
      String wage,
      String local,
      String description,
      IconData icon, {
        bool isEmergency = false,
        bool isHighVoltage = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      'Emergency',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isEmergency) const SizedBox(height: AppTheme.spacingSm),
                Text(
                  title,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Text(
                  company,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
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
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      wage,
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: AppTheme.spacingSm,
                  children: [
                    Chip(
                      label: Text(
                        local,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      backgroundColor: AppTheme.lightGray,
                    ),
                    Chip(
                      label: Text(
                        description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      backgroundColor: AppTheme.lightGray,
                    ),
                  ],
                ),
                if (isHighVoltage) const SizedBox(height: AppTheme.spacingXs),
                if (isHighVoltage)
                  Icon(
                    icon,
                    color: AppTheme.warningYellow,
                    size: AppTheme.iconLg,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElectricalActionCard(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [AppTheme.shadowSm],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.white,
              size: AppTheme.iconLg,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransmissionActionCard(String title, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.accentCopper,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [AppTheme.shadowSm],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.electrical_services,
              color: AppTheme.white,
              size: AppTheme.iconLg,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
