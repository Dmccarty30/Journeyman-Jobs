import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';

/// Represents a job posting record in the Firestore database.
/// 
/// This class encapsulates all the information related to a job opportunity,
/// including company details, location, wage information, job requirements,
/// and scheduling details. It handles multiple field naming conventions to
/// maintain compatibility with different data sources.
class JobsRecord extends FirestoreRecord {
  JobsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  /// The local union number associated with this job.
  /// 
  /// This field identifies which local union chapter is posting or managing
  /// this job opportunity. Defaults to 0 if not specified.
  int? _local;
  int get local => _local ?? 0;
  bool hasLocal() => _local != null;

  /// The job classification or category.
  /// 
  /// Describes the type of work or trade classification for this position
  /// (e.g., "Electrician", "Plumber", "Carpenter"). Defaults to empty string if not specified.
  String? _classification;
  String get classification => _classification ?? '';
  bool hasClassification() => _classification != null;

  /// The name of the company offering this job.
  /// 
  /// This field supports multiple naming conventions ('company' or 'Company')
  /// to maintain compatibility with different data sources. Defaults to empty string if not specified.
  String? _company;
  String get company => _company ?? '';
  bool hasCompany() => _company != null;

  /// The physical location where the job will be performed.
  /// 
  /// This field supports multiple naming conventions ('location' or 'Location').
  /// May include city, state, address, or job site details. Defaults to empty string if not specified.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  /// The working hours or shift information for this job.
  /// 
  /// This field supports multiple naming conventions ('hours' or 'Shift').
  /// May include daily hours, shift times, or schedule details. Defaults to empty string if not specified.
  String? _hours;
  String get hours => _hours ?? '';
  bool hasHours() => _hours != null;

  /// The wage or salary information for this position.
  /// 
  /// Typically includes hourly rate, salary range, or compensation details.
  /// Format may vary (e.g., "$25/hr", "$50,000/year"). Defaults to empty string if not specified.
  String? _wage;
  String get wage => _wage ?? '';
  bool hasWage() => _wage != null;

  /// The subcontractor or subsidiary information.
  /// 
  /// Indicates if this job is through a subcontractor or specific subsidiary company.
  /// Defaults to empty string if not specified.
  String? _sub;
  String get sub => _sub ?? '';
  bool hasSub() => _sub != null;

  /// The specific job class or level within the trade.
  /// 
  /// May indicate skill level, certification requirements, or job tier
  /// (e.g., "Journeyman", "Apprentice", "Master"). Defaults to empty string if not specified.
  String? _jobClass;
  String get jobClass => _jobClass ?? '';
  bool hasJobClass() => _jobClass != null;

  /// The specific local union number for this job.
  /// 
  /// This is typically the numerical identifier for the local union chapter.
  /// May be the same as or different from the 'local' field. Defaults to 0 if not specified.
  int? _localNumber;
  int get localNumber => _localNumber ?? 0;
  bool hasLocalNumber() => _localNumber != null;

  /// Required qualifications or additional notes for this position.
  /// 
  /// This field supports multiple naming conventions ('qualifications' or 'Notes').
  /// May include certifications, experience requirements, or special skills needed.
  /// Defaults to empty string if not specified.
  String? _qualifications;
  String get qualifications => _qualifications ?? '';
  bool hasQualifications() => _qualifications != null;

  /// The date when this job was posted.
  /// 
  /// Stored as a string to accommodate various date formats from different sources.
  /// Defaults to empty string if not specified.
  String? _datePosted;
  String get datePosted => _datePosted ?? '';
  bool hasDatePosted() => _datePosted != null;

  /// Detailed description of the job duties and responsibilities.
  /// 
  /// Provides comprehensive information about what the job entails,
  /// daily tasks, and project scope. Defaults to empty string if not specified.
  String? _jobDescription;
  String get jobDescription => _jobDescription ?? '';
  bool hasJobDescription() => _jobDescription != null;

  /// The official title of the position.
  /// 
  /// The formal job title as posted by the employer
  /// (e.g., "Senior Electrician", "Lead Carpenter"). Defaults to empty string if not specified.
  String? _jobTitle;
  String get jobTitle => _jobTitle ?? '';
  bool hasJobTitle() => _jobTitle != null;

