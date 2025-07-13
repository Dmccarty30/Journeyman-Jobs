import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import 'electrical_constants.dart';
import 'calculation_helpers.dart';

class ConduitFillCalculator extends StatefulWidget {
  const ConduitFillCalculator({super.key});

  @override
  State<ConduitFillCalculator> createState() => _ConduitFillCalculatorState();
}

class _ConduitFillCalculatorState extends State<ConduitFillCalculator> {
  String? _selectedConduitSize;
  ConduitType _conduitType = ConduitType.emt;
  List<ConductorEntry> _conductors = [ConductorEntry()];
  ConduitFillResult? _result;

  void _addConductor() {
    setState(() {
      _conductors.add(ConductorEntry());
    });
    _calculateConduitFill();
  }

  void _removeConductor(int index) {
    if (_conductors.length > 1) {
      setState(() {
        _conductors.removeAt(index);
      });
      _calculateConduitFill();
    }
  }

  void _calculateConduitFill() {
    if (_selectedConduitSize == null) return;

    // Filter out conductors with no size selected
    final validConductors = _conductors
        .where((conductor) => conductor.wireSize != null && conductor.quantity > 0)
        .map((conductor) => ConductorInfo(
              awgSize: conductor.wireSize!,
              quantity: conductor.quantity,
              insulationType: conductor.insulationType,
            ))
        .toList();

    if (validConductors.isEmpty) {
      setState(() {
        _result = null;
      });
      return;
    }

    setState(() {
    });

    // Simulate brief calculation delay for UX
    Future.delayed(const Duration(milliseconds: 200), () {
      final result = ElectricalCalculations.calculateConduitFill(
        conduitSize: _selectedConduitSize!,
        conduitType: _conduitType,
        conductors: validConductors,
      );

      if (mounted) {
        setState(() {
          _result = result;
        });
      }
    });
  }

