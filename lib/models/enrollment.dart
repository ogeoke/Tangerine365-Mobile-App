import 'package:json_annotation/json_annotation.dart';
import 'package:sevenup_mobile/models/course.dart';

part 'enrollment.g.dart';

@JsonSerializable()
class Enrollment {
  Enrollment({
    this.recommendByCourseName,
    this.recommendByCourseId,
    this.courselist,
  });

  @JsonKey(name: 'recommend_by_course_name')
  final String? recommendByCourseName;
  @JsonKey(name: 'recommend_by_course_id')
  final String? recommendByCourseId;
  @JsonKey(name: 'courselist')
  final List<Course>? courselist;

  Map<String, dynamic> toJson() => _$EnrollmentToJson(this);

  static Enrollment fromJson(Map<String, dynamic> json) =>
      _$EnrollmentFromJson(json);
}
