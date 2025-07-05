import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LocalsRecord extends FirestoreRecord {
  LocalsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "local_union" field.
  String? _localUnion;
  String get localUnion => _localUnion ?? '';
  bool hasLocalUnion() => _localUnion != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "state" field.
  String? _state;
  String get state => _state ?? '';
  bool hasState() => _state != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "fax" field.
  String? _fax;
  String get fax => _fax ?? '';
  bool hasFax() => _fax != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "website" field.
  String? _website;
  String get website => _website ?? '';
  bool hasWebsite() => _website != null;

  // "business_manager" field.
  String? _businessManager;
  String get businessManager => _businessManager ?? '';
  bool hasBusinessManager() => _businessManager != null;

  // "president" field.
  String? _president;
  String get president => _president ?? '';
  bool hasPresident() => _president != null;

  // "financial_secretary" field.
  String? _financialSecretary;
  String get financialSecretary => _financialSecretary ?? '';
  bool hasFinancialSecretary() => _financialSecretary != null;

  // "recording_secretary" field.
  String? _recordingSecretary;
  String get recordingSecretary => _recordingSecretary ?? '';
  bool hasRecordingSecretary() => _recordingSecretary != null;

  // "meeting_schedule" field.
  String? _meetingSchedule;
  String get meetingSchedule => _meetingSchedule ?? '';
  bool hasMeetingSchedule() => _meetingSchedule != null;

  // "initial_sign" field.
  String? _initialSign;
  String get initialSign => _initialSign ?? '';
  bool hasInitialSign() => _initialSign != null;

  // "re_sign" field.
  String? _reSign;
  String get reSign => _reSign ?? '';
  bool hasReSign() => _reSign != null;

  // "re_sign_procedure" field.
  String? _reSignProcedure;
  String get reSignProcedure => _reSignProcedure ?? '';
  bool hasReSignProcedure() => _reSignProcedure != null;

  // "classification" field.
  String? _classification;
  String get classification => _classification ?? '';
  bool hasClassification() => _classification != null;

  void _initializeFields() {
    _localUnion = snapshotData['local_union'] as String?;
    _city = snapshotData['city'] as String?;
    _state = snapshotData['state'] as String?;
    _address = snapshotData['address'] as String?;
    _phone = snapshotData['phone'] as String?;
    _fax = snapshotData['fax'] as String?;
    _email = snapshotData['email'] as String?;
    _website = snapshotData['website'] as String?;
    _businessManager = snapshotData['business_manager'] as String?;
    _president = snapshotData['president'] as String?;
    _financialSecretary = snapshotData['financial_secretary'] as String?;
    _recordingSecretary = snapshotData['recording_secretary'] as String?;
    _meetingSchedule = snapshotData['meeting_schedule'] as String?;
    _initialSign = snapshotData['initial_sign'] as String?;
    _reSign = snapshotData['re_sign'] as String?;
    _reSignProcedure = snapshotData['re_sign_procedure'] as String?;
    _classification = snapshotData['classification'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('locals');

  static Stream<LocalsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LocalsRecord.fromSnapshot(s));

  static Future<LocalsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LocalsRecord.fromSnapshot(s));

  static LocalsRecord fromSnapshot(DocumentSnapshot snapshot) => LocalsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LocalsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LocalsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LocalsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LocalsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLocalsRecordData({
  String? localUnion,
  String? city,
  String? state,
  String? address,
  String? phone,
  String? fax,
  String? email,
  String? website,
  String? businessManager,
  String? president,
  String? financialSecretary,
  String? recordingSecretary,
  String? meetingSchedule,
  String? initialSign,
  String? reSign,
  String? reSignProcedure,
  String? classification,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'local_union': localUnion,
      'city': city,
      'state': state,
      'address': address,
      'phone': phone,
      'fax': fax,
      'email': email,
      'website': website,
      'business_manager': businessManager,
      'president': president,
      'financial_secretary': financialSecretary,
      'recording_secretary': recordingSecretary,
      'meeting_schedule': meetingSchedule,
      'initial_sign': initialSign,
      're_sign': reSign,
      're_sign_procedure': reSignProcedure,
      'classification': classification,
    }.withoutNulls,
  );

  return firestoreData;
}

class LocalsRecordDocumentEquality implements Equality<LocalsRecord> {
  const LocalsRecordDocumentEquality();

  @override
  bool equals(LocalsRecord? e1, LocalsRecord? e2) {
    return e1?.localUnion == e2?.localUnion &&
        e1?.city == e2?.city &&
        e1?.state == e2?.state &&
        e1?.address == e2?.address &&
        e1?.phone == e2?.phone &&
        e1?.fax == e2?.fax &&
        e1?.email == e2?.email &&
        e1?.website == e2?.website &&
        e1?.businessManager == e2?.businessManager &&
        e1?.president == e2?.president &&
        e1?.financialSecretary == e2?.financialSecretary &&
        e1?.recordingSecretary == e2?.recordingSecretary &&
        e1?.meetingSchedule == e2?.meetingSchedule &&
        e1?.initialSign == e2?.initialSign &&
        e1?.reSign == e2?.reSign &&
        e1?.reSignProcedure == e2?.reSignProcedure &&
        e1?.classification == e2?.classification;
  }

  @override
  int hash(LocalsRecord? e) => const ListEquality().hash([
        e?.localUnion,
        e?.city,
        e?.state,
        e?.address,
        e?.phone,
        e?.fax,
        e?.email,
        e?.website,
        e?.businessManager,
        e?.president,
        e?.financialSecretary,
        e?.recordingSecretary,
        e?.meetingSchedule,
        e?.initialSign,
        e?.reSign,
        e?.reSignProcedure,
        e?.classification
      ]);

  @override
  bool isValidKey(Object? o) => o is LocalsRecord;
}
