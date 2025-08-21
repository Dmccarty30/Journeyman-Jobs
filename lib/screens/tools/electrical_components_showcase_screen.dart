import 'package:flutter/material.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../electrical_components/jj_electrical_notifications.dart';
import '../../electrical_components/jj_electrical_interactive_widgets.dart';
import '../../electrical_components/electrical_rotation_meter.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../electrical_components/power_line_loader.dart';
import '../../electrical_components/three_phase_sine_wave_loader.dart';
import '../../design_system/app_theme.dart';

/// Showcase screen demonstrating all electrical-themed components
/// Perfect for testing and previewing the electrical theme implementation
class ElectricalComponentsShowcaseScreen extends StatefulWidget {
  const ElectricalComponentsShowcaseScreen({Key? key}) : super(key: key);

  @override
  State<ElectricalComponentsShowcaseScreen> createState() => _ElectricalComponentsShowcaseScreenState();
}

class _ElectricalComponentsShowcaseScreenState extends State<ElectricalComponentsShowcaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _switchValue = false;
  String? _dropdownValue;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Electrical Components Showcase',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              JJElectricalNotifications.showElectricalToast(
                context: context,
                message: 'This showcases all electrical-themed components!',
                type: ElectricalNotificationType.info,
                showLightning: true,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Circuit board background
          const Positioned.fill(
            child: ElectricalCircuitBackground(
              opacity: 0.08,
              animationSpeed: 1.5,
              componentDensity: ComponentDensity.low,
              enableCurrentFlow: true,
              enableInteractiveComponents: true,
            ),
          ),
          
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Loading Indicators'),
                  const SizedBox(height: 16),
                  _buildLoadingIndicatorsSection(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Interactive Widgets'),
                  const SizedBox(height: 16),
                  _buildInteractiveWidgetsSection(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Electrical Controls'),
                  const SizedBox(height: 16),
                  _buildElectricalControlsSection(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Notifications'),
                  const SizedBox(height: 16),
                  _buildNotificationsSection(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Background Variations'),
                  const SizedBox(height: 16),
                  _buildBackgroundVariationsSection(),
                  
                  const SizedBox(height: 50), // Extra bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.electrical_services,
            color: AppTheme.accentCopper,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicatorsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const ElectricalRotationMeter(
                    size: 80,
                    label: 'Voltage Meter',
                    duration: Duration(seconds: 2),
                  ),
                  const SizedBox(height: 8),
                  JJElectricalNotifications.electricalTooltip(
                    message: 'Three-phase electrical meter animation',
                    type: ElectricalNotificationType.info,
                    child: const Text(
                      'Tap for info',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const PowerLineLoader(
                    width: 80,
                    height: 80,
                    duration: Duration(seconds: 3),
                  ),
                  const SizedBox(height: 8),
                  JJElectricalNotifications.electricalTooltip(
                    message: 'Power line transmission animation',
                    type: ElectricalNotificationType.info,
                    child: const Text(
                      'Power Lines',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const ThreePhaseSineWaveLoader(
                    width: 80,
                    height: 80,
                    duration: Duration(seconds: 4),
                  ),
                  const SizedBox(height: 8),
                  JJElectricalNotifications.electricalTooltip(
                    message: 'Three-phase sine wave pattern',
                    type: ElectricalNotificationType.info,
                    child: const Text(
                      'Sine Wave',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveWidgetsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          // Electrical buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              JJElectricalButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Primary button pressed!',
                    type: ElectricalNotificationType.success,
                  );
                },
                child: const Text('Primary'),
              ),
              JJElectricalButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalSnackBar(
                    context: context,
                    message: 'Warning button activated',
                    type: ElectricalNotificationType.warning,
                    actionLabel: 'OK',
                  );
                },
                sparkColor: Colors.amber,
                glowColor: Colors.amber,
                child: const Text('Warning'),
              ),
              JJElectricalButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Danger! High voltage detected',
                    type: ElectricalNotificationType.error,
                  );
                },
                sparkColor: Colors.red,
                glowColor: Colors.red,
                child: const Text('Danger'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Text field
          JJElectricalTextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Electrical Input',
              hintText: 'Type something electric...',
              helperText: 'Watch the current flow when focused',
            ),
            onChanged: (value) {
              // Handle text changes
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Dropdown
          JJElectricalDropdown<String>(
            value: _dropdownValue,
            hint: const Text('Select Electrical Component'),
            items: const [
              DropdownMenuItem(value: 'resistor', child: Text('Resistor')),
              DropdownMenuItem(value: 'capacitor', child: Text('Capacitor')),
              DropdownMenuItem(value: 'transistor', child: Text('Transistor')),
              DropdownMenuItem(value: 'inductor', child: Text('Inductor')),
            ],
            onChanged: (value) {
              setState(() {
                _dropdownValue = value;
              });
              JJElectricalNotifications.showElectricalToast(
                context: context,
                message: 'Selected: ${value?.toUpperCase()}',
                type: ElectricalNotificationType.info,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildElectricalControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          // Circuit breaker switch
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Main Breaker: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              JJCircuitBreakerSwitch(
                value: _switchValue,
                onChanged: (value) {
                  setState(() {
                    _switchValue = value;
                  });
                  
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: _switchValue ? 'Power ON' : 'Power OFF',
                    type: _switchValue 
                        ? ElectricalNotificationType.success 
                        : ElectricalNotificationType.warning,
                  );
                },
                size: JJCircuitBreakerSize.large,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Status: ${_switchValue ? "ENERGIZED" : "DE-ENERGIZED"}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _switchValue ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          const Text(
            'Test Electrical Notifications:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildNotificationButton(
                'Success Toast',
                ElectricalNotificationType.success,
                'Operation completed successfully!',
                Colors.green,
              ),
              _buildNotificationButton(
                'Warning Toast',
                ElectricalNotificationType.warning,
                'High voltage detected!',
                Colors.amber,
              ),
              _buildNotificationButton(
                'Error Toast',
                ElectricalNotificationType.error,
                'Circuit breaker tripped!',
                Colors.red,
              ),
              _buildNotificationButton(
                'Info SnackBar',
                ElectricalNotificationType.info,
                'System status nominal',
                const Color(0xFF00D4FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(
    String label,
    ElectricalNotificationType type,
    String message,
    Color color,
  ) {
    return JJElectricalButton(
      onPressed: () {
        if (label.contains('SnackBar')) {
          JJElectricalNotifications.showElectricalSnackBar(
            context: context,
            message: message,
            type: type,
            actionLabel: 'Dismiss',
          );
        } else {
          JJElectricalNotifications.showElectricalToast(
            context: context,
            message: message,
            type: type,
          );
        }
      },
      sparkColor: color,
      glowColor: color,
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildBackgroundVariationsSection() {
    return Column(
      children: [
        // Low density background
        Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentCopper.withOpacity(0.3)),
          ),
          child: const Stack(
            children: [
              Positioned.fill(
                child: ElectricalCircuitBackground(
                  opacity: 0.15,
                  componentDensity: ComponentDensity.low,
                  enableCurrentFlow: true,
                ),
              ),
              Center(
                child: Text(
                  'Low Density Background',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Medium density background
        Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentCopper.withOpacity(0.3)),
          ),
          child: const Stack(
            children: [
              Positioned.fill(
                child: ElectricalCircuitBackground(
                  opacity: 0.2,
                  componentDensity: ComponentDensity.medium,
                  enableCurrentFlow: true,
                  enableInteractiveComponents: true,
                ),
              ),
              Center(
                child: Text(
                  'Medium Density Background',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // High density background
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentCopper.withOpacity(0.3)),
          ),
          child: const Stack(
            children: [
              Positioned.fill(
                child: ElectricalCircuitBackground(
                  opacity: 0.25,
                  componentDensity: ComponentDensity.high,
                  enableCurrentFlow: true,
                  enableInteractiveComponents: true,
                  animationSpeed: 2.0,
                ),
              ),
              Center(
                child: Text(
                  'High Density Background',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.accentCopper.withOpacity(0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryNavy.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );
  }
}