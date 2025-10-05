import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class ElectricalCalculatorsScreen extends StatefulWidget {
  const ElectricalCalculatorsScreen({super.key});

  @override
  State<ElectricalCalculatorsScreen> createState() => _ElectricalCalculatorsScreenState();
}

class _ElectricalCalculatorsScreenState extends State<ElectricalCalculatorsScreen> {
  int _selectedCalculator = 0;
  
  final List<Map<String, dynamic>> _calculators = [
    {
      'title': 'Ohm\'s Law',
      'description': 'Calculate voltage, current, resistance, or power',
      'icon': Icons.flash_on,
    },
    {
      'title': 'Wire Size',
      'description': 'Determine proper wire gauge for electrical loads',
      'icon': Icons.cable,
    },
    {
      'title': 'Conduit Fill',
      'description': 'Calculate conduit fill capacity',
      'icon': Icons.circle_outlined,
    },
    {
      'title': 'Voltage Drop',
      'description': 'Calculate voltage drop over distance',
      'icon': Icons.trending_down,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Electrical Calculators',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Column(
        children: [
          // Calculator selector
          Container(
            height: 120,
            color: AppTheme.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: _calculators.length,
              itemBuilder: (context, index) {
                final calculator = _calculators[index];
                final isSelected = index == _selectedCalculator;
                
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: AppTheme.spacingMd),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCalculator = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accentCopper.withValues(alpha: 0.1) : AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: isSelected ? AppTheme.accentCopper : AppTheme.mediumGray,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            calculator['icon'],
                            size: AppTheme.iconMd,
                            color: isSelected ? AppTheme.accentCopper : AppTheme.textSecondary,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            calculator['title'],
                            style: AppTheme.labelMedium.copyWith(
                              color: isSelected ? AppTheme.accentCopper : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Calculator content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: _buildCalculatorContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorContent() {
    switch (_selectedCalculator) {
      case 0:
        return _OhmsLawCalculator();
      case 1:
        return _WireSizeCalculator();
      case 2:
        return _ConduitFillCalculator();
      case 3:
        return _VoltageDropCalculator();
      default:
        return _OhmsLawCalculator();
    }
  }
}

class _OhmsLawCalculator extends StatefulWidget {
  @override
  State<_OhmsLawCalculator> createState() => _OhmsLawCalculatorState();
}

class _OhmsLawCalculatorState extends State<_OhmsLawCalculator> {
  final _voltageController = TextEditingController();
  final _currentController = TextEditingController();
  final _resistanceController = TextEditingController();
  final _powerController = TextEditingController();
  
  String _result = '';

  void _calculate() {
    try {
      double? voltage = _voltageController.text.isNotEmpty ? double.parse(_voltageController.text) : null;
      double? current = _currentController.text.isNotEmpty ? double.parse(_currentController.text) : null;
      double? resistance = _resistanceController.text.isNotEmpty ? double.parse(_resistanceController.text) : null;
      double? power = _powerController.text.isNotEmpty ? double.parse(_powerController.text) : null;

      String result = '';

      // Calculate missing values
      if (voltage != null && current != null) {
        resistance = voltage / current;
        power = voltage * current;
        result += 'Resistance: ${resistance.toStringAsFixed(2)} Ω\n';
        result += 'Power: ${power.toStringAsFixed(2)} W\n';
      } else if (voltage != null && resistance != null) {
        current = voltage / resistance;
        power = (voltage * voltage) / resistance;
        result += 'Current: ${current.toStringAsFixed(2)} A\n';
        result += 'Power: ${power.toStringAsFixed(2)} W\n';
      } else if (current != null && resistance != null) {
        voltage = current * resistance;
        power = current * current * resistance;
        result += 'Voltage: ${voltage.toStringAsFixed(2)} V\n';
        result += 'Power: ${power.toStringAsFixed(2)} W\n';
      } else if (voltage != null && power != null) {
        current = power / voltage;
        resistance = (voltage * voltage) / power;
        result += 'Current: ${current.toStringAsFixed(2)} A\n';
        result += 'Resistance: ${resistance.toStringAsFixed(2)} Ω\n';
      } else {
        result = 'Please enter at least two values to calculate.';
      }

      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid input. Please enter valid numbers.';
      });
    }
  }

  void _clear() {
    _voltageController.clear();
    _currentController.clear();
    _resistanceController.clear();
    _powerController.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return JJCard(
      backgroundColor: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ohm\'s Law Calculator',
            style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Enter any two values to calculate the remaining values.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          JJTextField(
            label: 'Voltage (V)',
            controller: _voltageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Current (A)',
            controller: _currentController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Resistance (Ω)',
            controller: _resistanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Power (W)',
            controller: _powerController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Row(
            children: [
              Expanded(
                child: JJSecondaryButton(
                  text: 'Clear',
                  onPressed: _clear,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: JJPrimaryButton(
                  text: 'Calculate',
                  onPressed: _calculate,
                  variant: JJButtonVariant.primary,
                ),
              ),
            ],
          ),

          if (_result.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results:',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    _result,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WireSizeCalculator extends StatefulWidget {
  @override
  State<_WireSizeCalculator> createState() => _WireSizeCalculatorState();
}

class _WireSizeCalculatorState extends State<_WireSizeCalculator> {
  final _currentController = TextEditingController();
  final _distanceController = TextEditingController();
  String _selectedVoltage = '120';
  String _result = '';

  final List<String> _voltages = ['120', '240', '277', '480'];

  // Simplified wire size table (AWG to ampacity)
  final Map<String, int> _wireAmps = {
    '14': 15,
    '12': 20,
    '10': 30,
    '8': 40,
    '6': 55,
    '4': 70,
    '2': 95,
    '1': 110,
    '1/0': 125,
    '2/0': 145,
    '3/0': 165,
    '4/0': 195,
  };

  void _calculate() {
    try {
      double current = double.parse(_currentController.text);
      // Distance for future voltage drop calculations
      // double distance = double.parse(_distanceController.text);
      
      // Find minimum wire size for current capacity
      String? selectedWire;
      for (String wire in _wireAmps.keys) {
        if (_wireAmps[wire]! >= current) {
          selectedWire = wire;
          break;
        }
      }

      if (selectedWire == null) {
        setState(() {
          _result = 'Current exceeds standard wire ratings. Consult an engineer.';
        });
        return;
      }

      // Simple voltage drop calculation (3% max recommended)
      double maxVoltageDrop = double.parse(_selectedVoltage) * 0.03;
      
      setState(() {
        _result = 'Recommended Wire Size: $selectedWire AWG\n';
        _result += 'Wire Capacity: ${_wireAmps[selectedWire]} A\n';
        _result += 'Max Voltage Drop: ${maxVoltageDrop.toStringAsFixed(1)} V\n';
        _result += '\nNote: This is a simplified calculation. ';
        _result += 'Consult NEC and local codes for final sizing.';
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid input. Please enter valid numbers.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return JJCard(
      backgroundColor: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wire Size Calculator',
            style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Calculate minimum wire size for electrical loads.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          JJTextField(
            label: 'Load Current (A)',
            controller: _currentController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Distance (ft)',
            controller: _distanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Voltage dropdown
          Text('Voltage', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spacingSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.mediumGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedVoltage,
                isExpanded: true,
                items: _voltages.map((voltage) => DropdownMenuItem(
                  value: voltage,
                  child: Text('${voltage}V'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedVoltage = value!),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          JJPrimaryButton(
            text: 'Calculate Wire Size',
            onPressed: _calculate,
            isFullWidth: true,
            variant: JJButtonVariant.primary,
          ),

          if (_result.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(_result, style: AppTheme.bodyMedium),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConduitFillCalculator extends StatefulWidget {
  @override
  State<_ConduitFillCalculator> createState() => _ConduitFillCalculatorState();
}

class _ConduitFillCalculatorState extends State<_ConduitFillCalculator> {
  final _wireCountController = TextEditingController();
  String _selectedConduitSize = '1/2';
  String _selectedWireSize = '12';
  String _result = '';

  final List<String> _conduitSizes = ['1/2', '3/4', '1', '1-1/4', '1-1/2', '2', '2-1/2', '3', '4'];
  final List<String> _wireSizes = ['14', '12', '10', '8', '6', '4', '2', '1', '1/0', '2/0'];

  void _calculate() {
    try {
      int wireCount = int.parse(_wireCountController.text);
      
      // Simplified conduit fill calculation
      // This is a basic example - real calculations are more complex
      Map<String, Map<String, int>> maxWires = {
        '1/2': {'14': 9, '12': 7, '10': 5, '8': 2, '6': 1},
        '3/4': {'14': 16, '12': 13, '10': 9, '8': 5, '6': 3, '4': 1},
        '1': {'14': 26, '12': 22, '10': 16, '8': 9, '6': 6, '4': 4, '2': 3},
        // Add more sizes as needed
      };

      int maxAllowed = maxWires[_selectedConduitSize]?[_selectedWireSize] ?? 0;
      bool withinLimit = wireCount <= maxAllowed;
      
      setState(() {
        _result = 'Conduit Size: $_selectedConduitSize"\n';
        _result += 'Wire Size: $_selectedWireSize AWG\n';
        _result += 'Wires: $wireCount\n';
        _result += 'Maximum Allowed: $maxAllowed\n';
        _result += 'Status: ${withinLimit ? "✓ Within Limit" : "✗ Exceeds Limit"}\n';
        _result += '\nNote: Based on NEC Chapter 9 tables. ';
        _result += 'Verify with current code requirements.';
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid input. Please enter valid numbers.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return JJCard(
      backgroundColor: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conduit Fill Calculator',
            style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Check if wire count meets NEC conduit fill requirements.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          JJTextField(
            label: 'Number of Wires',
            controller: _wireCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Conduit size dropdown
          Text('Conduit Size', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spacingSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.mediumGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedConduitSize,
                isExpanded: true,
                items: _conduitSizes.map((size) => DropdownMenuItem(
                  value: size,
                  child: Text('$size"'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedConduitSize = value!),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Wire size dropdown
          Text('Wire Size', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spacingSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.mediumGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedWireSize,
                isExpanded: true,
                items: _wireSizes.map((size) => DropdownMenuItem(
                  value: size,
                  child: Text('$size AWG'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedWireSize = value!),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          JJPrimaryButton(
            text: 'Check Fill',
            onPressed: _calculate,
            isFullWidth: true,
            variant: JJButtonVariant.primary,
          ),

          if (_result.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(_result, style: AppTheme.bodyMedium),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoltageDropCalculator extends StatefulWidget {
  @override
  State<_VoltageDropCalculator> createState() => _VoltageDropCalculatorState();
}

class _VoltageDropCalculatorState extends State<_VoltageDropCalculator> {
  final _currentController = TextEditingController();
  final _distanceController = TextEditingController();
  String _selectedVoltage = '120';
  String _selectedWireSize = '12';
  String _result = '';

  final List<String> _voltages = ['120', '240', '277', '480'];
  final List<String> _wireSizes = ['14', '12', '10', '8', '6', '4', '2', '1', '1/0', '2/0'];

  // Wire resistance per 1000 feet (ohms)
  final Map<String, double> _wireResistance = {
    '14': 3.07,
    '12': 1.93,
    '10': 1.21,
    '8': 0.764,
    '6': 0.491,
    '4': 0.308,
    '2': 0.194,
    '1': 0.154,
    '1/0': 0.122,
    '2/0': 0.0967,
  };

  void _calculate() {
    try {
      double current = double.parse(_currentController.text);
      double distance = double.parse(_distanceController.text);
      double voltage = double.parse(_selectedVoltage);
      
      double resistance = _wireResistance[_selectedWireSize]! * (distance / 1000) * 2; // Round trip
      double voltageDrop = current * resistance;
      double percentDrop = (voltageDrop / voltage) * 100;
      
      String status;
      if (percentDrop <= 3) {
        status = '✓ Acceptable (≤3%)';
      } else if (percentDrop <= 5) {
        status = '⚠ Marginal (3-5%)';
      } else {
        status = '✗ Excessive (>5%)';
      }

      setState(() {
        _result = 'System Voltage: ${voltage.toStringAsFixed(0)}V\n';
        _result += 'Wire Size: $_selectedWireSize AWG\n';
        _result += 'Current: ${current.toStringAsFixed(1)}A\n';
        _result += 'Distance: ${distance.toStringAsFixed(0)}ft\n';
        _result += 'Voltage Drop: ${voltageDrop.toStringAsFixed(2)}V\n';
        _result += 'Percent Drop: ${percentDrop.toStringAsFixed(2)}%\n';
        _result += 'Status: $status\n';
        _result += '\nNote: NEC recommends ≤3% for branch circuits, ≤5% total.';
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid input. Please enter valid numbers.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return JJCard(
      backgroundColor: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voltage Drop Calculator',
            style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Calculate voltage drop over wire runs.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          JJTextField(
            label: 'Load Current (A)',
            controller: _currentController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'One-way Distance (ft)',
            controller: _distanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Voltage and wire size dropdowns in a row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voltage', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.mediumGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVoltage,
                          isExpanded: true,
                          items: _voltages.map((voltage) => DropdownMenuItem(
                            value: voltage,
                            child: Text('${voltage}V'),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedVoltage = value!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wire Size', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.mediumGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedWireSize,
                          isExpanded: true,
                          items: _wireSizes.map((size) => DropdownMenuItem(
                            value: size,
                            child: Text('$size AWG'),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedWireSize = value!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLg),

          JJPrimaryButton(
            text: 'Calculate Drop',
            onPressed: _calculate,
            isFullWidth: true,
            variant: JJButtonVariant.primary,
          ),

          if (_result.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(_result, style: AppTheme.bodyMedium),
            ),
          ],
        ],
      ),
    );
  }
}