  /// Per diem allowances or benefits information.
  /// 
  /// This field supports multiple naming conventions ('per_diem' or 'Benefits').
  /// May include daily allowances, travel expenses, or additional benefits.
  /// Defaults to empty string if not specified.
  String? _perDiem;
  String get perDiem => _perDiem ?? '';
  bool hasPerDiem() => _perDiem != null;

  /// The labor agreement or contract type for this position.
  /// 
  /// May reference specific union agreements, contract terms, or
  /// collective bargaining agreements. Defaults to empty string if not specified.
  String? _agreement;
  String get agreement => _agreement ?? '';
  bool hasAgreement() => _agreement != null;

  /// The number of workers needed for this job.
  /// 
  /// This field supports multiple naming conventions ('numberOfJobs' or 'Men Needed').
  /// Indicates how many positions are available. Stored as string to accommodate
  /// various formats (e.g., "5", "5-10", "Multiple"). Defaults to empty string if not specified.
  String? _numberOfJobs;
  String get numberOfJobs => _numberOfJobs ?? '';
  bool hasNumberOfJobs() => _numberOfJobs != null;

  /// The timestamp when this job record was created or last updated.
  /// 
  /// Used for sorting and tracking when job postings were added to the system.
  /// Returns null if not set.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  /// The start date for the job.
  /// 
  /// When the worker is expected to begin work. Stored as string to
  /// accommodate various date formats. Defaults to empty string if not specified.
  String? _startDate;
  String get startDate => _startDate ?? '';
  bool hasStartDate() => _startDate != null;

  /// The start time for the job on the start date.
  /// 
  /// Specifies what time workers should report to the job site.
  /// Format may vary (e.g., "7:00 AM", "07:00"). Defaults to empty string if not specified.
  String? _startTime;
  String get startTime => _startTime ?? '';
  bool hasStartTime() => _startTime != null;

  /// List of book numbers that track which union books this job is listed on.
  /// 
  /// Used for tracking job postings across different union books or registries.
  /// Returns empty list if not specified. Each integer represents a book identifier.
  List<int>? _booksYourOn;
  List<int> get booksYourOn => _booksYourOn ?? const [];
  bool hasBooksYourOn() => _booksYourOn != null;

  /// The specific type of work to be performed.
  /// 
  /// This field supports multiple naming conventions ('typeOfWork' or 'Type of Work').
  /// Provides details about the nature of the work (e.g., "Commercial", "Residential",
  /// "Industrial"). Defaults to empty string if not specified.
  String? _typeOfWork;
  String get typeOfWork => _typeOfWork ?? '';
  bool hasTypeOfWork() => _typeOfWork != null;

  /// The expected duration of the job.
  /// 
  /// This field supports multiple naming conventions ('duration' or 'Duration').
  /// May indicate project length (e.g., "3 months", "6 weeks", "Long-term").
  /// Defaults to empty string if not specified.
  String? _duration;
  String get duration => _duration ?? '';
  bool hasDuration() => _duration != null;

