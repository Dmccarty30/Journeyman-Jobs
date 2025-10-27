import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/domain/enums/onboarding_status.dart';

/// User Model - IBEW Electrical Worker Profile
///
/// Represents a complete user profile for IBEW electrical workers in the
/// Journeyman Jobs application. This model stores all personal, professional,
/// and preference data collected during onboarding and maintained throughout
/// the user's lifecycle.
///
/// ## Key Sections:
///
/// ### Authentication & Identity
/// - Basic user identification (uid, username, email)
/// - Display information (displayName, avatarUrl)
/// - Online status tracking for real-time features
///
/// ### IBEW Professional Information
/// - Classification: Type of electrical worker (Journeyman Lineman, Wireman, etc.)
/// - Home Local: IBEW local union number where member holds their ticket
/// - Ticket Number: IBEW membership/journeyman ticket identifier
/// - Books On: Which local's out-of-work books they're currently on
/// - Work Status: Current employment status (isWorking)
///
/// ### Personal Information
/// - Contact details (phone, address)
/// - Required for job dispatch and emergency contacts
/// - Privacy-protected, never shared without consent
///
/// ### Job Search Preferences
/// - Construction types (Commercial, Industrial, Residential, Utility)
/// - Hours per week preference (40-50, 50-60, 60-70, 70+)
/// - Per diem requirements for travel work
/// - Preferred locals for finding work opportunities
/// - Maximum travel distance for jobs
///
/// ### Career Goals & Motivations
/// - Professional development goals (networking, advancement, skills)
/// - Compensation preferences (pay rate, benefits)
/// - Work preferences (long-term, travel opportunities)
///
/// ### System Metadata
/// - Account creation and last active timestamps
/// - FCM token for push notifications
/// - Crew associations for team features
/// - Onboarding status tracking
///
/// ## Firebase Integration:
/// All fields map directly to Firestore document structure.
/// Uses single consolidated write during onboarding completion
/// to prevent duplicate fields and ensure data consistency.
///
/// ## Privacy & Security:
/// - Sensitive fields (ticketNumber) are never exposed in public queries
/// - Personal information is only shared with user consent
/// - Location data is approximate for privacy protection
///
/// ## IBEW Terminology:
/// - "Home Local": The IBEW local where a member holds their primary membership
/// - "Books On": The out-of-work list at a local union hall
/// - "Ticket Number": Journeyman certification identifier
/// - "Classification": Specific trade specialization within IBEW
/// - "Brother/Sister": Traditional respectful greeting among union members
class UserModel {
  /// Firebase Authentication unique identifier
  final String uid;

  /// User's chosen username (typically email prefix)
  final String username;

  /// IBEW electrical classification (e.g., 'Journeyman Lineman', 'Journeyman Wireman')
  final String classification;

  /// IBEW home local union number (e.g., 26 for Washington DC)
  final int homeLocal;

  /// User role in the system ('electrician', 'contractor', 'admin')
  final String role;

  /// IDs of crews the user belongs to for team features
  final List<String> crewIds;

  /// User's email address for authentication and communication
  final String email;

  /// Profile picture URL from Firebase Storage or social provider
  final String? avatarUrl;

  /// Real-time online status for presence features (default: true after onboarding)
  final bool onlineStatus;

  /// Timestamp of last user activity for presence tracking
  final DateTime lastActive;

  /// Personal information - Required for job dispatch
  final String firstName;
  final String lastName;
  final String phoneNumber;

  /// Address information - Required for job location matching
  final String address1;
  final String? address2;  // Optional: apartment, unit, etc.
  final String city;
  final String state;
  final int zipcode;

  /// IBEW membership ticket/book number - Sensitive, handle with care
  final String ticketNumber;

  /// Current employment status
  final bool isWorking;

  /// Which local's out-of-work books they're signed on (e.g., "Local 103")
  final String? booksOn;

  /// Types of construction work preferred (Commercial, Industrial, Residential, Utility)
  final List<String> constructionTypes;

  /// Preferred weekly hours range (40-50, 50-60, 60-70, 70+)
  final String? hoursPerWeek;

  /// Minimum per diem requirement for travel work ($50-75, $75-100, etc.)
  final String? perDiemRequirement;

  /// Comma-separated list of preferred IBEW locals for work
  final String? preferredLocals;

  /// Firebase Cloud Messaging token for push notifications
  final String? fcmToken;

  /// Full display name (firstName + lastName or custom)
  final String displayName;

  /// Account active status for soft deletion
  final bool isActive;

  /// Account creation timestamp
  final DateTime? createdTime;

  /// Professional certifications held (OSHA 10, OSHA 30, etc.)
  final List<String> certifications;

  /// Years of experience in the trade
  final int yearsExperience;

