// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_module.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModule _$CourseModuleFromJson(Map<String, dynamic> json) => CourseModule(
      name: json['name_lo'] as String,
      nameCourse: json['name_course'] as String?,
      idItem: json['id_item'] as String?,
      idCourse: json['id_course'] as String,
      visibile: json['visibile'] as String?,
      type: json['type'] as String?,
      src: json['src'] as String?,
      loStatus: json['lo_status'] as bool?,
    );

Map<String, dynamic> _$CourseModuleToJson(CourseModule instance) =>
    <String, dynamic>{
      'name_lo': instance.name,
      'name_course': instance.nameCourse,
      'id_item': instance.idItem,
      'id_course': instance.idCourse,
      'visibile': instance.visibile,
      'type': instance.type,
      'src': instance.src,
      'lo_status': instance.loStatus,
    };
