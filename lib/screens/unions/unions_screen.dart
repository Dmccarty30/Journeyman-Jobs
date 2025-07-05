import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class UnionsScreen extends StatefulWidget {
  const UnionsScreen({super.key});

  @override
  State<UnionsScreen> createState() => _UnionsScreenState();
}

class _UnionsScreenState extends State<UnionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'IBEW Locals',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.white),
            onPressed: () {
              // TODO: Show search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppTheme.primaryNavy,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              0,
              AppTheme.spacingMd,
              AppTheme.spacingMd,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by local number or city...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                ),
              ),
            ),
          ),

          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            color: AppTheme.accentCopper.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentCopper,
                  size: AppTheme.iconSm,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    '797+ IBEW Locals with contact information',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Union list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              children: [
                // Coming soon message
                JJEmptyState(
                  title: 'Union Directory Loading',
                  subtitle: 'We\'re building a comprehensive directory of all 797+ IBEW locals with contact information, job board links, and referral policies.',
                  icon: Icons.people_outline,
                  action: Column(
                    children: [
                      JJPrimaryButton(
                        text: 'View Sample Locals',
                        icon: Icons.visibility,
                        onPressed: () {
                          _showSampleLocals();
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      JJSecondaryButton(
                        text: 'Request Priority Access',
                        icon: Icons.priority_high,
                        onPressed: () {
                          // TODO: Show priority access form
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSampleLocals() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXl),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Row(
                    children: [
                      Text(
                        'Sample IBEW Locals',
                        style: AppTheme.headlineSmall,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Sample locals list
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    children: [
                      _buildSampleLocalCard('Local 103', 'Boston, MA', '(617) 555-0103', 'local103@ibew.org'),
                      _buildSampleLocalCard('Local 26', 'Washington, DC', '(202) 555-0026', 'info@local26.org'),
                      _buildSampleLocalCard('Local 134', 'Chicago, IL', '(312) 555-0134', 'dispatch@ibew134.org'),
                      _buildSampleLocalCard('Local 46', 'Seattle, WA', '(206) 555-0046', 'jobs@local46.org'),
                      _buildSampleLocalCard('Local 11', 'Los Angeles, CA', '(213) 555-0011', 'referrals@ibew11.org'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSampleLocalCard(String local, String location, String phone, String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: JJCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    color: AppTheme.accentCopper,
                    size: AppTheme.iconSm,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local,
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      Text(
                        location,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: AppTheme.iconSm,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  phone,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingSm),
            
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: AppTheme.iconSm,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  email,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            Row(
              children: [
                Expanded(
                  child: JJSecondaryButton(
                    text: 'Contact',
                    icon: Icons.phone,
                    onPressed: () {
                      // TODO: Launch phone call
                    },
                    height: 36,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: JJPrimaryButton(
                    text: 'View Jobs',
                    icon: Icons.work,
                    onPressed: () {
                      // TODO: Navigate to local jobs
                    },
                    height: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}