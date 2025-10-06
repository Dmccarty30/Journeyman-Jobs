import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/domain/enums/onboarding_status.dart';

/// A comprehensive data model representing an application user.
///
/// It includes personal information, professional details, job preferences,
/// and app-specific settings.
class UserModel {
  /// The unique identifier for the user, typically from Firebase Auth.
  final String uid;
  /// The user's chosen username.
  final String username;
  /// The user's primary IBEW classification (e.g., 'Journeyman Lineman').
  final String classification;
  /// The user's home IBEW local union number.
  final int homeLocal;
  /// The user's role within the app (e.g., 'journeyman', 'foreman', 'admin').
  final String role;
  /// A list of IDs for the crews the user is a member of.
  final List<String> crewIds;
  /// The user's email address.
  final String email;
  /// The URL for the user's profile picture.
  final String? avatarUrl;
  /// A boolean indicating if the user is currently online.
  final bool onlineStatus;
  /// A timestamp of the user's last activity.
  final Timestamp lastActive;
  /// The user's first name.
  final String firstName;
  /// The user's last name.
  final String lastName;
  /// The user's phone number.
  final String phoneNumber;
  /// The first line of the user's address.
  final String address1;
  /// The second line of the user's address.
  final String? address2;
  /// The city of the user's address.
  final String city;
  /// The state of the user's address.
  final String state;
  /// The postal code of the user's address.
  final int zipcode;
  /// The user's IBEW ticket or card number.
  final String ticketNumber;
  /// A flag indicating if the user is currently employed.
  final bool isWorking;
  /// A string indicating which union books the user is signed on.
  final String? booksOn;
  /// A list of construction types the user is interested in.
  final List<String> constructionTypes;
  /// The user's preferred number of hours per week.
  final String? hoursPerWeek;
  /// The user's requirement for per diem.
  final String? perDiemRequirement;
  /// A string listing the user's preferred IBEW locals to work out of.
  final String? preferredLocals;
  /// The Firebase Cloud Messaging token for push notifications.
  final String? fcmToken;
  /// The user's display name, which might differ from their full name.
  final String displayName;
  /// A flag indicating if the user's account is active.
  final bool isActive;
  /// The timestamp when the user account was created.
  final DateTime? createdTime;
  /// A list of the user's professional certifications.
  final List<String> certifications;
  /// The user's years of experience in their trade.
  final int yearsExperience;
  /// The maximum distance the user is willing to travel for work.
  final int preferredDistance;
  /// The user's IBEW local number (potentially redundant with `homeLocal`).
  final String localNumber;
  /// A career goal flag for networking.
  final bool networkWithOthers;
  /// A career goal flag for seeking advancements.
  final bool careerAdvancements;
  /// A career goal flag for finding better benefits.
  final bool betterBenefits;
  /// A career goal flag for seeking higher pay.
  final bool higherPayRate;
  /// A career goal flag for learning new skills.
  final bool learnNewSkill;
  /// A career goal flag for traveling.
  final bool travelToNewLocation;
  /// A career goal flag for finding long-term employment.
  final bool findLongTermWork;
  /// A free-text field for other career goals.
  final String? careerGoals;
  /// How the user heard about the app.
  final String? howHeardAboutUs;
  /// What the user is looking to accomplish with the app.
  final String? lookingToAccomplish;
  /// The user's current status in the onboarding process.
  final OnboardingStatus? onboardingStatus;

  /// Creates an instance of [UserModel].
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
  });

  /// A computed property that returns the `displayName` if available,
  /// otherwise constructs a full name from `firstName` and `lastName`.
  String get displayNameStr => displayName.isEmpty ? '$firstName $lastName'.trim() : displayName;

  /// A getter for the `isActive` status.
  bool get isActiveGetter => isActive;

  /// Creates a [UserModel] instance from a Firestore [DocumentSnapshot].
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
      lastActive: data['lastActive'] ?? Timestamp.now(),
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
      createdTime: data['createdTime'],
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
    );
  }

  /// Creates a [UserModel] instance from a JSON map.
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
      lastActive: Timestamp.fromDate(DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String())),
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
    );
  }

  /// Converts the [UserModel] instance to a JSON map, suitable for serialization.
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
      'lastActive': lastActive.toDate().toIso8601String(),
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
    };
  }

  /// Converts the [UserModel] instance to a map suitable for writing to Firestore.
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
      'lastActive': lastActive,
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
      'createdTime': createdTime,
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
    };
  }

  /// Checks if the user model has the minimum required data to be considered valid.
  bool isValid() {
    return username.isNotEmpty && email.isNotEmpty && classification.isNotEmpty;
  }
}
