import 'package:json_annotation/json_annotation.dart';

part 'course_progress.g.dart';

@JsonSerializable()
class CourseProgress {
  CourseProgress({
    this.completePercentage,
    this.failedPercentage,
  });

  @JsonKey(name: 'complete_percentage')
  final double? completePercentage;
  @JsonKey(name: 'failed_percentage')
  final double? failedPercentage;

  Map<String, dynamic> toJson() => _$CourseProgressToJson(this);

  static CourseProgress fromJson(Map<String, dynamic> json) =>
      _$CourseProgressFromJson(json);
}
