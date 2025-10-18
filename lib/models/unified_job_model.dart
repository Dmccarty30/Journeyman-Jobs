import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unified_job_model.freezed.dart';
part 'unified_job_model.g.dart';

/// Unified Job model consolidating all job representations in the application.
///
/// This model replaces:
/// - lib/models/job_model.dart (441 lines)
/// - lib/models/jobs_record.dart (220 lines)
/// - lib/legacy/flutterflow/schema/jobs_record.dart (567 lines)
///
/// Features:
/// - Immutable data class with Freezed code generation
/// - Automatic copyWith, equality, and toString implementations
/// - JSON serialization with custom Firestore type converters
/// - Backward compatibility with legacy data sources
/// - Type-safe null handling with Dart null safety
///
/// Usage:
/// ```dart
/// // Create from Firestore
/// final job = UnifiedJobModelFirestore.fromFirestore(snapshot);
///
/// // Update with copyWith
/// final updated = job.copyWith(wage: 45.50);
///
/// // Save to Firestore
/// await jobRef.set(job.toFirestore());
/// ```
@freezed
class UnifiedJobModel with _$UnifiedJobModel {
  const factory UnifiedJobModel({
    required String id,
    @JsonKey(includeToJson: false, includeFromJson: false)
    DocumentReference? reference,
    @Default('') String sharerId,
    @Default({}) Map<String, dynamic> jobDetails,
    @Default(false) bool matchesCriteria,
    @Default(false) bool deleted,
    int? local,
    String? classification,
    required String company,
    required String location,
    @JsonKey(toJson: _geoPointToJson, fromJson: _geoPointFromJson)
    GeoPoint? geoPoint,
    int? hours,
    double? wage,
    String? sub,
    String? jobClass,
    int? localNumber,
    String? qualifications,
    String? datePosted,
    String? jobDescription,
    String? jobTitle,
    String? perDiem,
    String? agreement,
    String? numberOfJobs,
    @JsonKey(toJson: _timestampToJson, fromJson: _timestampFromJson)
    DateTime? timestamp,
    String? startDate,
    String? startTime,
    List<int>? booksYourOn,
    String? typeOfWork,
    String? duration,
    String? voltageLevel,
    List<String>? certifications,
    @Default(false) bool isSaved,
    @Default(false) bool isApplied,
  }) = _UnifiedJobModel;

  const UnifiedJobModel._();

  factory UnifiedJobModel.fromJson(Map<String, dynamic> json) =>
      _$UnifiedJobModelFromJson(json);
}

// Helper functions for JSON conversion
GeoPoint? _geoPointFromJson(dynamic json) =>
    json is GeoPoint ? json : null;

dynamic _geoPointToJson(GeoPoint? geoPoint) => geoPoint;

DateTime? _timestampFromJson(dynamic json) {
  if (json is Timestamp) return json.toDate();
  if (json is String) return DateTime.tryParse(json);
  return null;
}

dynamic _timestampToJson(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;

/// Business logic extension for UnifiedJobModel
///
/// Contains computed getters and validation methods
extension UnifiedJobModelLogic on UnifiedJobModel {
  /// Validates whether this job has the minimum required fields
  ///
  /// A valid job must have:
  /// - A non-empty ID
  /// - A company name
  /// - A location
  bool get isValid =>
      id.isNotEmpty && company.isNotEmpty && location.isNotEmpty;

  /// Extracts wage from either the wage field or jobDetails map
  double? get effectiveWage => wage ?? jobDetails['payRate'] as double?;

  /// Extracts hours from either the hours field or jobDetails map
  int? get effectiveHours => hours ?? jobDetails['hours'] as int?;

  /// Extracts per diem from either the perDiem field or jobDetails map
  String? get effectivePerDiem =>
      perDiem ?? jobDetails['perDiem']?.toString();

  /// Returns the local union number (handles both field names)
  int? get effectiveLocal => local ?? localNumber;

  /// Determines if this is a high-voltage job based on classification
  bool get isHighVoltage {
    final voltage = voltageLevel?.toLowerCase();
    return voltage != null &&
        (voltage.contains('high') ||
            voltage.contains('transmission') ||
            voltage.contains('69'));
  }

  /// Determines if this is a lineman position
  bool get isLinemanPosition {
    final classif = classification?.toLowerCase() ?? '';
    final title = jobTitle?.toLowerCase() ?? '';
    return classif.contains('lineman') || title.contains('lineman');
  }

  /// Returns a display-friendly wage string
  String get wageDisplay {
    final w = effectiveWage;
    if (w == null) return 'Wage not specified';
    return '\$${w.toStringAsFixed(2)}/hr';
  }

  /// Returns a shortened job description for list views
  String get shortDescription {
    if (jobDescription == null || jobDescription!.isEmpty) {
      return 'No description available';
    }
    if (jobDescription!.length <= 100) return jobDescription!;
    return '${jobDescription!.substring(0, 97)}...';
  }
}

/// Firestore-specific extensions for UnifiedJobModel
///
/// Handles conversion to/from Firestore documents
extension UnifiedJobModelFirestore on UnifiedJobModel {
  /// Creates a UnifiedJobModel from a Firestore DocumentSnapshot
  ///
  /// Automatically extracts the document ID and merges it with the data.
  /// Preserves the DocumentReference for later updates.
  ///
  /// Example:
  /// ```dart
  /// FirebaseFirestore.instance
  ///   .collection('jobs')
  ///   .snapshots()
  ///   .map((snapshot) => snapshot.docs.map((doc) =>
  ///       UnifiedJobModelFirestore.fromFirestore(doc)
  ///   ).toList());
  /// ```
  static UnifiedJobModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      throw Exception('Document does not exist: ${snapshot.id}');
    }

    final data = snapshot.data()!;
    return UnifiedJobModel.fromJson({
      ...data,
      'id': snapshot.id,
    }).copyWith(reference: snapshot.reference);
  }

  /// Converts this model to a Firestore-compatible map
  ///
  /// Removes client-side fields (isSaved, isApplied, reference)
  /// and ensures DateTime fields are converted to Firestore Timestamps.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseFirestore.instance
  ///   .collection('jobs')
  ///   .doc(job.id)
  ///   .set(job.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Remove client-side fields that shouldn't be stored
    json.remove('isSaved');
    json.remove('isApplied');
    json.remove('reference');

    // Ensure DateTime fields are Timestamps
    if (json['timestamp'] is String) {
      json['timestamp'] =
          Timestamp.fromDate(DateTime.parse(json['timestamp'] as String));
    }

    return json;
  }
}

/// Migration helper functions for converting from legacy models
extension UnifiedJobModelMigration on UnifiedJobModel {
  /// Creates a UnifiedJobModel from legacy Job model
  ///
  /// Maps fields from lib/models/job_model.dart to UnifiedJobModel
  static UnifiedJobModel fromLegacyJob(Map<String, dynamic> legacyData) {
    return UnifiedJobModel.fromJson(legacyData);
  }

  /// Creates a UnifiedJobModel from legacy JobsRecord
  ///
  /// Maps fields from lib/models/jobs_record.dart to UnifiedJobModel
  static UnifiedJobModel fromJobsRecord(Map<String, dynamic> recordData) {
    return UnifiedJobModel.fromJson(recordData);
  }

  /// Creates a UnifiedJobModel from legacy FlutterFlow JobsRecord
  ///
  /// Maps fields from lib/legacy/flutterflow/schema/jobs_record.dart
  static UnifiedJobModel fromFlutterFlowRecord(
      Map<String, dynamic> ffData) {
    return UnifiedJobModel.fromJson(ffData);
  }
}
