// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enrollment _$EnrollmentFromJson(Map<String, dynamic> json) => Enrollment(
      recommendByCourseName: json['recommend_by_course_name'] as String?,
      recommendByCourseId: json['recommend_by_course_id'] as String?,
      courselist: (json['courselist'] as List<dynamic>?)
          ?.map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EnrollmentToJson(Enrollment instance) =>
    <String, dynamic>{
      'recommend_by_course_name': instance.recommendByCourseName,
      'recommend_by_course_id': instance.recommendByCourseId,
      'courselist': instance.courselist,
    };
