import 'package:flutter/material.dart';

/// A data model for IBEW storm restoration work assignments.
///
/// This class represents an emergency storm restoration event, providing all
/// the necessary information for electrical workers to evaluate and respond to
/// storm damage and power restoration needs.
class StormEvent {
  /// The unique identifier for the storm event.
  final String id;
  
  /// The name of the storm or emergency event (e.g., "Hurricane Zeta").
  final String name;
  
  /// The geographic region affected by the storm (e.g., "Gulf Coast").
  final String region;
  
  /// The severity level of the event (e.g., "Critical", "High", "Moderate").
  final String severity;
  
  /// A list of utility companies affected by the storm.
  final List<String> affectedUtilities;
  
  /// The estimated duration of the restoration work.
  final String estimatedDuration;
  
  /// The number of open positions available for this event.
  final int openPositions;
  
  /// The hourly pay rate or range for the work.
  final String payRate;
  
  /// The daily per diem allowance provided to workers.
  final String perDiem;
  
  /// The current status of the restoration efforts (e.g., "Mobilizing", "In Progress").
  final String status;
  
  /// A detailed description of the storm damage and the work required.
  final String description;
  
  /// The date when deployment is scheduled to begin.
  final DateTime deploymentDate;

  /// Creates an instance of [StormEvent].
  const StormEvent({
    required this.id,
    required this.name,
    required this.region,
    required this.severity,
    required this.affectedUtilities,
    required this.estimatedDuration,
    required this.openPositions,
    required this.payRate,
    required this.perDiem,
    required this.status,
    required this.description,
    required this.deploymentDate,
  });

  /// Serializes the [StormEvent] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'severity': severity,
      'affectedUtilities': affectedUtilities,
      'estimatedDuration': estimatedDuration,
      'openPositions': openPositions,
      'payRate': payRate,
      'perDiem': perDiem,
      'status': status,
      'description': description,
      'deploymentDate': deploymentDate.toIso8601String(),
    };
  }

  /// Creates a [StormEvent] instance from a JSON map.
  factory StormEvent.fromJson(Map<String, dynamic> json) {
    return StormEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      severity: json['severity'] as String,
      affectedUtilities: List<String>.from(json['affectedUtilities'] as List),
      estimatedDuration: json['estimatedDuration'] as String,
      openPositions: json['openPositions'] as int,
      payRate: json['payRate'] as String,
      perDiem: json['perDiem'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      deploymentDate: DateTime.parse(json['deploymentDate'] as String),
    );
  }

  /// Returns a [Color] corresponding to the event's severity level for UI display.
  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFE53E3E); // Error Red
      case 'high':
        return const Color(0xFFD69E2E); // Warning Yellow
      case 'moderate':
        return const Color(0xFFB45309); // Accent Copper
      default:
        return const Color(0xFF3182CE); // Info Blue
    }
  }

  /// A boolean indicating whether the deployment date is in the future.
  bool get isUpcoming => deploymentDate.isAfter(DateTime.now());

  /// Returns a formatted string indicating the time until deployment or since it started.
  String get deploymentTimeString {
    final now = DateTime.now();
    final difference = deploymentDate.difference(now);
    
    if (difference.isNegative) {
      final days = difference.abs().inDays;
      return 'Started ${days}d ago';
    } else if (difference.inHours < 24) {
      return 'Deploying in ${difference.inHours}h';
    } else {
      return 'Deploying in ${difference.inDays}d';
    }
  }
}