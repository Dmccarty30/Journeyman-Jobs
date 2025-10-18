// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnifiedJobModel {

 String get id; DocumentReference? get reference; String get sharerId; Map<String, dynamic> get jobDetails; bool get matchesCriteria; bool get deleted; int? get local; String? get classification; String get company; String get location;@JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper) GeoPoint? get geoPoint; int? get hours; double? get wage; String? get sub; String? get jobClass; int? get localNumber; String? get qualifications; String? get datePosted; String? get jobDescription; String? get jobTitle; String? get perDiem; String? get agreement; String? get numberOfJobs;@JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper) DateTime? get timestamp; String? get startDate; String? get startTime; List<int>? get booksYourOn; String? get typeOfWork; String? get duration; String? get voltageLevel; List<String>? get certifications; bool get isSaved; bool get isApplied;
/// Create a copy of UnifiedJobModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnifiedJobModelCopyWith<UnifiedJobModel> get copyWith => _$UnifiedJobModelCopyWithImpl<UnifiedJobModel>(this as UnifiedJobModel, _$identity);

  /// Serializes this UnifiedJobModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnifiedJobModel&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.sharerId, sharerId) || other.sharerId == sharerId)&&const DeepCollectionEquality().equals(other.jobDetails, jobDetails)&&(identical(other.matchesCriteria, matchesCriteria) || other.matchesCriteria == matchesCriteria)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.local, local) || other.local == local)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.geoPoint, geoPoint) || other.geoPoint == geoPoint)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.wage, wage) || other.wage == wage)&&(identical(other.sub, sub) || other.sub == sub)&&(identical(other.jobClass, jobClass) || other.jobClass == jobClass)&&(identical(other.localNumber, localNumber) || other.localNumber == localNumber)&&(identical(other.qualifications, qualifications) || other.qualifications == qualifications)&&(identical(other.datePosted, datePosted) || other.datePosted == datePosted)&&(identical(other.jobDescription, jobDescription) || other.jobDescription == jobDescription)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.perDiem, perDiem) || other.perDiem == perDiem)&&(identical(other.agreement, agreement) || other.agreement == agreement)&&(identical(other.numberOfJobs, numberOfJobs) || other.numberOfJobs == numberOfJobs)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&const DeepCollectionEquality().equals(other.booksYourOn, booksYourOn)&&(identical(other.typeOfWork, typeOfWork) || other.typeOfWork == typeOfWork)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.voltageLevel, voltageLevel) || other.voltageLevel == voltageLevel)&&const DeepCollectionEquality().equals(other.certifications, certifications)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isApplied, isApplied) || other.isApplied == isApplied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,sharerId,const DeepCollectionEquality().hash(jobDetails),matchesCriteria,deleted,local,classification,company,location,geoPoint,hours,wage,sub,jobClass,localNumber,qualifications,datePosted,jobDescription,jobTitle,perDiem,agreement,numberOfJobs,timestamp,startDate,startTime,const DeepCollectionEquality().hash(booksYourOn),typeOfWork,duration,voltageLevel,const DeepCollectionEquality().hash(certifications),isSaved,isApplied]);

@override
String toString() {
  return 'UnifiedJobModel(id: $id, reference: $reference, sharerId: $sharerId, jobDetails: $jobDetails, matchesCriteria: $matchesCriteria, deleted: $deleted, local: $local, classification: $classification, company: $company, location: $location, geoPoint: $geoPoint, hours: $hours, wage: $wage, sub: $sub, jobClass: $jobClass, localNumber: $localNumber, qualifications: $qualifications, datePosted: $datePosted, jobDescription: $jobDescription, jobTitle: $jobTitle, perDiem: $perDiem, agreement: $agreement, numberOfJobs: $numberOfJobs, timestamp: $timestamp, startDate: $startDate, startTime: $startTime, booksYourOn: $booksYourOn, typeOfWork: $typeOfWork, duration: $duration, voltageLevel: $voltageLevel, certifications: $certifications, isSaved: $isSaved, isApplied: $isApplied)';
}


}

