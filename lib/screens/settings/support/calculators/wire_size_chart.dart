import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../design_system/components/reusable_components.dart';
import 'electrical_constants.dart';

class WireSizeChart extends StatefulWidget {
  const WireSizeChart({super.key});

  @override
  State<WireSizeChart> createState() => _WireSizeChartState();
}

class _WireSizeChartState extends State<WireSizeChart> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  TemperatureRating _selectedTempRating = TemperatureRating.temp75C;
  ConductorMaterial _selectedMaterial = ConductorMaterial.copper;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<WireData> get _filteredWireData {
    List<WireData> filtered = standardWireData;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((wire) =>
        wire.awgSize.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        _getAmpacity(wire).toString().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  int _getAmpacity(WireData wire) {
    if (_selectedMaterial == ConductorMaterial.aluminum) {
      switch (_selectedTempRating) {
        case TemperatureRating.temp75C:
          return wire.ampacityAlum75C;
        case TemperatureRating.temp90C:
          return wire.ampacityAlum90C;
        case TemperatureRating.temp60C:
          return wire.ampacity60C; // Fallback to copper 60C
      }
    } else {
      switch (_selectedTempRating) {
        case TemperatureRating.temp60C:
          return wire.ampacity60C;
        case TemperatureRating.temp75C:
          return wire.ampacity75C;
        case TemperatureRating.temp90C:
          return wire.ampacity90C;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Wire Size Chart',
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
            Tab(text: 'Chart'),
            Tab(text: 'Quick Reference'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartView(),
                _buildQuickReferenceView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppTheme.primaryNavy,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        0,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by AWG size or ampacity...',
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
          const SizedBox(height: AppTheme.spacingSm),
          
          // Filter chips
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Material',
                  _selectedMaterial == ConductorMaterial.copper ? 'Copper' : 'Aluminum',
                  () => _showMaterialSelector(),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _buildFilterChip(
                  'Temperature',
                  _getTempRatingDisplay(_selectedTempRating),
                  () => _showTemperatureSelector(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    value,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.white.withValues(alpha: 0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [AppTheme.shadowSm],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMd),
                  topRight: Radius.circular(AppTheme.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.table_chart,
                    color: AppTheme.primaryNavy,
                    size: AppTheme.iconMd,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'AWG Wire Sizing & Ampacity Chart',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Table header
            _buildTableHeader(),
            
            // Table rows
            ..._filteredWireData.map((wire) => _buildTableRow(wire)),
            
            // Footer with NEC reference
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusMd),
                  bottomRight: Radius.circular(AppTheme.radiusMd),
                ),
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
                      'Based on NEC Table 310.15(B)(16) - Allowable ampacities for insulated conductors',
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
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'AWG Size',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Ampacity',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Circular Mils',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Diameter',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(WireData wire) {
    int ampacity = _getAmpacity(wire);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.lightGray.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              ElectricalHelpers.formatAwgSize(wire.awgSize),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              ampacity > 0 ? '${ampacity}A' : 'N/A',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${wire.circularMils.toInt()}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${wire.diameterInches.toStringAsFixed(3)}"',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReferenceView() {
    List<String> commonSizes = ['14', '12', '10', '8', '6', '4', '2', '1/0', '2/0', '4/0'];
    List<WireData> commonWires = standardWireData.where((wire) => 
      commonSizes.contains(wire.awgSize)
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Common Wire Sizes',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          ...commonWires.map((wire) => _buildQuickReferenceCard(wire)),
          
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildElectricalNotes(),
        ],
      ),
    );
  }

  Widget _buildQuickReferenceCard(WireData wire) {
    int ampacity = _getAmpacity(wire);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: Text(
                wire.awgSize,
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ElectricalHelpers.formatAwgSize(wire.awgSize),
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ampacity > 0 ? '$ampacity amperes' : 'Not rated for aluminum',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${wire.circularMils.toInt()}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'CM',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElectricalNotes() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.infoBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.infoBlue,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Important Notes',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.infoBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          ...const [
            '• Ampacities shown are for copper conductors in raceway',
            '• Aluminum conductors have lower ampacity ratings',
            '• Derating may be required for multiple conductors',
            '• Temperature correction factors may apply',
            '• Always consult NEC for specific applications',
            '• Voltage drop calculations may require larger wire',
          ].map((note) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
            child: Text(
              note,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.infoBlue,
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showMaterialSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Conductor Material',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            ...ConductorMaterial.values.map((material) => ListTile(
              title: Text(material == ConductorMaterial.copper ? 'Copper' : 'Aluminum'),
              leading: Radio<ConductorMaterial>(
                value: material,
                groupValue: _selectedMaterial,
                onChanged: (value) {
                  setState(() {
                    _selectedMaterial = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                setState(() {
                  _selectedMaterial = material;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showTemperatureSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Temperature Rating',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            ...TemperatureRating.values.map((rating) => ListTile(
              title: Text(_getTempRatingDisplay(rating)),
              leading: Radio<TemperatureRating>(
                value: rating,
                groupValue: _selectedTempRating,
                onChanged: (value) {
                  setState(() {
                    _selectedTempRating = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                setState(() {
                  _selectedTempRating = rating;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _getTempRatingDisplay(TemperatureRating rating) {
    switch (rating) {
      case TemperatureRating.temp60C:
        return '60°C (140°F)';
      case TemperatureRating.temp75C:
        return '75°C (167°F)';
      case TemperatureRating.temp90C:
        return '90°C (194°F)';
    }
  }
}