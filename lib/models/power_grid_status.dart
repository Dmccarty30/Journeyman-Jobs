import 'package:flutter/material.dart';

class PowerGridStatus {
  final String gridName;
  final String stateLabel;
  final Color stateColor;
  final double loadPercentage;
  final int affectedCustomers;
  final double voltageLevel;
  final List<String> activeHazards;

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

class PowerGridMockData {
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