  /// Maximum distance willing to travel for work (miles)
  final int preferredDistance;

  /// Alternative field for local number (legacy support)
  final String localNumber;

  /// Career goals and motivations - Job search preferences
  final bool networkWithOthers;      // Connect with other electricians
  final bool careerAdvancements;      // Seek leadership roles
  final bool betterBenefits;          // Improved benefit packages
  final bool higherPayRate;           // Increase compensation
  final bool learnNewSkill;           // Gain new experience
  final bool travelToNewLocation;     // Work in different areas
  final bool findLongTermWork;        // Stable, long-term positions

  /// Free-form career goals text
  final String? careerGoals;

  /// Marketing: How user discovered the app
  final String? howHeardAboutUs;

  /// User's primary goal with the app
  final String? lookingToAccomplish;

  /// Tracks onboarding completion status
  final OnboardingStatus? onboardingStatus;

  /// Whether user has configured job search preferences
  final bool hasSetJobPreferences;

  UserModel({
    required this.uid,
    required this.username,
    required this.classification,
    required this.homeLocal,
    required this.role,
    this.crewIds = const [],
    required this.email,
    this.avatarUrl,
    this.onlineStatus = false,
    required this.lastActive,
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '',
    this.address1 = '',
    this.address2,
    this.city = '',
    this.state = '',
    this.zipcode = 0,
    this.ticketNumber = '',
    this.isWorking = false,
    this.booksOn,
    this.constructionTypes = const [],
    this.hoursPerWeek,
    this.perDiemRequirement,
    this.preferredLocals,
    this.fcmToken,
    this.displayName = '',
    this.isActive = true,
    this.createdTime,
    this.certifications = const [],
    this.yearsExperience = 0,
    this.preferredDistance = 0,
    this.localNumber = '',
    required this.networkWithOthers,
    required this.careerAdvancements,
    required this.betterBenefits,
    required this.higherPayRate,
    required this.learnNewSkill,
    required this.travelToNewLocation,
    required this.findLongTermWork,
    this.careerGoals,
    this.howHeardAboutUs,
    this.lookingToAccomplish,
    this.onboardingStatus,
    this.hasSetJobPreferences = false,
  });

  String get displayNameStr => displayName.isEmpty ? '$firstName $lastName'.trim() : displayName;

