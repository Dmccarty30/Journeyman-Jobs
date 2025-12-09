import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../design_system/widgets/design_system_widgets.dart';
import '../../../../electrical_components/jj_circuit_breaker_switch_list_tile.dart';
import '../../../../electrical_components/jj_circuit_breaker_switch.dart';
import 'calculation_helpers.dart';

class LoadCalculator extends StatefulWidget {
  const LoadCalculator({super.key});

  @override
  State<LoadCalculator> createState() => _LoadCalculatorState();
}

class _LoadCalculatorState extends State<LoadCalculator> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _squareFootageController = TextEditingController();
  final _hvacLoadController = TextEditingController();
  
  // Form values
  int _smallApplianceCircuits = 2;
  bool _hasLaundryCircuit = true;
  int _systemVoltage = 240;
  final List<ApplianceEntry> _appliances = [];
  
  LoadCalculationResult? _result;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _squareFootageController.dispose();
    _hvacLoadController.dispose();
    super.dispose();
  }

  void _calculateLoad() {
    final squareFootage = double.tryParse(_squareFootageController.text);
    final hvacLoad = double.tryParse(_hvacLoadController.text) ?? 0;
    
    if (squareFootage == null || squareFootage <= 0) {
      JJSnackBar.showError(
        context: context,
        message: 'Please enter valid square footage',
      );
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    // Convert appliance entries to ApplianceLoad objects
    final appliances = _appliances.map((entry) => ApplianceLoad(
      name: entry.name,
      load: entry.load,
      isMotor: entry.isMotor,
      powerFactor: entry.powerFactor,
    )).toList();

    // Simulate brief calculation delay for UX
    Future.delayed(const Duration(milliseconds: 400), () {
      final result = ElectricalCalculations.calculateResidentialLoad(
        squareFootage: squareFootage,
        smallApplianceCircuits: _smallApplianceCircuits,
        hasLaundryCircuit: _hasLaundryCircuit,
        appliances: appliances,
        hvacLoad: hvacLoad,
        systemVoltage: _systemVoltage,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isCalculating = false;
        });
      }
    });
  }

  void _addAppliance() {
    setState(() {
      _appliances.add(ApplianceEntry());
    });
  }

  void _removeAppliance(int index) {
    setState(() {
      _appliances.removeAt(index);
    });
    if (_squareFootageController.text.isNotEmpty) {
      _calculateLoad();
    }
  }

  void _clearCalculation() {
    setState(() {
      _result = null;
      _squareFootageController.clear();
      _hvacLoadController.clear();
      _appliances.clear();
      _smallApplianceCircuits = 2;
      _hasLaundryCircuit = true;
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
          'Load Calculator',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCopper,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Inputs'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputsTab(),
          _buildResultsTab(),
        ],
      ),
    );
  }

  Widget _buildInputsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalculatorHeader(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildBasicLoadsSection(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildAppliancesSection(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildHVACSection(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildSystemVoltageSection(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildCalculateButton(),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_result == null) {
      return Center(
        child: JJEmptyState(
          title: 'No Calculation Yet',
          subtitle: 'Complete the inputs and calculate to see results',
          icon: Icons.analytics,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultsSummary(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildLoadBreakdown(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildServiceSizeRecommendation(),
          const SizedBox(height: AppTheme.spacingLg),
          
          _buildNecReference(),
        ],
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
              Icons.analytics,
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
                  'Residential Load Calculator',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Calculate electrical loads and service size per NEC Article 220',
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

  Widget _buildBasicLoadsSection() {
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
            'Basic Loads',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Square footage
          JJTextField(
            controller: _squareFootageController,
            label: 'Dwelling Square Footage',
            keyboardType: TextInputType.number,
            hintText: 'General lighting @ 3 VA per sq ft (NEC 220.12)',
            onChanged: (value) {
              if (value.isNotEmpty && double.tryParse(value) != null) {
                _calculateLoad();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Small appliance circuits
          _buildCounterField(
            label: 'Small Appliance Circuits',
            value: _smallApplianceCircuits,
            min: 2,
            max: 10,
            helperText: '1500 VA each (NEC 220.52(A)) - minimum 2 required',
            onChanged: (value) {
              setState(() {
                _smallApplianceCircuits = value;
              });
              if (_squareFootageController.text.isNotEmpty) {
                _calculateLoad();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Laundry circuit
          JJCircuitBreakerSwitchListTile(
            title: Text(
              'Laundry Circuit',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '1500 VA (NEC 220.52(B))',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            value: _hasLaundryCircuit,
            onChanged: (value) {
              setState(() {
                _hasLaundryCircuit = value;
              });
              if (_squareFootageController.text.isNotEmpty) {
                _calculateLoad();
              }
            },
            size: JJCircuitBreakerSize.small,
            showElectricalEffects: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppliancesSection() {
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
                'Appliances & Fixed Loads',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _addAppliance,
                icon: const Icon(Icons.add_circle, color: AppTheme.accentCopper),
                tooltip: 'Add Appliance',
              ),
            ],
          ),
          
          if (_appliances.isEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.lightGray),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.textLight,
                    size: AppTheme.iconSm,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      'No appliances added. Tap + to add appliances like water heater, range, dryer, etc.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.spacingMd),
            ..._appliances.asMap().entries.map((entry) {
              final index = entry.key;
              final appliance = entry.value;
              return _buildApplianceRow(appliance, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildApplianceRow(ApplianceEntry appliance, int index) {
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
                'Appliance ${index + 1}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () => _removeAppliance(index),
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
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: appliance.name,
                  decoration: const InputDecoration(
                    labelText: 'Appliance Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    appliance.name = value;
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: appliance.load.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Load (VA)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    appliance.load = double.tryParse(value) ?? 0;
                    if (_squareFootageController.text.isNotEmpty) {
                      _calculateLoad();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          CheckboxListTile(
            title: Text(
              'Motor Load',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              'Subject to 125% multiplier (NEC 430.22)',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            value: appliance.isMotor,
            onChanged: (value) {
              setState(() {
                appliance.isMotor = value ?? false;
              });
              if (_squareFootageController.text.isNotEmpty) {
                _calculateLoad();
              }
            },
            activeColor: AppTheme.accentCopper,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildHVACSection() {
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
            'HVAC Load',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          JJTextField(
            controller: _hvacLoadController,
            label: 'HVAC Load (VA)',
            keyboardType: TextInputType.number,
            hintText: 'Air conditioning, heat pump, or heating load - use larger of heating or cooling',
            onChanged: (value) {
              if (_squareFootageController.text.isNotEmpty) {
                _calculateLoad();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemVoltageSection() {
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
            'System Voltage',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          Wrap(
            spacing: AppTheme.spacingSm,
            children: [120, 240].map((voltage) => FilterChip(
              label: Text('${voltage}V'),
              selected: _systemVoltage == voltage,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _systemVoltage = voltage;
                  });
                  if (_squareFootageController.text.isNotEmpty) {
                    _calculateLoad();
                  }
                }
              },
              selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentCopper,
              side: _systemVoltage == voltage 
                  ? const BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthThick)
                  : null,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCalculating ? null : _calculateLoad,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentCopper,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: _isCalculating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              )
            : Text(
                'Calculate Load',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResultsSummary() {
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
                'Load Calculation Summary',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          _buildResultRow(
            'Total Calculated Load',
            '${_result!.totalLoad.toStringAsFixed(0)} VA',
            isHighlight: true,
          ),
          _buildResultRow(
            'Demand Load (after factors)',
            '${_result!.demandLoad.toStringAsFixed(0)} VA',
            isHighlight: true,
            color: AppTheme.accentCopper,
          ),
          _buildResultRow(
            'Service Current',
            '${(_result!.demandLoad / _systemVoltage).toStringAsFixed(1)} Amperes',
          ),
          _buildResultRow(
            'Recommended Service Size',
            '${_result!.recommendedServiceSize} Amperes',
            isHighlight: true,
            color: AppTheme.successGreen,
          ),
          
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
        ],
      ),
    );
  }

  Widget _buildLoadBreakdown() {
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
            'Load Breakdown',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          ..._result!.loadBreakdown.entries.map((entry) => 
            _buildResultRow(entry.key, '${entry.value.toStringAsFixed(0)} VA')
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSizeRecommendation() {
    List<int> standardSizes = [100, 125, 150, 200, 225, 300, 400];
    int recommendedSize = _result!.recommendedServiceSize;
    
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
            'Service Size Recommendation',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: standardSizes.map((size) {
              bool isRecommended = size == recommendedSize;
              bool isOversized = size > recommendedSize;
              bool isUndersized = size < recommendedSize;
              
              Color color = isRecommended 
                  ? AppTheme.successGreen
                  : isOversized 
                      ? AppTheme.infoBlue
                      : AppTheme.errorRed;
              
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: color,
                    width: isRecommended ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${size}A',
                      style: AppTheme.bodyMedium.copyWith(
                        color: color,
                        fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isRecommended) ...[
                      Text(
                        'Recommended',
                        style: AppTheme.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else if (isUndersized) ...[
                      Text(
                        'Too Small',
                        style: AppTheme.labelSmall.copyWith(
                          color: color,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Oversized',
                        style: AppTheme.labelSmall.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
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
                Icons.book,
                color: AppTheme.infoBlue,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'NEC Load Calculation References',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.infoBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          Text(
            'Reference: ${_result?.necReference ?? "NEC Article 220"}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.infoBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          ...const [
            '• NEC 220.12: General lighting loads',
            '• NEC 220.52(A): Small appliance branch circuits',
            '• NEC 220.52(B): Laundry branch circuit',
            '• NEC 220.42: General lighting demand factors',
            '• NEC 230.42(B): Minimum service size (100A for dwelling)',
            '• NEC 430.22: Motor load calculations',
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

  Widget _buildResultRow(String label, String value, {bool isHighlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: color ?? (isHighlight ? AppTheme.accentCopper : AppTheme.textPrimary),
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterField({
    required String label,
    required int value,
    required int min,
    required int max,
    required String helperText,
    required void Function(int) onChanged,
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
        
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.lightGray,
                foregroundColor: AppTheme.textSecondary,
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                child: Text(
                  '$value',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
        
        if (helperText.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            helperText,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class ApplianceEntry {
  String name;
  double load;
  bool isMotor;
  double powerFactor;

  ApplianceEntry({
    this.name = '',
    this.load = 0,
    this.isMotor = false,
    this.powerFactor = 1.0,
  });
}