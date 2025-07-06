import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/firestore_util.dart';
import '/backend/schema/enums/enums.dart';
import '/utils/lat_lng.dart';

import 'index.dart';
import '/utils/lat_lng.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    // Initialize other fields similarly as needed
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "first_name" field.
  String? _firstName;
  String get firstName => _firstName ?? '';
  bool hasFirstName() => _firstName != null;

  // "last_name" field.
  String? _lastName;
  String get lastName => _lastName ?? '';
  bool hasLastName() => _lastName != null;

  // "address1" field.
  String? _address1;
  String get address1 => _address1 ?? '';
  bool hasAddress1() => _address1 != null;

  // "address2" field.
  String? _address2;
  String get address2 => _address2 ?? '';
  bool hasAddress2() => _address2 != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "state" field.
  String? _state;
  String get state => _state ?? '';
  bool hasState() => _state != null;

  // "zipcode" field.
  int? _zipcode;
  int get zipcode => _zipcode ?? 0;
  bool hasZipcode() => _zipcode != null;

  // "home_local" field.
  int? _homeLocal;
  int get homeLocal => _homeLocal ?? 0;
  bool hasHomeLocal() => _homeLocal != null;

  // "ticket_number" field.
  int? _ticketNumber;
  int get ticketNumber => _ticketNumber ?? 0;
  bool hasTicketNumber() => _ticketNumber != null;

  // "is_working" field.
  bool? _isWorking;
  bool get isWorking => _isWorking ?? false;
  bool hasIsWorking() => _isWorking != null;

  // "ai_widget_enabled" field.
  bool? _aiWidgetEnabled;
  bool get aiWidgetEnabled => _aiWidgetEnabled ?? false;
  bool hasAiWidgetEnabled() => _aiWidgetEnabled != null;

  // "classification" field.
  Classification? _classification;
  Classification? get classification => _classification;
  bool hasClassification() => _classification != null;

  // "networkWithOthers" field.
  bool? _networkWithOthers;
  bool get networkWithOthers => _networkWithOthers ?? false;
  bool hasNetworkWithOthers() => _networkWithOthers != null;

  // "careerAdvancements" field.
  bool? _careerAdvancements;
  bool get careerAdvancements => _careerAdvancements ?? false;
  bool hasCareerAdvancements() => _careerAdvancements != null;

  // "betterBenefits" field.
  bool? _betterBenefits;
  bool get betterBenefits => _betterBenefits ?? false;
  bool hasBetterBenefits() => _betterBenefits != null;

  // "higherPayRate" field.
  bool? _higherPayRate;
  bool get higherPayRate => _higherPayRate ?? false;
  bool hasHigherPayRate() => _higherPayRate != null;

  // "learnNewSkill" field.
  bool? _learnNewSkill;
  bool get learnNewSkill => _learnNewSkill ?? false;
  bool hasLearnNewSkill() => _learnNewSkill != null;

  // "travelToNewLocation" field.
  bool? _travelToNewLocation;
  bool get travelToNewLocation => _travelToNewLocation ?? false;
  bool hasTravelToNewLocation() => _travelToNewLocation != null;

  // "findLongTermWork" field.
  bool? _findLongTermWork;
  bool get findLongTermWork => _findLongTermWork ?? false;
  bool hasFindLongTermWork() => _findLongTermWork != null;

  // "onboardingStatus" field.
  String? _onboardingStatus;
  String get onboardingStatus => _onboardingStatus ?? '';
  bool hasOnboardingStatus() => _onboardingStatus != null;

  // "constructionTypes" field (multi-select).
  List<String>? _constructionTypes;
  List<String> get constructionTypes => _constructionTypes ?? const [];
  bool hasConstructionTypes() => _constructionTypes != null && _constructionTypes!.isNotEmpty;

  // "on_books" field.
  String? _onBooks;
  String get onBooks => _onBooks ?? '';
  bool hasOnBooks() => _onBooks != null;

  // "preferred_local1" field.
  String? _preferredLocal1;
  String get preferredLocal1 => _preferredLocal1 ?? '';
  bool hasPreferredLocal1() => _preferredLocal1 != null;

  // "preferred_local2" field.
  String? _preferredLocal2;
  String get preferredLocal2 => _preferredLocal2 ?? '';
  bool hasPreferredLocal2() => _preferredLocal2 != null;

  // "preferred_local3" field.
  String? _preferredLocal3;
  String get preferredLocal3 => _preferredLocal3 ?? '';
  bool hasPreferredLocal3() => _preferredLocal3 != null;

  // "careerGoals" field.
  String? _careerGoals;
  String get careerGoals => _careerGoals ?? '';
  bool hasCareerGoals() => _careerGoals != null;

  // "aboutUs" field.
  String? _aboutUs;
  String get aboutUs => _aboutUs ?? '';
  bool hasAboutUs() => _aboutUs != null;

  // "lookingToAccomplish" field.
  String? _lookingToAccomplish;
  String get lookingToAccomplish => _lookingToAccomplish ?? '';
  bool hasLookingToAccomplish() => _lookingToAccomplish != null;

  // "min_hourly_rate" field.
  double? _minHourlyRate;
  double get minHourlyRate => _minHourlyRate ?? 0.0;
  bool hasMinHourlyRate() => _minHourlyRate != null;

  // "max_hourly_rate" field.
  double? _maxHourlyRate;
  double get maxHourlyRate => _maxHourlyRate ?? 0.0;
  bool hasMaxHourlyRate() => _maxHourlyRate != null;



  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  Map<String, dynamic> createData() {
    return {
      if (_email != null) 'email': _email,
      if (_displayName != null) 'display_name': _displayName,
      if (_photoUrl != null) 'photo_url': _photoUrl,
      if (_uid != null) 'uid': _uid,
      if (_createdTime != null) 'created_time': _createdTime,
      if (_phoneNumber != null) 'phone_number': _phoneNumber,
      if (_firstName != null) 'first_name': _firstName,
      if (_lastName != null) 'last_name': _lastName,
      if (_address1 != null) 'address1': _address1,
      if (_address2 != null) 'address2': _address2,
      if (_city != null) 'city': _city,
      if (_state != null) 'state': _state,
      if (_zipcode != null) 'zipcode': _zipcode,
      if (_homeLocal != null) 'home_local': _homeLocal,
      if (_ticketNumber != null) 'ticket_number': _ticketNumber,
      if (_isWorking != null) 'is_working': _isWorking,
      if (_aiWidgetEnabled != null) 'ai_widget_enabled': _aiWidgetEnabled,
      if (_classification != null) 'classification': serializeEnum(_classification),
      if (_networkWithOthers != null) 'networkWithOthers': _networkWithOthers,
      if (_careerAdvancements != null) 'careerAdvancements': _careerAdvancements,
      if (_betterBenefits != null) 'betterBenefits': _betterBenefits,
      if (_higherPayRate != null) 'higherPayRate': _higherPayRate,
      if (_learnNewSkill != null) 'learnNewSkill': _learnNewSkill,
      if (_travelToNewLocation != null) 'travelToNewLocation': _travelToNewLocation,
      if (_findLongTermWork != null) 'findLongTermWork': _findLongTermWork,
      if (_onboardingStatus != null) 'onboardingStatus': _onboardingStatus,
      if (_constructionTypes != null) 'constructionTypes': _constructionTypes,
      if (_onBooks != null) 'on_books': _onBooks,
      if (_preferredLocal1 != null) 'preferred_local1': _preferredLocal1,
      if (_preferredLocal2 != null) 'preferred_local2': _preferredLocal2,
      if (_preferredLocal3 != null) 'preferred_local3': _preferredLocal3,
      if (_careerGoals != null) 'careerGoals': _careerGoals,
      if (_aboutUs != null) 'aboutUs': _aboutUs,
      if (_lookingToAccomplish != null) 'lookingToAccomplish': _lookingToAccomplish,
      if (_minHourlyRate != null) 'min_hourly_rate': _minHourlyRate,
      if (_maxHourlyRate != null) 'max_hourly_rate': _maxHourlyRate,
    }.withoutNulls;
  }

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? firstName,
  String? lastName,
  String? address1,
  String? address2,
  String? city,
  String? state,
  int? zipcode,
  int? homeLocal,
  int? ticketNumber,
  bool? isWorking,
  bool? aiWidgetEnabled,
  Classification? classification,
  bool? networkWithOthers,
  bool? careerAdvancements,
  bool? betterBenefits,
  bool? higherPayRate,
  bool? learnNewSkill,
  bool? travelToNewLocation,
  bool? findLongTermWork,
  String? onboardingStatus,
  List<String>? constructionTypes,
  String? onBooks,
  String? preferredLocal1,
  String? preferredLocal2,
  String? preferredLocal3,
  String? careerGoals,
  String? aboutUs,
  String? lookingToAccomplish,
  double? minHourlyRate,
  double? maxHourlyRate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'home_local': homeLocal,
      'ticket_number': ticketNumber,
      'is_working': isWorking,
      'ai_widget_enabled': aiWidgetEnabled,
      'classification': classification,
      'networkWithOthers': networkWithOthers,
      'careerAdvancements': careerAdvancements,
      'betterBenefits': betterBenefits,
      'higherPayRate': higherPayRate,
      'learnNewSkill': learnNewSkill,
      'travelToNewLocation': travelToNewLocation,
      'findLongTermWork': findLongTermWork,
      'onboardingStatus': onboardingStatus,
      'constructionTypes': constructionTypes,
      'on_books': onBooks,
      'preferred_local1': preferredLocal1,
      'preferred_local2': preferredLocal2,
      'preferred_local3': preferredLocal3,
      'careerGoals': careerGoals,
      'aboutUs': aboutUs,
      'lookingToAccomplish': lookingToAccomplish,
      'min_hourly_rate': minHourlyRate,
      'max_hourly_rate': maxHourlyRate,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.firstName == e2?.firstName &&
        e1?.lastName == e2?.lastName &&
        e1?.address1 == e2?.address1 &&
        e1?.address2 == e2?.address2 &&
        e1?.city == e2?.city &&
        e1?.state == e2?.state &&
        e1?.zipcode == e2?.zipcode &&
        e1?.homeLocal == e2?.homeLocal &&
        e1?.ticketNumber == e2?.ticketNumber &&
        e1?.isWorking == e2?.isWorking &&
        e1?.aiWidgetEnabled == e2?.aiWidgetEnabled &&
        e1?.classification == e2?.classification &&
        e1?.networkWithOthers == e2?.networkWithOthers &&
        e1?.careerAdvancements == e2?.careerAdvancements &&
        e1?.betterBenefits == e2?.betterBenefits &&
        e1?.higherPayRate == e2?.higherPayRate &&
        e1?.learnNewSkill == e2?.learnNewSkill &&
        e1?.travelToNewLocation == e2?.travelToNewLocation &&
        e1?.findLongTermWork == e2?.findLongTermWork &&
        e1?.onboardingStatus == e2?.onboardingStatus &&
        const ListEquality().equals(e1?.constructionTypes, e2?.constructionTypes) &&
        e1?.onBooks == e2?.onBooks &&
        e1?.preferredLocal1 == e2?.preferredLocal1 &&
        e1?.preferredLocal2 == e2?.preferredLocal2 &&
        e1?.preferredLocal3 == e2?.preferredLocal3 &&
        e1?.careerGoals == e2?.careerGoals &&
        e1?.aboutUs == e2?.aboutUs &&
        e1?.lookingToAccomplish == e2?.lookingToAccomplish &&
        e1?.minHourlyRate == e2?.minHourlyRate &&
        e1?.maxHourlyRate == e2?.maxHourlyRate;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.firstName,
        e?.lastName,
        e?.address1,
        e?.address2,
        e?.city,
        e?.state,
        e?.zipcode,
        e?.homeLocal,
        e?.ticketNumber,
        e?.isWorking,
        e?.aiWidgetEnabled,
        e?.classification,
        e?.networkWithOthers,
        e?.careerAdvancements,
        e?.betterBenefits,
        e?.higherPayRate,
        e?.learnNewSkill,
        e?.travelToNewLocation,
        e?.findLongTermWork,
        e?.onboardingStatus,
        e?.constructionTypes,
        e?.onBooks,
        e?.preferredLocal1,
        e?.preferredLocal2,
        e?.preferredLocal3,
        e?.careerGoals,
        e?.aboutUs,
        e?.lookingToAccomplish,
        e?.minHourlyRate,
        e?.maxHourlyRate
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
