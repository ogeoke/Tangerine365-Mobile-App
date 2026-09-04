// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

General _$GeneralFromJson(Map<String, dynamic> json) => General(
      login: json['login'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      fullname: json['fullname'] as String?,
      userType: json['user_type'] as String?,
      userTypesID: json['user_types_ID'] as String?,
      totalLessons: (json['total_lessons'] as num?)?.toInt(),
      totalCourses: (json['total_courses'] as num?)?.toInt(),
      language: json['language'] as String?,
      active: json['active'] as String?,
      activeStr: json['active_str'] as String?,
      joined: json['joined'] as String?,
      joinedStr: json['joined_str'] as String?,
      avatar: json['avatar'] as String?,
      totalLoginTimeUnformated:
          (json['total_login_time_unformated'] as num?)?.toInt(),
      totalLoginTime: json['total_login_time'] as String?,
      memberSince: json['member_since'] as String?,
    );

Map<String, dynamic> _$GeneralToJson(General instance) => <String, dynamic>{
      'login': instance.login,
      'name': instance.name,
      'surname': instance.surname,
      'fullname': instance.fullname,
      'user_type': instance.userType,
      'user_types_ID': instance.userTypesID,
      'total_lessons': instance.totalLessons,
      'total_courses': instance.totalCourses,
      'language': instance.language,
      'active': instance.active,
      'active_str': instance.activeStr,
      'joined': instance.joined,
      'joined_str': instance.joinedStr,
      'avatar': instance.avatar,
      'total_login_time_unformated': instance.totalLoginTimeUnformated,
      'total_login_time': instance.totalLoginTime,
      'member_since': instance.memberSince,
    };
