// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseProgress _$CourseProgressFromJson(Map<String, dynamic> json) =>
    CourseProgress(
      completePercentage: (json['complete_percentage'] as num?)?.toDouble(),
      failedPercentage: (json['failed_percentage'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CourseProgressToJson(CourseProgress instance) =>
    <String, dynamic>{
      'complete_percentage': instance.completePercentage,
      'failed_percentage': instance.failedPercentage,
    };
