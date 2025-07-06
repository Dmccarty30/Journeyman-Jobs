import 'package:flutter/material.dart';
import 'electrical_components.dart';

/// Demo page showcasing all electrical components
/// 
/// This page demonstrates the usage of all electrical components
/// in a single interface, showing their animations, interactions,
/// and visual design.
class ElectricalComponentsDemo extends StatefulWidget {
  const ElectricalComponentsDemo({Key? key}) : super(key: key);

  @override
  State<ElectricalComponentsDemo> createState() => _ElectricalComponentsDemoState();
}

class _ElectricalComponentsDemoState extends State<ElectricalComponentsDemo> {
  bool _circuitBreakerOn = false;
  bool _mainPowerOn = true;
  bool _backupPowerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrical Components Demo'),
        backgroundColor: const Color(0xFF1A202C), // Navy
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Electrical Components Library',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Industrial-grade Flutter components for electrical applications',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 32),

            // Loading Components Section
            _buildSection(
              title: 'Loading Components',
              children: [
                _buildComponentCard(
                  title: '3-Phase Sine Wave Loader',
                  description: 'Animated AC power visualization',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const ThreePhaseSineWaveLoader(
                      width: 200,
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildComponentCard(
                  title: 'Electrical Rotation Meter',
                  description: 'Gauge-style loading indicator',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const ElectricalRotationMeter(
                      size: 120,
                      label: 'System Load',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildComponentCard(
                  title: 'Power Line Loader',
                  description: 'Transmission line animation',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const PowerLineLoader(
                      width: 250,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Interactive Components Section
            _buildSection(
              title: 'Interactive Components',
              children: [
                _buildComponentCard(
                  title: 'Circuit Breaker Toggle',
                  description: 'Professional electrical switch',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Main Power',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CircuitBreakerToggle(
                                  isOn: _mainPowerOn,
                                  onChanged: (value) {
                                    setState(() {
                                      _mainPowerOn = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Backup Power',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CircuitBreakerToggle(
                                  isOn: _backupPowerOn,
                                  onChanged: (value) {
                                    setState(() {
                                      _backupPowerOn = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Circuit Breaker: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                            CircuitBreakerToggle(
                              isOn: _circuitBreakerOn,
                              onChanged: (value) {
                                setState(() {
                                  _circuitBreakerOn = value;
                                });
                              },
                              width: 100,
                              height: 50,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Static Icons Section
            _buildSection(
              title: 'Static Icons',
              children: [
                _buildComponentCard(
                  title: 'Safety & Infrastructure Icons',
                  description: 'Professional electrical symbols',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const HardHatIcon(size: 64),
                            const SizedBox(height: 8),
                            const Text(
                              'Safety First',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                            const Text(
                              'Hard Hat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const TransmissionTowerIcon(size: 64),
                            const SizedBox(height: 8),
                            const Text(
                              'Infrastructure',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                            const Text(
                              'Transmission Tower',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // System Status Panel
            _buildSystemStatusPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildComponentCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusPanel() {
    final isSystemActive = _mainPowerOn || _backupPowerOn;
    final statusColor = isSystemActive ? const Color(0xFF38A169) : const Color(0xFF718096);
    
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const HardHatIcon(size: 32),
                const SizedBox(width: 16),
                const Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isSystemActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isSystemActive) ...[
              const ThreePhaseSineWaveLoader(
                width: 150,
                height: 40,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusIndicator(
                  'Main Power',
                  _mainPowerOn,
                ),
                _buildStatusIndicator(
                  'Backup Power',
                  _backupPowerOn,
                ),
                _buildStatusIndicator(
                  'Circuit Breaker',
                  _circuitBreakerOn,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF38A169) : const Color(0xFF718096),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}