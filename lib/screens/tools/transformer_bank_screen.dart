import 'package:flutter/material.dart';

import '../../design_system/app_theme.dart';
import '../../electrical_components/circuit_pattern_painter.dart';
import 'transformer_reference_screen.dart';

class TransformerBankScreen extends StatefulWidget {
  const TransformerBankScreen({super.key});

  @override
  State<TransformerBankScreen> createState() => _TransformerBankScreenState();
}

class _TransformerBankScreenState extends State<TransformerBankScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _lightningAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _lightningAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This screen now routes directly to the Reference experience
    return const TransformerReferenceScreen();
  }

  Widget _buildHeroSection() => Container(
        width: double.infinity,
        height: 240,
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: AppTheme.splashGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: const <BoxShadow>[AppTheme.shadowMd],
        ),
        child: Stack(
          children: <Widget>[
            // Circuit pattern background
            Positioned.fill(
              child: CustomPaint(
                painter: CircuitPatternPainter(
                  primaryColor: AppTheme.white.withValues(alpha: 0.1),
                  secondaryColor: AppTheme.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Lightning animation
                  AnimatedBuilder(
                    animation: _lightningAnimation,
                    builder: (BuildContext context, Widget? child) =>
                        Transform.scale(
                      scale: 1.0 + (_lightningAnimation.value * 0.1),
                      child: Icon(
                        Icons.electric_bolt,
                        size: 60,
                        color: AppTheme.white.withValues(
                          alpha: 0.8 + (_lightningAnimation.value * 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  // Title
                  const Text(
                    'Master Transformer Banks',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  // Subtitle
                  const Text(
                    'Professional Training & Reference',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildModeSelection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'MODE SELECTION',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildModeCard(
                    title: 'REFERENCE',
                    icon: Icons.book,
                    subtitle: 'Study & Learn\nConfigurations',
                    features: <String>[
                      '• View all banks',
                      '• Component info',
                      '• Technical specs',
                    ],
                    buttonText: 'Explore',
                    onTap: _navigateToReferenceMode,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildModeCard(
                    title: 'TRAINING',
                    icon: Icons.gps_fixed,
                    subtitle: 'Test Your Knowledge\nInteractive Practice',
                    features: <String>[
                      '• 3 Difficulty levels',
                      '• Real-time feedback',
                      '• Progress tracking',
                    ],
                    buttonText: 'Start Training',
                    onTap: _navigateToTrainingMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildModeCard({
    required String title,
    required IconData icon,
    required String subtitle,
    required List<String> features,
    required String buttonText,
    required VoidCallback onTap,
  }) =>
      Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const <BoxShadow>[AppTheme.shadowSm],
          border: Border.all(
            color: AppTheme.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.accentCopper,
                    size: AppTheme.iconMd,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Features
            ...features.map(
              (String feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                child: Text(
                  feature,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: AppTheme.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    const Icon(
                      Icons.arrow_forward,
                      size: AppTheme.iconSm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildQuickAccess() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: const <BoxShadow>[AppTheme.shadowSm],
            border: Border.all(
              color: AppTheme.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'QUICK ACCESS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildQuickAccessSection(
                icon: Icons.trending_up,
                title: 'Recent Activity',
                items: <String>[
                  'Delta-Delta Training (85% Complete)',
                  'Wye-Wye Reference (Last viewed)',
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildQuickAccessSection(
                icon: Icons.star,
                title: 'Bookmarks',
                items: <String>[
                  'Open-Delta Configuration',
                  'Single Pot Setup',
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildQuickAccessSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: AppTheme.accentCopper,
                size: AppTheme.iconSm,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ...items.map(
            (String item) => Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.spacingMd,
                bottom: AppTheme.spacingXs,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  void _navigateToReferenceMode() {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const TransformerReferenceScreen(),
      ),
    );
  }

  void _navigateToTrainingMode() {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const TransformerTrainingScreen(),
      ),
    );
  }
}

// Placeholder screen for training mode

class TransformerTrainingScreen extends StatelessWidget {
  const TransformerTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Training Mode'),
          backgroundColor: AppTheme.primaryNavy,
          foregroundColor: AppTheme.white,
        ),
        body: const Center(
          child: Text('Training Mode - Coming Soon!'),
        ),
      );
}
