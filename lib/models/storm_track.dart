import 'package:cloud_firestore/cloud_firestore.dart';

class StormTrack {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final String contractor;
  final String utility;
  final String stormType;
  final double payRate;
  final double perDiem;
  final String currency;
  final double workingHours;
  final double hoursWorked;
  final double mobilizationHours;
  final double demobilizationHours;
  final double travelReimbursement;
  final double completionBonus;
  final String conditions;
  final String notes;

  StormTrack({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.contractor,
    required this.utility,
    required this.hoursWorked,
    required this.stormType,
    required this.payRate,
    required this.perDiem,
    this.currency = 'USD',
    this.workingHours = 0.0,
    this.mobilizationHours = 0.0,
    this.demobilizationHours = 0.0,
    this.travelReimbursement = 0.0,
    this.completionBonus = 0.0,
    this.conditions = '',
    this.notes = '',
  });

  // Pay Calculation Logic
  double get mobilizationPay => mobilizationHours * payRate * 2;
  double get workingPay => workingHours * payRate * 2;
  double get demobilizationPay => demobilizationHours * payRate * 1.5;
  double get totalHourlyPay => mobilizationPay + workingPay + demobilizationPay;
  int get totalDays {
    if (endDate == null) return 0;
    // Add 1 to include the start day
    final days = endDate!.difference(startDate).inDays + 1;
    return days > 0 ? days : 1;
  }

  double get perDiemPay => totalDays * perDiem;
  double get totalPay =>
      totalHourlyPay + perDiemPay + travelReimbursement + completionBonus;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'contractor': contractor,
      'utility': utility,
      'stormType': stormType,
      'payRate': payRate,
      'perDiem': perDiem,
      'currency': currency,
      'workingHours': workingHours,
      'hoursWorked' : hoursWorked,
      'mobilizationHours': mobilizationHours,
      'demobilizationHours': demobilizationHours,
      'travelReimbursement': travelReimbursement,
      'completionBonus': completionBonus,
      'conditions': conditions,
      'notes': notes,
    };
  }

  factory StormTrack.fromMap(Map<String, dynamic> map) {
    return StormTrack(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      contractor: map['contractor'] ?? '',
      utility: map['utility'] ?? '',
      stormType: map['stormType'] ?? '',
      payRate: (map['payRate'] ?? 0.0).toDouble(),
      perDiem: (map['perDiem'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      workingHours: (map['workingHours'] ?? map['hoursWorked'] ?? 0.0)
          .toDouble(), // Backward compatibility
      hoursWorked: (map['hoursWorked'] ?? map['hoursWorked'] ?? 0.0)
          .toDouble(), // Backward compatibility
      mobilizationHours: (map['mobilizationHours'] ?? 0.0).toDouble(),
      demobilizationHours: (map['demobilizationHours'] ?? 0.0).toDouble(),
      travelReimbursement: (map['travelReimbursement'] ?? 0.0).toDouble(),
      completionBonus: (map['completionBonus'] ?? 0.0).toDouble(),
      conditions: map['conditions'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  StormTrack copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? contractor,
    String? utility,
    String? stormType,
    double? payRate,
    double? perDiem,
    String? currency,
    double? workingHours,
    double? mobilizationHours,
    double? demobilizationHours,
    double? travelReimbursement,
    double? completionBonus,
    String? conditions,
    String? notes,
  }) {
    return StormTrack(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      contractor: contractor ?? this.contractor,
      utility: utility ?? this.utility,
      stormType: stormType ?? this.stormType,
      payRate: payRate ?? this.payRate,
      perDiem: perDiem ?? this.perDiem,
      currency: currency ?? this.currency,
      workingHours: workingHours ?? this.workingHours,
      hoursWorked: hoursWorked,
      mobilizationHours: mobilizationHours ?? this.mobilizationHours,
      demobilizationHours: demobilizationHours ?? this.demobilizationHours,
      travelReimbursement: travelReimbursement ?? this.travelReimbursement,
      completionBonus: completionBonus ?? this.completionBonus,
      conditions: conditions ?? this.conditions,
      notes: notes ?? this.notes,
    );
  }
}
