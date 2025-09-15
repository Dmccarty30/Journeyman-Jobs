import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'crew_enums.dart';

/// Core crew model for IBEW electrical worker crews
/// 
/// Represents a crew of electrical workers organized for job coordination,
/// group bidding, and collaborative work management. Supports various crew
/// types from temporary storm crews to permanent maintenance teams.
class Crew {
  /// Unique crew identifier
  final String id;
  
  /// Crew basic information
  final String name;
  final String? description;
  final String? imageUrl;
  
  /// Crew leadership and organization
  final String createdBy;
  final String? foremanId;
  final List<String> adminIds;
  
  /// Crew member management
  final List<String> memberIds;
  final List<String> invitedMemberIds;
  final int maxMembers;
  final bool isPublic;
  
  /// Professional specifications
  final List<String> classifications;
  final List<JobType> jobTypes;
  final List<String> preferredLocals;
  final String? homeLocal;
  
  /// Location and availability
  final String? location;
  final double? latitude;
  final double? longitude;
  final int travelRadius;
  final bool availableForStormWork;
  final bool availableForEmergencyWork;
  
  /// Crew status and metadata
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivityAt;
  
  /// Job coordination
  final List<String> currentJobIds;
  final List<String> bidJobIds;
  final double? hourlyRate;
  final String? perDiemRequirement;
  
  /// Communication preferences
  final bool allowJobSharing;
  final bool allowInvitations;
  final List<String> communicationChannels;
  
  /// Statistics and performance
  final int totalJobs;
  final double averageRating;
  final int completedJobs;
  final DateTime? lastJobCompletedAt;

  const Crew({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.memberIds,
    required this.maxMembers,
    required this.classifications,
    required this.jobTypes,
    required this.travelRadius,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.imageUrl,
    this.foremanId,
    this.adminIds = const [],
    this.invitedMemberIds = const [],
    this.isPublic = false,
    this.preferredLocals = const [],
    this.homeLocal,
    this.location,
    this.latitude,
    this.longitude,
    this.availableForStormWork = false,
    this.availableForEmergencyWork = false,
    this.lastActivityAt,
    this.currentJobIds = const [],
    this.bidJobIds = const [],
    this.hourlyRate,
    this.perDiemRequirement,
    this.allowJobSharing = true,
    this.allowInvitations = true,
    this.communicationChannels = const ['in_app', 'email'],
    this.totalJobs = 0,
    this.averageRating = 0.0,
    this.completedJobs = 0,
    this.lastJobCompletedAt,
  });

