import 'package:flutter/material.dart';

/// Custom electrical-themed icons for IBEW application features.
/// 
/// Provides specialized iconography for electrical workers including
/// crew management, job types, and electrical equipment.
class ElectricalIcons {
  ElectricalIcons._();

  // Crew management icons
  static const IconData crew = Icons.group_work;
  static const IconData crewLeader = Icons.engineering;
  static const IconData crewMember = Icons.person_outline;

  // Job and work type icons
  static const IconData inside_wireman = Icons.electrical_services;
  static const IconData journeyman_lineman = Icons.power;
  static const IconData tree_trimmer = Icons.nature;
  static const IconData equipment_operator = Icons.construction;
  static const IconData inside_journeyman = Icons.build_circle;

  // Equipment and electrical icons
  static const IconData powerLine = Icons.power_outlined;
  static const IconData circuitBreaker = Icons.electrical_services;
  static const IconData transformer = Icons.battery_charging_full;
  static const IconData hardHat = Icons.construction;
  static const IconData transmissionTower = Icons.cell_tower;

  // Weather and storm icons
  static const IconData storm = Icons.flash_on;
  static const IconData weatherAlert = Icons.warning;
  static const IconData lightning = Icons.bolt;

  // Union and location icons
  static const IconData union = Icons.business;
  static const IconData local = Icons.location_city;
  static const IconData territory = Icons.map;

  // Status and activity icons
  static const IconData active = Icons.radio_button_checked;
  static const IconData inactive = Icons.radio_button_unchecked;
  static const IconData recruiting = Icons.person_add;
  static const IconData full = Icons.group;

  // Communication icons
  static const IconData share = Icons.share;
  static const IconData message = Icons.message;
  static const IconData notification = Icons.notifications;

  /// Get icon for electrical classification
  static IconData getClassificationIcon(String classification) {
    switch (classification.toLowerCase()) {
      case 'inside_wireman':
        return inside_wireman;
      case 'journeyman_lineman':
        return journeyman_lineman;
      case 'tree_trimmer':
        return tree_trimmer;
      case 'equipment_operator':
        return equipment_operator;
      case 'inside_journeyman':
        return inside_journeyman;
      default:
        return electrical_services;
    }
  }

  /// Get icon for crew status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return active;
      case 'inactive':
        return inactive;
      case 'recruiting':
        return recruiting;
      case 'full':
        return full;
      default:
        return inactive;
    }
  }
}