  bool get isActiveGetter => isActive;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      classification: data['classification'] ?? '',
      homeLocal: data['homeLocal'] ?? 0,
      role: data['role'] ?? '',
      crewIds: List<String>.from(data['crewIds'] ?? []),
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      onlineStatus: data['onlineStatus'] ?? false,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address1: data['address1'] ?? '',
      address2: data['address2'],
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipcode: data['zipcode'] ?? 0,
      ticketNumber: data['ticketNumber'] ?? '',
      isWorking: data['isWorking'] ?? false,
      booksOn: data['booksOn'],
      constructionTypes: List<String>.from(data['constructionTypes'] ?? []),
      hoursPerWeek: data['hoursPerWeek'],
      perDiemRequirement: data['perDiemRequirement'],
      preferredLocals: data['preferredLocals'],
      fcmToken: data['fcmToken'],
      displayName: data['displayName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdTime: (data['createdTime'] as Timestamp?)?.toDate(),
      certifications: List<String>.from(data['certifications'] ?? []),
      yearsExperience: data['yearsExperience'] ?? 0,
      preferredDistance: data['preferredDistance'] ?? 0,
      localNumber: data['localNumber'] ?? '',
      networkWithOthers: data['networkWithOthers'] ?? false,
      careerAdvancements: data['careerAdvancements'] ?? false,
      betterBenefits: data['betterBenefits'] ?? false,
      higherPayRate: data['higherPayRate'] ?? false,
      learnNewSkill: data['learnNewSkill'] ?? false,
      travelToNewLocation: data['travelToNewLocation'] ?? false,
      findLongTermWork: data['findLongTermWork'] ?? false,
      careerGoals: data['careerGoals'],
      howHeardAboutUs: data['howHeardAboutUs'],
      lookingToAccomplish: data['lookingToAccomplish'],
      onboardingStatus: data['onboardingStatus'] != null ? OnboardingStatus.values.firstWhere((e) => e.name == data['onboardingStatus']) : null,
      hasSetJobPreferences: data['hasSetJobPreferences'] ?? false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      classification: json['classification'] ?? '',
      homeLocal: json['homeLocal'] ?? 0,
      role: json['role'] ?? '',
      crewIds: List<String>.from(json['crewIds'] ?? []),
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      onlineStatus: json['onlineStatus'] ?? false,
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipcode: json['zipcode'] ?? 0,
      ticketNumber: json['ticketNumber'] ?? '',
      isWorking: json['isWorking'] ?? false,
      booksOn: json['booksOn'],
      constructionTypes: List<String>.from(json['constructionTypes'] ?? []),
      hoursPerWeek: json['hoursPerWeek'],
      perDiemRequirement: json['perDiemRequirement'],
      preferredLocals: json['preferredLocals'],
      fcmToken: json['fcmToken'],
      displayName: json['displayName'] ?? '',
      isActive: json['isActive'] ?? true,
      createdTime: json['createdTime'] != null ? DateTime.parse(json['createdTime']) : null,
      certifications: List<String>.from(json['certifications'] ?? []),
      yearsExperience: json['yearsExperience'] ?? 0,
      preferredDistance: json['preferredDistance'] ?? 0,
      localNumber: json['localNumber'] ?? '',
      networkWithOthers: json['networkWithOthers'] ?? false,
      careerAdvancements: json['careerAdvancements'] ?? false,
      betterBenefits: json['betterBenefits'] ?? false,
      higherPayRate: json['higherPayRate'] ?? false,
      learnNewSkill: json['learnNewSkill'] ?? false,
      travelToNewLocation: json['travelToNewLocation'] ?? false,
      findLongTermWork: json['findLongTermWork'] ?? false,
      careerGoals: json['careerGoals'],
      howHeardAboutUs: json['howHeardAboutUs'],
      lookingToAccomplish: json['lookingToAccomplish'],
      onboardingStatus: json['onboardingStatus'] != null ? OnboardingStatus.values.firstWhere((e) => e.name == json['onboardingStatus']) : null,
      hasSetJobPreferences: json['hasSetJobPreferences'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'classification': classification,
      'homeLocal': homeLocal,
      'role': role,
      'crewIds': crewIds,
      'email': email,
      'avatarUrl': avatarUrl,
      'onlineStatus': onlineStatus,
      'lastActive': lastActive.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'ticketNumber': ticketNumber,
      'isWorking': isWorking,
      'booksOn': booksOn,
      'constructionTypes': constructionTypes,
      'hoursPerWeek': hoursPerWeek,
      'perDiemRequirement': perDiemRequirement,
      'preferredLocals': preferredLocals,
      'fcmToken': fcmToken,
      'displayName': displayName,
      'isActive': isActive,
      'createdTime': createdTime?.toIso8601String(),
      'certifications': certifications,
      'yearsExperience': yearsExperience,
      'preferredDistance': preferredDistance,
      'localNumber': localNumber,
      'networkWithOthers': networkWithOthers,
      'careerAdvancements': careerAdvancements,
      'betterBenefits': betterBenefits,
      'higherPayRate': higherPayRate,
      'learnNewSkill': learnNewSkill,
      'travelToNewLocation': travelToNewLocation,
      'findLongTermWork': findLongTermWork,
      'careerGoals': careerGoals,
      'howHeardAboutUs': howHeardAboutUs,
      'lookingToAccomplish': lookingToAccomplish,
      'onboardingStatus': onboardingStatus,
      'hasSetJobPreferences': hasSetJobPreferences,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'classification': classification,
      'homeLocal': homeLocal,
      'role': role,
      'crewIds': crewIds,
      'email': email,
      'avatarUrl': avatarUrl,
      'onlineStatus': onlineStatus,
      'lastActive': Timestamp.fromDate(lastActive),
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'ticketNumber': ticketNumber,
      'isWorking': isWorking,
      'booksOn': booksOn,
      'constructionTypes': constructionTypes,
      'hoursPerWeek': hoursPerWeek,
      'perDiemRequirement': perDiemRequirement,
      'preferredLocals': preferredLocals,
      'fcmToken': fcmToken,
      'displayName': displayName,
      'isActive': isActive,
      'createdTime': createdTime != null ? Timestamp.fromDate(createdTime!) : null,
      'certifications': certifications,
      'yearsExperience': yearsExperience,
      'preferredDistance': preferredDistance,
      'localNumber': localNumber,
      'networkWithOthers': networkWithOthers,
      'careerAdvancements': careerAdvancements,
      'betterBenefits': betterBenefits,
      'higherPayRate': higherPayRate,
      'learnNewSkill': learnNewSkill,
      'travelToNewLocation': travelToNewLocation,
      'findLongTermWork': findLongTermWork,
      'careerGoals': careerGoals,
      'howHeardAboutUs': howHeardAboutUs,
      'lookingToAccomplish': lookingToAccomplish,
      'onboardingStatus': onboardingStatus,
      'hasSetJobPreferences': hasSetJobPreferences,
    };
  }

  bool isValid() {
    return username.isNotEmpty && email.isNotEmpty && classification.isNotEmpty;
  }
}
