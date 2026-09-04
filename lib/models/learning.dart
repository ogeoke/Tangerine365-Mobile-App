import 'package:json_annotation/json_annotation.dart';

part 'learning.g.dart';

@JsonSerializable()
class Learning {
  Learning({
    this.subscribed,
    this.totalCourses,
    this.waiting,
    this.subscriptionToConfirm,
    this.notStarted,
    this.inProgress,
    this.completed,
    this.suspended,
    this.overbooking,
    this.others,
    this.totalNoCourseCatalog,
  });

  @JsonKey(name: 'subscribed')
  final int? subscribed;
  @JsonKey(name: 'total_courses')
  final int? totalCourses;
  @JsonKey(name: 'waiting')
  final int? waiting;
  @JsonKey(name: 'subscription_to_confirm')
  final int? subscriptionToConfirm;
  @JsonKey(name: 'not-started')
  final int? notStarted;
  @JsonKey(name: 'in-progress')
  final int? inProgress;
  @JsonKey(name: 'completed')
  final int? completed;
  @JsonKey(name: 'suspended')
  final int? suspended;
  @JsonKey(name: 'overbooking')
  final int? overbooking;
  @JsonKey(name: 'others')
  final int? others;
  @JsonKey(name: 'total_no_course_catalog')
  final int? totalNoCourseCatalog;

  Map<String, dynamic> toJson() => _$LearningToJson(this);

  static Learning fromJson(Map<String, dynamic> json) =>
      _$LearningFromJson(json);
}