/// @nodoc
abstract mixin class $UnifiedJobModelCopyWith<$Res>  {
  factory $UnifiedJobModelCopyWith(UnifiedJobModel value, $Res Function(UnifiedJobModel) _then) = _$UnifiedJobModelCopyWithImpl;
@useResult
$Res call({
 String id, DocumentReference? reference, String sharerId, Map<String, dynamic> jobDetails, bool matchesCriteria, bool deleted, int? local, String? classification, String company, String location,@JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper) GeoPoint? geoPoint, int? hours, double? wage, String? sub, String? jobClass, int? localNumber, String? qualifications, String? datePosted, String? jobDescription, String? jobTitle, String? perDiem, String? agreement, String? numberOfJobs,@JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper) DateTime? timestamp, String? startDate, String? startTime, List<int>? booksYourOn, String? typeOfWork, String? duration, String? voltageLevel, List<String>? certifications, bool isSaved, bool isApplied
});




}
/// @nodoc
class _$UnifiedJobModelCopyWithImpl<$Res>
    implements $UnifiedJobModelCopyWith<$Res> {
  _$UnifiedJobModelCopyWithImpl(this._self, this._then);

  final UnifiedJobModel _self;
  final $Res Function(UnifiedJobModel) _then;

/// Create a copy of UnifiedJobModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? sharerId = null,Object? jobDetails = null,Object? matchesCriteria = null,Object? deleted = null,Object? local = freezed,Object? classification = freezed,Object? company = null,Object? location = null,Object? geoPoint = freezed,Object? hours = freezed,Object? wage = freezed,Object? sub = freezed,Object? jobClass = freezed,Object? localNumber = freezed,Object? qualifications = freezed,Object? datePosted = freezed,Object? jobDescription = freezed,Object? jobTitle = freezed,Object? perDiem = freezed,Object? agreement = freezed,Object? numberOfJobs = freezed,Object? timestamp = freezed,Object? startDate = freezed,Object? startTime = freezed,Object? booksYourOn = freezed,Object? typeOfWork = freezed,Object? duration = freezed,Object? voltageLevel = freezed,Object? certifications = freezed,Object? isSaved = null,Object? isApplied = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as DocumentReference?,sharerId: null == sharerId ? _self.sharerId : sharerId // ignore: cast_nullable_to_non_nullable
as String,jobDetails: null == jobDetails ? _self.jobDetails : jobDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,matchesCriteria: null == matchesCriteria ? _self.matchesCriteria : matchesCriteria // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as int?,classification: freezed == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String?,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,geoPoint: freezed == geoPoint ? _self.geoPoint : geoPoint // ignore: cast_nullable_to_non_nullable
as GeoPoint?,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as int?,wage: freezed == wage ? _self.wage : wage // ignore: cast_nullable_to_non_nullable
as double?,sub: freezed == sub ? _self.sub : sub // ignore: cast_nullable_to_non_nullable
as String?,jobClass: freezed == jobClass ? _self.jobClass : jobClass // ignore: cast_nullable_to_non_nullable
as String?,localNumber: freezed == localNumber ? _self.localNumber : localNumber // ignore: cast_nullable_to_non_nullable
as int?,qualifications: freezed == qualifications ? _self.qualifications : qualifications // ignore: cast_nullable_to_non_nullable
as String?,datePosted: freezed == datePosted ? _self.datePosted : datePosted // ignore: cast_nullable_to_non_nullable
as String?,jobDescription: freezed == jobDescription ? _self.jobDescription : jobDescription // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,perDiem: freezed == perDiem ? _self.perDiem : perDiem // ignore: cast_nullable_to_non_nullable
as String?,agreement: freezed == agreement ? _self.agreement : agreement // ignore: cast_nullable_to_non_nullable
as String?,numberOfJobs: freezed == numberOfJobs ? _self.numberOfJobs : numberOfJobs // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,booksYourOn: freezed == booksYourOn ? _self.booksYourOn : booksYourOn // ignore: cast_nullable_to_non_nullable
as List<int>?,typeOfWork: freezed == typeOfWork ? _self.typeOfWork : typeOfWork // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,voltageLevel: freezed == voltageLevel ? _self.voltageLevel : voltageLevel // ignore: cast_nullable_to_non_nullable
as String?,certifications: freezed == certifications ? _self.certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<String>?,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isApplied: null == isApplied ? _self.isApplied : isApplied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UnifiedJobModel].
extension UnifiedJobModelPatterns on UnifiedJobModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnifiedJobModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnifiedJobModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnifiedJobModel value)  $default,){
final _that = this;
switch (_that) {
case _UnifiedJobModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnifiedJobModel value)?  $default,){
final _that = this;
switch (_that) {
case _UnifiedJobModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DocumentReference? reference,  String sharerId,  Map<String, dynamic> jobDetails,  bool matchesCriteria,  bool deleted,  int? local,  String? classification,  String company,  String location, @JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper)  GeoPoint? geoPoint,  int? hours,  double? wage,  String? sub,  String? jobClass,  int? localNumber,  String? qualifications,  String? datePosted,  String? jobDescription,  String? jobTitle,  String? perDiem,  String? agreement,  String? numberOfJobs, @JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper)  DateTime? timestamp,  String? startDate,  String? startTime,  List<int>? booksYourOn,  String? typeOfWork,  String? duration,  String? voltageLevel,  List<String>? certifications,  bool isSaved,  bool isApplied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnifiedJobModel() when $default != null:
return $default(_that.id,_that.reference,_that.sharerId,_that.jobDetails,_that.matchesCriteria,_that.deleted,_that.local,_that.classification,_that.company,_that.location,_that.geoPoint,_that.hours,_that.wage,_that.sub,_that.jobClass,_that.localNumber,_that.qualifications,_that.datePosted,_that.jobDescription,_that.jobTitle,_that.perDiem,_that.agreement,_that.numberOfJobs,_that.timestamp,_that.startDate,_that.startTime,_that.booksYourOn,_that.typeOfWork,_that.duration,_that.voltageLevel,_that.certifications,_that.isSaved,_that.isApplied);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DocumentReference? reference,  String sharerId,  Map<String, dynamic> jobDetails,  bool matchesCriteria,  bool deleted,  int? local,  String? classification,  String company,  String location, @JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper)  GeoPoint? geoPoint,  int? hours,  double? wage,  String? sub,  String? jobClass,  int? localNumber,  String? qualifications,  String? datePosted,  String? jobDescription,  String? jobTitle,  String? perDiem,  String? agreement,  String? numberOfJobs, @JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper)  DateTime? timestamp,  String? startDate,  String? startTime,  List<int>? booksYourOn,  String? typeOfWork,  String? duration,  String? voltageLevel,  List<String>? certifications,  bool isSaved,  bool isApplied)  $default,) {final _that = this;
switch (_that) {
case _UnifiedJobModel():
return $default(_that.id,_that.reference,_that.sharerId,_that.jobDetails,_that.matchesCriteria,_that.deleted,_that.local,_that.classification,_that.company,_that.location,_that.geoPoint,_that.hours,_that.wage,_that.sub,_that.jobClass,_that.localNumber,_that.qualifications,_that.datePosted,_that.jobDescription,_that.jobTitle,_that.perDiem,_that.agreement,_that.numberOfJobs,_that.timestamp,_that.startDate,_that.startTime,_that.booksYourOn,_that.typeOfWork,_that.duration,_that.voltageLevel,_that.certifications,_that.isSaved,_that.isApplied);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DocumentReference? reference,  String sharerId,  Map<String, dynamic> jobDetails,  bool matchesCriteria,  bool deleted,  int? local,  String? classification,  String company,  String location, @JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper)  GeoPoint? geoPoint,  int? hours,  double? wage,  String? sub,  String? jobClass,  int? localNumber,  String? qualifications,  String? datePosted,  String? jobDescription,  String? jobTitle,  String? perDiem,  String? agreement,  String? numberOfJobs, @JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper)  DateTime? timestamp,  String? startDate,  String? startTime,  List<int>? booksYourOn,  String? typeOfWork,  String? duration,  String? voltageLevel,  List<String>? certifications,  bool isSaved,  bool isApplied)?  $default,) {final _that = this;
switch (_that) {
case _UnifiedJobModel() when $default != null:
return $default(_that.id,_that.reference,_that.sharerId,_that.jobDetails,_that.matchesCriteria,_that.deleted,_that.local,_that.classification,_that.company,_that.location,_that.geoPoint,_that.hours,_that.wage,_that.sub,_that.jobClass,_that.localNumber,_that.qualifications,_that.datePosted,_that.jobDescription,_that.jobTitle,_that.perDiem,_that.agreement,_that.numberOfJobs,_that.timestamp,_that.startDate,_that.startTime,_that.booksYourOn,_that.typeOfWork,_that.duration,_that.voltageLevel,_that.certifications,_that.isSaved,_that.isApplied);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnifiedJobModel extends UnifiedJobModel {
  const _UnifiedJobModel({required this.id, this.reference, this.sharerId = '', final  Map<String, dynamic> jobDetails = const {}, this.matchesCriteria = false, this.deleted = false, this.local, this.classification, required this.company, required this.location, @JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper) this.geoPoint, this.hours, this.wage, this.sub, this.jobClass, this.localNumber, this.qualifications, this.datePosted, this.jobDescription, this.jobTitle, this.perDiem, this.agreement, this.numberOfJobs, @JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper) this.timestamp, this.startDate, this.startTime, final  List<int>? booksYourOn, this.typeOfWork, this.duration, this.voltageLevel, final  List<String>? certifications, this.isSaved = false, this.isApplied = false}): _jobDetails = jobDetails,_booksYourOn = booksYourOn,_certifications = certifications,super._();
  factory _UnifiedJobModel.fromJson(Map<String, dynamic> json) => _$UnifiedJobModelFromJson(json);

@override final  String id;
@override final  DocumentReference? reference;
@override@JsonKey() final  String sharerId;
 final  Map<String, dynamic> _jobDetails;
@override@JsonKey() Map<String, dynamic> get jobDetails {
  if (_jobDetails is EqualUnmodifiableMapView) return _jobDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_jobDetails);
}

