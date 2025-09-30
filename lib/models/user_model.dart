import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String classification;
  final int homeLocal;
  final String role;
  final List<String> crewIds;
  final String email;
  final String? avatarUrl;
  final bool onlineStatus;
  final Timestamp lastActive;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address1;
  final String? address2;
  final String city;
  final String state;
  final int zipcode;
  final String ticketNumber;
  final bool isWorking;
  final bool booksOn;
  final List<String> constructionTypes;
  final int hoursPerWeek;
  final double perDiemRequirement;
  final List<String> preferredLocals;
  final String? fcmToken;
  final String displayName;
  final bool isActive;
  final DateTime? createdTime;
  final List<String> certifications;
  final int yearsExperience;
  final int preferredDistance;
  final String localNumber;

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
    this.booksOn = false,
    this.constructionTypes = const [],
    this.hoursPerWeek = 0,
    this.perDiemRequirement = 0.0,
    this.preferredLocals = const [],
    this.fcmToken,
    this.displayName = '',
    this.isActive = true,
    this.createdTime,
    this.certifications = const [],
    this.yearsExperience = 0,
    this.preferredDistance = 0,
    this.localNumber = '',
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
      booksOn: data['booksOn'] ?? false,
      constructionTypes: List<String>.from(data['constructionTypes'] ?? []),
      hoursPerWeek: data['hoursPerWeek'] ?? 0,
      perDiemRequirement: (data['perDiemRequirement'] ?? 0.0).toDouble(),
      preferredLocals: List<String>.from(data['preferredLocals'] ?? []),
      fcmToken: data['fcmToken'],
      displayName: data['displayName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdTime: data['createdTime'],
      certifications: List<String>.from(data['certifications'] ?? []),
      yearsExperience: data['yearsExperience'] ?? 0,
      preferredDistance: data['preferredDistance'] ?? 0,
      localNumber: data['localNumber'] ?? '',
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
      booksOn: json['booksOn'] ?? false,
      constructionTypes: List<String>.from(json['constructionTypes'] ?? []),
      hoursPerWeek: json['hoursPerWeek'] ?? 0,
      perDiemRequirement: (json['perDiemRequirement'] ?? 0.0).toDouble(),
      preferredLocals: List<String>.from(json['preferredLocals'] ?? []),
      fcmToken: json['fcmToken'],
      displayName: json['displayName'] ?? '',
      isActive: json['isActive'] ?? true,
      createdTime: json['createdTime'] != null ? DateTime.parse(json['createdTime']) : null,
      certifications: List<String>.from(json['certifications'] ?? []),
      yearsExperience: json['yearsExperience'] ?? 0,
      preferredDistance: json['preferredDistance'] ?? 0,
      localNumber: json['localNumber'] ?? '',
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
    };
  }

  bool isValid() {
    return username.isNotEmpty && email.isNotEmpty && classification.isNotEmpty;
  }
}
