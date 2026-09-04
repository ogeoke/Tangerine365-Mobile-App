import 'package:json_annotation/json_annotation.dart';

part 'course_module.g.dart';

@JsonSerializable()
class CourseModule {
  CourseModule({
    required this.name,
    this.nameCourse,
    this.idItem,
    required this.idCourse,
    this.visibile,
    this.type,
    this.src,
    this.loStatus,
  });

  @JsonKey(name: 'name_lo')
  final String name;
  @JsonKey(name: 'name_course')
  final String? nameCourse;
  @JsonKey(name: 'id_item')
  final String? idItem;
  @JsonKey(name: 'id_course')
  final String idCourse;
  @JsonKey(name: 'visibile')
  final String? visibile;
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'src')
  final String? src;
  @JsonKey(name: 'lo_status')
  final bool? loStatus;

  Map<String, dynamic> toJson() => _$CourseModuleToJson(this);

  static CourseModule fromJson(Map<String, dynamic> json) =>
      _$CourseModuleFromJson(json);
}
