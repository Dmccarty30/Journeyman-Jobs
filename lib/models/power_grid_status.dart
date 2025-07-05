import 'package:flutter/material.dart';

/// Represents the status of power grid infrastructure
class PowerGridStatus {
  final String gridId;
  final String gridName;
  final String region;
  final PowerGridState state;
  final double loadPercentage;
  final int affectedCustomers;
  final List<ElectricalHazard> activeHazards;
  final DateTime lastUpdated;
  final VoltageLevel voltageLevel;
  final int activeOutages;
  final int restoredOutages;
  final String estimatedRestoration;

  PowerGridStatus({
    required this.gridId,
    required this.gridName,
    required this.region,
    required this.state,
    required this.loadPercentage,
    required this.affectedCustomers,
    required this.activeHazards,
    required this.lastUpdated,
    required this.voltageLevel,
    required this.activeOutages,
    required this.restoredOutages,
    required this.estimatedRestoration,
  });

  Color get stateColor {
    switch (state) {
      case PowerGridState.operational:
        return Colors.green;
      case PowerGridState.stressed:
        return Colors.orange;
      case PowerGridState.critical:
        return Colors.red;
      case PowerGridState.offline:
        return Colors.grey;
    }
  }

  String get stateLabel {
    switch (state) {
      case PowerGridState.operational:
        return 'Operational';
      case PowerGridState.stressed:
        return 'Stressed';
      case PowerGridState.critical:
        return 'Critical';
      case PowerGridState.offline:
        return 'Offline';
    }
  }
}

/// Represents the operational state of a power grid
enum PowerGridState {
  operational,
  stressed,
  critical,
  offline,
}

/// Represents voltage levels in the power grid
enum VoltageLevel {
  low(label: 'Low Voltage', range: '< 1kV', color: Colors.blue),
  medium(label: 'Medium Voltage', range: '1kV - 35kV', color: Colors.amber),
  high(label: 'High Voltage', range: '35kV - 230kV', color: Colors.orange),
  extraHigh(label: 'Extra High Voltage', range: '> 230kV', color: Colors.red);

  final String label;
  final String range;
  final Color color;

  const VoltageLevel({
    required this.label,
    required this.range,
    required this.color,
  });
}

/// Represents electrical hazards in the field
class ElectricalHazard {
  final String hazardId;
  final HazardType type;
  final HazardSeverity severity;
  final String location;
  final String description;
  final DateTime reportedAt;
  final bool isActive;
  final List<String> safetyMeasures;

  ElectricalHazard({
    required this.hazardId,
    required this.type,
    required this.severity,
    required this.location,
    required this.description,
    required this.reportedAt,
    required this.isActive,
    required this.safetyMeasures,
  });

  Color get severityColor {
    switch (severity) {
      case HazardSeverity.low:
        return Colors.yellow;
      case HazardSeverity.medium:
        return Colors.orange;
      case HazardSeverity.high:
        return Colors.red;
      case HazardSeverity.extreme:
        return Colors.purple;
    }
  }

  IconData get hazardIcon {
    switch (type) {
      case HazardType.downedPowerLine:
        return Icons.flash_on;
      case HazardType.floodedEquipment:
        return Icons.water_damage;
      case HazardType.damagedTransformer:
        return Icons.electric_bolt;
      case HazardType.exposedWiring:
        return Icons.warning;
      case HazardType.unstableStructure:
        return Icons.domain_disabled;
      case HazardType.arcFlashRisk:
        return Icons.brightness_7;
    }
  }
}

/// Types of electrical hazards
enum HazardType {
  downedPowerLine,
  floodedEquipment,
  damagedTransformer,
  exposedWiring,
  unstableStructure,
  arcFlashRisk,
}

/// Severity levels for electrical hazards
enum HazardSeverity {
  low,
  medium,
  high,
  extreme,
}

/// Mock data generator for power grid status
class PowerGridMockData {
  static List<PowerGridStatus> generateMockData() {
    return [
      PowerGridStatus(
        gridId: 'GRID-FL-001',
        gridName: 'Florida Central Grid',
        region: 'Florida',
        state: PowerGridState.critical,
        loadPercentage: 87.5,
        affectedCustomers: 245000,
        activeHazards: [
          ElectricalHazard(
            hazardId: 'HAZ-001',
            type: HazardType.downedPowerLine,
            severity: HazardSeverity.extreme,
            location: 'Tampa Bay Area - Multiple Locations',
            description: 'Multiple high-voltage transmission lines down due to hurricane damage',
            reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
            isActive: true,
            safetyMeasures: [
              'Maintain 35ft minimum clearance',
              'Assume all lines are energized',
              'Use proper grounding procedures',
              'Wear arc-rated PPE Cat 4',
            ],
          ),
          ElectricalHazard(
            hazardId: 'HAZ-002',
            type: HazardType.floodedEquipment,
            severity: HazardSeverity.high,
            location: 'Substations - Coastal Areas',
            description: 'Storm surge has flooded multiple substations',
            reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
            isActive: true,
            safetyMeasures: [
              'Do not enter flooded areas',
              'Test for step potential',
              'Use insulated tools only',
              'Verify de-energization before approach',
            ],
          ),
        ],
        lastUpdated: DateTime.now(),
        voltageLevel: VoltageLevel.high,
        activeOutages: 156,
        restoredOutages: 89,
        estimatedRestoration: '5-7 days',
      ),
      PowerGridStatus(
        gridId: 'GRID-TX-001',
        gridName: 'Texas ERCOT Grid',
        region: 'Texas',
        state: PowerGridState.stressed,
        loadPercentage: 78.2,
        affectedCustomers: 45000,
        activeHazards: [
          ElectricalHazard(
            hazardId: 'HAZ-003',
            type: HazardType.damagedTransformer,
            severity: HazardSeverity.medium,
            location: 'Houston Industrial District',
            description: 'Ice damage to distribution transformers',
            reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
            isActive: true,
            safetyMeasures: [
              'Check for PCB contamination',
              'Use proper lockout/tagout',
              'Monitor for overheating',
              'Maintain safe approach distance',
            ],
          ),
        ],
        lastUpdated: DateTime.now(),
        voltageLevel: VoltageLevel.medium,
        activeOutages: 34,
        restoredOutages: 112,
        estimatedRestoration: '2-3 days',
      ),
      PowerGridStatus(
        gridId: 'GRID-MW-001',
        gridName: 'Midwest Regional Grid',
        region: 'Midwest',
        state: PowerGridState.operational,
        loadPercentage: 62.5,
        affectedCustomers: 12000,
        activeHazards: [
          ElectricalHazard(
            hazardId: 'HAZ-004',
            type: HazardType.exposedWiring,
            severity: HazardSeverity.low,
            location: 'Rural Distribution Lines',
            description: 'Tree damage has exposed some distribution wiring',
            reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
            isActive: true,
            safetyMeasures: [
              'Use insulated gloves',
              'Test before touch',
              'Maintain visual awareness',
              'Follow minimum approach distance',
            ],
          ),
        ],
        lastUpdated: DateTime.now(),
        voltageLevel: VoltageLevel.low,
        activeOutages: 8,
        restoredOutages: 156,
        estimatedRestoration: '< 24 hours',
      ),
    ];
  }
}
