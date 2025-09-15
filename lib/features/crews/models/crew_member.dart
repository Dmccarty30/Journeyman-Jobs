import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_enums.dart';

/// Represents a member of an IBEW electrical worker crew
/// 
/// Tracks individual member information, role, preferences,
/// and status within the crew organization.
class CrewMember {
  /// Unique identifier for this crew member record
  final String? id;
  
  /// User ID of the crew member
  final String userId;
  
  /// Crew ID this member belongs to
  final String crewId;
  
  /// Member's display name
  final String? displayName;
  
  /// Member's email
  final String? email;
  
  /// Member's phone number
  final String? phone;
  
  /// Member's profile image URL
  final String? profileImageUrl;
  
  /// Role within the crew
  final CrewRole role;
  
  /// Date when member joined the crew
  final DateTime joinedAt;
  
  /// Date when member was last active
  final DateTime? lastActiveAt;
  
  /// Whether member is currently active
  final bool isActive;
  
  /// Work preferences for this member
  final CrewMemberPreferences workPreferences;
  
  /// Notification settings for this member
  final NotificationSettings notifications;
  
  /// Member's IBEW classifications
  final List<String> classifications;
  
  /// Member's IBEW local number
  final String? localNumber;
  
  /// Member's years of experience
  final int? yearsExperience;
  
  /// Member's certifications
  final List<String> certifications;
  
  /// Member's skills and specializations
  final List<String> skills;
  
  /// Member's availability status
  final MemberAvailability availability;
  
  /// Member's rating within the crew
  final double? rating;
  
  /// Number of jobs completed with this crew
  final int jobsCompleted;
  
  /// Emergency contact information
  final EmergencyContact? emergencyContact;

  const CrewMember({
    this.id,
    required this.userId,
    required this.crewId,
    this.displayName,
    this.email,
    this.phone,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
    this.lastActiveAt,
    required this.isActive,
    required this.workPreferences,
    required this.notifications,
    this.classifications = const [],
    this.localNumber,
    this.yearsExperience,
    this.certifications = const [],
    this.skills = const [],
    this.availability = MemberAvailability.available,
    this.rating,
    this.jobsCompleted = 0,
    this.emergencyContact,
  });

