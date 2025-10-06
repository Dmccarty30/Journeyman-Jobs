import 'package:flutter/material.dart';

/// A data model representing the real-time status of a specific power grid section.
///
/// This is used for dashboard visualizations to monitor grid health.
class PowerGridStatus {
  /// The name of the grid section (e.g., 'North Grid').
  final String gridName;
  /// A human-readable label for the current state (e.g., 'Stable', 'Critical').
  final String stateLabel;
  /// The color associated with the current state for UI representation.
  final Color stateColor;
  /// The current load on the grid as a percentage of its capacity.
  final double loadPercentage;
  /// The number of customers currently affected by outages or issues in this grid.
  final int affectedCustomers;
  /// The current voltage level in kilovolts (kV).
  final double voltageLevel;
  /// A list of active hazards or issues affecting the grid (e.g., 'Storm Damage').
  final List<String> activeHazards;

  /// Creates an instance of [PowerGridStatus].
  PowerGridStatus({
    required this.gridName,
    required this.stateLabel,
    required this.stateColor,
    required this.loadPercentage,
    required this.affectedCustomers,
    required this.voltageLevel,
    required this.activeHazards,
  });
}

/// A utility class that provides mock data for [PowerGridStatus].
///
/// This is useful for UI development and testing of the power grid dashboard.
class PowerGridMockData {
  /// Returns a static list of sample [PowerGridStatus] objects.
  static List<PowerGridStatus> getSampleData() {
    return [
      PowerGridStatus(
        gridName: 'North Grid',
        stateLabel: 'Stable',
        stateColor: Colors.green,
        loadPercentage: 75.5,
        affectedCustomers: 0,
        voltageLevel: 13.8,
        activeHazards: [],
      ),
      PowerGridStatus(
        gridName: 'South Grid',
        stateLabel: 'Warning',
        stateColor: Colors.orange,
        loadPercentage: 92.1,
        affectedCustomers: 1500,
        voltageLevel: 12.5,
        activeHazards: ['Overload', 'Equipment Fault'],
      ),
      PowerGridStatus(
        gridName: 'East Grid',
        stateLabel: 'Critical',
        stateColor: Colors.red,
        loadPercentage: 98.0,
        affectedCustomers: 10000,
        voltageLevel: 11.0,
        activeHazards: ['Storm Damage', 'Power Outage'],
      ),
      PowerGridStatus(
        gridName: 'West Grid',
        stateLabel: 'Stable',
        stateColor: Colors.blue,
        loadPercentage: 60.0,
        affectedCustomers: 0,
        voltageLevel: 14.0,
        activeHazards: [],
      ),
    ];
  }
}