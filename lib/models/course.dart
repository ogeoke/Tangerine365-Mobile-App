import 'package:json_annotation/json_annotation.dart';

import 'can_enter.dart';
import 'course_stats.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  Course({
    this.courseId,
    this.idCourse,
    this.code,
    this.courseName,
    this.name,
    this.courseDescription,
    this.courseBoxDescription,
    this.status,
    this.selling,
    this.price,
    this.subscribeMethod,
    this.unsubscribeMethod,
    this.courseEdition,
    this.courseType,
    this.canSubscribe,
    this.subStartDate,
    this.subEndDate,
    this.dateBegin,
    this.dateEnd,
    this.courseLink,
    this.imgCourse,
    this.categoryId,
    this.category,
    this.enrolled,
    this.courseImage,
    this.userStatus,
    this.isEnrolled,
    this.canEnter,
    this.courseBoxEnabled,
    this.userCanUnsubscribe,
    this.canEnter1,
    this.dateSubscribed,
    this.dateFirstAccess,
    this.courseStats,
  });

  @JsonKey(name: 'course_id')
  final String? courseId;
  @JsonKey(name: 'idCourse')
  final String? idCourse;
  @JsonKey(name: 'code')
  final String? code;
  @JsonKey(name: 'course_name')
  final String? courseName;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'course_description')
  final String? courseDescription;
  @JsonKey(name: 'course_box_description')
  final String? courseBoxDescription;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'selling')
  final String? selling;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'subscribe_method')
  final String? subscribeMethod;
  @JsonKey(name: 'unsubscribe_method')
  final String? unsubscribeMethod;
  @JsonKey(name: 'course_edition')
  final String? courseEdition;
  @JsonKey(name: 'course_type')
  final String? courseType;
  @JsonKey(name: 'can_subscribe')
  final String? canSubscribe;
  @JsonKey(name: 'sub_start_date')
  final String? subStartDate;
  @JsonKey(name: 'sub_end_date')
  final String? subEndDate;
  @JsonKey(name: 'date_begin')
  final String? dateBegin;
  @JsonKey(name: 'date_end')
  final String? dateEnd;
  @JsonKey(name: 'course_link')
  final String? courseLink;
  @JsonKey(name: 'img_course')
  final String? imgCourse;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'enrolled')
  final dynamic enrolled;
  @JsonKey(name: 'course_image')
  final String? courseImage;
  @JsonKey(name: 'user_status')
  final String? userStatus;
  @JsonKey(name: 'is_enrolled')
  final bool? isEnrolled;
  @JsonKey(name: 'canEnter')
  final bool? canEnter;
  @JsonKey(name: 'courseBoxEnabled')
  final bool? courseBoxEnabled;
  @JsonKey(name: 'userCanUnsubscribe')
  final bool? userCanUnsubscribe;
  @JsonKey(name: 'can_enter')
  final CanEnter? canEnter1;
  @JsonKey(name: 'date_subscribed')
  final String? dateSubscribed;
  @JsonKey(name: 'date_first_access')
  final String? dateFirstAccess;
  @JsonKey(name: 'course_stats')
  final CourseStats? courseStats;
  Map<String, dynamic> toJson() => _$CourseToJson(this);

  static Course fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