  /// Create from Firestore document
  factory CrewMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CrewMember(
      id: doc.id,
      userId: data['userId'] ?? '',
      crewId: data['crewId'] ?? '',
      displayName: data['displayName'],
      email: data['email'],
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      role: CrewRole.fromString(data['role']) ?? CrewRole.crewMember,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      workPreferences: CrewMemberPreferences.fromJson(data['workPreferences'] ?? {}),
      notifications: NotificationSettings.fromJson(data['notifications'] ?? {}),
      classifications: List<String>.from(data['classifications'] ?? []),
      localNumber: data['localNumber'],
      yearsExperience: data['yearsExperience'],
      certifications: List<String>.from(data['certifications'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      availability: MemberAvailability.fromString(data['availability']) ?? MemberAvailability.available,
      rating: data['rating']?.toDouble(),
      jobsCompleted: data['jobsCompleted'] ?? 0,
      emergencyContact: data['emergencyContact'] != null 
          ? EmergencyContact.fromJson(data['emergencyContact'])
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'crewId': crewId,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'isActive': isActive,
      'workPreferences': workPreferences.toJson(),
      'notifications': notifications.toJson(),
      'classifications': classifications,
      'localNumber': localNumber,
      'yearsExperience': yearsExperience,
      'certifications': certifications,
      'skills': skills,
      'availability': availability.name,
      'rating': rating,
      'jobsCompleted': jobsCompleted,
      'emergencyContact': emergencyContact?.toJson(),
    };
  }

  /// Create a copy with updated fields
  CrewMember copyWith({
    String? id,
    String? userId,
    String? crewId,
    String? displayName,
    String? email,
    String? phone,
    String? profileImageUrl,
    CrewRole? role,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    bool? isActive,
    CrewMemberPreferences? workPreferences,
    NotificationSettings? notifications,
    List<String>? classifications,
    String? localNumber,
    int? yearsExperience,
    List<String>? certifications,
    List<String>? skills,
    MemberAvailability? availability,
    double? rating,
    int? jobsCompleted,
    EmergencyContact? emergencyContact,
  }) {
    return CrewMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      crewId: crewId ?? this.crewId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      workPreferences: workPreferences ?? this.workPreferences,
      notifications: notifications ?? this.notifications,
      classifications: classifications ?? this.classifications,
      localNumber: localNumber ?? this.localNumber,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      certifications: certifications ?? this.certifications,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  /// Helper methods
  bool get isLeader => role == CrewRole.foreman;
  bool get isAvailable => availability == MemberAvailability.available;
  bool get hasEmergencyContact => emergencyContact != null;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrewMember &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          crewId == other.crewId;

  @override
  int get hashCode => userId.hashCode ^ crewId.hashCode;

  @override
  String toString() => 'CrewMember(userId: $userId, crewId: $crewId, role: ${role.displayName})';
}

/// Member work preferences
class CrewMemberPreferences {
  final List<JobType> preferredJobTypes;
  final int maxTravelRadius;
  final bool availableForStormWork;
  final bool availableForWeekends;
  final bool availableForNightShift;
  final bool availableForOvertime;
  final double? preferredHourlyRate;
  final String? perDiemRequirement;

  const CrewMemberPreferences({
    this.preferredJobTypes = const [],
    this.maxTravelRadius = 50,
    this.availableForStormWork = false,
    this.availableForWeekends = true,
    this.availableForNightShift = false,
    this.availableForOvertime = true,
    this.preferredHourlyRate,
    this.perDiemRequirement,
  });

  factory CrewMemberPreferences.fromJson(Map<String, dynamic> json) {
    return CrewMemberPreferences(
      preferredJobTypes: (json['preferredJobTypes'] as List<dynamic>?)
          ?.map((type) => JobType.fromString(type))
          .whereType<JobType>()
          .toList() ?? [],
      maxTravelRadius: json['maxTravelRadius'] ?? 50,
      availableForStormWork: json['availableForStormWork'] ?? false,
      availableForWeekends: json['availableForWeekends'] ?? true,
      availableForNightShift: json['availableForNightShift'] ?? false,
      availableForOvertime: json['availableForOvertime'] ?? true,
      preferredHourlyRate: json['preferredHourlyRate']?.toDouble(),
      perDiemRequirement: json['perDiemRequirement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredJobTypes': preferredJobTypes.map((type) => type.name).toList(),
      'maxTravelRadius': maxTravelRadius,
      'availableForStormWork': availableForStormWork,
      'availableForWeekends': availableForWeekends,
      'availableForNightShift': availableForNightShift,
      'availableForOvertime': availableForOvertime,
      'preferredHourlyRate': preferredHourlyRate,
      'perDiemRequirement': perDiemRequirement,
    };
  }
}

/// Notification settings for crew member
class NotificationSettings {
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableSmsNotifications;
  final bool notifyOnNewJobs;
  final bool notifyOnJobUpdates;
  final bool notifyOnCrewMessages;
  final bool notifyOnEmergencyAlerts;
  final bool notifyOnScheduleChanges;
  final bool notifyOnBidUpdates;

  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.enableSmsNotifications = false,
    this.notifyOnNewJobs = true,
    this.notifyOnJobUpdates = true,
    this.notifyOnCrewMessages = true,
    this.notifyOnEmergencyAlerts = true,
    this.notifyOnScheduleChanges = true,
    this.notifyOnBidUpdates = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enableEmailNotifications: json['enableEmailNotifications'] ?? true,
      enableSmsNotifications: json['enableSmsNotifications'] ?? false,
      notifyOnNewJobs: json['notifyOnNewJobs'] ?? true,
      notifyOnJobUpdates: json['notifyOnJobUpdates'] ?? true,
      notifyOnCrewMessages: json['notifyOnCrewMessages'] ?? true,
      notifyOnEmergencyAlerts: json['notifyOnEmergencyAlerts'] ?? true,
      notifyOnScheduleChanges: json['notifyOnScheduleChanges'] ?? true,
      notifyOnBidUpdates: json['notifyOnBidUpdates'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableEmailNotifications': enableEmailNotifications,
      'enableSmsNotifications': enableSmsNotifications,
      'notifyOnNewJobs': notifyOnNewJobs,
      'notifyOnJobUpdates': notifyOnJobUpdates,
      'notifyOnCrewMessages': notifyOnCrewMessages,
      'notifyOnEmergencyAlerts': notifyOnEmergencyAlerts,
      'notifyOnScheduleChanges': notifyOnScheduleChanges,
      'notifyOnBidUpdates': notifyOnBidUpdates,
    };
  }
}

/// Member availability status
enum MemberAvailability {
  available,
  busy,
  onJob,
  onVacation,
  sick,
  unavailable,
  offline;

  String get displayName {
    switch (this) {
      case MemberAvailability.available:
        return 'Available';
      case MemberAvailability.busy:
        return 'Busy';
      case MemberAvailability.onJob:
        return 'On Job';
      case MemberAvailability.onVacation:
        return 'On Vacation';
      case MemberAvailability.sick:
        return 'Sick Leave';
      case MemberAvailability.unavailable:
        return 'Unavailable';
      case MemberAvailability.offline:
        return 'Offline';
    }
  }

  static MemberAvailability? fromString(String? value) {
    if (value == null) return null;
    try {
      return MemberAvailability.values.firstWhere(
        (status) => status.name == value,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Emergency contact information
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final String? alternatePhone;
  final String? email;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.alternatePhone,
    this.email,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phone: json['phone'] ?? '',
      alternatePhone: json['alternatePhone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'email': email,
    };
  }
}