  /// Create crew from Firestore document
  factory Crew.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Crew(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      foremanId: data['foremanId'],
      adminIds: List<String>.from(data['adminIds'] ?? []),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      invitedMemberIds: List<String>.from(data['invitedMemberIds'] ?? []),
      maxMembers: data['maxMembers'] ?? 10,
      isPublic: data['isPublic'] ?? false,
      classifications: List<String>.from(data['classifications'] ?? []),
      jobTypes: (data['jobTypes'] as List<dynamic>?)
          ?.map((type) => JobType.values.firstWhereOrNull(
                (e) => e.name == type.toString(),
              ))
          .whereType<JobType>()
          .toList() ?? [],
      preferredLocals: List<String>.from(data['preferredLocals'] ?? []),
      homeLocal: data['homeLocal'],
      location: data['location'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      travelRadius: data['travelRadius'] ?? 50,
      availableForStormWork: data['availableForStormWork'] ?? false,
      availableForEmergencyWork: data['availableForEmergencyWork'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: (data['lastActivityAt'] as Timestamp?)?.toDate(),
      currentJobIds: List<String>.from(data['currentJobIds'] ?? []),
      bidJobIds: List<String>.from(data['bidJobIds'] ?? []),
      hourlyRate: data['hourlyRate']?.toDouble(),
      perDiemRequirement: data['perDiemRequirement'],
      allowJobSharing: data['allowJobSharing'] ?? true,
      allowInvitations: data['allowInvitations'] ?? true,
      communicationChannels: List<String>.from(data['communicationChannels'] ?? ['in_app', 'email']),
      totalJobs: data['totalJobs'] ?? 0,
      averageRating: data['averageRating']?.toDouble() ?? 0.0,
      completedJobs: data['completedJobs'] ?? 0,
      lastJobCompletedAt: (data['lastJobCompletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert crew to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'foremanId': foremanId,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'invitedMemberIds': invitedMemberIds,
      'maxMembers': maxMembers,
      'isPublic': isPublic,
      'classifications': classifications,
      'jobTypes': jobTypes.map((type) => type.name).toList(),
      'preferredLocals': preferredLocals,
      'homeLocal': homeLocal,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'travelRadius': travelRadius,
      'availableForStormWork': availableForStormWork,
      'availableForEmergencyWork': availableForEmergencyWork,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'currentJobIds': currentJobIds,
      'bidJobIds': bidJobIds,
      'hourlyRate': hourlyRate,
      'perDiemRequirement': perDiemRequirement,
      'allowJobSharing': allowJobSharing,
      'allowInvitations': allowInvitations,
      'communicationChannels': communicationChannels,
      'totalJobs': totalJobs,
      'averageRating': averageRating,
      'completedJobs': completedJobs,
      'lastJobCompletedAt': lastJobCompletedAt != null ? Timestamp.fromDate(lastJobCompletedAt!) : null,
    };
  }

  /// Create a copy with updated fields
  Crew copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? createdBy,
    String? foremanId,
    List<String>? adminIds,
    List<String>? memberIds,
    List<String>? invitedMemberIds,
    int? maxMembers,
    bool? isPublic,
    List<String>? classifications,
    List<JobType>? jobTypes,
    List<String>? preferredLocals,
    String? homeLocal,
    String? location,
    double? latitude,
    double? longitude,
    int? travelRadius,
    bool? availableForStormWork,
    bool? availableForEmergencyWork,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
    List<String>? currentJobIds,
    List<String>? bidJobIds,
    double? hourlyRate,
    String? perDiemRequirement,
    bool? allowJobSharing,
    bool? allowInvitations,
    List<String>? communicationChannels,
    int? totalJobs,
    double? averageRating,
    int? completedJobs,
    DateTime? lastJobCompletedAt,
  }) {
    return Crew(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      foremanId: foremanId ?? this.foremanId,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      invitedMemberIds: invitedMemberIds ?? this.invitedMemberIds,
      maxMembers: maxMembers ?? this.maxMembers,
      isPublic: isPublic ?? this.isPublic,
      classifications: classifications ?? this.classifications,
      jobTypes: jobTypes ?? this.jobTypes,
      preferredLocals: preferredLocals ?? this.preferredLocals,
      homeLocal: homeLocal ?? this.homeLocal,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      travelRadius: travelRadius ?? this.travelRadius,
      availableForStormWork: availableForStormWork ?? this.availableForStormWork,
      availableForEmergencyWork: availableForEmergencyWork ?? this.availableForEmergencyWork,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      currentJobIds: currentJobIds ?? this.currentJobIds,
      bidJobIds: bidJobIds ?? this.bidJobIds,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      perDiemRequirement: perDiemRequirement ?? this.perDiemRequirement,
      allowJobSharing: allowJobSharing ?? this.allowJobSharing,
      allowInvitations: allowInvitations ?? this.allowInvitations,
      communicationChannels: communicationChannels ?? this.communicationChannels,
      totalJobs: totalJobs ?? this.totalJobs,
      averageRating: averageRating ?? this.averageRating,
      completedJobs: completedJobs ?? this.completedJobs,
      lastJobCompletedAt: lastJobCompletedAt ?? this.lastJobCompletedAt,
    );
  }

  /// Validation helpers
  bool get isValid => name.isNotEmpty && createdBy.isNotEmpty;
  bool get isFull => memberIds.length >= maxMembers;
  bool get hasActiveJobs => currentJobIds.isNotEmpty;
  bool get canAcceptInvitations => allowInvitations && !isFull;
  
  /// Member management helpers
  bool isMember(String userId) => memberIds.contains(userId);
  bool isAdmin(String userId) => adminIds.contains(userId) || createdBy == userId;
  bool isForeman(String userId) => foremanId == userId;
  bool isInvited(String userId) => invitedMemberIds.contains(userId);
  
  /// Location helpers
  bool get hasLocation => latitude != null && longitude != null;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Crew && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Crew(id: $id, name: $name, members: ${memberIds.length}/$maxMembers)';
}
