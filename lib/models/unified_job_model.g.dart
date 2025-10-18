// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnifiedJobModel _$UnifiedJobModelFromJson(Map<String, dynamic> json) =>
    _UnifiedJobModel(
      id: json['id'] as String,
      sharerId: json['sharerId'] as String? ?? '',
      jobDetails: json['jobDetails'] as Map<String, dynamic>? ?? const {},
      matchesCriteria: json['matchesCriteria'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      local: (json['local'] as num?)?.toInt(),
      classification: json['classification'] as String?,
      company: json['company'] as String,
      location: json['location'] as String,
      geoPoint: const OptionalGeoPointConverter().fromJson(json['geoPoint']),
      hours: (json['hours'] as num?)?.toInt(),
      wage: (json['wage'] as num?)?.toDouble(),
      sub: json['sub'] as String?,
      jobClass: json['jobClass'] as String?,
      localNumber: (json['localNumber'] as num?)?.toInt(),
      qualifications: json['qualifications'] as String?,
      datePosted: json['datePosted'] as String?,
      jobDescription: json['jobDescription'] as String?,
      jobTitle: json['jobTitle'] as String?,
      perDiem: json['perDiem'] as String?,
      agreement: json['agreement'] as String?,
      numberOfJobs: json['numberOfJobs'] as String?,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      startDate: json['startDate'] as String?,
      startTime: json['startTime'] as String?,
      booksYourOn: (json['booksYourOn'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      typeOfWork: json['typeOfWork'] as String?,
      duration: json['duration'] as String?,
      voltageLevel: json['voltageLevel'] as String?,
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isSaved: json['isSaved'] as bool? ?? false,
      isApplied: json['isApplied'] as bool? ?? false,
    );

Map<String, dynamic> _$UnifiedJobModelToJson(_UnifiedJobModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sharerId': instance.sharerId,
      'jobDetails': instance.jobDetails,
      'matchesCriteria': instance.matchesCriteria,
      'deleted': instance.deleted,
      'local': instance.local,
      'classification': instance.classification,
      'company': instance.company,
      'location': instance.location,
      'geoPoint': const OptionalGeoPointConverter().toJson(instance.geoPoint),
      'hours': instance.hours,
      'wage': instance.wage,
      'sub': instance.sub,
      'jobClass': instance.jobClass,
      'localNumber': instance.localNumber,
      'qualifications': instance.qualifications,
      'datePosted': instance.datePosted,
      'jobDescription': instance.jobDescription,
      'jobTitle': instance.jobTitle,
      'perDiem': instance.perDiem,
      'agreement': instance.agreement,
      'numberOfJobs': instance.numberOfJobs,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'startDate': instance.startDate,
      'startTime': instance.startTime,
      'booksYourOn': instance.booksYourOn,
      'typeOfWork': instance.typeOfWork,
      'duration': instance.duration,
      'voltageLevel': instance.voltageLevel,
      'certifications': instance.certifications,
      'isSaved': instance.isSaved,
      'isApplied': instance.isApplied,
    };
