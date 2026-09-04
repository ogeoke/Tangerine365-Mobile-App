import 'package:json_annotation/json_annotation.dart';

import 'course.dart';

part 'assigned_course.g.dart';

@JsonSerializable()
class AssignedCourse {
  AssignedCourse({
    required this.course,
  });

  @JsonKey(name: 'course_info')
  final Course course;

  Map<String, dynamic> toJson() => _$AssignedCourseToJson(this);

  static AssignedCourse fromJson(Map<String, dynamic> json) =>
      _$AssignedCourseFromJson(json);
}
