// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseStats _$CourseStatsFromJson(Map<String, dynamic> json) => CourseStats(
      status: json['status'] as String?,
      dateFirstAccess: json['date_first_access'] as String?,
      dateComplete: json['date_complete'] as String?,
    );

Map<String, dynamic> _$CourseStatsToJson(CourseStats instance) =>
    <String, dynamic>{
      'status': instance.status,
      'date_first_access': instance.dateFirstAccess,
      'date_complete': instance.dateComplete,
    };
