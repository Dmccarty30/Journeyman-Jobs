import 'package:flutter/material.dart';
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Example implementations of DynamicContainerRow widget
///
/// This file demonstrates various use cases and integration patterns
/// for the DynamicContainerRow widget in the Journeyman Jobs app.
class DynamicContainerRowExample extends StatefulWidget {
  const DynamicContainerRowExample({super.key});

  @override
  State<DynamicContainerRowExample> createState() => _DynamicContainerRowExampleState();
}

class _DynamicContainerRowExampleState extends State<DynamicContainerRowExample> {
  int _selectedBasicIndex = 0;
  int _selectedIconIndex = 0;
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Dynamic Container Row Examples'),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Implementation'),
            _buildDescription(
              'Simple 4-container row with text labels only. '
              'Perfect for category selection or tab-like navigation.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildBasicExample(),
            const SizedBox(height: AppTheme.spacingXl),

            _buildSectionTitle('With Icons'),
            _buildDescription(
              'Enhanced version with icons above labels. '
              'Provides better visual hierarchy and user recognition.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildIconExample(),
            const SizedBox(height: AppTheme.spacingXl),

            _buildSectionTitle('Tab Controller Integration'),
            _buildDescription(
              'Integration with TabController for synchronized tab switching. '
              'Demonstrates real-world usage in tab-based navigation.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildTabControllerExample(),
            const SizedBox(height: AppTheme.spacingXl),

            _buildSectionTitle('Custom Styling'),
            _buildDescription(
              'Examples of custom heights, spacing, and responsive layouts. '
              'Shows flexibility for different screen sizes and use cases.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildCustomStylingExamples(),
          ],
        ),
      ),
    );
  }

  /// Basic implementation with text labels only
  Widget _buildBasicExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicContainerRow(
          labels: const ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: _selectedBasicIndex,
          onTap: (index) {
            setState(() {
              _selectedBasicIndex = index;
            });
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildSelectionIndicator('Selected: $_selectedBasicIndex'),
      ],
    );
  }

  /// Implementation with icons and labels
  Widget _buildIconExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicContainerRowWithIcons(
          labels: const ['Feed', 'Jobs', 'Chat', 'Members'],
          icons: const [
            Icons.feed_outlined,
            Icons.work_outline,
            Icons.chat_bubble_outline,
            Icons.group_outlined,
          ],
          selectedIndex: _selectedIconIndex,
          onTap: (index) {
            setState(() {
              _selectedIconIndex = index;
            });
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildSelectionIndicator('Selected: $_selectedIconIndex'),
      ],
    );
  }

  /// Integration with TabController
  Widget _buildTabControllerExample() {
    final labels = ['Feed', 'Jobs', 'Chat', 'Members'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicContainerRow(
          labels: labels,
          selectedIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthMedium,
            ),
          ),
          child: Center(
            child: Text(
              '${labels[_selectedTabIndex]} Content',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Custom styling examples
  Widget _buildCustomStylingExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('Compact Height (40px)'),
        const SizedBox(height: AppTheme.spacingSm),
        DynamicContainerRow(
          labels: const ['A', 'B', 'C', 'D'],
          selectedIndex: 0,
          height: 40.0,
        ),
        const SizedBox(height: AppTheme.spacingLg),

        _buildSubsectionTitle('Generous Height (100px)'),
        const SizedBox(height: AppTheme.spacingSm),
        DynamicContainerRow(
          labels: const ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: 1,
          height: 100.0,
        ),
        const SizedBox(height: AppTheme.spacingLg),

        _buildSubsectionTitle('Wide Spacing (16px)'),
        const SizedBox(height: AppTheme.spacingSm),
        DynamicContainerRow(
          labels: const ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: 2,
          spacing: 16.0,
        ),
        const SizedBox(height: AppTheme.spacingLg),

        _buildSubsectionTitle('Minimal Spacing (4px)'),
        const SizedBox(height: AppTheme.spacingSm),
        DynamicContainerRow(
          labels: const ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: 3,
          spacing: 4.0,
        ),
      ],
    );
  }

  // Helper widgets for consistent formatting

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headlineMedium.copyWith(
        color: AppTheme.primaryNavy,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.titleMedium.copyWith(
        color: AppTheme.darkGray,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.mediumGray,
        height: 1.5,
      ),
    );
  }

  Widget _buildSelectionIndicator(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.accentCopper,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Real-world integration example: Tailboard Screen
///
/// This demonstrates how to integrate DynamicContainerRow
/// with the existing Tailboard screen architecture.
class TailboardIntegrationExample extends StatefulWidget {
  const TailboardIntegrationExample({super.key});

  @override
  State<TailboardIntegrationExample> createState() => _TailboardIntegrationExampleState();
}

class _TailboardIntegrationExampleState extends State<TailboardIntegrationExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index != _selectedIndex) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Tailboard Integration'),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [AppTheme.shadowSm],
            ),
            child: Column(
              children: [
                Text(
                  'Crew Alpha',
                  style: AppTheme.headlineLarge.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  '12 Members',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Container Row for tab selection
          DynamicContainerRowWithIcons(
            labels: const ['Feed', 'Jobs', 'Chat', 'Members'],
            icons: const [
              Icons.feed_outlined,
              Icons.work_outline,
              Icons.chat_bubble_outline,
              Icons.group_outlined,
            ],
            selectedIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                _tabController.animateTo(index);
              });
            },
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Control via container taps only
              children: [
                _buildTabContent('Feed', Icons.feed_outlined),
                _buildTabContent('Jobs', Icons.work_outline),
                _buildTabContent('Chat', Icons.chat_bubble_outline),
                _buildTabContent('Members', Icons.group_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            '$title Content',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}

/// Code snippets for documentation
///
/// These are reference implementations for the widget documentation.
class CodeSnippets {
  // Basic usage
  static const basicUsage = '''
DynamicContainerRow(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  selectedIndex: 0,
  onTap: (index) {
    print('Tapped container at index: \$index');
  },
)
''';

  // With icons
  static const withIcons = '''
DynamicContainerRowWithIcons(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  icons: [
    Icons.feed_outlined,
    Icons.work_outline,
    Icons.chat_bubble_outline,
    Icons.group_outlined,
  ],
  selectedIndex: 0,
  onTap: (index) {
    setState(() {
      selectedIndex = index;
    });
  },
)
''';

  // Custom styling
  static const customStyling = '''
DynamicContainerRow(
  labels: ['A', 'B', 'C', 'D'],
  selectedIndex: 0,
  height: 80.0,        // Custom height
  spacing: 16.0,       // Custom spacing
  onTap: (index) {
    // Handle tap
  },
)
''';

  // TabController integration
  static const tabControllerIntegration = '''
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicContainerRow(
          labels: ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: _selectedIndex,
          onTap: (index) {
            _tabController.animateTo(index);
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab content widgets
            ],
          ),
        ),
      ],
    );
  }
}
''';
}
