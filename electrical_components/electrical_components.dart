/// Electrical Components Library
/// 
/// A comprehensive collection of electrical-themed Flutter components
/// including loading indicators, interactive switches, and icons.
/// 
/// Designed for electrical, industrial, and engineering applications.
/// 
/// Example usage:
/// ```dart
/// import 'package:your_app/electrical_components/electrical_components.dart';
/// 
/// // Use any component
/// ThreePhaseSineWaveLoader(width: 200, height: 60)
/// ElectricalRotationMeter(size: 120, label: 'Power')
/// CircuitBreakerToggle(isOn: true, onChanged: (value) {})
/// PowerLineLoader(width: 300, height: 80)
/// HardHatIcon(size: 48)
/// TransmissionTowerIcon(size: 64)
/// ```

library electrical_components;

// Loading Components
export 'three_phase_sine_wave_loader.dart';
export 'electrical_rotation_meter.dart';
export 'power_line_loader.dart';

// Interactive Components
export 'circuit_breaker_toggle.dart';

// Static Icons
export 'hard_hat_icon.dart';
export 'transmission_tower_icon.dart';