@override@JsonKey() final  bool matchesCriteria;
@override@JsonKey() final  bool deleted;
@override final  int? local;
@override final  String? classification;
@override final  String company;
@override final  String location;
@override@JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper) final  GeoPoint? geoPoint;
@override final  int? hours;
@override final  double? wage;
@override final  String? sub;
@override final  String? jobClass;
@override final  int? localNumber;
@override final  String? qualifications;
@override final  String? datePosted;
@override final  String? jobDescription;
@override final  String? jobTitle;
@override final  String? perDiem;
@override final  String? agreement;
@override final  String? numberOfJobs;
@override@JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper) final  DateTime? timestamp;
@override final  String? startDate;
@override final  String? startTime;
 final  List<int>? _booksYourOn;
@override List<int>? get booksYourOn {
  final value = _booksYourOn;
  if (value == null) return null;
  if (_booksYourOn is EqualUnmodifiableListView) return _booksYourOn;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? typeOfWork;
@override final  String? duration;
@override final  String? voltageLevel;
 final  List<String>? _certifications;
@override List<String>? get certifications {
  final value = _certifications;
  if (value == null) return null;
  if (_certifications is EqualUnmodifiableListView) return _certifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isSaved;
@override@JsonKey() final  bool isApplied;

/// Create a copy of UnifiedJobModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnifiedJobModelCopyWith<_UnifiedJobModel> get copyWith => __$UnifiedJobModelCopyWithImpl<_UnifiedJobModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnifiedJobModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnifiedJobModel&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.sharerId, sharerId) || other.sharerId == sharerId)&&const DeepCollectionEquality().equals(other._jobDetails, _jobDetails)&&(identical(other.matchesCriteria, matchesCriteria) || other.matchesCriteria == matchesCriteria)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.local, local) || other.local == local)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.geoPoint, geoPoint) || other.geoPoint == geoPoint)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.wage, wage) || other.wage == wage)&&(identical(other.sub, sub) || other.sub == sub)&&(identical(other.jobClass, jobClass) || other.jobClass == jobClass)&&(identical(other.localNumber, localNumber) || other.localNumber == localNumber)&&(identical(other.qualifications, qualifications) || other.qualifications == qualifications)&&(identical(other.datePosted, datePosted) || other.datePosted == datePosted)&&(identical(other.jobDescription, jobDescription) || other.jobDescription == jobDescription)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.perDiem, perDiem) || other.perDiem == perDiem)&&(identical(other.agreement, agreement) || other.agreement == agreement)&&(identical(other.numberOfJobs, numberOfJobs) || other.numberOfJobs == numberOfJobs)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&const DeepCollectionEquality().equals(other._booksYourOn, _booksYourOn)&&(identical(other.typeOfWork, typeOfWork) || other.typeOfWork == typeOfWork)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.voltageLevel, voltageLevel) || other.voltageLevel == voltageLevel)&&const DeepCollectionEquality().equals(other._certifications, _certifications)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isApplied, isApplied) || other.isApplied == isApplied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,sharerId,const DeepCollectionEquality().hash(_jobDetails),matchesCriteria,deleted,local,classification,company,location,geoPoint,hours,wage,sub,jobClass,localNumber,qualifications,datePosted,jobDescription,jobTitle,perDiem,agreement,numberOfJobs,timestamp,startDate,startTime,const DeepCollectionEquality().hash(_booksYourOn),typeOfWork,duration,voltageLevel,const DeepCollectionEquality().hash(_certifications),isSaved,isApplied]);

@override
String toString() {
  return 'UnifiedJobModel(id: $id, reference: $reference, sharerId: $sharerId, jobDetails: $jobDetails, matchesCriteria: $matchesCriteria, deleted: $deleted, local: $local, classification: $classification, company: $company, location: $location, geoPoint: $geoPoint, hours: $hours, wage: $wage, sub: $sub, jobClass: $jobClass, localNumber: $localNumber, qualifications: $qualifications, datePosted: $datePosted, jobDescription: $jobDescription, jobTitle: $jobTitle, perDiem: $perDiem, agreement: $agreement, numberOfJobs: $numberOfJobs, timestamp: $timestamp, startDate: $startDate, startTime: $startTime, booksYourOn: $booksYourOn, typeOfWork: $typeOfWork, duration: $duration, voltageLevel: $voltageLevel, certifications: $certifications, isSaved: $isSaved, isApplied: $isApplied)';
}


}

/// @nodoc
abstract mixin class _$UnifiedJobModelCopyWith<$Res> implements $UnifiedJobModelCopyWith<$Res> {
  factory _$UnifiedJobModelCopyWith(_UnifiedJobModel value, $Res Function(_UnifiedJobModel) _then) = __$UnifiedJobModelCopyWithImpl;
@override @useResult
$Res call({
 String id, DocumentReference? reference, String sharerId, Map<String, dynamic> jobDetails, bool matchesCriteria, bool deleted, int? local, String? classification, String company, String location,@JsonKey(fromJson: _geoPointFromJsonHelper, toJson: _geoPointToJsonHelper) GeoPoint? geoPoint, int? hours, double? wage, String? sub, String? jobClass, int? localNumber, String? qualifications, String? datePosted, String? jobDescription, String? jobTitle, String? perDiem, String? agreement, String? numberOfJobs,@JsonKey(fromJson: _timestampFromJsonHelper, toJson: _timestampToJsonHelper) DateTime? timestamp, String? startDate, String? startTime, List<int>? booksYourOn, String? typeOfWork, String? duration, String? voltageLevel, List<String>? certifications, bool isSaved, bool isApplied
});




}
/// @nodoc
class __$UnifiedJobModelCopyWithImpl<$Res>
    implements _$UnifiedJobModelCopyWith<$Res> {
  __$UnifiedJobModelCopyWithImpl(this._self, this._then);

  final _UnifiedJobModel _self;
  final $Res Function(_UnifiedJobModel) _then;

/// Create a copy of UnifiedJobModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? sharerId = null,Object? jobDetails = null,Object? matchesCriteria = null,Object? deleted = null,Object? local = freezed,Object? classification = freezed,Object? company = null,Object? location = null,Object? geoPoint = freezed,Object? hours = freezed,Object? wage = freezed,Object? sub = freezed,Object? jobClass = freezed,Object? localNumber = freezed,Object? qualifications = freezed,Object? datePosted = freezed,Object? jobDescription = freezed,Object? jobTitle = freezed,Object? perDiem = freezed,Object? agreement = freezed,Object? numberOfJobs = freezed,Object? timestamp = freezed,Object? startDate = freezed,Object? startTime = freezed,Object? booksYourOn = freezed,Object? typeOfWork = freezed,Object? duration = freezed,Object? voltageLevel = freezed,Object? certifications = freezed,Object? isSaved = null,Object? isApplied = null,}) {
  return _then(_UnifiedJobModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as DocumentReference?,sharerId: null == sharerId ? _self.sharerId : sharerId // ignore: cast_nullable_to_non_nullable
as String,jobDetails: null == jobDetails ? _self._jobDetails : jobDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,matchesCriteria: null == matchesCriteria ? _self.matchesCriteria : matchesCriteria // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as int?,classification: freezed == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String?,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,geoPoint: freezed == geoPoint ? _self.geoPoint : geoPoint // ignore: cast_nullable_to_non_nullable
as GeoPoint?,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as int?,wage: freezed == wage ? _self.wage : wage // ignore: cast_nullable_to_non_nullable
as double?,sub: freezed == sub ? _self.sub : sub // ignore: cast_nullable_to_non_nullable
as String?,jobClass: freezed == jobClass ? _self.jobClass : jobClass // ignore: cast_nullable_to_non_nullable
as String?,localNumber: freezed == localNumber ? _self.localNumber : localNumber // ignore: cast_nullable_to_non_nullable
as int?,qualifications: freezed == qualifications ? _self.qualifications : qualifications // ignore: cast_nullable_to_non_nullable
as String?,datePosted: freezed == datePosted ? _self.datePosted : datePosted // ignore: cast_nullable_to_non_nullable
as String?,jobDescription: freezed == jobDescription ? _self.jobDescription : jobDescription // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,perDiem: freezed == perDiem ? _self.perDiem : perDiem // ignore: cast_nullable_to_non_nullable
as String?,agreement: freezed == agreement ? _self.agreement : agreement // ignore: cast_nullable_to_non_nullable
as String?,numberOfJobs: freezed == numberOfJobs ? _self.numberOfJobs : numberOfJobs // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,booksYourOn: freezed == booksYourOn ? _self._booksYourOn : booksYourOn // ignore: cast_nullable_to_non_nullable
as List<int>?,typeOfWork: freezed == typeOfWork ? _self.typeOfWork : typeOfWork // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,voltageLevel: freezed == voltageLevel ? _self.voltageLevel : voltageLevel // ignore: cast_nullable_to_non_nullable
as String?,certifications: freezed == certifications ? _self._certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<String>?,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isApplied: null == isApplied ? _self.isApplied : isApplied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
