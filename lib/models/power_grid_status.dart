import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

class PowerGridStatus {
  final String gridName;
  final String stateLabel;
  final Color stateColor;
  final double loadPercentage;
  final int affectedCustomers;
  final List<String> activeHazards;

  PowerGridStatus({
    required this.gridName,
    required this.stateLabel,
    required this.stateColor,
    required this.loadPercentage,
    required this.affectedCustomers,
    required this.activeHazards,
  });
}

class PowerGridMockData {
  static List<PowerGridStatus> getSampleData() {
    return [
      PowerGridStatus(
        gridName: 'North Grid',
        stateLabel: 'Stable',
        stateColor: AppTheme.successGreen,
        loadPercentage: 75.5,
        affectedCustomers: 0,
        activeHazards: [],
      ),
      PowerGridStatus(
        gridName: 'South Grid',
        stateLabel: 'Warning',
        stateColor: AppTheme.warningOrange,
        loadPercentage: 92.1,
        affectedCustomers: 1500,
        activeHazards: ['Overload', 'Equipment Fault'],
      ),
      PowerGridStatus(
        gridName: 'East Grid',
        stateLabel: 'Critical',
        stateColor: AppTheme.errorRed,
        loadPercentage: 98.0,
        affectedCustomers: 10000,
        activeHazards: ['Storm Damage', 'Power Outage'],
      ),
      PowerGridStatus(
        gridName: 'West Grid',
        stateLabel: 'Stable',
        stateColor: AppTheme.infoBlue,
        loadPercentage: 60.0,
        affectedCustomers: 0,
        activeHazards: [],
      ),
    ];
  }
}
