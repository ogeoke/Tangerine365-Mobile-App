// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedCourse _$AssignedCourseFromJson(Map<String, dynamic> json) =>
    AssignedCourse(
      course: Course.fromJson(json['course_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssignedCourseToJson(AssignedCourse instance) =>
    <String, dynamic>{'course_info': instance.course};