  void _clearCalculation() {
    setState(() {
      _result = null;
      _selectedConduitSize = null;
      _conductors = [ConductorEntry()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Conduit Fill Calculator',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.white),
              onPressed: _clearCalculation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalculatorHeader(),
            const SizedBox(height: AppTheme.spacingLg),
            
            _buildConduitSection(),
            const SizedBox(height: AppTheme.spacingLg),
            
            _buildConductorsSection(),
            const SizedBox(height: AppTheme.spacingLg),
            
            if (_result != null) ...[
              _buildResultsSection(),
              const SizedBox(height: AppTheme.spacingLg),
            ],
            
            _buildNecReference(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorHeader() {
    return Container(
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
            child: const Icon(
              Icons.architecture,
              color: AppTheme.accentCopper,
              size: AppTheme.iconMd,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conduit Fill Calculator',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Calculate maximum wire capacity for conduit per NEC Chapter 9',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConduitSection() {
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
            'Conduit Information',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Conduit Type Selection
          Text(
            'Conduit Type',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: AppTheme.spacingSm,
            children: ConduitType.values.map((type) => FilterChip(
              label: Text(_getConduitTypeDisplay(type)),
              selected: _conduitType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _conduitType = type;
                    _selectedConduitSize = null; // Reset size when type changes
                  });
                }
              },
              selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentCopper,
              side: _conduitType == type 
                  ? const BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthThick)
                  : null,
            )).toList(),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Conduit Size Dropdown
          _buildDropdownField<String>(
            label: 'Conduit Size',
            value: _selectedConduitSize,
            items: _getAvailableConduitSizes().map((size) => DropdownMenuItem(
              value: size,
              child: Text(size),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedConduitSize = value;
              });
              _calculateConduitFill();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConductorsSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conductors',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _addConductor,
                icon: const Icon(Icons.add_circle, color: AppTheme.accentCopper),
                tooltip: 'Add Conductor',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          ..._conductors.asMap().entries.map((entry) {
            final index = entry.key;
            final conductor = entry.value;
            return _buildConductorRow(conductor, index);
          }),
        ],
      ),
    );
  }

  Widget _buildConductorRow(ConductorEntry conductor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conductor ${index + 1}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_conductors.length > 1)
                IconButton(
                  onPressed: () => _removeConductor(index),
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppTheme.errorRed,
                    size: AppTheme.iconSm,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          Row(
            children: [
              // Wire Size
              Expanded(
                flex: 2,
                child: _buildDropdownField<String>(
                  label: 'Wire Size',
                  value: conductor.wireSize,
                  items: standardWireData.map((wire) => DropdownMenuItem(
                    value: wire.awgSize,
                    child: Text(ElectricalHelpers.formatAwgSize(wire.awgSize)),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      conductor.wireSize = value;
                    });
                    _calculateConduitFill();
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              
              // Quantity
              Expanded(
                flex: 1,
                child: _buildQuantityField(conductor, index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityField(ConductorEntry conductor, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: conductor.quantity > 1 ? () {
                  setState(() {
                    conductor.quantity--;
                  });
                  _calculateConduitFill();
                } : null,
                icon: const Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.lightGray,
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                  horizontal: 4,
                ),
                child: Text(
                  '${conductor.quantity}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: conductor.quantity < 50 ? () {
                  setState(() {
                    conductor.quantity++;
                  });
                  _calculateConduitFill();
                } : null,
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (_result == null) return const SizedBox.shrink();

    double fillPercentage = _result!.fillPercentage;
    Color fillColor = ElectricalHelpers.getComplianceColor(
      fillPercentage,
      _getFillLimit() * 100,
    );

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: Border.all(
          color: _result!.isCompliant ? AppTheme.successGreen : AppTheme.errorRed,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _result!.isCompliant ? Icons.check_circle : Icons.error,
                color: _result!.isCompliant ? AppTheme.successGreen : AppTheme.errorRed,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Fill Calculation Results',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Fill percentage with visual indicator
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: fillColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: fillColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Conduit Fill',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${fillPercentage.toStringAsFixed(1)}%',
                      style: AppTheme.titleMedium.copyWith(
                        color: fillColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                
                // Progress bar
                LinearProgressIndicator(
                  value: fillPercentage / 100,
                  backgroundColor: AppTheme.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(fillColor),
                  minHeight: 8,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    Text(
                      'Limit: ${(_getFillLimit() * 100).toInt()}%',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    Text(
                      '100%',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Detailed results
          _buildResultRow('Total Conductor Area', '${_result!.totalConductorArea.toStringAsFixed(4)} sq in'),
          _buildResultRow('Conduit Internal Area', '${_result!.conduitArea.toStringAsFixed(4)} sq in'),
          _buildResultRow('Number of Conductors', '${_result!.conductorCount}'),
          _buildResultRow('Fill Limit', '${(_getFillLimit() * 100).toInt()}%'),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Compliance message
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: (_result!.isCompliant ? AppTheme.successGreen : AppTheme.errorRed)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  _result!.isCompliant ? Icons.thumb_up : Icons.warning,
                  color: _result!.isCompliant ? AppTheme.successGreen : AppTheme.errorRed,
                  size: AppTheme.iconSm,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    _result!.message,
                    style: AppTheme.bodySmall.copyWith(
                      color: _result!.isCompliant ? AppTheme.successGreen : AppTheme.errorRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          // NEC reference
          Text(
            'Reference: ${_result!.necReference}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNecReference() {
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
                Icons.info_outline,
                color: AppTheme.infoBlue,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'NEC Conduit Fill Requirements',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.infoBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          ...const [
            '• 1 conductor: Maximum 53% fill',
            '• 2 conductors: Maximum 31% fill',
            '• 3 or more conductors: Maximum 40% fill',
            '• Based on NEC Chapter 9, Table 1',
            '• Conductor areas from NEC Chapter 9, Table 5',
            '• Conduit dimensions from NEC Chapter 9, Table 4',
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

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: const BorderSide(color: AppTheme.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: const BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthThick),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
          ),
        ),
      ],
    );
  }

  String _getConduitTypeDisplay(ConduitType type) {
    switch (type) {
      case ConduitType.emt:
        return 'EMT';
      case ConduitType.imc:
        return 'IMC';
      case ConduitType.rmc:
        return 'RMC';
      case ConduitType.pvc:
        return 'PVC';
    }
  }

  List<String> _getAvailableConduitSizes() {
    // Currently only EMT data is available
    if (_conduitType == ConduitType.emt) {
      return emtConduitData.map((conduit) => conduit.size).toList();
    }
    return [];
  }

  double _getFillLimit() {
    int totalConductors = _conductors
        .where((conductor) => conductor.wireSize != null)
        .map((conductor) => conductor.quantity)
        .fold(0, (sum, quantity) => sum + quantity);

    if (totalConductors == 1) {
      return ElectricalConstants.fill1Conductor;
    } else if (totalConductors == 2) {
      return ElectricalConstants.fill2Conductor;
    } else {
      return ElectricalConstants.fill3OrMore;
    }
  }
}

class ConductorEntry {
  String? wireSize;
  int quantity;
  String insulationType;

  ConductorEntry({
    this.wireSize,
    this.quantity = 1,
    this.insulationType = 'THWN',
  });
}