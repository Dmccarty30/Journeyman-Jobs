import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../design_system/widgets/design_system_widgets.dart';
import 'electrical_constants.dart';
import 'calculation_helpers.dart';

class VoltageDropCalculator extends StatefulWidget {
  const VoltageDropCalculator({super.key});

  @override
  State<VoltageDropCalculator> createState() => _VoltageDropCalculatorState();
}

class _VoltageDropCalculatorState extends State<VoltageDropCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _lengthController = TextEditingController();
  
  String? _selectedWireSize;
  int _systemVoltage = 240;
  ConductorMaterial _conductorMaterial = ConductorMaterial.copper;
  CircuitType _circuitType = CircuitType.singlePhase;
  
  VoltageDropResult? _result;
  bool _isCalculating = false;

  @override
  void dispose() {
    _currentController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _calculateVoltageDrop() async {
    if (_formKey.currentState?.validate() != true || _selectedWireSize == null) {
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    // Simulate brief calculation delay for UX
    await Future.delayed(const Duration(milliseconds: 300));
    
    final result = ElectricalCalculations.calculateVoltageDrop(
      wireSize: _selectedWireSize!,
      current: double.parse(_currentController.text),
      length: double.parse(_lengthController.text),
      systemVoltage: _systemVoltage,
      material: _conductorMaterial,
      circuitType: _circuitType,
    );

    if (mounted) {
      setState(() {
        _result = result;
        _isCalculating = false;
      });
    }
  }

  void _clearCalculation() {
    setState(() {
      _result = null;
      _currentController.clear();
      _lengthController.clear();
      _selectedWireSize = null;
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
          'Voltage Drop Calculator',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalculatorHeader(),
              const SizedBox(height: AppTheme.spacingLg),
              
              _buildInputSection(),
              const SizedBox(height: AppTheme.spacingLg),
              
              if (_result != null) ...[
                _buildResultsSection(),
                const SizedBox(height: AppTheme.spacingLg),
              ],
              
              _buildCalculateButton(),
              const SizedBox(height: AppTheme.spacingLg),
              
              _buildFormulaReference(),
            ],
          ),
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
              Icons.calculate,
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
                  'Voltage Drop Calculator',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Calculate voltage drop for wire runs based on NEC standards',
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

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthMedium,
        ),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Circuit Parameters',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Wire Size Dropdown
          _buildDropdownField(
            label: 'Wire Size (AWG/MCM)',
            value: _selectedWireSize,
            items: standardWireData.map((wire) => DropdownMenuItem(
              value: wire.awgSize,
              child: Text(ElectricalHelpers.formatAwgSize(wire.awgSize)),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedWireSize = value;
              });
              if (_formKey.currentState?.validate() == true && 
                  _currentController.text.isNotEmpty && 
                  _lengthController.text.isNotEmpty) {
                _calculateVoltageDrop();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Current Input
          JJTextField(
            controller: _currentController,
            label: 'Current (Amperes)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter current';
              }
              final current = double.tryParse(value);
              if (current == null || current <= 0) {
                return 'Please enter a valid positive number';
              }
              if (current > 10000) {
                return 'Current seems unreasonably high';
              }
              return null;
            },
            onChanged: (value) {
              if (_formKey.currentState?.validate() == true && 
                  _selectedWireSize != null && 
                  _lengthController.text.isNotEmpty) {
                _calculateVoltageDrop();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Length Input
          JJTextField(
            controller: _lengthController,
            label: 'Length (Feet)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter length';
              }
              final length = double.tryParse(value);
              if (length == null || length <= 0) {
                return 'Please enter a valid positive number';
              }
              if (length > 10000) {
                return 'Length seems unreasonably high';
              }
              return null;
            },
            onChanged: (value) {
              if (_formKey.currentState?.validate() == true && 
                  _selectedWireSize != null && 
                  _currentController.text.isNotEmpty) {
                _calculateVoltageDrop();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // System Voltage
          _buildDropdownField(
            label: 'System Voltage',
            value: _systemVoltage,
            items: ElectricalConstants.standardVoltages.map((voltage) => DropdownMenuItem(
              value: voltage,
              child: Text('${voltage}V'),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _systemVoltage = value!;
              });
              if (_formKey.currentState?.validate() == true && 
                  _selectedWireSize != null && 
                  _currentController.text.isNotEmpty && 
                  _lengthController.text.isNotEmpty) {
                _calculateVoltageDrop();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Material Selection
          Text(
            'Conductor Material',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  'Copper',
                  ConductorMaterial.copper,
                  _conductorMaterial,
                  (value) {
                    setState(() {
                      _conductorMaterial = value!;
                    });
                    if (_formKey.currentState?.validate() == true && 
                        _selectedWireSize != null && 
                        _currentController.text.isNotEmpty && 
                        _lengthController.text.isNotEmpty) {
                      _calculateVoltageDrop();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _buildRadioOption(
                  'Aluminum',
                  ConductorMaterial.aluminum,
                  _conductorMaterial,
                  (value) {
                    setState(() {
                      _conductorMaterial = value!;
                    });
                    if (_formKey.currentState?.validate() == true && 
                        _selectedWireSize != null && 
                        _currentController.text.isNotEmpty && 
                        _lengthController.text.isNotEmpty) {
                      _calculateVoltageDrop();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Circuit Type Selection
          Text(
            'Circuit Type',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  'Single Phase',
                  CircuitType.singlePhase,
                  _circuitType,
                  (value) {
                    setState(() {
                      _circuitType = value!;
                    });
                    if (_formKey.currentState?.validate() == true && 
                        _selectedWireSize != null && 
                        _currentController.text.isNotEmpty && 
                        _lengthController.text.isNotEmpty) {
                      _calculateVoltageDrop();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _buildRadioOption(
                  'Three Phase',
                  CircuitType.threePhase,
                  _circuitType,
                  (value) {
                    setState(() {
                      _circuitType = value!;
                    });
                    if (_formKey.currentState?.validate() == true && 
                        _selectedWireSize != null && 
                        _currentController.text.isNotEmpty && 
                        _lengthController.text.isNotEmpty) {
                      _calculateVoltageDrop();
                    }
                  },
                ),
              ),
            ],
          ),
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
          initialValue: value,
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
          validator: (value) {
            if (value == null) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRadioOption<T>(
    String title,
    T value,
    T groupValue,
    void Function(T?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: value == groupValue ? AppTheme.accentCopper : AppTheme.lightGray,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: RadioListTile<T>(
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppTheme.accentCopper,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_result == null) return const SizedBox.shrink();

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
                'Calculation Results',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Main results
          _buildResultRow(
            'Voltage Drop',
            '${_result!.voltageDropVolts.toStringAsFixed(2)} volts',
            isHighlight: true,
          ),
          _buildResultRow(
            'Percentage Drop',
            '${_result!.voltageDropPercentage.toStringAsFixed(2)}%',
            isHighlight: true,
            color: ElectricalHelpers.getComplianceColor(
              _result!.voltageDropPercentage,
              ElectricalConstants.branchCircuitVoltageDropLimit,
            ),
          ),
          _buildResultRow(
            'Final Voltage',
            '${_result!.finalVoltage.toStringAsFixed(1)} volts',
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

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCalculating ? null : _calculateVoltageDrop,
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
                'Calculate Voltage Drop',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildFormulaReference() {
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
                Icons.functions,
                color: AppTheme.infoBlue,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Voltage Drop Formula',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.infoBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          Text(
            'VD = (K × I × L) / CM',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.infoBlue,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          ...const [
            'VD = Voltage Drop (volts)',
            'K = Resistivity constant (12.9 for copper, 21.2 for aluminum)',
            'I = Current (amperes)',
            'L = Length (feet)',
            'CM = Circular mils of conductor',
            '',
            'Single-phase: Multiply by 2',
            'Three-phase: Multiply by √3 (1.732)',
            '',
            'NEC recommends maximum 3% voltage drop for branch circuits',
          ].map((line) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
            child: Text(
              line,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.infoBlue,
                fontWeight: line.isEmpty ? FontWeight.normal : FontWeight.w400,
              ),
            ),
          )),
        ],
      ),
    );
  }
}