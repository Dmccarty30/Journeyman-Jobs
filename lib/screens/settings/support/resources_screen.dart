import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import 'calculators/voltage_drop_calculator.dart';
import 'calculators/conduit_fill_calculator.dart';
import 'calculators/load_calculator.dart';
import 'calculators/wire_size_chart.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ResourceItem> _documents = [
    ResourceItem(
      category: 'IBEW Documents',
      title: 'IBEW Constitution',
      description: 'Official constitution and laws of the IBEW',
      type: ResourceType.document,
      icon: Icons.gavel,
      color: AppTheme.primaryNavy,
      action: 'https://www.ibew.org/constitution',
    ),
    ResourceItem(
      category: 'IBEW Documents',
      title: 'Code of Excellence',
      description: 'IBEW\'s commitment to quality workmanship',
      type: ResourceType.document,
      icon: Icons.star,
      color: AppTheme.accentCopper,
      action: 'https://www.ibew.org/codeofexcellence',
    ),
    ResourceItem(
      category: 'Safety',
      title: 'NFPA 70E Standard',
      description: 'Electrical Safety in the Workplace',
      type: ResourceType.document,
      icon: Icons.security,
      color: AppTheme.warningYellow,
      action: 'https://www.nfpa.org/codes-and-standards/all-codes-and-standards/list-of-codes-and-standards/detail?code=70E',
    ),
    ResourceItem(
      category: 'Safety',
      title: 'OSHA Electrical Standards',
      description: 'Federal workplace safety regulations',
      type: ResourceType.document,
      icon: Icons.shield,
      color: AppTheme.warningYellow,
      action: 'https://www.osha.gov/laws-regs/regulations/standardnumber/1926/1926Subparts',
    ),
    ResourceItem(
      category: 'Technical',
      title: 'National Electrical Code (NEC)',
      description: 'NFPA 70 - Installation standards',
      type: ResourceType.document,
      icon: Icons.electrical_services,
      color: AppTheme.infoBlue,
      action: 'https://www.nfpa.org/codes-and-standards/all-codes-and-standards/list-of-codes-and-standards/detail?code=70',
    ),
    ResourceItem(
      category: 'Technical',
      title: 'IEEE Standards',
      description: 'Institute of Electrical and Electronics Engineers',
      type: ResourceType.document,
      icon: Icons.engineering,
      color: AppTheme.infoBlue,
      action: 'https://www.ieee.org/standards/index.html',
    ),
  ];

  final List<ResourceItem> _tools = [
    ResourceItem(
      category: 'Calculators',
      title: 'Voltage Drop Calculator',
      description: 'Calculate voltage drop for wire runs',
      type: ResourceType.tool,
      icon: Icons.calculate,
      color: AppTheme.accentCopper,
      action: 'voltage_drop_calc',
    ),
    ResourceItem(
      category: 'Calculators',
      title: 'Conduit Fill Calculator',
      description: 'Determine maximum wire capacity for conduit',
      type: ResourceType.tool,
      icon: Icons.architecture,
      color: AppTheme.accentCopper,
      action: 'conduit_fill_calc',
    ),
    ResourceItem(
      category: 'Calculators',
      title: 'Load Calculation Tool',
      description: 'Calculate electrical loads for panels',
      type: ResourceType.tool,
      icon: Icons.analytics,
      color: AppTheme.accentCopper,
      action: 'load_calc',
    ),
    ResourceItem(
      category: 'Reference',
      title: 'Wire Size Chart',
      description: 'AWG wire sizing and ampacity reference',
      type: ResourceType.tool,
      icon: Icons.table_chart,
      color: AppTheme.infoBlue,
      action: 'wire_chart',
    ),
    ResourceItem(
      category: 'Reference',
      title: 'Conduit Size Chart',
      description: 'Conduit sizing and fill percentages',
      type: ResourceType.tool,
      icon: Icons.view_list,
      color: AppTheme.infoBlue,
      action: 'conduit_chart',
    ),
    ResourceItem(
      category: 'Reference',
      title: 'Electrical Symbols',
      description: 'Standard electrical drawing symbols',
      type: ResourceType.tool,
      icon: Icons.emoji_symbols,
      color: AppTheme.infoBlue,
      action: 'symbols_ref',
    ),
    ResourceItem(
      category: 'Reference',
      title: 'Transformer Banks',
      description: 'Interactive transformer bank configurations and connections',
      type: ResourceType.tool,
      icon: Icons.electrical_services,
      color: AppTheme.accentCopper,
      action: 'transformer_banks',
    ),
  ];

  final List<ResourceItem> _links = [
    ResourceItem(
      category: 'IBEW Official',
      title: 'IBEW International',
      description: 'Official IBEW website and resources',
      type: ResourceType.link,
      icon: Icons.public,
      color: AppTheme.primaryNavy,
      action: 'https://www.ibew.org',
    ),
    ResourceItem(
      category: 'IBEW Official',
      title: 'IBEW Local Union Directory',
      description: 'Find contact info for all IBEW locals',
      type: ResourceType.link,
      icon: Icons.location_city,
      color: AppTheme.primaryNavy,
      action: 'https://www.ibew.org/tools/find-a-local',
    ),
    ResourceItem(
      category: 'Training',
      title: 'IBEW Training Centers',
      description: 'Apprenticeship and continuing education',
      type: ResourceType.link,
      icon: Icons.school,
      color: AppTheme.successGreen,
      action: 'https://www.ibew.org/jobsandtraining/apprenticeship',
    ),
    ResourceItem(
      category: 'Training',
      title: 'NECA Education Centers',
      description: 'National Electrical Contractors Association',
      type: ResourceType.link,
      icon: Icons.business,
      color: AppTheme.successGreen,
      action: 'https://www.necanet.org/training',
    ),
    ResourceItem(
      category: 'Safety',
      title: 'NFPA - Fire Safety',
      description: 'National Fire Protection Association',
      type: ResourceType.link,
      icon: Icons.local_fire_department,
      color: AppTheme.errorRed,
      action: 'https://www.nfpa.org',
    ),
    ResourceItem(
      category: 'Government',
      title: 'Department of Labor',
      description: 'Federal employment and labor information',
      type: ResourceType.link,
      icon: Icons.account_balance,
      color: AppTheme.textSecondary,
      action: 'https://www.dol.gov',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ResourceItem> _getFilteredItems(List<ResourceItem> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((item) =>
      item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.category.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Resources',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCopper,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Documents'),
            Tab(text: 'Tools'),
            Tab(text: 'Links'),
          ],
        ),
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
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search resources...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResourceList(_getFilteredItems(_documents)),
                _buildResourceList(_getFilteredItems(_tools)),
                _buildResourceList(_getFilteredItems(_links)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList(List<ResourceItem> items) {
    if (items.isEmpty) {
      return Center(
        child: JJEmptyState(
          title: 'No Resources Found',
          subtitle: 'Try searching with different keywords',
          icon: Icons.search_off,
        ),
      );
    }

    // Group items by category
    final groupedItems = <String, List<ResourceItem>>{};
    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: AppTheme.spacingLg),
            
            // Category header
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.spacingSm,
                bottom: AppTheme.spacingSm,
              ),
              child: Text(
                category,
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Category items
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                      color: AppTheme.accentCopper,
                      width: AppTheme.borderWidthThin,
                    ),
                boxShadow: [AppTheme.shadowSm],
              ),
              child: Column(
                children: categoryItems.asMap().entries.map((entry) {
                  final itemIndex = entry.key;
                  final item = entry.value;
                  final isLast = itemIndex == categoryItems.length - 1;

                  return Column(
                    children: [
                      ResourceCard(item: item),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppTheme.borderCopper,
                          indent: AppTheme.spacingXl,
                          endIndent: AppTheme.spacingMd,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum ResourceType { document, tool, link }

class ResourceItem {
  final String category;
  final String title;
  final String description;
  final ResourceType type;
  final IconData icon;
  final Color color;
  final String action;

  ResourceItem({
    required this.category,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    required this.action,
  });
}

class ResourceCard extends StatelessWidget {
  final ResourceItem item;

  const ResourceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleResourceAction(context, item),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      item.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getActionIcon(item.type),
                size: 16,
                color: AppTheme.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Icons.description;
      case ResourceType.tool:
        return Icons.build;
      case ResourceType.link:
        return Icons.open_in_new;
    }
  }

  void _handleResourceAction(BuildContext context, ResourceItem item) {
    switch (item.type) {
      case ResourceType.document:
      case ResourceType.link:
        if (item.action.startsWith('http')) {
          Clipboard.setData(ClipboardData(text: item.action));
          JJSnackBar.showSuccess(
            context: context,
            message: 'Link copied to clipboard',
          );
        } else {
          JJSnackBar.showSuccess(
            context: context,
            message: 'Document access coming soon',
          );
        }
        break;
      case ResourceType.tool:
        _navigateToTool(context, item);
        break;
    }
  }

  void _navigateToTool(BuildContext context, ResourceItem item) {
    Widget? toolScreen;
    
    switch (item.action) {
      case 'voltage_drop_calc':
        toolScreen = const VoltageDropCalculator();
        break;
      case 'conduit_fill_calc':
        toolScreen = const ConduitFillCalculator();
        break;
      case 'load_calc':
        toolScreen = const LoadCalculator();
        break;
      case 'wire_chart':
        toolScreen = const WireSizeChart();
        break;
      case 'transformer_banks':
        context.go('/tools/transformer-reference');
        return;
      default:
        _showToolDialog(context, item);
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => toolScreen!),
    );
    }

  void _showToolDialog(BuildContext context, ResourceItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: AppTheme.iconMd,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(
                item.title,
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoBlue,
                    size: AppTheme.iconSm,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      'Interactive tools and calculators are coming in a future update.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.infoBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}