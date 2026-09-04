// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseItem _$CourseItemFromJson(Map<String, dynamic> json) => CourseItem(
      name: json['name_lo'] as String,
      nameCourse: json['name_course'] as String?,
      idItem: json['id_item'] as String?,
      idCourse: json['id_course'] as String?,
      visibile: json['visibile'] as String?,
      type: json['type'] as String?,
      src: json['src'] as String?,
      loStatus: json['lo_status'] as String?,
      proctoringEnabled: json['proctoring_enabled'] as bool?,
    );

Map<String, dynamic> _$CourseItemToJson(CourseItem instance) =>
    <String, dynamic>{
      'name_lo': instance.name,
      'name_course': instance.nameCourse,
      'id_item': instance.idItem,
      'id_course': instance.idCourse,
      'visibile': instance.visibile,
      'type': instance.type,
      'src': instance.src,
      'lo_status': instance.loStatus,
      'proctoring_enabled': instance.proctoringEnabled,
    };
