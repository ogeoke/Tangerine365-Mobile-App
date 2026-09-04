import 'package:json_annotation/json_annotation.dart';

part 'course_stats.g.dart';

@JsonSerializable()
class CourseStats {
  CourseStats({
    this.status,
    this.dateFirstAccess,
    this.dateComplete,
  });

  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'date_first_access')
  final String? dateFirstAccess;
  @JsonKey(name: 'date_complete')
  final String? dateComplete;

  Map<String, dynamic> toJson() => _$CourseStatsToJson(this);

  static CourseStats fromJson(Map<String, dynamic> json) =>
      _$CourseStatsFromJson(json);
}
