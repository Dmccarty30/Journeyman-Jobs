import 'package:flutter/material.dart';

/// Storm Event Model for IBEW Storm Restoration Work
/// 
/// Represents emergency storm restoration assignments for electrical workers.
/// Includes all necessary information for workers to evaluate and respond to
/// storm damage and power restoration needs.
class StormEvent {
  /// Unique identifier for the storm event
  final String id;
  
  /// Name of the storm or emergency event
  final String name;
  
  /// Geographic region affected by the storm
  final String region;
  
  /// Severity level (Critical, High, Moderate, Low)
  final String severity;
  
  /// List of affected utility companies
  final List<String> affectedUtilities;
  
  /// Estimated duration of restoration work
  final String estimatedDuration;
  
  /// Number of open positions available
  final int openPositions;
  
  /// Hourly pay rate range
  final String payRate;
  
  /// Daily per diem allowance
  final String perDiem;
  
  /// Current status of restoration efforts
  final String status;
  
  /// Detailed description of storm damage and work needed
  final String description;
  
  /// When deployment is scheduled to begin
  final DateTime deploymentDate;

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

  /// Convert to Firestore document data
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

  /// Create from Firestore document data
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

  /// Get severity color for UI
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

  /// Check if deployment is in the future
  bool get isUpcoming => deploymentDate.isAfter(DateTime.now());

  /// Get time until deployment or time since started
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