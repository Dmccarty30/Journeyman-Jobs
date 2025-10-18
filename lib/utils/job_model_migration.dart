import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unified_job_model.dart';

/// Migration utilities for transitioning from legacy Job models to UnifiedJobModel
///
/// This file provides helpers for:
/// - Converting from old Job/JobsRecord models
/// - Batch migration of collections
/// - Data validation during migration
/// - Rollback support
///
/// Usage during migration:
/// ```dart
/// // Convert single job
/// final unified = JobModelMigration.convertLegacyToUnified(oldJob);
///
/// // Migrate entire collection
/// await JobModelMigration.migrateJobsCollection();
/// ```
class JobModelMigration {
  /// Converts a legacy Job model (from job_model.dart) to UnifiedJobModel
  ///
  /// Handles:
  /// - jobDetails map extraction
  /// - sharerId preservation
  /// - matchesCriteria flag
  /// - DocumentReference preservation
  static UnifiedJobModel convertLegacyToUnified(
    Map<String, dynamic> legacyData, {
    DocumentReference? reference,
  }) {
    // Extract wage from jobDetails if not in top level
    final wage = legacyData['wage'] ??
        legacyData['jobDetails']?['payRate'] as double?;

    // Extract hours from jobDetails if not in top level
    final hours = legacyData['hours'] ??
        legacyData['jobDetails']?['hours'] as int?;

    // Extract per diem from jobDetails if not in top level
    final perDiem = legacyData['perDiem'] ??
        legacyData['per_diem'] ??
        legacyData['jobDetails']?['perDiem']?.toString();

    return UnifiedJobModel(
      id: legacyData['id']?.toString() ?? '',
      reference: reference,
      sharerId: legacyData['sharerId']?.toString() ?? '',
      jobDetails: legacyData['jobDetails'] as Map<String, dynamic>? ?? {},
      matchesCriteria: legacyData['matchesCriteria'] ?? false,
      deleted: legacyData['deleted'] ?? false,
      local: legacyData['local'] as int?,
      classification: legacyData['classification']?.toString(),
      company: legacyData['company']?.toString() ?? '',
      location: legacyData['location']?.toString() ?? '',
      hours: hours,
      wage: wage,
      sub: legacyData['sub']?.toString(),
      jobClass: legacyData['jobClass']?.toString(),
      localNumber: legacyData['localNumber'] as int?,
      qualifications: legacyData['qualifications']?.toString(),
      datePosted: legacyData['datePosted']?.toString() ??
          legacyData['date_posted']?.toString(),
      jobDescription: legacyData['jobDescription']?.toString() ??
          legacyData['job_description']?.toString(),
      jobTitle: legacyData['jobTitle']?.toString() ??
          legacyData['job_title']?.toString(),
      perDiem: perDiem,
      agreement: legacyData['agreement']?.toString(),
      numberOfJobs: legacyData['numberOfJobs']?.toString(),
      timestamp: _parseDateTime(legacyData['timestamp']),
      startDate: legacyData['startDate']?.toString(),
      startTime: legacyData['startTime']?.toString(),
      booksYourOn: _parseIntList(legacyData['booksYourOn']),
      typeOfWork: legacyData['typeOfWork']?.toString() ??
          legacyData['work_type']?.toString(),
      duration: legacyData['duration']?.toString(),
      voltageLevel: legacyData['voltageLevel']?.toString() ??
          legacyData['voltage_level']?.toString(),
    );
  }

  /// Converts a JobsRecord (from jobs_record.dart) to UnifiedJobModel
  ///
  /// JobsRecord is simpler, so most fields map directly
  static UnifiedJobModel convertJobsRecordToUnified(
    Map<String, dynamic> recordData, {
    DocumentReference? reference,
  }) {
    return UnifiedJobModel(
      id: recordData['id']?.toString() ?? '',
      reference: reference,
      company: recordData['company']?.toString() ?? '',
      location: recordData['location']?.toString() ?? '',
      classification: recordData['classification']?.toString(),
      hours: recordData['hours'] as int?,
      wage: recordData['wage'] as double?,
      jobTitle: recordData['jobTitle']?.toString(),
      timestamp: _parseDateTime(recordData['timestamp']),
      startDate: recordData['startDate']?.toString(),
      jobDescription: recordData['jobDescription']?.toString(),
      qualifications: recordData['qualifications']?.toString(),
      perDiem: recordData['perDiem']?.toString(),
      typeOfWork: recordData['typeOfWork']?.toString(),
      duration: recordData['duration']?.toString(),
      voltageLevel: recordData['voltageLevel']?.toString(),
      localNumber: recordData['localNumber'] as int?,
      certifications: _parseStringList(recordData['certifications']),
      deleted: recordData['deleted'] ?? false,
    );
  }