  /// Initializes all fields from the Firestore snapshot data.
  /// 
  /// This method handles multiple field naming conventions to maintain
  /// compatibility with different data sources. It safely parses data types
  /// and provides fallback values for fields that may have different names
  /// in different data sources.
  void _initializeFields() {
    _local = _safeParseInt(snapshotData['local']);
    _classification = snapshotData['classification'] as String?;
    
    // Handle multiple field naming conventions for company
    _company = snapshotData['company'] as String? ?? snapshotData['Company'] as String?;
    
    // Handle multiple field naming conventions for location
    _location = snapshotData['location'] as String? ?? snapshotData['Location'] as String?;
    
    // Handle multiple field naming conventions for hours/shift
    _hours = snapshotData['hours'] as String? ?? snapshotData['Shift'] as String?;
    
    // Handle multiple field naming conventions for wage
    _wage = snapshotData['wage'] as String?;
    
    _sub = snapshotData['sub'] as String?;
    _jobClass = snapshotData['jobClass'] as String?;
    _localNumber = _safeParseInt(snapshotData['localNumber']);
    
    // Handle multiple field naming conventions for qualifications/notes
    _qualifications = snapshotData['qualifications'] as String? ?? snapshotData['Notes'] as String?;
    
    _datePosted = snapshotData['date_posted'] as String?;
    _jobDescription = snapshotData['job_description'] as String?;
    _jobTitle = snapshotData['job_title'] as String?;
    
    // Handle multiple field naming conventions for per diem/benefits
    _perDiem = snapshotData['per_diem'] as String? ?? snapshotData['Benefits'] as String?;
    
    _agreement = snapshotData['agreement'] as String?;
    
    // Handle multiple field naming conventions for number of jobs
    _numberOfJobs = snapshotData['numberOfJobs'] as String? ?? snapshotData['Men Needed'] as String?;
    
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _startDate = snapshotData['startDate'] as String?;
    _startTime = snapshotData['startTime'] as String?;
    _booksYourOn = _safeParseIntList(snapshotData['booksYourOn']);
    
    // Handle multiple field naming conventions for type of work
    _typeOfWork = snapshotData['typeOfWork'] as String? ?? snapshotData['Type of Work'] as String?;
    
    // Handle multiple field naming conventions for duration
    _duration = snapshotData['duration'] as String? ?? snapshotData['Duration'] as String?;
  }

  /// Safely parses an integer from various data types.
  /// 
  /// Handles conversion from int, double, and String types.
  /// Returns null if the value cannot be parsed or is null.
  /// Logs a warning if string parsing fails.
  /// 
  /// [value] The dynamic value to parse as an integer.
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        developer.log(
          'Warning: Could not parse "$value" as int, defaulting to null',
          name: 'JobsRecord._safeParseInt',
          error: e,
        );
        return null;
      }
    }
    return null;
  }

  /// Safely parses a list of integers from dynamic data.
  /// 
  /// Converts each item in the list to an integer using [_safeParseInt].
  /// Returns an empty list if the value is null or not a list.
  /// Items that cannot be parsed are converted to 0.
  /// 
  /// [value] The dynamic value to parse as a list of integers.
  List<int> _safeParseIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => _safeParseInt(item) ?? 0).toList();
    }
    return [];
  }

  /// Gets the Firestore collection reference for job records.
  /// 
  /// Returns a reference to the 'jobs' collection in Firestore.
  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('jobs');

  /// Creates a stream of JobsRecord updates for a specific document.
  /// 
  /// [ref] The document reference to observe.
  /// Returns a stream that emits a new JobsRecord whenever the document changes.
  static Stream<JobsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => JobsRecord.fromSnapshot(s));

  /// Fetches a JobsRecord once from a document reference.
  /// 
  /// [ref] The document reference to fetch.
  /// Returns a Future that resolves to a JobsRecord.
  static Future<JobsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => JobsRecord.fromSnapshot(s));

  /// Creates a JobsRecord from a Firestore document snapshot.
  /// 
  /// [snapshot] The Firestore document snapshot containing the job data.
  /// Returns a new JobsRecord instance with the snapshot data.
  static JobsRecord fromSnapshot(DocumentSnapshot snapshot) => JobsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  /// Creates a JobsRecord from raw data and a document reference.
  /// 
  /// [data] The raw job data as a map.
  /// [reference] The Firestore document reference.
  /// Returns a new JobsRecord instance.
  static JobsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      JobsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'JobsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is JobsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;

  Query<Object?> toMap() {
    return collection.where('reference', isEqualTo: reference);
  }
}

