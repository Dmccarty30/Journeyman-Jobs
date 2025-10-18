import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/firestore_converters.dart';

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
/// final job = UnifiedJobModel.fromFirestore(snapshot);
///
/// // Update with copyWith
/// final updated = job.copyWith(wage: 45.50);
///
/// // Save to Firestore
/// await jobRef.set(job.toFirestore());
/// ```
@freezed
class UnifiedJobModel with _$UnifiedJobModel {
  const UnifiedJobModel._();

  /// Creates a new UnifiedJobModel instance
  ///
  /// All fields are optional except [id], [company], and [location]
  /// which are required for a valid job posting.
  const factory UnifiedJobModel({
    /// Unique identifier for the job (typically Firestore document ID)
    required String id,

    /// Firestore DocumentReference (not serialized to JSON)
    @JsonKey(includeFromJson: false, includeToJson: false)
    DocumentReference? reference,

    /// User ID of the person who shared/posted this job
    @Default('') String sharerId,

    /// Nested map containing additional job details
    ///
    /// May include fields like:
    /// - hours: int
    /// - payRate: double
    /// - perDiem: String
    /// - contractor: String
    /// - location: GeoPoint
    @Default({}) Map<String, dynamic> jobDetails,

    /// Whether this job matches the user's search criteria/preferences
    @Default(false) bool matchesCriteria,

    /// Soft delete flag - if true, job should not be displayed
    @Default(false) bool deleted,

    /// IBEW local union number
    int? local,

    /// Worker classification (e.g., "Inside Wireman", "Journeyman Lineman")
    String? classification,

    /// Company/contractor name (required)
    required String company,

    /// Job location city/address (required)
    required String location,

    /// GeoPoint for precise location mapping
    @OptionalGeoPointConverter() GeoPoint? geoPoint,

    /// Work hours per week or shift length
    int? hours,

    /// Hourly wage rate
    double? wage,

    /// Subcontractor information
    String? sub,

    /// Job classification code or category
    String? jobClass,

    /// Local union number (alternative field)
    int? localNumber,

    /// Required qualifications, certifications, or skills
    String? qualifications,

    /// Date the job was posted (string format for compatibility)
    String? datePosted,

    /// Detailed job description
    String? jobDescription,

    /// Job title or position name
    String? jobTitle,

    /// Per diem allowance information
    String? perDiem,

    /// Union agreement or contract type
    String? agreement,

    /// Number of positions available
    String? numberOfJobs,

    /// Timestamp when job was created/posted
    @TimestampConverter() DateTime? timestamp,

    /// Expected start date for the job
    String? startDate,

    /// Start time for the job/shift
    String? startTime,

    /// Book classifications this job is available for
    List<int>? booksYourOn,

    /// Type of work (e.g., "Commercial", "Industrial", "Residential")
    String? typeOfWork,

    /// Expected duration of the job
    String? duration,

    /// Voltage level classification (e.g., "Low Voltage", "High Voltage")
    String? voltageLevel,

    /// List of required certifications (alternative to qualifications)
    List<String>? certifications,

    /// Client-side flag: whether user has saved this job
    @Default(false) bool isSaved,

    /// Client-side flag: whether user has applied to this job
    @Default(false) bool isApplied,
  }) = _UnifiedJobModel;

  /// Creates a UnifiedJobModel from JSON data
  ///
  /// Supports various field name variations from different data sources:
  /// - Firestore field names (camelCase)
  /// - Legacy field names (snake_case)
  /// - Alternative field names from different scrapers
  factory UnifiedJobModel.fromJson(Map<String, dynamic> json) =>
      _$UnifiedJobModelFromJson(json);

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
  ///       UnifiedJobModel.fromFirestore(doc)
  ///   ).toList());
  /// ```
  factory UnifiedJobModel.fromFirestore(
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