  /// Migrates an entire Firestore collection from legacy to unified model
  ///
  /// Process:
  /// 1. Read all documents
  /// 2. Convert to UnifiedJobModel
  /// 3. Validate each conversion
  /// 4. Write back to Firestore
  /// 5. Report any failures
  ///
  /// **IMPORTANT:** This is a destructive operation. Create backup first!
  ///
  /// Example:
  /// ```dart
  /// final result = await JobModelMigration.migrateJobsCollection();
  /// print('Migrated: ${result.successCount}');
  /// print('Failed: ${result.failureCount}');
  /// ```
  static Future<MigrationResult> migrateJobsCollection({
    String collectionName = 'jobs',
    bool dryRun = true,
    int batchSize = 500,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final result = MigrationResult();

    try {
      final snapshot = await firestore.collection(collectionName).get();

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Try to detect which model type this is
          UnifiedJobModel unified;
          if (data.containsKey('jobDetails')) {
            // Legacy Job model
            unified = convertLegacyToUnified(data, reference: doc.reference);
          } else {
            // JobsRecord model
            unified = convertJobsRecordToUnified(data,
                reference: doc.reference);
          }

          // Validate conversion
          if (!unified.isValid) {
            result.addFailure(doc.id, 'Invalid job after conversion');
            continue;
          }

          // Write back if not dry run
          if (!dryRun) {
            await doc.reference.set(unified.toFirestore());
          }

          result.addSuccess(doc.id);
        } catch (e) {
          result.addFailure(doc.id, e.toString());
        }
      }
    } catch (e) {
      result.error = e.toString();
    }

    return result;
  }

  /// Validates that all jobs in a collection match UnifiedJobModel schema
  ///
  /// Returns a report of:
  /// - Total jobs
  /// - Valid jobs
  /// - Invalid jobs with reasons
  static Future<ValidationReport> validateJobsCollection({
    String collectionName = 'jobs',
  }) async {
    final firestore = FirebaseFirestore.instance;
    final report = ValidationReport();

    try {
      final snapshot = await firestore.collection(collectionName).get();
      report.total = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final unified = UnifiedJobModel.fromJson({...data, 'id': doc.id});

          if (unified.isValid) {
            report.validCount++;
          } else {
            report.addInvalid(doc.id, 'Missing required fields');
          }
        } catch (e) {
          report.addInvalid(doc.id, e.toString());
        }
      }
    } catch (e) {
      report.error = e.toString();
    }

    return report;
  }

  /// Helper to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Helper to parse list of integers
  static List<int>? _parseIntList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
    }
    return null;
  }

  /// Helper to parse list of strings
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return value.split(',').map((s) => s.trim()).toList();
    }
    return null;
  }
}

/// Result of a migration operation
class MigrationResult {
  final List<String> successfulIds = [];
  final Map<String, String> failedIds = {};
  String? error;

  int get successCount => successfulIds.length;
  int get failureCount => failedIds.length;

  void addSuccess(String id) => successfulIds.add(id);
  void addFailure(String id, String reason) => failedIds[id] = reason;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Migration Result:');
    buffer.writeln('  Success: $successCount');
    buffer.writeln('  Failures: $failureCount');

    if (error != null) {
      buffer.writeln('  Error: $error');
    }

    if (failedIds.isNotEmpty) {
      buffer.writeln('\nFailed IDs:');
      failedIds.forEach((id, reason) {
        buffer.writeln('  - $id: $reason');
      });
    }

    return buffer.toString();
  }
}

/// Result of a validation operation
class ValidationReport {
  int total = 0;
  int validCount = 0;
  final Map<String, String> invalidJobs = {};
  String? error;

  int get invalidCount => invalidJobs.length;
  double get validPercent =>
      total > 0 ? (validCount / total) * 100 : 0;

  void addInvalid(String id, String reason) => invalidJobs[id] = reason;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Validation Report:');
    buffer.writeln('  Total: $total');
    buffer.writeln('  Valid: $validCount (${validPercent.toStringAsFixed(1)}%)');
    buffer.writeln('  Invalid: $invalidCount');

    if (error != null) {
      buffer.writeln('  Error: $error');
    }

    if (invalidJobs.isNotEmpty) {
      buffer.writeln('\nInvalid Jobs:');
      invalidJobs.forEach((id, reason) {
        buffer.writeln('  - $id: $reason');
      });
    }

    return buffer.toString();
  }
}

/// Example usage and migration script
///
/// Run this to perform the actual migration:
///
/// ```dart
/// void main() async {
///   // 1. Validate first (safe, read-only)
///   final validation = await JobModelMigration.validateJobsCollection();
///   print(validation);
///
///   if (validation.validPercent < 95) {
///     print('Warning: ${validation.invalidCount} invalid jobs found!');
///     print('Review validation report before migrating.');
///     return;
///   }
///
///   // 2. Dry run (safe, no writes)
///   final dryRun = await JobModelMigration.migrateJobsCollection(
///     dryRun: true,
///   );
///   print(dryRun);
///
///   // 3. Actual migration (destructive!)
///   print('Starting real migration...');
///   final result = await JobModelMigration.migrateJobsCollection(
///     dryRun: false,
///   );
///   print(result);
///
///   if (result.failureCount > 0) {
///     print('Migration completed with ${result.failureCount} failures!');
///   } else {
///     print('Migration completed successfully!');
///   }
/// }
/// ```
