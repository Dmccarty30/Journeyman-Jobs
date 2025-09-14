import 'storm_event.dart';

/// Model representing a document in the "storm contractors" Firestore collection.
class StormContractor {
  final String id;
  final String contractorName;
  final String localWages;
  final String showUpLocation;
  final DateTime showUpTime;
  final int requestedPositions;
  final int positionsFilled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? utility;
  final String? workingLocal;
  final String? payScale;
  final String? workingConditions;
  final String? positionRequested;
  final String? notesRequirements;

  const StormContractor({
    required this.id,
    required this.contractorName,
    required this.localWages,
    required this.showUpLocation,
    required this.showUpTime,
    required this.requestedPositions,
    required this.positionsFilled,
    this.createdAt,
    this.updatedAt,
    this.utility,
    this.workingLocal,
    this.payScale,
    this.workingConditions,
    this.positionRequested,
    this.notesRequirements,
  });

  /// Safely parse dynamic values commonly returned from Firestore.
  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      // Some Firestore SDKs return a Timestamp-like object with toDate()
      final toDate = (v as dynamic).toDate;
      if (toDate is Function) {
        final d = (v as dynamic).toDate();
        if (d is DateTime) return d;
      }
    } catch (_) {}
    // If it's an int or string representing milliseconds or iso8601
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
      final asInt = int.tryParse(v);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
    }
    return null;
  }

  /// Factory to create a StormContractor from a Firestore document map and its id.
  factory StormContractor.fromMap(Map<String, dynamic>? map, String id) {
    final safe = map ?? <String, dynamic>{};
    final contractorName = (safe['contractorName'] ?? safe['name'] ?? '') as String;
    final localWages = (safe['localWages'] ?? safe['payRate'] ?? '') as String;
    final showUpLocation = (safe['showUpLocation'] ?? safe['location'] ?? 'TBD') as String;

    final showUpTimeRaw = safe['showUpTime'] ?? safe['deploymentDate'];
    final parsedShowUpTime = _parseDateTime(showUpTimeRaw) ?? DateTime.now();

    final requestedPositions = (safe['requestedPositions'] is int)
        ? safe['requestedPositions'] as int
        : int.tryParse('${safe['requestedPositions'] ?? 0}') ?? 0;

    final positionsFilled = (safe['positionsFilled'] is int)
        ? safe['positionsFilled'] as int
        : int.tryParse('${safe['positionsFilled'] ?? 0}') ?? 0;

    final createdAt = _parseDateTime(safe['createdAt']);
    final updatedAt = _parseDateTime(safe['updatedAt']);

    return StormContractor(
      id: id,
      contractorName: contractorName,
      localWages: localWages,
      showUpLocation: showUpLocation,
      showUpTime: parsedShowUpTime,
      requestedPositions: requestedPositions,
      positionsFilled: positionsFilled,
      createdAt: createdAt,
      updatedAt: updatedAt,
      utility: safe['utility']?.toString(),
      workingLocal: safe['workingLocal']?.toString(),
      payScale: safe['payScale']?.toString(),
      workingConditions: safe['workingConditions']?.toString(),
      positionRequested: safe['positionRequested']?.toString(),
      notesRequirements: safe['notesRequirements']?.toString(),
    );
  }

  /// Convert to a map suitable for writing to Firestore.
  ///
  /// Note: DateTime values are kept as DateTime here; Firestore service layer
  /// is expected to convert them to server timestamps or Timestamp objects as needed.
  Map<String, dynamic> toMap() {
    return {
      'contractorName': contractorName,
      'localWages': localWages,
      'showUpLocation': showUpLocation,
      'showUpTime': showUpTime.toUtc().toIso8601String(),
      'requestedPositions': requestedPositions,
      'positionsFilled': positionsFilled,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
      if (utility != null) 'utility': utility,
      if (workingLocal != null) 'workingLocal': workingLocal,
      if (payScale != null) 'payScale': payScale,
      if (workingConditions != null) 'workingConditions': workingConditions,
      if (positionRequested != null) 'positionRequested': positionRequested,
      if (notesRequirements != null) 'notesRequirements': notesRequirements,
    };
  }

  StormContractor copyWith({
    String? id,
    String? contractorName,
    String? localWages,
    String? showUpLocation,
    DateTime? showUpTime,
    int? requestedPositions,
    int? positionsFilled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? utility,
    String? workingLocal,
    String? payScale,
    String? workingConditions,
    String? positionRequested,
    String? notesRequirements,
  }) {
    return StormContractor(
      id: id ?? this.id,
      contractorName: contractorName ?? this.contractorName,
      localWages: localWages ?? this.localWages,
      showUpLocation: showUpLocation ?? this.showUpLocation,
      showUpTime: showUpTime ?? this.showUpTime,
      requestedPositions: requestedPositions ?? this.requestedPositions,
      positionsFilled: positionsFilled ?? this.positionsFilled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      utility: utility ?? this.utility,
      workingLocal: workingLocal ?? this.workingLocal,
      payScale: payScale ?? this.payScale,
      workingConditions: workingConditions ?? this.workingConditions,
      positionRequested: positionRequested ?? this.positionRequested,
      notesRequirements: notesRequirements ?? this.notesRequirements,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StormContractor &&
        other.id == id &&
        other.contractorName == contractorName &&
        other.localWages == localWages &&
        other.showUpLocation == showUpLocation &&
        other.showUpTime == showUpTime &&
        other.requestedPositions == requestedPositions &&
        other.positionsFilled == positionsFilled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.utility == utility &&
        other.workingLocal == workingLocal &&
        other.payScale == payScale &&
        other.workingConditions == workingConditions &&
        other.positionRequested == positionRequested &&
        other.notesRequirements == notesRequirements;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      contractorName,
      localWages,
      showUpLocation,
      showUpTime,
      requestedPositions,
      positionsFilled,
      createdAt,
      updatedAt,
      utility,
      workingLocal,
      payScale,
      workingConditions,
      positionRequested,
      notesRequirements,
    );
  }

  /// Build a sample StormContractor from a StormEvent for seeding/demo purposes.
  ///
  /// Mapping:
  /// - name -> contractorName
  /// - payRate -> localWages
  /// - first affectedUtilities -> showUpLocation or 'TBD'
  /// - deploymentDate -> showUpTime
  /// - openPositions -> requestedPositions
  /// - positionsFilled -> 0
  static StormContractor sampleFromStormEvent(StormEvent event, {String? id}) {
    final contractorName = event.name;
    final localWages = event.payRate;
    final showUpLocation = (event.affectedUtilities.isNotEmpty)
        ? event.affectedUtilities.first
        : 'TBD';
    final showUpTime = event.deploymentDate;
    final requestedPositions = event.openPositions;

    return StormContractor(
      id: id ?? '',
      contractorName: contractorName,
      localWages: localWages,
      showUpLocation: showUpLocation,
      showUpTime: showUpTime,
      requestedPositions: requestedPositions,
      positionsFilled: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
