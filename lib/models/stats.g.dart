// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      general: json['general'] == null
          ? null
          : General.fromJson(json['general'] as Map<String, dynamic>),
      competenciesAttained: (json['competencies_attained'] as num?)?.toInt(),
      certificatesAttained: (json['certificates_attained'] as num?)?.toInt(),
      lastLogin: json['last_login'] as String?,
      courseAttendance: json['course_attendance'] == null
          ? null
          : Learning.fromJson(
              json['course_attendance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'general': instance.general,
      'competencies_attained': instance.competenciesAttained,
      'certificates_attained': instance.certificatesAttained,
      'last_login': instance.lastLogin,
      'course_attendance': instance.courseAttendance,
    };