/// Creates a map of job data suitable for Firestore storage.
/// 
/// This helper function creates a properly formatted data map for creating
/// or updating job records in Firestore. All parameters are optional and
/// null values are filtered out before storage.
/// 
/// Parameters:
/// - [local]: The local union number
/// - [classification]: Job classification or category
/// - [company]: Company name offering the job
/// - [location]: Physical job location
/// - [hours]: Working hours or shift information
/// - [wage]: Wage or salary information
/// - [sub]: Subcontractor information
/// - [jobClass]: Specific job class or level
/// - [localNumber]: Specific local union number
/// - [qualifications]: Required qualifications
/// - [datePosted]: Date the job was posted
/// - [jobDescription]: Detailed job description
/// - [jobTitle]: Official job title
/// - [perDiem]: Per diem or benefits information
/// - [agreement]: Labor agreement type
/// - [numberOfJobs]: Number of workers needed
/// - [timestamp]: Creation or update timestamp
/// - [startDate]: Job start date
/// - [startTime]: Job start time
/// 
/// Returns a Map<String, dynamic> with non-null values ready for Firestore.
Map<String, dynamic> createJobsRecordData({
  int? local,
  String? classification,
  String? company,
  String? location,
  String? hours,
  String? wage,
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
  DateTime? timestamp,
  String? startDate,
  String? startTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'local': local,
      'classification': classification,
      'company': company,
      'location': location,
      'hours': hours,
      'wage': wage,
      'sub': sub,
      'jobClass': jobClass,
      'localNumber': localNumber,
      'qualifications': qualifications,
      'date_posted': datePosted,
      'job_description': jobDescription,
      'job_title': jobTitle,
      'per_diem': perDiem,
      'agreement': agreement,
      'numberOfJobs': numberOfJobs,
      'timestamp': timestamp,
      'startDate': startDate,
      'startTime': startTime,
    }.withoutNulls,
  );

  return firestoreData;
}

/// Provides equality comparison for JobsRecord instances.
/// 
/// This class implements the Equality interface to allow proper comparison
/// of JobsRecord objects based on their field values rather than object
/// references. It's particularly useful for state management and change
/// detection in Flutter applications.
class JobsRecordDocumentEquality implements Equality<JobsRecord> {
  const JobsRecordDocumentEquality();

  /// Compares two JobsRecord instances for equality.
  /// 
  /// Returns true if all fields in both records are equal, including
  /// proper list comparison for the booksYourOn field.
  /// 
  /// [e1] First JobsRecord to compare
  /// [e2] Second JobsRecord to compare
  /// Returns true if records are equal, false otherwise
  @override
  bool equals(JobsRecord? e1, JobsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.local == e2?.local &&
        e1?.classification == e2?.classification &&
        e1?.company == e2?.company &&
        e1?.location == e2?.location &&
        e1?.hours == e2?.hours &&
        e1?.wage == e2?.wage &&
        e1?.sub == e2?.sub &&
        e1?.jobClass == e2?.jobClass &&
        e1?.localNumber == e2?.localNumber &&
        e1?.qualifications == e2?.qualifications &&
        e1?.datePosted == e2?.datePosted &&
        e1?.jobDescription == e2?.jobDescription &&
        e1?.jobTitle == e2?.jobTitle &&
        e1?.perDiem == e2?.perDiem &&
        e1?.agreement == e2?.agreement &&
        e1?.numberOfJobs == e2?.numberOfJobs &&
        e1?.timestamp == e2?.timestamp &&
        e1?.startDate == e2?.startDate &&
        e1?.startTime == e2?.startTime &&
        listEquality.equals(e1?.booksYourOn, e2?.booksYourOn);
  }

  /// Generates a hash code for a JobsRecord instance.
  /// 
  /// Creates a hash based on all field values to ensure consistent
  /// hashing for equal objects.
  /// 
  /// [e] The JobsRecord to hash
  /// Returns an integer hash code
  @override
  int hash(JobsRecord? e) => const ListEquality().hash([
        e?.local,
        e?.classification,
        e?.company,
        e?.location,
        e?.hours,
        e?.wage,
        e?.sub,
        e?.jobClass,
        e?.localNumber,
        e?.qualifications,
        e?.datePosted,
        e?.jobDescription,
        e?.jobTitle,
        e?.perDiem,
        e?.agreement,
        e?.numberOfJobs,
        e?.timestamp,
        e?.startDate,
        e?.startTime,
        e?.booksYourOn
      ]);

  /// Checks if an object is a valid key for comparison.
  /// 
  /// [o] The object to validate
  /// Returns true if the object is a JobsRecord instance
  @override
  bool isValidKey(Object? o) => o is JobsRecord;
}
