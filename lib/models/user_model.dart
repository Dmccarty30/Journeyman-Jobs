import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model for IBEW Electrical Workers
/// 
/// Represents a complete user profile for the Journeyman Jobs app,
/// including personal information, professional details, and preferences.
class UserModel {
  /// Unique user identifier (Firebase Auth UID)
  final String uid;
  
  /// Personal Information
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  
  /// Profile Information
  final String? photoUrl;
  
  /// Address Information
  final String address1;
  final String? address2;
  final String city;
  final String state;
  final String zipcode;
  
  /// Professional Details
  final String homeLocal;
  final String ticketNumber;
  final String classification;
  final bool isWorking;
  final String? booksOn;
  
  /// Job Preferences
  final List<String> constructionTypes;
  final String? hoursPerWeek;
  final String? perDiemRequirement;
  final String? preferredLocals;
  
  /// Career Goals
  final bool networkWithOthers;
  final bool careerAdvancements;
  final bool betterBenefits;
  final bool higherPayRate;
  final bool learnNewSkill;
  final bool travelToNewLocation;
  final bool findLongTermWork;
  final String? careerGoals;
  
  /// App Experience
  final String? howHeardAboutUs;
  final String? lookingToAccomplish;
  
  /// System Fields
  final String onboardingStatus;
  final DateTime createdTime;
  final DateTime? updatedTime;

  const UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.photoUrl,
    required this.address1,
    this.address2,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.homeLocal,
    required this.ticketNumber,
    required this.classification,
    required this.isWorking,
    this.booksOn,
    required this.constructionTypes,
    this.hoursPerWeek,
    this.perDiemRequirement,
    this.preferredLocals,
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
    required this.onboardingStatus,
    required this.createdTime,
    this.updatedTime,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name (alias for fullName)
  String get displayName => fullName;

  /// Get formatted address
  String get fullAddress {
    final address = address2?.isNotEmpty == true 
        ? '$address1, $address2' 
        : address1;
    return '$address, $city, $state $zipcode';
  }

  /// Check if onboarding is complete
  bool get isOnboardingComplete => onboardingStatus == 'completed';

  /// Convert to Firestore document data
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'homeLocal': homeLocal,
      'ticketNumber': ticketNumber,
      'classification': classification,
      'isWorking': isWorking,
      'booksOn': booksOn,
      'constructionTypes': constructionTypes,
      'hoursPerWeek': hoursPerWeek,
      'perDiemRequirement': perDiemRequirement,
      'preferredLocals': preferredLocals,
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
      'createdTime': createdTime.toIso8601String(),
      'updatedTime': updatedTime?.toIso8601String(),
    };
  }

  /// Create from Firestore document data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      address1: json['address1'] as String,
      address2: json['address2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      zipcode: json['zipcode'] as String,
      homeLocal: json['homeLocal'] as String,
      ticketNumber: json['ticketNumber'] as String,
      classification: json['classification'] as String,
      isWorking: json['isWorking'] as bool,
      booksOn: json['booksOn'] as String?,
      constructionTypes: List<String>.from(json['constructionTypes'] as List),
      hoursPerWeek: json['hoursPerWeek'] as String?,
      perDiemRequirement: json['perDiemRequirement'] as String?,
      preferredLocals: json['preferredLocals'] as String?,
      networkWithOthers: json['networkWithOthers'] as bool,
      careerAdvancements: json['careerAdvancements'] as bool,
      betterBenefits: json['betterBenefits'] as bool,
      higherPayRate: json['higherPayRate'] as bool,
      learnNewSkill: json['learnNewSkill'] as bool,
      travelToNewLocation: json['travelToNewLocation'] as bool,
      findLongTermWork: json['findLongTermWork'] as bool,
      careerGoals: json['careerGoals'] as String?,
      howHeardAboutUs: json['howHeardAboutUs'] as String?,
      lookingToAccomplish: json['lookingToAccomplish'] as String?,
      onboardingStatus: json['onboardingStatus'] as String,
      createdTime: DateTime.parse(json['createdTime'] as String),
      updatedTime: json['updatedTime'] != null 
          ? DateTime.parse(json['updatedTime'] as String) 
          : null,
    );
  }

  /// Create from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'uid': doc.id,
      ...data,
    });
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipcode,
    String? homeLocal,
    String? ticketNumber,
    String? classification,
    bool? isWorking,
    String? booksOn,
    List<String>? constructionTypes,
    String? hoursPerWeek,
    String? perDiemRequirement,
    String? preferredLocals,
    bool? networkWithOthers,
    bool? careerAdvancements,
    bool? betterBenefits,
    bool? higherPayRate,
    bool? learnNewSkill,
    bool? travelToNewLocation,
    bool? findLongTermWork,
    String? careerGoals,
    String? howHeardAboutUs,
    String? lookingToAccomplish,
    String? onboardingStatus,
    DateTime? createdTime,
    DateTime? updatedTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipcode: zipcode ?? this.zipcode,
      homeLocal: homeLocal ?? this.homeLocal,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      classification: classification ?? this.classification,
      isWorking: isWorking ?? this.isWorking,
      booksOn: booksOn ?? this.booksOn,
      constructionTypes: constructionTypes ?? this.constructionTypes,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      perDiemRequirement: perDiemRequirement ?? this.perDiemRequirement,
      preferredLocals: preferredLocals ?? this.preferredLocals,
      networkWithOthers: networkWithOthers ?? this.networkWithOthers,
      careerAdvancements: careerAdvancements ?? this.careerAdvancements,
      betterBenefits: betterBenefits ?? this.betterBenefits,
      higherPayRate: higherPayRate ?? this.higherPayRate,
      learnNewSkill: learnNewSkill ?? this.learnNewSkill,
      travelToNewLocation: travelToNewLocation ?? this.travelToNewLocation,
      findLongTermWork: findLongTermWork ?? this.findLongTermWork,
      careerGoals: careerGoals ?? this.careerGoals,
      howHeardAboutUs: howHeardAboutUs ?? this.howHeardAboutUs,
      lookingToAccomplish: lookingToAccomplish ?? this.lookingToAccomplish,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $fullName, local: $homeLocal)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

/// Classification options for IBEW workers
class Classification {
  static const String journeymanLineman = 'Journeyman Lineman';
  static const String journeymanElectrician = 'Journeyman Electrician';
  static const String journeymanWireman = 'Journeyman Wireman';
  static const String journeymanTreeTrimmer = 'Journeyman Tree Trimmer';
  static const String operator = 'Operator';

  static const List<String> all = [
    journeymanLineman,
    journeymanElectrician,
    journeymanWireman,
    journeymanTreeTrimmer,
    operator,
  ];
}

/// Construction type options
class ConstructionType {
  static const String distribution = 'Distribution';
  static const String transmission = 'Transmission';
  static const String subStation = 'SubStation';
  static const String residential = 'Residential';
  static const String industrial = 'Industrial';
  static const String dataCenter = 'Data Center';
  static const String commercial = 'Commercial';
  static const String underground = 'Underground';

  static const List<String> all = [
    distribution,
    transmission,
    subStation,
    residential,
    industrial,
    dataCenter,
    commercial,
    underground,
  ];
}

/// Onboarding status options
class OnboardingStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
}