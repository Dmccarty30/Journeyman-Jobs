import 'dart:async';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_util.dart';
import 'index.dart';

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
    final data = snapshotData ?? {};
    _localUnion = data['local_union'] as String?;
    _city = data['city'] as String?;
    _state = data['state'] as String?;
    _address = data['address'] as String?;
    _phone = data['phone'] as String?;
    _fax = data['fax'] as String?;
    _email = data['email'] as String?;
    _website = data['website'] as String?;
    _businessManager = data['business_manager'] as String?;
    _president = data['president'] as String?;
    _financialSecretary = data['financial_secretary'] as String?;
    _recordingSecretary = data['recording_secretary'] as String?;
    _meetingSchedule = data['meeting_schedule'] as String?;
    _initialSign = data['initial_sign'] as String?;
    _reSign = data['re_sign'] as String?;
    _reSignProcedure = data['re_sign_procedure'] as String?;
    _classification = data['classification'] as String?;
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
  Map<String, dynamic> createData() {
    return {
      if (_localUnion != null) 'local_union': _localUnion,
      if (_city != null) 'city': _city,
      if (_state != null) 'state': _state,
      if (_address != null) 'address': _address,
      if (_phone != null) 'phone': _phone,
      if (_fax != null) 'fax': _fax,
      if (_email != null) 'email': _email,
      if (_website != null) 'website': _website,
      if (_businessManager != null) 'business_manager': _businessManager,
      if (_president != null) 'president': _president,
      if (_financialSecretary != null) 'financial_secretary': _financialSecretary,
      if (_recordingSecretary != null) 'recording_secretary': _recordingSecretary,
      if (_meetingSchedule != null) 'meeting_schedule': _meetingSchedule,
      if (_initialSign != null) 'initial_sign': _initialSign,
      if (_reSign != null) 're_sign': _reSign,
      if (_reSignProcedure != null) 're_sign_procedure': _reSignProcedure,
      if (_classification != null) 'classification': _classification,
    }.withoutNulls;
  }

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
    }
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
