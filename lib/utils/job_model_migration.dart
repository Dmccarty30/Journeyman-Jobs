import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

/// Utility functions for Job model operations and validations
///
/// This file provides helpers for:
/// - Job model validation
/// - Field mapping between different job representations
/// - Data parsing and normalization
/// - Firestore batch operations
///
/// Usage:
/// ```dart
/// // Validate job
/// final isValid = JobModelUtils.validateJob(job);
///
/// // Normalize job data
/// final normalized = JobModelUtils.normalizeJobData(data);
/// ```
class JobModelUtils {
  /// Validates that a Job has all required fields
  ///
  /// Required fields:
  /// - id (non-empty)
  /// - sharerId (non-empty)
  /// - company (non-empty)
  /// - location (non-empty)
  /// - jobDetails (non-empty map)
  ///
  /// Example:
  /// ```dart
  /// if (!JobModelUtils.validateJob(job)) {
  ///   print('Invalid job: missing required fields');
  /// }
  /// ```
  static bool validateJob(Job job) {
    return job.id.isNotEmpty &&
           job.sharerId.isNotEmpty &&
           job.company.isNotEmpty &&
           job.location.isNotEmpty &&
           job.jobDetails.isNotEmpty;
  }

  /// Normalizes job data from various sources to consistent format
  ///
  /// Handles:
  /// - Field name variations (company vs companyName, wage vs hourlyRate)
  /// - Type conversions (string to int/double)
  /// - Null safety and default values
  /// - jobDetails map construction
  ///
  /// Example:
  /// ```dart
  /// final normalized = JobModelUtils.normalizeJobData({
  ///   'companyName': 'ABC Electric',  // → company
  ///   'hourlyRate': '45.50',          // → wage as double
  /// });
  /// ```
  static Map<String, dynamic> normalizeJobData(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};

    // Normalize company field
    normalized['company'] = data['company'] ??
                           data['companyName'] ??
                           data['employer'] ??
                           '';

    // Normalize wage field
    normalized['wage'] = _parseDouble(data['wage']) ??
                        _parseDouble(data['hourlyRate']) ??
                        _parseDouble(data['payRate']);

    // Normalize location
    normalized['location'] = data['location'] ??
                            data['Location'] ??
                            '';

    // Copy other standard fields
    normalized['id'] = data['id'] ?? '';
    normalized['sharerId'] = data['sharerId'] ?? '';
    normalized['matchesCriteria'] = data['matchesCriteria'] ?? false;
    normalized['deleted'] = data['deleted'] ?? false;
    normalized['local'] = _parseInt(data['local'] ?? data['localNumber']);
    normalized['classification'] = data['classification'] ?? data['jobClass'];
    normalized['hours'] = _parseInt(data['hours'] ?? data['Shift']);
    normalized['sub'] = data['sub'];
    normalized['jobClass'] = data['jobClass'];
    normalized['localNumber'] = _parseInt(data['localNumber'] ?? data['local']);
    normalized['qualifications'] = data['qualifications'];
    normalized['datePosted'] = data['datePosted'] ?? data['date_posted'];
    normalized['jobDescription'] = data['jobDescription'] ?? data['job_description'];
    normalized['jobTitle'] = data['jobTitle'] ?? data['job_title'] ?? data['title'];
    normalized['perDiem'] = data['perDiem'] ?? data['per_diem'];
    normalized['agreement'] = data['agreement'];
    normalized['numberOfJobs'] = data['numberOfJobs'];
    normalized['timestamp'] = _parseDateTime(data['timestamp']);
    normalized['startDate'] = data['startDate'];
    normalized['startTime'] = data['startTime'];
    normalized['booksYourOn'] = _parseIntList(data['booksYourOn']);
    normalized['typeOfWork'] = data['typeOfWork'] ?? data['work_type'];
    normalized['duration'] = data['duration'];
    normalized['voltageLevel'] = data['voltageLevel'] ?? data['voltage_level'];

    // Build jobDetails map if not present
    if (data['jobDetails'] == null) {
      normalized['jobDetails'] = {
        'hours': normalized['hours'],
        'payRate': normalized['wage'],
        'perDiem': normalized['perDiem'],
        'contractor': normalized['company'],
        'location': data['geoPoint'], // GeoPoint if available
      };
    } else {
      normalized['jobDetails'] = data['jobDetails'];
    }

    return normalized;
  }

  /// Validates all jobs in a Firestore collection
  ///
  /// Returns a report of:
  /// - Total jobs
  /// - Valid jobs (have all required fields)
  /// - Invalid jobs with reasons
  ///
  /// Example:
  /// ```dart
  /// final report = await JobModelUtils.validateJobsCollection();
  /// print('Valid: ${report.validPercent}%');
  /// if (report.invalidCount > 0) {
  ///   print('Invalid jobs:');
  ///   report.invalidJobs.forEach((id, reason) {
  ///     print('  $id: $reason');
  ///   });
  /// }
  /// ```
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
          final job = Job.fromJson({...data, 'id': doc.id});

          if (validateJob(job)) {
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

  /// Helper to safely parse double from any type
  ///
  /// Handles: int, double, string (with currency symbols)
  /// Examples: "$45.50/hr", "45.50", 45.5, 45
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove currency symbols and formatting
      String cleanValue = value
          .replaceAll(RegExp(r'[\$,]'), '')
          .replaceAll('/hr', '')
          .replaceAll('/hour', '')
          .trim();
      return double.tryParse(cleanValue);
    }
    return null;
  }

  /// Helper to safely parse integer from any type
  ///
  /// Handles: int, double, string (with digit extraction)
  /// Validates positive integers to prevent invalid data
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value >= 0 ? value : null;
    if (value is double) return value >= 0 ? value.toInt() : null;
    if (value is String) {
      // First try direct parse
      final direct = int.tryParse(value.trim());
      if (direct != null && direct >= 0) return direct;

      // Extract leading digits (e.g., "123-Local" → 123)
      final match = RegExp(r'^\d+').firstMatch(value.trim());
      if (match != null) {
        final parsed = int.tryParse(match.group(0)!);
        if (parsed != null && parsed >= 0) return parsed;
      }
    }
    return null;
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

/// Example usage:
///
/// ```dart
/// void main() async {
///   // Validate jobs collection
///   final validation = await JobModelUtils.validateJobsCollection();
///   print(validation);
///
///   if (validation.validPercent < 95) {
///     print('Warning: ${validation.invalidCount} invalid jobs found!');
///     print('Review validation report:');
///     validation.invalidJobs.forEach((id, reason) {
///       print('  $id: $reason');
///     });
///   } else {
///     print('All jobs valid! ${validation.validPercent.toStringAsFixed(1)}%');
///   }
///
///   // Normalize data from external source
///   final externalData = {
///     'companyName': 'ABC Electric',  // Different field name
///     'hourlyRate': '\$45.50/hr',     // String with formatting
///   };
///   final normalized = JobModelUtils.normalizeJobData(externalData);
///   print('Normalized: ${normalized['company']}, ${normalized['wage']}');
/// }
/// ```
