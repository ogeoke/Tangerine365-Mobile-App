import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

part 'course_item.g.dart';

enum CourseItemStatus {
  notStarted('not-started', Color.fromARGB(255, 252, 2, 2)),
  inProgress('in-progress', Color(0xffF5AA32)),
  completed('completed', Color(0xff1DE73F));

  final String status;
  final Color color;
  const CourseItemStatus(this.status, this.color);
}

extension CourseItemStatusEnum on CourseItem {
  CourseItemStatus get status => CourseItemStatus.values.firstWhere(
        (v) => v.name == loStatus,
        orElse: () => CourseItemStatus.notStarted,
      );
}

@JsonSerializable()
class CourseItem {
  CourseItem({
    required this.name,
    this.nameCourse,
    this.idItem,
    this.idCourse,
    this.visibile,
    this.type,
    this.src,
    this.loStatus,
    this.proctoringEnabled,
  });

  @JsonKey(name: 'name_lo')
  final String name;
  @JsonKey(name: 'name_course')
  final String? nameCourse;
  @JsonKey(name: 'id_item')
  final String? idItem;
  @JsonKey(name: 'id_course')
  final String? idCourse;
  @JsonKey(name: 'visibile')
  final String? visibile;
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'src')
  final String? src;
  @JsonKey(name: 'lo_status')
  final String? loStatus;

  @JsonKey(name: 'proctoring_enabled')
  final bool? proctoringEnabled;

  Map<String, dynamic> toJson() => _$CourseItemToJson(this);

  static CourseItem fromJson(Map<String, dynamic> json) =>
      _$CourseItemFromJson(json);
}
